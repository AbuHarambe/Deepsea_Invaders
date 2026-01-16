extends Node

const TEMPLATE_PATH: String = "res://Assets/Data/save_state_template.json"

var data: Dictionary = {}
var current_path: String = ""

func load_template() -> Dictionary:
	var f: FileAccess = FileAccess.open(TEMPLATE_PATH, FileAccess.READ)
	if f == null:
		push_error("SaveManager: Could not open template at %s" % TEMPLATE_PATH)
		return {}
	var text: String = f.get_as_text()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("SaveManager: Template JSON is not a dictionary.")
		return {}
	return parsed as Dictionary


func create_new_save(path: String, player_name: String = "") -> void:
	data = load_template()
	data["playerName"] = player_name
	current_path = path
	save()


func load_save(path: String) -> bool:
	if not FileAccess.file_exists(path):
		push_error("SaveManager: File does not exist: %s" % path)
		return false

	var f: FileAccess = FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("SaveManager: Could not open file: %s" % path)
		return false

	var text: String = f.get_as_text()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("SaveManager: Save JSON is not a dictionary.")
		return false

	data = parsed as Dictionary
	current_path = path
	return true


func save() -> void:
	if current_path == "":
		push_error("SaveManager: current_path is empty, cannot save.")
		return
	var f: FileAccess = FileAccess.open(current_path, FileAccess.WRITE)
	if f == null:
		push_error("SaveManager: Could not open for write: %s" % current_path)
		return
	f.store_string(JSON.stringify(data, "  "))

# --- Player basics ---------------------------------------------------------

func set_player_name(name: String) -> void:
	data["playerName"] = name
	save()


func add_xp(amount: int) -> void:
	var current_xp: int = int(data.get("playerXP", 0))
	data["playerXP"] = current_xp + amount
	save()


func set_hp(hp: int) -> void:
	data["playerHP"] = hp
	save()


# --- Cosmetics -------------------------------------------------------------

func set_hat(hat_id: String) -> void:
	var cosmetics_variant: Variant = data.get("cosmetics", {})
	var cosmetics: Dictionary
	if typeof(cosmetics_variant) == TYPE_DICTIONARY:
		cosmetics = cosmetics_variant as Dictionary
	else:
		cosmetics = {}
		data["cosmetics"] = cosmetics

	cosmetics["hat"] = hat_id
	save()


# --- Enemy capture data ----------------------------------------------------

func increment_capture(enemy_type_id: String, amount: int = 1) -> void:
	var list_variant: Variant = data.get("enemyCaptureData", [])
	var list: Array

	if typeof(list_variant) == TYPE_ARRAY:
		list = list_variant as Array
	else:
		list = []
		data["enemyCaptureData"] = list

	for entry in list:
		if typeof(entry) == TYPE_DICTIONARY:
			var entry_dict: Dictionary = entry as Dictionary
			if entry_dict.get("enemyTypeID", "") == enemy_type_id:
				var current_count: int = int(entry_dict.get("captureCount", 0))
				entry_dict["captureCount"] = current_count + amount
				save()
				return

	# If not found, create a new entry
	var new_entry: Dictionary = {
		"enemyTypeID": enemy_type_id,
		"captureCount": amount
	}
	list.append(new_entry)
	save()


# --- Upgrade skill data ----------------------------------------------------

func set_skill_level(skill_id: String, level: int) -> void:
	var skills_variant: Variant = data.get("upgradeSkillData", {})
	var skills: Dictionary

	if typeof(skills_variant) == TYPE_DICTIONARY:
		skills = skills_variant as Dictionary
	else:
		skills = {}
		data["upgradeSkillData"] = skills

	var skill_entry_variant: Variant = skills.get(skill_id, {})
	var skill_entry: Dictionary
	if typeof(skill_entry_variant) == TYPE_DICTIONARY:
		skill_entry = skill_entry_variant as Dictionary
	else:
		skill_entry = {}
	skills[skill_id] = skill_entry

	skill_entry["skillLevel"] = level
	save()


func add_skill_level(skill_id: String, delta: int = 1) -> void:
	var skills_variant: Variant = data.get("upgradeSkillData", {})
	var skills: Dictionary

	if typeof(skills_variant) == TYPE_DICTIONARY:
		skills = skills_variant as Dictionary
	else:
		skills = {}
		data["upgradeSkillData"] = skills

	var skill_entry_variant: Variant = skills.get(skill_id, {})
	var skill_entry: Dictionary
	if typeof(skill_entry_variant) == TYPE_DICTIONARY:
		skill_entry = skill_entry_variant as Dictionary
	else:
		# default starting level if it didn't exist
		skill_entry = {"skillLevel": 1}
	skills[skill_id] = skill_entry

	var current_level: int = int(skill_entry.get("skillLevel", 1))
	skill_entry["skillLevel"] = current_level + delta
	save()
	
func reset_all_fish_progress() -> void:
	# Pull the default capture list from the template (so you keep the same set of fish IDs)
	var template: Dictionary = load_template()
	var template_list_variant: Variant = template.get("enemyCaptureData", [])
	var template_list: Array

	if typeof(template_list_variant) == TYPE_ARRAY:
		# Duplicate so we don't accidentally share references
		template_list = (template_list_variant as Array).duplicate(true)
	else:
		template_list = []

	data["enemyCaptureData"] = template_list
	save()
