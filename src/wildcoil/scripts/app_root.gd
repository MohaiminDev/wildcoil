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
	paused_overlay.visible = false

func _show_character_select() -> void:
	mode = "character_select"
	_ensure_title_layer()
	label.text = "Choose Hero\n\n1 / R - Raya Flint\nBalanced mechanic, wrench fighter\n\n2 / N - Nika Sol\nFast scout, dash fighter"

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
	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.08, 0.1)
	bg.size = Vector2(1280, 720)
	title_layer.add_child(bg)
	for i in range(8):
		var glow := ColorRect.new()
		glow.color = Color(0.1, 0.85, 0.45, 0.35)
		glow.position = Vector2(60 + i * 160, 510 - (i % 2) * 36)
		glow.size = Vector2(22, 70)
		title_layer.add_child(glow)
	label = Label.new()
	label.position = Vector2(255, 205)
	label.size = Vector2(770, 270)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.62))
	title_layer.add_child(label)
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
