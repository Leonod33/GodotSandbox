extends Node2D

@onready var ken: KenFighter = $Ken

var state_label: Label
var position_label: Label


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("07111d"))
	build_interface()
	queue_redraw()


func _process(_delta: float) -> void:
	if state_label and ken:
		state_label.text = "STATE: %s" % String(ken.state).to_upper()
		position_label.text = "POSITION: %03d    FACING: %s" % [int(ken.position.x), "RIGHT" if ken.facing > 0.0 else "LEFT"]


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fighter_exit"):
		Sandbox.open_category("fighting")
	elif event.is_action_pressed("fighter_reset"):
		ken.reset_fighter()


func _draw() -> void:
	# A deliberately simple training stage so locomotion remains easy to judge.
	draw_rect(Rect2(0, 92, 820, 556), Color("081a29"))
	for x in range(40, 821, 52):
		draw_line(Vector2(x, 110), Vector2(x, 535), Color(0.1, 0.25, 0.34, 0.42), 1.0)
	for y in range(119, 536, 52):
		draw_line(Vector2(0, y), Vector2(820, y), Color(0.1, 0.25, 0.34, 0.42), 1.0)

	draw_rect(Rect2(0, 535, 820, 113), Color("142637"))
	draw_line(Vector2(0, 535), Vector2(820, 535), Color("ffd166"), 4.0)
	for x in range(0, 850, 80):
		draw_line(Vector2(x, 535), Vector2(x - 35, 648), Color(0.2, 0.3, 0.39, 0.45), 2.0)
	var centre_line := Color(1.0, 0.42, 0.34, 0.38)
	draw_line(Vector2(410, 110), Vector2(410, 535), centre_line, 2.0)


func build_interface() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)
	var header := ColorRect.new()
	header.color = Color("0d1829")
	header.set_anchors_preset(Control.PRESET_TOP_WIDE)
	header.custom_minimum_size.y = 92
	canvas.add_child(header)
	var title := Label.new()
	title.position = Vector2(34, 15)
	title.text = "KEN TRAINING GROUND — LOCOMOTION BUILD"
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color("f5f8ff"))
	header.add_child(title)
	var subtitle := Label.new()
	subtitle.position = Vector2(35, 53)
	subtitle.text = "Move: Left/Right   Jump: Up   Crouch: Hold Down   Reset: Back/Select   Exit: Start/Menu or Esc"
	subtitle.add_theme_color_override("font_color", Color("91a4c1"))
	header.add_child(subtitle)

	var panel := PanelContainer.new()
	panel.position = Vector2(845, 120)
	panel.size = Vector2(275, 430)
	panel.add_theme_stylebox_override("panel", UIFactory.panel_style(Color(0.045, 0.08, 0.14, 0.97), Color("ff6b57"), 16))
	canvas.add_child(panel)
	var info := VBoxContainer.new()
	info.add_theme_constant_override("separation", 17)
	panel.add_child(info)
	var heading := Label.new()
	heading.text = "PHASE 1 DIAGNOSTICS"
	heading.add_theme_font_size_override("font_size", 18)
	heading.add_theme_color_override("font_color", Color("ff8a70"))
	info.add_child(heading)
	state_label = create_readout()
	position_label = create_readout()
	info.add_child(state_label)
	info.add_child(position_label)

	var implemented := Label.new()
	implemented.text = "IMPLEMENTED\n✓ Six-frame idle\n✓ Six-frame walk\n✓ Facing and boundaries\n✓ Vertical jump arc\n✓ Standing crouch\n✓ Nearest-neighbour pixels"
	implemented.add_theme_color_override("font_color", Color("dbe7fa"))
	implemented.add_theme_font_size_override("font_size", 15)
	info.add_child(implemented)
	var next_label := Label.new()
	next_label.text = "ATTACK BUTTONS ARE RESERVED\nPunches, kicks, hitboxes and the training dummy come in later builds."
	next_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	next_label.add_theme_color_override("font_color", Color("ffd166"))
	info.add_child(next_label)


func create_readout() -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color("f5f8ff"))
	return label
