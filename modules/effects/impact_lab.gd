extends Node2D

class Spark:
	var position: Vector2
	var velocity: Vector2
	var lifetime: float
	var maximum_lifetime: float
	var color: Color

	func _init(start: Vector2, movement: Vector2, duration: float, spark_color: Color) -> void:
		position = start
		velocity = movement
		lifetime = duration
		maximum_lifetime = duration
		color = spark_color


const TARGET_POSITION := Vector2(520, 345)
const TARGET_RADIUS := 82.0

var sparks: Array[Spark] = []
var intensity: int = 2
var shake_time: float = 0.0
var shake_strength: float = 0.0
var flash_alpha: float = 0.0
var target_scale: Vector2 = Vector2.ONE
var impact_count: int = 0
var intensity_label: Label
var count_label: Label
var feedback_label: Label


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("08101d"))
	build_interface()
	update_labels("READY — GIVE IT A WHACK")
	queue_redraw()


func _process(delta: float) -> void:
	shake_time = maxf(0.0, shake_time - delta)
	flash_alpha = maxf(0.0, flash_alpha - delta * 3.8)
	target_scale.x = lerpf(target_scale.x, 1.0, delta * 10.0)
	target_scale.y = lerpf(target_scale.y, 1.0, delta * 10.0)

	for index in range(sparks.size() - 1, -1, -1):
		var spark: Spark = sparks[index]
		spark.lifetime -= delta
		if spark.lifetime <= 0.0:
			sparks.remove_at(index)
			continue
		spark.velocity.y += 430.0 * delta
		spark.position += spark.velocity * delta
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("sandbox_back"):
		Sandbox.open_category("effects")
	elif event.is_action_pressed("combo_hit"):
		trigger_impact()
	elif event.is_action_pressed("sandbox_reset"):
		reset_lab()
	elif event.is_action_pressed("ui_left"):
		set_intensity(intensity - 1)
	elif event.is_action_pressed("ui_right"):
		set_intensity(intensity + 1)


func _draw() -> void:
	var shake_offset: Vector2 = Vector2.ZERO
	if shake_time > 0.0:
		shake_offset = Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))

	# Subtle test chamber grid.
	for x in range(40, 800, 40):
		draw_line(Vector2(x, 100), Vector2(x, 600), Color("12213a"), 1.0)
	for y in range(120, 601, 40):
		draw_line(Vector2(35, y), Vector2(800, y), Color("12213a"), 1.0)

	var centre: Vector2 = TARGET_POSITION + shake_offset
	draw_circle(centre + Vector2(12, 15), TARGET_RADIUS * 1.05, Color(0.0, 0.0, 0.0, 0.32))
	draw_set_transform(centre, 0.0, target_scale)
	draw_circle(Vector2.ZERO, TARGET_RADIUS, Color("243b5e"))
	draw_circle(Vector2.ZERO, TARGET_RADIUS - 10.0, Color("ff637d"))
	draw_circle(Vector2.ZERO, TARGET_RADIUS - 31.0, Color("ffd166"))
	draw_circle(Vector2.ZERO, TARGET_RADIUS - 54.0, Color("f5f8ff"))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	for spark in sparks:
		var alpha: float = clampf(spark.lifetime / spark.maximum_lifetime, 0.0, 1.0)
		var spark_color: Color = spark.color
		spark_color.a = alpha
		draw_line(spark.position, spark.position - spark.velocity.normalized() * 14.0, spark_color, 4.0, true)

	if flash_alpha > 0.0:
		draw_rect(Rect2(0, 92, 815, 556), Color(1.0, 0.92, 0.65, flash_alpha))


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
	title.text = "IMPACT EFFECTS LABORATORY"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("f5f8ff"))
	header.add_child(title)
	var subtitle := Label.new()
	subtitle.position = Vector2(35, 54)
	subtitle.text = "Impact: A/Cross or Space   Intensity: Left/Right   Reset: X/Square   Back: B/Circle"
	subtitle.add_theme_color_override("font_color", Color("91a4c1"))
	header.add_child(subtitle)

	var panel := PanelContainer.new()
	panel.position = Vector2(835, 125)
	panel.size = Vector2(285, 415)
	panel.add_theme_stylebox_override("panel", UIFactory.panel_style(Color(0.055, 0.098, 0.17, 0.96), Color("a78bfa"), 16))
	canvas.add_child(panel)
	var info := VBoxContainer.new()
	info.add_theme_constant_override("separation", 20)
	panel.add_child(info)
	var heading := Label.new()
	heading.text = "EFFECT MIXER"
	heading.add_theme_font_size_override("font_size", 19)
	heading.add_theme_color_override("font_color", Color("a78bfa"))
	info.add_child(heading)

	intensity_label = Label.new()
	intensity_label.add_theme_font_size_override("font_size", 22)
	intensity_label.add_theme_color_override("font_color", Color("ffd166"))
	info.add_child(intensity_label)
	var effects := Label.new()
	effects.text = "ACTIVE EFFECTS\n\n• Screen shake\n• Target squash\n• Impact flash\n• Radial sparks\n• Colour feedback"
	effects.add_theme_color_override("font_color", Color("dbe7fa"))
	effects.add_theme_font_size_override("font_size", 16)
	info.add_child(effects)
	count_label = Label.new()
	count_label.add_theme_color_override("font_color", Color("9fb0ca"))
	info.add_child(count_label)

	feedback_label = Label.new()
	feedback_label.position = Vector2(140, 545)
	feedback_label.size = Vector2(760, 45)
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.add_theme_font_size_override("font_size", 20)
	feedback_label.add_theme_color_override("font_color", Color("7ee787"))
	canvas.add_child(feedback_label)


func trigger_impact() -> void:
	impact_count += 1
	shake_time = 0.08 + intensity * 0.035
	shake_strength = 2.0 + intensity * 2.8
	flash_alpha = 0.05 + intensity * 0.035
	target_scale = Vector2(1.18 + intensity * 0.035, 0.82 - intensity * 0.025)

	var spark_count: int = 8 + intensity * 5
	for index in range(spark_count):
		var angle: float = TAU * float(index) / float(spark_count) + randf_range(-0.12, 0.12)
		var speed: float = randf_range(100.0, 180.0) + intensity * 35.0
		var velocity: Vector2 = Vector2.from_angle(angle) * speed
		var spark_color: Color = Color("ffd166") if index % 2 == 0 else Color("ff637d")
		sparks.append(Spark.new(TARGET_POSITION, velocity, randf_range(0.35, 0.65), spark_color))
	update_labels("IMPACT %d — %s" % [impact_count, intensity_name()])


func set_intensity(new_intensity: int) -> void:
	intensity = clampi(new_intensity, 1, 4)
	update_labels("INTENSITY SET TO %s" % intensity_name())


func intensity_name() -> String:
	var names: Array[String] = ["", "TAP", "THUMP", "SMASH", "CATASTROPHIC"]
	return names[intensity]


func reset_lab() -> void:
	sparks.clear()
	impact_count = 0
	shake_time = 0.0
	flash_alpha = 0.0
	target_scale = Vector2.ONE
	update_labels("LABORATORY RESET")


func update_labels(message: String) -> void:
	intensity_label.text = "◀  %d / 4 — %s  ▶" % [intensity, intensity_name()]
	count_label.text = "IMPACTS TESTED: %d" % impact_count
	feedback_label.text = message

