class_name ResultOverlay
extends Control

var _panel: PanelContainer
var _vbox: VBoxContainer
var _title: Label
var _info_box: VBoxContainer
var _actions_box: HBoxContainer

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	_build()

func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.75)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	_panel = PanelContainer.new()
	_panel.anchor_left = 0.5
	_panel.anchor_right = 0.5
	_panel.anchor_top = 0.5
	_panel.anchor_bottom = 0.5
	_panel.offset_left = -430
	_panel.offset_right = 430
	_panel.offset_top = -560
	_panel.offset_bottom = 560
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#1c1c32")
	style.border_color = Color("#1de9b6")
	style.set_border_width_all(4)
	style.set_corner_radius_all(28)
	style.set_content_margin_all(30)
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)

	_vbox = VBoxContainer.new()
	_vbox.add_theme_constant_override("separation", 20)
	_panel.add_child(_vbox)

	_title = Label.new()
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_title.add_theme_font_size_override("font_size", 52)
	_title.add_theme_color_override("font_color", Color("#1de9b6"))
	_vbox.add_child(_title)

	_info_box = VBoxContainer.new()
	_info_box.add_theme_constant_override("separation", 12)
	_vbox.add_child(_info_box)

	_actions_box = HBoxContainer.new()
	_actions_box.alignment = BoxContainer.ALIGNMENT_CENTER
	_actions_box.add_theme_constant_override("separation", 20)
	_vbox.add_child(_actions_box)

func open(title: String, lines: Array, actions: Array) -> void:
	_title.text = title
	for c in _info_box.get_children():
		c.queue_free()
	for line in lines:
		var l := Label.new()
		l.text = str(line)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.add_theme_font_size_override("font_size", 30)
		l.add_theme_color_override("font_color", Color("#e8eaf6"))
		_info_box.add_child(l)
	for c in _actions_box.get_children():
		c.queue_free()
	for action in actions:
		var b := Button.new()
		b.text = str(action.get("text", "OK"))
		b.custom_minimum_size = Vector2(280, 96)
		b.add_theme_font_size_override("font_size", 30)
		b.add_theme_color_override("font_color", Color.WHITE)
		var color: Color = action.get("color", Color("#1de9b6"))
		_style_button(b, color)
		b.pressed.connect(_do_action.bind(action.get("cb", Callable())))
		_actions_box.add_child(b)
	visible = true
	modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.2)

func close() -> void:
	visible = false

func _do_action(cb: Callable) -> void:
	visible = false
	if cb.is_valid():
		cb.call()

func _style_button(btn: Button, color: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = color
	normal.set_corner_radius_all(18)
	var hover := normal.duplicate()
	hover.bg_color = color.lightened(0.15)
	var pressed := normal.duplicate()
	pressed.bg_color = color.darkened(0.2)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("focus", normal.duplicate())
