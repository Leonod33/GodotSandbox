extends Node2D

const ORIGIN := Vector2(150, 520)
const GROUND_Y := 540.0
const PIXELS_PER_METRE := 5.0

var angle_degrees := 45.0
var launch_speed := 30.0
var gravity := 9.8
var projectile_position := ORIGIN
var projectile_velocity := Vector2.ZERO
var projectile_flying := false
var trail: Array[Vector2] = []
var readout: Label


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("08101d"))
	build_interface()
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("sandbox_back"):
		Sandbox.open_category("physics")
	elif event.is_action_pressed("sandbox_reset"):
		reset_projectile()
	elif event.is_action_pressed("combo_hit"):
		launch_projectile()


func _physics_process(delta: float) -> void:
	if not projectile_flying:
		return

	projectile_velocity.y += gravity * PIXELS_PER_METRE * delta
	projectile_position += projectile_velocity * delta
	trail.append(projectile_position)

	if projectile_position.y >= GROUND_Y:
		projectile_position.y = GROUND_Y
		projectile_flying = false
		update_readout("LANDED")
	elif projectile_position.x > get_viewport_rect().size.x + 30:
		projectile_flying = false
		update_readout("OUT OF RANGE")

	queue_redraw()


func _draw() -> void:
	# Laboratory grid
	for x in range(0, 1153, 50):
		draw_line(Vector2(x, 95), Vector2(x, GROUND_Y), Color("12213a"), 1.0)
	for y in range(140, 541, 50):
		draw_line(Vector2(0, y), Vector2(1152, y), Color("12213a"), 1.0)

	draw_rect(Rect2(0, GROUND_Y, 1152, 108), Color("101d31"))
	draw_line(Vector2(0, GROUND_Y), Vector2(1152, GROUND_Y), Color("62d9ff"), 2.0)

	# Predicted trajectory
	var initial_velocity := velocity_from_controls()
	for i in range(1, 45):
		var time := i * 0.12
		var predicted := ORIGIN + initial_velocity * time + Vector2(0, gravity * PIXELS_PER_METRE * time * time * 0.5)
		if predicted.y > GROUND_Y or predicted.x > 1152:
			break
		draw_circle(predicted, 2.2, Color(0.39, 0.85, 1.0, 0.42))

	# Cannon and launch direction
	var direction := Vector2.from_angle(deg_to_rad(-angle_degrees))
	draw_circle(ORIGIN, 22, Color("243b5e"))
	draw_line(ORIGIN, ORIGIN + direction * 54, Color("dbe9ff"), 12.0, true)
	draw_circle(ORIGIN, 11, Color("62d9ff"))

	if trail.size() > 1:
		draw_polyline(PackedVector2Array(trail), Color(1.0, 0.82, 0.4, 0.48), 2.0, true)
	draw_circle(projectile_position, 10, Color("ffd166"))
	draw_circle(projectile_position - Vector2(3, 3), 3, Color("fff4c7"))


func build_interface() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)

	var top_bar := ColorRect.new()
	top_bar.color = Color("0d1829")
	top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_bar.custom_minimum_size.y = 95
	canvas.add_child(top_bar)

	var header := HBoxContainer.new()
	header.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 18)
	header.add_theme_constant_override("separation", 18)
	top_bar.add_child(header)

	var back := Button.new()
	back.text = "← PHYSICS"
	back.focus_mode = Control.FOCUS_NONE
	back.custom_minimum_size.x = 145
	UIFactory.style_button(back, Color("62d9ff"))
	back.pressed.connect(Sandbox.open_category.bind("physics"))
	header.add_child(back)

	var heading := VBoxContainer.new()
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(heading)

	var title := Label.new()
	title.text = "PROJECTILE LABORATORY"
	title.add_theme_color_override("font_color", Color("f5f8ff"))
	title.add_theme_font_size_override("font_size", 27)
	heading.add_child(title)

	var hint := Label.new()
	hint.text = "D-pad/Stick: adjust focused slider   A/Cross: launch   X/Square: reset   B/Circle: back"
	hint.add_theme_color_override("font_color", Color("91a4c1"))
	heading.add_child(hint)

	var panel := PanelContainer.new()
	panel.position = Vector2(790, 120)
	panel.size = Vector2(330, 390)
	panel.add_theme_stylebox_override("panel", UIFactory.panel_style(Color(0.055, 0.098, 0.17, 0.96), Color("30425f"), 16))
	canvas.add_child(panel)

	var controls := VBoxContainer.new()
	controls.add_theme_constant_override("separation", 11)
	panel.add_child(controls)

	var control_title := Label.new()
	control_title.text = "LAUNCH PARAMETERS"
	control_title.add_theme_color_override("font_color", Color("62d9ff"))
	control_title.add_theme_font_size_override("font_size", 17)
	controls.add_child(control_title)

	var angle_control := create_slider("ANGLE", 10, 80, angle_degrees, "°", set_angle)
	controls.add_child(angle_control)
	controls.add_child(create_slider("SPEED", 10, 50, launch_speed, " m/s", set_speed))
	controls.add_child(create_slider("GRAVITY", 1, 20, gravity, " m/s²", set_gravity))
	var angle_slider: HSlider = angle_control.get_child(1)
	angle_slider.grab_focus.call_deferred()

	readout = Label.new()
	readout.text = "READY TO LAUNCH"
	readout.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	readout.add_theme_color_override("font_color", Color("ffd166"))
	readout.add_theme_font_size_override("font_size", 15)
	controls.add_child(readout)

	var launch := Button.new()
	launch.text = "LAUNCH"
	UIFactory.style_button(launch, Color("ffd166"))
	launch.pressed.connect(launch_projectile)
	controls.add_child(launch)

	var reset := Button.new()
	reset.text = "RESET"
	UIFactory.style_button(reset, Color("62d9ff"))
	reset.pressed.connect(reset_projectile)
	controls.add_child(reset)


func create_slider(label_text: String, minimum: float, maximum: float, value: float, suffix: String, callback: Callable) -> VBoxContainer:
	var group := VBoxContainer.new()
	var label := Label.new()
	label.text = "%s: %.1f%s" % [label_text, value, suffix]
	label.add_theme_color_override("font_color", Color("dbe7fa"))
	group.add_child(label)

	var slider := HSlider.new()
	slider.min_value = minimum
	slider.max_value = maximum
	slider.step = 0.5
	slider.value = value
	slider.custom_minimum_size.y = 24
	slider.value_changed.connect(func(new_value: float):
		label.text = "%s: %.1f%s" % [label_text, new_value, suffix]
		callback.call(new_value)
	)
	group.add_child(slider)
	return group


func velocity_from_controls() -> Vector2:
	var radians := deg_to_rad(angle_degrees)
	return Vector2(cos(radians), -sin(radians)) * launch_speed * PIXELS_PER_METRE


func launch_projectile() -> void:
	projectile_position = ORIGIN
	projectile_velocity = velocity_from_controls()
	projectile_flying = true
	trail.clear()
	trail.append(projectile_position)
	update_readout("IN FLIGHT")
	queue_redraw()


func reset_projectile() -> void:
	projectile_position = ORIGIN
	projectile_velocity = Vector2.ZERO
	projectile_flying = false
	trail.clear()
	update_readout("READY TO LAUNCH")
	queue_redraw()


func set_angle(value: float) -> void:
	angle_degrees = value
	reset_projectile()


func set_speed(value: float) -> void:
	launch_speed = value
	reset_projectile()


func set_gravity(value: float) -> void:
	gravity = value
	reset_projectile()


func update_readout(message: String) -> void:
	if readout:
		readout.text = message
