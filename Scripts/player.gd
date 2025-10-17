extends CharacterBody2D

# @export makes the variables show up on the right menu in Godot called Inspector
@export var speed = 600
@export var acceleration: float = 1800.0 # How quickly the player reaches max speed
@export var friction: float = 1400.0 # How quickly the player slows down 
@export var max_health: int = 100

@onready var health_bar = get_tree().get_first_node_in_group("progress_bars")

var current_health: int = 0

var boundary_top_left = Vector2.ZERO
var boundary_bottom_right = Vector2.ZERO

#_ready is called when the node enters the scene tree for the first time
func _ready() -> void:
	current_health = max_health
	
	# Check if the health_bar reference is valid
	if is_instance_valid(health_bar):
		# 🎯 FIX: Defer the call to init_health()
		# This ensures that the HealthBar's @onready variables (timer and damage_bar)
		# have fully initialized BEFORE we try to use them.
		health_bar.call_deferred("init_health", current_health)
	
	pass

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
		
	#moves the body based on the velocity set above
	move_and_slide()
	clamp_position()

func handle_death():
	#for now just print the msg later on play sound and so on
	print("Player Defeated.")
	#removes the player from the game
	queue_free()

 #clamps position to camera view
func clamp_position():
	if boundary_top_left != Vector2.ZERO and boundary_bottom_right != Vector2.ZERO:
		
		# Clamp X position between the left and right boundary edges
		global_position.x = clamp(
			global_position.x, 
			boundary_top_left.x, 
			boundary_bottom_right.x
		)
		
		# Clamp Y position between the top and bottom boundary edges
		global_position.y = clamp(
			global_position.y, 
			boundary_top_left.y, 
			boundary_bottom_right.y
		)

func take_damage (dmg):
	current_health = current_health - dmg
	health_bar.set_health(current_health)
