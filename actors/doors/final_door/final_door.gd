extends Area2D

@export var kills_required: int = 5
@export var win_scene: String  = "res://cutscenes/you_win/you_win.tscn"

@export var door_sfx: AudioStream = preload("res://actors/doors/unlocked_door/unlocked_door.wav")

@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var sprite: CanvasItem = $Sprite2D

var _player_inside: bool = false
var _unlocked: bool = false

func _ready() -> void:
	_set_unlocked(false)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	# Check unlock condition
	if not _unlocked and GameState.enemies_defeated >= kills_required:
		_set_unlocked(true)

	if not _player_inside or not _unlocked:
		return

	if Input.is_action_just_pressed("interact"):
		Sfx.play_one_shot(door_sfx)
		_go_to_win_scene()

func _set_unlocked(value: bool) -> void:
	_unlocked = value
	visible = value
	collider.disabled = not value

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		_player_inside = true

func _on_body_exited(body: Node) -> void:
	if body is CharacterBody2D:
		_player_inside = false

func _go_to_win_scene() -> void:
	if win_scene.is_empty():
		push_warning("FinalDoor has no win_scene set.")
		return

	get_tree().change_scene_to_file(win_scene)
