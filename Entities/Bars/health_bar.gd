# health_bar_script.gd (Attached to the main ProgressBar)
extends ProgressBar

# --- FIX 1: Rename references to match case/structure ---
# Godot paths are case-sensitive. If your node is named 'DamageBar', use that.
@onready var timer = $Health_Bar_Timer     # Correct path for direct child
@onready var damage_bar = $Damage_Bar       # Correct path for direct child

var health: int = 0 : set = set_health

func set_health(new_health: int) -> void:
	var prev_health = health
	health = min(max_value, new_health)
	value = health
	
	if is_instance_valid(timer):
		pass
	else:
		print("timer nicht gefunden")
	if is_instance_valid(damage_bar):
			pass
	else:
		print("damagebar nicht gefunden")
	
	
	if health < prev_health:
		if is_instance_valid(timer):
			timer.start()
		else:
			print("timer nicht gefunden")
	else:
		# If healed or unchanged, set damage bar instantly
		if is_instance_valid(damage_bar):
			damage_bar.value = health
		else:
			print("damage_bar nicht gefunden")

func init_health(max_hp: int) -> void:
	# --- FIX 2: Correctly assign local variable and properties ---
	
	# Correctly assign the argument to the instance variable
	health = max_hp
	
	# Assign max_hp to the ProgressBar's max_value property
	self.max_value = max_hp
	
	# Initialize the current display value
	self.value = max_hp
	
	# Safely initialize the dependent ProgressBar
	if is_instance_valid(damage_bar):
		damage_bar.max_value = max_hp
		damage_bar.value = max_hp
	else:
		# This will print if the reference is still broken
		push_error("DamageBar node reference is invalid!")


func _on_timer_timeout() -> void:
	# This slowly animated drop is better handled in _process (see note below)
	# But for a simple immediate reset, this is okay:
	damage_bar.value = health
