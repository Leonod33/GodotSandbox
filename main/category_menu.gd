extends Control


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("09111f"))
	if Sandbox.selected_category.is_empty() or not Sandbox.categories.has(Sandbox.selected_category):
		Sandbox.go_home()
		return
	build_interface(Sandbox.categories[Sandbox.selected_category])


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("sandbox_back"):
		get_viewport().set_input_as_handled()
		Sandbox.go_home()


func build_interface(data: Dictionary) -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 72)
	margin.add_theme_constant_override("margin_right", 72)
	margin.add_theme_constant_override("margin_top", 44)
	margin.add_theme_constant_override("margin_bottom", 44)
	add_child(margin)

	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 20)
	margin.add_child(page)

	var back := Button.new()
	back.text = "←  ALL ENVIRONMENTS"
	back.custom_minimum_size.x = 230
	back.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	UIFactory.style_button(back, data.accent)
	back.pressed.connect(Sandbox.go_home)
	page.add_child(back)

	var title := Label.new()
	title.text = "%s  %s" % [data.icon, data.title]
	title.add_theme_color_override("font_color", Color("f5f8ff"))
	title.add_theme_font_size_override("font_size", 42)
	page.add_child(title)

	var subtitle := Label.new()
	subtitle.text = data.description
	subtitle.add_theme_color_override("font_color", Color("9fb0ca"))
	subtitle.add_theme_font_size_override("font_size", 18)
	page.add_child(subtitle)

	var modules := VBoxContainer.new()
	modules.size_flags_vertical = Control.SIZE_EXPAND_FILL
	modules.add_theme_constant_override("separation", 14)
	page.add_child(modules)

	var first_ready_button: Button
	for module in data.modules:
		var module_button := create_module_card(module, data.accent)
		modules.add_child(module_button)
		if first_ready_button == null and not module_button.disabled:
			first_ready_button = module_button
	if first_ready_button:
		first_ready_button.grab_focus.call_deferred()
	else:
		back.grab_focus.call_deferred()


func create_module_card(module: Dictionary, accent: Color) -> Button:
	var button := Button.new()
	button.text = "%s     %s\n          %s" % [module.status, module.title, module.description]
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.custom_minimum_size.y = 100
	button.disabled = module.scene.is_empty()
	UIFactory.style_button(button, accent, true)
	if not button.disabled:
		button.pressed.connect(Sandbox.open_module.bind(module.scene))
	return button
