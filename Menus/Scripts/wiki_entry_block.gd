@tool
extends Control  # or whatever your root node is

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
	var popup_scene: PackedScene = load("res://Scenes/wiki_entry_popup.tscn")
	var popup: Control = popup_scene.instantiate()

	# Find the wiki menu instance this block belongs to
	var wiki_menu = get_tree().get_first_node_in_group("wiki_menu")

	# Or: var wiki_menu = get_parent().get_parent().get_parent() ... (but groups are cleaner)

	var overlay = wiki_menu.get_overlay()
	overlay.add_child(popup)
	popup.set_data(_image, _title, _tier1info, _tier2info, _tier3info)

	
	# Feed Data
	print("trying to feed")
	var entry := WikiData.get_entry(_title)
	popup.set_data(
		_image,
		_title,
		entry.get("tier1", ""),
		entry.get("tier2", ""),
		entry.get("tier3", "")
	)
	print(entry)
