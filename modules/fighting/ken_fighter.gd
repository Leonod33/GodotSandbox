class_name KenFighter
extends Node2D

signal state_changed(new_state: StringName)

const DISPLAY_SCALE := 4.0
const WALK_SPEED := 245.0
const JUMP_VELOCITY := -560.0
const GRAVITY := 1450.0
const FLOOR_Y := 535.0
const LEFT_BOUND := 105.0
const RIGHT_BOUND := 785.0

var idle_frames: Array[Rect2] = [
	Rect2(6, 9, 24, 36), Rect2(32, 9, 25, 36), Rect2(59, 9, 24, 36),
	Rect2(85, 8, 24, 37), Rect2(111, 7, 23, 38), Rect2(136, 8, 24, 37)
]
var walk_frames: Array[Rect2] = [
	Rect2(6, 63, 22, 34), Rect2(30, 61, 25, 36), Rect2(56, 60, 27, 37),
	Rect2(85, 61, 26, 36), Rect2(113, 61, 22, 36), Rect2(137, 61, 21, 36)
]
var crouch_frames: Array[Rect2] = [
	Rect2(30, 449, 23, 29), Rect2(55, 453, 26, 25)
]
var jump_frames: Array[Rect2] = [
	Rect2(30, 623, 23, 41), Rect2(55, 608, 21, 36), Rect2(78, 600, 22, 30),
	Rect2(103, 599, 19, 27), Rect2(125, 603, 19, 33), Rect2(147, 613, 22, 41),
	Rect2(172, 633, 22, 33)
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
	var colour_key_material := ShaderMaterial.new()
	colour_key_material.shader = load("res://modules/fighting/ken_colour_key.gdshader") as Shader
	material = colour_key_material
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
	var source: Rect2 = frames[mini(frame_index, frames.size() - 1)]
	var draw_size: Vector2 = source.size * DISPLAY_SCALE
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1.0))
	var destination := Rect2(-draw_size.x / 2.0, -draw_size.y, draw_size.x, draw_size.y)
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
