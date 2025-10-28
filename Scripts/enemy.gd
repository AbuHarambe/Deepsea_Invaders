extends CharacterBody2D

# @export makes the variables show up on the right menu in Godot called Inspector
@export var max_speed = 400
@export var acceleration: float = 1800.0 # How quickly the player reaches max speed
@export var friction: float = 1400.0 # How quickly the player slows down 
@export var damage = 10
@export var rotation_speed = 10.0
@export var scan_difficulty: float = 2.0 # This is the goal time inside the scanner (was goal_time_inside)

# allows this script to access the properties of Player
@onready var sprite_node = $Sprite2D
@onready var hurtbox_node = $CollisionShape2D
@onready var player = get_tree().get_first_node_in_group("player_group")
@onready var scanner_bar = $ScanProgressBar

# Const PI is 3.14159... (180 degrees)
const PI_FLIP = PI  
# Start with -PI/2 to fix the 90 degree alignment
const UP_AXIS_OFFSET = -PI / 2.0

var in_scanner = false

#_ready is called when the node enters the scene tree for the first time
func _ready() -> void:
	pass

#_process is called every frame. Delta is the elapsed time since the last frame
func _physics_process(delta: float) -> void:
	
	var target_direction = Vector2.ZERO
	
	# maps a vector leading to player coordinates
	if is_instance_valid(player):
		var player_position: Vector2 = player.global_position
		target_direction = (player_position - global_position).normalized() 
		
	var speed = max_speed
	if in_scanner:
		# Enemy slows down when detected
		speed = max_speed / 2
	
	#moves enemy towards vector target_direction
	if target_direction:
		var target_velocity = target_direction * speed
		# Use move_toward to move current velocity towards target velocity
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		# Player is NOT providing input: Apply friction (gradual deceleration)
		# Use move_toward to move velocity toward Vector2.ZERO
		# This creates the "sliding" or "floating" stop
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
		# rotation mechancic
	if velocity.length_squared() > 1.0: 
		
		# 1. Start with the vector's angle
		var target_rotation = velocity.angle()
		
		# 2. Add the 90-degree offset to align the sprite (e.g., UP)
		target_rotation += UP_AXIS_OFFSET 
		
		# 3. ADD THE 180 DEGREE FLIP
		target_rotation += PI_FLIP 
		
		# 4. Smoothly rotate the nodes
		sprite_node.rotation = lerp_angle(
			sprite_node.rotation, 
			target_rotation, 
			delta * rotation_speed # This changes the speed of rotation
		)
		hurtbox_node.rotation = lerp_angle(
			hurtbox_node.rotation, 
			target_rotation, 
			delta * rotation_speed # This changes the speed of rotation
		)
		
	#moves the body based on the velocity set above
	move_and_slide()
	if get_slide_collision_count() > 0:
		_handle_specific_collision()

# state maching for scan
func set_scanner_state(is_in_scanner: bool):
	in_scanner = is_in_scanner
	# print("Enemy is now in_scanner: ", in_scanner) # Optional: Debug output

func _handle_specific_collision():
	# Loop through all collisions that occurred this frame
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var hit_body = collision.get_collider()
		
		# Check if the body belongs to the group you want to identify
		if hit_body.is_in_group("player_group"):
			
			player.take_damage(damage)
			return # Stop after processing the specific collision

func update_scan_progress(progress_ratio: float) -> void:
	if is_instance_valid(scanner_bar):
		# This still calls the correct function on the bar's script
		scanner_bar.update_progress(progress_ratio)
