class_name TowerMonitor
extends Node3D

signal tower_collapsed

const FALL_DRIFT := 1.30
const FALL_DEPTH := 1.50
const BLOCK_LAYER := 2

var blocks: Array = []
var base_y: float = 0.0
var enabled: bool = false

var _triggered: bool = false
var _fallen_count: int = 0
var _catcher: Area3D

func setup(blocks_list: Array, p_base_y: float) -> void:
	blocks = blocks_list
	base_y = p_base_y

	_catcher = Area3D.new()
	var cs := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(40.0, 2.0, 40.0)
	cs.shape = box
	_catcher.add_child(cs)
	_catcher.position = Vector3(0.0, base_y - 3.0, 0.0)
	_catcher.collision_layer = 0
	_catcher.collision_mask = BLOCK_LAYER
	_catcher.monitoring = true
	add_child(_catcher)
	_catcher.body_entered.connect(_on_body_entered)

func remove_block(block: JengaBlock) -> void:
	blocks.erase(block)

func _physics_process(_delta: float) -> void:
	if not enabled or _triggered:
		return
	var fallen := 0
	for b in blocks:
		if is_instance_valid(b) and b.global_position.y < base_y - FALL_DEPTH:
			fallen += 1
	if fallen >= 2:
		_trigger()

func check_stability() -> void:
	if not enabled or _triggered:
		return
	var max_drift := 0.0
	for b in blocks:
		if not is_instance_valid(b) or b.is_dragged or b.extracted:
			continue
		var d := Vector2(
			b.global_position.x - b.home_position.x,
			b.global_position.z - b.home_position.z
		).length()
		max_drift = maxf(max_drift, d)
	if max_drift > FALL_DRIFT:
		_trigger()

func _on_body_entered(body: Node) -> void:
	if _triggered or not enabled:
		return
	if body is JengaBlock and not body.extracted:
		_fallen_count += 1
		if _fallen_count >= 2:
			_trigger()

func _trigger() -> void:
	if _triggered:
		return
	_triggered = true
	tower_collapsed.emit()
