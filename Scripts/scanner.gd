extends Area2D

var entered_times: Dictionary = {}

# We will check the time for all tracked enemies every physics frame
func _physics_process(delta: float) -> void:
	# We must iterate over a copy of the keys to safely modify the dictionary (by erasing keys)
	for enemy_node in entered_times.keys().duplicate(): 
		# Get the entry time
		var entry_time_ms = entered_times.get(enemy_node, 0)
		var current_time_ms = Time.get_ticks_msec()
		
		var time_inside_s = (current_time_ms - entry_time_ms) / 1000.0
		
		# We need the enemy's goal time, which is stored in its script
		# Check if the node is still valid (it might have been deleted elsewhere)
		if is_instance_valid(enemy_node):
			
			# Safely cast and get the goal difficulty
			var enemy: CharacterBody2D = enemy_node as CharacterBody2D
			var goal_time = enemy.scan_difficulty
			
			# 1. Calculate the Progress Ratio (0.0 to 1.0)
			var progress_ratio = min(time_inside_s / goal_time, 1.0)
			
			# 2. 💡 NEW LOGIC: Update the Enemy's Visual Bar
			enemy.update_scan_progress(progress_ratio)
			
			# 💡 Diagnostic Print Statement (for troubleshooting)
			# print("Area2D calculated ratio: ", progress_ratio) 

			if time_inside_s >= goal_time:
				# 🚨 GOAL MET: Perform the successful action and remove the key! 🚨
				print("Goal Met: Deleting Enemy ", enemy.name, " after ", time_inside_s, "s.")
				
				# Optional: Set the bar to 100% just before deletion
				enemy.update_scan_progress(1.0) 
				
				enemy.queue_free() # Enemy deletes itself
				entered_times.erase(enemy_node) # Stop tracking the deleted enemy
			
		else:
			# Clean up the dictionary if the node was deleted another way
			entered_times.erase(enemy_node)


# Keep your entry function the same
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		var enemy_node: CharacterBody2D = body as CharacterBody2D
		if enemy_node:
			enemy_node.set_scanner_state(true)
			entered_times[enemy_node] = Time.get_ticks_msec() 

# Keep your exit function simple for cleanup
func _on_body_exited(body: Node2D) -> void:
	var enemy_node: CharacterBody2D = body as CharacterBody2D
	if enemy_node:
		enemy_node.set_scanner_state(false)
		# We don't need to check the time here anymore, just stop tracking!
		if entered_times.has(enemy_node):
			print("Enemy exited before goal. Stopping track.")
			entered_times.erase(enemy_node)
