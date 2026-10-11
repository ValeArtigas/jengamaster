class_name TurnBanner
extends Control

var _label: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label = Label.new()
	_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override("font_size", 60)
	_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	_label.add_theme_constant_override("outline_size", 8)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.modulate.a = 0.0
	add_child(_label)

func announce(text: String, color: Color) -> void:
	_label.text = text
	_label.add_theme_color_override("font_color", color)
	_label.pivot_offset = size * 0.5
	var tw := create_tween()
	tw.tween_property(_label, "modulate:a", 1.0, 0.18)
	tw.parallel().tween_property(_label, "scale", Vector2.ONE, 0.25).from(Vector2(0.4, 0.4)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_interval(0.8)
	tw.tween_property(_label, "modulate:a", 0.0, 0.35)
