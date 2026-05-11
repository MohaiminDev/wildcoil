extends CanvasLayer
class_name ArcadeCombatFx

const SCREEN_SIZE := Vector2(1280, 720)
const STAGE_CARD_WIDTH := 760.0
const STAGE_CARD_HEIGHT := 58.0
const STAGE_CARD_FONT_SIZE := 18
const STAGE_CARD_BODY_LIMIT := 46
const STAGE_CARD_Y_RATIO := 0.17
const BANNER_GROUP_NAME := "arcade-fx-banner"
const BANNER_GROUP_META := "arcade_fx_banner"

var non_bloody_impact_palette := {
	"spark": Color(1.0, 0.78, 0.20, 0.90),
	"flash": Color(1.0, 0.96, 0.68, 0.72),
	"luma": Color(0.25, 1.0, 0.70, 0.42),
	"smoke": Color(0.06, 0.065, 0.060, 0.26)
}

func _ready() -> void:
	layer = 25

func show_stage_card(stage_title: String, objective: String, wave_index: int) -> void:
	var title := "ROUND %d  |  %s" % [wave_index + 1, stage_title.to_upper()]
	var body := objective
	_flash_banner(title, body, Color(0.05, 0.06, 0.08, 0.52), Color(0.24, 1.0, 0.64), STAGE_CARD_Y_RATIO, 1.35, STAGE_CARD_HEIGHT, STAGE_CARD_FONT_SIZE, STAGE_CARD_BODY_LIMIT, STAGE_CARD_WIDTH)

func show_stage_event(title: String, body: String) -> void:
	_flash_banner(title.to_upper(), body, Color(0.08, 0.035, 0.02, 0.72), Color(0.35, 1.0, 0.72), 0.20, 1.1, 74.0, 21, 58, 820.0)

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

func spawn_impact_burst(screen_position: Vector2, facing: int, big: bool = false) -> void:
	var root := Node2D.new()
	root.name = "non-bloody-impact-burst"
	root.position = screen_position
	add_child(root)
	_build_hit_stop_flash(root, big)
	_build_impact_ring(root, big)
	_build_directional_speed_lines(root, facing, big)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(root, "scale", Vector2(1.22, 1.22), 0.16 if big else 0.12)
	tween.tween_property(root, "modulate:a", 0.0, 0.22 if big else 0.16)
	tween.chain().tween_callback(root.queue_free)

func _build_hit_stop_flash(root: Node2D, big: bool) -> void:
	var flash := Polygon2D.new()
	flash.name = "hit-stop-flash"
	var radius := 54.0 if big else 34.0
	flash.polygon = _burst_points(radius)
	flash.color = non_bloody_impact_palette["flash"]
	root.add_child(flash)
	var smoke := Polygon2D.new()
	smoke.name = "impact-smoke-pop"
	smoke.polygon = _burst_points(radius * 1.35)
	smoke.color = non_bloody_impact_palette["smoke"]
	root.add_child(smoke)

func _build_impact_ring(root: Node2D, big: bool) -> void:
	var ring := Line2D.new()
	ring.name = "impact-timing-ring"
	ring.default_color = non_bloody_impact_palette["luma"] if big else non_bloody_impact_palette["spark"]
	ring.width = 4.0 if big else 3.0
	var radius := 48.0 if big else 31.0
	var points := PackedVector2Array()
	for i in range(25):
		var angle := TAU * float(i) / 24.0
		points.append(Vector2(cos(angle) * radius, sin(angle) * radius * 0.62))
	ring.points = points
	root.add_child(ring)

func _build_directional_speed_lines(root: Node2D, facing: int, big: bool) -> void:
	var direction := 1.0 if facing >= 0 else -1.0
	var line_count := 7 if big else 5
	for i in range(line_count):
		var line := Line2D.new()
		line.name = "impact-speed-line"
		line.default_color = Color(1.0, 0.92, 0.52, 0.58)
		line.width = 4.0 if big else 3.0
		var y := -30.0 + float(i) * (60.0 / float(maxi(line_count - 1, 1)))
		var length := 74.0 + float(i % 2) * 22.0
		line.points = PackedVector2Array([
			Vector2(-direction * 16.0, y),
			Vector2(-direction * length, y - 8.0 + float(i % 3) * 8.0)
		])
		root.add_child(line)

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

func _flash_banner(title: String, body: String, bg_color: Color, accent_color: Color, y_ratio: float, hold: float, banner_height := 132.0, font_size := 27, body_limit := 72, banner_width := 0.0) -> void:
	_clear_existing_banners()
	var banner_width_resolved := SCREEN_SIZE.x if banner_width <= 0.0 else minf(banner_width, SCREEN_SIZE.x)
	var group := Control.new()
	group.name = BANNER_GROUP_NAME
	group.set_meta(BANNER_GROUP_META, true)
	group.position = Vector2((SCREEN_SIZE.x - banner_width_resolved) * 0.5, SCREEN_SIZE.y * y_ratio)
	group.size = Vector2(banner_width_resolved, banner_height)
	group.clip_contents = true
	add_child(group)
	var bg := ColorRect.new()
	bg.color = bg_color
	bg.size = group.size
	group.add_child(bg)
	var accent := ColorRect.new()
	accent.color = accent_color
	accent.position = Vector2(0, 0)
	accent.size = Vector2(banner_width_resolved, 5)
	group.add_child(accent)
	var label := Label.new()
	label.position = Vector2(28, 7)
	label.size = Vector2(maxf(banner_width_resolved - 56.0, 160.0), banner_height - 14)
	label.text = "%s\n%s" % [title, _short_banner_body(body, body_limit)]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.66))
	group.add_child(label)
	group.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(group, "modulate:a", 1.0, 0.12)
	tween.tween_interval(hold)
	tween.tween_property(group, "modulate:a", 0.0, 0.30)
	tween.tween_callback(group.queue_free)

func _clear_existing_banners() -> void:
	for child in get_children():
		if child == null or not is_instance_valid(child):
			continue
		if not child.has_meta(BANNER_GROUP_META) and not str(child.name).contains(BANNER_GROUP_NAME):
			continue
		if child is CanvasItem:
			child.visible = false
		child.queue_free()

func _short_banner_body(body: String, limit := 72) -> String:
	var clean := body.replace("\n", " | ")
	if clean.length() <= limit:
		return clean
	return "%s..." % clean.substr(0, maxi(limit - 3, 1))

func _burst_points(radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in range(16):
		var scale := radius if i % 2 == 0 else radius * 0.34
		var angle := TAU * float(i) / 16.0
		points.append(Vector2(cos(angle) * scale, sin(angle) * scale))
	return points
