class_name Game
extends Control

signal menu_requested

const MAX_LIVES := 3
const QUESTIONS_PER_LEVEL := 10
const BLOCK_W := 150.0
const BLOCK_H := 42.0
const BLOCK_GAP := 6.0
const FLOOR_GAP := 4.0
const FLOORS := 10

class Background:
	extends Control

	var environment: int = 0

	func _draw() -> void:
		if environment == 0:
			_draw_arcade()
		else:
			_draw_classroom()

	func _draw_arcade() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color("#0d0d1f"))
		draw_rect(Rect2(Vector2(0, size.y * 0.62), Vector2(size.x, size.y * 0.38)), Color("#0a1522"))
		var perspective := Vector2(size.x * 0.5, size.y * 0.62)
		for i in 16:
			var t := float(i) / 15.0
			var x := size.x * t
			draw_line(perspective, Vector2(x, size.y), Color("#1a4a6e"), 1.5)
		for i in 6:
			var yy := size.y * 0.62 + pow(float(i) / 5.0, 1.8) * size.y * 0.38
			draw_line(Vector2(0, yy), Vector2(size.x, yy), Color("#153d58"), 1.5)
		for i in 24:
			var sx := fmod(float(i) * 97.0, size.x)
			var sy := fmod(float(i) * 53.0, size.y * 0.55)
			draw_circle(Vector2(sx, sy), 1.5, Color(1, 1, 1, 0.35))
		draw_rect(Rect2(Vector2(size.x * 0.03, size.y * 0.08), Vector2(170, 54)), Color(1.0, 0.23, 0.62, 0.12))
		draw_rect(Rect2(Vector2(size.x * 0.03, size.y * 0.08), Vector2(170, 54)), Color(1.0, 0.23, 0.62, 0.7), false, 2.0)
		draw_string(ThemeDB.fallback_font, Vector2(size.x * 0.03 + 14, size.y * 0.08 + 36), "ARCADE", HORIZONTAL_ALIGNMENT_LEFT, 150, 26, Color("#ff5298"))
		draw_rect(Rect2(Vector2(size.x * 0.88, size.y * 0.08), Vector2(150, 54)), Color(0.0, 0.91, 0.71, 0.1))
		draw_rect(Rect2(Vector2(size.x * 0.88, size.y * 0.08), Vector2(150, 54)), Color(0.0, 0.91, 0.71, 0.7), false, 2.0)
		draw_string(ThemeDB.fallback_font, Vector2(size.x * 0.88 + 16, size.y * 0.08 + 36), "NEON", HORIZONTAL_ALIGNMENT_LEFT, 120, 26, Color("#1de9b6"))

	func _draw_classroom() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color("#e8d9b8"))
		draw_rect(Rect2(Vector2(0, size.y * 0.78), Vector2(size.x, size.y * 0.22)), Color("#8b5a2b"))
		for i in 9:
			var px := size.x * float(i) / 9.0
			draw_line(Vector2(px, size.y * 0.78), Vector2(px, size.y), Color("#6e4420"), 1.5)
		draw_line(Vector2(0, size.y * 0.78), Vector2(size.x, size.y * 0.78), Color("#5c3518"), 3.0)
		draw_rect(Rect2(Vector2(size.x * 0.12, size.y * 0.1), Vector2(size.x * 0.76, size.y * 0.44)), Color("#2e5c46"))
		draw_rect(Rect2(Vector2(size.x * 0.12, size.y * 0.1), Vector2(size.x * 0.76, size.y * 0.44)), Color("#5c3a20"), false, 8.0)
		var font := ThemeDB.fallback_font
		var chalk := Color(1, 1, 1, 0.85)
		draw_string(font, Vector2(size.x * 0.16, size.y * 0.2), "Unidad III: Permutaciones", HORIZONTAL_ALIGNMENT_LEFT, size.x * 0.7, 28, chalk)
		draw_string(font, Vector2(size.x * 0.16, size.y * 0.28), "P(n, r) = n! / (n - r)!", HORIZONTAL_ALIGNMENT_LEFT, size.x * 0.7, 24, Color("#ffe082"))
		draw_string(font, Vector2(size.x * 0.16, size.y * 0.36), "n! = n · (n-1) · (n-2) · ... · 1", HORIZONTAL_ALIGNMENT_LEFT, size.x * 0.7, 24, Color("#b3e5fc"))
		draw_string(font, Vector2(size.x * 0.16, size.y * 0.44), "Permutación circular: (n-1)!", HORIZONTAL_ALIGNMENT_LEFT, size.x * 0.7, 24, Color("#c8e6c9"))

