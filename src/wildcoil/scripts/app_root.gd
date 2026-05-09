extends Node2D

const STAGE_SCENE := preload("res://scenes/stages/sunset_overpass.tscn")
const DEFAULT_HERO_ROSTER := [
	{"id": "raya_flint", "name": "Raya Flint", "role": "Balanced mechanic", "capability_summary": "Reliable combos and field repair.", "specialty": "All-round pressure", "weakness": "No extreme matchup advantage", "stats": {"power": 3, "speed": 3, "control": 3, "defense": 3}},
	{"id": "kian_vale", "name": "Kian Vale", "role": "Field medic", "capability_summary": "Controls crowds and protects creatures.", "specialty": "Crowd control and recovery", "weakness": "Lower raw damage", "stats": {"power": 2, "speed": 3, "control": 5, "defense": 3}},
	{"id": "nika_sol", "name": "Nika Sol", "role": "Agile scout", "capability_summary": "Turns the arena into a race line.", "specialty": "Speed and aerial burst", "weakness": "Low health", "stats": {"power": 2, "speed": 5, "control": 2, "defense": 1}},
	{"id": "tor_bram", "name": "Tor Bram", "role": "Heavy defender", "capability_summary": "Absorbs hits and breaks enemy lines.", "specialty": "Power, armor, and throws", "weakness": "Slowest hero", "stats": {"power": 5, "speed": 1, "control": 3, "defense": 5}}
]

var mode := "title"
var selected_hero := "raya_flint"
var selected_hero_index := 0
var hero_roster: Array = []
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
var controls_label: Label
var paused_overlay: ColorRect
var hero_cards: Array = []
var stage1_demo_active := false

func _ready() -> void:
	DisplayServer.window_set_title("Rift Road: Beasts of the Afterglow")
	hero_roster = _load_hero_roster()
	var stage_text := FileAccess.get_file_as_string("res://data/stages.json")
	var stage_data = JSON.parse_string(stage_text)
	if typeof(stage_data) == TYPE_DICTIONARY:
		final_ending = stage_data.get("final_ending", final_ending)
	_show_title()
	if OS.get_environment("WILDCOIL_AUTOSTART_STAGE1") == "1":
		call_deferred("_start_stage1_demo")

func _start_stage1_demo() -> void:
	selected_hero = "raya_flint"
	_start_campaign()
	await get_tree().process_frame
	await get_tree().process_frame
	if stage != null and is_instance_valid(stage) and stage.player != null:
		stage.player.max_health = 999
		stage.player.health = 999
		stage.player.attack_damage = mini(stage.player.attack_damage, 6)
		stage.player.special_damage = mini(stage.player.special_damage, 14)
		stage.player.invulnerable_timer = 0.0
		if stage.has_method("set_demo_autoplay"):
			stage.set_demo_autoplay(true)
		stage1_demo_active = true

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_F3 and stage != null:
		stage.debug_overlay.toggle()
		return
	if event.keycode == KEY_ESCAPE:
		if mode == "stage":
			_toggle_pause()
		elif mode == "hero_preview":
			_show_character_select()
		elif mode == "game_over" or mode == "complete":
			_show_title()
		return
	if mode == "title":
		_show_character_select()
	elif mode == "character_select":
		if _handle_roster_key(event.keycode):
			_show_hero_capability_preview()
		elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			_show_hero_capability_preview()
	elif mode == "hero_preview":
		if _handle_roster_key(event.keycode):
			_show_hero_capability_preview()
		elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER or event.keycode == KEY_J:
			_confirm_hero_and_start()
	elif mode == "stage_clear":
		_start_next_campaign_stage()
	elif mode == "game_over" or mode == "complete":
		_show_title()

func _show_title() -> void:
	_clear_stage()
	stage1_demo_active = false
	mode = "title"
	_ensure_title_layer()
	label.position = Vector2(190, 58)
	label.size = Vector2(900, 190)
	label.add_theme_font_size_override("font_size", 32)
	label.text = "RIFT ROAD: BEASTS OF THE AFTERGLOW\n\nPress any key"
	controls_label.text = "Move WASD / Arrows   Attack J   Jump K   Special L   Dash I   Pause Esc"
	_set_hero_cards_visible(false)
	paused_overlay.visible = false

func _show_character_select() -> void:
	mode = "character_select"
	_ensure_title_layer()
	label.position = Vector2(180, 58)
	label.size = Vector2(920, 150)
	label.add_theme_font_size_override("font_size", 32)
	label.text = "ARCADE CAMPAIGN\n\nChoose Hero"
	controls_label.text = "1/R Raya   2/K Kian   3/N Nika   4/T Tor   Enter: capabilities"
	_set_hero_cards_visible(true)
	_refresh_hero_card_selection()

