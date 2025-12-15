extends Area2D

@export var damage: int = 15
@export var lifetime: float = 0.5 # Wie lange man die Explosion sieht

func _ready():
	# 1. Sofort Schaden machen beim Erscheinen
	explode()
	
	# 2. Nach kurzer Zeit löschen
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func explode():
	# Wir holen uns ALLE Körper, die gerade im Radius (CollisionShape) sind
	var bodies = get_overlapping_bodies()
	
	for body in bodies:
		if body.is_in_group("player_group"):
			if body.has_method("take_damage"):
				body.take_damage(damage)
