extends Control

enum DialogMode { NONE, NEW_GAME, LOAD_GAME }

@onready var title_label: Label = $MarginContainer/VBoxContainer/Label
@onready var new_button: Button = $MarginContainer/VBoxContainer/NewSave
@onready var load_button: Button = $MarginContainer/VBoxContainer/LoadSave
@onready var quit_button: Button = $MarginContainer/VBoxContainer/Quit
@onready var file_dialog: FileDialog = $FileDialog

var current_mode: DialogMode = DialogMode.NONE

func _ready() -> void:
	new_button.pressed.connect(_on_new_pressed)
	load_button.pressed.connect(_on_load_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	file_dialog.file_selected.connect(_on_file_selected)

	file_dialog.filters = PackedStringArray(["*.json ; JSON-Speicherstände"])
	file_dialog.current_dir = "user://"

func _on_new_pressed() -> void:
	current_mode = DialogMode.NEW_GAME
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dialog.title = "Neuen Spielstand speichern"
	file_dialog.current_file = "save_1.json"  # default name suggestion
	file_dialog.popup_centered_ratio(0.8)

func _on_load_pressed() -> void:
	current_mode = DialogMode.LOAD_GAME
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.title = "Spielstand laden"
	file_dialog.popup_centered_ratio(0.8)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_file_selected(path: String) -> void:
	match current_mode:
		DialogMode.NEW_GAME:
			_handle_new_game_path(path)
		DialogMode.LOAD_GAME:
			_handle_load_game_path(path)
		_:
			print("Unknown dialog mode")
	current_mode = DialogMode.NONE

func _handle_new_game_path(path: String) -> void:
	# Ensure .json extension
	if not path.ends_with(".json"):
		path += ".json"

	# Optional: ask player name somewhere else; for now leave it empty
	var player_name := ""
	SaveManager.create_new_save(path, player_name)

	# Go to your main menu or game scene
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	print("tried to change to main menu")

func _handle_load_game_path(path: String) -> void:
	if not SaveManager.load_save(path):
		push_error("SaveSelect: Failed to load save at %s" % path)
		return
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
