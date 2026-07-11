extends Node

const MAIN_MENU := "res://main/main_menu.tscn"
const CATEGORY_MENU := "res://main/category_menu.tscn"

var selected_category := ""
var transitioning: bool = false
var fade_layer: CanvasLayer
var fade_rect: ColorRect
var move_player: AudioStreamPlayer
var confirm_player: AudioStreamPlayer


func _ready() -> void:
	configure_input_actions()
	create_transition_layer()
	create_menu_audio()
	await get_tree().process_frame
	fade_from_black()

var categories := {
	"physics": {
		"title": "Physics",
		"icon": "↗",
		"description": "Motion, collisions, forces and joints.",
		"accent": Color("62d9ff"),
		"modules": [
			{
				"title": "Projectile Laboratory",
				"description": "Launch a projectile and explore how angle, speed and gravity alter its path.",
				"scene": "res://modules/physics/projectile_lab.tscn",
				"status": "READY"
			},
			{
				"title": "Collision Layers",
				"description": "A visual playground for masks, layers and overlapping bodies.",
				"scene": "res://modules/physics/collision_lab.tscn",
				"status": "READY"
			}
		]
	},
	"sprites": {
		"title": "Sprites",
		"icon": "◆",
		"description": "Animation, layering and sprite behaviour.",
		"accent": Color("ff8cc8"),
		"modules": [
			{"title": "Animation Workshop", "description": "Compare frame animation with an AnimationPlayer motion layer.", "scene": "res://modules/sprites/animation_workshop.tscn", "status": "READY"}
		]
	},
	"scoring": {
		"title": "Scoring Systems",
		"icon": "★",
		"description": "Points, combos, multipliers and feedback.",
		"accent": Color("ffd166"),
		"modules": [
			{"title": "Combo Laboratory", "description": "Test timing windows, multiplier growth and score feedback.", "scene": "res://modules/scoring/combo_lab.tscn", "status": "READY"}
		]
	},
	"effects": {
		"title": "Unusual Visual Effects",
		"icon": "✦",
		"description": "Particles, shaders and screen effects.",
		"accent": Color("a78bfa"),
		"modules": [
			{"title": "Impact Effects", "description": "Mix screen shake, flashes, squash and procedural particles.", "scene": "res://modules/effects/impact_lab.tscn", "status": "READY"},
			{"title": "Neon Kaleidoscope", "description": "Conduct a colourful, symmetrical light machine with the controller.", "scene": "res://modules/effects/kaleidoscope_lab.tscn", "status": "READY"}
		]
	},
	"gameplay": {
		"title": "Basic Gameplay Loops",
		"icon": "↻",
		"description": "Small repeatable loops and prototypes.",
		"accent": Color("7ee787"),
		"modules": [
			{"title": "Collect and Return", "description": "Gather objects, manage carrying capacity, and bank them under pressure.", "scene": "res://modules/gameplay/collect_return.tscn", "status": "READY"}
		]
	}
}


func configure_input_actions() -> void:
	# UI buttons use Godot's built-in action, so explicitly ensure controllers
	# have an accept input rather than relying on an editor-generated default.
	add_action("ui_accept", [KEY_ENTER, KEY_SPACE], [JOY_BUTTON_A])
	add_action("sandbox_back", [KEY_ESCAPE], [JOY_BUTTON_B])
	add_action("sandbox_reset", [KEY_R], [JOY_BUTTON_X])
	add_action("lab_layer_1", [KEY_1], [JOY_BUTTON_X])
	add_action("lab_layer_2", [KEY_2], [JOY_BUTTON_Y])
	add_action("lab_layer_3", [KEY_3], [JOY_BUTTON_LEFT_SHOULDER])
	add_action("combo_hit", [KEY_SPACE, KEY_ENTER], [JOY_BUTTON_A])


func add_action(action_name: StringName, keys: Array, joy_buttons: Array) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for keycode in keys:
		var key_event := InputEventKey.new()
		key_event.physical_keycode = keycode
		if not InputMap.action_has_event(action_name, key_event):
			InputMap.action_add_event(action_name, key_event)
	for button_index in joy_buttons:
		var joy_event := InputEventJoypadButton.new()
		joy_event.button_index = button_index
		if not InputMap.action_has_event(action_name, joy_event):
			InputMap.action_add_event(action_name, joy_event)


func open_category(category_id: String) -> void:
	selected_category = category_id
	change_scene(CATEGORY_MENU)


func open_module(scene_path: String) -> void:
	if not scene_path.is_empty():
		change_scene(scene_path)


func go_home() -> void:
	change_scene(MAIN_MENU)


func change_scene(scene_path: String) -> void:
	if transitioning:
		return
	transitioning = true
	fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var fade_out: Tween = create_tween()
	fade_out.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	fade_out.tween_property(fade_rect, "color:a", 1.0, 0.22)
	await fade_out.finished
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	var fade_in: Tween = create_tween()
	fade_in.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	fade_in.tween_property(fade_rect, "color:a", 0.0, 0.28)
	await fade_in.finished
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transitioning = false


func create_transition_layer() -> void:
	fade_layer = CanvasLayer.new()
	fade_layer.layer = 100
	add_child(fade_layer)
	fade_rect = ColorRect.new()
	fade_rect.color = Color(0.025, 0.045, 0.08, 1.0)
	fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	fade_layer.add_child(fade_rect)


func fade_from_black() -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(fade_rect, "color:a", 0.0, 0.4)
	await tween.finished
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE


func create_menu_audio() -> void:
	move_player = AudioStreamPlayer.new()
	move_player.stream = create_tone(540.0, 0.045, 0.15)
	move_player.volume_db = -11.0
	add_child(move_player)
	confirm_player = AudioStreamPlayer.new()
	confirm_player.stream = create_tone(760.0, 0.09, 0.22)
	confirm_player.volume_db = -8.0
	add_child(confirm_player)


func create_tone(frequency: float, duration: float, volume: float) -> AudioStreamWAV:
	const SAMPLE_RATE := 22050
	var sample_count: int = int(SAMPLE_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(sample_count * 2)
	for index in range(sample_count):
		var progress: float = float(index) / float(sample_count)
		var envelope: float = (1.0 - progress) * volume
		var wave: float = sin(TAU * frequency * float(index) / float(SAMPLE_RATE))
		bytes.encode_s16(index * 2, int(wave * envelope * 32767.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = bytes
	return stream


func play_move() -> void:
	if move_player:
		move_player.play()


func play_confirm() -> void:
	if confirm_player:
		confirm_player.play()
