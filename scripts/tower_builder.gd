class_name TowerBuilder
extends Node3D

const BLOCK_SIZE := Vector3(3.0, 0.5, 1.0)
const BLOCKS_PER_FLOOR := 3
const FRICTION := 0.85
const BLOCK_LAYER := 2

var blocks: Array = []
var floors: int = 12
var theme: int = 0
var _phys: PhysicsMaterial

func build(p_floors: int, p_theme: int) -> void:
	floors = p_floors
	theme = p_theme
	_phys = PhysicsMaterial.new()
	_phys.friction = FRICTION
	_phys.bounce = 0.0
	_phys.rough = true

	var palette := _palette_for_theme()
	for f in floors:
		var y := 0.26 + float(f) * (BLOCK_SIZE.y + 0.006)
		var along_x := f % 2 == 0
		for s in BLOCKS_PER_FLOOR:
			var offset := float(s - 1)
			var pos := Vector3(0.0, y, offset) if along_x else Vector3(offset, y, 0.0)
			var color: Color = palette[(f + s) % palette.size()]
			var block := JengaBlock.new()
			add_child(block)
			block.build(color, f, pos, _phys, BLOCK_LAYER)
			if not along_x:
				block.rotation = Vector3(0, deg_to_rad(90), 0)
			blocks.append(block)

func remove_block(block: JengaBlock) -> void:
	blocks.erase(block)

func add_block(block: JengaBlock) -> void:
	if not blocks.has(block):
		blocks.append(block)

func remaining() -> int:
	return blocks.size()

# --- Regla de la cima ---------------------------------------------------

# Piso mas alto ocupado por la torre (indice logico).
func highest_floor() -> int:
	var top := -1
	for b in blocks:
		if is_instance_valid(b) and not b.extracted:
			top = maxi(top, b.floor_index)
	return top

# Limite superior de extraccion: dos pisos por debajo de la cima.
func extract_limit() -> int:
	return highest_floor() - 2

func is_extractable(block: JengaBlock) -> bool:
	if block == null or not is_instance_valid(block):
		return false
	return block.floor_index <= extract_limit()

func has_eligible_block() -> bool:
	var limit := extract_limit()
	for b in blocks:
		if is_instance_valid(b) and b.floor_index <= limit:
			return true
	return false

func _floor_block_count(floor_i: int) -> int:
	var n := 0
	for b in blocks:
		if is_instance_valid(b) and not b.extracted and b.floor_index == floor_i:
			n += 1
	return n

# Siguiente hueco ordenado en la cima: 3 bloques por piso con orientacion
# alternada. Devuelve {} si ya se alcanzo el maximo de pisos.
func next_top_transform() -> Dictionary:
	var top := highest_floor()
	var floor_i := top
	var count := 0
	if top < 0:
		floor_i = 0
	else:
		count = _floor_block_count(top)
		if count >= BLOCKS_PER_FLOOR:
			floor_i = top + 1
			count = 0
	if floor_i >= GameState.MAX_TOWER_FLOORS:
		return {}
	var along_x := floor_i % 2 == 0
	var offset := float(count - 1)
	var y := 0.26 + float(floor_i) * (BLOCK_SIZE.y + 0.006)
	var pos := Vector3(0.0, y, offset) if along_x else Vector3(offset, y, 0.0)
	return {
		"position": pos,
		"floor_index": floor_i,
		"rot_y": 0.0 if along_x else deg_to_rad(90.0)
	}

func can_place() -> bool:
	return not next_top_transform().is_empty()

func tower_height() -> float:
	return float(floors) * BLOCK_SIZE.y

func _palette_for_theme() -> Array:
	if theme == 0:
		return [
			Color("#ff8a65"), Color("#ffd54f"), Color("#4dd0e1"),
			Color("#81c784"), Color("#ba68c8")
		]
	return [
		Color("#00e5ff"), Color("#ff4081"), Color("#76ff03"),
		Color("#ffd740"), Color("#e040fb")
	]
