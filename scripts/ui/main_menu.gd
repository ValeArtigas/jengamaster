class_name MainMenu
extends Control

signal mode_selected(mode: int)

const INK := Color("#1b1b1b")
const POP_YELLOW := Color("#ffd23f")
const POP_PINK := Color("#ff4fa3")
const POP_CYAN := Color("#00c2ff")
const POP_ORANGE := Color("#ff8a3d")

var _popup: Control
var _wallet_label: Label
var _record_label: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()
	resized.connect(queue_redraw)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), POP_YELLOW)

	# Rayos de sol tras el titulo.
	var center := Vector2(size.x * 0.5, size.y * 0.22)
	var rays := 22
	var r := Vector2(size.x, size.y).length()
	for i in rays:
		var a0 := TAU * float(i) / float(rays)
		var a1 := a0 + TAU / float(rays) * 0.55
		var col := POP_ORANGE if i % 2 == 0 else Color("#ffc93c")
		draw_colored_polygon(PackedVector2Array([
			center,
			center + Vector2(cos(a0), sin(a0)) * r,
			center + Vector2(cos(a1), sin(a1)) * r
		]), col)

	# Trama de puntos estilo Ben-Day.
	var spacing := 46.0
	var y := spacing * 0.5
	while y < size.y:
		var x := spacing * 0.5
		while x < size.x:
			draw_circle(Vector2(x, y), 5.0, Color(1, 1, 1, 0.16))
			x += spacing
		y += spacing

	# Franjas de color y marco de comic.
	draw_rect(Rect2(0, 0, size.x, 20), POP_PINK)
	draw_rect(Rect2(0, size.y - 20, size.x, 20), POP_CYAN)
	draw_rect(Rect2(Vector2.ZERO, size), INK, false, 12.0)

func _build() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 70)
	margin.add_theme_constant_override("margin_right", 70)
	margin.add_theme_constant_override("margin_top", 110)
	margin.add_theme_constant_override("margin_bottom", 90)
	add_child(margin)

	var vb := VBoxContainer.new()
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_theme_constant_override("separation", 24)
	margin.add_child(vb)

	var title := Label.new()
	title.text = "TORRE DEL\nSABER"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 104)
	title.add_theme_color_override("font_color", POP_PINK)
	title.add_theme_color_override("font_outline_color", INK)
	title.add_theme_constant_override("outline_size", 16)
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.35))
	title.add_theme_constant_override("shadow_offset_x", 6)
	title.add_theme_constant_override("shadow_offset_y", 8)
	title.add_theme_constant_override("shadow_outline_size", 2)
	vb.add_child(title)

	var sub := Label.new()
	sub.text = "EL RETO JENGA 3D"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 38)
	sub.add_theme_color_override("font_color", Color.WHITE)
	sub.add_theme_color_override("font_outline_color", INK)
	sub.add_theme_constant_override("outline_size", 8)
	vb.add_child(sub)

	vb.add_child(_spacer(6))

	_wallet_label = Label.new()
	_wallet_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_wallet_label.add_theme_font_size_override("font_size", 30)
	_wallet_label.add_theme_color_override("font_color", Color.WHITE)
	_wallet_label.add_theme_color_override("font_outline_color", INK)
	_wallet_label.add_theme_constant_override("outline_size", 6)
	vb.add_child(_wallet_label)
	_update_wallet_label()

	_record_label = Label.new()
	_record_label.text = "RÉCORD: %d   ·   AMBIENTE: %s" % [GameState.best_score, GameState.environment_name(GameState.selected_env)]
	_record_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_record_label.add_theme_font_size_override("font_size", 24)
	_record_label.add_theme_color_override("font_color", INK)
	vb.add_child(_record_label)

	vb.add_child(_spacer(16))

	var p1 := _make_button("1 JUGADOR", POP_CYAN, 36)
	p1.pressed.connect(func() -> void: mode_selected.emit(GameState.Mode.SINGLE))
	vb.add_child(p1)

	var p2 := _make_button("2 JUGADORES", POP_PINK, 36)
	p2.pressed.connect(func() -> void: mode_selected.emit(GameState.Mode.VERSUS))
	vb.add_child(p2)

	var shop := _make_button("TIENDA DE AMBIENTES", POP_ORANGE, 32)
	shop.pressed.connect(_show_shop)
	vb.add_child(shop)

	var help := _make_button("CÓMO JUGAR", Color("#7c4dff"), 28)
	help.pressed.connect(_on_help)
	vb.add_child(help)

	var credits := _make_button("CRÉDITOS", Color("#2ec4b6"), 28)
	credits.pressed.connect(_on_credits)
	vb.add_child(credits)

