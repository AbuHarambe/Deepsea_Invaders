extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# Check if the Area2D that entered belongs to an enemy
	if body.get_parent().is_in_group("enemies"):
		# Get the enemy's main script/node (assuming the enemy's root is a CharacterBody2D)
		var enemy_node = body.get_parent() 
		print("area entered")
		# Call the function on the enemy to set its state to TRUE
		enemy_node.set_scanner_state(true)

func _on_body_exited(body: Node2D) -> void:
	# Check if the Area2D that exited belongs to an enemy
	if body.get_parent().is_in_group("enemies"):
		var enemy_node = body.get_parent()
		print("area exited")
		# Call the function on the enemy to set its state to FALSE
		enemy_node.set_scanner_state(false)
