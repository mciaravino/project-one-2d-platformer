# res://ui/main_menu/main_menu.gd
extends Control

@export var level_01_path := "res://levels/level_01/level_01.tscn"
@export var options_scene: PackedScene = preload("res://ui/main_menu/options_menu/options_menu.tscn")

@onready var start_button: Button = $PanelContainer/VBoxContainer/StartButton
@onready var options_button: Button = $PanelContainer/VBoxContainer/OptionsButton
@onready var quit_button: Button = $PanelContainer/VBoxContainer/QuitButton

var options_instance: Node = null

func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)

	start_button.grab_focus()

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(level_01_path)

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_options_button_pressed() -> void:
	# Prevent opening multiple options menus
	if options_instance != null and is_instance_valid(options_instance):
		return

	options_instance = options_scene.instantiate()
	add_child(options_instance)

	# When it closes, restore focus to the menu
	if options_instance.has_signal("closed"):
		options_instance.closed.connect(func() -> void:
			options_instance = null
			options_button.grab_focus()
		)
	else:
		# Fallback: if no signal, just refocus when the node exits
		options_instance.tree_exited.connect(func() -> void:
			options_instance = null
			options_button.grab_focus()
		)
