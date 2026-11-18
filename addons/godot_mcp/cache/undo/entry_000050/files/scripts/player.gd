extends CharacterBody2D
## ตัวละครผู้เล่น (อลิซ) เดินแนว isometric
## - เดินลง/ขึ้น: ใช้ท่า down / up
## - เดินซ้าย/ขวา: ใช้ท่า side (ภาพต้นฉบับหันขวา ไปทางซ้ายจะกลับด้านภาพ)
## - หยุดเดิน: เปลี่ยนเป็นท่ายืนค้างทิศล่าสุด
## - ยืนใกล้ของที่โต้ตอบได้ จะมีข้อความ [E] ขึ้นเหนือหัว กด E เพื่อโต้ตอบ
## - ระหว่างอ่านกล่องข้อความ ตัวละครจะหยุดเดิน
## ฮิตบล็อก กล้อง และสไปรต์ อยู่ในโหนดของฉาก แก้ในหน้า 2D ได้เลย

@export var speed := 140.0
@export var iso_squash := 0.5

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var interact_area: Area2D = $InteractArea
@onready var prompt_label: Label = $PromptLabel

var facing := "down"  # down / side / up
var _target: Area2D = null

func _ready() -> void:
	prompt_label.add_theme_font_size_override("font_size", 12)
	prompt_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	prompt_label.add_theme_constant_override("outline_size", 4)
	prompt_label.hide()

func _physics_process(_delta: float) -> void:
	if DialogueBox.active:
		velocity = Vector2.ZERO
		move_and_slide()
		_update_animation(Vector2.ZERO)
		prompt_label.hide()
		return
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = Vector2(input.x, input.y * iso_squash) * speed
	move_and_slide()
	_update_animation(input)
	_update_target()

func _update_target() -> void:
	var best: Area2D = null
	var best_dist := INF
	for area in interact_area.get_overlapping_areas():
		if area.is_in_group("interactable") and area.has_method("interact"):
			var d := global_position.distance_squared_to(area.global_position)
			if d < best_dist:
				best_dist = d
				best = area
	_target = best
	if _target:
		prompt_label.text = "[E] " + _target.get_prompt()
		prompt_label.show()
	else:
		prompt_label.hide()

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
	if DialogueBox.active:
		return
	if event.is_action_pressed("interact") and _target:
		_target.interact(self)
