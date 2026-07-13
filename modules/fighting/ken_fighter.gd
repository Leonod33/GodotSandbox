class_name KenFighter
extends Node2D

signal state_changed(new_state: StringName)

# The supplied sheet is already the full-resolution 1546x5207 source. This
# display multiplier preserves the character's previous on-screen size without
# scaling the Node2D or altering the source texture.
const DISPLAY_SCALE := 2.36
const WALK_SPEED := 245.0
const JUMP_HORIZONTAL_SPEED := 225.0
const JUMP_VELOCITY := -900.0
const GRAVITY := 2300.0
const JUMP_APEX_HEIGHT := 176.0
const FLOOR_Y := 535.0
const START_X := 270.0
const LEFT_BOUND := 70.0
const RIGHT_BOUND := 1082.0
const PUSHBOX_HALF_WIDTH := 53.0
const CLOSE_ATTACK_DISTANCE := 155.0
const ATTACK_STATES: Array[StringName] = [
	&"light_punch", &"medium_punch", &"heavy_punch",
	&"close_light_punch", &"close_medium_punch", &"close_heavy_punch",
	&"light_kick", &"medium_kick", &"heavy_kick",
	&"close_light_kick", &"close_medium_kick", &"close_heavy_kick"
]

var idle_frames: Array[Rect2] = [
	Rect2(15, 22, 62, 93), Rect2(81, 22, 64, 93), Rect2(150, 22, 62, 93),
	Rect2(216, 20, 62, 95), Rect2(282, 17, 59, 98), Rect2(345, 20, 62, 95)
]
var idle_anchors: Array[Vector2] = [
	Vector2(30.5, 92), Vector2(32, 92), Vector2(30.5, 92),
	Vector2(31, 94), Vector2(29.5, 97), Vector2(31, 94)
]
var light_punch_frames: Array[Rect2] = [
	Rect2(15, 284, 67, 97), Rect2(86, 284, 97, 97), Rect2(188, 284, 67, 97)
]
var light_punch_anchors: Array[Vector2] = [
	Vector2(33, 96), Vector2(48, 96), Vector2(32, 96)
]
var medium_punch_frames: Array[Rect2] = []
var medium_punch_anchors: Array[Vector2] = []
var close_light_punch_frames: Array[Rect2] = []
var close_light_punch_anchors: Array[Vector2] = []
var close_medium_punch_frames: Array[Rect2] = []
var close_medium_punch_anchors: Array[Vector2] = []
var close_heavy_punch_frames: Array[Rect2] = []
var close_heavy_punch_anchors: Array[Vector2] = []
var far_light_medium_kick_frames: Array[Rect2] = []
var far_light_medium_kick_anchors: Array[Vector2] = []
var heavy_kick_frames: Array[Rect2] = []
var heavy_kick_anchors: Array[Vector2] = []
var close_light_kick_frames: Array[Rect2] = []
var close_light_kick_anchors: Array[Vector2] = []
var close_medium_kick_frames: Array[Rect2] = []
var close_medium_kick_anchors: Array[Vector2] = []
var close_heavy_kick_frames: Array[Rect2] = []
var close_heavy_kick_anchors: Array[Vector2] = []
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
var somersault_frames: Array[Rect2] = [
	Rect2(16, 2261, 55, 85), Rect2(79, 2238, 55, 103), Rect2(142, 2198, 61, 78),
	Rect2(211, 2204, 104, 42), Rect2(323, 2167, 53, 82), Rect2(384, 2198, 122, 44),
	Rect2(514, 2183, 71, 87), Rect2(593, 2188, 55, 103), Rect2(656, 2261, 55, 85)
]
var somersault_anchors: Array[Vector2] = [
	Vector2(27.5, 85), Vector2(27.5, 94), Vector2(30.5, 81.5),
	Vector2(52, 63.5), Vector2(26.5, 83.5), Vector2(61, 64.5),
	Vector2(35.5, 86), Vector2(27.5, 94), Vector2(27.5, 85)
]

var sprite_sheet: Texture2D
var state: StringName = &"idle"
var frame_index: int = 0
var frame_elapsed: float = 0.0
var velocity: Vector2 = Vector2.ZERO
var facing: float = 1.0
var grounded: bool = true
var travelling_jump: bool = false
var opponent: Node2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite_sheet = load("res://modules/fighting/ken_sheet.png") as Texture2D
	populate_attack_frames_from_sheet()
	position.y = FLOOR_Y
	queue_redraw()


