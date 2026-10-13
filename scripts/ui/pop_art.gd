class_name PopArt
extends RefCounted

const INK := Color("#1b1b1b")
const YELLOW := Color("#ffd23f")
const PINK := Color("#ff4fa3")
const CYAN := Color("#00c2ff")
const ORANGE := Color("#ff8a3d")
const PURPLE := Color("#7c4dff")
const GREEN := Color("#1de9b6")
const CREAM := Color("#fff6d5")
const RED := Color("#ff5252")

static func sticker_style(color: Color, radius: int = 18, border: int = 7, shadow: int = 14) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(radius)
	s.set_border_width_all(border)
	s.border_color = INK
	s.set_content_margin_all(16)
	s.shadow_color = Color(0, 0, 0, 0.45)
	s.shadow_size = shadow
	s.shadow_offset = Vector2(0, maxf(4.0, float(shadow) * 0.55))
	return s

static func panel_style(color: Color = CREAM) -> StyleBoxFlat:
	var s := sticker_style(color, 26, 8, 18)
	s.set_content_margin_all(30)
	return s

static func style_button(btn: Button, color: Color) -> void:
	var normal := sticker_style(color)
	var hover := normal.duplicate()
	hover.bg_color = color.lightened(0.12)
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

static func style_label(label: Label, font_size: int, color: Color, outline_size: int = 8) -> void:
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", INK)
	label.add_theme_constant_override("outline_size", outline_size)

static func style_header(label: Label, font_size: int, color: Color) -> void:
	style_label(label, font_size, color, 12)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.35))
	label.add_theme_constant_override("shadow_offset_x", 5)
	label.add_theme_constant_override("shadow_offset_y", 6)
