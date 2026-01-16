extends Node
var data: Array = []

func _ready() -> void:
	var file := FileAccess.open("res://Assets/Data/wiki_data.json", FileAccess.READ)
	if file:
		data = JSON.parse_string(file.get_as_text())

func get_entry(ID: String) -> Dictionary:
	for entry in data:
		if entry.get("ID") == ID:
			return entry
	return {}
