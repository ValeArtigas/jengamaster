class_name Menu
extends Control

signal game_requested

var main: Node
var popup: Control

func _init(main_ref: Node) -> void:
	main = main_ref

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	resized.connect(_queue_redraw_safe)

func _queue_redraw_safe() -> void:
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#12121f"))
	var neon := Color(0.0, 0.91, 0.71, 0.12)
	for i in 14:
		var x := size.x * float(i) / 14.0
		draw_line(Vector2(x, 0.0), Vector2(x, size.y), neon, 1.0)
	for i in 8:
		var y := size.y * float(i) / 8.0
		draw_line(Vector2(0.0, y), Vector2(size.x, y), neon, 1.0)
	draw_rect(Rect2(Vector2(size.x * 0.08, size.y * 0.12), Vector2(size.x * 0.84, 6.0)), Color(0.0, 0.91, 0.71, 0.6))
	draw_rect(Rect2(Vector2(size.x * 0.08, size.y * 0.86), Vector2(size.x * 0.84, 6.0)), Color(1.0, 0.23, 0.62, 0.5))

func _build_ui() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 30)
	add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 18)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "JENGAMASTER"
	title.add_theme_font_size_override("font_size", 76)
	title.add_theme_color_override("font_color", Color("#1de9b6"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Torre de Permutaciones · Unidad III"
	subtitle.add_theme_font_size_override("font_size", 24)
	subtitle.add_theme_color_override("font_color", Color("#aab0c8"))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(subtitle)

	var progress := Label.new()
	progress.text = "PROGRESO: %d monedas   |   %d estrellas   |   Mejor nivel: %d   |   Récord: %d" % [main.coins, main.stars, main.max_level, main.best_score]
	progress.add_theme_font_size_override("font_size", 18)
	progress.add_theme_color_override("font_color", Color("#ffd54f"))
	progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(progress)

	vbox.add_child(_spacer(20.0))

	var play_btn := _make_button("JUGAR", Color("#1de9b6"), 36)
	play_btn.pressed.connect(_on_play)
	vbox.add_child(play_btn)

	var help_btn := _make_button("CÓMO JUGAR", Color("#3d5afe"), 26)
	help_btn.pressed.connect(_on_help)
	vbox.add_child(help_btn)

	var credits_btn := _make_button("CRÉDITOS", Color("#7c4dff"), 26)
	credits_btn.pressed.connect(_on_credits)
	vbox.add_child(credits_btn)

func _on_play() -> void:
	game_requested.emit()

func _on_help() -> void:
	var lines := [
		"Toca el bloque cuya respuesta sea CORRECTA para extraerlo de la torre.",
		"Respuesta correcta: ganas monedas y la torre sigue en pie.",
		"Respuesta incorrecta: pierdes 1 vida y la torre tiembla.",
		"Los bloques DORADOS dan un bonus: vida extra, monedas o estrella.",
		"Cada 5 aciertos ganas 1 estrella.",
		"Completa 10 aciertos para superar el nivel.",
		"Si te quedas sin vidas, se acaba la partida.",
		"Preguntas de la Unidad III: Permutaciones + cultura general."
	]
	_show_popup("CÓMO JUGAR", lines)

func _on_credits() -> void:
	var lines := [
		"JengaMaster",
		"Juego de permutaciones con temática Jenga.",
		"Unidad III - Permutaciones",
		"Hecho con Godot 4"
	]
	_show_popup("CRÉDITOS", lines)

func _show_popup(title_text: String, lines: Array) -> void:
	if is_instance_valid(popup):
		popup.queue_free()
	popup = Control.new()
	popup.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	popup.add_child(dim)
	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -320
	panel.offset_right = 320
	panel.offset_top = -220
	panel.offset_bottom = 220
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#1c1c32")
	style.border_color = Color("#1de9b6")
	style.set_border_width_all(2)
	style.set_corner_radius_all(16)
	style.set_content_margin_all(28)
	panel.add_theme_stylebox_override("panel", style)
	popup.add_child(panel)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 14)
	panel.add_child(vb)

	var tl := Label.new()
	tl.text = title_text
	tl.add_theme_font_size_override("font_size", 32)
	tl.add_theme_color_override("font_color", Color("#1de9b6"))
	tl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(tl)

	for line in lines:
		var l := Label.new()
		l.text = line
		l.add_theme_font_size_override("font_size", 17)
		l.add_theme_color_override("font_color", Color("#e8eaf6"))
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vb.add_child(l)

	var close_btn := _make_button("CERRAR", Color("#ff5252"), 22)
	close_btn.pressed.connect(func() -> void: popup.queue_free())
	vb.add_child(close_btn)

	add_child(popup)

func _make_button(text_value: String, color: Color, font_size: int) -> Button:
	var btn := Button.new()
	btn.text = text_value
	btn.custom_minimum_size = Vector2(320, 54)
	btn.add_theme_font_size_override("font_size", font_size)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_color_override("font_hover_color", Color.WHITE)
	btn.add_theme_color_override("font_pressed_color", Color.WHITE)
	var normal := StyleBoxFlat.new()
	normal.bg_color = color
	normal.set_corner_radius_all(12)
	var hover := normal.duplicate()
	hover.bg_color = color.lightened(0.15)
	var pressed := normal.duplicate()
	pressed.bg_color = color.darkened(0.2)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("focus", normal.duplicate())
	return btn

func _spacer(height: float) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, height)
	return c
