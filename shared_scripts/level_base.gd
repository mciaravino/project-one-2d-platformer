extends Node2D
class_name LevelBase

# ---- Camera padding
@export var pad_top_tiles: int = 10
@export var pad_bottom_tiles: int = 2
@export var pad_left_tiles: int = 2
@export var pad_right_tiles: int = 2

# ---- Camera framing
@export var ground_offset_tiles: float = 0.0
@export var air_offset_tiles: float = -1.0
@export var cam_offset_lerp: float = 6.0
@export var rise_threshold: float = -25.0
@export var fall_threshold: float = 25.0

# ---- Spawning
@export var spawn_enemies: bool = true
@export var enemy_scene: PackedScene
@export var player_scene: PackedScene

@export var player_start_hp: int = 10

@onready var tile_layer: TileMapLayer = $TileMapLayer
@onready var spawn_point: Marker2D = $PlayerSpawnPoint
@onready var hud_control = $Hud/HudControl
@onready var enemy_spawns: Node = $EnemySpawns

const CameraLimits = preload("res://shared_scripts/camera_settings.gd")

var cam_mode_is_air: bool = false
var player: CharacterBody2D
var cam: Camera2D
var cam_target_offset_y: float = 0.0

func _ready() -> void:
	_spawn_player()

	if spawn_enemies and enemy_scene != null:
		_spawn_enemies()

	cam.make_current()

	CameraLimits.apply_limits_with_padding(
		cam,
		tile_layer,
		pad_top_tiles,
		pad_bottom_tiles,
		pad_left_tiles,
		pad_right_tiles
	)

	_on_level_ready() # hook for level-specific stuff (music, triggers, etc.)

func _physics_process(delta: float) -> void:
	if player == null or cam == null:
		return
	_update_camera_framing(delta)

func _spawn_player() -> void:
	if player:
		player.queue_free()

	player = (player_scene.instantiate() as CharacterBody2D)
	player.name = "Player"
	add_child(player)
	player.global_position = spawn_point.global_position
	player.died.connect(_on_player_died)

	# --- Persistent HP across levels ---
	GameState.ensure_initialized(player.max_hp)
	GameState.set_max_hp(player.max_hp)

	# Apply persistent HP to player
	player.set_hp(GameState.hp)

	# Capture (overwrite) the level-start HP snapshot for THIS load
	GameState.level_start_hp[self.scene_file_path] = GameState.hp

		
	cam = player.get_node("Camera2D") as Camera2D
	cam.position = Vector2.ZERO
	# --- Persistent HP across levels + per-level restart snapshot ---
	GameState.ensure_initialized(player.max_hp)
	GameState.set_max_hp(player.max_hp)

	player.set_hp(GameState.hp)

	# Capture "starting HP for this level" once (used for restarting this level)
	GameState.capture_level_start(self)

	# Optional: keep GameState.hp updated when player HP changes
	if player.has_signal("health_changed"):
		player.health_changed.connect(func(current: int, _maxv: int) -> void:
			GameState.set_hp(current)
		)

	hud_control.bind_to_player(player)

func _update_camera_framing(delta: float) -> void:
	var tile_h: float = float(tile_layer.tile_set.tile_size.y) * tile_layer.global_scale.y
	var vy: float = player.velocity.y

	if cam_mode_is_air:
		if vy > fall_threshold:
			cam_mode_is_air = false
	else:
		if vy < rise_threshold:
			cam_mode_is_air = true

	var target_tiles: float = air_offset_tiles if cam_mode_is_air else ground_offset_tiles
	var target_y: float = (target_tiles * tile_h) / cam.zoom.y

	var t: float = clampf(cam_offset_lerp * delta, 0.0, 1.0)
	cam_target_offset_y = lerp(cam_target_offset_y, target_y, t)
	cam.offset = Vector2(0.0, cam_target_offset_y)

func _spawn_enemies() -> void:
	for child in enemy_spawns.get_children():
		if child is Marker2D:
			var e := enemy_scene.instantiate()
			add_child(e)
			e.global_position = child.global_position
			if e.has_method("set_target") and player != null:
				e.set_target(player)

# Override in Level01/Level02 for music, cutscenes, etc.
func _on_level_ready() -> void:
	pass
	
func restart_level() -> void:
	var tree := get_tree()
	tree.paused = false

	# Reset HP to this level's captured start HP
	GameState.reset_to_level_start(self)

	# Restart music for this level (uses stored intro/loop)
	Music.restart_music()

	tree.call_deferred("reload_current_scene")
func _on_player_died() -> void:
	restart_level()
