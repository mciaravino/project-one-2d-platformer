# res://ui/enemy_bars.gd
extends Node2D
class_name EnemyBars

@export var bar_size := Vector2(12, 4)
@export var bar_gap := 2
@export var y_offset := 0.0

# Use Object so typed GDScript doesn't complain about get_bars_data()
var enemy: Object = null

var _pattern: Array = []
var _cleared: Array = []

func bind_enemy(e: Object) -> void:
	enemy = e

func _process(_delta: float) -> void:
	if enemy == null:
		return
	if not enemy.has_method("get_bars_data"):
		return

	# Call dynamically (avoids "Node has no method get_bars_data" editor error)
	var data: Dictionary = enemy.call("get_bars_data")
	set_bars(data.get("pattern", []), data.get("cleared", []))

func set_bars(pattern: Array, cleared: Array) -> void:
	_pattern = pattern
	_cleared = cleared
	queue_redraw()

func _draw() -> void:
	var n := _pattern.size()
	if n == 0:
		return

	var total_w := n * bar_size.x + (n - 1) * bar_gap
	var start_x := -total_w * 0.5
	var y := y_offset

	for i in range(n):
		var rect := Rect2(
			Vector2(start_x + i * (bar_size.x + bar_gap), y),
			bar_size
		)

		var col: Color
		if i < _cleared.size() and _cleared[i]:
			col = Color(0.5, 0.5, 0.5) # gray
		else:
			# Enemy.DamageChannel: { AUTO=0, RED=1, BLUE=2 }
			var ch := int(_pattern[i])
			if ch == 2: # BLUE
				col = Color(0.2, 0.6, 1.0)
			else:       # RED
				col = Color(1.0, 0.3, 0.3)

		draw_rect(rect, col, true)
