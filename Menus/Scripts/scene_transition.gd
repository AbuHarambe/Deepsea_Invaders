extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Referenz auf den AnimationPlayer, damit wir ihn ansprechen können
@onready var animation_player = $AnimationPlayer

# Diese Funktion rufen wir von unserem Menü aus auf.
func fade_to_scene(scene_path):
	# Starte die "fade_out" Animation (wird schwarz)
	animation_player.play("fade_out")
	
	# WICHTIG: Warte, bis die Animation fertig ist.
	# "await" ist wie ein "warten" in Java, ohne den Thread zu blockieren.
	await animation_player.animation_finished
	
	# Erst DANACH die Szene wechseln
	get_tree().change_scene_to_file(scene_path)
	
	# Sobald die neue Szene geladen ist (was einen Frame dauert),
	# spiele die "fade_in" Animation ab, um sie einzublenden.
	animation_player.play("fade_in")
