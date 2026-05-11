extends CanvasLayer
class_name HUDController

const VisualAssetLoader := preload("res://scripts/visual_asset_loader.gd")
const PLAYER_PANEL_POS := Vector2(16, 12)
const PLAYER_PANEL_SIZE := Vector2(320, 74)
const PLAYER_PORTRAIT_POS := Vector2(24, 20)
const PLAYER_PORTRAIT_SIZE := Vector2(52, 58)
const PLAYER_NAME_POS := Vector2(94, 18)
const HEALTH_BAR_POS := Vector2(94, 42)
const HEALTH_BAR_SIZE := Vector2(214, 14)
const SPECIAL_BAR_POS := Vector2(94, 62)
const SPECIAL_BAR_SIZE := Vector2(184, 10)
const SCORE_PANEL_POS := Vector2(1000, 14)
const SCORE_PANEL_SIZE := Vector2(256, 54)
const SCORE_LABEL_POS := Vector2(1024, 24)
const SCORE_LABEL_SIZE := Vector2(206, 24)
const COMBO_LABEL_POS := Vector2(1030, 46)
const COMBO_LABEL_SIZE := Vector2(190, 20)
const OBJECTIVE_PANEL_POS := Vector2(418, 12)
const OBJECTIVE_PANEL_SIZE := Vector2(444, 38)
const OBJECTIVE_LABEL_POS := Vector2(442, 21)
const OBJECTIVE_LABEL_SIZE := Vector2(396, 20)

var name_label: Label
var health_bar: ProgressBar
var special_bar: ProgressBar
var score_label: Label
var boss_label: Label
var boss_bar: ProgressBar
var notice_label: Label
var objective_label: Label
var combo_label: Label
var portrait_rect: TextureRect
var health_warning_strip: ColorRect
var visual_assets := VisualAssetLoader.new()
var current_portrait_hero := ""
var notice_timer := 0.0

func _ready() -> void:
	var player_panel := _make_arcade_panel(PLAYER_PANEL_POS, PLAYER_PANEL_SIZE, Color(0.025, 0.028, 0.032, 0.68), Color(0.25, 1.0, 0.66, 0.54))
	add_child(player_panel)
	_make_portrait_frame(PLAYER_PORTRAIT_POS, PLAYER_PORTRAIT_SIZE, Color(1.0, 0.58, 0.24))
	name_label = _make_label(PLAYER_NAME_POS, "Raya Flint")
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.92))
	name_label.add_theme_constant_override("shadow_offset_x", 2)
	name_label.add_theme_constant_override("shadow_offset_y", 2)
	add_child(name_label)
	health_bar = _make_bar(HEALTH_BAR_POS, HEALTH_BAR_SIZE, Color(0.95, 0.16, 0.10))
	add_child(health_bar)
	_make_bar_ticks(HEALTH_BAR_POS, HEALTH_BAR_SIZE, 6)
	special_bar = _make_bar(SPECIAL_BAR_POS, SPECIAL_BAR_SIZE, Color(0.2, 0.72, 1.0))
	add_child(special_bar)
	_make_bar_ticks(SPECIAL_BAR_POS, SPECIAL_BAR_SIZE, 5)
	health_warning_strip = ColorRect.new()
	health_warning_strip.name = "health-warning-strip"
	health_warning_strip.position = Vector2(HEALTH_BAR_POS.x, HEALTH_BAR_POS.y - 5)
	health_warning_strip.size = Vector2(HEALTH_BAR_SIZE.x, 3)
	health_warning_strip.color = Color(1.0, 0.28, 0.10, 0.0)
	add_child(health_warning_strip)
	var score_panel := _make_arcade_panel(SCORE_PANEL_POS, SCORE_PANEL_SIZE, Color(0.025, 0.028, 0.032, 0.62), Color(1.0, 0.68, 0.22, 0.48))
	add_child(score_panel)
	score_label = _make_label(SCORE_LABEL_POS, "Score 0 | Luma 0")
	score_label.size = SCORE_LABEL_SIZE
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_label.add_theme_font_size_override("font_size", 16)
	add_child(score_label)
	var objective_panel := _make_arcade_panel(OBJECTIVE_PANEL_POS, OBJECTIVE_PANEL_SIZE, Color(0.025, 0.028, 0.032, 0.58), Color(0.25, 1.0, 0.66, 0.42))
	add_child(objective_panel)
	objective_label = _make_label(OBJECTIVE_LABEL_POS, "Objective: Clear the roadblock")
	objective_label.size = OBJECTIVE_LABEL_SIZE
	objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	objective_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	objective_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	objective_label.add_theme_font_size_override("font_size", 15)
	add_child(objective_label)
	combo_label = _make_label(COMBO_LABEL_POS, "")
	combo_label.size = COMBO_LABEL_SIZE
	combo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	combo_label.add_theme_font_size_override("font_size", 18)
	combo_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.2))
	add_child(combo_label)
	var boss_panel := _make_arcade_panel(Vector2(390, 638), Vector2(500, 58), Color(0.06, 0.025, 0.02, 0.82), Color(1.0, 0.20, 0.10, 0.58))
	boss_panel.name = "BossPanel"
	boss_panel.visible = false
	add_child(boss_panel)
	boss_label = _make_label(Vector2(424, 646), "")
	boss_label.size = Vector2(432, 22)
	boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(boss_label)
	boss_bar = _make_bar(Vector2(420, 675), Vector2(440, 16), Color(0.86, 0.1, 0.08))
	boss_bar.visible = false
	add_child(boss_bar)
	notice_label = _make_label(Vector2(360, 110), "")
	notice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notice_label.size = Vector2(560, 80)
	add_child(notice_label)

