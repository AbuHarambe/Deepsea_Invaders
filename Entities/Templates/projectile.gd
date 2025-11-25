extends Area2D

var velocity = Vector2.ZERO
var damage = 10

func _physics_process(delta):
	position += velocity * delta

func _on_body_entered(body):
	if body.is_in_group("player_group"): # Stelle sicher, dass dein Player in dieser Gruppe ist
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free() # Kugel löschen
	elif not body.is_in_group("enemy_group"): # Damit sie nicht an anderen Gegnern zerschellt
		queue_free() # An Wänden löschen
