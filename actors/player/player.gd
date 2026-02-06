extends CharacterBody2D

@export var speed := 260.0
@export var jump_velocity := -1100.0
@export var gravity_scale := 1.0

@export var coyote_time := 0.12
@export var jump_buffer_time := 0.12

var gravity := 0.0
var coyote_timer := 0.0
var jump_buffer_timer := 0.0

var facing := 1 # 1 = right, -1 = left
var attacking := false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity") as float

	# Your art faces left by default, so "right" is flip_h = true.
	facing = 1
	anim.flip_h = true
	anim.play("idle")

	# End attack lock when the animation finishes.
	anim.animation_finished.connect(_on_anim_finished)

func _on_anim_finished() -> void:
	if anim.animation == "attack":
		attacking = false

func _physics_process(delta: float) -> void:
	# --- Attack input (priority) ---
	if Input.is_action_just_pressed("attack") and not attacking:
		attacking = true
		anim.play("attack")

	# --- Timers ---
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	jump_buffer_timer -= delta

	# --- Gravity ---
	if not is_on_floor():
		velocity.y += gravity * gravity_scale * delta
	else:
		velocity.y = 0.0

	# --- Jump input ---
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time

	# --- Jump execution ---
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0 and not attacking:
		velocity.y = jump_velocity
		jump_buffer_timer = 0.0
		coyote_timer = 0.0

	# --- Horizontal movement ---
	var dir := 0.0 if attacking else Input.get_axis("move_left", "move_right")
	velocity.x = dir * speed

	# --- Facing (only update when moving) ---
	if dir != 0.0:
		facing = 1 if dir > 0.0 else -1

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
