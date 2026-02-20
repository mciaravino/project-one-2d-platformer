extends CharacterBody2D

@export var speed := 260.0
@export var jump_velocity := -1100.0
@export var gravity_scale := 1.0

@export var coyote_time := 0.12
@export var jump_buffer_time := 0.12

@export var attack_hit_start := 0.05
@export var attack_hit_end := 0.20

# Assign your sword/attack WAV here in the Player scene Inspector
@export var attack_sfx_right: AudioStream
@export var attack_sfx_left: AudioStream
@export var attack_sfx_frame := 0 # 0-based frame index for multi-frame attack anim
var attack_sfx_to_play: AudioStream

signal died
signal health_changed(current: int, max_hp: int)

@export var max_hp: int = 10
var hp: int
var is_dead: bool = false

var hp_initialized: bool = false

var attack_time := 0.0
var attack_sfx_played := false

@onready var hitbox: Area2D = $AttackHitBox
@onready var hitshape: CollisionShape2D = $AttackHitBox/CollisionShape2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var gravity := 0.0
var coyote_timer := 0.0
var jump_buffer_timer := 0.0

var facing := 1 # 1 = right, -1 = left
var attacking := false

enum AttackType { BLUE, RED }
var current_attack_type: int = AttackType.BLUE

func _ready() -> void:
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity") as float
	hitbox.monitoring = true
	hitshape.disabled = true

	# Your art faces left by default, so "right" is flip_h = true.
	facing = 1
	anim.flip_h = true
	anim.play("idle")

	anim.animation_finished.connect(_on_anim_finished)
	hitbox.body_entered.connect(_on_attack_hitbox_body_entered)
	anim.frame_changed.connect(_on_anim_frame_changed)
	
	if not hp_initialized:
		hp = max_hp
		hp_initialized = true
		emit_signal("health_changed", hp, max_hp)

func _on_anim_finished() -> void:
	if anim.animation == "attack":
		attacking = false
		attack_sfx_played = false
		hitshape.disabled = true

func _physics_process(delta: float) -> void:
	if is_dead:
		return
# --- Attack input (priority) ---
	var left_pressed := Input.is_action_just_pressed("attack_left")
	var right_pressed := Input.is_action_just_pressed("attack_right")

	if (left_pressed or right_pressed) and not attacking:
		attacking = true
		attack_time = 0.0
		attack_sfx_played = false
		hitshape.disabled = true

		current_attack_type = AttackType.BLUE if left_pressed else AttackType.RED

		# Choose which sound to play for this attack
		attack_sfx_to_play = attack_sfx_left if left_pressed else attack_sfx_right

		anim.play("attack")

		# If attack animation is 1 frame (or missing), play immediately.
		var fc := 0
		if anim.sprite_frames != null and anim.sprite_frames.has_animation("attack"):
			fc = anim.sprite_frames.get_frame_count("attack")

		if fc <= 1:
			attack_sfx_played = true
			Sfx.play_one_shot(attack_sfx_to_play)





	# --- Timers ---
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	jump_buffer_timer = maxf(jump_buffer_timer - delta, 0.0)

	# --- Gravity ---
	if not is_on_floor():
		velocity.y += gravity * gravity_scale * delta
	else:
		velocity.y = 0.0

	# --- Jump input ---
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time

	# --- Jump execution ---
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = jump_velocity
		jump_buffer_timer = 0.0
		coyote_timer = 0.0

	# --- Horizontal movement (allow during attack) ---
	var dir := Input.get_axis("move_left", "move_right")
	velocity.x = dir * speed

	# --- Facing (only update when moving) ---
	if dir != 0.0:
		facing = 1 if dir > 0.0 else -1

	hitbox.position.x = absf(hitbox.position.x) * facing

	# Art faces left by default => right is flip_h=true, left is flip_h=false
	anim.flip_h = (facing == 1)

	move_and_slide()

	# --- Animation state (don’t override attack while locked) ---
	if not attacking:
		if not is_on_floor():
			if anim.animation != "idle":
				anim.play("idle")
		elif absf(velocity.x) > 1.0:
			if anim.animation != "walk":
				anim.play("walk")
		else:
			if anim.animation != "idle":
				anim.play("idle")

	if attacking:
		attack_time += delta
		hitshape.disabled = not (
			attack_time >= attack_hit_start and
			attack_time <= attack_hit_end
		)
		
		

func _on_attack_hitbox_body_entered(body: Node) -> void:
	if not attacking:
		return
	if hitshape.disabled:
		return

	#print("HIT:", body.name)

	if body.has_method("take_damage"):
	# Map player attack type -> enemy DamageChannel
	# BLUE = left click, RED = right click
		var channel := 0
		if current_attack_type == AttackType.BLUE:
			channel = body.DamageChannel.BLUE
		else:
			channel = body.DamageChannel.RED
		
		body.take_damage(1, channel)

func _on_anim_frame_changed() -> void:
	if anim.animation != "attack":
		return
	if attack_sfx_played:
		return
	if anim.frame >= attack_sfx_frame:
		attack_sfx_played = true
		if attack_sfx_to_play != null:
			Sfx.play_one_shot(attack_sfx_to_play)
		
func take_damage(amount: int) -> void:
	if is_dead:
		return
	if amount <= 0:
		return

	hp = max(hp - amount, 0)
	emit_signal("health_changed", hp, max_hp)

	if hp == 0:
		die()

func die() -> void:
	if is_dead:
		return
	is_dead = true
	emit_signal("died")

	set_physics_process(false)
	set_process(false)
	velocity = Vector2.ZERO

	# DEFER collision changes (avoids "flushing queries" error)
	hitshape.set_deferred("disabled", true)
	hitbox.set_deferred("monitoring", false)

	var cs := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if cs:
		cs.set_deferred("disabled", true)

	hide()
	
func set_hp(value: int) -> void:
	hp = clamp(value, 0, max_hp)
	hp_initialized = true
	emit_signal("health_changed", hp, max_hp)
