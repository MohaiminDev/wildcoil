extends Node2D

const STAGE_SCENE := preload("res://scenes/stages/sunset_overpass.tscn")

var mode := "title"
var selected_hero := "raya_flint"
var stage_order := [
	"sunset_overpass",
	"glassleaf_jungle",
	"ember_rest_market",
	"mineral_rail",
	"ashforge_town",
	"storm_plain_chase",
	"the_underroot",
	"deep_crown_citadel"
]
var current_stage_index := 0
var final_ending := "The Sundrifter drives into dawn. The road's open."
var stage
var title_layer: CanvasLayer
var label: Label
var paused_overlay: ColorRect
var hero_cards: Array = []

func _ready() -> void:
	DisplayServer.window_set_title("Rift Road: Beasts of the Afterglow")
	var stage_text := FileAccess.get_file_as_string("res://data/stages.json")
	var stage_data = JSON.parse_string(stage_text)
	if typeof(stage_data) == TYPE_DICTIONARY:
		final_ending = stage_data.get("final_ending", final_ending)
	_show_title()

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_F3 and stage != null:
		stage.debug_overlay.toggle()
		return
	if event.keycode == KEY_ESCAPE:
		if mode == "stage":
			_toggle_pause()
		elif mode == "game_over" or mode == "complete":
			_show_title()
		return
	if mode == "title":
		_show_character_select()
	elif mode == "character_select":
		if event.keycode == KEY_1 or event.keycode == KEY_R:
			selected_hero = "raya_flint"
			_start_campaign()
		elif event.keycode == KEY_2 or event.keycode == KEY_N:
			selected_hero = "nika_sol"
			_start_campaign()
	elif mode == "stage_clear":
		_start_next_campaign_stage()
	elif mode == "game_over" or mode == "complete":
		_show_title()

func _show_title() -> void:
	_clear_stage()
	mode = "title"
	_ensure_title_layer()
	label.text = "RIFT ROAD: BEASTS OF THE AFTERGLOW\n\nPress any key"
	_set_hero_cards_visible(false)
	paused_overlay.visible = false

func _show_character_select() -> void:
	mode = "character_select"
	_ensure_title_layer()
	label.text = "ARCADE CAMPAIGN\n\nChoose Hero"
	_set_hero_cards_visible(true)

func _start_campaign() -> void:
	current_stage_index = 0
	_start_stage(stage_order[current_stage_index])

func _start_stage(next_stage_id: String) -> void:
	mode = "stage"
	title_layer.visible = false
	stage = STAGE_SCENE.instantiate()
	stage.hero_id = selected_hero
	stage.stage_id = next_stage_id
	stage.game_over.connect(_on_game_over)
	stage.stage_completed.connect(_on_stage_completed)
	add_child(stage)

func _on_game_over() -> void:
	mode = "game_over"
	_ensure_title_layer()
	title_layer.visible = true
	label.text = "GAME OVER\n\nThe road can still be won.\nPress any key"

func _on_stage_completed(text: String) -> void:
	current_stage_index += 1
	_ensure_title_layer()
	title_layer.visible = true
	if current_stage_index >= stage_order.size():
		mode = "complete"
		label.text = "FINAL CLEAR\n\n%s\n\n%s\n\nPress any key" % [text, final_ending]
	else:
		mode = "stage_clear"
		label.text = "STAGE CLEAR\n\n%s\n\nNext: %s\nPress any key" % [text, stage_order[current_stage_index].replace("_", " ").to_upper()]

func _start_next_campaign_stage() -> void:
	_clear_stage()
	_start_stage(stage_order[current_stage_index])

func _toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	paused_overlay.visible = get_tree().paused

func _clear_stage() -> void:
	get_tree().paused = false
	if stage != null and is_instance_valid(stage):
		stage.queue_free()
	stage = null

func _ensure_title_layer() -> void:
	if title_layer != null:
		title_layer.visible = true
		return
	title_layer = CanvasLayer.new()
	add_child(title_layer)
	_build_title_backdrop(title_layer)
	_draw_title_vehicle(title_layer)
	label = Label.new()
	label.position = Vector2(190, 58)
	label.size = Vector2(900, 190)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 32)
	label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.62))
	title_layer.add_child(label)
	hero_cards.append(_build_hero_card(title_layer, Vector2(230, 330), "1 / R", "Raya Flint", "Balanced mechanic", Color(0.95, 0.36, 0.12), Color(1.0, 0.76, 0.36)))
	hero_cards.append(_build_hero_card(title_layer, Vector2(710, 330), "2 / N", "Nika Sol", "Fast scout", Color(0.55, 0.12, 0.95), Color(0.86, 0.78, 1.0)))
	_set_hero_cards_visible(false)
	paused_overlay = ColorRect.new()
	paused_overlay.color = Color(0, 0, 0, 0.62)
	paused_overlay.size = Vector2(1280, 720)
	paused_overlay.visible = false
	title_layer.add_child(paused_overlay)
	var pause_text := Label.new()
	pause_text.text = "PAUSED\nEsc to resume"
	pause_text.position = Vector2(520, 300)
	pause_text.add_theme_font_size_override("font_size", 30)
	paused_overlay.add_child(pause_text)

