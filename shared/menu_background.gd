class_name MenuBackground
extends Node2D

var accent: Color = Color("62d9ff")
var time: float = 0.0
var motes: Array[Vector2] = []


func setup(new_accent: Color) -> void:
	accent = new_accent
	for index in range(18):
		var x: float = fmod(83.0 + index * 197.0, 1152.0)
		var y: float = fmod(61.0 + index * 113.0, 648.0)
		motes.append(Vector2(x, y))
	queue_redraw()


func _process(delta: float) -> void:
	time += delta
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(0, 0, 1152, 648), Color("09111f"))
	for x in range(-40, 1200, 64):
		draw_line(Vector2(x, 0), Vector2(x, 648), Color(0.08, 0.15, 0.25, 0.42), 1.0)
	for y in range(0, 680, 64):
		draw_line(Vector2(0, y), Vector2(1152, y), Color(0.08, 0.15, 0.25, 0.42), 1.0)

	var glow: Color = accent
	glow.a = 0.055 + sin(time * 0.8) * 0.012
	draw_circle(Vector2(930, 120), 260.0, glow)
	var second_glow: Color = accent.lerp(Color("ff8cc8"), 0.35)
	second_glow.a = 0.035
	draw_circle(Vector2(180, 610), 235.0, second_glow)

	for index in range(motes.size()):
		var original: Vector2 = motes[index]
		var drift_y: float = fposmod(original.y - time * (7.0 + index % 4), 700.0) - 25.0
		var drift_x: float = original.x + sin(time * 0.45 + index) * 10.0
		var mote_color: Color = accent
		mote_color.a = 0.18 + float(index % 3) * 0.07
		draw_circle(Vector2(drift_x, drift_y), 1.5 + float(index % 2), mote_color)

	var scan_y: float = fposmod(time * 28.0, 648.0)
	var scan_color: Color = accent
	scan_color.a = 0.035
	draw_line(Vector2(0, scan_y), Vector2(1152, scan_y), scan_color, 2.0)
