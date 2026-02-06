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
	tree.paused = not tree.paused
	pause_menu.visible = tree.paused
