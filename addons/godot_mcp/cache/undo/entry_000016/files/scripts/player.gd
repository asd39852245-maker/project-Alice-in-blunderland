extends CharacterBody2D
## ตัวละครผู้เล่น (ตัวทดสอบชั่วคราว) เดินแนว isometric
## iso_squash < 1 ทำให้เดินแนวตั้งช้าลง ให้ความรู้สึกเป็นมุมเอียง
## รูปทรงชนและขอบกล้องตั้งด้วยโค้ดตอนเริ่มเกม

@export var speed := 140.0
@export var iso_squash := 0.5
@export var map_size := Vector2i(1402, 1122)

@onready var interact_area: Area2D = $InteractArea

func _ready() -> void:
	var body_shape := CircleShape2D.new()
	body_shape.radius = 10.0
	($CollisionShape2D as CollisionShape2D).shape = body_shape

	var interact_shape := CircleShape2D.new()
	interact_shape.radius = 48.0
	($InteractArea/CollisionShape2D as CollisionShape2D).shape = interact_shape

	var body_rect := $Body as ColorRect
	body_rect.color = Color("#ffd166")
	body_rect.size = Vector2(20, 44)
	body_rect.position = Vector2(-10, -44)

	var cam := $Camera2D as Camera2D
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = map_size.x
	cam.limit_bottom = map_size.y
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 8.0

func _physics_process(_delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = Vector2(input.x, input.y * iso_squash) * speed
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		for area in interact_area.get_overlapping_areas():
			if area.is_in_group("interactable"):
				print("โต้ตอบกับ: ", area.name)
