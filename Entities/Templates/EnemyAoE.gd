extends BaseRangedBlubblub

@export_group("AoE Attack Settings")
@export var projectile_scene: PackedScene # Hier den AirRing reinziehen
@export var attack_cooldown: float = 3.0
@export var ring_speed: float = 250.0

var current_cooldown: float = 0.0

func _physics_process(delta: float) -> void:
	# 1. Die normale Bewegung vom Base-Skript ausführen
	super._physics_process(delta)
	
	# 2. Cooldown verwalten
	if current_cooldown > 0:
		current_cooldown -= delta
	
	# 3. Angriffs-Logik
	if is_instance_valid(player) and current_cooldown <= 0:
		# Nur schießen, wenn in Reichweite (nutzt Variable aus BaseRanged)
		var dist = global_position.distance_to(player.global_position)
		if dist <= max_distance_player:
			shoot_aoe_ring()

func shoot_aoe_ring():
	current_cooldown = attack_cooldown
	
	if projectile_scene:
		# Instanz erzeugen
		var ring = projectile_scene.instantiate()
		
		# Zur Welt hinzufügen (nicht zum Delfin, sonst bewegt sich der Ring mit dem Delfin mit!)
		get_parent().add_child(ring)
		
		# Startposition setzen (Mund des Delfins)
		ring.global_position = global_position
		
		# Richtung berechnen
		var dir = (player.global_position - global_position).normalized()
		
		# Dem Ring die Richtung geben (erwartet 'velocity' Variable im Ring-Skript)
		ring.velocity = dir * ring_speed
		
		# Rotation anpassen, damit der Ring in Flugrichtung schaut
		ring.rotation = dir.angle()
