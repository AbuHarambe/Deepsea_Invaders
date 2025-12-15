extends BaseRangedBlubblub

@export_group("Rapid Fire Settings")
@export var ammo_scene: PackedScene
@export var burst_count: int = 3
@export var time_between_shots: float = 0.15
@export var burst_cooldown: float = 2.0
@export var spread_angle: float = 15.0 # Grad
@export var projectile_speed: float = 400.0

var cooldown_timer: float = 0.0

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	cooldown_timer -= delta
	
	if cooldown_timer <= 0 and is_instance_valid(player):
		# Prüfen ob Player in Reichweite (optional, da BaseRanged das Kiting macht)
		if global_position.distance_to(player.global_position) <= max_distance_player:
			fire_burst()

func fire_burst():
	cooldown_timer = 999.0 # Blockieren während des Bursts
	
	for i in range(burst_count):
		if not is_instance_valid(player): break
		
		shoot_one_bullet()
		await get_tree().create_timer(time_between_shots).timeout
	
	cooldown_timer = burst_cooldown

func shoot_one_bullet():
	var projectile = ammo_scene.instantiate()
	get_parent().add_child(projectile)
	projectile.global_position = global_position
	
	# Richtung zum Player + Zufall
	var dir = (player.global_position - global_position).normalized()
	var angle_rand = deg_to_rad(randf_range(-spread_angle, spread_angle))
	var final_dir = dir.rotated(angle_rand)
	
	projectile.velocity = final_dir * projectile_speed
	projectile.rotation = final_dir.angle()