func _build_title_backdrop(parent: Node) -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.055, 0.075)
	bg.size = Vector2(1280, 720)
	parent.add_child(bg)
	for band in range(16):
		var strip := ColorRect.new()
		strip.color = Color(0.05 + band * 0.008, 0.06 + band * 0.006, 0.10 + band * 0.010)
		strip.position = Vector2(0, band * 32)
		strip.size = Vector2(1280, 34)
		parent.add_child(strip)
	for i in range(11):
		var crystal := ColorRect.new()
		crystal.color = Color(0.15, 0.95, 0.62, 0.42)
		crystal.position = Vector2(36 + i * 124, 575 - (i % 4) * 34)
		crystal.size = Vector2(20 + (i % 3) * 8, 104)
		parent.add_child(crystal)
	for i in range(5):
		var ruin := ColorRect.new()
		ruin.color = Color(0.12, 0.11, 0.15, 0.85)
		ruin.position = Vector2(90 + i * 255, 260 - (i % 2) * 45)
		ruin.size = Vector2(120, 300)
		parent.add_child(ruin)

func _draw_title_vehicle(parent: Node) -> void:
	var vehicle := Node2D.new()
	vehicle.position = Vector2(642, 545)
	parent.add_child(vehicle)
	var body := Polygon2D.new()
	body.polygon = PackedVector2Array([Vector2(-180, 28), Vector2(-112, -58), Vector2(82, -66), Vector2(176, -6), Vector2(142, 44), Vector2(-150, 52)])
	body.color = Color(0.88, 0.42, 0.14)
	vehicle.add_child(body)
	var glass := ColorRect.new()
	glass.position = Vector2(-42, -48)
	glass.size = Vector2(86, 30)
	glass.color = Color(0.42, 0.92, 1.0, 0.74)
	vehicle.add_child(glass)
	for wheel_x in [-112, 116]:
		var wheel := Polygon2D.new()
		wheel.polygon = _ellipse_points(Vector2(wheel_x, 56), Vector2(42, 42), 24)
		wheel.color = Color(0.02, 0.02, 0.025)
		vehicle.add_child(wheel)
		var hub := Polygon2D.new()
		hub.polygon = _ellipse_points(Vector2(wheel_x, 56), Vector2(18, 18), 18)
		hub.color = Color(0.94, 0.78, 0.42)
		vehicle.add_child(hub)

func _build_hero_card(parent: Node, pos: Vector2, key_text: String, hero_name: String, role: String, body_color: Color, accent: Color) -> Node2D:
	var card := Node2D.new()
	card.position = pos
	parent.add_child(card)
	var panel := ColorRect.new()
	panel.color = Color(0.08, 0.085, 0.105, 0.92)
	panel.size = Vector2(330, 210)
	card.add_child(panel)
	var accent_bar := ColorRect.new()
	accent_bar.color = accent
	accent_bar.size = Vector2(330, 8)
	card.add_child(accent_bar)
	var silhouette := Polygon2D.new()
	silhouette.position = Vector2(76, 148)
	silhouette.polygon = PackedVector2Array([Vector2(-36, 24), Vector2(-24, -72), Vector2(24, -76), Vector2(38, 24)])
	silhouette.color = body_color
	card.add_child(silhouette)
	var head := Polygon2D.new()
	head.position = Vector2(76, 58)
	head.polygon = _ellipse_points(Vector2.ZERO, Vector2(24, 24), 18)
	head.color = Color(0.72, 0.42, 0.24)
	card.add_child(head)
	var text := Label.new()
	text.position = Vector2(132, 42)
	text.size = Vector2(178, 122)
	text.text = "%s\n%s\n%s" % [key_text, hero_name, role]
	text.add_theme_font_size_override("font_size", 20)
	text.add_theme_color_override("font_color", Color(1.0, 0.9, 0.68))
	card.add_child(text)
	return card

func _set_hero_cards_visible(visible_state: bool) -> void:
	for card in hero_cards:
		if card != null and is_instance_valid(card):
			card.visible = visible_state

func _ellipse_points(center: Vector2, radius: Vector2, count: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in range(count):
		var angle := TAU * float(i) / float(count)
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	return points
