extends Control

@export var main_menu_path := "res://ui/main_menu/main_menu.tscn"

func _ready() -> void:
	$PanelContainer/VBoxContainer/Unpause.pressed.connect(_on_unpause_pressed)
	$PanelContainer/VBoxContainer/RestartLevel.pressed.connect(_on_restart_level_pressed)
	$PanelContainer/VBoxContainer/ReturnToMain.pressed.connect(_on_return_to_main_pressed)
	$PanelContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit_button_pressed)

func _on_unpause_pressed() -> void:
	get_tree().paused = false
	visible = false

func _on_restart_level_pressed() -> void:
	var tree := get_tree()
	tree.paused = false
	visible = false
	tree.reload_current_scene()

func _on_return_to_main_pressed() -> void:
	var tree := get_tree()
	tree.paused = false
	tree.change_scene_to_file(main_menu_path)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
