class_name HUD
extends Control

signal menu_pressed

var _level_label: Label
var _tower_label: Label
var _players_box: VBoxContainer
var _hint_label: Label
var _hint_timer: SceneTreeTimer = null
const HINT_DEFAULT := "Saca un bloque de los pisos bajos y llévalo a la cima · Arrastra el fondo para girar · Pellizca para zoom"
var _panels: Array = []
var _name_labels: Array = []
var _stat_labels: Array = []

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build()
	update_all()

func _build() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(margin)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 16)
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(vb)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 16)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_child(top)

	_level_label = Label.new()
	_level_label.add_theme_font_size_override("font_size", 34)
	_level_label.add_theme_color_override("font_color", Color.WHITE)
	_level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_level_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(_level_label)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(spacer)

	var menu_btn := Button.new()
	menu_btn.text = "SALIR"
	menu_btn.custom_minimum_size = Vector2(150, 64)
	menu_btn.add_theme_font_size_override("font_size", 24)
	menu_btn.add_theme_color_override("font_color", Color.WHITE)
	_style_button(menu_btn, Color("#ff5252"))
	menu_btn.pressed.connect(func() -> void: menu_pressed.emit())
	top.add_child(menu_btn)

	_tower_label = Label.new()
	_tower_label.add_theme_font_size_override("font_size", 30)
	_tower_label.add_theme_color_override("font_color", Color("#ffd54f"))
	_tower_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_child(_tower_label)

	_players_box = VBoxContainer.new()
	_players_box.add_theme_constant_override("separation", 12)
	_players_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_child(_players_box)

	var grow := Control.new()
	grow.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_child(grow)

	_hint_label = Label.new()
	_hint_label.text = HINT_DEFAULT
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint_label.add_theme_font_size_override("font_size", 24)
	_hint_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.85))
	_hint_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_child(_hint_label)

func rebuild_for_match() -> void:
	for c in _players_box.get_children():
		c.queue_free()
	_panels.clear()
	_name_labels.clear()
	_stat_labels.clear()
	for i in GameState.players.size():
		_create_player_panel(i)
	set_turn(GameState.current_player)
	update_all()

func _create_player_panel(index: int) -> void:
	var p: GameState.PlayerData = GameState.players[index]
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.set_meta("index", index)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(box)

	var name_label := Label.new()
	name_label.text = p.name
	name_label.add_theme_font_size_override("font_size", 34)
	name_label.add_theme_color_override("font_color", p.color)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(name_label)

	var stat_label := Label.new()
	stat_label.add_theme_font_size_override("font_size", 26)
	stat_label.add_theme_color_override("font_color", Color.WHITE)
	stat_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(stat_label)

	_players_box.add_child(panel)
	_panels.append(panel)
	_name_labels.append(name_label)
	_stat_labels.append(stat_label)
	panel.add_theme_stylebox_override("panel", _panel_style(p.color, false))

func set_turn(index: int) -> void:
	for i in _panels.size():
		var p: GameState.PlayerData = GameState.players[i]
		var style := _panel_style(p.color, i == index)
		(_panels[i] as PanelContainer).add_theme_stylebox_override("panel", style)
		var target := 1.0 if (i == index or _panels.size() == 1) else 0.55
		(_panels[i] as PanelContainer).modulate = Color(target, target, target, 1.0)

func update_all() -> void:
	_level_label.text = "NIVEL %d" % GameState.level
	if _tower_label != null:
		_tower_label.text = "TORRE %d/%d pisos   ·   Bloques apilados: %d" % [
			GameState.tower_height, GameState.goal_height, GameState.stacked_blocks
		]
	for i in _stat_labels.size():
		var p: GameState.PlayerData = GameState.players[i]
		_stat_labels[i].text = "VIDAS %s   ★ %d   ● %d   ⬛ %d" % [_hearts(p.lives), p.stars, p.coins, p.blocks]

func flash_hint(text: String) -> void:
	if _hint_label == null:
		return
	_hint_label.text = text
	_hint_label.add_theme_color_override("font_color", Color("#ff8a80"))
	if _hint_timer != null and _hint_timer.timeout.is_connected(_reset_hint):
		_hint_timer.timeout.disconnect(_reset_hint)
	_hint_timer = get_tree().create_timer(1.6)
	_hint_timer.timeout.connect(_reset_hint)

func _reset_hint() -> void:
	if _hint_label == null:
		return
	_hint_label.text = HINT_DEFAULT
	_hint_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.85))

func _hearts(lives: int) -> String:
	return "♥".repeat(maxi(lives, 0)) + "♡".repeat(maxi(GameState.START_LIVES - lives, 0))

func _panel_style(color: Color, active: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.06, 0.06, 0.14, 0.82)
	s.border_color = color if active else Color(color, 0.4)
	s.set_border_width_all(6 if active else 3)
	s.set_corner_radius_all(20)
	s.set_content_margin_all(18)
	return s

func _style_button(btn: Button, color: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = color
	normal.set_corner_radius_all(16)
	var hover := normal.duplicate()
	hover.bg_color = color.lightened(0.15)
	var pressed := normal.duplicate()
	pressed.bg_color = color.darkened(0.2)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("focus", normal.duplicate())
