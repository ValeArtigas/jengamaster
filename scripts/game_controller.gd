class_name GameController
extends Node3D

signal exit_requested

enum State { BUILDING, TURN, DRAGGING, PLACING, TRIVIA, GAME_OVER }

const BLOCK_LAYER := 2
const DRAG_STIFFNESS := 9.0
const MAX_DRAG_SPEED := 8.0
const EXTRACT_RADIUS := 2.6
const PLACE_TIME := 0.45

var camera: CameraOrbit
var env_builder: EnvironmentBuilder
var tower: TowerBuilder
var monitor: TowerMonitor
var hud: HUD
var modal: TriviaModal
var result: ResultOverlay
var banner: TurnBanner

var _ui: CanvasLayer
var _state: int = State.BUILDING

var _grabbed: JengaBlock = null
var _drag_offset: Vector3 = Vector3.ZERO
var _drag_target: Vector3 = Vector3.ZERO
var _has_drag_target: bool = false

var _touches: Dictionary = {}
var _last_pinch: float = 0.0
var _mode: int = 0

var _collapse_pending: bool = false
var _resolving: bool = false

var _pending_block: JengaBlock = null
var _pending_transform: Dictionary = {}

func _ready() -> void:
	var floors := randi_range(12, 15)
	var theme := GameState.selected_env

	env_builder = EnvironmentBuilder.new()
	add_child(env_builder)
	env_builder.build(theme)

	tower = TowerBuilder.new()
	add_child(tower)
	tower.build(floors, theme)
	GameState.configure_tower(tower.highest_floor() + 1)

	monitor = TowerMonitor.new()
	add_child(monitor)
	monitor.setup(tower.blocks, 0.0)
	monitor.tower_collapsed.connect(_on_tower_collapsed)

	camera = CameraOrbit.new()
	add_child(camera)
	camera.target = Vector3(0.0, tower.tower_height() * 0.38, 0.0)
	camera.distance = 17.0
	camera.make_current()

	_build_ui()
	call_deferred("_begin")

func _build_ui() -> void:
	_ui = CanvasLayer.new()
	add_child(_ui)

	hud = HUD.new()
	_ui.add_child(hud)
	hud.menu_pressed.connect(_to_menu)
	hud.rebuild_for_match()

	banner = TurnBanner.new()
	_ui.add_child(banner)

	modal = TriviaModal.new()
	_ui.add_child(modal)
	modal.answered.connect(_on_trivia_answered)

	result = ResultOverlay.new()
	_ui.add_child(result)

func _begin() -> void:
	await get_tree().create_timer(0.6).timeout
	if not is_instance_valid(self):
		return
	monitor.enabled = true
	_start_turn()

func _start_turn() -> void:
	_state = State.TURN
	_resolving = false
	_collapse_pending = false
	hud.set_turn(GameState.current_player)
	hud.update_all()
	banner.announce("¡Turno de %s!" % GameState.active().name, GameState.active().color)
	AudioManager.play("click")

func _physics_process(_delta: float) -> void:
	if _state == State.DRAGGING and _grabbed != null:
		if not is_instance_valid(_grabbed):
			_cancel_grab()
			return
		var desired := (_drag_target - _grabbed.global_position) * DRAG_STIFFNESS
		desired = desired.limit_length(MAX_DRAG_SPEED)
		_grabbed.linear_velocity = desired
		_grabbed.angular_velocity = _grabbed.angular_velocity * 0.4

func _unhandled_input(event: InputEvent) -> void:
	if _state != State.TURN and _state != State.DRAGGING:
		return
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)

func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		_touches[event.index] = event.position
		if _touches.size() == 1:
			_begin_pointer(event.position)
		else:
			_cancel_grab()
			_mode = 0
	else:
		_touches.erase(event.index)
		if _touches.size() == 0:
			_end_pointer()
		else:
			_last_pinch = 0.0
			_cancel_grab()
			_mode = 0

func _handle_drag(event: InputEventScreenDrag) -> void:
	_touches[event.index] = event.position
	if _touches.size() >= 2:
		_pinch()
		return
	if _mode == 2 and _grabbed != null:
		_update_drag_target(event.position)
	elif _mode == 1:
		camera.orbit(event.relative)

func _begin_pointer(screen_pos: Vector2) -> void:
	if _try_grab(screen_pos):
		_mode = 2
	else:
		_mode = 1

