extends Node2D

# --- New Limit Property ---
## Maximum number of enemies allowed on screen at one time.
@export var MAX_ENEMIES_ON_SCREEN: int = 8 

# --- Editable Properties in the Inspector ---
@export var DIVIDE_X_POS: float = 500.0
@export var player_node: Node2D
@export var spawn_interval: float = 2.0

# --- Enemy Pools ---
@export var ENEMY_POOL_A: Array[PackedScene] = []
@export var ENEMY_POOL_B: Array[PackedScene] = []

# --- Internal Variables ---
var spawn_timer: Timer

func _ready():
	# 1. Error check for empty pools
	if ENEMY_POOL_A.is_empty() and ENEMY_POOL_B.is_empty():
		push_error("Both enemy pools are empty. Spawner will not work.")
		set_process(false)
		return

	# 2. Set up the spawn timer
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	print(spawn_timer.time_left)

func _on_spawn_timer_timeout():
	print("timer timeout")
	if is_instance_valid(player_node):
		
		# --- NEW: Check the enemy count before spawning ---
		if get_tree().get_nodes_in_group("enemies").size() >= MAX_ENEMIES_ON_SCREEN:
			# Stop spawning if the limit is reached
			print("Enemy limit reached (" + str(MAX_ENEMIES_ON_SCREEN) + "). Stopping spawn for now.")
			return # Exit the function, skip spawning
		
		spawn_enemy()
	else:
		spawn_timer.stop()

# --- Core Spawning Logic ---

func spawn_enemy():
	print("trying to spawn enemy")
	var current_pool: Array[PackedScene] = []
	
	# [Rest of pool selection logic remains the same]
	if player_node.global_position.x < DIVIDE_X_POS:
		current_pool = ENEMY_POOL_A
	else:
		current_pool = ENEMY_POOL_B
	
	if current_pool.is_empty():
		# Fallback logic...
		if current_pool == ENEMY_POOL_A and not ENEMY_POOL_B.is_empty():
			current_pool = ENEMY_POOL_B
		elif current_pool == ENEMY_POOL_B and not ENEMY_POOL_A.is_empty():
			current_pool = ENEMY_POOL_A
		else:
			print("No enemies available to spawn.")
			return

	var enemy_scene = current_pool[randi() % current_pool.size()]
	var enemy_instance = enemy_scene.instantiate()
	var spawn_pos = determine_spawn_position(player_node.global_position)
	
	enemy_instance.global_position = spawn_pos
	
	# ----------------------------------------------------
	# IMPORTANT: The Enemy MUST be added to the "enemies" Group!
	# ----------------------------------------------------
	# NOTE: It is best practice to add the group in the Enemy's scene file, 
	# but we can also do it here for completeness:
	if not enemy_instance.is_in_group("enemies"):
		enemy_instance.add_to_group("enemies")
	
	get_parent().add_child(enemy_instance)
	
	print("Spawned enemy from pool: " + ("A" if current_pool == ENEMY_POOL_A else "B") + 
		  ". Current count: " + str(get_tree().get_nodes_in_group("enemies").size()))

# --- Utility Function for Spawn Position (Remains the same) ---

func determine_spawn_position(player_pos: Vector2) -> Vector2:
	var distance = randf_range(800, 1000)
	var angle = randf() * TAU
	
	var offset = Vector2(cos(angle), sin(angle)) * distance
	return player_pos + offset
