extends Node

const MAIN_MENU := "res://main/main_menu.tscn"
const CATEGORY_MENU := "res://main/category_menu.tscn"

var selected_category := ""


func _ready() -> void:
	configure_input_actions()

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
			{"title": "Animation Workshop", "description": "Compare sprite animation techniques and timing.", "scene": "", "status": "PLANNED"}
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
			{"title": "Impact Effects", "description": "Mix screen shake, hit-stop, flashes and particles.", "scene": "", "status": "PLANNED"}
		]
	},
	"gameplay": {
		"title": "Basic Gameplay Loops",
		"icon": "↻",
		"description": "Small repeatable loops and prototypes.",
		"accent": Color("7ee787"),
		"modules": [
			{"title": "Collect and Return", "description": "Gather objects, bank them safely, and repeat under pressure.", "scene": "", "status": "PLANNED"}
		]
	}
}


func configure_input_actions() -> void:
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
	get_tree().change_scene_to_file(CATEGORY_MENU)


func open_module(scene_path: String) -> void:
	if not scene_path.is_empty():
		get_tree().change_scene_to_file(scene_path)


func go_home() -> void:
	get_tree().change_scene_to_file(MAIN_MENU)
