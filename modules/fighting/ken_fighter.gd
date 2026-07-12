class_name KenFighter
extends Node2D

signal state_changed(new_state: StringName)

# The supplied sheet is already the full-resolution 1546x5207 source.  This
# display multiplier preserves the character's previous on-screen size without
# scaling the Node2D or altering the source texture.
const DISPLAY_SCALE := 2.36
const WALK_SPEED := 245.0
const JUMP_VELOCITY := -560.0
const GRAVITY := 1450.0
const FLOOR_Y := 535.0
const LEFT_BOUND := 105.0
const RIGHT_BOUND := 785.0

var idle_frames: Array[Rect2] = [
	Rect2(15, 22, 62, 93), Rect2(81, 22, 64, 93), Rect2(150, 22, 62, 93),
	Rect2(216, 20, 62, 95), Rect2(282, 17, 59, 98), Rect2(345, 20, 62, 95)
]
var idle_anchors: Array[Vector2] = [
	Vector2(30.5, 92), Vector2(32, 92), Vector2(30.5, 92),
	Vector2(31, 94), Vector2(29.5, 97), Vector2(31, 94)
]
var walk_frames: Array[Rect2] = [
	Rect2(15, 160, 57, 87), Rect2(76, 155, 64, 92), Rect2(142, 152, 70, 95),
	Rect2(216, 155, 67, 92), Rect2(287, 155, 57, 92), Rect2(348, 155, 54, 92)
]
var walk_anchors: Array[Vector2] = [
	Vector2(27.5, 85), Vector2(31, 90), Vector2(35, 93),
	Vector2(32.5, 90), Vector2(28, 90), Vector2(27, 90)
]
var crouch_frames: Array[Rect2] = [
	Rect2(76, 1141, 59, 75), Rect2(139, 1151, 67, 65)
]
var crouch_anchors: Array[Vector2] = [
	Vector2(29.5, 73), Vector2(33.5, 63)
]
var jump_frames: Array[Rect2] = [
	Rect2(76, 1583, 59, 106), Rect2(139, 1545, 55, 93), Rect2(198, 1525, 57, 77),
	Rect2(261, 1522, 50, 70), Rect2(317, 1533, 50, 85), Rect2(373, 1558, 57, 105),
	Rect2(437, 1609, 57, 85)
]
var jump_anchors: Array[Vector2] = [
	Vector2(31, 106), Vector2(29, 93), Vector2(31.5, 77), Vector2(27, 70),
	Vector2(27, 85), Vector2(30.5, 105), Vector2(28.5, 85)
]

var sprite_sheet: Texture2D
var state: StringName = &"idle"
var frame_index: int = 0
var frame_elapsed: float = 0.0
var velocity: Vector2 = Vector2.ZERO
var facing: float = 1.0
var grounded: bool = true


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite_sheet = load("res://modules/fighting/ken_sheet.png") as Texture2D
	position.y = FLOOR_Y
	queue_redraw()


func _physics_process(delta: float) -> void:
	var horizontal_input: float = Input.get_axis("ui_left", "ui_right")
	var crouching: bool = grounded and Input.is_action_pressed("ui_down")

	if grounded and Input.is_action_just_pressed("ui_up") and not crouching:
		grounded = false
		velocity.y = JUMP_VELOCITY
		set_state(&"jump")

	if not grounded:
		velocity.y += GRAVITY * delta
		velocity.x = horizontal_input * WALK_SPEED * 0.72
		if not is_zero_approx(horizontal_input):
			facing = signf(horizontal_input)
		position += velocity * delta
		if position.y >= FLOOR_Y:
			position.y = FLOOR_Y
			velocity = Vector2.ZERO
			grounded = true
			set_state(&"idle")
	elif crouching:
		velocity.x = 0.0
		set_state(&"crouch")
	elif not is_zero_approx(horizontal_input):
		facing = signf(horizontal_input)
		velocity.x = horizontal_input * WALK_SPEED
		position.x += velocity.x * delta
		set_state(&"walk")
	else:
		velocity.x = 0.0
		set_state(&"idle")

	position.x = clampf(position.x, LEFT_BOUND, RIGHT_BOUND)
	advance_animation(delta)
	queue_redraw()


func _draw() -> void:
	if sprite_sheet == null:
		return
	var frames: Array[Rect2] = current_frames()
	if frames.is_empty():
		return
	var safe_frame_index: int = mini(frame_index, frames.size() - 1)
	var source: Rect2 = frames[safe_frame_index]
	var anchors: Array[Vector2] = current_anchors()
	var anchor: Vector2 = anchors[safe_frame_index]
	var draw_size: Vector2 = source.size * DISPLAY_SCALE
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1.0))
	var destination := Rect2(-anchor * DISPLAY_SCALE, draw_size)
	draw_texture_rect_region(sprite_sheet, destination, source)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func set_state(new_state: StringName) -> void:
	if state == new_state:
		return
	state = new_state
	frame_index = 0
	frame_elapsed = 0.0
	state_changed.emit(state)


func advance_animation(delta: float) -> void:
	var frames: Array[Rect2] = current_frames()
	var frames_per_second: float = animation_speed()
	frame_elapsed += delta
	if frame_elapsed < 1.0 / frames_per_second:
		return
	frame_elapsed -= 1.0 / frames_per_second
	if state == &"crouch":
		frame_index = mini(frame_index + 1, frames.size() - 1)
	elif state == &"jump":
		var jump_progress: float = clampf((FLOOR_Y - position.y) / 112.0, 0.0, 1.0)
		if velocity.y < 0.0:
			frame_index = mini(int(jump_progress * 3.0), 3)
		else:
			frame_index = clampi(3 + int((1.0 - jump_progress) * 4.0), 3, frames.size() - 1)
	else:
		frame_index = (frame_index + 1) % frames.size()


func current_frames() -> Array[Rect2]:
	match state:
		&"walk":
			return walk_frames
		&"crouch":
			return crouch_frames
		&"jump":
			return jump_frames
		_:
			return idle_frames


func current_anchors() -> Array[Vector2]:
	match state:
		&"walk":
			return walk_anchors
		&"crouch":
			return crouch_anchors
		&"jump":
			return jump_anchors
		_:
			return idle_anchors


func animation_speed() -> float:
	match state:
		&"walk":
			return 11.0
		&"crouch":
			return 8.0
		&"jump":
			return 12.0
		_:
			return 7.5


func reset_fighter() -> void:
	position = Vector2(335, FLOOR_Y)
	velocity = Vector2.ZERO
	facing = 1.0
	grounded = true
	set_state(&"idle")
