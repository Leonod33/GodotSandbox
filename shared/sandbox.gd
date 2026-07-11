extends Node

const MAIN_MENU := "res://main/main_menu.tscn"
const CATEGORY_MENU := "res://main/category_menu.tscn"

var selected_category := ""

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
				"scene": "",
				"status": "PLANNED"
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
			{"title": "Combo Laboratory", "description": "Test combo windows, multiplier decay and score feedback.", "scene": "", "status": "PLANNED"}
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


func open_category(category_id: String) -> void:
	selected_category = category_id
	get_tree().change_scene_to_file(CATEGORY_MENU)


func open_module(scene_path: String) -> void:
	if not scene_path.is_empty():
		get_tree().change_scene_to_file(scene_path)


func go_home() -> void:
	get_tree().change_scene_to_file(MAIN_MENU)

