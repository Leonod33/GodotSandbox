extends Node2D

const SPEED := 260.0
const PLAYER_START := Vector2(135, 340)
const LAYER_COLORS := [Color("62d9ff"), Color("ff8cc8"), Color("ffd166")]

var player: CharacterBody2D
var layer_enabled := [true, true, true]
var status_label: Label
var layer_labels: Array[Label] = []


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("08101d"))
	create_arena()
	build_interface()
	update_layer_display()


func _physics_process(_delta: float) -> void:
	player.velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * SPEED
	player.move_and_slide()
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("sandbox_back"):
		Sandbox.open_category("physics")
	elif event.is_action_pressed("lab_layer_1"):
		toggle_layer(0)
	elif event.is_action_pressed("lab_layer_2"):
		toggle_layer(1)
	elif event.is_action_pressed("lab_layer_3"):
		toggle_layer(2)
	elif event.is_action_pressed("sandbox_reset"):
		reset_player()


func _draw() -> void:
	for x in range(40, 780, 40):
		draw_line(Vector2(x, 115), Vector2(x, 600), Color("12213a"), 1.0)
	for y in range(120, 601, 40):
		draw_line(Vector2(35, y), Vector2(780, y), Color("12213a"), 1.0)
	draw_rect(Rect2(35, 110, 745, 490), Color("30425f"), false, 2.0)


func create_arena() -> void:
	player = CharacterBody2D.new()
	player.name = "Player"
	player.position = PLAYER_START
	player.collision_layer = 1
	player.collision_mask = 2 | 4 | 8
	add_child(player)

	var player_shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 18
	player_shape.shape = circle
	player.add_child(player_shape)

	var player_visual := Polygon2D.new()
	player_visual.polygon = PackedVector2Array([Vector2(0, -20), Vector2(17, 12), Vector2(0, 7), Vector2(-17, 12)])
	player_visual.color = Color("f5f8ff")
	player.add_child(player_visual)

	create_boundary(Vector2(407, 100), Vector2(765, 20))
	create_boundary(Vector2(407, 610), Vector2(765, 20))
	create_boundary(Vector2(25, 355), Vector2(20, 530))
	create_boundary(Vector2(790, 355), Vector2(20, 530))

	create_obstacle(Vector2(300, 215), Vector2(42, 210), 0)
	create_obstacle(Vector2(500, 390), Vector2(42, 250), 1)
	create_obstacle(Vector2(665, 240), Vector2(42, 220), 2)


func create_obstacle(pos: Vector2, obstacle_size: Vector2, layer_index: int) -> void:
	var body := StaticBody2D.new()
	body.position = pos
	body.collision_layer = 1 << (layer_index + 1)
	body.collision_mask = 1
	add_child(body)

	var shape_node := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = obstacle_size
	shape_node.shape = shape
	body.add_child(shape_node)

	var visual := Polygon2D.new()
	var half := obstacle_size / 2.0
	visual.polygon = PackedVector2Array([Vector2(-half.x, -half.y), Vector2(half.x, -half.y), Vector2(half.x, half.y), Vector2(-half.x, half.y)])
	visual.color = LAYER_COLORS[layer_index]
	visual.color.a = 0.78
	body.add_child(visual)


func create_boundary(pos: Vector2, boundary_size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.position = pos
	body.collision_layer = 16
	body.collision_mask = 1
	add_child(body)
	player.collision_mask |= 16
	var shape_node := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = boundary_size
	shape_node.shape = shape
	body.add_child(shape_node)


func build_interface() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)
	var header := ColorRect.new()
	header.color = Color("0d1829")
	header.set_anchors_preset(Control.PRESET_TOP_WIDE)
	header.custom_minimum_size.y = 90
	canvas.add_child(header)

	var title := Label.new()
	title.position = Vector2(32, 17)
	title.text = "COLLISION LAYERS LABORATORY"
	title.add_theme_font_size_override("font_size", 27)
	title.add_theme_color_override("font_color", Color("f5f8ff"))
	header.add_child(title)
	var subtitle := Label.new()
	subtitle.position = Vector2(33, 53)
	subtitle.text = "Move: D-pad/Stick   Toggle: X/Square, Y/Triangle, LB/L1   Reset: R   Back: B/Circle"
	subtitle.add_theme_color_override("font_color", Color("91a4c1"))
	header.add_child(subtitle)

	var panel := PanelContainer.new()
	panel.position = Vector2(820, 120)
	panel.size = Vector2(300, 420)
	panel.add_theme_stylebox_override("panel", UIFactory.panel_style(Color(0.055, 0.098, 0.17, 0.96)))
	canvas.add_child(panel)
	var info := VBoxContainer.new()
	info.add_theme_constant_override("separation", 16)
	panel.add_child(info)
	var info_title := Label.new()
	info_title.text = "PLAYER COLLISION MASK"
	info_title.add_theme_color_override("font_color", Color("f5f8ff"))
	info_title.add_theme_font_size_override("font_size", 18)
	info.add_child(info_title)

	for i in range(3):
		var label := Label.new()
		label.add_theme_font_size_override("font_size", 17)
		label.add_theme_color_override("font_color", LAYER_COLORS[i])
		layer_labels.append(label)
		info.add_child(label)

	var explanation := Label.new()
	explanation.text = "Enabled layers block the player.\nDisabled layers are ignored, allowing the player to pass straight through matching walls."
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	explanation.add_theme_color_override("font_color", Color("9fb0ca"))
	info.add_child(explanation)
	status_label = Label.new()
	status_label.text = "Try crossing each coloured wall."
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_color_override("font_color", Color("ffd166"))
	info.add_child(status_label)


func toggle_layer(index: int) -> void:
	layer_enabled[index] = not layer_enabled[index]
	var layer_bit := 1 << (index + 1)
	if layer_enabled[index]:
		player.collision_mask |= layer_bit
	else:
		player.collision_mask &= ~layer_bit
	update_layer_display()


func update_layer_display() -> void:
	var names := ["CYAN — X / Square / 1", "PINK — Y / Triangle / 2", "GOLD — LB / L1 / 3"]
	for i in range(3):
		layer_labels[i].text = "●  %s: %s" % [names[i], "BLOCKING" if layer_enabled[i] else "IGNORED"]
	status_label.text = "Collision mask changed. Test the walls!"


func reset_player() -> void:
	player.position = PLAYER_START
	player.velocity = Vector2.ZERO
	status_label.text = "Player returned to the starting point."
