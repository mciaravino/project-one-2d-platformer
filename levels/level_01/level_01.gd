extends "res://shared_scripts/level_base.gd"

func _ready() -> void:
	player_scene = preload("res://actors/player/player.tscn")
	enemy_scene = preload("res://actors/enemy/flame_enemy/flame_enemy.tscn")

	super._ready()

func _on_level_ready() -> void:
	var intro := preload("res://ui/background_music_player/background_wavs/field_wavs/field_intro.wav")
	var loop := preload("res://ui/background_music_player/background_wavs/field_wavs/field_loop.wav")
	Music.play_intro_and_loop(intro, loop)