var main: Node
var level: int
var lives: int = MAX_LIVES
var run_coins: int = 0
var score: int = 0
var level_correct: int = 0
var level_mistakes: int = 0
var stars_this_level: int = 0
var streak: int = 0
var questions: Array = []
var q_pos: int = 0
var current_q: Dictionary = {}
var blocks: Array = []
var active_blocks: Array = []
var is_active: bool = false
var bg: Background
var blocks_root: Control
var question_label: Label
var lives_label: Label
var coins_label: Label
var stars_label: Label
var score_label: Label
var level_label: Label
var feedback_label: Label
var flow_tween: Tween
var feedback_tween: Tween
var overlay: Control

func _init(main_ref: Node, start_level: int = 1) -> void:
	main = main_ref
	level = start_level

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_background()
	_build_hud()
	_build_question_panel()
	_build_blocks_root()
	_build_feedback()
	_start_level(false)

func _start_level(reset_score: bool) -> void:
	is_active = false
	if reset_score:
		score = 0
	lives = MAX_LIVES
	level_correct = 0
	level_mistakes = 0
	stars_this_level = 0
	streak = 0
	run_coins = 0
	questions = Questions.pick_level_questions(QUESTIONS_PER_LEVEL)
	q_pos = 0
	bg.environment = 0 if int((level - 1) / 5) % 2 == 0 else 1
	bg.queue_redraw()
	_rebuild_tower()
	_update_hud()
	_after_delay(0.4, _show_next_question)

func _build_background() -> void:
	bg = Background.new()
	bg.environment = 0 if int((level - 1) / 5) % 2 == 0 else 1
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

func _build_hud() -> void:
	var hud := MarginContainer.new()
	hud.anchor_left = 0.0
	hud.anchor_right = 1.0
	hud.anchor_top = 0.0
	hud.anchor_bottom = 0.0
	hud.offset_left = 16
	hud.offset_right = -16
	hud.offset_top = 10
	hud.offset_bottom = 58
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hud)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 24)
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(hbox)

	lives_label = _hud_label("")
	coins_label = _hud_label("")
	stars_label = _hud_label("")
	score_label = _hud_label("")
	level_label = _hud_label("")

	hbox.add_child(lives_label)
	hbox.add_child(coins_label)
	hbox.add_child(stars_label)
	hbox.add_child(score_label)
	hbox.add_child(level_label)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)

	var menu_btn := Button.new()
	menu_btn.text = "◄ MENÚ"
	menu_btn.custom_minimum_size = Vector2(130, 40)
	menu_btn.add_theme_font_size_override("font_size", 16)
	menu_btn.add_theme_color_override("font_color", Color.WHITE)
	_style_button(menu_btn, Color("#ff5252"))
	menu_btn.pressed.connect(func() -> void: menu_requested.emit())
	hbox.add_child(menu_btn)

func _hud_label(text_value: String) -> Label:
	var l := Label.new()
	l.text = text_value
	l.add_theme_font_size_override("font_size", 18)
	l.add_theme_color_override("font_color", Color.WHITE)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return l

func _build_question_panel() -> void:
	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.0
	panel.anchor_bottom = 0.0
	panel.offset_left = -420
	panel.offset_right = 420
	panel.offset_top = 66
	panel.offset_bottom = 150
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.16, 0.92)
	style.border_color = Color("#1de9b6")
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(16)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	question_label = Label.new()
	question_label.add_theme_font_size_override("font_size", 22)
	question_label.add_theme_color_override("font_color", Color.WHITE)
	question_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	question_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	question_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(question_label)

func _build_blocks_root() -> void:
	blocks_root = Control.new()
	blocks_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	blocks_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(blocks_root)

func _build_feedback() -> void:
	feedback_label = Label.new()
	feedback_label.anchor_left = 0.5
	feedback_label.anchor_right = 0.5
	feedback_label.anchor_top = 0.5
	feedback_label.anchor_bottom = 0.5
	feedback_label.offset_left = -260
	feedback_label.offset_right = 260
	feedback_label.offset_top = -170
	feedback_label.offset_bottom = -110
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.add_theme_font_size_override("font_size", 34)
	feedback_label.add_theme_color_override("font_color", Color("#ffd54f"))
	feedback_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	feedback_label.visible = false
	add_child(feedback_label)

