extends CanvasLayer
## ช่องเก็บของมุมซ้ายบน (Autoload ชื่อ Hud)
## แสดงไอคอนของไอเท็มที่ GameState มี ข้อมูลไอเท็มอยู่ที่ res://data/items.json
## เพิ่มไอเท็มใหม่: ใส่ id, name, icon ในไฟล์นั้น แล้วเรียก GameState.add_item("id")

const ITEMS_PATH := "res://data/items.json"
const ICON_SCALE := 2

var _items_db: Dictionary = {}

@onready var row: HBoxContainer = $Margin/Row

func _ready() -> void:
	if FileAccess.file_exists(ITEMS_PATH):
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(ITEMS_PATH))
		if parsed is Dictionary:
			_items_db = parsed
	GameState.item_added.connect(func(_id): _refresh())
	GameState.item_removed.connect(func(_id): _refresh())
	_refresh()

func _refresh() -> void:
	for child in row.get_children():
		child.queue_free()
	for item_id in GameState.items:
		var info: Dictionary = _items_db.get(item_id, {})
		var icon_path: String = info.get("icon", "")
		if icon_path == "" or not ResourceLoader.exists(icon_path):
			continue
		var tex := TextureRect.new()
		tex.texture = load(icon_path)
		tex.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tex.stretch_mode = TextureRect.STRETCH_KEEP
		tex.custom_minimum_size = tex.texture.get_size() * ICON_SCALE
		tex.tooltip_text = str(info.get("name", item_id))
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_SCALE
		row.add_child(tex)
