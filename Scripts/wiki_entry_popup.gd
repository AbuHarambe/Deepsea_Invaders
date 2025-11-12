extends Control
signal closed

@onready var tex_rect: TextureRect = $Panel/MarginContainer/VBoxContainer/TextureRect
@onready var fish_name: Label = $Panel/MarginContainer/VBoxContainer/FishName
@onready var tier1_lbl: Label = $Panel/MarginContainer/VBoxContainer/Tier1Info
@onready var tier2_lbl: Label = $Panel/MarginContainer/VBoxContainer/Tier2Info
@onready var tier3_lbl: Label = $Panel/MarginContainer/VBoxContainer/Tier3Info
@onready var back_btn: Button = $Panel/MarginContainer/VBoxContainer/Back
@onready var panel: Panel = $Panel

func _ready():
	back_btn.pressed.connect(_on_back_pressed)
	# Make the overlay cover the screen and block clicks to what's below.
	mouse_filter = Control.MOUSE_FILTER_STOP
	# Panel should also stop input so clicks inside don't bubble to the overlay.
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
func _on_back_pressed():
	emit_signal("closed")
	queue_free()

func _gui_input(event):
	# Any click on the overlay (i.e., outside the panel) closes the popup.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var click_local: Vector2 = event.position
		# panel’s rect is in *the same local space* because it’s a child
		if not panel.get_rect().has_point(click_local):
			_close()

# --- Setter function so the menu can feed data into it ---
func set_data(image: Texture2D, name: String, tier1: String, tier2: String, tier3: String) -> void:
	tex_rect.texture = image
	fish_name.text = name
	tier1_lbl.text = tier1
	tier2_lbl.text = tier2
	tier3_lbl.text = tier3

func _unhandled_input(event):
	# Optional: allow ESC / B button to close
	if event.is_action_pressed("ui_cancel"):
		_close()

func _close():
	emit_signal("closed")
	queue_free()
