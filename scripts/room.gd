extends Node2D
## ห้องหมากรุก (พาร์ท 2)
## - ใส่ภาพแมพ และตั้งรูปทรงชนของประตู/โต๊ะ ด้วยโค้ดตอนเริ่มเกม
## - สร้างกำแพงล่องหนเป็นวงรีรอบพื้นห้อง ไม่ให้ตัวละครเดินออกนอกพื้นที่
## ปรับ floor_center / walk_radius ใน Inspector ได้ ถ้าขอบไม่ตรงกับภาพ

const MAP_TEXTURE: Texture2D = preload("res://assets/maps/checker_room.png")

@export var floor_center := Vector2(702, 612)
@export var walk_radius := Vector2(500, 300)
@export var segments := 48
@export var show_debug := false

func _ready() -> void:
	_setup_background()
	_setup_shapes()
	_build_boundary()
	queue_redraw()

func _setup_background() -> void:
	var bg := $Background as Sprite2D
	bg.texture = MAP_TEXTURE
	bg.centered = false
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	bg.z_index = -10

func _make_circle(radius: float) -> CircleShape2D:
	var c := CircleShape2D.new()
	c.radius = radius
	return c

func _setup_shapes() -> void:
	var table_shape := RectangleShape2D.new()
	table_shape.size = Vector2(180, 70)
	($TableBody/CollisionShape2D as CollisionShape2D).shape = table_shape
	for area in $Interactables.get_children():
		var cs := area.get_node("CollisionShape2D") as CollisionShape2D
		cs.shape = _make_circle(70.0 if area.name == "Note_Table" else 50.0)

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