func _rebuild_tower() -> void:
	for child in blocks_root.get_children():
		child.queue_free()
	blocks.clear()
	active_blocks.clear()
	var vs := get_viewport().get_visible_rect().size
	var tower_w := 3.0 * BLOCK_W + 2.0 * BLOCK_GAP + (BLOCK_W + BLOCK_GAP) * 0.5
	var origin_x := (vs.x - tower_w) * 0.5
	var bottom_y := vs.y - 24.0
	for floor_i in FLOORS:
		var y := bottom_y - float(floor_i + 1) * (BLOCK_H + FLOOR_GAP)
		var offset := ((BLOCK_W + BLOCK_GAP) * 0.5) if floor_i % 2 == 1 else 0.0
		for slot in 3:
			var x := origin_x + float(slot) * (BLOCK_W + BLOCK_GAP) + offset
			_create_block(floor_i, slot, Vector2(x, y))

func _create_block(floor_i: int, slot: int, pos: Vector2) -> void:
	var btn := Button.new()
	btn.position = pos
	btn.size = Vector2(BLOCK_W, BLOCK_H)
	btn.pressed.connect(_on_block_pressed.bind(btn))
	var base_color := Color("#d49a5b") if floor_i % 2 == 0 else Color("#c07f3e")
	_style_block(btn, base_color, false)
	btn.set_meta("base_color", base_color)
	btn.set_meta("used", false)
	btn.set_meta("is_correct", false)
	btn.set_meta("golden", false)
	var lbl := Label.new()
	lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_color", Color("#3a2210"))
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(lbl)
	blocks_root.add_child(btn)
	blocks.append({"node": btn, "label": lbl, "floor": floor_i, "slot": slot})

func _style_block(btn: Button, color: Color, golden: bool) -> void:
	var border := Color("#8a5a28") if not golden else Color("#ff8f00")
	var normal := StyleBoxFlat.new()
	normal.bg_color = color
	normal.border_color = border
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(6)
	var hover := normal.duplicate()
	hover.bg_color = color.lightened(0.12)
	var pressed := normal.duplicate()
	pressed.bg_color = color.darkened(0.15)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("focus", normal.duplicate())
	btn.add_theme_stylebox_override("disabled", normal.duplicate())

