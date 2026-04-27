extends CanvasLayer
class_name DebugOverlay

var enabled := false
var label: Label

func _ready() -> void:
	label = Label.new()
	label.position = Vector2(18, 112)
	label.add_theme_color_override("font_color", Color(0.7, 1.0, 0.72))
	add_child(label)
	visible = enabled

func toggle() -> void:
	enabled = not enabled
	visible = enabled

func update_debug(player: Node2D, enemy_count: int, collision_summary: String) -> void:
	if not enabled:
		return
	label.text = "FPS %d\nPlayer %.0f, %.0f\nEnemies %d\n%s" % [
		Engine.get_frames_per_second(),
		player.position.x,
		player.position.y,
		enemy_count,
		collision_summary
	]

