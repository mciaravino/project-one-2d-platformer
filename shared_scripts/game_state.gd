# res://shared_scripts/game_state.gd
extends Node
#class_name GameState

var max_hp: int = 10
var hp: int = -1  # -1 means "not initialized yet"

# Per-level restart HP snapshot (keyed by scene path)
var level_start_hp := {}  # Dictionary[String, int]

# --- Enemy defeats (global) + per-level restart snapshot ---
var enemies_defeated: int = 0
var level_start_enemies := {}  # Dictionary[String, int]

func ensure_initialized(default_max: int) -> void:
	if hp < 0:
		max_hp = default_max
		hp = max_hp

func set_hp(value: int) -> void:
	hp = clamp(value, 0, max_hp)

func set_max_hp(value: int) -> void:
	max_hp = value
	hp = clamp(hp, 0, max_hp)

func add_enemy_defeat(amount: int = 1) -> void:
	enemies_defeated += amount

func set_enemy_defeats(value: int) -> void:
	enemies_defeated = max(0, value)

func level_key(scene: Node) -> String:
	return scene.scene_file_path

func capture_level_start(scene: Node) -> void:
	var key := level_key(scene)

	if not level_start_hp.has(key):
		level_start_hp[key] = hp

	if not level_start_enemies.has(key):
		level_start_enemies[key] = enemies_defeated

func reset_to_level_start(scene: Node) -> void:
	var key := level_key(scene)

	if level_start_hp.has(key):
		hp = int(level_start_hp[key])
	else:
		# fallback: treat current hp as level-start if missing
		level_start_hp[key] = hp

	if level_start_enemies.has(key):
		enemies_defeated = int(level_start_enemies[key])
	else:
		# fallback: treat current count as level-start if missing
		level_start_enemies[key] = enemies_defeated
