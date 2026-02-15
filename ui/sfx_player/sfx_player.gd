extends Node

func play_one_shot(stream: AudioStream) -> void:
	if stream == null:
		return

	var player := AudioStreamPlayer.new()
	player.bus = "SFX"
	player.stream = stream
	add_child(player)

	player.play()

	player.finished.connect(player.queue_free)
