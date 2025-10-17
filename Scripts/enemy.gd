extends CharacterBody2D

# @export makes the variables show up on the right menu in Godot called Inspector
@export var speed = 400
@export var acceleration: float = 1800.0 # How quickly the player reaches max speed
@export var friction: float = 1400.0 # How quickly the player slows down 
@export var damage = 10

# allows this script to access the properties of Player
@onready var player = get_tree().get_first_node_in_group("player_group")

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
		
	
	
	if target_direction:
		var target_velocity = target_direction * speed
		# Use move_toward to move current velocity towards target velocity
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		# Player is NOT providing input: Apply friction (gradual deceleration)
		# Use move_toward to move velocity toward Vector2.ZERO
		# This creates the "sliding" or "floating" stop
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
	#moves the body based on the velocity set above
	move_and_slide()
	if get_slide_collision_count() > 0:
		_handle_specific_collision()

# Player.gd (or Enemy.gd)

func _handle_specific_collision():
	# Loop through all collisions that occurred this frame
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var hit_body = collision.get_collider()
		
		# Check if the body belongs to the group you want to identify
		if hit_body.is_in_group("player_group"):
			
			print("collision detected")
			player.take_damage(damage)
			return # Stop after processing the specific collision
