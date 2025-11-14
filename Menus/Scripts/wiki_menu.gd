extends Control

func _ready() -> void:
	add_to_group("wiki_menu")

func _on_button_pressed() -> void:
	queue_free()

func get_overlay() -> Node:
	return $Overlay
