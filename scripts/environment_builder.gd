class_name EnvironmentBuilder
extends Node3D

const TROPICAL := 0
const DESERT := 1
const MARINE := 2

var _rng := RandomNumberGenerator.new()

func build(theme: int) -> void:
	for c in get_children():
		c.queue_free()
	_rng.randomize()
	_build_sky(theme)
	_build_light(theme)
	match theme:
		DESERT:
			_build_desert()
		MARINE:
			_build_marine()
		_:
			_build_tropical()
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
	match theme:
		DESERT:
			sky_mat.sky_top_color = Color("#ffb74d")
			sky_mat.sky_horizon_color = Color("#ffe0a3")
			sky_mat.ground_bottom_color = Color("#c98a3a")
			sky_mat.ground_horizon_color = Color("#ffd79a")
		MARINE:
			sky_mat.sky_top_color = Color("#003b6f")
			sky_mat.sky_horizon_color = Color("#1c8fc2")
			sky_mat.ground_bottom_color = Color("#02223f")
			sky_mat.ground_horizon_color = Color("#1c8fc2")
		_:
			sky_mat.sky_top_color = Color("#3fa9f5")
			sky_mat.sky_horizon_color = Color("#cdeeff")
			sky_mat.ground_bottom_color = Color("#2f7d32")
			sky_mat.ground_horizon_color = Color("#cdeeff")

	var sky := Sky.new()
	sky.sky_material = sky_mat

	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 1.0
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.glow_enabled = theme == MARINE
	env.glow_intensity = 0.7

	var world_env := WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)

func _build_light(theme: int) -> void:
	var sun := DirectionalLight3D.new()
	sun.shadow_enabled = true
	sun.rotation_degrees = Vector3(-58, 35, 0)
	var fill := DirectionalLight3D.new()
	fill.light_energy = 0.35
	fill.shadow_enabled = false
	fill.rotation_degrees = Vector3(-25, 200, 0)

	match theme:
		DESERT:
			sun.light_energy = 1.5
			sun.light_color = Color("#fff0c2")
			fill.light_color = Color("#ffd28a")
		MARINE:
			sun.light_energy = 0.85
			sun.light_color = Color("#7fd6ff")
			fill.light_color = Color("#2fa8e0")
		_:
			sun.light_energy = 1.25
			sun.light_color = Color.WHITE
			fill.light_color = Color("#a8d8ff")

	add_child(sun)
	add_child(fill)

# --- Selva Tropical (normal) -------------------------------------------

func _build_tropical() -> void:
	_add_cylinder(0.0, 0.6, 6.2, Color("#5ec24d"), Vector3(0, -0.3, 0), 40)
	_add_cone(Color("#9c6b3f"), Vector3(0, -3.0, 0), 6.2, 1.2, 4.4)
	_add_cylinder(0.0, 0.4, 5.4, Color("#6fd65a"), Vector3(0, -0.2, 0), 40)

	for i in 7:
		var a := _rng.randf_range(0.0, TAU)
		var r := _rng.randf_range(7.5, 14.0)
		_add_cloud(Vector3(cos(a) * r, _rng.randf_range(6.0, 12.0), sin(a) * r))

	for i in 5:
		var a := _rng.randf_range(0.0, TAU)
		var r := _rng.randf_range(4.4, 5.7)
		_add_palm(Vector3(cos(a) * r, 0.0, sin(a) * r))

	for i in 5:
		var a := _rng.randf_range(0.0, TAU)
		var r := _rng.randf_range(4.2, 5.8)
		_add_tree(Vector3(cos(a) * r, 0.0, sin(a) * r))

# --- Desierto -----------------------------------------------------------

