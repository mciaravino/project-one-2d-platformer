extends Control

@export var return_scene: String = "res://ui/main_menu/main_menu.tscn"
@export var win_sfx: AudioStream

func _ready() -> void:
	#Music.fade_out_and_stop(0.6)

	# Play victory sound once
	if win_sfx:
		Sfx.play_one_shot(win_sfx)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		get_tree().change_scene_to_file(return_scene)
