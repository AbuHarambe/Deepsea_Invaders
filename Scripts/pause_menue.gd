extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_fortsetzen_pressed() -> void:
# 1. Das Spiel fortsetzen
	print("Es wird fortgesetzt!")
	get_tree().paused = false
	# 2. Das Pausenmenü aus der Szene entfernen (es zerstört sich selbst)
	queue_free()


func _on_neustart_pressed() -> void:
	# WICHTIG: Immer zuerst un-pausen, bevor man die Szene wechselt!
	get_tree().paused = false
	
	# Hole den Pfad der aktuell laufenden Szene und lade sie neu
	var current_scene_path = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file(current_scene_path)


func _on_wiki_platzhalter_pressed() -> void:
	print("Wiki (Platzhalter) geöffnet")


func _on_zum_hauptmenü_pressed() -> void:
	# WICHTIG: Immer zuerst un-pausen!
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menue.tscn")
