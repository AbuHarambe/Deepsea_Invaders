# File: BaseEnemy.gd
extends CharacterBody2D
class_name BaseMeleeBlubblub # Gives the class a reusable name for type checking and exporting

# ==============================================================================
# 1. ENEMY STATS & EXPORTS (REUSABLE)
# ==============================================================================
@export var image: Texture2D:
	set(value):
		image = value
		var sprite := get_node_or_null("Sprite2D")
		if sprite:
			sprite.texture = value
	get:
		return image
@export var max_speed: float = 250.0
@export var acceleration: float = 1800.0
@export var friction: float = 1400.0 
@export var damage: int = 10
@export var rotation_speed: float = 10.0
@export var scan_difficulty: float = 2.0 # Time goal to bubble away
@export_group("Scan Decay Settings")
@export var scan_decay_rate: float = 0.5 
@export var scan_decay_delay: float = 1.0
@export var scanner_slow_factor: float = 2.0



# ==============================================================================
# 2. STATE AND NODES (REUSABLE)
# ==============================================================================
@onready var sprite_node = $Sprite2D
@onready var hurtbox_node = $CollisionShape2D
@onready var player = get_tree().get_first_node_in_group("player_group")
@onready var scanner_bar = $ScanProgressBar

# Rotation Constants
const PI_FLIP = PI
const UP_AXIS_OFFSET = -PI / 2.0

var in_scanner: bool = false
var current_scan_progress: float = 0.0 # New variable for tracking progress
var time_outside_scanner: float = 0.0 # New variable for tracking decay delay


# ==============================================================================
# 3. CORE LIFECYCLE (REUSABLE)
# ==============================================================================
func _physics_process(delta: float) -> void:
	
	# 3a. MOVEMENT (Targeting the Player)
	_apply_movement(delta)
	
	# 3b. SCAN PROGRESS AND DECAY (New Logic)
	_update_scan_state(delta)
	
	# 3c. MOVEMENT EXECUTION & ROTATION
	_apply_rotation(delta)
	move_and_slide()
	
	# 3d. COLLISION CHECK
	if get_slide_collision_count() > 0:
		_handle_specific_collision()

# ==============================================================================
# 4. CORE MECHANIC IMPLEMENTATIONS (REUSABLE FUNCTIONS)
# ==============================================================================

# Handles movement acceleration/friction and slow-down when scanned
func _apply_movement(delta: float):
	var target_direction = Vector2.ZERO
	
	if is_instance_valid(player):
		var player_position: Vector2 = player.global_position
		target_direction = (player_position - global_position).normalized()
		
	var current_speed = max_speed
	if in_scanner:
		current_speed = max_speed / scanner_slow_factor
	
	if target_direction:
		var target_velocity = target_direction * current_speed
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

# Handles the movement-based rotation of the visuals/hurtbox
func _apply_rotation(delta: float):
	if velocity.length_squared() > 1.0:
		var target_rotation = velocity.angle() + UP_AXIS_OFFSET + PI_FLIP
		
		sprite_node.rotation = lerp_angle(
			sprite_node.rotation,
			target_rotation,
			delta * rotation_speed
		)
		hurtbox_node.rotation = lerp_angle(
			hurtbox_node.rotation,
			target_rotation,
			delta * rotation_speed
		)
		
# Handles hard collision with the player
func _handle_specific_collision():
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var hit_body = collision.get_collider()
		
		if hit_body.is_in_group("player_group"):
			player.take_damage(damage)
			return

# === SCANNER LOGIC (NEW CORE IMPLEMENTATION) ===
# This function tracks the scan progress, decay, and removal
func _update_scan_state(delta: float):
	
	if in_scanner:
		# 1. Progress: Increase progress when in scanner
		current_scan_progress += delta
		# Reset decay timer
		time_outside_scanner = 0.0 
	else:
		# 2. Decay: Start decay timer when outside scanner
		if current_scan_progress > 0.0:
			time_outside_scanner += delta
			
			# Apply decay only after the delay has passed
			if time_outside_scanner >= scan_decay_delay:
				# Decay at a rate proportional to scan_decay_rate
				var decay_amount = delta * scan_decay_rate
				current_scan_progress = max(0.0, current_scan_progress - decay_amount)
	
	# 3. Check for completion
	if current_scan_progress >= scan_difficulty:
		_bubble_away()
		return
		
	# 4. Update the progress bar visually
	var progress_ratio = current_scan_progress / scan_difficulty
	update_scan_progress(progress_ratio)

# Callable function from the Scanner Area2D
func set_scanner_state(is_in_scanner: bool):
	in_scanner = is_in_scanner

# Function to be overridden by child classes for unique removal effects
func _bubble_away():
	# Placeholder for the "bubble away" animation/sound
	print(name, " has been bubbled away!")
	# Notify manager to update enemy count
	get_tree().call_group("game_manager_group", "on_enemy_bubbled") 
	queue_free()

# Function to update the visual bar (assuming it's a separate script)
func update_scan_progress(progress_ratio: float) -> void:
	if is_instance_valid(scanner_bar):
		scanner_bar.update_progress(progress_ratio)
