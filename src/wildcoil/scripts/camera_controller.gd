extends Camera2D
class_name CameraController

var target: Node2D
var arena_min_x := 0.0
var arena_max_x := 1280.0

func _process(delta: float) -> void:
	if target == null:
		return
	var desired := target.global_position
	desired.x = clamp(desired.x, arena_min_x + 360.0, arena_max_x - 360.0)
	global_position = global_position.lerp(desired, minf(delta * 5.0, 1.0))

