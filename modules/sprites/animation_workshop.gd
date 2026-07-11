extends Node2D

@onready var sprite: AnimatedSprite2D = $Sprite

var animation_player: AnimationPlayer
var playback_speed: float = 1.0
var playing: bool = true
var speed_label: Label
var state_label: Label
var frame_label: Label


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("08101d"))
	create_motion_animation()
	build_interface()
	update_labels("BOTH ANIMATION SYSTEMS RUNNING")


func _process(_delta: float) -> void:
	if playing:
		frame_label.text = "CURRENT FRAME: %d / 4" % (sprite.frame + 1)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("sandbox_back"):
		Sandbox.open_category("sprites")
	elif event.is_action_pressed("combo_hit"):
		toggle_playback()
	elif event.is_action_pressed("sandbox_reset"):
		sprite.flip_h = not sprite.flip_h
		update_labels("SPRITE FLIPPED HORIZONTALLY")
	elif event.is_action_pressed("ui_left"):
		change_speed(-0.25)
	elif event.is_action_pressed("ui_right"):
		change_speed(0.25)
	elif event.is_action_pressed("lab_layer_2"):
		step_frame()


func create_motion_animation() -> void:
	animation_player = AnimationPlayer.new()
	animation_player.name = "MotionPlayer"
	add_child(animation_player)

	var motion: Animation = Animation.new()
	motion.length = 1.2
	motion.loop_mode = Animation.LOOP_LINEAR
	var position_track: int = motion.add_track(Animation.TYPE_VALUE)
	motion.track_set_path(position_track, NodePath("Sprite:position"))
	motion.track_insert_key(position_track, 0.0, Vector2(440, 345))
	motion.track_insert_key(position_track, 0.3, Vector2(440, 326))
	motion.track_insert_key(position_track, 0.6, Vector2(440, 345))
	motion.track_insert_key(position_track, 0.9, Vector2(440, 326))
	motion.track_insert_key(position_track, 1.2, Vector2(440, 345))

	var rotation_track: int = motion.add_track(Animation.TYPE_VALUE)
	motion.track_set_path(rotation_track, NodePath("Sprite:rotation"))
	motion.track_insert_key(rotation_track, 0.0, -0.035)
	motion.track_insert_key(rotation_track, 0.3, 0.035)
	motion.track_insert_key(rotation_track, 0.6, -0.035)
	motion.track_insert_key(rotation_track, 0.9, 0.035)
	motion.track_insert_key(rotation_track, 1.2, -0.035)

	var library: AnimationLibrary = AnimationLibrary.new()
	library.add_animation("bob", motion)
	animation_player.add_animation_library("", library)
	animation_player.play("bob")


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
	title.text = "ANIMATION WORKSHOP"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("f5f8ff"))
	header.add_child(title)
	var subtitle := Label.new()
	subtitle.position = Vector2(35, 54)
	subtitle.text = "Play/Pause: A/Cross   Speed: Left/Right   Flip: X/Square   Step: Y/Triangle   Back: B/Circle"
	subtitle.add_theme_color_override("font_color", Color("91a4c1"))
	header.add_child(subtitle)

	var floor_line := ColorRect.new()
	floor_line.position = Vector2(110, 500)
	floor_line.size = Vector2(650, 3)
	floor_line.color = Color("30425f")
	canvas.add_child(floor_line)

	var panel := PanelContainer.new()
	panel.position = Vector2(820, 125)
	panel.size = Vector2(300, 420)
	panel.add_theme_stylebox_override("panel", UIFactory.panel_style(Color(0.055, 0.098, 0.17, 0.96), Color("ff8cc8"), 16))
	canvas.add_child(panel)
	var info := VBoxContainer.new()
	info.add_theme_constant_override("separation", 18)
	panel.add_child(info)
	var heading := Label.new()
	heading.text = "TWO LAYERS, ONE RESULT"
	heading.add_theme_font_size_override("font_size", 18)
	heading.add_theme_color_override("font_color", Color("ff8cc8"))
	info.add_child(heading)
	var explanation := Label.new()
	explanation.text = "AnimatedSprite2D\nCycles the four drawn robot frames.\n\nAnimationPlayer\nAdds the smooth bob and rotation independently."
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	explanation.add_theme_color_override("font_color", Color("dbe7fa"))
	info.add_child(explanation)
	speed_label = Label.new()
	speed_label.add_theme_font_size_override("font_size", 19)
	speed_label.add_theme_color_override("font_color", Color("ffd166"))
	info.add_child(speed_label)
	frame_label = Label.new()
	frame_label.add_theme_color_override("font_color", Color("9fb0ca"))
	info.add_child(frame_label)
	state_label = Label.new()
	state_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	state_label.add_theme_color_override("font_color", Color("7ee787"))
	info.add_child(state_label)


func toggle_playback() -> void:
	playing = not playing
	if playing:
		sprite.play("walk")
		animation_player.play("bob")
		update_labels("PLAYBACK RESUMED")
	else:
		sprite.pause()
		animation_player.pause()
		update_labels("PAUSED — TRY FRAME STEP")


func change_speed(amount: float) -> void:
	playback_speed = clampf(playback_speed + amount, 0.25, 2.0)
	sprite.speed_scale = playback_speed
	animation_player.speed_scale = playback_speed
	update_labels("BOTH PLAYERS SET TO %.2fx" % playback_speed)


func step_frame() -> void:
	if playing:
		playing = false
		sprite.pause()
		animation_player.pause()
	var frame_count: int = sprite.sprite_frames.get_frame_count("walk")
	sprite.frame = (sprite.frame + 1) % frame_count
	animation_player.advance(0.08)
	update_labels("ADVANCED ONE SPRITE FRAME")


func update_labels(message: String) -> void:
	speed_label.text = "PLAYBACK SPEED: %.2fx" % playback_speed
	frame_label.text = "CURRENT FRAME: %d / 4" % (sprite.frame + 1)
	state_label.text = message