func _style_button(btn: Button, color: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = color
	normal.set_corner_radius_all(10)
	var hover := normal.duplicate()
	hover.bg_color = color.lightened(0.15)
	var pressed := normal.duplicate()
	pressed.bg_color = color.darkened(0.2)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("focus", normal.duplicate())

func _show_next_question() -> void:
	var avail: Array = []
	for b in blocks:
		if is_instance_valid(b["node"]) and not b["node"].get_meta("used"):
			avail.append(b)
	if avail.size() < 4 or level_correct >= QUESTIONS_PER_LEVEL:
		return
	avail.shuffle()
	active_blocks = avail.slice(0, 4)
	current_q = questions[q_pos]
	q_pos = (q_pos + 1) % questions.size()
	question_label.text = current_q["q"]
	var opts: Array = current_q["opts"].duplicate()
	var golden_slot := -1
	if randf() < 0.2:
		golden_slot = randi() % 4
	for i in 4:
		var entry: Dictionary = active_blocks[i]
		var btn: Button = entry["node"]
		var lbl: Label = entry["label"]
		btn.set_meta("is_correct", i == current_q["a"])
		btn.set_meta("golden", i == golden_slot)
		btn.set_meta("used", false)
		btn.disabled = false
		btn.modulate = Color.WHITE
		btn.rotation_degrees = 0.0
		var base: Color = btn.get_meta("base_color")
		if i == golden_slot:
			_style_block(btn, Color("#ffd54f"), true)
			lbl.text = "★ " + str(opts[i])
		else:
			_style_block(btn, base, false)
			lbl.text = str(opts[i])
	is_active = true

func _on_block_pressed(btn: Button) -> void:
	if not is_active:
		return
	if btn.get_meta("used"):
		return
	if btn.get_meta("is_correct"):
		_on_correct(btn)
	else:
		_on_wrong(btn)

func _on_correct(btn: Button) -> void:
	is_active = false
	streak += 1
	level_correct += 1
	var gain := 10 + streak * 2
	var bonus_text := ""
	if btn.get_meta("golden"):
		bonus_text = _apply_bonus()
		gain += 25
	score += gain
	run_coins += gain
	main.add_coins(gain)
	var star_gained := false
	if level_correct % 5 == 0:
		main.add_stars(1)
		stars_this_level += 1
		star_gained = true
	_update_hud()
	var msg := "¡Correcto! +%d" % gain
	if star_gained:
		msg += "  ★ +1 ESTRELLA"
	_flash_feedback(msg, Color("#69f0ae"))
	if bonus_text != "":
		_show_bonus_feedback(bonus_text)
	_animate_extract(btn)
	if level_correct >= QUESTIONS_PER_LEVEL:
		_after_delay(1.2, _level_complete)
	else:
		_after_delay(0.9, _show_next_question)

func _on_wrong(btn: Button) -> void:
	is_active = false
	lives -= 1
	level_mistakes += 1
	streak = 0
	_update_hud()
	_flash_feedback("¡Incorrecto! -1 vida", Color("#ff5252"))
	_flash_block_red(btn)
	_shake_tower()
	if lives <= 0:
		_after_delay(1.1, _game_over)
	else:
		_after_delay(1.0, func() -> void: is_active = true)

func _apply_bonus() -> String:
	var roll := randi() % 3
	if roll == 0 and lives < MAX_LIVES + 2:
		lives += 1
		_update_hud()
		return "¡BONUS: +1 vida!"
	elif roll == 1:
		main.add_coins(50)
		run_coins += 50
		score += 50
		_update_hud()
		return "¡BONUS: +50 monedas!"
	main.add_stars(1)
	stars_this_level += 1
	_update_hud()
	return "¡BONUS: +1 estrella!"

func _animate_extract(btn: Button) -> void:
	btn.set_meta("used", true)
	btn.disabled = true
	btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for i in range(blocks.size() - 1, -1, -1):
		if blocks[i]["node"] == btn:
			blocks.remove_at(i)
	var vs := get_viewport().get_visible_rect().size
	var dir := 1.0 if btn.position.x + BLOCK_W * 0.5 > vs.x * 0.5 else -1.0
	var tw := btn.create_tween()
	tw.tween_property(btn, "modulate", Color(0.6, 1.6, 0.6), 0.12)
	tw.tween_property(btn, "position:x", btn.position.x + dir * 170.0, 0.22)
	tw.parallel().tween_property(btn, "rotation_degrees", dir * 20.0, 0.22)
	tw.tween_property(btn, "position:y", btn.position.y + 320.0, 0.32)
	tw.parallel().tween_property(btn, "rotation_degrees", dir * 90.0, 0.32)
	tw.tween_property(btn, "modulate:a", 0.0, 0.18)
	tw.tween_callback(btn.queue_free)

func _flash_block_red(btn: Button) -> void:
	var tw := btn.create_tween()
	tw.tween_property(btn, "modulate", Color(2.5, 0.4, 0.4), 0.1)
	tw.tween_property(btn, "modulate", Color.WHITE, 0.25)

func _shake_tower() -> void:
	var base_x := blocks_root.position.x
	var tw := blocks_root.create_tween()
	tw.tween_property(blocks_root, "position:x", base_x + 12.0, 0.05)
	tw.tween_property(blocks_root, "position:x", base_x - 12.0, 0.05)
	tw.tween_property(blocks_root, "position:x", base_x + 8.0, 0.05)
	tw.tween_property(blocks_root, "position:x", base_x, 0.05)

func _collapse_tower() -> void:
	for entry in blocks:
		var btn: Button = entry["node"]
		if not is_instance_valid(btn) or btn.get_meta("used"):
			continue
		var tw := btn.create_tween()
		var dx := randf_range(-160.0, 160.0)
		var dy := randf_range(40.0, 260.0)
		var rot := randf_range(-120.0, 120.0)
		tw.tween_property(btn, "position", btn.position + Vector2(dx, dy), randf_range(0.4, 0.8))
		tw.parallel().tween_property(btn, "rotation_degrees", rot, randf_range(0.4, 0.8))
		tw.parallel().tween_property(btn, "modulate:a", 0.25, randf_range(0.5, 0.9))
		btn.set_meta("used", true)
		btn.disabled = true

func _level_complete() -> void:
	is_active = false
	var perfect := level_mistakes == 0
	var premio_coins := 50 if perfect else 25
	var premio_stars := 2 if perfect else 0
	main.add_coins(premio_coins)
	if premio_stars > 0:
		main.add_stars(premio_stars)
	main.set_max_level(level + 1)
	var info := [
		"¡Nivel %d completado!" % level,
		"Aciertos: %d   Errores: %d" % [level_correct, level_mistakes],
		"Monedas ganadas: %d" % run_coins,
		"Estrellas ganadas: %d" % stars_this_level,
		"Premio: +%d monedas%s" % [premio_coins, " y +2 estrellas ¡PERFECTO!" if perfect else ""]
	]
	_show_overlay("¡NIVEL SUPERADO!", info, [
		{"text": "SIGUIENTE NIVEL", "cb": _next_level},
		{"text": "MENÚ", "cb": func() -> void: menu_requested.emit()}
	])

func _next_level() -> void:
	level += 1
	_start_level(false)

func _game_over() -> void:
	is_active = false
	main.record_score(score)
	_collapse_tower()
	var info := [
		"La torre se derrumbó...",
		"Puntaje: %d" % score,
		"Récord: %d" % main.best_score,
		"Nivel alcanzado: %d" % level,
		"Monedas acumuladas: %d" % main.coins
	]
	_show_overlay("FIN DEL JUEGO", info, [
		{"text": "REINTENTAR", "cb": _restart_level},
		{"text": "MENÚ", "cb": func() -> void: menu_requested.emit()}
	])

func _restart_level() -> void:
	_start_level(true)

func _show_overlay(title_text: String, info: Array, actions: Array) -> void:
	if is_instance_valid(overlay):
		overlay.queue_free()
	overlay = Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.68)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(dim)
	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -270
	panel.offset_right = 270
	panel.offset_top = -190
	panel.offset_bottom = 190
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#1c1c32")
	style.border_color = Color("#1de9b6")
	style.set_border_width_all(2)
	style.set_corner_radius_all(16)
	style.set_content_margin_all(24)
	panel.add_theme_stylebox_override("panel", style)
	overlay.add_child(panel)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 12)
	panel.add_child(vb)

	var tl := Label.new()
	tl.text = title_text
	tl.add_theme_font_size_override("font_size", 34)
	tl.add_theme_color_override("font_color", Color("#1de9b6"))
	tl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(tl)

	for line in info:
		var l := Label.new()
		l.text = line
		l.add_theme_font_size_override("font_size", 18)
		l.add_theme_color_override("font_color", Color("#e8eaf6"))
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vb.add_child(l)

	var hb := BoxContainer.new()
	hb.alignment = BoxContainer.ALIGNMENT_CENTER
	hb.add_theme_constant_override("separation", 16)
	vb.add_child(hb)

	for action in actions:
		var b := Button.new()
		b.text = action["text"]
		b.custom_minimum_size = Vector2(200, 48)
		b.add_theme_font_size_override("font_size", 18)
		b.add_theme_color_override("font_color", Color.WHITE)
		_style_button(b, Color("#1de9b6") if action["text"] != "MENÚ" and action["text"] != "FIN DEL JUEGO" else Color("#ff5252"))
		b.pressed.connect(_do_action.bind(overlay, action["cb"]))
		hb.add_child(b)

	add_child(overlay)

