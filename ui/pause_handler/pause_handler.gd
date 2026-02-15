# res://ui/pause_handler.gd (or wherever yours lives)
extends Node

@export var pause_menu_scene: PackedScene
var pause_menu: Control

@onready var pause_layer: CanvasLayer = $PauseLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	if pause_menu_scene:
		pause_menu = pause_menu_scene.instantiate()
		pause_layer.add_child.call_deferred(pause_menu)
		pause_menu.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_pause()
		get_viewport().set_input_as_handled()

func _toggle_pause() -> void:
	if pause_menu == null:
		return

	var tree := get_tree()
	if tree.paused:
		# Prefer the menu’s close method (unpauses + hides)
		if pause_menu.has_method("close_menu"):
			pause_menu.call("close_menu")
		else:
			tree.paused = false
			pause_menu.visible = false
	else:
		# Prefer the menu’s open method (pauses + shows + focus)
		if pause_menu.has_method("open_menu"):
			pause_menu.call("open_menu")
		else:
			tree.paused = true
			pause_menu.visible = true
