extends Node2D

const PLAYER_START := Vector2(145, 350)
const BASE_POSITION := Vector2(105, 350)
const BASE_RADIUS := 62.0
const PLAYER_SPEED := 220.0
const SPRINT_MULTIPLIER := 1.65
const CAPACITY := 3
const ROUND_LENGTH := 60.0

var player_position: Vector2 = PLAYER_START
var items: Array[Vector2] = []
var carrying: int = 0
var score: int = 0
var deposited: int = 0
var time_remaining: float = ROUND_LENGTH
var game_over: bool = false
var score_label: Label
var carry_label: Label
var timer_label: Label
var message_label: Label


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("08101d"))
	build_interface()
	spawn_items(10)
	update_hud("COLLECT THE GREEN CRYSTALS")
	queue_redraw()


func _process(delta: float) -> void:
	if game_over:
		return

	time_remaining = maxf(0.0, time_remaining - delta)
	if time_remaining <= 0.0:
		game_over = true
		update_hud("TIME! FINAL SCORE: %d" % score)
		queue_redraw()
		return

	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var speed: float = PLAYER_SPEED * (SPRINT_MULTIPLIER if Input.is_action_pressed("combo_hit") else 1.0)
	player_position += direction * speed * delta
	player_position.x = clampf(player_position.x, 48.0, 775.0)
	player_position.y = clampf(player_position.y, 125.0, 595.0)
	check_collection()
	check_deposit()
	update_hud_values()
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("sandbox_back"):
		Sandbox.open_category("gameplay")
	elif event.is_action_pressed("sandbox_reset"):
		reset_round()


func _draw() -> void:
	for x in range(40, 800, 40):
		draw_line(Vector2(x, 105), Vector2(x, 610), Color("12213a"), 1.0)
	for y in range(120, 611, 40):
		draw_line(Vector2(35, y), Vector2(800, y), Color("12213a"), 1.0)

	draw_circle(BASE_POSITION, BASE_RADIUS, Color(0.39, 0.85, 1.0, 0.15))
	draw_circle(BASE_POSITION, BASE_RADIUS, Color("62d9ff"), false, 4.0)
	draw_string(ThemeDB.fallback_font, BASE_POSITION + Vector2(-28, 5), "BASE", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("eaf2ff"))

	for item in items:
		draw_circle(item, 12, Color("7ee787"))
		draw_circle(item - Vector2(3, 4), 4, Color("d8ffe0"))

	var player_color: Color = Color("ff7b93") if carrying >= CAPACITY else Color("ffd166")
	draw_circle(player_position, 19, player_color)
	draw_circle(player_position, 9, Color("17263f"))
	for index in range(carrying):
		draw_circle(player_position + Vector2(-13 + index * 13, -29), 6, Color("7ee787"))


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
	title.text = "COLLECT AND RETURN"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("f5f8ff"))
	header.add_child(title)
	var subtitle := Label.new()
	subtitle.position = Vector2(35, 54)
	subtitle.text = "Move: D-pad/Stick   Sprint: Hold A/Cross   Reset: X/Square   Back: B/Circle"
	subtitle.add_theme_color_override("font_color", Color("91a4c1"))
	header.add_child(subtitle)

	var panel := PanelContainer.new()
	panel.position = Vector2(825, 125)
	panel.size = Vector2(295, 410)
	panel.add_theme_stylebox_override("panel", UIFactory.panel_style(Color(0.055, 0.098, 0.17, 0.96), Color("7ee787"), 16))
	canvas.add_child(panel)
	var info := VBoxContainer.new()
	info.add_theme_constant_override("separation", 18)
	panel.add_child(info)
	var heading := Label.new()
	heading.text = "ROUND STATUS"
	heading.add_theme_font_size_override("font_size", 19)
	heading.add_theme_color_override("font_color", Color("7ee787"))
	info.add_child(heading)
	timer_label = create_stat_label()
	score_label = create_stat_label()
	carry_label = create_stat_label()
	info.add_child(timer_label)
	info.add_child(score_label)
	info.add_child(carry_label)
	var explanation := Label.new()
	explanation.text = "Crystals are collected automatically. Carry up to three, then return to the blue base to bank them.\n\nA full load earns a 100-point efficiency bonus."
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	explanation.add_theme_color_override("font_color", Color("dbe7fa"))
	info.add_child(explanation)

	message_label = Label.new()
	message_label.position = Vector2(120, 605)
	message_label.size = Vector2(720, 34)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 18)
	message_label.add_theme_color_override("font_color", Color("ffd166"))
	canvas.add_child(message_label)


func create_stat_label() -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color("f5f8ff"))
	return label


func check_collection() -> void:
	if carrying >= CAPACITY:
		return
	for index in range(items.size() - 1, -1, -1):
		if player_position.distance_to(items[index]) <= 30.0:
			items.remove_at(index)
			carrying += 1
			update_hud("CRYSTAL COLLECTED — %d / %d" % [carrying, CAPACITY])
			if carrying >= CAPACITY:
				update_hud("FULL LOAD! RETURN TO BASE FOR A BONUS")
			break


func check_deposit() -> void:
	if carrying == 0 or player_position.distance_to(BASE_POSITION) > BASE_RADIUS:
		return
	var banked_now: int = carrying
	var bonus: int = 100 if carrying == CAPACITY else 0
	score += carrying * 100 + bonus
	deposited += carrying
	carrying = 0
	spawn_items(banked_now)
	update_hud("BANKED %d CRYSTALS%s" % [banked_now, " + FULL-LOAD BONUS!" if bonus > 0 else ""])


func spawn_items(amount: int) -> void:
	for _index in range(amount):
		var candidate: Vector2 = Vector2.ZERO
		for _attempt in range(30):
			candidate = Vector2(randf_range(245.0, 760.0), randf_range(135.0, 575.0))
			if candidate.distance_to(BASE_POSITION) > 180.0:
				break
		items.append(candidate)


func reset_round() -> void:
	player_position = PLAYER_START
	items.clear()
	carrying = 0
	score = 0
	deposited = 0
	time_remaining = ROUND_LENGTH
	game_over = false
	spawn_items(10)
	update_hud("NEW ROUND — GET GATHERING!")
	queue_redraw()


func update_hud(message: String) -> void:
	message_label.text = message
	update_hud_values()


func update_hud_values() -> void:
	timer_label.text = "TIME: %02d" % ceili(time_remaining)
	score_label.text = "SCORE: %d" % score
	carry_label.text = "CARRYING: %d / %d" % [carrying, CAPACITY]

