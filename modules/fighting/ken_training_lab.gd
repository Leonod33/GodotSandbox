extends Node2D

const STAGE_WIDTH := 1152.0
const FLOOR_Y := 535.0
const DUMMY_X := 576.0

@onready var ken: KenFighter = $Ken
@onready var training_dummy: TrainingDummy = $TrainingDummy

var help_overlay: Control
var state_label: Label
var position_label: Label
var distance_label: Label


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("07111d"))
	ken.set_opponent(training_dummy)
	training_dummy.set_opponent(ken)
	build_interface()
	queue_redraw()


func _process(_delta: float) -> void:
	if state_label and ken:
		state_label.text = "STATE: %s" % String(ken.state).to_upper()
		position_label.text = "KEN X: %04d    FACING: %s" % [
			int(ken.position.x), "RIGHT" if ken.facing > 0.0 else "LEFT"
		]
		distance_label.text = "DUMMY X: %04d    DISTANCE: %03d" % [
			int(training_dummy.position.x), int(absf(training_dummy.position.x - ken.position.x))
		]


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fighter_exit"):
		Sandbox.open_category("fighting")
	elif event.is_action_pressed("fighter_help"):
		help_overlay.visible = not help_overlay.visible
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("fighter_reset"):
		ken.reset_fighter()


func _draw() -> void:
	# Full-width stage: the former diagnostics column is now fighting space.
	draw_rect(Rect2(0, 92, STAGE_WIDTH, 556), Color("081a29"))
	for x in range(40, int(STAGE_WIDTH) + 1, 52):
		draw_line(Vector2(x, 110), Vector2(x, FLOOR_Y), Color(0.1, 0.25, 0.34, 0.42), 1.0)
	for y in range(119, int(FLOOR_Y) + 1, 52):
		draw_line(Vector2(0, y), Vector2(STAGE_WIDTH, y), Color(0.1, 0.25, 0.34, 0.42), 1.0)

	draw_rect(Rect2(0, FLOOR_Y, STAGE_WIDTH, 113), Color("142637"))
	draw_line(Vector2(0, FLOOR_Y), Vector2(STAGE_WIDTH, FLOOR_Y), Color("ffd166"), 4.0)
	for x in range(0, int(STAGE_WIDTH) + 80, 80):
		draw_line(Vector2(x, FLOOR_Y), Vector2(x - 35, 648), Color(0.2, 0.3, 0.39, 0.45), 2.0)

	var centre_line := Color(0.35, 0.62, 1.0, 0.34)
	draw_line(Vector2(DUMMY_X, 110), Vector2(DUMMY_X, FLOOR_Y), centre_line, 2.0)
	draw_line(Vector2(DUMMY_X - 42, FLOOR_Y + 12), Vector2(DUMMY_X + 42, FLOOR_Y + 12), centre_line, 3.0)


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
	title.text = "KEN TRAINING GROUND — DUMMY BUILD"
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color("f5f8ff"))
	header.add_child(title)

	var subtitle := Label.new()
	subtitle.position = Vector2(35, 53)
	subtitle.text = "Move: Left/Right   Jump: Up   Crouch: Down   Help: Select/View   Reset: L3 or R   Exit: Start/Menu"
	subtitle.add_theme_color_override("font_color", Color("91a4c1"))
	header.add_child(subtitle)

	var dummy_label := Label.new()
	dummy_label.position = Vector2(DUMMY_X - 56, 267)
	dummy_label.size = Vector2(112, 28)
	dummy_label.text = "TRAINING DUMMY"
	dummy_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dummy_label.add_theme_font_size_override("font_size", 13)
	dummy_label.add_theme_color_override("font_color", Color("79aaff"))
	canvas.add_child(dummy_label)

	help_overlay = Control.new()
	help_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	help_overlay.visible = false
	canvas.add_child(help_overlay)

	var dimmer := ColorRect.new()
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.015, 0.03, 0.06, 0.62)
	help_overlay.add_child(dimmer)

	var panel := PanelContainer.new()
	panel.position = Vector2(336, 112)
	panel.size = Vector2(480, 458)
	panel.add_theme_stylebox_override("panel", UIFactory.panel_style(Color(0.045, 0.08, 0.14, 0.98), Color("79aaff"), 18))
	help_overlay.add_child(panel)

	var info := VBoxContainer.new()
	info.add_theme_constant_override("separation", 14)
	panel.add_child(info)

	var heading := Label.new()
	heading.text = "TRAINING GROUND HELP"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 21)
	heading.add_theme_color_override("font_color", Color("79aaff"))
	info.add_child(heading)

	state_label = create_readout()
	position_label = create_readout()
	distance_label = create_readout()
	info.add_child(state_label)
	info.add_child(position_label)
	info.add_child(distance_label)

	var implemented := Label.new()
	implemented.text = "CURRENT BUILD\n✓ Full-width fighting stage\n✓ Centre training dummy\n✓ Ground pushboxes\n✓ Jump-over crossover\n✓ Both fighters turn to face each other\n✓ Standing punches and kicks"
	implemented.add_theme_color_override("font_color", Color("dbe7fa"))
	implemented.add_theme_font_size_override("font_size", 15)
	info.add_child(implemented)

	var controls := Label.new()
	controls.text = "PUNCHES   X / Y / RB     Close-heavy preview: LB\nKICKS       A / B / RT\n\nPress Select/View again to close this panel."
	controls.add_theme_color_override("font_color", Color("ffd166"))
	controls.add_theme_font_size_override("font_size", 14)
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.add_child(controls)


func create_readout() -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color("f5f8ff"))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label