func _physics_process(delta: float) -> void:
	var previous_x: float = position.x
	var horizontal_input: float = Input.get_axis("ui_left", "ui_right")
	var crouching: bool = grounded and Input.is_action_pressed("ui_down")

	if grounded and not crouching and not is_attacking():
		if Input.is_action_just_pressed("heavy_kick"):
			start_attack(distance_attack(&"close_heavy_kick", &"heavy_kick"))
		elif Input.is_action_just_pressed("medium_kick"):
			start_attack(distance_attack(&"close_medium_kick", &"medium_kick"))
		elif Input.is_action_just_pressed("light_kick"):
			start_attack(distance_attack(&"close_light_kick", &"light_kick"))
		elif Input.is_action_just_pressed("close_heavy_punch"):
			start_attack(&"close_heavy_punch")
		elif Input.is_action_just_pressed("heavy_punch"):
			start_attack(distance_attack(&"close_heavy_punch", &"heavy_punch"))
		elif Input.is_action_just_pressed("medium_punch"):
			start_attack(distance_attack(&"close_medium_punch", &"medium_punch"))
		elif Input.is_action_just_pressed("light_punch"):
			start_attack(distance_attack(&"close_light_punch", &"light_punch"))

	if grounded and not is_attacking() and Input.is_action_just_pressed("ui_up") and not crouching:
		grounded = false
		travelling_jump = not is_zero_approx(horizontal_input)
		velocity.x = signf(horizontal_input) * JUMP_HORIZONTAL_SPEED if travelling_jump else 0.0
		velocity.y = JUMP_VELOCITY
		set_state(&"jump")

	if is_attacking():
		velocity.x = 0.0
	elif not grounded:
		velocity.y += GRAVITY * delta
		position += velocity * delta
		if position.y >= FLOOR_Y:
			position.y = FLOOR_Y
			velocity = Vector2.ZERO
			grounded = true
			travelling_jump = false
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
	constrain_against_opponent(previous_x)
	position.x = clampf(position.x, LEFT_BOUND, RIGHT_BOUND)
	update_facing_from_opponent()
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


func start_attack(attack_state: StringName) -> void:
	velocity.x = 0.0
	set_state(attack_state)


func is_attacking() -> bool:
	return state in ATTACK_STATES


func is_close_to_opponent() -> bool:
	return opponent != null and absf(opponent.position.x - position.x) <= CLOSE_ATTACK_DISTANCE


func distance_attack(close_state: StringName, far_state: StringName) -> StringName:
	return close_state if is_close_to_opponent() else far_state


func set_opponent(new_opponent: Node2D) -> void:
	opponent = new_opponent
	update_facing_from_opponent()


func constrain_against_opponent(previous_x: float) -> void:
	if not grounded or opponent == null:
		return
	var opponent_half_width: float = PUSHBOX_HALF_WIDTH
	if opponent.has_method("get_pushbox_half_width"):
		opponent_half_width = float(opponent.call("get_pushbox_half_width"))
	var minimum_separation: float = PUSHBOX_HALF_WIDTH + opponent_half_width
	var difference: float = position.x - opponent.position.x
	if absf(difference) >= minimum_separation:
		return
	var side: float = signf(difference)
	if is_zero_approx(side):
		side = -1.0 if previous_x <= opponent.position.x else 1.0
	position.x = opponent.position.x + side * minimum_separation
	velocity.x = 0.0


func update_facing_from_opponent() -> void:
	if opponent == null:
		return
	var direction_to_opponent: float = opponent.position.x - position.x
	if not is_zero_approx(direction_to_opponent):
		facing = signf(direction_to_opponent)


func set_state(new_state: StringName) -> void:
	if state == new_state:
		return
	state = new_state
	frame_index = 0
	frame_elapsed = 0.0
	state_changed.emit(state)


func advance_animation(delta: float) -> void:
	var frames: Array[Rect2] = current_frames()
	if frames.is_empty():
		set_state(&"idle")
		return
	var frame_duration: float = animation_frame_duration()
	frame_elapsed += delta
	if frame_elapsed < frame_duration:
		return
	frame_elapsed -= frame_duration
	if is_attacking():
		frame_index += 1
		if frame_index >= frames.size():
			set_state(&"idle")
	elif state == &"crouch":
		frame_index = mini(frame_index + 1, frames.size() - 1)
	elif state == &"jump":
		if travelling_jump:
			frame_index = mini(frame_index + 1, frames.size() - 1)
		else:
			var jump_progress: float = clampf((FLOOR_Y - position.y) / JUMP_APEX_HEIGHT, 0.0, 1.0)
			if velocity.y < 0.0:
				frame_index = mini(int(jump_progress * 3.0), 3)
			else:
				frame_index = clampi(3 + int((1.0 - jump_progress) * 4.0), 3, frames.size() - 1)
	else:
		frame_index = (frame_index + 1) % frames.size()


