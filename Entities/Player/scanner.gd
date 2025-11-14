extends Area2D

# Dictionary to track scan progress for all enemies.
# Stores: {EnemyNode: {"accumulated_time": float, "last_update_time_ms": int, "is_inside": bool, "decay_start_time_ms": int}}
var scan_targets: Dictionary = {}

# --- REMOVED CONSTANT: The DECAY_RATE is now read from the enemy script. ---

# --- Signal: When an enemy enters the area (START/RESUME SCAN) ---
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		var enemy_node: CharacterBody2D = body as CharacterBody2D
		
		if is_instance_valid(enemy_node):
			enemy_node.set_scanner_state(true)
			
			if scan_targets.has(enemy_node):
				# Enemy is re-entering: Resume tracking
				var data = scan_targets[enemy_node]
				data.is_inside = true
				data.last_update_time_ms = Time.get_ticks_msec()
				data["decay_start_time_ms"] = 0 # Reset delay timer
			else:
				# Enemy is entering for the first time: Initialize data
				scan_targets[enemy_node] = {
					"accumulated_time": 0.0,
					"last_update_time_ms": Time.get_ticks_msec(),
					"is_inside": true,
					"decay_start_time_ms": 0 # Initialize the new variable
				}

# --- Signal: When an enemy exits the area (PAUSE / START DECAY DELAY TIMER) ---
func _on_body_exited(body: Node2D) -> void:
	var enemy_node: CharacterBody2D = body as CharacterBody2D
	
	if enemy_node and scan_targets.has(enemy_node):
		enemy_node.set_scanner_state(false)
		
		var data = scan_targets[enemy_node]
		data.is_inside = false
		data.last_update_time_ms = Time.get_ticks_msec()
		
		# 💡 NEW: Record the exact time the enemy exited to begin the pause delay
		data.decay_start_time_ms = Time.get_ticks_msec()


# --- Core Logic: Continuous Update and Decay ---
func _physics_process(delta: float) -> void:
	for enemy_node in scan_targets.keys().duplicate(): 
		
		if not is_instance_valid(enemy_node):
			scan_targets.erase(enemy_node)
			continue
			
		var enemy: CharacterBody2D = enemy_node as CharacterBody2D
		var data = scan_targets[enemy_node]
		
		# 💡 NEW: Fetch customizable parameters from the enemy script
		var goal_time = enemy.scan_difficulty
		var enemy_decay_rate = enemy.scan_decay_rate
		var enemy_decay_delay = enemy.scan_decay_delay 
		
		# Calculate time elapsed since the last physics frame check
		var current_time_ms = Time.get_ticks_msec()
		var delta_time_s = (current_time_ms - data.last_update_time_ms) / 1000.0
		data.last_update_time_ms = current_time_ms # Reset for the next frame

		# --- PROGRESS ACCUMULATION / DECAY LOGIC ---
		if data.is_inside:
			# If inside: ADD time
			data.accumulated_time += delta_time_s
			
		else:
			# If outside: Check if the decay delay has passed
			var time_outside_s = (current_time_ms - data.decay_start_time_ms) / 1000.0
			
			if time_outside_s >= enemy_decay_delay:
				# Decay delay is over: SUBTRACT time (decay)
				data.accumulated_time -= delta_time_s * enemy_decay_rate
				
			# else: progress is paused, doing nothing here.
			
		# Clamp the progress so it never goes below zero
		data.accumulated_time = max(0.0, data.accumulated_time)
		
		# --- UPDATE VISUALS AND CHECK GOAL ---
		
		var progress_ratio = min(data.accumulated_time / goal_time, 1.0)
		enemy.update_scan_progress(progress_ratio)
		
		if data.accumulated_time >= goal_time:
			print("Goal Met (Persistent): Deleting Enemy ", enemy.name)
			enemy.update_scan_progress(1.0) 
			enemy.queue_free() 
			scan_targets.erase(enemy_node)