func _build_desert() -> void:
	_add_cylinder(0.0, 0.6, 6.2, Color("#e0b45e"), Vector3(0, -0.3, 0), 40)
	_add_cone(Color("#c98a3a"), Vector3(0, -3.0, 0), 6.2, 1.2, 4.4)
	_add_cylinder(0.0, 0.4, 5.4, Color("#f2cf83"), Vector3(0, -0.2, 0), 40)

	for i in 6:
		var a := _rng.randf_range(0.0, TAU)
		var r := _rng.randf_range(7.0, 13.0)
		var dune := _add_cone(Color("#e8c06a"), Vector3(cos(a) * r, 1.2, sin(a) * r), 4.0, 3.4, 2.4)
		dune.scale = Vector3(1.0, 0.5, 1.0)

	for i in 5:
		var a := _rng.randf_range(0.0, TAU)
		var r := _rng.randf_range(4.2, 5.7)
		_add_cactus(Vector3(cos(a) * r, 0.0, sin(a) * r))

	for i in 6:
		var a := _rng.randf_range(0.0, TAU)
		var r := _rng.randf_range(3.8, 5.8)
		var s := _rng.randf_range(0.25, 0.5)
		_add_sphere(s, Color("#b98a52"), Vector3(cos(a) * r, s * 0.6, sin(a) * r))

# --- Marina -------------------------------------------------------------

func _build_marine() -> void:
	_add_cylinder(0.0, 0.6, 6.2, Color("#e6d8a8"), Vector3(0, -0.3, 0), 40)
	_add_cylinder(0.0, 0.4, 5.4, Color("#f0e4bc"), Vector3(0, -0.2, 0), 40)

	var coral_colors: Array = [
		Color("#ff6f91"), Color("#ff9671"), Color("#ffc75f"),
		Color("#d65db1"), Color("#845ec2"), Color("#2c73d2")
	]

	for i in 9:
		var a := _rng.randf_range(0.0, TAU)
		var r := _rng.randf_range(4.0, 5.8)
		_add_coral(Vector3(cos(a) * r, 0.0, sin(a) * r), coral_colors[i % coral_colors.size()])

	for i in 10:
		var a := _rng.randf_range(0.0, TAU)
		var r := _rng.randf_range(3.6, 5.8)
		_add_seagrass(Vector3(cos(a) * r, 0.0, sin(a) * r))

	for i in 14:
		var a := _rng.randf_range(0.0, TAU)
		var r := _rng.randf_range(1.5, 8.0)
		_add_bubble(Vector3(cos(a) * r, _rng.randf_range(1.0, 11.0), sin(a) * r))

	for i in 7:
		var a := _rng.randf_range(0.0, TAU)
		var r := _rng.randf_range(4.0, 9.0)
		_add_fish(Vector3(cos(a) * r, _rng.randf_range(2.0, 9.0), sin(a) * r), coral_colors[i % coral_colors.size()])

# --- Primitivas ---------------------------------------------------------

func _add_cylinder(top_r: float, bot_r: float, height: float, color: Color, pos: Vector3, segments: int = 24, emissive: bool = false) -> MeshInstance3D:
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
	return mi

func _add_cone(color: Color, pos: Vector3, base_r: float, tip_r: float, height: float) -> MeshInstance3D:
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
	return mi

func _add_sphere(radius: float, color: Color, pos: Vector3, emissive: bool = false) -> MeshInstance3D:
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
	return mi

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

func _add_cloud(pos: Vector3) -> void:
	# Multiplicamos X y Z para alejar la nube del centro (0, 0)
	var factor_distancia := 2.0  # Cambia este número para alejarla más o menos
	var pos_alejada := Vector3(pos.x * factor_distancia, pos.y, pos.z * factor_distancia)
	
	var pieces := _rng.randi_range(3, 5)
	for i in pieces:
		var off := Vector3(_rng.randf_range(-1.6, 1.6), _rng.randf_range(-0.3, 0.3), _rng.randf_range(-1.6, 1.6))
		_add_sphere(_rng.randf_range(0.8, 1.5), Color(1, 1, 1, 0.95), pos_alejada + off)

func _add_palm(pos: Vector3) -> void:
	# Restamos valor al eje Y para bajar la palmera (puedes cambiar 1.5 por el valor que quieras)
	var pos_baja := pos - Vector3(0, 3.5, 0)
	
	var h := _rng.randf_range(3.0, 4.5)
	_add_cylinder(0.16, 0.22, h, Color("#8a5a34"), pos_baja + Vector3(0, h * 0.5, 0), 10)
	var top := pos_baja + Vector3(0, h, 0)
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

