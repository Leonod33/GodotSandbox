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
	var focus := panel_style(Color("223454"), accent.lightened(0.2), 12)
	focus.set_border_width_all(3)
	var disabled := panel_style(Color("141c2a"), Color("263247"), 12)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", focus)
	button.add_theme_stylebox_override("disabled", disabled)


static func animate_button(button: Button, accent: Color, entrance_delay := 0.0) -> void:
	button.resized.connect(func(): button.pivot_offset = button.size / 2.0)
	button.pivot_offset = button.size / 2.0
	button.scale = Vector2(0.94, 0.94)
	button.modulate.a = 0.0
	var entrance: Tween = button.create_tween()
	entrance.set_parallel(true)
	entrance.tween_property(button, "scale", Vector2.ONE, 0.28).set_delay(entrance_delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	entrance.tween_property(button, "modulate:a", 1.0, 0.2).set_delay(entrance_delay)

	if button.disabled:
		return
	button.focus_entered.connect(func():
		animate_scale(button, Vector2(1.035, 1.035))
		Sandbox.play_move()
	)
	button.focus_exited.connect(func(): animate_scale(button, Vector2.ONE))
	button.mouse_entered.connect(func(): animate_scale(button, Vector2(1.025, 1.025)))
	button.mouse_exited.connect(func():
		if not button.has_focus():
			animate_scale(button, Vector2.ONE)
	)
	button.pressed.connect(Sandbox.play_confirm)
	button.add_theme_color_override("font_focus_color", accent.lightened(0.22))


static func animate_scale(control: Control, target: Vector2) -> void:
	var tween: Tween = control.create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(control, "scale", target, 0.11)
