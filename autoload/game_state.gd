extends Node
## สถานะเกมกลาง (Autoload ชื่อ GameState)
## เก็บ flag ว่าทำอะไรไปแล้ว ไอเท็มที่ผู้เล่นมี และค่าทั่วไป ใช้ได้จากทุกฉาก
## ตัวอย่าง: GameState.has_item("key"), GameState.has_flag("read_note"),
##          GameState.get_value("chosen_door", "")

signal item_added(item_id: String)
signal item_removed(item_id: String)
signal flag_changed(flag: String, value: bool)

var flags: Dictionary = {}
var values: Dictionary = {}
var items: Array[String] = []

func set_flag(flag: String, value: bool = true) -> void:
	flags[flag] = value
	flag_changed.emit(flag, value)

func has_flag(flag: String) -> bool:
	return flags.get(flag, false)

func set_value(key: String, value: Variant) -> void:
	values[key] = value

func get_value(key: String, default: Variant = null) -> Variant:
	return values.get(key, default)

func add_item(item_id: String) -> void:
	if item_id in items:
		return
	items.append(item_id)
	item_added.emit(item_id)

func remove_item(item_id: String) -> void:
	if item_id in items:
		items.erase(item_id)
		item_removed.emit(item_id)

func has_item(item_id: String) -> bool:
	return item_id in items