func _try_grab(screen_pos: Vector2) -> bool:
	var from := camera.project_ray_origin(screen_pos)
	var to := from + camera.project_ray_normal(screen_pos) * 500.0
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = BLOCK_LAYER
	query.collide_with_areas = false
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return false
	var collider = hit.get("collider")
	if not (collider is JengaBlock):
		return false
	if not tower.is_extractable(collider):
		_reject_block(collider)
		return false
	_grabbed = collider
	_grabbed.is_dragged = true
	_grabbed.set_highlight(true)
	_grabbed.sleeping = false
	var plane_y: float = _grabbed.global_position.y
	var world: Variant = _ray_plane_point(screen_pos, plane_y)
	_drag_offset = (world - _grabbed.global_position) if world != null else Vector3.ZERO
	_drag_target = _grabbed.global_position
	_has_drag_target = true
	_state = State.DRAGGING
	AudioManager.play("click")
	return true

func _reject_block(block: JengaBlock) -> void:
	block.set_neon(true, Color("#ff3d3d"))
	AudioManager.play("wrong")
	var tw := block.create_tween()
	tw.tween_interval(0.35)
	tw.tween_callback(func() -> void:
		if is_instance_valid(block):
			block.set_neon(false))
	hud.flash_hint("No puedes tocar los dos pisos superiores. Saca bloques mas abajo.")

func _update_drag_target(screen_pos: Vector2) -> void:
	if not is_instance_valid(_grabbed):
		return
	var world: Variant = _ray_plane_point(screen_pos, _grabbed.global_position.y)
	if world != null:
		_drag_target = world - _drag_offset

func _ray_plane_point(screen_pos: Vector2, plane_y: float) -> Variant:
	var from := camera.project_ray_origin(screen_pos)
	var dir := camera.project_ray_normal(screen_pos)
	if absf(dir.y) < 0.001:
		return null
	var t := (plane_y - from.y) / dir.y
	if t < 0.0:
		return null
	return from + dir * t

func _end_pointer() -> void:
	if _mode == 2 and _grabbed != null and is_instance_valid(_grabbed):
		_release_grab()
	_mode = 0
	_last_pinch = 0.0

func _release_grab() -> void:
	var block := _grabbed
	block.is_dragged = false
	block.set_highlight(false)
	_grabbed = null
	_has_drag_target = false
	var flat := Vector2(block.global_position.x, block.global_position.z)
	if flat.length() > EXTRACT_RADIUS and tower.is_extractable(block):
		_extract_and_lift(block)
	else:
		_state = State.TURN

func _cancel_grab() -> void:
	if _grabbed != null and is_instance_valid(_grabbed):
		_grabbed.is_dragged = false
		_grabbed.set_highlight(false)
	_grabbed = null
	_has_drag_target = false
	if _state == State.DRAGGING:
		_state = State.TURN

func _pinch() -> void:
	var pts: Array = _touches.values()
	if pts.size() < 2:
		return
	var d: float = (pts[0] as Vector2).distance_to(pts[1] as Vector2)
	if _last_pinch > 0.0 and d > 0.0:
		camera.zoom_by(d / _last_pinch)
	_last_pinch = d

# Saca el bloque y lo eleva hasta el tope. La trivia se dispara al terminar.
func _extract_and_lift(block: JengaBlock) -> void:
	var target := tower.next_top_transform()
	if target.is_empty():
		_state = State.TURN
		return
	_state = State.PLACING
	tower.remove_block(block)
	monitor.remove_block(block)
	GameState.active().extracted += 1
	block.extracted = true
	block.begin_place()
	AudioManager.play("pop")
	_spawn_confetti(block.global_position, 30)
	_update_stats()

	_pending_transform = target
	var pos: Vector3 = target["position"]
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(block, "global_position", pos, PLACE_TIME)
	tw.tween_callback(func() -> void: _on_block_on_top(block))

func _on_block_on_top(block: JengaBlock) -> void:
	if _state != State.PLACING:
		return
	_pending_block = block
	block.global_position = _pending_transform["position"]
	_state = State.TRIVIA
	monitor.check_stability()
	if _state == State.GAME_OVER:
		return
	_open_trivia()

