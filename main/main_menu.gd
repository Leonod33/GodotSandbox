extends Control


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("09111f"))
	var background := MenuBackground.new()
	background.setup(Color("62d9ff"))
	add_child(background)
	build_interface()


func build_interface() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 72)
	margin.add_theme_constant_override("margin_right", 72)
	margin.add_theme_constant_override("margin_top", 52)
	margin.add_theme_constant_override("margin_bottom", 42)
	add_child(margin)

	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 22)
	margin.add_child(page)

	var eyebrow := Label.new()
	eyebrow.text = "PERSONAL GODOT LABORATORY  /  BUILD 001"
	eyebrow.add_theme_color_override("font_color", Color("62d9ff"))
	eyebrow.add_theme_font_size_override("font_size", 15)
	page.add_child(eyebrow)

	var title := Label.new()
	title.text = "GODOT SANDBOX"
	title.add_theme_color_override("font_color", Color("f5f8ff"))
	title.add_theme_font_size_override("font_size", 48)
	page.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Pick a testing environment. Break things deliberately. Keep the useful bits."
	subtitle.add_theme_color_override("font_color", Color("9fb0ca"))
	subtitle.add_theme_font_size_override("font_size", 19)
	page.add_child(subtitle)

	var spacer := Control.new()
	spacer.custom_minimum_size.y = 10
	page.add_child(spacer)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 18)
	grid.add_theme_constant_override("v_separation", 18)
	page.add_child(grid)

	var first_button: Button
	var card_index: int = 0
	for category_id in Sandbox.categories:
		var category_button := create_category_card(category_id, Sandbox.categories[category_id])
		grid.add_child(category_button)
		UIFactory.animate_button(category_button, Sandbox.categories[category_id].accent, 0.05 + card_index * 0.055)
		card_index += 1
		if first_button == null:
			first_button = category_button
	first_button.grab_focus.call_deferred()

	var footer := Label.new()
	footer.text = "Navigate: D-pad / Left Stick     Select: A / Cross     Mouse and keyboard also supported"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_color_override("font_color", Color("60708b"))
	footer.add_theme_font_size_override("font_size", 14)
	page.add_child(footer)


func create_category_card(category_id: String, data: Dictionary) -> Button:
	var button := Button.new()
	button.text = "%s   %s\n%s\n\n%d MODULE%s" % [
		data.icon,
		data.title,
		data.description,
		data.modules.size(),
		"" if data.modules.size() == 1 else "S"
	]
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(290, 155)
	UIFactory.style_button(button, data.accent, true)
	button.pressed.connect(Sandbox.open_category.bind(category_id))
	return button
