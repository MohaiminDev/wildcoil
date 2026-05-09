extends CanvasLayer
class_name ArcadeCombatFx

const SCREEN_SIZE := Vector2(1280, 720)

func _ready() -> void:
	layer = 25

func show_stage_card(stage_title: String, objective: String, wave_index: int) -> void:
	var title := "ROUND %d  |  %s" % [wave_index + 1, stage_title.to_upper()]
	var body := "%s\nCOMBO hits build special meter. Clear the arena to advance." % objective
	_flash_banner(title, body, Color(0.05, 0.06, 0.08, 0.86), Color(0.24, 1.0, 0.64), 0.25, 1.75)

func show_boss_intro(boss_name: String, hazard: String) -> void:
	var hazard_text := hazard.replace("_", " ").to_upper()
	_flash_banner("BOSS: %s" % boss_name.to_upper(), "Arena hazard: %s" % hazard_text, Color(0.18, 0.04, 0.03, 0.90), Color(1.0, 0.32, 0.15), 0.15, 2.0)

func show_victory_banner(text: String) -> void:
	_flash_banner("STAGE CLEAR", text, Color(0.04, 0.10, 0.08, 0.92), Color(0.35, 1.0, 0.72), 0.2, 2.5)

func spawn_hit_spark(screen_position: Vector2, color: Color = Color(1.0, 0.78, 0.18), big: bool = false) -> void:
	var root := Node2D.new()
	root.position = screen_position
	add_child(root)
	var radius := 34.0 if big else 22.0
	for i in range(8):
		var shard := ColorRect.new()
		shard.color = color
		shard.size = Vector2(radius * 0.55, 5)
		shard.position = Vector2(-2, -2)
		shard.rotation = TAU * float(i) / 8.0
		root.add_child(shard)
	var flash := Polygon2D.new()
	flash.polygon = _burst_points(radius)
	flash.color = Color(1.0, 0.95, 0.65, 0.72)
	root.add_child(flash)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(root, "scale", Vector2(1.7, 1.7), 0.18)
	tween.tween_property(root, "modulate:a", 0.0, 0.18)
	tween.chain().tween_callback(root.queue_free)

func spawn_attack_arc(screen_position: Vector2, facing: int, color: Color = Color(1.0, 0.85, 0.24, 0.52)) -> void:
	var arc := Polygon2D.new()
	arc.position = screen_position
	arc.polygon = PackedVector2Array([
		Vector2(0, -42),
		Vector2(82 * facing, -30),
		Vector2(102 * facing, 3),
		Vector2(64 * facing, 28),
		Vector2(0, 38),
		Vector2(34 * facing, 0)
	])
	arc.color = color
	add_child(arc)
	var edge := Line2D.new()
	edge.points = PackedVector2Array([
		Vector2(6 * facing, -43),
		Vector2(86 * facing, -28),
		Vector2(110 * facing, 2),
		Vector2(68 * facing, 30)
	])
	edge.default_color = Color(1.0, 0.95, 0.58, 0.88)
	edge.width = 4.0
	arc.add_child(edge)
	var speed_line := Line2D.new()
	speed_line.points = PackedVector2Array([
		Vector2(-42 * facing, -18),
		Vector2(66 * facing, -5)
	])
	speed_line.default_color = Color(1.0, 1.0, 1.0, 0.46)
	speed_line.width = 3.0
	arc.add_child(speed_line)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(arc, "scale", Vector2(1.25, 1.25), 0.14)
	tween.tween_property(arc, "modulate:a", 0.0, 0.14)
	tween.chain().tween_callback(arc.queue_free)

func spawn_damage_number(screen_position: Vector2, amount: int, combo_count: int) -> void:
	var number := Label.new()
	number.text = "-%d  COMBO %d" % [amount, combo_count]
	number.position = screen_position + Vector2(-24, -48)
	number.add_theme_font_size_override("font_size", 20)
	number.add_theme_color_override("font_color", Color(1.0, 0.88, 0.36))
	add_child(number)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(number, "position", number.position + Vector2(0, -38), 0.55)
	tween.tween_property(number, "modulate:a", 0.0, 0.55)
	tween.chain().tween_callback(number.queue_free)

func _flash_banner(title: String, body: String, bg_color: Color, accent_color: Color, y_ratio: float, hold: float) -> void:
	var group := Control.new()
	group.position = Vector2(0, SCREEN_SIZE.y * y_ratio)
	group.size = Vector2(SCREEN_SIZE.x, 132)
	add_child(group)
	var bg := ColorRect.new()
	bg.color = bg_color
	bg.size = group.size
	group.add_child(bg)
	var accent := ColorRect.new()
	accent.color = accent_color
	accent.position = Vector2(0, 0)
	accent.size = Vector2(SCREEN_SIZE.x, 8)
	group.add_child(accent)
	var label := Label.new()
	label.position = Vector2(70, 18)
	label.size = Vector2(1140, 96)
	label.text = "%s\n%s" % [title, body]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 27)
	label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.66))
	group.add_child(label)
	group.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(group, "modulate:a", 1.0, 0.12)
	tween.tween_interval(hold)
	tween.tween_property(group, "modulate:a", 0.0, 0.30)
	tween.tween_callback(group.queue_free)

func _burst_points(radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in range(16):
		var scale := radius if i % 2 == 0 else radius * 0.34
		var angle := TAU * float(i) / 16.0
		points.append(Vector2(cos(angle) * scale, sin(angle) * scale))
	return points