func _process(delta: float) -> void:
	if notice_timer <= 0.0:
		return
	notice_timer -= delta
	if notice_timer <= 0.0:
		clear_notice()

func _make_label(pos: Vector2, text: String) -> Label:
	var label := Label.new()
	label.position = pos
	label.text = text
	label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.72))
	return label

func _make_panel(pos: Vector2, size: Vector2, color: Color, border_color: Color) -> ColorRect:
	var panel := ColorRect.new()
	panel.position = pos
	panel.size = size
	panel.color = color
	var line := Line2D.new()
	line.default_color = border_color
	line.width = 2.0
	line.points = PackedVector2Array([
		Vector2.ZERO,
		Vector2(size.x, 0),
		Vector2(size.x, size.y),
		Vector2(0, size.y),
		Vector2.ZERO
	])
	panel.add_child(line)
	return panel

func _make_arcade_panel(pos: Vector2, size: Vector2, color: Color, border_color: Color) -> ColorRect:
	var panel := _make_panel(pos, size, color, border_color)
	panel.name = "arcade-hud-panel"
	var glow := ColorRect.new()
	glow.name = "panel-inner-glow"
	glow.position = Vector2(5, 5)
	glow.size = Vector2(size.x - 10, 7)
	glow.color = Color(border_color.r, border_color.g, border_color.b, 0.10)
	panel.add_child(glow)
	for i in range(2):
		var slash := Line2D.new()
		slash.name = "panel-corner-slash"
		slash.default_color = Color(border_color.r, border_color.g, border_color.b, 0.62)
		slash.width = 2.0
		var x := size.x - 40.0 - float(i) * 16.0
		slash.points = PackedVector2Array([Vector2(x, size.y), Vector2(x + 28.0, size.y - 28.0)])
		panel.add_child(slash)
	return panel

func _make_portrait_frame(pos: Vector2, size: Vector2, accent: Color) -> void:
	var frame := ColorRect.new()
	frame.name = "asset-backed-portrait-frame"
	frame.position = pos
	frame.size = size
	frame.clip_contents = true
	frame.color = Color(0.02, 0.018, 0.018, 0.78)
	add_child(frame)
	var accent_poly := Polygon2D.new()
	accent_poly.name = "portrait-accent-slash"
	accent_poly.polygon = PackedVector2Array([
		Vector2(0, size.y),
		Vector2(size.x * 0.48, 0),
		Vector2(size.x, 0),
		Vector2(size.x * 0.52, size.y)
	])
	accent_poly.color = Color(accent.r, accent.g, accent.b, 0.18)
	frame.add_child(accent_poly)
	portrait_rect = TextureRect.new()
	portrait_rect.name = "asset-backed-hero-portrait"
	portrait_rect.position = Vector2(-12, -28)
	portrait_rect.size = Vector2(78, 91)
	portrait_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait_rect.modulate = Color(1.05, 1.05, 1.05, 1.0)
	frame.add_child(portrait_rect)
	var border := Line2D.new()
	border.name = "portrait-border"
	border.default_color = Color(accent.r, accent.g, accent.b, 0.78)
	border.width = 2.0
	border.points = PackedVector2Array([Vector2.ZERO, Vector2(size.x, 0), Vector2(size.x, size.y), Vector2(0, size.y), Vector2.ZERO])
	frame.add_child(border)

