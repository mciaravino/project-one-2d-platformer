# res://ui/pause_menu/pause_menu.gd
extends Control

@export var main_menu_path := "res://ui/main_menu/main_menu.tscn"

@onready var unpause_btn: Button = $PanelContainer/VBoxContainer/Unpause
@onready var restart_btn: Button = $PanelContainer/VBoxContainer/RestartLevel
@onready var main_btn: Button = $PanelContainer/VBoxContainer/ReturnToMain
@onready var quit_btn: Button = $PanelContainer/VBoxContainer/QuitButton

func _ready() -> void:
	# IMPORTANT: allow menu to work while the game is paused
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	unpause_btn.pressed.connect(_on_unpause_pressed)
	restart_btn.pressed.connect(_on_restart_level_pressed)
	main_btn.pressed.connect(_on_return_to_main_pressed)
	quit_btn.pressed.connect(_on_quit_button_pressed)

	# If it's already visible on scene start, ensure focus.
	if visible:
		unpause_btn.grab_focus()

func open_menu() -> void:
	visible = true
	get_tree().paused = true
	unpause_btn.grab_focus()

func close_menu() -> void:
	get_tree().paused = false
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	# Controller back / Esc closes pause menu
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		close_menu()
		get_viewport().set_input_as_handled()

func _on_unpause_pressed() -> void:
	close_menu()

func _on_restart_level_pressed() -> void:
	close_menu()

	var tree := get_tree()
	var level := tree.current_scene

	if level != null and level.has_method("restart_level"):
		# restart_level() should already defer its reload; but defer just in case
		level.call_deferred("restart_level")
	else:
		Music.restart_music()
		tree.call_deferred("reload_current_scene")

func _on_return_to_main_pressed() -> void:
	close_menu()
	Music.stop_music()
	get_tree().change_scene_to_file(main_menu_path)

func _on_quit_button_pressed() -> void:
	Music.stop_music()
	get_tree().quit()