func _update_wallet_label() -> void:
	if _wallet_label == null:
		return
	_wallet_label.text = "● %d MONEDAS" % GameState.wallet

func _refresh_record_label() -> void:
	if _record_label == null:
		return
	_record_label.text = "RÉCORD: %d   ·   AMBIENTE: %s" % [GameState.best_score, GameState.environment_name(GameState.selected_env)]

func _on_help() -> void:
	_show_popup("CÓMO JUGAR", [
		"Saca con cuidado un bloque de los pisos bajos (no los 2 de arriba).",
		"El bloque sube solo a la cima y se acomoda formando un piso nuevo.",
		"Responde la TRIVIA: acierto = crece y sumas puntos; error = desaparece.",
		"Gana monedas ● respondiendo Cultura General.",
		"Cambia el escenario en la TIENDA DE AMBIENTES.",
		"Si la torre COLAPSA en tu turno, pierdes.",
		"Objetivo: llegar a 20 pisos."
	])

func _on_credits() -> void:
	_show_popup("CRÉDITOS", [
		"Torre del Saber: El Reto Jenga 3D",
		"Juego educativo de permutaciones · Unidad III",
		"Estilo Pop Art · Hecho con Godot 4"
	])

# --- Tienda de ambientaciones -------------------------------------------

func _show_shop() -> void:
	_close_popup()
	_popup = Control.new()
	_popup.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.78)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_popup.add_child(dim)

	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -460
	panel.offset_right = 460
	panel.offset_top = -720
	panel.offset_bottom = 720
	panel.add_theme_stylebox_override("panel", _panel_style(POP_ORANGE))
	_popup.add_child(panel)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 20)
	panel.add_child(vb)

	var title := Label.new()
	title.text = "TIENDA DE AMBIENTES"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 44)
	title.add_theme_color_override("font_color", Color.WHITE)
	title.add_theme_color_override("font_outline_color", INK)
	title.add_theme_constant_override("outline_size", 10)
	vb.add_child(title)

	var bal := Label.new()
	bal.text = "Tus monedas: ● %d" % GameState.wallet
	bal.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bal.add_theme_font_size_override("font_size", 32)
	bal.add_theme_color_override("font_color", POP_YELLOW)
	bal.add_theme_color_override("font_outline_color", INK)
	bal.add_theme_constant_override("outline_size", 6)
	vb.add_child(bal)

	for id in GameState.ENVIRONMENTS.size():
		vb.add_child(_shop_row(id))

	var close_btn := _make_button("VOLVER", Color("#ff5252"), 30)
	close_btn.pressed.connect(_close_popup)
	vb.add_child(close_btn)

	add_child(_popup)

