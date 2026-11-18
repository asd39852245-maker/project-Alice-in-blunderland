extends CanvasLayer
## กล่องข้อความกลาง (Autoload ชื่อ DialogueBox)
## - DialogueBox.start("ชื่อผู้พูด", ["ประโยค 1", "ประโยค 2"]) เปิดกล่องข้อความ
## - กด E หรือ Enter: ถ้าข้อความยังพิมพ์ไม่จบ จะแสดงเต็มทันที ถ้าจบแล้วไปประโยคถัดไป
## - ส่งสัญญาณ finished เมื่อจบทุกประโยค
## - ข้อมูลบทพูดอยู่ที่ res://data/dialogues.json

signal finished

const DB_PATH := "res://data/dialogues.json"
const CHARS_PER_SECOND := 40.0

var active := false

var _db: Dictionary = {}
var _lines: Array = []
var _index := 0
var _start_frame := -1
var _tween: Tween

@onready var panel: PanelContainer = $Panel
@onready var name_label: Label = $Panel/Margin/VBox/Name
@onready var text_label: RichTextLabel = $Panel/Margin/VBox/Text
@onready var hint_label: Label = $Panel/Margin/VBox/Hint

func _ready() -> void:
	panel.hide()
	_load_db()

func _load_db() -> void:
	if not FileAccess.file_exists(DB_PATH):
		push_warning("ไม่พบไฟล์บทพูด: " + DB_PATH)
		return
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(DB_PATH))
	if parsed is Dictionary:
		_db = parsed
	else:
		push_error("ไฟล์ dialogues.json รูปแบบไม่ถูกต้อง")

func get_entry(id: String) -> Dictionary:
	return _db.get(id, {})

func start(speaker: String, lines: Array) -> void:
	if lines.is_empty():
		return
	_lines = lines
	_index = 0
	active = true
	_start_frame = Engine.get_process_frames()
	name_label.text = speaker
	name_label.visible = speaker != ""
	panel.show()
	_show_line()

func _show_line() -> void:
	text_label.text = str(_lines[_index])
	text_label.visible_ratio = 0.0
	hint_label.text = "▼ [E]"
	if _tween:
		_tween.kill()
	var duration := maxf(0.2, text_label.get_total_character_count() / CHARS_PER_SECOND)
	_tween = create_tween()
	_tween.tween_property(text_label, "visible_ratio", 1.0, duration)

func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return
	# ข้ามการกดที่เป็นครั้งเดียวกับที่เปิดกล่องข้อความ
	if Engine.get_process_frames() == _start_frame:
		return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		if text_label.visible_ratio < 1.0:
			if _tween:
				_tween.kill()
			text_label.visible_ratio = 1.0
		else:
			_next()

func _next() -> void:
	_index += 1
	if _index >= _lines.size():
		_close()
	else:
		_show_line()

func _close() -> void:
	active = false
	panel.hide()
	finished.emit()
