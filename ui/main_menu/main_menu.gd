extends Control

@export var level_01_path := "res://levels/level_01/level_01.tscn"

func _ready() -> void:
	$PanelContainer/VBoxContainer/StartButton.pressed.connect(_on_start_button_pressed)
	$PanelContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit_button_pressed)
	$PanelContainer/VBoxContainer/OptionsButton.pressed.connect(_on_options_button_pressed)

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(level_01_path)

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_options_button_pressed() -> void:
	var options := preload("res://ui/main_menu/options_menu/options_menu.tscn").instantiate()
	add_child(options)
