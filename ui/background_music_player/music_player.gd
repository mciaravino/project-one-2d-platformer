extends Node

@onready var player: AudioStreamPlayer = $Player

var loop_stream: AudioStream = null
var intro_stream: AudioStream = null
var is_playing := false

var _fade_tween: Tween

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

	# Cancel any fade and restore full volume
	if _fade_tween and _fade_tween.is_running():
		_fade_tween.kill()
	player.volume_db = 0.0

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
	# Cancel any fade and restore volume for next play
	if _fade_tween and _fade_tween.is_running():
		_fade_tween.kill()
	player.stop()
	player.volume_db = 0.0

	is_playing = false
	intro_stream = null
	loop_stream = null

func fade_out_and_stop(duration: float = 0.6) -> void:
	# If nothing is playing, just hard-stop state.
	if not player.playing:
		stop_music()
		return

	# Kill existing fade
	if _fade_tween and _fade_tween.is_running():
		_fade_tween.kill()

	_fade_tween = create_tween()
	_fade_tween.tween_property(player, "volume_db", -40.0, duration)
	_fade_tween.tween_callback(Callable(self, "stop_music"))

func restart_music() -> void:
	# Restarts using the last provided streams (useful for “restart level”).
	if intro_stream == null or loop_stream == null:
		return
	play_intro_and_loop(intro_stream, loop_stream, true)
