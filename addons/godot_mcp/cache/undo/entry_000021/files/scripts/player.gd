extends CharacterBody2D
## ตัวละครผู้เล่น (ตัวทดสอบชั่วคราว) เดินแนว isometric
## iso_squash < 1 ทำให้เดินแนวตั้งช้าลง ให้ความรู้สึกเป็นมุมเอียง
## รูปทรงชน กล้อง และฮิตบล็อกทั้งหมดอยู่ในโหนดของฉาก แก้ในหน้า 2D ได้เลย

@export var speed := 140.0
@export var iso_squash := 0.5

@onready var interact_area: Area2D = $InteractArea

func _physics_process(_delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = Vector2(input.x, input.y * iso_squash) * speed
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		for area in interact_area.get_overlapping_areas():
			if area.is_in_group("interactable"):
				print("โต้ตอบกับ: ", area.name)
