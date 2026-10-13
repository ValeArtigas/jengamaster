class_name JengaBlock
extends RigidBody3D

const SIZE := Vector3(3.0, 0.5, 1.0)
const TOON_SHADER := preload("res://shaders/toon.gdshader")

var home_position: Vector3 = Vector3.ZERO
var floor_index: int = 0
var base_color: Color = Color.WHITE
var is_dragged: bool = false
var extracted: bool = false
var placing: bool = false

var _mat: ShaderMaterial
var _layer: int = 2

func build(color: Color, floor_i: int, pos: Vector3, phys: PhysicsMaterial, layer: int) -> void:
	floor_index = floor_i
	base_color = color
	home_position = pos
	_layer = layer

	var shape := BoxShape3D.new()
	shape.size = SIZE
	var col := CollisionShape3D.new()
	col.shape = shape
	add_child(col)

	_mat = ShaderMaterial.new()
	_mat.shader = TOON_SHADER
	_mat.set_shader_parameter("albedo", color)
	_mat.set_shader_parameter("emission_color", Color.BLACK)
	_mat.set_shader_parameter("emission_strength", 0.0)

	var bm := BoxMesh.new()
	bm.size = SIZE
	bm.material = _mat
	var mesh := MeshInstance3D.new()
	mesh.mesh = bm
	add_child(mesh)

	mass = 1.0
	physics_material_override = phys
	collision_layer = layer
	collision_mask = layer | 1
	continuous_cd = true
	contact_monitor = true
	max_contacts_reported = 6
	linear_damp = 0.35
	angular_damp = 0.55

	var rng := RandomNumberGenerator.new()
	rng.seed = hash(pos)
	rotation.y = deg_to_rad(rng.randf_range(0.4, -0.4))
	position = pos

func set_highlight(on: bool) -> void:
	if _mat == null:
		return
	_mat.set_shader_parameter("emission_color", Color(1.0, 1.0, 0.55) if on else Color.BLACK)
	_mat.set_shader_parameter("emission_strength", 0.9 if on else 0.0)

func set_neon(on: bool, color: Color = base_color) -> void:
	if _mat == null:
		return
	_mat.set_shader_parameter("emission_color", color if on else Color.BLACK)
	_mat.set_shader_parameter("emission_strength", 0.7 if on else 0.0)

func mark_extracted() -> void:
	vanish()

# Prepara el bloque para ser elevado al tope sin chocar con la torre.
func begin_place() -> void:
	placing = true
	is_dragged = false
	freeze = true
	collision_layer = 0
	collision_mask = 0
	set_highlight(false)

# Consolida el bloque como nuevo piso en la cima.
func finalize_place(pos: Vector3, rot_y: float, floor_i: int) -> void:
	placing = false
	extracted = false
	floor_index = floor_i
	home_position = pos
	global_position = pos
	rotation = Vector3(0.0, rot_y, 0.0)
	scale = Vector3.ONE
	freeze = false
	collision_layer = _layer
	collision_mask = _layer | 1
	sleeping = false
	set_neon(false)

# Desaparece magicamente al fallar la trivia.
func vanish() -> void:
	extracted = true
	placing = false
	freeze = true
	collision_layer = 0
	collision_mask = 0
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector3(0.01, 0.01, 0.01), 0.3)
	tw.parallel().tween_property(self, "rotation:y", rotation.y + TAU, 0.3)
	tw.parallel().tween_property(self, "position:y", position.y - 1.5, 0.3)
	tw.tween_callback(queue_free)
