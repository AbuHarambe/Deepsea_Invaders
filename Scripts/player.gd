extends CharacterBody2D

# @export makes the variables show up on the right menu in Godot called Inspector
@export var speed = 600
@export var rotation_speed = 10.0
@export var acceleration: float = 1800.0 # How quickly the player reaches max speed
@export var friction: float = 1400.0 # How quickly the player slows down 
@export var max_health: int = 100

# @onready calls are established the second the scene is loaded
@onready var scanner_node = $Scanner
@onready var animation_player = $Scanner/Sprite/AnimationPlayer
@onready var sprite_node = $Sprite
@onready var hurtbox_node = $Hurtbox
@onready var health_bar = get_tree().get_first_node_in_group("progress_bars")

var current_health: int = 0

# Const PI is 3.14159... (180 degrees)
const PI_FLIP = PI  
# Start with -PI/2 to fix the 90 degree alignment
const UP_AXIS_OFFSET = -PI / 2.0

#_ready is called when the node enters the scene tree for the first time
func _ready() -> void:
	current_health = max_health
	
	# Check if the health_bar reference is valid
	if is_instance_valid(health_bar):
		# 🎯 FIX: Defer the call to init_health()
		# This ensures that the HealthBar's @onready variables (timer and damage_bar)
		# have fully initialized BEFORE we try to use them.
		health_bar.call_deferred("init_health", current_health)
	
	animation_player.play("Idle")

#_process is called every frame. Delta is the elapsed time since the last frame
func _physics_process(delta: float) -> void:
	# maps directional inputs into a vector called direction
	var input_direction = Input.get_vector("Left", "Right", "Up", "Down")
	
	if input_direction:
		# Player is providing input: Accelerate towards the target velocity
		var target_velocity = input_direction * speed
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
		
		# 3. 🚨 ADD THE 180 DEGREE FLIP 🚨
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

func _process(delta: float) -> void:
	if is_instance_valid(scanner_node):
		_rotate_scanner_to_mouse()
		
func _rotate_scanner_to_mouse():
	var mouse_world_pos = get_global_mouse_position()
	
	# Calculate the vector pointing FROM the scanner TO the mouse
	var direction_vector = mouse_world_pos - global_position 
	
	# Calculate the angle of that vector
	var target_angle = direction_vector.angle()
	
	# 1. Apply the 90-degree offset for alignment
	target_angle += UP_AXIS_OFFSET 
	
	# 2. 🚨 FINAL FIX: Add the 180-degree flip 🚨
	target_angle += PI_FLIP 
	
	# Apply the rotation
	scanner_node.rotation = target_angle


func handle_death():
	#for now just print the msg later on play sound and so on
	print("Player Defeated.")
	#removes the player from the game
	queue_free()

func take_damage (dmg):
	current_health = current_health - dmg
	health_bar.set_health(current_health)
