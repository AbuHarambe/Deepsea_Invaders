extends CharacterBody2D

# @export makes the variables show up on the right menu in Godot called Inspector
@export var speed = 600
@export var max_health: int = 100
var current_health: int = 0

var boundary_top_left = Vector2.ZERO
var boundary_bottom_right = Vector2.ZERO

#_ready is called when the node enters the scene tree for the first time
func _ready() -> void:
	current_health = max_health
	
	pass

#_process is called every frame. Delta is the elapsed time since the last frame
func _physics_process(delta: float) -> void:
	# maps directional inputs into a vector called direction
	var direction = Input.get_vector("Left", "Right", "Up", "Down")
	velocity = direction * speed
	#moves the body based on the velocity set above
	move_and_slide()

func handle_death():
	#for now just print the msg later on play sound and so on
	print("Player Defeated.")
	#removes the player from the game
	queue_free()

 #clamps position to camera view
func clamp_postion():
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
