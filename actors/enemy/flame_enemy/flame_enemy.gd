# res://actors/enemy/enemy.gd
extends CharacterBody2D

enum DamageChannel { AUTO, RED, BLUE }

@export var bars_count: int = 3 # for now your only enemy has 3 (later 1-4)

@export var gravity: float = 3600.0
@export var move_speed: float = 0.0 # keep 0 for turret enemy, later add patrol

@export var projectile_scene: PackedScene
@export var shots_per_second: float = 1.0
@export var projectile_speed: float = 520.0

@onready var shoot_timer: Timer = $ShootTimer
@onready var muzzle: Marker2D = $ShooterNode/MuzzleMarker
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var bars_anchor: Marker2D = $BarsAnchor

var target: Node2D = null
var bars_ui: EnemyBars

# --- Pattern health ---
var bars_pattern: Array[int] = []
var bars_cleared: Array[bool] = []
var bars_index: int = 0  # next bar to clear (in order)

func _ready() -> void:
	_generate_bars(bars_count)

	# Create and attach bars UI to BarsAnchor
	bars_ui = EnemyBars.new()
	bars_anchor.add_child(bars_ui)
	bars_ui.position = Vector2.ZERO
	bars_ui.bind_enemy(self)
	bars_ui.z_index = 100

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

func _generate_bars(count: int) -> void:
	count = clamp(count, 1, 4)
	bars_pattern.clear()
	bars_cleared.clear()
	bars_index = 0

	var rng := RandomNumberGenerator.new()
	rng.randomize()

	for i in range(count):
		var ch := DamageChannel.BLUE if rng.randi_range(0, 1) == 0 else DamageChannel.RED
		bars_pattern.append(ch)
		bars_cleared.append(false)

	#print("Enemy bars pattern: ", bars_pattern)

func get_bars_data() -> Dictionary:
	return {
		"pattern": bars_pattern,
		"cleared": bars_cleared,
	}

func take_damage(amount: int, channel: DamageChannel = DamageChannel.AUTO) -> void:
	# Ignore AUTO and only allow explicit RED/BLUE.
	if amount <= 0:
		return
	if channel != DamageChannel.RED and channel != DamageChannel.BLUE:
		return

	# If already dead, ignore
	if bars_index >= bars_pattern.size():
		return

	# Strict order: must match the next bar
	var required := bars_pattern[bars_index]
	if channel != required:
		return

	# Correct hit: clear exactly one bar (ignore amount for now)
	bars_cleared[bars_index] = true
	bars_index += 1

	#print("Correct hit. Progress=", bars_index, "/", bars_pattern.size())

	if bars_index >= bars_pattern.size():
		die()

func die() -> void:
	GameState.add_enemy_defeat(1)
	queue_free()

func _on_shoot_timer_timeout() -> void:
	if projectile_scene == null:
		return

	var p := projectile_scene.instantiate()
	get_tree().current_scene.add_child(p)
	p.global_position = muzzle.global_position

	var dir := Vector2.RIGHT
	if target != null:
		dir = (target.global_position - muzzle.global_position).normalized()

	if p.has_method("fire"):
		p.fire(dir, projectile_speed)

func _update_facing() -> void:
	if target == null:
		return
	anim.flip_h = (target.global_position.x < global_position.x)
