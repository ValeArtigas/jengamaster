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
	dim.color = Color(0, 0, 0, 0.80)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	_panel = PanelContainer.new()
	_panel.anchor_left = 0.5
	_panel.anchor_right = 0.5
	_panel.anchor_top = 0.5
	_panel.anchor_bottom = 0.5
	_panel.offset_left = -480
	_panel.offset_right = 480
	_panel.offset_top = -660
	_panel.offset_bottom = 660
	_panel.add_theme_stylebox_override("panel", PopArt.panel_style(PopArt.CREAM))
	add_child(_panel)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 18)
	_panel.add_child(vb)

	var header := Label.new()
	header.text = "¿SABES LA RESPUESTA?"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	PopArt.style_header(header, 40, PopArt.PINK)
	vb.add_child(header)

	_category_label = Label.new()
	_category_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_category_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	PopArt.style_header(_category_label, 26, PopArt.PURPLE)
	vb.add_child(_category_label)

	_question_label = Label.new()
	_question_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_question_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_question_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_question_label.custom_minimum_size = Vector2(0, 220)
	_question_label.add_theme_font_size_override("font_size", 34)
	_question_label.add_theme_color_override("font_color", PopArt.INK)
	vb.add_child(_question_label)

	_options_box = VBoxContainer.new()
	_options_box.add_theme_constant_override("separation", 16)
	vb.add_child(_options_box)

	_buttons.clear()
	for i in 4:
		var b := _make_option_button(i)
		_options_box.add_child(b)
		_buttons.append(b)

	_feedback_label = Label.new()
	_feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	PopArt.style_header(_feedback_label, 32, PopArt.GREEN)
	_feedback_label.visible = false
	vb.add_child(_feedback_label)

	_continue_btn = _make_button("CONTINUAR", PopArt.GREEN, 30)
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
	_category_label.add_theme_color_override("font_color", PopArt.PURPLE if cat == Trivia.CATEGORY_CULTURA else PopArt.PINK)
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
	_buttons[correct_index].modulate = Color(0.55, 1.5, 0.6)
	if index != correct_index and index >= 0 and index < _buttons.size():
		_buttons[index].modulate = Color(1.7, 0.45, 0.45)

	var is_correct := index == correct_index
	_feedback_label.visible = true
	_feedback_label.text = "¡CORRECTO! GANASTE UNA RECOMPENSA" if is_correct else "¡UPS! RESPUESTA INCORRECTA"
	_feedback_label.add_theme_color_override("font_color", PopArt.GREEN if is_correct else PopArt.RED)
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
	b.custom_minimum_size = Vector2(0, 104)
	b.add_theme_font_size_override("font_size", 28)
	b.add_theme_color_override("font_color", Color.WHITE)
	b.add_theme_color_override("font_outline_color", PopArt.INK)
	b.add_theme_constant_override("outline_size", 6)
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.pressed.connect(_on_option.bind(index))
	return b

func _style_options() -> void:
	for i in _buttons.size():
		var b: Button = _buttons[i]
		b.add_theme_stylebox_override("normal", PopArt.sticker_style(PopArt.CYAN))
		b.add_theme_stylebox_override("hover", PopArt.sticker_style(PopArt.CYAN.lightened(0.15)))
		b.add_theme_stylebox_override("pressed", PopArt.sticker_style(PopArt.CYAN.darkened(0.15), 18, 7, 4))
		b.add_theme_stylebox_override("disabled", PopArt.sticker_style(PopArt.CYAN))
		b.add_theme_stylebox_override("focus", PopArt.sticker_style(PopArt.CYAN))

func _make_button(text: String, color: Color, font_size: int) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 104)
	b.add_theme_font_size_override("font_size", font_size)
	b.add_theme_color_override("font_color", Color.WHITE)
	b.add_theme_color_override("font_outline_color", PopArt.INK)
	b.add_theme_constant_override("outline_size", 7)
	PopArt.style_button(b, color)
	return b

func _pretty_category(cat: String) -> String:
	if cat == Trivia.CATEGORY_UNIDAD:
		return "UNIDAD III · PREMIO: ESTRELLA"
	if cat == Trivia.CATEGORY_CULTURA:
		return "CULTURA GENERAL · PREMIO: MONEDA"
	return cat