func _make_bar_ticks(pos: Vector2, size: Vector2, count: int) -> void:
	var ticks := Node2D.new()
	ticks.name = "bar-tick-group"
	ticks.position = pos
	add_child(ticks)
	for i in range(1, count):
		var tick := ColorRect.new()
		tick.name = "bar-tick-%d" % i
		tick.position = Vector2(size.x * float(i) / float(count), 1)
		tick.size = Vector2(2, size.y - 2)
		tick.color = Color(0.02, 0.02, 0.02, 0.46)
		ticks.add_child(tick)

func _make_bar(pos: Vector2, size: Vector2, color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.position = pos
	bar.size = size
	bar.max_value = 100
	bar.value = 100
	bar.show_percentage = false
	var style := StyleBoxFlat.new()
	style.bg_color = color
	bar.add_theme_stylebox_override("fill", style)
	var back := StyleBoxFlat.new()
	back.bg_color = Color(0.02, 0.025, 0.03, 0.92)
	back.border_color = Color(1.0, 0.92, 0.72, 0.38)
	back.set_border_width_all(1)
	bar.add_theme_stylebox_override("background", back)
	return bar

func update_player(player) -> void:
	_update_portrait_texture(player.hero_id)
	name_label.text = player.display_name
	health_bar.max_value = player.max_health
	health_bar.value = player.health
	special_bar.value = player.special_meter
	score_label.text = "Score %d | Luma %d" % [player.score, player.luma_shards]
	health_warning_strip.color = _low_health_warning_color(player.health, player.max_health)
	name_label.add_theme_color_override("font_color", _hero_accent_color(player.hero_id).lightened(0.46))
	update_combo(player.combo_count, player.combo_timer)

func update_boss(boss: Node) -> void:
	if boss == null or not is_instance_valid(boss):
		boss_bar.visible = false
		boss_label.text = ""
		_set_boss_panel_visible(false)
		return
	boss_bar.visible = true
	_set_boss_panel_visible(true)
	boss_label.text = boss.display_name
	boss_bar.max_value = boss.max_health
	boss_bar.value = boss.health

func show_notice(text: String, duration := 0.0) -> void:
	notice_label.text = text
	notice_timer = duration

func clear_notice() -> void:
	notice_label.text = ""
	notice_timer = 0.0

func update_objective(text: String) -> void:
	objective_label.text = "Objective: %s" % text

func update_combo(combo_count: int, combo_timer: float) -> void:
	if combo_count <= 1 or combo_timer <= 0.0:
		combo_label.text = ""
	else:
		combo_label.text = "COMBO x%d" % combo_count

func _set_boss_panel_visible(visible_state: bool) -> void:
	var panel := get_node_or_null("BossPanel")
	if panel != null:
		panel.visible = visible_state

func _update_portrait_texture(hero_id: String) -> void:
	if hero_id == current_portrait_hero or portrait_rect == null:
		return
	current_portrait_hero = hero_id
	portrait_rect.texture = visual_assets.actor_texture(hero_id, "idle")
	portrait_rect.modulate = _hero_accent_color(hero_id).lightened(0.18)

func _hero_accent_color(hero_id: String) -> Color:
	match hero_id:
		"nika_sol":
			return Color(0.64, 0.28, 1.0)
		"raya_flint":
			return Color(1.0, 0.58, 0.24)
		_:
			return Color(0.25, 1.0, 0.66)

func _low_health_warning_color(health: int, max_health: int) -> Color:
	if max_health <= 0:
		return Color(1.0, 0.28, 0.10, 0.0)
	var ratio := float(health) / float(max_health)
	if ratio > 0.34:
		return Color(1.0, 0.28, 0.10, 0.0)
	return Color(1.0, 0.28, 0.10, 0.28 + (0.34 - ratio) * 0.75)
