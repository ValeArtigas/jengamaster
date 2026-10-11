class_name TriviaModal
extends Control

signal answered(correct: bool, category: String)

var _panel: PanelContainer
var _category_label: Label
var _question_label: Label
var _feedback_label: Label
var _options_box: VBoxContainer
var _continue_btn: Button
var _buttons: Array = []
var _question: Dictionary = {}
var _chosen: int = -1
var _locked: bool = false

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	_build()

func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.72)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	_panel = PanelContainer.new()
	_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_panel.anchor_left = 0.5
	_panel.anchor_right = 0.5
	_panel.anchor_top = 0.5
	_panel.anchor_bottom = 0.5
	_panel.offset_left = -460
	_panel.offset_right = 460
	_panel.offset_top = -620
	_panel.offset_bottom = 620
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#1c1c32")
	style.border_color = Color("#ffd54f")
	style.set_border_width_all(4)
	style.set_corner_radius_all(28)
	style.set_content_margin_all(30)
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 18)
	_panel.add_child(vb)

	_category_label = Label.new()
	_category_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_category_label.add_theme_font_size_override("font_size", 26)
	_category_label.add_theme_color_override("font_color", Color("#ffd54f"))
	vb.add_child(_category_label)

	_question_label = Label.new()
	_question_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_question_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_question_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_question_label.custom_minimum_size = Vector2(0, 220)
	_question_label.add_theme_font_size_override("font_size", 34)
	_question_label.add_theme_color_override("font_color", Color.WHITE)
	vb.add_child(_question_label)

	_options_box = VBoxContainer.new()
	_options_box.add_theme_constant_override("separation", 14)
	vb.add_child(_options_box)

	_buttons.clear()
	for i in 4:
		var b := _make_option_button(i)
		_options_box.add_child(b)
		_buttons.append(b)

	_feedback_label = Label.new()
	_feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_feedback_label.add_theme_font_size_override("font_size", 30)
	_feedback_label.visible = false
	vb.add_child(_feedback_label)

	_continue_btn = _make_button("CONTINUAR", Color("#1de9b6"), 28)
	_continue_btn.visible = false
	_continue_btn.pressed.connect(_on_continue)
	vb.add_child(_continue_btn)

func open(question: Dictionary) -> void:
	_question = question
	_chosen = -1
	_locked = false
	_feedback_label.visible = false
	_continue_btn.visible = false
	var cat := str(question.get("categoria", ""))
	_category_label.text = _pretty_category(cat)
	_question_label.text = str(question.get("pregunta", ""))
	var opts: Array = question.get("opciones", [])
	for i in _buttons.size():
		var b: Button = _buttons[i]
		b.disabled = false
		b.visible = i < opts.size()
		b.text = str(opts[i]) if i < opts.size() else ""
		b.modulate = Color.WHITE
	_style_options()
	visible = true
	modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.2)

func close() -> void:
	visible = false

func _on_option(index: int) -> void:
	if _locked:
		return
	_locked = true
	_chosen = index
	var correct_index := int(_question.get("respuesta_correcta", -1))
	for b in _buttons:
		(b as Button).disabled = true
	_buttons[correct_index].modulate = Color(0.4, 1.4, 0.5)
	if index != correct_index and index >= 0 and index < _buttons.size():
		_buttons[index].modulate = Color(1.6, 0.4, 0.4)

	var is_correct := index == correct_index
	_feedback_label.visible = true
	_feedback_label.text = "¡CORRECTO! Ganaste una recompensa" if is_correct else "¡UPS! Respuesta incorrecta"
	_feedback_label.add_theme_color_override("font_color", Color("#69f0ae") if is_correct else Color("#ff5252"))
	_continue_btn.visible = true

func _on_continue() -> void:
	if not _locked:
		return
	var correct := _chosen == int(_question.get("respuesta_correcta", -1))
	var category := str(_question.get("categoria", ""))
	visible = false
	answered.emit(correct, category)

func _make_option_button(index: int) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(0, 100)
	b.add_theme_font_size_override("font_size", 28)
	b.add_theme_color_override("font_color", Color.WHITE)
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.pressed.connect(_on_option.bind(index))
	return b

func _style_options() -> void:
	for i in _buttons.size():
		var b: Button = _buttons[i]
		b.add_theme_stylebox_override("normal", _opt_style(Color("#3d5afe")))
		b.add_theme_stylebox_override("hover", _opt_style(Color("#3d5afe").lightened(0.2)))
		b.add_theme_stylebox_override("pressed", _opt_style(Color("#3d5afe").darkened(0.2)))
		b.add_theme_stylebox_override("disabled", _opt_style(Color("#3d5afe")))
		b.add_theme_stylebox_override("focus", _opt_style(Color("#3d5afe")))

func _opt_style(color: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(16)
	s.set_content_margin_all(16)
	return s

func _make_button(text: String, color: Color, font_size: int) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 90)
	b.add_theme_font_size_override("font_size", font_size)
	b.add_theme_color_override("font_color", Color.WHITE)
	var normal := StyleBoxFlat.new()
	normal.bg_color = color
	normal.set_corner_radius_all(16)
	var hover := normal.duplicate()
	hover.bg_color = color.lightened(0.15)
	var pressed := normal.duplicate()
	pressed.bg_color = color.darkened(0.2)
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", pressed)
	b.add_theme_stylebox_override("focus", normal.duplicate())
	return b

func _pretty_category(cat: String) -> String:
	if cat == Trivia.CATEGORY_UNIDAD:
		return "UNIDAD III · Premio: ESTRELLA"
	if cat == Trivia.CATEGORY_CULTURA:
		return "CULTURA GENERAL · Premio: MONEDA"
	return cat
