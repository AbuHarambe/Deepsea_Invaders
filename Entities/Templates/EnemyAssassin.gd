extends BaseMeleeBlubblub

@export_group("Assassin Settings")
@export var dash_speed: float = 800.0
@export var dash_duration: float = 0.3
@export var prepare_time: float = 0.5
@export var attack_range: float = 150.0
@export var attack_cooldown: float = 2.0

@export var knockback_force: float = 500.0
var is_attacking: bool = false
var attack_timer: float = 0.0

func _physics_process(delta: float) -> void:
	# Cooldown verwalten
	if attack_timer > 0:
		attack_timer -= delta
	
	# Wenn wir nicht angreifen, ganz normale Base-Logik ausführen
	if not is_attacking:
		super._physics_process(delta) # Ruft _physics_process vom BaseMelee auf
		
		# Prüfen ob wir angreifen können
		if is_instance_valid(player) and attack_timer <= 0:
			if global_position.distance_to(player.global_position) < attack_range:
				start_dash_attack()
	else:
		# Während des Angriffs kümmern wir uns selbst um Bewegung/Rotation
		move_and_slide()
		_update_scan_state(delta) # Scannen soll trotzdem weiterlaufen

func start_dash_attack():
	is_attacking = true
	velocity = Vector2.ZERO # Kurz stehenbleiben
	
	# 1. Vorbereitung (Telegraphing) - z.B. rot blinken
	var original_modulate = sprite_node.modulate
	sprite_node.modulate = Color.RED
	await get_tree().create_timer(prepare_time).timeout
	
	# 2. Der Dash
	if is_instance_valid(player):
		var dash_dir = (player.global_position - global_position).normalized()
		velocity = dash_dir * dash_speed
		sprite_node.modulate = original_modulate
		
		await get_tree().create_timer(dash_duration).timeout
		
	# 3. Reset
	velocity = Vector2.ZERO
	is_attacking = false
	attack_timer = attack_cooldown
	
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
