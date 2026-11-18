extends Area2D
## ประตู (กด E)
## กติกา: กุญแจมี 1 ดอก ใช้เปิดประตูได้แค่ 1 บานจากทั้งหมด
##  - ยังไม่มีกุญแจ        -> ประตูล็อกอยู่
##  - มีกุญแจ ยังไม่เลือก  -> ถามยืนยัน ถ้าตกลง กุญแจจะหายและประตูบานนี้เปิดออก
##  - เลือกบานนี้ไปแล้ว     -> เข้าประตูได้
##  - เลือกบานอื่นไปแล้ว    -> บานนี้ล็อกตลอดไป
## ข้อความทั้งหมดอยู่ใน res://data/dialogues.json (ชื่อขึ้นต้นด้วย door_)

@export var door_id := ""            ## ชื่อประตู เช่น north / south / east / west
@export var door_name := "ประตู"     ## ชื่อที่แสดงในข้อความ
@export_file("*.tscn") var destination := ""  ## ฉากที่จะไปเมื่อเข้าประตู (ว่าง = ยังไม่ทำ)

func _chosen() -> String:
	return str(GameState.get_value("chosen_door", ""))

func get_prompt() -> String:
	if _chosen() == door_id:
		return "เข้า" + door_name
	return "ตรวจ" + door_name

func _say(entry_id: String) -> void:
	var entry := DialogueBox.get_entry(entry_id)
	var lines: Array = []
	for line in entry.get("lines", []):
		lines.append(str(line).replace("{door}", door_name))
	DialogueBox.start(str(entry.get("speaker", "")), lines)
	await DialogueBox.finished

func interact(_player: Node) -> void:
	var chosen := _chosen()
	if chosen == door_id:
		await _enter()
	elif chosen != "":
		await _say("door_locked_forever")
	elif GameState.has_item("key"):
		var entry := DialogueBox.get_entry("door_confirm")
		var question := str(entry.get("question", "")).replace("{door}", door_name)
		var choice: int = await DialogueBox.ask(str(entry.get("speaker", "")), question, entry.get("options", ["ใช่", "ไม่"]))
		if choice == 0:
			GameState.remove_item("key")
			GameState.set_value("chosen_door", door_id)
			await _say("door_unlocked")
			await _enter()
	else:
		await _say("door_no_key")

func _enter() -> void:
	if destination == "" or not ResourceLoader.exists(destination):
		await _say("door_not_ready")
		return
	get_tree().change_scene_to_file(destination)