func _do_action(ov: Control, cb: Callable) -> void:
	ov.queue_free()
	cb.call()

func _flash_feedback(text_value: String, color: Color) -> void:
	feedback_label.text = text_value
	feedback_label.add_theme_color_override("font_color", color)
	feedback_label.visible = true
	if feedback_tween and feedback_tween.is_valid():
		feedback_tween.kill()
	feedback_tween = create_tween()
	feedback_tween.tween_interval(0.85)
	feedback_tween.tween_callback(func() -> void: feedback_label.visible = false)

func _show_bonus_feedback(text_value: String) -> void:
	var bonus := Label.new()
	bonus.anchor_left = 0.5
	bonus.anchor_right = 0.5
	bonus.anchor_top = 0.5
	bonus.anchor_bottom = 0.5
	bonus.offset_left = -260
	bonus.offset_right = 260
	bonus.offset_top = -100
	bonus.offset_bottom = -60
	bonus.text = text_value
	bonus.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bonus.add_theme_font_size_override("font_size", 28)
	bonus.add_theme_color_override("font_color", Color("#ffd54f"))
	bonus.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bonus)
	var tw := bonus.create_tween()
	tw.tween_interval(1.1)
	tw.tween_callback(bonus.queue_free)

func _after_delay(delay: float, cb: Callable) -> void:
	if flow_tween and flow_tween.is_valid():
		flow_tween.kill()
	flow_tween = create_tween()
	flow_tween.tween_interval(delay)
	flow_tween.tween_callback(cb)

func _update_hud() -> void:
	lives_label.text = "VIDAS: " + "♥".repeat(lives) + "♡".repeat(max(0, MAX_LIVES - lives))
	coins_label.text = "MONEDAS: %d" % main.coins
	stars_label.text = "ESTRELLAS: %d" % main.stars
	score_label.text = "PUNTOS: %d" % score
	level_label.text = "NIVEL %d  (%d/%d)" % [level, level_correct, QUESTIONS_PER_LEVEL]