func current_frames() -> Array[Rect2]:
	match state:
		&"light_punch":
			return light_punch_frames
		&"medium_punch":
			return medium_punch_frames
		&"heavy_punch":
			return medium_punch_frames
		&"close_light_punch":
			return close_light_punch_frames
		&"close_medium_punch":
			return close_medium_punch_frames
		&"close_heavy_punch":
			return close_heavy_punch_frames
		&"light_kick":
			return far_light_medium_kick_frames
		&"medium_kick":
			return far_light_medium_kick_frames
		&"heavy_kick":
			return heavy_kick_frames
		&"close_light_kick":
			return close_light_kick_frames
		&"close_medium_kick":
			return close_medium_kick_frames
		&"close_heavy_kick":
			return close_heavy_kick_frames
		&"walk":
			return walk_frames
		&"crouch":
			return crouch_frames
		&"jump":
			return somersault_frames if travelling_jump else jump_frames
		_:
			return idle_frames


func current_anchors() -> Array[Vector2]:
	match state:
		&"light_punch":
			return light_punch_anchors
		&"medium_punch":
			return medium_punch_anchors
		&"heavy_punch":
			return medium_punch_anchors
		&"close_light_punch":
			return close_light_punch_anchors
		&"close_medium_punch":
			return close_medium_punch_anchors
		&"close_heavy_punch":
			return close_heavy_punch_anchors
		&"light_kick":
			return far_light_medium_kick_anchors
		&"medium_kick":
			return far_light_medium_kick_anchors
		&"heavy_kick":
			return heavy_kick_anchors
		&"close_light_kick":
			return close_light_kick_anchors
		&"close_medium_kick":
			return close_medium_kick_anchors
		&"close_heavy_kick":
			return close_heavy_kick_anchors
		&"walk":
			return walk_anchors
		&"crouch":
			return crouch_anchors
		&"jump":
			return somersault_anchors if travelling_jump else jump_anchors
		_:
			return idle_anchors


func animation_speed() -> float:
	match state:
		&"light_punch":
			return 14.0
		&"medium_punch":
			return 12.0
		&"heavy_punch":
			return 12.0
		&"close_light_punch":
			return 14.0
		&"close_medium_punch":
			return 12.0
		&"close_heavy_punch":
			return 10.5
		&"light_kick":
			return 16.0
		&"medium_kick":
			return 15.0
		&"heavy_kick":
			return 10.0
		&"close_light_kick":
			return 14.0
		&"close_medium_kick":
			return 12.0
		&"close_heavy_kick":
			return 10.0
		&"walk":
			return 11.0
		&"crouch":
			return 8.0
		&"jump":
			return 14.0 if travelling_jump else 12.0
		_:
			return 7.5


func animation_frame_duration() -> float:
	# Far heavy punch reuses far medium punch and holds its fully extended frame.
	if state == &"heavy_punch" and frame_index == 2:
		return 0.18
	# Far light and medium kick share frames. Medium lingers on the fully
	# extended third frame, matching the original game's heavier timing.
	if state == &"medium_kick" and frame_index == 2:
		return 0.16
	return 1.0 / animation_speed()