func _open_trivia() -> void:
	var category := Trivia.CATEGORY_UNIDAD if randf() < 0.5 else Trivia.CATEGORY_CULTURA
	var question := Trivia.random_question(category)
	if question.is_empty():
		question = Trivia.random_question()
	if question.is_empty():
		_on_trivia_answered(true, category)
		return
	modal.open(question)

func _on_trivia_answered(correct: bool, category: String) -> void:
	if _state == State.GAME_OVER:
		return
	modal.close()
	_state = State.TURN
	var p: GameState.PlayerData = GameState.active()
	if correct:
		_consolidate_pending()
		if category == Trivia.CATEGORY_UNIDAD:
			GameState.add_star(1)
		else:
			GameState.add_coin(1)
		p.correct += 1
		AudioManager.play("correct")
		_spawn_confetti(_pending_world_pos() + Vector3(0, 2, 0), 60)
	else:
		_fail_pending()
		p.wrong += 1
		AudioManager.play("wrong")
		_shake_tower()
		GameState.lose_life()
	_pending_block = null
	_pending_transform = {}
	_update_stats()
	_resolve_turn()

# Acierto: el bloque se consolida, la torre crece y se asignan puntos por altura.
func _consolidate_pending() -> void:
	var block := _pending_block
	if not is_instance_valid(block):
		return
	var t := _pending_transform
	block.finalize_place(t["position"], t["rot_y"], t["floor_index"])
	tower.add_block(block)
	tower.floors = maxi(tower.floors, int(t["floor_index"]) + 1)
	GameState.set_tower_height(tower.highest_floor() + 1)
	GameState.register_stack(GameState.stack_points_for(tower.highest_floor() + 1))

# Error: el bloque desaparece y deja un vacio en la torre.
func _fail_pending() -> void:
	var block := _pending_block
	if is_instance_valid(block):
		block.vanish()
	monitor.check_stability()

func _pending_world_pos() -> Vector3:
	var t := _pending_transform
	return t.get("position", camera.target)

func _resolve_turn() -> void:
	if _resolving:
		return
	_resolving = true
	await get_tree().create_timer(0.5).timeout
	if _state == State.GAME_OVER:
		return
	if _collapse_pending:
		_end_game_collapse()
		return
	var p: GameState.PlayerData = GameState.active()
	if not p.alive:
		_end_game_eliminated()
		return
	if GameState.mode == GameState.Mode.VERSUS and GameState.alive_players().size() <= 1:
		_end_game_eliminated()
		return
	if GameState.goal_reached():
		_end_game_score()
		return
	if tower.remaining() <= 2 or not tower.has_eligible_block():
		_end_game_score()
		return
	GameState.advance_turn()
	_start_turn()

func _on_tower_collapsed() -> void:
	if _state == State.GAME_OVER:
		return
	_collapse_pending = true
	AudioManager.play("lose")
	if _state == State.TRIVIA:
		modal.close()
		_end_game_collapse()
	elif _state == State.TURN or _state == State.DRAGGING or _state == State.PLACING:
		_end_game_collapse()

func _end_game_collapse() -> void:
	if _state == State.GAME_OVER:
		return
	_state = State.GAME_OVER
	_cancel_grab()
	monitor.enabled = false
	_shake_tower()
	_spawn_confetti(Vector3(0, 3, 0), 150)
	var loser := GameState.current_player
	if GameState.mode == GameState.Mode.VERSUS:
		_finish_versus(loser, "La torre se derrumbó en el turno de %s." % GameState.players[loser].name)
	else:
		_finish_single("¡LA TORRE SE DERRUMBÓ!")

func _end_game_eliminated() -> void:
	if _state == State.GAME_OVER:
		return
	_state = State.GAME_OVER
	monitor.enabled = false
	var loser := GameState.current_player
	if GameState.mode == GameState.Mode.VERSUS:
		_finish_versus(loser, "%s se quedó sin vidas." % GameState.players[loser].name)
	else:
		_finish_single("¡SIN VIDAS!")

