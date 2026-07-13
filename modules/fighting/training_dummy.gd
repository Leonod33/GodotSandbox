class_name TrainingDummy
extends Node2D

const DISPLAY_SCALE := 2.36
const PUSHBOX_HALF_WIDTH := 72.0
const IDLE_SPEED := 7.5

var idle_frames: Array[Rect2] = [
	Rect2(15, 22, 62, 93), Rect2(81, 22, 64, 93), Rect2(150, 22, 62, 93),
	Rect2(216, 20, 62, 95), Rect2(282, 17, 59, 98), Rect2(345, 20, 62, 95)
]
var idle_anchors: Array[Vector2] = [
	Vector2(30.5, 92), Vector2(32, 92), Vector2(30.5, 92),
	Vector2(31, 94), Vector2(29.5, 97), Vector2(31, 94)
]

var sprite_sheet: Texture2D
var opponent: Node2D
var frame_index: int = 0
var frame_elapsed: float = 0.0
var facing: float = -1.0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite_sheet = load("res://modules/fighting/ken_sheet.png") as Texture2D
	queue_redraw()


func _process(delta: float) -> void:
	frame_elapsed += delta
	if frame_elapsed >= 1.0 / IDLE_SPEED:
		frame_elapsed -= 1.0 / IDLE_SPEED
		frame_index = (frame_index + 1) % idle_frames.size()
		queue_redraw()
	if opponent != null:
		var direction_to_opponent: float = opponent.position.x - position.x
		if not is_zero_approx(direction_to_opponent):
			var new_facing: float = signf(direction_to_opponent)
			if new_facing != facing:
				facing = new_facing
				queue_redraw()


func _draw() -> void:
	if sprite_sheet == null:
		return
	var source: Rect2 = idle_frames[frame_index]
	var anchor: Vector2 = idle_anchors[frame_index]
	var draw_size: Vector2 = source.size * DISPLAY_SCALE
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1.0))
	draw_texture_rect_region(sprite_sheet, Rect2(-anchor * DISPLAY_SCALE, draw_size), source)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func set_opponent(new_opponent: Node2D) -> void:
	opponent = new_opponent


func get_pushbox_half_width() -> float:
	return PUSHBOX_HALF_WIDTH