func _show_hero_capability_preview() -> void:
	mode = "hero_preview"
	_ensure_title_layer()
	selected_hero = _selected_hero_profile().get("id", "raya_flint")
	var hero := _selected_hero_profile()
	var stats: Dictionary = hero.get("stats", {})
	label.position = Vector2(170, 48)
	label.size = Vector2(940, 260)
	label.add_theme_font_size_override("font_size", 24)
	label.text = "CAPABILITIES\n%s\n%s\n\n%s\nSpecialty: %s\nWeakness: %s\n\nPower %s  Speed %s  Control %s  Defense %s" % [
		hero.get("name", "Raya Flint"),
		hero.get("role", "Balanced mechanic"),
		hero.get("capability_summary", "Ready for the road."),
		hero.get("specialty", "Balanced pressure"),
		hero.get("weakness", "None listed"),
		str(stats.get("power", 3)),
		str(stats.get("speed", 3)),
		str(stats.get("control", 3)),
		str(stats.get("defense", 3))
	]
	controls_label.text = "Enter/J Start Stage 1   1-4 Change Hero   Esc Back"
	_set_hero_cards_visible(true)
	_refresh_hero_card_selection()

func _confirm_hero_and_start() -> void:
	selected_hero = _selected_hero_profile().get("id", "raya_flint")
	_start_campaign()

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
		if stage.has_method("set_demo_autoplay"):
			stage.set_demo_autoplay(false)
		stage.queue_free()
	stage = null
	stage1_demo_active = false

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
	controls_label = Label.new()
	controls_label.position = Vector2(210, 648)
	controls_label.size = Vector2(860, 42)
	controls_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	controls_label.add_theme_font_size_override("font_size", 18)
	controls_label.add_theme_color_override("font_color", Color(0.72, 1.0, 0.82))
	title_layer.add_child(controls_label)
	_build_roster_preview(title_layer)
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
	var generated_background := _load_runtime_texture("res://assets/stage1/source/generated_stage1_background.png")
	if generated_background != null:
		var image := Sprite2D.new()
		image.name = "title-generated-stage1-background"
		image.texture = generated_background
		image.centered = false
		image.scale = Vector2(1280.0 / generated_background.get_width(), 720.0 / generated_background.get_height())
		parent.add_child(image)
		var scrim := ColorRect.new()
		scrim.name = "title-readable-scrim"
		scrim.color = Color(0.02, 0.018, 0.026, 0.46)
		scrim.size = Vector2(1280, 720)
		parent.add_child(scrim)
		return
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
	if ResourceLoader.exists("res://assets/stage1/source/generated_stage1_background.png"):
		return
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

func _build_roster_preview(parent: Node) -> void:
	hero_cards.clear()
	var positions := [Vector2(30, 350), Vector2(342, 350), Vector2(654, 350), Vector2(966, 350)]
	for index in range(mini(hero_roster.size(), 4)):
		hero_cards.append(_build_hero_card(parent, positions[index], index, hero_roster[index]))

func _build_hero_card(parent: Node, pos: Vector2, index: int, profile: Dictionary) -> Node2D:
	var card := Node2D.new()
	card.name = "hero-card-%s" % str(profile.get("id", "hero"))
	card.position = pos
	parent.add_child(card)
	var panel := ColorRect.new()
	panel.name = "selection-panel"
	panel.color = Color(0.08, 0.085, 0.105, 0.92)
	panel.size = Vector2(284, 198)
	card.add_child(panel)
	var accent_bar := ColorRect.new()
	accent_bar.color = _hero_accent_color(str(profile.get("id", "")))
	accent_bar.size = Vector2(284, 8)
	card.add_child(accent_bar)
	var sprite_path := _hero_sprite_path(str(profile.get("id", "")))
	var texture := _load_runtime_texture(sprite_path)
	if texture != null:
		var hero_sprite := Sprite2D.new()
		hero_sprite.name = "hero-card-%s-sprite" % str(profile.get("name", "hero")).to_lower().replace(" ", "-")
		hero_sprite.texture = texture
		hero_sprite.centered = true
		hero_sprite.position = Vector2(76, 124)
		var scale_factor: float = minf(104.0 / texture.get_width(), 142.0 / texture.get_height())
		hero_sprite.scale = Vector2(scale_factor, scale_factor)
		card.add_child(hero_sprite)
	else:
		_build_planned_hero_badge(card, str(profile.get("id", "")))
	var text := Label.new()
	text.position = Vector2(132, 34)
	text.size = Vector2(134, 118)
	var stats: Dictionary = profile.get("stats", {})
	text.text = "%d\n%s\n%s\nP%d S%d C%d D%d" % [
		index + 1,
		profile.get("name", "Hero"),
		profile.get("role", "fighter"),
		int(stats.get("power", 3)),
		int(stats.get("speed", 3)),
		int(stats.get("control", 3)),
		int(stats.get("defense", 3))
	]
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.add_theme_font_size_override("font_size", 16)
	text.add_theme_color_override("font_color", Color(1.0, 0.9, 0.68))
	card.add_child(text)
	return card

