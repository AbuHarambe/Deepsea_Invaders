extends Node2D

@onready var hud_layer = $HUD_Layer
var pause_menu_scene = preload("res://Menus/Scenes/pause_menu.tscn")
var gameover_scene = preload("res://Menus/Scenes/gameover.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _enter_tree() -> void:
	add_to_group("main_scene")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
# In main.gd
func _game_over():
	var gameover_instance = gameover_scene.instantiate()
	hud_layer.add_child(gameover_instance)
	pass

func _unhandled_input(event):
	# Prüfen, ob die "ui_cancel"-Aktion gedrückt wurde (das ist Standard für Esc)
	if event.is_action_pressed("ui_cancel"):

		# Prüfen, ob das Spiel bereits pausiert ist (damit wir es nicht doppelt öffnen)
		if get_tree().paused:
			# Wenn es pausiert ist, wollen wir es nicht fortsetzen
			# (das soll nur der "Fortsetzen"-Button tun)
			return 

		# 1. Das Spiel pausieren!
		get_tree().paused = true

		# 2. Eine Instanz (Kopie) unseres Pausenmenüs erstellen
		var pause_instance = pause_menu_scene.instantiate()

		# 3. Das Menü zur aktuellen Szene hinzufügen
		hud_layer.add_child(pause_instance)
