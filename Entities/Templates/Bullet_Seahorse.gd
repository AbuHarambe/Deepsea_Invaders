extends Area2D

var velocity = Vector2.ZERO
var damage = 10

func _physics_process(delta):
	position += velocity * delta

# Wenn die Kugel etwas trifft
func _on_body_entered(body):
	if body.is_in_group("player_group"): 
		body.take_damage(damage)
		queue_free() # Kugel zerstören
	elif not body.is_in_group("enemy_group"): 
		queue_free() # An Wänden zerstören
