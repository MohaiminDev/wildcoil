extends CanvasLayer
class_name HUDController

var name_label: Label
var health_bar: ProgressBar
var special_bar: ProgressBar
var score_label: Label
var boss_label: Label
var boss_bar: ProgressBar
var notice_label: Label
var objective_label: Label
var combo_label: Label

func _ready() -> void:
	var player_panel := _make_panel(Vector2(16, 12), Vector2(292, 86), Color(0.035, 0.04, 0.05, 0.74), Color(0.25, 1.0, 0.66, 0.46))
	add_child(player_panel)
	name_label = _make_label(Vector2(24, 18), "Raya Flint")
	name_label.add_theme_font_size_override("font_size", 18)
	add_child(name_label)
	health_bar = _make_bar(Vector2(24, 46), Vector2(260, 18), Color(0.9, 0.18, 0.12))
	add_child(health_bar)
	special_bar = _make_bar(Vector2(24, 72), Vector2(220, 14), Color(0.2, 0.72, 1.0))
	add_child(special_bar)
	var score_panel := _make_panel(Vector2(986, 14), Vector2(270, 82), Color(0.035, 0.04, 0.05, 0.70), Color(1.0, 0.68, 0.22, 0.42))
	add_child(score_panel)
	score_label = _make_label(Vector2(1010, 22), "Score 0 | Luma 0")
	score_label.size = Vector2(220, 28)
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(score_label)
	var objective_panel := _make_panel(Vector2(398, 12), Vector2(484, 52), Color(0.035, 0.04, 0.05, 0.64), Color(0.25, 1.0, 0.66, 0.36))
	add_child(objective_panel)
	objective_label = _make_label(Vector2(422, 18), "Objective: Clear the roadblock")
	objective_label.size = Vector2(436, 36)
	objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(objective_label)
	combo_label = _make_label(Vector2(1030, 58), "")
	combo_label.size = Vector2(190, 28)
	combo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	combo_label.add_theme_font_size_override("font_size", 20)
	combo_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.2))
	add_child(combo_label)
	var boss_panel := _make_panel(Vector2(390, 638), Vector2(500, 58), Color(0.06, 0.025, 0.02, 0.78), Color(1.0, 0.20, 0.10, 0.50))
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
	name_label.text = player.display_name
	health_bar.max_value = player.max_health
	health_bar.value = player.health
	special_bar.value = player.special_meter
	score_label.text = "Score %d | Luma %d" % [player.score, player.luma_shards]
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

func show_notice(text: String) -> void:
	notice_label.text = text

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
