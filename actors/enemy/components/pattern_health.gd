# res://enemies/components/pattern_health.gd
extends Node
class_name PatternHealth

signal changed

enum AttackType { LEFT, RIGHT }

@export_range(1, 4) var max_bars: int = 4
@export_range(1, 4) var start_bars: int = 3  # for now: your only enemy has 3

var pattern: Array[int] = []     # values from AttackType
var cleared: Array[bool] = []    # same length as pattern

func _ready() -> void:
	generate_pattern(start_bars)

func generate_pattern(count: int) -> void:
	count = clamp(count, 1, max_bars)
	pattern.clear()
	cleared.clear()

	var rng := RandomNumberGenerator.new()
	rng.randomize()

	for i in range(count):
		var req := AttackType.LEFT if rng.randi_range(0, 1) == 0 else AttackType.RIGHT
		pattern.append(req)
		cleared.append(false)

	emit_signal("changed")

func is_dead() -> bool:
	for d in cleared:
		if not d:
			return false
	return true

func next_index_to_clear() -> int:
	for i in range(cleared.size()):
		if not cleared[i]:
			return i
	return -1

# Returns true if the hit did something (correct attack and progressed the bars)
func apply_attack(attack: int) -> bool:
	var i := next_index_to_clear()
	if i == -1:
		return false

	if pattern[i] != attack:
		return false

	cleared[i] = true
	emit_signal("changed")
	return true
