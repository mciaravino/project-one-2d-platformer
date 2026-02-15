extends "res://shared_scripts/level_base.gd"

func _ready() -> void:
	# If you set these in the Inspector instead, you can delete these two lines.
	player_scene = preload("res://actors/player/player.tscn")
	enemy_scene = preload("res://actors/enemy/flame_enemy/flame_enemy.tscn")

	super._ready()

func _on_level_ready() -> void:
	# Put Level02 music here (or leave empty for no music change)
	# var intro := preload("res://ui/background_music_player/background_wavs/xxx_intro.wav")
	# var loop := preload("res://ui/background_music_player/background_wavs/xxx_loop.wav")
	# Music.play_intro_and_loop(intro, loop)
	pass
