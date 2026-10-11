class_name MainMenu
extends Control

signal mode_selected(mode: int)

var _popup: Control

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()
	resized.connect(queue_redraw)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#12121f"))
	for i in 10:
		var x := size.x * float(i) / 10.0
		draw_line(Vector2(x, 0), Vector2(x, size.y), Color(0.0, 0.91, 0.71, 0.10), 1.0)
	draw_rect(Rect2(Vector2(size.x * 0.08, size.y * 0.30), Vector2(size.x * 0.84, 8.0)), Color(0, 0.91, 0.71, 0.6))
	draw_rect(Rect2(Vector2(size.x * 0.08, size.y * 0.72), Vector2(size.x * 0.84, 8.0)), Color(1.0, 0.32, 0.62, 0.5))

func _build() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 60)
	margin.add_theme_constant_override("margin_right", 60)
	margin.add_theme_constant_override("margin_top", 80)
	margin.add_theme_constant_override("margin_bottom", 80)
	add_child(margin)

	var vb := VBoxContainer.new()
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_theme_constant_override("separation", 28)
	margin.add_child(vb)

	var title := Label.new()
	title.text = "TORRE DEL SABER"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 92)
	title.add_theme_color_override("font_color", Color("#1de9b6"))
	vb.add_child(title)

	var sub := Label.new()
	sub.text = "El Reto Jenga 3D\nUnidad III · Permutaciones"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 30)
	sub.add_theme_color_override("font_color", Color("#aab0c8"))
	vb.add_child(sub)

	var record := Label.new()
	record.text = "Récord: %d" % GameState.best_score
	record.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	record.add_theme_font_size_override("font_size", 26)
	record.add_theme_color_override("font_color", Color("#ffd54f"))
	vb.add_child(record)

	vb.add_child(_spacer(30))

	var p1 := _make_button("1 JUGADOR (Récord)", Color("#1de9b6"), 34)
	p1.pressed.connect(func() -> void: mode_selected.emit(GameState.Mode.SINGLE))
	vb.add_child(p1)

	var p2 := _make_button("2 JUGADORES (Turnos)", Color("#ff5298"), 34)
	p2.pressed.connect(func() -> void: mode_selected.emit(GameState.Mode.VERSUS))
	vb.add_child(p2)

	var help := _make_button("CÓMO JUGAR", Color("#3d5afe"), 28)
	help.pressed.connect(_on_help)
	vb.add_child(help)

	var credits := _make_button("CRÉDITOS", Color("#7c4dff"), 28)
	credits.pressed.connect(_on_credits)
	vb.add_child(credits)

func _on_help() -> void:
	_show_popup("CÓMO JUGAR", [
		"Toca y ARRASTRA un bloque del centro para deslizarlo fuera de la torre.",
		"Arrastra el fondo para ORBITAR la cámara. Pellizca para ZOOM.",
		"Al extraer un bloque aparece una TRIVIA.",
		"Unidad III te da ★ ESTRELLAS. Cultura General te da ● MONEDAS.",
		"Respuesta correcta: ganas recompensa y tu turno termina a salvo.",
		"Respuesta incorrecta: pierdes 1 vida y la torre tiembla.",
		"Si la torre COLAPSA en tu turno, pierdes la partida.",
		"En 2 Jugadores gana quien sobreviva a la torre."
	])

func _on_credits() -> void:
	_show_popup("CRÉDITOS", [
		"Torre del Saber: El Reto Jenga 3D",
		"Juego educativo de permutaciones · Unidad III",
		"Estilo Toon · Multijugador local Pass & Play",
		"Hecho con Godot 4"
	])

func _show_popup(title_text: String, lines: Array) -> void:
	if is_instance_valid(_popup):
		_popup.queue_free()
	_popup = Control.new()
	_popup.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.72)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_popup.add_child(dim)

	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -440
	panel.offset_right = 440
	panel.offset_top = -640
	panel.offset_bottom = 640
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#1c1c32")
	style.border_color = Color("#1de9b6")
	style.set_border_width_all(4)
	style.set_corner_radius_all(24)
	style.set_content_margin_all(30)
	panel.add_theme_stylebox_override("panel", style)
	_popup.add_child(panel)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 18)
	panel.add_child(vb)

	var tl := Label.new()
	tl.text = title_text
	tl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tl.add_theme_font_size_override("font_size", 46)
	tl.add_theme_color_override("font_color", Color("#1de9b6"))
	vb.add_child(tl)

	for line in lines:
		var l := Label.new()
		l.text = str(line)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.add_theme_font_size_override("font_size", 28)
		l.add_theme_color_override("font_color", Color("#e8eaf6"))
		vb.add_child(l)

	var close_btn := _make_button("CERRAR", Color("#ff5252"), 28)
	close_btn.pressed.connect(func() -> void: _popup.queue_free())
	vb.add_child(close_btn)

	add_child(_popup)

func _make_button(text_value: String, color: Color, font_size: int) -> Button:
	var btn := Button.new()
	btn.text = text_value
	btn.custom_minimum_size = Vector2(0, 110)
	btn.add_theme_font_size_override("font_size", font_size)
	btn.add_theme_color_override("font_color", Color.WHITE)
	var normal := StyleBoxFlat.new()
	normal.bg_color = color
	normal.set_corner_radius_all(20)
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
