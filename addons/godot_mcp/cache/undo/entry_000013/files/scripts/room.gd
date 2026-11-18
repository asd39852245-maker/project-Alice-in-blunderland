extends Node2D
## ห้องหมากรุก (พาร์ท 2)
## สร้างกำแพงล่องหนเป็นวงรีรอบพื้นห้อง ไม่ให้ตัวละครเดินออกนอกพื้นที่
## ปรับ floor_center / walk_radius ใน Inspector ได้ ถ้าขอบไม่ตรงกับภาพ

@export var floor_center := Vector2(702, 612)
@export var walk_radius := Vector2(500, 300)
@export var segments := 48
@export var show_debug := false

func _ready() -> void:
	_build_boundary()
	queue_redraw()

func _ellipse_point(angle: float, scale_factor: float) -> Vector2:
	return floor_center + Vector2(cos(angle) * walk_radius.x, sin(angle) * walk_radius.y) * scale_factor

func _build_boundary() -> void:
	var body := $Boundary as StaticBody2D
	for i in segments:
		var a0 := TAU * float(i) / segments
		var a1 := TAU * float(i + 1) / segments
		var poly := CollisionPolygon2D.new()
		poly.polygon = PackedVector2Array([
			_ellipse_point(a0, 1.0),
			_ellipse_point(a1, 1.0),
			_ellipse_point(a1, 2.0),
			_ellipse_point(a0, 2.0),
		])
		body.add_child(poly)

func _draw() -> void:
	if not show_debug:
		return
	var pts := PackedVector2Array()
	for i in segments + 1:
		pts.append(_ellipse_point(TAU * float(i) / segments, 1.0))
	draw_polyline(pts, Color(1, 0, 0, 0.8), 2.0)
