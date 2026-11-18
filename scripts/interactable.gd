extends Area2D
## สิ่งที่ผู้เล่นกด E โต้ตอบได้ (โน้ต ประตู NPC ฯลฯ)
## ใช้งาน: แนบสคริปต์นี้กับ Area2D ที่อยู่ในกลุ่ม "interactable"
## แล้วใส่ Dialogue Id ให้ตรงกับชื่อใน res://data/dialogues.json
##
## ช่องที่ใช้ใน dialogues.json:
##   speaker     ชื่อผู้พูด (ว่างได้)
##   prompt      ข้อความที่ขึ้นเหนือหัวตัวละคร เช่น "อ่านโน้ต" หรือ "คุยกับ ..."
##   lines       บทพูดครั้งแรก
##   flag        ชื่อ flag ที่จะตั้งเมื่อพูดจบ (ใส่หรือไม่ใส่ก็ได้)
##   give_item   ไอเท็มที่ได้รับเมื่อพูดจบ (ใส่หรือไม่ใส่ก็ได้)
##   lines_after บทพูดเมื่อมี flag แล้ว (เช่น หยิบของไปแล้ว)

@export var dialogue_id := ""

func _entry() -> Dictionary:
	return DialogueBox.get_entry(dialogue_id)

func get_prompt() -> String:
	return str(_entry().get("prompt", "โต้ตอบ"))

func interact(_player: Node) -> void:
	var entry := _entry()
	if entry.is_empty():
		push_warning("ไม่พบบทพูดชื่อ '%s' ใน dialogues.json" % dialogue_id)
		return
	var flag: String = entry.get("flag", "")
	var already_done := flag != "" and GameState.has_flag(flag)
	var lines: Array = entry.get("lines", [])
	if already_done and entry.has("lines_after"):
		lines = entry["lines_after"]
	DialogueBox.start(str(entry.get("speaker", "")), lines)
	await DialogueBox.finished
	if not already_done:
		if entry.has("give_item"):
			GameState.add_item(str(entry["give_item"]))
		if flag != "":
			GameState.set_flag(flag)
