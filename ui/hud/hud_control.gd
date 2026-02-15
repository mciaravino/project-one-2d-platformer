extends Control

@onready var health_label: Label = $Health
@onready var enemies_label: Label = $Enemies

func bind_to_player(p: Node) -> void:
	if p == null:
		health_label.text = "HP: ?"
		return

	if p.has_signal("health_changed"):
		p.health_changed.connect(_on_health_changed)

	# Initialize HP immediately
	if "hp" in p and "max_hp" in p:
		_on_health_changed(p.hp, p.max_hp)

	# Initialize enemy counter immediately
	_update_enemy_label()

func _on_health_changed(current: int, max_health: int) -> void:
	health_label.text = "HP: %d / %d" % [current, max_health]

func _process(_delta: float) -> void:
	# Lightweight and simple: just refresh every frame
	_update_enemy_label()

func _update_enemy_label() -> void:
	enemies_label.text = "Enemies Felled: %d / 5" % GameState.enemies_defeated
