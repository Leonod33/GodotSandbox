extends Node2D

const CENTRE := Vector2(440, 350)

var phase: float = 0.0
var rotation_speed: float = 1.0
var symmetry: int = 8
var palette_index: int = 0
var trails_enabled: bool = true
var burst_energy: float = 0.0
var pulse_phase: float = 0.0
var palette_label: Label
var symmetry_label: Label
var speed_label: Label
var trails_label: Label
var message_label: Label

var palettes: Array[PackedColorArray] = [
	PackedColorArray([Color("62d9ff"), Color("ff8cc8"), Color("ffd166"), Color("a78bfa")]),
	PackedColorArray([Color("7ee787"), Color("38bdf8"), Color("f5f8ff"), Color("14b8a6")]),
	PackedColorArray([Color("ff637d"), Color("ff9f43"), Color("ffe66d"), Color("ff4ecd")]),
	PackedColorArray([Color("c084fc"), Color("818cf8"), Color("22d3ee"), Color("f0abfc")])
]
var palette_names: Array[String] = ["ARCADE SUNSET", "DEEP OCEAN", "SOLAR FLARE", "COSMIC DREAM"]


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("050914"))
	build_interface()
	update_labels("LIGHT MACHINE ONLINE")
	queue_redraw()


func _process(delta: float) -> void:
	phase += delta * rotation_speed
	pulse_phase += delta * 2.2
	burst_energy = maxf(0.0, burst_energy - delta * 0.8)
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("sandbox_back"):
		Sandbox.open_category("effects")
	elif event.is_action_pressed("combo_hit"):
		trigger_burst()
	elif event.is_action_pressed("sandbox_reset"):
		cycle_palette()
	elif event.is_action_pressed("lab_layer_2"):
		trails_enabled = not trails_enabled
		update_labels("GHOST TRAILS %s" % ("ENABLED" if trails_enabled else "DISABLED"))
	elif event.is_action_pressed("ui_left"):
		set_symmetry(symmetry - 1)
	elif event.is_action_pressed("ui_right"):
		set_symmetry(symmetry + 1)
	elif event.is_action_pressed("ui_up"):
		set_speed(rotation_speed + 0.25)
	elif event.is_action_pressed("ui_down"):
		set_speed(rotation_speed - 0.25)


func _draw() -> void:
	# A dark chamber and a soft breathing glow behind the mechanism.
	draw_rect(Rect2(0, 92, 805, 556), Color("060b18"))
	var glow_color: Color = palettes[palette_index][0]
	glow_color.a = 0.045 + sin(pulse_phase) * 0.012 + burst_energy * 0.05
	draw_circle(CENTRE, 250.0 + burst_energy * 55.0, glow_color)

	for ring_index in range(3):
		var radius: float = 95.0 + ring_index * 65.0
		var ring_color: Color = palettes[palette_index][2]
		ring_color.a = 0.07
		draw_circle(CENTRE, radius, ring_color, false, 1.5)

	if trails_enabled:
		draw_pattern(phase - 0.22, 0.09, 0.94)
		draw_pattern(phase - 0.13, 0.15, 0.97)
		draw_pattern(phase - 0.065, 0.23, 0.985)
	draw_pattern(phase, 0.9, 1.0 + burst_energy * 0.18)

	if burst_energy > 0.0:
		var burst_color: Color = palettes[palette_index][1]
		burst_color.a = burst_energy * 0.65
		var burst_radius: float = 90.0 + (1.0 - burst_energy) * 260.0
		draw_circle(CENTRE, burst_radius, burst_color, false, 7.0 * burst_energy + 1.0)


