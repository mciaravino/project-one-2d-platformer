extends Node2D

# Camera padding in tiles from the USED tilemap area.
@export var pad_top_tiles: int = 10
@export var pad_bottom_tiles: int = 2
@export var pad_left_tiles: int = 2
@export var pad_right_tiles: int = 2

# Player framing (how far the player sits from screen center).
# Positive values push the view DOWN, making the player appear higher on screen.
@export var ground_offset_tiles: float = 0.0
@export var air_offset_tiles: float = -1.0
@export var cam_offset_lerp: float = 6.0

@export var rise_threshold: float = -25.0   # px/s (more negative = must be clearly rising)
@export var fall_threshold: float =  25.0   # px/s (more positive = must be clearly falling)

@onready var tile_layer: TileMapLayer = $TileMapLayer
@onready var spawn_point: Marker2D = $SpawnPoint
@onready var hud_control := $Hud/HudControl

const CameraLimits = preload("res://shared_scripts/camera_settings.gd")

var cam_mode_is_air: bool = false

var player: CharacterBody2D
var cam: Camera2D

var cam_target_offset_y: float = 0.0
var player_scene := preload("res://actors/player/player.tscn")

func _ready() -> void:
	_spawn_player()

	# Ensure we're operating on the actual camera instance we just grabbed.
	cam.make_current()

	# Set limits once the camera exists.
	CameraLimits.apply_limits_with_padding(
		cam,
		tile_layer,
		pad_top_tiles,
		pad_bottom_tiles,
		pad_left_tiles,
		pad_right_tiles
	)
func _physics_process(delta: float) -> void:
	if player == null or cam == null:
		return

	_update_camera_framing(delta)

func _spawn_player() -> void:
	if player:
		player.queue_free()

	player = player_scene.instantiate() as CharacterBody2D
	player.name = "Player"
	add_child(player)
	player.global_position = spawn_point.global_position

	cam = player.get_node("Camera2D") as Camera2D

	# We drive Camera2D.offset for framing; keep local position at 0.
	cam.position = Vector2.ZERO
	hud_control.bind_to_player(player)


	# Optional: if you use built-in smoothing, keep it off to avoid double-smoothing.
	# cam.position_smoothing_enabled = false

func _update_camera_framing(delta: float) -> void:
	# When rising, use smaller offset (show more above). Otherwise show more ground.
	var tile_h: float = float(tile_layer.tile_set.tile_size.y) * tile_layer.global_scale.y

	var vy: float = player.velocity.y

# Hysteresis to avoid rapid toggling near apex
	if cam_mode_is_air:
		# stay in air mode until we're clearly falling or nearly stopped
		if vy > fall_threshold:
			cam_mode_is_air = false
	else:
		# enter air mode only when clearly rising
		if vy < rise_threshold:
			cam_mode_is_air = true

	var target_tiles: float = air_offset_tiles if cam_mode_is_air else ground_offset_tiles

	# Camera2D.offset is in *screen* pixels; compensate for zoom so it behaves consistently.
	# Positive offset.y moves the camera view DOWN (player appears higher).
	var target_y: float = (target_tiles * tile_h) / cam.zoom.y

	var t: float = clampf(cam_offset_lerp * delta, 0.0, 1.0)
	cam_target_offset_y = lerp(cam_target_offset_y, target_y, t)

	cam.offset = Vector2(0.0, cam_target_offset_y)