# The first attack rows contain several animation sequences with irregularly
# sized frames. Reading their alpha-separated bounds keeps the frame selection
# tied to the user's row/frame references without making fragile guesses at
# hand-measured pixel rectangles.
func populate_attack_frames_from_sheet() -> void:
	if sprite_sheet == null:
		return
	var image: Image = sprite_sheet.get_image()
	if image == null or image.is_empty():
		push_error("Ken sprite sheet could not be read for punch frame mapping.")
		return

	var rows: Array[Vector2i] = find_sprite_rows(image, 1000)
	if rows.size() < 6:
		push_error("Ken sprite sheet has fewer than six detectable animation rows.")
		return

	var third_row_frames: Array[Rect2] = find_frames_in_row(image, rows[2])
	var fourth_row_frames: Array[Rect2] = find_frames_in_row(image, rows[3])
	var fifth_row_frames: Array[Rect2] = find_frames_in_row(image, rows[4])
	var sixth_row_frames: Array[Rect2] = find_frames_in_row(image, rows[5])

	# Row 3: frames 1-3 are light punch; frames 4-8 are medium punch.
	append_frame_range(third_row_frames, 3, 8, medium_punch_frames, medium_punch_anchors)
	# Far heavy punch reuses far medium punch with a longer extended-frame hold.
	# Row 5 contains close light (1-3), medium (4-10), and heavy (11-15) punch.
	append_frame_range(fifth_row_frames, 0, 3, close_light_punch_frames, close_light_punch_anchors)
	append_frame_range(fifth_row_frames, 3, 10, close_medium_punch_frames, close_medium_punch_anchors)
	append_frame_range(fifth_row_frames, 10, 15, close_heavy_punch_frames, close_heavy_punch_anchors)
	# Row 4 frames 1-5 are shared by far light and medium kick. Their timing differs.
	append_frame_range(fourth_row_frames, 0, 5, far_light_medium_kick_frames, far_light_medium_kick_anchors)
	# Row 4 frames 6-10 are far heavy kick.
	append_frame_range(fourth_row_frames, 5, 10, heavy_kick_frames, heavy_kick_anchors)
	# Row 6 contains all three close kicks: frames 1-5, 6-10 and 11-16.
	append_frame_range(sixth_row_frames, 0, 5, close_light_kick_frames, close_light_kick_anchors)
	append_frame_range(sixth_row_frames, 5, 10, close_medium_kick_frames, close_medium_kick_anchors)
	append_frame_range(sixth_row_frames, 10, 16, close_heavy_kick_frames, close_heavy_kick_anchors)

	if medium_punch_frames.size() != 5:
		push_error("Expected five medium-punch frames on row 3.")
	if close_light_punch_frames.size() != 3:
		push_error("Expected three close light-punch frames on row 5.")
	if close_medium_punch_frames.size() != 7:
		push_error("Expected seven close medium-punch frames on row 5.")
	if close_heavy_punch_frames.size() != 5:
		push_error("Expected five close heavy-punch frames on row 5.")
	if far_light_medium_kick_frames.size() != 5:
		push_error("Expected five shared far light/medium-kick frames on row 4.")
	if heavy_kick_frames.size() != 5:
		push_error("Expected five far heavy-kick frames on row 4.")
	if close_light_kick_frames.size() != 5:
		push_error("Expected five close light-kick frames on row 6.")
	if close_medium_kick_frames.size() != 5:
		push_error("Expected five close medium-kick frames on row 6.")
	if close_heavy_kick_frames.size() != 6:
		push_error("Expected six close heavy-kick frames on row 6.")


func find_sprite_rows(image: Image, scan_height: int) -> Array[Vector2i]:
	var rows: Array[Vector2i] = []
	var row_start: int = -1
	var last_occupied_y: int = -1
	var maximum_y: int = mini(scan_height, image.get_height())

	for y in range(maximum_y):
		var occupied: bool = false
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a > 0.01:
				occupied = true
				break
		if occupied:
			if row_start == -1:
				row_start = y
			last_occupied_y = y
		elif row_start != -1 and y - last_occupied_y > 3:
			rows.append(Vector2i(row_start, last_occupied_y))
			row_start = -1
			last_occupied_y = -1

	if row_start != -1:
		rows.append(Vector2i(row_start, last_occupied_y))
	return rows


func find_frames_in_row(image: Image, row_bounds: Vector2i) -> Array[Rect2]:
	var frames: Array[Rect2] = []
	var frame_start_x: int = -1
	var last_occupied_x: int = -1

	for x in range(image.get_width()):
		var occupied: bool = false
		for y in range(row_bounds.x, row_bounds.y + 1):
			if image.get_pixel(x, y).a > 0.01:
				occupied = true
				break
		if occupied:
			if frame_start_x == -1:
				frame_start_x = x
			last_occupied_x = x
		elif frame_start_x != -1 and x - last_occupied_x > 3:
			frames.append(tight_frame_rect(image, frame_start_x, last_occupied_x, row_bounds))
			frame_start_x = -1
			last_occupied_x = -1

	if frame_start_x != -1:
		frames.append(tight_frame_rect(image, frame_start_x, last_occupied_x, row_bounds))
	return frames


func tight_frame_rect(image: Image, start_x: int, end_x: int, row_bounds: Vector2i) -> Rect2:
	var minimum_y: int = row_bounds.y
	var maximum_y: int = row_bounds.x
	for x in range(start_x, end_x + 1):
		for y in range(row_bounds.x, row_bounds.y + 1):
			if image.get_pixel(x, y).a > 0.01:
				minimum_y = mini(minimum_y, y)
				maximum_y = maxi(maximum_y, y)
	return Rect2(start_x, minimum_y, end_x - start_x + 1, maximum_y - minimum_y + 1)


func append_frame_range(
	source_frames: Array[Rect2],
	start_index: int,
	end_index: int,
	target_frames: Array[Rect2],
	target_anchors: Array[Vector2]
) -> void:
	for index in range(start_index, mini(end_index, source_frames.size())):
		var frame: Rect2 = source_frames[index]
		target_frames.append(frame)
		target_anchors.append(Vector2(frame.size.x / 2.0, frame.size.y - 1.0))


func reset_fighter() -> void:
	position = Vector2(START_X, FLOOR_Y)
	velocity = Vector2.ZERO
	facing = 1.0
	grounded = true
	travelling_jump = false
	set_state(&"idle")
	update_facing_from_opponent()
