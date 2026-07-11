class_name UIFactory
extends RefCounted


static func panel_style(color: Color, border_color := Color("30425f"), radius := 16) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border_color
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 22
	style.content_margin_right = 22
	style.content_margin_top = 18
	style.content_margin_bottom = 18
	return style


static func style_button(button: Button, accent: Color, large := false) -> void:
	button.custom_minimum_size = Vector2(0, 64 if large else 46)
	button.add_theme_font_size_override("font_size", 20 if large else 16)
	button.add_theme_color_override("font_color", Color("eaf2ff"))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)

	var normal := panel_style(Color("18243a"), Color("30425f"), 12)
	var hover := panel_style(Color("223454"), accent, 12)
	var pressed := panel_style(Color("101a2c"), accent, 12)
	var disabled := panel_style(Color("141c2a"), Color("263247"), 12)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)

