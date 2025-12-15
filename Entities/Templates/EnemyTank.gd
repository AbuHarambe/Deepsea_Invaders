extends BaseMeleeBlubblub

@export_group("Tank Settings")
@export var knockback_force: float = 500.0

# Wir überschreiben die Kollisions-Funktion aus deinem Base-Skript
func _handle_specific_collision():
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var hit_body = collision.get_collider()
		
		if hit_body.is_in_group("player_group"):
			# Schaden machen (nutzt 'damage' aus Base)
			if hit_body.has_method("take_damage"):
				hit_body.take_damage(damage)
			
			# RÜCKSTOSS: Wenn der Spieler eine Velocity hat oder eine Funktion dafür
			if hit_body is CharacterBody2D:
				var knockback_dir = (hit_body.global_position - global_position).normalized()
				# Angenommen der Player hat eine Variable 'velocity' oder function 'apply_knockback'
				# Hier ein einfacher direkter Push, falls dein Player das zulässt:
				hit_body.velocity += knockback_dir * knockback_force
			return
