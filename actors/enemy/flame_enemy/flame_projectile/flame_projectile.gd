# res://actors/projectiles/enemy_projectile.gd
extends Area2D

@export var lifetime: float = 2.0
@export var damage: int = 1
@export var speed: float = 520.0

var velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# self-destruct after lifetime
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func fire(direction: Vector2, new_speed: float) -> void:
	speed = new_speed
	velocity = direction.normalized() * speed
	rotation = velocity.angle()

func _physics_process(delta: float) -> void:
	global_position += velocity * delta

func _on_body_entered(body: Node) -> void:
	# If player has take_damage(), call it
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
