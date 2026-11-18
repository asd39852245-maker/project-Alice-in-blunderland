extends CharacterBody2D
## ตัวละครผู้เล่น (อลิซ) เดินแนว isometric
## - เดินลง/ขึ้น: ใช้ท่า down / up
## - เดินซ้าย/ขวา: ใช้ท่า side (ภาพต้นฉบับหันขวา ไปทางซ้ายจะกลับด้านภาพ)
## - หยุดเดิน: เปลี่ยนเป็นท่ายืนค้างทิศล่าสุด
## ฮิตบล็อก กล้อง และสไปรต์ อยู่ในโหนดของฉาก แก้ในหน้า 2D ได้เลย

@export var speed := 140.0
@export var iso_squash := 0.5

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var interact_area: Area2D = $InteractArea

var facing := "down"  # down / side / up

func _physics_process(_delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = Vector2(input.x, input.y * iso_squash) * speed
	move_and_slide()
	_update_animation(input)

func _update_animation(input: Vector2) -> void:
	var moving := input.length() > 0.1
	if moving:
		if absf(input.x) >= absf(input.y):
			facing = "side"
			sprite.flip_h = input.x < 0.0
		elif input.y > 0.0:
			facing = "down"
			sprite.flip_h = false
		else:
			facing = "up"
			sprite.flip_h = false
	var anim := ("walk_" if moving else "stand_") + facing
	if sprite.animation != anim:
		sprite.play(anim)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		for area in interact_area.get_overlapping_areas():
			if area.is_in_group("interactable"):
				print("โต้ตอบกับ: ", area.name)
