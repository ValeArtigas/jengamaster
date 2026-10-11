class_name EnvironmentBuilder
extends Node3D

const ISLAND := 0
const LAB := 1

var _rng := RandomNumberGenerator.new()

func build(theme: int) -> void:
	for c in get_children():
		c.queue_free()
	_rng.randomize()
	_build_sky(theme)
	_build_light(theme)
	if theme == ISLAND:
		_build_island()
	else:
		_build_lab()
	_add_ground_body()

func _add_ground_body() -> void:
	var body := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = 5.5
	shape.height = 0.8
	cs.shape = shape
	body.add_child(cs)
	body.position = Vector3(0.0, -0.4, 0.0)
	var pm := PhysicsMaterial.new()
	pm.friction = 0.9
	pm.bounce = 0.0
	body.physics_material_override = pm
	body.collision_layer = 1
	body.collision_mask = 2
	add_child(body)

func _build_sky(theme: int) -> void:
	var sky_mat := ProceduralSkyMaterial.new()
	if theme == ISLAND:
		sky_mat.sky_top_color = Color("#3fa9f5")
		sky_mat.sky_horizon_color = Color("#cdeeff")
		sky_mat.ground_bottom_color = Color("#2f7d32")
		sky_mat.ground_horizon_color = Color("#cdeeff")
	else:
		sky_mat.sky_top_color = Color("#160033")
		sky_mat.sky_horizon_color = Color("#5b1a8c")
		sky_mat.ground_bottom_color = Color("#101020")
		sky_mat.ground_horizon_color = Color("#3d1266")

	var sky := Sky.new()
	sky.sky_material = sky_mat

	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 1.0
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.glow_enabled = theme == LAB
	env.glow_intensity = 0.7

	var world_env := WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)

func _build_light(theme: int) -> void:
	var sun := DirectionalLight3D.new()
	sun.light_energy = 1.25 if theme == ISLAND else 0.7
	sun.light_color = Color.WHITE if theme == ISLAND else Color("#c9a6ff")
	sun.shadow_enabled = true
	sun.rotation_degrees = Vector3(-58, 35, 0)
	add_child(sun)

	var fill := DirectionalLight3D.new()
	fill.light_energy = 0.35
	fill.light_color = Color("#a8d8ff") if theme == ISLAND else Color("#ff7ad9")
	fill.shadow_enabled = false
	fill.rotation_degrees = Vector3(-25, 200, 0)
	add_child(fill)

func _build_island() -> void:
	_add_cylinder(0.0, 0.6, 6.2, Color("#5ec24d"), Vector3(0, -0.3, 0), 40)
	_add_cone(Color("#9c6b3f"), Vector3(0, -3.0, 0), 6.2, 1.2, 4.4)
	_add_cylinder(0.0, 0.4, 5.4, Color("#6fd65a"), Vector3(0, -0.2, 0), 40)

	for i in 7:
		var a := _rng.randf_range(0.0, TAU)
		var r := _rng.randf_range(7.5, 14.0)
		_add_cloud(Vector3(cos(a) * r, _rng.randf_range(6.0, 12.0), sin(a) * r))

	for i in 5:
		var a := _rng.randf_range(0.0, TAU)
		var r := _rng.randf_range(5.0, 7.5)
		_add_palm(Vector3(cos(a) * r, 0.0, sin(a) * r))

	for i in 4:
		var a := _rng.randf_range(0.0, TAU)
		var r := _rng.randf_range(9.0, 16.0)
		var p := Vector3(cos(a) * r, _rng.randf_range(-1.5, 2.5), sin(a) * r)
		_add_cylinder(1.6, 2.0, 1.4, Color("#6fd65a"), p, 12)
		_add_cone(Color("#8a5a34"), p + Vector3(0, -2.0, 0), 1.6, 0.3, 2.2)

