extends Control

@onready var label: Label = $Health

func bind_to_player(p: Node) -> void:
	if p == null:
		label.text = "HP: ?"
		return

	if p.has_signal("health_changed"):
		p.health_changed.connect(_on_health_changed)

	# Initialize immediately using correct property names
	if "hp" in p and "max_hp" in p:
		_on_health_changed(p.hp, p.max_hp)

func _on_health_changed(current: int, max_health: int) -> void:
	label.text = "HP: %d / %d" % [current, max_health]