func _end_game_score() -> void:
	if _state == State.GAME_OVER:
		return
	_state = State.GAME_OVER
	monitor.enabled = false
	_spawn_confetti(Vector3(0, 3, 0), 120)
	if GameState.mode == GameState.Mode.VERSUS:
		AudioManager.play("win")
		var a: GameState.PlayerData = GameState.players[0]
		var b: GameState.PlayerData = GameState.players[1]
		var sa := GameState.score_of(a)
		var sb := GameState.score_of(b)
		var title := "¡EMPATE!"
		var winner_text := "Ambos terminaron igual."
		if sa != sb:
			var winner := a if sa > sb else b
			title = "¡%s GANA!" % winner.name.to_upper()
			winner_text = "%s se quedó con la torre." % winner.name
		result.open(title, [
			winner_text,
			"Altura final: %d pisos · Apilados: %d" % [GameState.tower_height, GameState.stacked_blocks],
			"%s → %d pts" % [a.name, sa],
			"%s → %d pts" % [b.name, sb]
		], [
			{"text": "REVANCHA", "cb": _restart, "color": Color("#1de9b6")},
			{"text": "MENÚ", "cb": _to_menu, "color": Color("#ff5252")}
		])
	elif GameState.goal_reached():
		_finish_single("¡CIMA ALCANZADA!")
	else:
		_finish_single("¡TORRE COMPLETADA!")

func _finish_versus(loser: int, reason: String) -> void:
	AudioManager.play("win")
	var winner := (loser + 1) % GameState.players.size()
	var wp: GameState.PlayerData = GameState.players[winner]
	result.open("¡%s GANA!" % wp.name.to_upper(), [
		reason,
		"Ganador: %s" % wp.name,
		"★ %d    ● %d    Aciertos: %d" % [wp.stars, wp.coins, wp.correct]
	], [
		{"text": "REVANCHA", "cb": _restart, "color": Color("#1de9b6")},
		{"text": "MENÚ", "cb": _to_menu, "color": Color("#ff5252")}
	])

func _finish_single(reason: String) -> void:
	AudioManager.play("win" if GameState.goal_reached() else "lose")
	var p: GameState.PlayerData = GameState.players[0]
	var sc := GameState.score_of(p)
	GameState.record_score(sc)
	result.open(reason, [
		"Puntaje: %d" % sc,
		"Récord: %d" % GameState.best_score,
		"Altura alcanzada: %d pisos (meta %d)" % [GameState.tower_height, GameState.goal_height],
		"Bloques apilados: %d" % p.blocks,
		"Aciertos: %d    ★ %d    ● %d" % [p.correct, p.stars, p.coins]
	], [
		{"text": "REINTENTAR", "cb": _restart, "color": Color("#1de9b6")},
		{"text": "MENÚ", "cb": _to_menu, "color": Color("#ff5252")}
	])

func _restart() -> void:
	get_tree().reload_current_scene()

func _to_menu() -> void:
	exit_requested.emit()

func _update_stats() -> void:
	hud.update_all()

func _shake_tower() -> void:
	var base := tower.position
	var tw := tower.create_tween()
	tw.tween_property(tower, "position:x", base.x + 0.18, 0.04)
	tw.tween_property(tower, "position:x", base.x - 0.18, 0.04)
	tw.tween_property(tower, "position:x", base.x + 0.12, 0.04)
	tw.tween_property(tower, "position:x", base.x, 0.05)

func _spawn_confetti(pos: Vector3, amount: int) -> void:
	var p := GPUParticles3D.new()
	p.amount = amount
	p.lifetime = 1.8
	p.one_shot = true
	p.explosiveness = 1.0
	p.position = pos
	p.local_coords = false

	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 0.6
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 70.0
	mat.initial_velocity_min = 4.0
	mat.initial_velocity_max = 10.0
	mat.gravity = Vector3(0, -9.0, 0)
	mat.angular_velocity_min = -360.0
	mat.angular_velocity_max = 360.0

	var grad := Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 0.33, 0.66, 1.0])
	grad.colors = PackedColorArray([
		Color("#ff5298"), Color("#1de9b6"), Color("#ffd54f"), Color("#3d5afe")
	])
	var gt := GradientTexture1D.new()
	gt.gradient = grad
	mat.color_ramp = gt
	p.process_material = mat

	var quad := QuadMesh.new()
	quad.size = Vector2(0.16, 0.26)
	var mm := StandardMaterial3D.new()
	mm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mm.vertex_color_use_as_albedo = true
	mm.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	quad.material = mm
	p.draw_pass_1 = quad

	add_child(p)
	p.emitting = true
	var timer := get_tree().create_timer(p.lifetime + 0.4)
	timer.timeout.connect(func() -> void:
		if is_instance_valid(p):
			p.queue_free())