func draw_pattern(pattern_phase: float, alpha: float, size_multiplier: float) -> void:
	var palette: PackedColorArray = palettes[palette_index]
	var breathing: float = 1.0 + sin(pulse_phase) * 0.055
	for arm in range(symmetry):
		var base_angle: float = pattern_phase + TAU * float(arm) / float(symmetry)
		var wobble: float = sin(pattern_phase * 1.7 + arm * 0.8) * 0.22
		var direction_a: Vector2 = Vector2.from_angle(base_angle)
		var direction_b: Vector2 = Vector2.from_angle(base_angle + 0.42 + wobble)
		var direction_c: Vector2 = Vector2.from_angle(base_angle - 0.28 - wobble * 0.5)
		var point_a: Vector2 = CENTRE + direction_a * 78.0 * breathing * size_multiplier
		var point_b: Vector2 = CENTRE + direction_b * 155.0 * breathing * size_multiplier
		var point_c: Vector2 = CENTRE + direction_c * 226.0 * breathing * size_multiplier
		var colour_a: Color = palette[arm % palette.size()]
		var colour_b: Color = palette[(arm + 1) % palette.size()]
		colour_a.a = alpha
		colour_b.a = alpha * 0.82
		draw_line(CENTRE, point_a, colour_a, 3.0, true)
		draw_line(point_a, point_b, colour_b, 5.0, true)
		draw_line(point_b, point_c, colour_a, 2.5, true)
		draw_colored_polygon(PackedVector2Array([point_a, point_b, point_c]), Color(colour_b, alpha * 0.16))
		draw_circle(point_a, 7.0, colour_a)
		draw_circle(point_b, 5.0, colour_b)
		draw_circle(point_c, 3.5, colour_a)

	var core_color: Color = palette[0]
	core_color.a = alpha
	draw_circle(CENTRE, 24.0 * size_multiplier, core_color)
	draw_circle(CENTRE, 10.0 * size_multiplier, Color("f5f8ff"))


func build_interface() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)
	var header := ColorRect.new()
	header.color = Color("0d1829")
	header.set_anchors_preset(Control.PRESET_TOP_WIDE)
	header.custom_minimum_size.y = 92
	canvas.add_child(header)
	var title := Label.new()
	title.position = Vector2(34, 16)
	title.text = "NEON KALEIDOSCOPE LABORATORY"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("f5f8ff"))
	header.add_child(title)
	var subtitle := Label.new()
	subtitle.position = Vector2(35, 54)
	subtitle.text = "Symmetry: Left/Right   Speed: Up/Down   Burst: A/Cross   Palette: X/Square   Trails: Y/Triangle"
	subtitle.add_theme_color_override("font_color", Color("91a4c1"))
	header.add_child(subtitle)

	var panel := PanelContainer.new()
	panel.position = Vector2(825, 125)
	panel.size = Vector2(295, 420)
	panel.add_theme_stylebox_override("panel", UIFactory.panel_style(Color(0.035, 0.06, 0.12, 0.97), Color("a78bfa"), 16))
	canvas.add_child(panel)
	var info := VBoxContainer.new()
	info.add_theme_constant_override("separation", 19)
	panel.add_child(info)
	var heading := Label.new()
	heading.text = "LIGHT MACHINE CONTROLS"
	heading.add_theme_font_size_override("font_size", 18)
	heading.add_theme_color_override("font_color", Color("f0abfc"))
	info.add_child(heading)
	symmetry_label = create_readout()
	speed_label = create_readout()
	palette_label = create_readout()
	trails_label = create_readout()
	info.add_child(symmetry_label)
	info.add_child(speed_label)
	info.add_child(palette_label)
	info.add_child(trails_label)
	var explanation := Label.new()
	explanation.text = "Every shape is drawn procedurally. Change the rotational symmetry, colour family, motion speed and layered ghost images in real time."
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	explanation.add_theme_color_override("font_color", Color("b7c5db"))
	info.add_child(explanation)

	message_label = Label.new()
	message_label.position = Vector2(125, 595)
	message_label.size = Vector2(640, 35)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 18)
	message_label.add_theme_color_override("font_color", Color("ffd166"))
	canvas.add_child(message_label)


func create_readout() -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_color_override("font_color", Color("eaf2ff"))
	return label


func trigger_burst() -> void:
	burst_energy = 1.0
	update_labels("KALEIDOSCOPIC PULSE RELEASED!")


func cycle_palette() -> void:
	palette_index = (palette_index + 1) % palettes.size()
	update_labels("PALETTE: %s" % palette_names[palette_index])


func set_symmetry(new_value: int) -> void:
	symmetry = clampi(new_value, 3, 16)
	update_labels("SYMMETRY SET TO %d ARMS" % symmetry)


func set_speed(new_value: float) -> void:
	rotation_speed = clampf(new_value, -2.0, 2.0)
	if is_zero_approx(rotation_speed):
		rotation_speed = 0.0
	update_labels("ROTATION SPEED: %.2f" % rotation_speed)


func update_labels(message: String) -> void:
	symmetry_label.text = "SYMMETRY ARMS:  ◀  %d  ▶" % symmetry
	speed_label.text = "ROTATION SPEED:  %.2fx" % rotation_speed
	palette_label.text = "PALETTE:  %s" % palette_names[palette_index]
	trails_label.text = "GHOST TRAILS:  %s" % ("ON" if trails_enabled else "OFF")
	message_label.text = message