func _build_planned_hero_badge(card: Node2D, hero_id: String) -> void:
	var badge := ColorRect.new()
	badge.position = Vector2(24, 48)
	badge.size = Vector2(92, 112)
	badge.color = Color(0.03, 0.04, 0.045, 0.74)
	card.add_child(badge)
	var border := Line2D.new()
	border.default_color = _hero_accent_color(hero_id)
	border.width = 2.0
	border.points = PackedVector2Array([Vector2(24, 48), Vector2(116, 48), Vector2(116, 160), Vector2(24, 160), Vector2(24, 48)])
	card.add_child(border)
	var icon := Label.new()
	icon.position = Vector2(29, 76)
	icon.size = Vector2(84, 24)
	icon.text = "PLANNED HERO"
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.add_theme_font_size_override("font_size", 10)
	icon.add_theme_color_override("font_color", _hero_accent_color(hero_id))
	card.add_child(icon)
	var meter_names := ["P", "S", "C", "D"]
	for i in range(meter_names.size()):
		var meter := ColorRect.new()
		meter.position = Vector2(36, 116 + i * 10)
		meter.size = Vector2(62, 5)
		meter.color = _hero_accent_color(hero_id).darkened(float(i) * 0.08)
		card.add_child(meter)

func _hero_sprite_path(hero_id: String) -> String:
	match hero_id:
		"raya_flint":
			return "res://assets/stage1/actors/raya_flint_idle.png"
		"nika_sol":
			return "res://assets/stage1/actors/nika_sol_idle.png"
		_:
			return ""

func _hero_body_color(hero_id: String) -> Color:
	match hero_id:
		"kian_vale":
			return Color(0.22, 0.72, 0.42)
		"nika_sol":
			return Color(0.55, 0.12, 0.95)
		"tor_bram":
			return Color(0.55, 0.56, 0.58)
		_:
			return Color(0.95, 0.36, 0.12)

func _hero_accent_color(hero_id: String) -> Color:
	match hero_id:
		"kian_vale":
			return Color(0.55, 1.0, 0.62)
		"nika_sol":
			return Color(0.86, 0.78, 1.0)
		"tor_bram":
			return Color(0.78, 0.22, 0.16)
		_:
			return Color(1.0, 0.76, 0.36)

func _hero_silhouette(hero_id: String) -> PackedVector2Array:
	if hero_id == "tor_bram":
		return PackedVector2Array([Vector2(-48, 24), Vector2(-42, -76), Vector2(40, -78), Vector2(52, 24)])
	if hero_id == "kian_vale":
		return PackedVector2Array([Vector2(-30, 24), Vector2(-22, -74), Vector2(24, -76), Vector2(34, 24)])
	return PackedVector2Array([Vector2(-36, 24), Vector2(-24, -72), Vector2(24, -76), Vector2(38, 24)])

func _load_hero_roster() -> Array:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/characters.json"))
	if typeof(parsed) != TYPE_DICTIONARY:
		return DEFAULT_HERO_ROSTER.duplicate(true)
	var heroes: Array = parsed.get("heroes", [])
	if heroes.size() < 4:
		return DEFAULT_HERO_ROSTER.duplicate(true)
	return heroes

func _selected_hero_profile() -> Dictionary:
	if hero_roster.is_empty():
		hero_roster = DEFAULT_HERO_ROSTER.duplicate(true)
	selected_hero_index = clampi(selected_hero_index, 0, hero_roster.size() - 1)
	return hero_roster[selected_hero_index]

func _handle_roster_key(keycode: int) -> bool:
	match keycode:
		KEY_1, KEY_R:
			selected_hero_index = 0
			return true
		KEY_2, KEY_K:
			selected_hero_index = 1
			return true
		KEY_3, KEY_N:
			selected_hero_index = 2
			return true
		KEY_4, KEY_T:
			selected_hero_index = 3
			return true
		KEY_LEFT, KEY_A:
			selected_hero_index = wrapi(selected_hero_index - 1, 0, hero_roster.size())
			return true
		KEY_RIGHT, KEY_D:
			selected_hero_index = wrapi(selected_hero_index + 1, 0, hero_roster.size())
			return true
	return false

func _refresh_hero_card_selection() -> void:
	for index in range(hero_cards.size()):
		var card = hero_cards[index]
		if card == null or not is_instance_valid(card):
			continue
		var panel = card.get_node_or_null("selection-panel")
		if panel != null:
			panel.color = Color(0.14, 0.11, 0.06, 0.96) if index == selected_hero_index else Color(0.08, 0.085, 0.105, 0.92)
		card.scale = Vector2(1.04, 1.04) if index == selected_hero_index else Vector2.ONE

func _load_runtime_texture(path: String) -> Texture2D:
	if not ResourceLoader.exists(path):
		return null
	return load(path)

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
