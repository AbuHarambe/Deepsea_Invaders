extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_optionen_pressed() -> void:
	print("Öffne Optionen!")
	get_tree().change_scene_to_file("res://Scenes/options_menue.tscn")


func _on_quit_pressed() -> void:
	# Dieser Befehl beendet das Spiel
	get_tree().quit()


func _on_wiki_pressed() -> void:
	pass # Replace with function body.


func _on_start_pressed() -> void:
	print("Spiel starten!")
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