func _build_lab() -> void:
	_add_cylinder(0.0, 0.5, 6.2, Color("#37474f"), Vector3(0, -0.25, 0), 40)
	_add_cylinder(0.0, 0.3, 5.6, Color("#546e7a"), Vector3(0, -0.15, 0), 40)
	_add_cylinder(0.0, 0.3, 5.9, Color("#00e5ff"), Vector3(0, -0.18, 0), 40, true)

	var tube_colors: Array = [Color("#00e5ff"), Color("#ff4081"), Color("#76ff03"), Color("#e040fb")]
	for i in 10:
		var a := TAU * float(i) / 10.0
		var r := 5.4
		var col: Color = tube_colors[i % tube_colors.size()]
		var h := _rng.randf_range(4.0, 8.0)
		_add_cylinder(0.18, 0.18, h, col, Vector3(cos(a) * r, h * 0.5, sin(a) * r), 12, true)
		_add_sphere(0.4, col, Vector3(cos(a) * r, h + 0.3, sin(a) * r))

	for i in 8:
		var a := _rng.randf_range(0.0, TAU)
		var r := _rng.randf_range(3.5, 8.0)
		_add_bubble(Vector3(cos(a) * r, _rng.randf_range(3.0, 10.0), sin(a) * r))

	for i in 3:
		_add_torus(2.4 + i * 1.6, 0.12, tube_colors[i % tube_colors.size()],
			Vector3(0, 5.0 + i * 3.0, 0), Vector3(90 * i, 0, 30))

func _add_cylinder(top_r: float, bot_r: float, height: float, color: Color, pos: Vector3, segments: int = 24, emissive: bool = false) -> void:
	var mesh := CylinderMesh.new()
	mesh.top_radius = top_r
	mesh.bottom_radius = bot_r
	mesh.height = height
	mesh.radial_segments = segments
	mesh.material = _flat(color, emissive)
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	add_child(mi)

func _add_cone(color: Color, pos: Vector3, base_r: float, tip_r: float, height: float) -> void:
	var mesh := CylinderMesh.new()
	mesh.top_radius = tip_r
	mesh.bottom_radius = base_r
	mesh.height = height
	mesh.radial_segments = 20
	mesh.material = _flat(color, false)
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	add_child(mi)

func _add_sphere(radius: float, color: Color, pos: Vector3, emissive: bool = false) -> void:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 16
	mesh.rings = 8
	mesh.material = _flat(color, emissive)
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	add_child(mi)

func _add_bubble(pos: Vector3) -> void:
	var mesh := SphereMesh.new()
	var r := _rng.randf_range(0.3, 0.8)
	mesh.radius = r
	mesh.height = r * 2.0
	mesh.radial_segments = 16
	mesh.rings = 8
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.6, 0.9, 1.0, 0.25)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color("#00e5ff")
	mat.emission_energy_multiplier = 1.5
	mesh.material = mat
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	add_child(mi)

func _add_torus(radius: float, tube: float, color: Color, pos: Vector3, rot_deg: Vector3) -> void:
	var mesh := TorusMesh.new()
	mesh.inner_radius = radius - tube
	mesh.outer_radius = radius + tube
	mesh.rings = 24
	mesh.ring_segments = 12
	mesh.material = _flat(color, true)
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	mi.rotation_degrees = rot_deg
	add_child(mi)

func _add_cloud(pos: Vector3) -> void:
	var pieces := _rng.randi_range(3, 5)
	for i in pieces:
		var off := Vector3(_rng.randf_range(-1.6, 1.6), _rng.randf_range(-0.3, 0.3), _rng.randf_range(-1.6, 1.6))
		_add_sphere(_rng.randf_range(0.8, 1.5), Color(1, 1, 1, 0.95), pos + off)

func _add_palm(pos: Vector3) -> void:
	var h := _rng.randf_range(3.0, 4.5)
	_add_cylinder(0.16, 0.22, h, Color("#8a5a34"), pos + Vector3(0, h * 0.5, 0), 10)
	var top := pos + Vector3(0, h, 0)
	for i in 6:
		var a := TAU * float(i) / 6.0
		var leaf := SphereMesh.new()
		leaf.radius = 0.5
		leaf.height = 1.0
		leaf.radial_segments = 8
		leaf.rings = 4
		leaf.material = _flat(Color("#3fae3f"), false)
		var mi := MeshInstance3D.new()
		mi.mesh = leaf
		mi.position = top + Vector3(cos(a) * 1.1, 0.2, sin(a) * 1.1)
		mi.scale = Vector3(2.4, 0.5, 0.9)
		mi.rotation_degrees = Vector3(0, -rad_to_deg(a), 20)
		add_child(mi)

func _flat(color: Color, emissive: bool) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.9
	if emissive:
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = 1.8
	return mat
