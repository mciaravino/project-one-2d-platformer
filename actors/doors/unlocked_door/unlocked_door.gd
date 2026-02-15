extends Area2D

@export var target_level: String
@export var spawn_point_name: String = "SpawnPoint"

# Assign your door sound here in the inspector (drag the .wav in)
@export var door_sfx: AudioStream = preload("res://actors/doors/unlocked_door/unlocked_door.wav")

var _player_inside: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		_player_inside = true

func _on_body_exited(body: Node) -> void:
	if body is CharacterBody2D:
		_player_inside = false

func _process(_delta: float) -> void:
	if not _player_inside:
		return

	if Input.is_action_just_pressed("interact"):
		Sfx.play_one_shot(door_sfx)
		_go_to_level()

func _go_to_level() -> void:
	if target_level.is_empty():
		push_warning("UnlockedDoor has no target_level set.")
		return

	get_tree().change_scene_to_file(target_level)
