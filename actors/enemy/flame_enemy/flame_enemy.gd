# res://actors/enemy/enemy.gd
extends CharacterBody2D

enum DamageChannel { AUTO, RED, BLUE }

@export var red_hp_max: int = 3
@export var blue_hp_max: int = 0
@export var red_hp: int = 3
@export var blue_hp: int = 0

@export var gravity: float = 3600.0
@export var move_speed: float = 0.0 # keep 0 for turret enemy, later add patrol

@export var projectile_scene: PackedScene
@export var shots_per_second: float = 1.0
@export var projectile_speed: float = 520.0

@onready var shoot_timer: Timer = $ShootTimer
@onready var muzzle: Marker2D = $ShooterNode/MuzzleMarker
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


var target: Node2D = null

func _ready() -> void:
	# Initialize pools safely
	red_hp = clamp(red_hp, 0, red_hp_max)
	blue_hp = clamp(blue_hp, 0, blue_hp_max)

	# Setup timer from shots_per_second
	shoot_timer.wait_time = 1.0 / max(shots_per_second, 0.01)
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.start()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	velocity.x = move_speed
	move_and_slide()

	_update_facing()


func set_target(t: Node2D) -> void:
	target = t

func take_damage(amount: int, channel: DamageChannel = DamageChannel.AUTO) -> void:
	if amount <= 0:
		return

	match channel:
		DamageChannel.BLUE:
			blue_hp = max(blue_hp - amount, 0)
		DamageChannel.RED:
			red_hp = max(red_hp - amount, 0)
		DamageChannel.AUTO:
			var remaining := amount
			if blue_hp > 0:
				var used = min(blue_hp, remaining)
				blue_hp -= used
				remaining -= used
			if remaining > 0:
				red_hp = max(red_hp - remaining, 0)

	# Debug
	print("Enemy took ", amount, " dmg. Red=", red_hp, " Blue=", blue_hp)

	if red_hp <= 0:
		die()

func die() -> void:
	queue_free()

func _on_shoot_timer_timeout() -> void:
	
	if projectile_scene == null:
		return

	# If you want it to only shoot when target exists:
	# if target == null: return

	var p := projectile_scene.instantiate()
	get_tree().current_scene.add_child(p)

	# spawn at muzzle
	p.global_position = muzzle.global_position

	# Decide direction
	var dir := Vector2.RIGHT
	if target != null:
		dir = (target.global_position - muzzle.global_position).normalized()

	# Tell projectile how to move (method below)
	if p.has_method("fire"):
		p.fire(dir, projectile_speed)

func _update_facing() -> void:
	if target == null:
		return

	if target.global_position.x < global_position.x:
		anim.flip_h = true
	else:
		anim.flip_h = false
