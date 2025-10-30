# scanner_progress_bar.gd (Attached to your ProgressBar node)
extends ProgressBar

# Remove the entire _process function!
# func _process(delta: float) -> void:
#     ... (The logic here is now handled below)

# Called by the Area2D (C) with the calculated progress
func update_progress(ratio: float) -> void:
	# 1. Update the bar value
	# Ensure the value is clamped between 0.0 and 1.0
	self.value = clampf(ratio, 0.0, 1.0)
	
	# 2. Control visibility based on the desired state:
	
	# Option A: Visible only when actively filling (0 < value < 1.0)
	#self.visible = ratio > 0.0 and ratio < 1.0
	
	# --- OR ---
	
	# Option B: Visible as long as the enemy is being tracked (value > 0.0)
	# This keeps the bar visible at 100% until the enemy is deleted.
	#self.visible = ratio > 0.0 
	
	# Let's stick with the 'active filling' logic (Option A) for now.