# Arbol de copa redonda apoyado en el suelo.
func _add_tree(pos: Vector3) -> void:
	# Le restamos valor al eje Y para hundir todo el árbol en el suelo (ej: -0.8)
	var pos_baja := pos - Vector3(0, 4.0, 0)
	
	var h := _rng.randf_range(1.6, 2.4)
	_add_cylinder(0.26, 0.36, h, Color("#8a5a34"), pos_baja + Vector3(0, h * 0.5, 0), 10)
	var r := _rng.randf_range(1.0, 1.4)
	_add_sphere(r, Color("#3fae3f"), pos_baja + Vector3(0, h + r * 0.6, 0))
	_add_sphere(r * 0.6, Color("#4fc44f"), pos_baja + Vector3(r * 0.5, h + r * 1.0, r * 0.2))
	_add_sphere(r * 0.5, Color("#2f9e2f"), pos_baja + Vector3(-r * 0.5, h + r * 0.8, -r * 0.2))
func _add_cactus(pos: Vector3) -> void:
	var h := _rng.randf_range(1.8, 3.0)
	var green := Color("#3f9e4d")
	_add_cylinder(0.32, 0.4, h, green, pos + Vector3(0, h * 0.5, 0), 12)
	_add_cylinder(0.16, 0.16, 0.9, green, pos + Vector3(0.55, h * 0.55, 0), 10)
	_add_cylinder(0.16, 0.16, 0.7, green, pos + Vector3(0.85, h * 0.7, 0), 10)
	_add_cylinder(0.16, 0.16, 0.8, green, pos + Vector3(-0.5, h * 0.45, 0), 10)
	_add_cylinder(0.16, 0.16, 0.6, green, pos + Vector3(-0.75, h * 0.6, 0), 10)

func _add_coral(pos: Vector3, color: Color) -> void:
	var branches := _rng.randi_range(3, 5)
	for i in branches:
		var h := _rng.randf_range(0.8, 1.8)
		var off := Vector3(_rng.randf_range(-0.5, 0.5), 0.0, _rng.randf_range(-0.5, 0.5))
		var mi := _add_cylinder(0.08, 0.16, h, color, pos + off + Vector3(0, h * 0.5, 0), 8)
		mi.rotation_degrees = Vector3(_rng.randf_range(-14, 14), 0, _rng.randf_range(-14, 14))

func _add_seagrass(pos: Vector3) -> void:
	for i in 5:
		var h := _rng.randf_range(0.8, 1.6)
		var off := Vector3(_rng.randf_range(-0.4, 0.4), 0.0, _rng.randf_range(-0.4, 0.4))
		var mi := _add_cylinder(0.03, 0.06, h, Color("#39a553"), pos + off + Vector3(0, h * 0.5, 0), 6)
		mi.rotation_degrees = Vector3(_rng.randf_range(-18, 18), 0, _rng.randf_range(-18, 18))

func _add_fish(pos: Vector3, color: Color) -> void:
	var body := SphereMesh.new()
	body.radius = 0.35
	body.height = 0.7
	body.radial_segments = 12
	body.rings = 6
	body.material = _flat(color, true)
	var mi := MeshInstance3D.new()
	mi.mesh = body
	mi.position = pos
	mi.scale = Vector3(1.8, 1.0, 0.7)
	mi.rotation_degrees = Vector3(0, _rng.randf_range(0, 360), 0)
	add_child(mi)

	var tail := CylinderMesh.new()
	tail.top_radius = 0.0
	tail.bottom_radius = 0.28
	tail.height = 0.4
	tail.radial_segments = 8
	tail.material = _flat(color, true)
	var tm := MeshInstance3D.new()
	tm.mesh = tail
	tm.position = pos + Vector3(0, 0, 0.55)
	tm.rotation_degrees = Vector3(90, 0, 0)
	add_child(tm)

func _flat(color: Color, emissive: bool) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.9
	if emissive:
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = 1.8
	return mat
