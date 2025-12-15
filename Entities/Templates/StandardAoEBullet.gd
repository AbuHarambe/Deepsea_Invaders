extends Area2D

@export var speed: float = 400.0
@export var explosion_scene: PackedScene # WICHTIG: Hier ziehst du 'AoE_Explosion.tscn' rein!

var velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	position += velocity * delta

func _on_body_entered(body: Node2D) -> void:
	# Egal was wir treffen (Spieler oder Wand), wir explodieren!
	# (Außer wir treffen den Gegner selbst, das wäre doof)
	if not body.is_in_group("enemy_group"):
		spawn_explosion()
		queue_free() # Kugel weg

func spawn_explosion():
	if explosion_scene:
		var explosion = explosion_scene.instantiate()
		# Explosion in die Welt setzen (nicht als Kind der Kugel, die wird ja gelöscht!)
		get_parent().add_child(explosion)
		explosion.global_position = global_position
