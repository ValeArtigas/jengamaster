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

func remaining() -> int:
	return blocks.size()

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
