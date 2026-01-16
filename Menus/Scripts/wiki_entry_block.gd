@tool
extends Control  # or whatever your root node is


@export var ID:String = "0"
# --- Image ---
var _image: Texture2D
@export var image: Texture2D:
	set(value):
		_image = value
		var tex_rect := get_node_or_null("Panel/Button/MarginContainer/VBoxContainer/TextureRect")
		if tex_rect:
			tex_rect.texture = value
	get:
		return _image

# --- Title ---
var _title: String
@export var title: String:
	set(value):
		_title = value
		var lbl := get_node_or_null("Panel/Button/MarginContainer/VBoxContainer/FishName")
		if lbl:
			lbl.text = value
	get:
		return _title

# --- Tier 1 ---
var _tier1info: String
@export var tier1info: String:
	set(value):
		_tier1info = value
		var lbl := get_node_or_null("Panel/Button/MarginContainer/VBoxContainer/Tier1Info")
		if lbl:
			lbl.text = value
	get:
		return _tier1info

# --- Tier 2 ---
var _tier2info: String
@export var tier2info: String:
	set(value):
		_tier2info = value
		var lbl := get_node_or_null("Panel/Button/MarginContainer/VBoxContainer/Tier2Info")
		if lbl:
			lbl.text = value
	get:
		return _tier2info

# --- Tier 3 ---
var _tier3info: String
@export var tier3info: String:
	set(value):
		_tier3info = value
		var lbl := get_node_or_null("Panel/Button/MarginContainer/VBoxContainer/Tier3Info")
		if lbl:
			lbl.text = value
	get:
		return _tier3info


func _ready():
	# Reapply exported values when scene loads (for both editor preview and runtime)
	var tex_rect := get_node_or_null("Panel/Button/MarginContainer/VBoxContainer/TextureRect")
	if tex_rect:
		tex_rect.texture = _image

	var fish_name := get_node_or_null("Panel/Button/MarginContainer/VBoxContainer/FishName")
	if fish_name:
		fish_name.text = _title

	var tier1 := get_node_or_null("Panel/Button/MarginContainer/VBoxContainer/Tier1Info")
	if tier1:
		tier1.text = _tier1info

	var tier2 := get_node_or_null("Panel/Button/MarginContainer/VBoxContainer/Tier2Info")
	if tier2:
		tier2.text = _tier2info

	var tier3 := get_node_or_null("Panel/Button/MarginContainer/VBoxContainer/Tier3Info")
	if tier3:
		tier3.text = _tier3info

	
func _on_button_pressed() -> void:
	var popup_scene: PackedScene = load("res://Menus/Scenes/wiki_entry_popup.tscn")
	var popup: Control = popup_scene.instantiate()

	# Find wiki menu instance + overlay
	var wiki_menu := get_tree().get_first_node_in_group("wiki_menu")
	if wiki_menu == null:
		push_error("WikiEntryBlock: wiki_menu group not found.")
		return

	var overlay: Node = wiki_menu.get_overlay()
	overlay.add_child(popup)

	# Fetch wiki entry text from WikiData JSON
	var entry: Dictionary = WikiData.get_entry(ID)

	# How many of this fish the player has scanned/caught
	var count: int = _get_capture_count_for(ID)

	# Apply thresholds
	var tier1_text: String = _tier_text_or_locked(count, 1, String(entry.get("tier1", "")))
	var tier2_text: String = _tier_text_or_locked(count, 5, String(entry.get("tier2", "")))
	var tier3_text: String = _tier_text_or_locked(count, 10, String(entry.get("tier3", "")))

	# Feed popup with: image + title from block, tier texts gated by progress
	popup.set_data(_image, _title, tier1_text, tier2_text, tier3_text)

const LOCKED_MSG := "Du musst diesen Fisch häufiger fangen, um mehr Infos zu erhalten."

func _get_capture_count_for(enemy_type_id: String) -> int:
	# Reads from SaveManager's current save data
	var list_variant: Variant = SaveManager.data.get("enemyCaptureData", [])
	if typeof(list_variant) != TYPE_ARRAY:
		return 0

	var list: Array = list_variant as Array
	for entry in list:
		if typeof(entry) == TYPE_DICTIONARY:
			var d: Dictionary = entry as Dictionary
			if String(d.get("enemyTypeID", "")) == enemy_type_id:
				return int(d.get("captureCount", 0))
	return 0


func _tier_text_or_locked(capture_count: int, required: int, text: String) -> String:
	return text if capture_count >= required and text != "" else LOCKED_MSG
