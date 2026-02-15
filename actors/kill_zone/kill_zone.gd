extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	var n := body
	while n != null:
		if n.has_method("die"):
			n.die()
			return
		n = n.get_parent()
