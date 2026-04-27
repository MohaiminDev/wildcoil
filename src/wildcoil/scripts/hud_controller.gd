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
	name_label = _make_label(Vector2(24, 18), "Raya Flint")
	add_child(name_label)
	health_bar = _make_bar(Vector2(24, 46), Vector2(260, 18), Color(0.9, 0.18, 0.12))
	add_child(health_bar)
	special_bar = _make_bar(Vector2(24, 72), Vector2(220, 14), Color(0.2, 0.72, 1.0))
	add_child(special_bar)
	score_label = _make_label(Vector2(1010, 22), "Score 0 | Luma 0")
	add_child(score_label)
	objective_label = _make_label(Vector2(470, 18), "Objective: Clear the roadblock")
	objective_label.size = Vector2(420, 36)
	objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(objective_label)
	combo_label = _make_label(Vector2(1030, 58), "")
	combo_label.add_theme_font_size_override("font_size", 20)
	combo_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.2))
	add_child(combo_label)
	boss_label = _make_label(Vector2(500, 650), "")
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
		return
	boss_bar.visible = true
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