func _shop_row(id: int) -> PanelContainer:
	var owned := GameState.owns_env(id)
	var selected := GameState.selected_env == id
	var price := GameState.environment_price(id)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style(POP_CYAN if selected else Color("#ffffff")))

	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 16)
	panel.add_child(hb)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(info)

	var name_label := Label.new()
	name_label.text = GameState.environment_name(id)
	name_label.add_theme_font_size_override("font_size", 34)
	name_label.add_theme_color_override("font_color", INK)
	info.add_child(name_label)

	var desc := Label.new()
	desc.text = GameState.environment_desc(id)
	desc.add_theme_font_size_override("font_size", 22)
	desc.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	info.add_child(desc)

	var btn := Button.new()
	btn.custom_minimum_size = Vector2(230, 92)
	btn.add_theme_font_size_override("font_size", 26)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_color_override("font_outline_color", INK)
	btn.add_theme_constant_override("outline_size", 5)

	if selected:
		btn.text = "EN USO"
		btn.disabled = true
		_style_button(btn, Color("#7a7a7a"))
	elif owned:
		btn.text = "USAR"
		_style_button(btn, Color("#1de9b6"))
		btn.pressed.connect(func() -> void:
			GameState.select_env(id)
			_refresh_record_label()
			_show_shop())
	else:
		btn.text = "COMPRAR ●%d" % price
		if GameState.can_afford(id):
			_style_button(btn, POP_PINK)
		else:
			_style_button(btn, Color("#9e9e9e"))
			btn.disabled = true
		btn.pressed.connect(func() -> void:
			if GameState.buy_env(id):
				AudioManager.play("correct")
			else:
				AudioManager.play("wrong")
			_refresh_record_label()
			_show_shop())

	hb.add_child(btn)
	return panel

func _close_popup() -> void:
	if is_instance_valid(_popup):
		_popup.queue_free()
	_popup = null

func _show_popup(title_text: String, lines: Array) -> void:
	_close_popup()
	_popup = Control.new()
	_popup.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.78)
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
	panel.add_theme_stylebox_override("panel", _panel_style(POP_CYAN))
	_popup.add_child(panel)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 18)
	panel.add_child(vb)

	var tl := Label.new()
	tl.text = title_text
	tl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tl.add_theme_font_size_override("font_size", 48)
	tl.add_theme_color_override("font_color", Color.WHITE)
	tl.add_theme_color_override("font_outline_color", INK)
	tl.add_theme_constant_override("outline_size", 10)
	vb.add_child(tl)

	for line in lines:
		var l := Label.new()
		l.text = str(line)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.add_theme_font_size_override("font_size", 27)
		l.add_theme_color_override("font_color", INK)
		vb.add_child(l)

	var close_btn := _make_button("CERRAR", Color("#ff5252"), 28)
	close_btn.pressed.connect(_close_popup)
	vb.add_child(close_btn)

	add_child(_popup)

# --- Estilos pop art ----------------------------------------------------

func _panel_style(color: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(22)
	s.set_border_width_all(8)
	s.border_color = INK
	s.set_content_margin_all(24)
	s.shadow_color = Color(0, 0, 0, 0.4)
	s.shadow_size = 16
	s.shadow_offset = Vector2(0, 8)
	return s

func _make_button(text_value: String, color: Color, font_size: int) -> Button:
	var btn := Button.new()
	btn.text = text_value
	btn.custom_minimum_size = Vector2(0, 116)
	btn.add_theme_font_size_override("font_size", font_size)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_color_override("font_outline_color", INK)
	btn.add_theme_constant_override("outline_size", 7)
	_style_button(btn, color)
	return btn

func _style_button(btn: Button, color: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = color
	normal.set_corner_radius_all(18)
	normal.set_border_width_all(7)
	normal.border_color = INK
	normal.set_content_margin_all(16)
	normal.shadow_color = Color(0, 0, 0, 0.45)
	normal.shadow_size = 18
	normal.shadow_offset = Vector2(0, 10)

	var hover := normal.duplicate()
	hover.bg_color = color.lightened(0.12)
	hover.shadow_offset = Vector2(0, 12)

	var pressed := normal.duplicate()
	pressed.bg_color = color.darkened(0.15)
	pressed.shadow_size = 6
	pressed.shadow_offset = Vector2(0, 3)

	var disabled := normal.duplicate()
	disabled.bg_color = color
	disabled.shadow_size = 8
	disabled.shadow_offset = Vector2(0, 4)

	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("disabled", disabled)
	btn.add_theme_stylebox_override("focus", normal.duplicate())

func _spacer(height: float) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, height)
	return c
