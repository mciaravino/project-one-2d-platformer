extends CharacterBody2D

@export var speed := 260.0
@export var jump_velocity := -1100.0
@export var gravity_scale := 1.0

@export var coyote_time := 0.12
@export var jump_buffer_time := 0.12

@export var attack_hit_start := 0.05
@export var attack_hit_end := 0.20

var attack_time := 0.0

@onready var hitbox: Area2D = $AttackHitBox
@onready var hitshape: CollisionShape2D = $AttackHitBox/CollisionShape2D
@onready var sfx_attack: AudioStreamPlayer2D = $SfxAttack

var attack_sfx_played := false
@export var attack_sfx_frame := 0  # pick the frame index you want the whoosh on (0-based)


var gravity := 0.0
var coyote_timer := 0.0
var jump_buffer_timer := 0.0

var facing := 1 # 1 = right, -1 = left
var attacking := false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity") as float
	hitbox.monitoring = true

	hitshape.disabled = true

	# Your art faces left by default, so "right" is flip_h = true.
	facing = 1
	anim.flip_h = true
	anim.play("idle")

	# End attack lock when the animation finishes.
	anim.animation_finished.connect(_on_anim_finished)
	# Script-based signal connect
	hitbox.body_entered.connect(_on_attack_hitbox_body_entered)
	print("Hitbox connected:", hitbox.body_entered.is_connected(_on_attack_hitbox_body_entered))
	anim.frame_changed.connect(_on_anim_frame_changed)



func _on_anim_finished() -> void:
	if anim.animation == "attack":
		attacking = false
		attack_sfx_played = false
		hitshape.disabled = true


func _physics_process(delta: float) -> void:
	# --- Attack input (priority) ---
	if Input.is_action_just_pressed("attack") and not attacking:
		attacking = true
		attack_time = 0.0
		attack_sfx_played = false   # <-- add this
		hitshape.disabled = true
		anim.play("attack")
		var fc := anim.sprite_frames.get_frame_count("attack")
		if fc <= 1:
			attack_sfx_played = true
			if sfx_attack.playing:
				sfx_attack.stop()
			sfx_attack.play()


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
			# If you don't have "jump" / "fall" animations yet, keep idle.
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
	# Only register hits during the active frames
	if not attacking:
		return
	if hitshape.disabled:
		return

	# Debug proof
	print("HIT:", body.name)

	# Damage hook (enemy implements this)
	if body.has_method("take_damage"):
		body.take_damage(1)

	print("HIT:", body.name)

func _on_anim_frame_changed() -> void:
	if anim.animation != "attack":
		return
	if attack_sfx_played:
		return
	if anim.frame >= attack_sfx_frame:
		attack_sfx_played = true
		if sfx_attack.playing:
			sfx_attack.stop()
		sfx_attack.play()
