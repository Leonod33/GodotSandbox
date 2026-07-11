extends Node2D

const BAR_RECT := Rect2(160, 330, 832, 70)
const SWEET_WIDTH := 125.0

var cursor_ratio := 0.0
var cursor_direction := 1.0
var cursor_speed := 0.62
var sweet_centre := 0.5
var score := 0
var combo := 0
var best_combo := 0
var feedback := "PRESS A / CROSS IN THE TARGET ZONE"
var feedback_color := Color("9fb0ca")
var score_label: Label
var combo_label: Label
var best_label: Label
var feedback_label: Label


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("08101d"))
	build_interface()
	update_labels()
	queue_redraw()


func _process(delta: float) -> void:
	cursor_ratio += cursor_direction * cursor_speed * delta
	if cursor_ratio >= 1.0:
		cursor_ratio = 1.0
		cursor_direction = -1.0
	elif cursor_ratio <= 0.0:
		cursor_ratio = 0.0
		cursor_direction = 1.0
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("sandbox_back"):
		Sandbox.open_category("scoring")
	elif event.is_action_pressed("combo_hit"):
		attempt_hit()
	elif event.is_action_pressed("sandbox_reset"):
		reset_game()


func _draw() -> void:
	draw_style_box(UIFactory.panel_style(Color("101b2e"), Color("30425f"), 18), Rect2(120, 230, 912, 270))
	draw_rect(BAR_RECT, Color("17263f"))
	var target_x := BAR_RECT.position.x + BAR_RECT.size.x * sweet_centre - SWEET_WIDTH / 2.0
	draw_rect(Rect2(target_x, BAR_RECT.position.y, SWEET_WIDTH, BAR_RECT.size.y), Color(0.49, 0.91, 0.53, 0.34))
	draw_line(Vector2(target_x, BAR_RECT.position.y), Vector2(target_x, BAR_RECT.end.y), Color("7ee787"), 3.0)
	draw_line(Vector2(target_x + SWEET_WIDTH, BAR_RECT.position.y), Vector2(target_x + SWEET_WIDTH, BAR_RECT.end.y), Color("7ee787"), 3.0)
	var cursor_x := BAR_RECT.position.x + BAR_RECT.size.x * cursor_ratio
	draw_line(Vector2(cursor_x, BAR_RECT.position.y - 18), Vector2(cursor_x, BAR_RECT.end.y + 18), Color("ffd166"), 7.0, true)
	draw_circle(Vector2(cursor_x, BAR_RECT.position.y - 20), 10, Color("ffd166"))


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
	title.text = "COMBO LABORATORY"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("f5f8ff"))
	header.add_child(title)
	var subtitle := Label.new()
	subtitle.position = Vector2(35, 54)
	subtitle.text = "Hit: A/Cross or Space   Reset: X/Square or R   Back: B/Circle or Esc"
	subtitle.add_theme_color_override("font_color", Color("91a4c1"))
	header.add_child(subtitle)

	var stats := HBoxContainer.new()
	stats.position = Vector2(150, 130)
	stats.size = Vector2(852, 65)
	stats.alignment = BoxContainer.ALIGNMENT_CENTER
	stats.add_theme_constant_override("separation", 100)
	canvas.add_child(stats)
	score_label = create_stat_label()
	combo_label = create_stat_label()
	best_label = create_stat_label()
	stats.add_child(score_label)
	stats.add_child(combo_label)
	stats.add_child(best_label)

	feedback_label = Label.new()
	feedback_label.position = Vector2(150, 430)
	feedback_label.size = Vector2(852, 44)
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.add_theme_font_size_override("font_size", 22)
	canvas.add_child(feedback_label)

	var instructions := Label.new()
	instructions.position = Vector2(190, 535)
	instructions.size = Vector2(772, 65)
	instructions.text = "Every successful hit raises the combo and multiplier.\nThe cursor speeds up and the target relocates. One miss breaks the combo."
	instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instructions.add_theme_color_override("font_color", Color("8294b0"))
	instructions.add_theme_font_size_override("font_size", 17)
	canvas.add_child(instructions)


func create_stat_label() -> Label:
	var label := Label.new()
	label.custom_minimum_size.x = 180
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	return label


func attempt_hit() -> void:
	var target_half_ratio := (SWEET_WIDTH / BAR_RECT.size.x) / 2.0
	var distance := abs(cursor_ratio - sweet_centre)
	if distance <= target_half_ratio:
		combo += 1
		best_combo = max(best_combo, combo)
		var multiplier := 1 + int(combo / 3.0)
		var gained := 100 * multiplier
		score += gained
		feedback = "GOOD HIT!  +%d  (x%d MULTIPLIER)" % [gained, multiplier]
		feedback_color = Color("7ee787")
		cursor_speed = min(1.35, cursor_speed + 0.045)
		sweet_centre = randf_range(0.18, 0.82)
	else:
		feedback = "MISS — COMBO BROKEN AT %d" % combo
		feedback_color = Color("ff7b93")
		combo = 0
		cursor_speed = max(0.62, cursor_speed - 0.08)
	update_labels()


func reset_game() -> void:
	score = 0
	combo = 0
	best_combo = 0
	cursor_ratio = 0.0
	cursor_direction = 1.0
	cursor_speed = 0.62
	sweet_centre = 0.5
	feedback = "FRESH RUN — LINE IT UP!"
	feedback_color = Color("9fb0ca")
	update_labels()


func update_labels() -> void:
	score_label.text = "SCORE\n%d" % score
	combo_label.text = "COMBO\n%d" % combo
	best_label.text = "BEST\n%d" % best_combo
	for label in [score_label, combo_label, best_label]:
		label.add_theme_color_override("font_color", Color("f5f8ff"))
	feedback_label.text = feedback
	feedback_label.add_theme_color_override("font_color", feedback_color)

