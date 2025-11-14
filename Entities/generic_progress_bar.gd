# File: Generic_ProgressBar.gd
extends ProgressBar
class_name GenericProgressBar

# This is the speed at which the bar visually updates its value
@export var update_speed: float = 8.0 

# ==============================================================================
# 1. CORE VARIABLES
# ==============================================================================

# Internal variable to track the smooth visual value (The bar's actual position)
var visual_value: float = 0.0 

# Internal variable to track the target value set by game logic
var target_value: float = 0.0 


# ==============================================================================
# 2. LIFECYCLE
# ==============================================================================

func _ready() -> void:
	# Initialize both tracking variables based on the value set in the editor
	visual_value = value
	target_value = value
	
	# Ensure the minimum value is 0 (standard for a progress bar)
	min_value = 0.0

func _process(delta: float) -> void:
	# Smoothly move the visual value toward the target value
	visual_value = lerp(visual_value, target_value, delta * update_speed)
	
	# Update the built-in ProgressBar 'value' property every frame
	value = visual_value

# ==============================================================================
# 3. PUBLIC SETTER METHOD
# ==============================================================================

# This is the method external scripts (like BaseEnemy.gd) should call.
# progress_ratio should be a value between 0.0 (empty) and 1.0 (full).
func set_progress(progress_ratio: float) -> void:
	
	# 1. Clamp the input ratio to ensure it's valid
	var clamped_ratio = clampf(progress_ratio, 0.0, 1.0) 
	
	# 2. Calculate the new target value based on the ProgressBar's max_value
	# The max_value property must be set in the editor (e.g., to 100)
	target_value = max_value * clamped_ratio 
	
	# Optional: Snap the visual value instantly if the progress is dropping to zero quickly, 
	# preventing the slow decay from the previous value.
	if target_value < visual_value and target_value == 0:
		visual_value = target_value
