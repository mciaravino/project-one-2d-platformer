extends Node

@onready var player: AudioStreamPlayer = $Player

var loop_stream: AudioStream = null
var intro_stream: AudioStream = null
var is_playing := false

func play_intro_and_loop(intro: AudioStream, loop: AudioStream, restart: bool = false) -> void:
	# If we’re already playing and not restarting, keep going (level transitions).
	if is_playing and not restart:
		return

	intro_stream = intro
	loop_stream = loop
	is_playing = true

	# Ensure the intro-finished handler is connected once.
	if not player.finished.is_connected(_on_intro_finished):
		player.finished.connect(_on_intro_finished)

	player.stop()
	player.stream = intro_stream
	player.play()

func _on_intro_finished() -> void:
	# When intro ends, switch to loop. Looping behavior is controlled by the loop WAV import setting.
	if loop_stream == null:
		return
	player.stream = loop_stream
	player.play()

func stop_music() -> void:
	player.stop()
	is_playing = false
	intro_stream = null
	loop_stream = null

func restart_music() -> void:
	# Restarts using the last provided streams (useful for “restart level”).
	if intro_stream == null or loop_stream == null:
		return
	play_intro_and_loop(intro_stream, loop_stream, true)
