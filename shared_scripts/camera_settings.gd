extends Node
class_name CameraSettings

static func apply_limits_with_padding(
	camera: Camera2D,
	layer: TileMapLayer,
	pad_top_tiles: int,
	pad_bottom_tiles: int,
	pad_left_tiles: int,
	pad_right_tiles: int
) -> void:
	var used: Rect2i = layer.get_used_rect()
	if used.size == Vector2i.ZERO:
		return

	var ts: Vector2 = Vector2(layer.tile_set.tile_size)
	var scale: Vector2 = layer.global_scale

	var tile_w: float = ts.x * scale.x
	var tile_h: float = ts.y * scale.y

	var half: Vector2 = (ts * scale) / 2.0
	var top_left: Vector2 = layer.to_global(layer.map_to_local(used.position)) - half
	var bottom_right: Vector2 = layer.to_global(layer.map_to_local(used.position + used.size)) - half

	camera.limit_left = int(floor(top_left.x - pad_left_tiles * tile_w))
	camera.limit_top = int(floor(top_left.y - pad_top_tiles * tile_h))
	camera.limit_right = int(ceil(bottom_right.x + pad_right_tiles * tile_w))
	camera.limit_bottom = int(ceil(bottom_right.y + pad_bottom_tiles * tile_h))
