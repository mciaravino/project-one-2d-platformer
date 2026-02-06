extends Control

@onready var label: Label = $Health

func bind_to_player(p: Node) -> void:
	if p == null:
		label.text = "HP: ?"
		return

	if p.has_signal("health_changed"):
		p.health_changed.connect(_on_health_changed)

	# initialize immediately
	if "health" in p and "max_health" in p:
		_on_health_changed(p.health, p.max_health)

func _on_health_changed(current: int, max_health: int) -> void:
	label.text = "HP: %d / %d" % [current, max_health]
