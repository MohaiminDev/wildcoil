extends Node2D

const STAGE_SCENE := preload("res://scenes/stages/sunset_overpass.tscn")
const STAGE1_SMOKE_ARG := "--rift-road-smoke-stage1"
const SMOKE_CAPTURE_DIR_PREFIX := "--rift-road-smoke-capture-dir="
const SMOKE_TITLE_CAPTURE_NAME := "stage1-exported-app-smoke-title.png"
const SMOKE_HERO_SELECT_CAPTURE_NAME := "stage1-exported-app-smoke-hero-select.png"
const SMOKE_OPENING_STORY_CAPTURE_NAME := "stage1-exported-app-smoke-opening-story.png"
const SMOKE_GAMEPLAY_CAPTURE_NAME := "stage1-exported-app-smoke-gameplay.png"
const SMOKE_COMBAT_CAPTURE_NAME := "stage1-exported-app-smoke-combat.png"
const SMOKE_PICKUP_CAPTURE_NAME := "stage1-exported-app-smoke-pickups.png"
const SMOKE_ROAD_COLLAPSE_CAPTURE_NAME := "stage1-exported-app-smoke-road-collapse.png"
const SMOKE_BRASK_INTRO_CAPTURE_NAME := "stage1-exported-app-smoke-brask-intro.png"
const SMOKE_STAGE_CLEAR_CAPTURE_NAME := "stage1-exported-app-smoke-stage-clear.png"
const SMOKE_GAME_OVER_CAPTURE_NAME := "stage1-exported-app-smoke-game-over.png"
const SMOKE_RETRY_GAMEPLAY_CAPTURE_NAME := "stage1-exported-app-smoke-retry-gameplay.png"
const KEYBOARD_FALLBACK_SMOKE_ARG := "--rift-road-keyboard-fallback-smoke"
const KEYBOARD_FALLBACK_OUTPUT_PREFIX := "--rift-road-keyboard-fallback-output="
const KEYBOARD_FALLBACK_CAPTURE_DIR_PREFIX := "--rift-road-keyboard-fallback-capture-dir="
const KEYBOARD_FALLBACK_CAPTURE_NAME := "stage1-exported-app-keyboard-fallback.png"
const HERO_CARD_SIZE := Vector2(284, 198)
const HERO_CARD_SLANT := 22.0
const RENDER_PERF_SAMPLE_ARG := "--rift-road-render-perf-sample"
const RENDER_PERF_OUTPUT_PREFIX := "--rift-road-render-perf-output="
const RENDER_PERF_WINDOW_SIZE_PREFIX := "--rift-road-render-perf-window-size="
const RENDER_PERF_WINDOW_MODE_PREFIX := "--rift-road-render-perf-window-mode="
const RENDER_PERF_WARMUP_FRAMES := 8
const RENDER_PERF_SAMPLE_FRAMES := 240
const RENDER_PERF_FRAME_BUDGET_MS := 33.3
const RENDER_PERF_MAX_FRAME_MS := 120.0
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
var last_completed_stage_id := "sunset_overpass"
var final_ending := "The Sundrifter drives into dawn. The road's open."
var stage
var title_layer: CanvasLayer
var pause_layer: CanvasLayer
var title_logo_group: Node2D
var hero_select_header_group: Node2D
var result_overlay_group: Node2D
var label: Label
var controls_label: Label
var paused_overlay: ColorRect
var pause_text_label: Label
var hero_cards: Array = []
var stage1_demo_active := false
var render_perf_active := false
var render_perf_output_path := ""
var render_perf_window_size := "1280x720"
var render_perf_window_mode := "windowed"
var render_perf_warmup_frames_remaining := RENDER_PERF_WARMUP_FRAMES
var render_perf_frame_ms: Array[float] = []
var focus_pause_active := false

func _ready() -> void:
	DisplayServer.window_set_title("Rift Road: Beasts of the Afterglow")
	hero_roster = _load_hero_roster()
	var stage_text := FileAccess.get_file_as_string("res://data/stages.json")
	var stage_data = JSON.parse_string(stage_text)
	if typeof(stage_data) == TYPE_DICTIONARY:
		final_ending = stage_data.get("final_ending", final_ending)
	var launch_args := _launch_args()
	render_perf_active = RENDER_PERF_SAMPLE_ARG in launch_args
	render_perf_output_path = _launch_arg_value(launch_args, RENDER_PERF_OUTPUT_PREFIX)
	render_perf_window_size = _launch_arg_value(launch_args, RENDER_PERF_WINDOW_SIZE_PREFIX, render_perf_window_size)
	render_perf_window_mode = _launch_arg_value(launch_args, RENDER_PERF_WINDOW_MODE_PREFIX, render_perf_window_mode).to_lower()
	var smoke_capture_dir := _launch_arg_value(launch_args, SMOKE_CAPTURE_DIR_PREFIX)
	var keyboard_fallback_output_path := _launch_arg_value(launch_args, KEYBOARD_FALLBACK_OUTPUT_PREFIX)
	var keyboard_fallback_capture_dir := _launch_arg_value(launch_args, KEYBOARD_FALLBACK_CAPTURE_DIR_PREFIX)
	if render_perf_active:
		_configure_render_perf_window(render_perf_window_size, render_perf_window_mode)
	_show_title()
	if smoke_capture_dir != "":
		call_deferred("_run_exported_smoke_capture", smoke_capture_dir)
	elif KEYBOARD_FALLBACK_SMOKE_ARG in launch_args:
		call_deferred("_run_exported_keyboard_fallback_smoke", keyboard_fallback_output_path, keyboard_fallback_capture_dir)
	elif render_perf_active or _should_autostart_stage1(launch_args):
		call_deferred("_start_stage1_demo")

func _process(delta: float) -> void:
	if render_perf_active:
		_tick_render_perf_sample(delta)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		_handle_focus_lost()
	elif what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		_handle_focus_returned()

func _launch_args() -> PackedStringArray:
	var args := OS.get_cmdline_user_args()
	args.append_array(OS.get_cmdline_args())
	return args

func _should_autostart_stage1(args: PackedStringArray) -> bool:
	if OS.get_environment("WILDCOIL_AUTOSTART_STAGE1") == "1":
		return true
	return STAGE1_SMOKE_ARG in args

func _launch_arg_value(args: PackedStringArray, prefix: String, default_value := "") -> String:
	for arg in args:
		if arg.begins_with(prefix):
			return arg.substr(prefix.length())
	return default_value

func _configure_render_perf_window(size_text: String, mode_text: String) -> void:
	if mode_text == "fullscreen":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		render_perf_window_mode = "windowed"
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	var parts := size_text.to_lower().split("x")
	if parts.size() != 2 or not parts[0].is_valid_int() or not parts[1].is_valid_int():
		render_perf_window_size = "1280x720"
		DisplayServer.window_set_size(Vector2i(1280, 720))
		return
	var width := clampi(int(parts[0]), 320, 3840)
	var height := clampi(int(parts[1]), 240, 2160)
	render_perf_window_size = "%dx%d" % [width, height]
	DisplayServer.window_set_size(Vector2i(width, height))

func _run_exported_smoke_capture(capture_dir: String) -> void:
	var dir_error := DirAccess.make_dir_recursive_absolute(capture_dir)
	if dir_error != OK:
		push_error("Unable to create exported smoke capture directory: %s" % capture_dir)
		get_tree().quit(1)
		return
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var title_path := capture_dir.path_join(SMOKE_TITLE_CAPTURE_NAME)
	if not _save_viewport_png(title_path):
		get_tree().quit(1)
		return
	selected_hero_index = 0
	_show_character_select()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var hero_select_path := capture_dir.path_join(SMOKE_HERO_SELECT_CAPTURE_NAME)
	if not _save_viewport_png(hero_select_path):
		get_tree().quit(1)
		return
	await _start_stage1_demo()
	if not await _show_opening_story_smoke_capture():
		get_tree().quit(1)
		return
	var opening_story_path := capture_dir.path_join(SMOKE_OPENING_STORY_CAPTURE_NAME)
	if not _save_viewport_png(opening_story_path):
		get_tree().quit(1)
		return
	if stage != null and is_instance_valid(stage) and stage.combat_fx != null:
		var smoke_goal := str(stage.stage_data.get("scenario_goal", "Free caged dinos"))
		stage.combat_fx.show_stage_card(str(stage.stage_data.get("title", "Sunset Overpass")), stage._stage_card_goal(smoke_goal), maxi(stage.wave_index, 0))
	for _i in range(45):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var gameplay_path := capture_dir.path_join(SMOKE_GAMEPLAY_CAPTURE_NAME)
	if not _save_viewport_png(gameplay_path):
		get_tree().quit(1)
		return
	if not await _show_combat_action_smoke_capture():
		get_tree().quit(1)
		return
	var combat_path := capture_dir.path_join(SMOKE_COMBAT_CAPTURE_NAME)
	if not _save_viewport_png(combat_path):
		get_tree().quit(1)
		return
	if not await _show_pickup_smoke_capture():
		get_tree().quit(1)
		return
	var pickup_path := capture_dir.path_join(SMOKE_PICKUP_CAPTURE_NAME)
	if not _save_viewport_png(pickup_path):
		get_tree().quit(1)
		return
	if not await _show_road_collapse_smoke_capture():
		get_tree().quit(1)
		return
	var road_collapse_path := capture_dir.path_join(SMOKE_ROAD_COLLAPSE_CAPTURE_NAME)
	if not _save_viewport_png(road_collapse_path):
		get_tree().quit(1)
		return
	if not await _show_brask_intro_smoke_capture():
		get_tree().quit(1)
		return
	var brask_intro_path := capture_dir.path_join(SMOKE_BRASK_INTRO_CAPTURE_NAME)
	if not _save_viewport_png(brask_intro_path):
		get_tree().quit(1)
		return
	if not await _fast_forward_stage1_smoke_to_stage_clear():
		get_tree().quit(1)
		return
	var stage_clear_path := capture_dir.path_join(SMOKE_STAGE_CLEAR_CAPTURE_NAME)
	if not _save_viewport_png(stage_clear_path):
		get_tree().quit(1)
		return
	if not await _show_game_over_smoke_capture():
		get_tree().quit(1)
		return
	var game_over_path := capture_dir.path_join(SMOKE_GAME_OVER_CAPTURE_NAME)
	if not _save_viewport_png(game_over_path):
		get_tree().quit(1)
		return
	if not await _show_retry_gameplay_smoke_capture():
		get_tree().quit(1)
		return
	var retry_gameplay_path := capture_dir.path_join(SMOKE_RETRY_GAMEPLAY_CAPTURE_NAME)
	if not _save_viewport_png(retry_gameplay_path):
		get_tree().quit(1)
		return
	print("RIFT_ROAD_EXPORTED_APP_SMOKE_CAPTURE ok title_capture=%s hero_select_capture=%s opening_story_capture=%s gameplay_capture=%s combat_capture=%s pickup_capture=%s road_collapse_capture=%s brask_intro_capture=%s stage_clear_capture=%s game_over_capture=%s retry_gameplay_capture=%s" % [title_path, hero_select_path, opening_story_path, gameplay_path, combat_path, pickup_path, road_collapse_path, brask_intro_path, stage_clear_path, game_over_path, retry_gameplay_path])
	get_tree().quit(0)

func _run_exported_keyboard_fallback_smoke(output_path: String, capture_dir: String) -> void:
	if output_path == "":
		push_error("Missing exported keyboard fallback output path")
		get_tree().quit(1)
		return
	var output_dir := output_path.get_base_dir()
	if output_dir != "":
		DirAccess.make_dir_recursive_absolute(output_dir)
	var capture_path := ""
	if capture_dir != "":
		DirAccess.make_dir_recursive_absolute(capture_dir)
		capture_path = capture_dir.path_join(KEYBOARD_FALLBACK_CAPTURE_NAME)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var title_ok: bool = mode == "title" and controls_label.text.contains("Attack J")
	_press_keyboard_smoke_menu_key(KEY_ENTER)
	await get_tree().process_frame
	var hero_select_ok: bool = mode == "character_select"
	_press_keyboard_smoke_menu_key(KEY_3)
	await get_tree().process_frame
	hero_select_ok = hero_select_ok and selected_hero_index == 2 and mode == "hero_preview"
	_press_keyboard_smoke_menu_key(KEY_ESCAPE)
	await get_tree().process_frame
	var cancel_ok: bool = mode == "character_select"
	_press_keyboard_smoke_menu_key(KEY_ENTER)
	await get_tree().process_frame
	_press_keyboard_smoke_menu_key(KEY_ENTER)
	await get_tree().process_frame
	await get_tree().process_frame
	var stage_started := mode == "stage" and stage != null and is_instance_valid(stage) and stage.player != null
	var movement_ok := false
	var attack_ok := false
	var jump_ok := false
	var special_ok := false
	var dash_ok := false
	var pause_ok := false
	if stage_started:
		stage.player.max_health = 999
		stage.player.health = 999
		var start_position: Vector2 = stage.player.position
		_set_keyboard_smoke_key_state(KEY_D, true)
		for _i in range(8):
			await get_tree().physics_frame
			await get_tree().process_frame
		_set_keyboard_smoke_key_state(KEY_D, false)
		movement_ok = stage.player.position.x > start_position.x + 4.0
		_set_keyboard_smoke_key_state(KEY_J, true)
		await get_tree().physics_frame
		await get_tree().process_frame
		_set_keyboard_smoke_key_state(KEY_J, false)
		attack_ok = stage.player.attack_step > 0
		_set_keyboard_smoke_key_state(KEY_K, true)
		await get_tree().physics_frame
		await get_tree().process_frame
		_set_keyboard_smoke_key_state(KEY_K, false)
		jump_ok = stage.player.jump_timer > 0.0 or stage.player.fake_height > 0.0
		stage.player.special_meter = 100
		stage.player.special_timer = 0.0
		_set_keyboard_smoke_key_state(KEY_L, true)
		await get_tree().physics_frame
		await get_tree().process_frame
		_set_keyboard_smoke_key_state(KEY_L, false)
		special_ok = stage.player.special_timer > 0.0 and stage.player.special_meter < 100
		stage.player.dash_cooldown = 0.0
		_set_keyboard_smoke_key_state(KEY_I, true)
		await get_tree().physics_frame
		await get_tree().process_frame
		_set_keyboard_smoke_key_state(KEY_I, false)
		dash_ok = stage.player.dash_timer > 0.0
		_press_keyboard_smoke_menu_key(KEY_ESCAPE)
		await get_tree().process_frame
		pause_ok = get_tree().paused and paused_overlay.visible
		_press_keyboard_smoke_menu_key(KEY_ESCAPE)
		await get_tree().process_frame
		pause_ok = pause_ok and not get_tree().paused and not paused_overlay.visible
		if stage.combat_fx != null and stage.combat_fx.has_method("_clear_existing_banners"):
			stage.combat_fx._clear_existing_banners()
		if stage != null and is_instance_valid(stage) and stage.hud != null:
			stage.hud.show_notice("Keyboard fallback smoke: move attack jump special dash pause", 2.0)
	for _i in range(8):
		await get_tree().process_frame
	if capture_path != "":
		await RenderingServer.frame_post_draw
		if not _save_viewport_png(capture_path):
			capture_path = ""
	var payload := {
		"automated": true,
		"note": "Automated exported-app keyboard fallback smoke; not manual tester evidence.",
		"title": title_ok,
		"hero_select": hero_select_ok,
		"stage1_movement": movement_ok,
		"attack": attack_ok,
		"jump": jump_ok,
		"special": special_ok,
		"dash": dash_ok,
		"pause": pause_ok,
		"cancel_back": cancel_ok,
		"capture": capture_path
	}
	var output_file := FileAccess.open(output_path, FileAccess.WRITE)
	if output_file == null:
		push_error("Unable to write exported keyboard fallback output: %s" % output_path)
		get_tree().paused = false
		_release_keyboard_smoke_keys([KEY_D, KEY_J, KEY_K, KEY_L, KEY_I])
		get_tree().quit(1)
		return
	output_file.store_string(JSON.stringify(payload, "\t"))
	output_file.close()
	var ok := title_ok and hero_select_ok and movement_ok and attack_ok and jump_ok and special_ok and dash_ok and pause_ok and cancel_ok and capture_path != ""
	get_tree().paused = false
	_release_keyboard_smoke_keys([KEY_D, KEY_J, KEY_K, KEY_L, KEY_I])
	if not ok:
		push_error("RIFT_ROAD_EXPORTED_KEYBOARD_FALLBACK failed output=%s capture=%s" % [output_path, capture_path])
		get_tree().quit(1)
		return
	print("RIFT_ROAD_EXPORTED_KEYBOARD_FALLBACK ok output=%s capture=%s" % [output_path, capture_path])
	get_tree().quit(0)

func _show_opening_story_smoke_capture() -> bool:
	if mode != "stage":
		push_error("Unable to show exported smoke opening story: expected stage, got %s" % mode)
		return false
	if stage == null or not is_instance_valid(stage):
		push_error("Unable to show exported smoke opening story: Stage 1 is not running")
		return false
	if stage.has_method("set_demo_autoplay"):
		stage.set_demo_autoplay(false)
	if stage.has_method("_show_opening_story_panel"):
		stage._show_opening_story_panel(0)
	for _i in range(16):
		await get_tree().process_frame
	if str(stage.last_story_beat) == "":
		push_error("Unable to show exported smoke opening story: no story beat was surfaced")
		return false
	await RenderingServer.frame_post_draw
	if stage.has_method("set_demo_autoplay"):
		stage.set_demo_autoplay(true)
	return true

func _show_combat_action_smoke_capture() -> bool:
	await get_tree().create_timer(2.8).timeout
	for _i in range(20):
		await get_tree().process_frame
	if mode != "stage":
		push_error("Unable to show exported smoke combat action: expected stage, got %s" % mode)
		return false
	if stage == null or not is_instance_valid(stage):
		push_error("Unable to show exported smoke combat action: Stage 1 is not running")
		return false
	await RenderingServer.frame_post_draw
	return true

func _show_pickup_smoke_capture() -> bool:
	if mode != "stage":
		push_error("Unable to show exported smoke pickups: expected stage, got %s" % mode)
		return false
	if stage == null or not is_instance_valid(stage):
		push_error("Unable to show exported smoke pickups: Stage 1 is not running")
		return false
	if stage.has_method("set_demo_autoplay"):
		stage.set_demo_autoplay(false)
	if stage.pickup_manager == null or stage.player == null:
		push_error("Unable to show exported smoke pickups: pickup manager or player missing")
		return false
	if stage.player.has_method("set_demo_intent"):
		stage.player.set_demo_intent(Vector2.ZERO, false)
	for _i in range(95):
		await get_tree().process_frame
	stage.pickup_manager.pickups.clear()
	var player_pos: Vector2 = stage.player.position
	var pickup_y := clampf(player_pos.y + 70.0, 390.0, 596.0)
	stage.pickup_manager.spawn_pickup("glowfruit", Vector2(clampf(player_pos.x + 108.0, 110.0, 1130.0), pickup_y))
	stage.pickup_manager.spawn_pickup("luma_shard", Vector2(clampf(player_pos.x + 180.0, 110.0, 1130.0), pickup_y))
	stage.last_pickup_notice = "Pickups: Glowfruit HP | Luma Shard Meter"
	stage.hud.show_notice(stage.last_pickup_notice, 1.6)
	for _i in range(18):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	return true

func _show_road_collapse_smoke_capture() -> bool:
	if mode != "stage":
		push_error("Unable to show exported smoke road collapse: expected stage, got %s" % mode)
		return false
	if stage == null or not is_instance_valid(stage):
		push_error("Unable to show exported smoke road collapse: Stage 1 is not running")
		return false
	if stage.has_method("set_demo_autoplay"):
		stage.set_demo_autoplay(false)
	_clear_stage1_smoke_enemies(stage)
	if not stage.road_collapse_triggered:
		stage._advance_after_wave()
	for _i in range(18):
		await get_tree().process_frame
	if not stage.road_collapse_triggered:
		push_error("Unable to show exported smoke road collapse: event did not trigger")
		return false
	await RenderingServer.frame_post_draw
	return true

func _show_brask_intro_smoke_capture() -> bool:
	if not await _fast_forward_stage1_smoke_to_brask_intro():
		return false
	for _i in range(10):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	return true

func _fast_forward_stage1_smoke_to_brask_intro() -> bool:
	if stage == null or not is_instance_valid(stage):
		push_error("Unable to fast-forward exported smoke to Brask: Stage 1 is not running")
		return false
	if stage.has_method("set_demo_autoplay"):
		stage.set_demo_autoplay(false)
	if stage.road_collapse_active:
		for _i in range(50):
			stage._tick_road_collapse(0.05)
			await get_tree().process_frame
			if not stage.road_collapse_active:
				break
	if stage.road_collapse_active:
		push_error("Unable to fast-forward exported smoke to Brask: road collapse did not resume")
		return false
	var waves: Array = stage.stage_data.get("waves", [])
	for _i in range(waves.size()):
		if stage.boss_started:
			break
		_clear_stage1_smoke_enemies(stage)
		stage._start_next_wave()
		await get_tree().process_frame
	if not stage.boss_started or stage.boss == null or not is_instance_valid(stage.boss):
		push_error("Unable to fast-forward exported smoke to Brask: boss did not start")
		return false
	return true

func _fast_forward_stage1_smoke_to_stage_clear() -> bool:
	if stage == null or not is_instance_valid(stage):
		push_error("Unable to fast-forward exported smoke: Stage 1 is not running")
		return false
	if stage.has_method("set_demo_autoplay"):
		stage.set_demo_autoplay(false)
	if not stage.boss_started:
		if not await _fast_forward_stage1_smoke_to_brask_intro():
			return false
	if not stage.boss_started or stage.boss == null or not is_instance_valid(stage.boss):
		push_error("Unable to fast-forward exported smoke: Stage 1 boss did not start")
		return false
	stage.boss.apply_damage(stage.boss.max_health + 1000, stage.player.position.x)
	for _i in range(6):
		await get_tree().process_frame
	if mode != "stage_clear":
		push_error("Unable to fast-forward exported smoke: expected stage_clear, got %s" % mode)
		return false
	await RenderingServer.frame_post_draw
	return true

func _show_game_over_smoke_capture() -> bool:
	_on_game_over()
	await get_tree().process_frame
	if mode != "game_over":
		push_error("Unable to show exported smoke Game Over: expected game_over, got %s" % mode)
		return false
	await RenderingServer.frame_post_draw
	return true

func _show_retry_gameplay_smoke_capture() -> bool:
	_restart_current_stage()
	for _i in range(45):
		await get_tree().process_frame
	if mode != "stage":
		push_error("Unable to show exported smoke retry gameplay: expected stage, got %s" % mode)
		return false
	if stage == null or not is_instance_valid(stage):
		push_error("Unable to show exported smoke retry gameplay: Stage 1 is not running")
		return false
	await RenderingServer.frame_post_draw
	return true

func _clear_stage1_smoke_enemies(stage_node) -> void:
	for enemy in stage_node.enemies.duplicate():
		if enemy != null and is_instance_valid(enemy):
			enemy.queue_free()
	stage_node.enemies.clear()

func _save_viewport_png(path: String) -> bool:
	var image := get_viewport().get_texture().get_image()
	if image == null or image.is_empty():
		push_error("Unable to read exported smoke viewport image: %s" % path)
		return false
	var save_error := image.save_png(path)
	if save_error != OK:
		push_error("Unable to write exported smoke capture: %s" % path)
		return false
	return true

func _tick_render_perf_sample(delta: float) -> void:
	if not stage1_demo_active:
		return
	if stage == null or not is_instance_valid(stage):
		return
	if render_perf_warmup_frames_remaining > 0:
		render_perf_warmup_frames_remaining -= 1
		return
	render_perf_frame_ms.append(delta * 1000.0)
	if render_perf_frame_ms.size() >= RENDER_PERF_SAMPLE_FRAMES:
		_finish_render_perf_sample()

func _finish_render_perf_sample() -> void:
	render_perf_active = false
	var total_ms := 0.0
	var max_ms := 0.0
	var max_frame_index := 0
	var frame_index := 0
	for frame_ms in render_perf_frame_ms:
		total_ms += frame_ms
		if frame_ms > max_ms:
			max_ms = frame_ms
			max_frame_index = frame_index
		frame_index += 1
	var avg_ms := total_ms / float(max(render_perf_frame_ms.size(), 1))
	var payload := {
		"frames": render_perf_frame_ms.size(),
		"avg_ms": avg_ms,
		"max_ms": max_ms,
		"max_frame_index": max_frame_index,
		"first_sample_ms": render_perf_frame_ms[0] if not render_perf_frame_ms.is_empty() else 0.0,
		"first_12_sample_ms": render_perf_frame_ms.slice(0, mini(render_perf_frame_ms.size(), 12)),
		"window_size": render_perf_window_size,
		"window_mode": render_perf_window_mode,
		"warmup_frames": RENDER_PERF_WARMUP_FRAMES,
		"budget_ms": RENDER_PERF_FRAME_BUDGET_MS,
		"max_budget_ms": RENDER_PERF_MAX_FRAME_MS
	}
	if render_perf_output_path != "":
		var file := FileAccess.open(render_perf_output_path, FileAccess.WRITE)
		if file != null:
			file.store_string(JSON.stringify(payload))
			file.close()
		else:
			push_error("Unable to write exported performance sample: %s" % render_perf_output_path)
	print("RIFT_ROAD_EXPORTED_PERF stage1 frames=%d avg_ms=%.3f max_ms=%.3f budget_ms=%.1f max_budget_ms=%.1f" % [
		render_perf_frame_ms.size(),
		avg_ms,
		max_ms,
		RENDER_PERF_FRAME_BUDGET_MS,
		RENDER_PERF_MAX_FRAME_MS
	])
	get_tree().quit(0)

func _start_stage1_demo() -> void:
	selected_hero = "raya_flint"
	_start_campaign()
	await get_tree().process_frame
	await get_tree().process_frame
	if stage != null and is_instance_valid(stage) and stage.player != null:
		render_perf_warmup_frames_remaining = RENDER_PERF_WARMUP_FRAMES
		render_perf_frame_ms.clear()
		stage.player.max_health = 999
		stage.player.health = 999
		stage.player.attack_damage = mini(stage.player.attack_damage, 6)
		stage.player.special_damage = mini(stage.player.special_damage, 14)
		stage.player.invulnerable_timer = 0.0
		if stage.has_method("set_demo_autoplay"):
			stage.set_demo_autoplay(true)
		stage1_demo_active = true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		_handle_keyboard_input(event)
	elif event is InputEventJoypadButton:
		_handle_controller_button(event)

func _handle_keyboard_input(event: InputEventKey) -> void:
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
		elif mode == "stage_clear" or mode == "game_over" or mode == "complete":
			_return_to_title_from_flow()
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
		if event.keycode == KEY_R:
			_restart_last_completed_stage()
		elif event.keycode == KEY_T:
			_return_to_title_from_flow()
		elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER or event.keycode == KEY_J:
			_start_next_campaign_stage()
	elif mode == "game_over":
		if event.keycode == KEY_R:
			_restart_current_stage()
		else:
			_return_to_title_from_flow()
	elif mode == "complete":
		if event.keycode == KEY_R:
			_restart_last_completed_stage()
		else:
			_return_to_title_from_flow()

func _handle_controller_button(event: InputEventJoypadButton) -> void:
	if not event.pressed:
		return
	var button := event.button_index
	if button == JOY_BUTTON_START:
		if mode == "stage":
			_toggle_pause()
		else:
			_advance_controller_flow()
		return
	if button == JOY_BUTTON_B or button == JOY_BUTTON_BACK:
		_back_controller_flow()
		return
	if button == JOY_BUTTON_DPAD_LEFT or button == JOY_BUTTON_LEFT_SHOULDER:
		_cycle_controller_roster(-1)
		return
	if button == JOY_BUTTON_DPAD_RIGHT or button == JOY_BUTTON_RIGHT_SHOULDER:
		_cycle_controller_roster(1)
		return
	if button == JOY_BUTTON_Y:
		if mode == "game_over":
			_restart_current_stage()
		elif mode == "stage_clear" or mode == "complete":
			_restart_last_completed_stage()
		return
	if button == JOY_BUTTON_A or button == JOY_BUTTON_X:
		_advance_controller_flow()

func _advance_controller_flow() -> void:
	if mode == "title":
		_show_character_select()
	elif mode == "character_select":
		_show_hero_capability_preview()
	elif mode == "hero_preview":
		_confirm_hero_and_start()
	elif mode == "stage_clear":
		_start_next_campaign_stage()
	elif mode == "game_over" or mode == "complete":
		_return_to_title_from_flow()

func _press_keyboard_smoke_menu_key(keycode: int) -> void:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.physical_keycode = keycode
	event.pressed = true
	_handle_keyboard_input(event)

func _set_keyboard_smoke_key_state(keycode: int, pressed_key: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.physical_keycode = keycode
	event.pressed = pressed_key
	Input.parse_input_event(event)

func _release_keyboard_smoke_keys(keys: Array) -> void:
	for keycode in keys:
		_set_keyboard_smoke_key_state(int(keycode), false)

func _back_controller_flow() -> void:
	if mode == "hero_preview":
		_show_character_select()
	elif mode == "stage_clear" or mode == "game_over" or mode == "complete":
		_return_to_title_from_flow()

func _cycle_controller_roster(direction: int) -> void:
	if mode != "character_select" and mode != "hero_preview":
		return
	if hero_roster.is_empty():
		return
	selected_hero_index = wrapi(selected_hero_index + direction, 0, hero_roster.size())
	if mode == "hero_preview":
		_show_hero_capability_preview()
	else:
		_refresh_hero_card_selection()

func _show_title() -> void:
	_clear_stage()
	stage1_demo_active = false
	mode = "title"
	_ensure_title_layer()
	_set_title_logo_visible(true)
	_set_hero_select_header_visible(false)
	_set_result_overlay_visible(false)
	label.position = Vector2(430, 312)
	label.size = Vector2(420, 58)
	label.add_theme_font_size_override("font_size", 28)
	label.text = "Press any key"
	controls_label.text = "Keyboard: WASD/Arrows Move  Attack J  Jump K  Special L  Dash I  Pause Esc\nGamepad: LS/D-pad Move  Attack X  Jump A  Special Y/LB  Dash B/RB  Pause Start"
	_set_hero_cards_visible(false)
	paused_overlay.visible = false

func _show_character_select() -> void:
	mode = "character_select"
	_ensure_title_layer()
	_set_title_logo_visible(false)
	_set_hero_select_header_visible(true)
	_set_result_overlay_visible(false)
	label.position = Vector2(180, 58)
	label.size = Vector2(920, 150)
	label.add_theme_font_size_override("font_size", 32)
	label.text = ""
	controls_label.text = "1/R Raya   2/K Kian   3/N Nika   4/T Tor   Enter/A: capabilities\nGamepad: D-pad/LB/RB change hero   B back"
	_set_hero_cards_visible(true)
	_refresh_hero_card_selection()

func _show_hero_capability_preview() -> void:
	mode = "hero_preview"
	_ensure_title_layer()
	_set_title_logo_visible(false)
	_set_hero_select_header_visible(false)
	_set_result_overlay_visible(false)
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
	controls_label.text = "Enter/J/A Start Stage 1   1-4 or D-pad Change Hero   Esc/B Back"
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
	_set_hero_cards_visible(false)
	title_layer.visible = false
	stage = STAGE_SCENE.instantiate()
	stage.hero_id = selected_hero
	stage.stage_id = next_stage_id
	stage.game_over.connect(_on_game_over)
	stage.stage_completed.connect(_on_stage_completed)
	add_child(stage)

func _on_game_over() -> void:
	mode = "game_over"
	_prepare_result_overlay()
	label.text = "GAME OVER\n\nThe road can still be won."
	controls_label.text = "R/Y Restart Stage   Esc/T/B Return Title"

func _on_stage_completed(text: String) -> void:
	var result_summary := _stage_clear_result_summary()
	if stage != null and is_instance_valid(stage):
		last_completed_stage_id = stage.stage_id
	current_stage_index += 1
	_prepare_result_overlay()
	if current_stage_index >= stage_order.size():
		mode = "complete"
		label.text = "FINAL CLEAR\n\n%s\n\n%s\n\n%s" % [_format_stage_clear_result_summary(result_summary), text, final_ending]
		controls_label.text = "R/Y Replay Stage   Esc/T/B Return Title"
	else:
		mode = "stage_clear"
		label.text = "STAGE CLEAR\n\n%s\n\n%s\n\nNext: %s" % [_format_stage_clear_result_summary(result_summary), text, stage_order[current_stage_index].replace("_", " ").to_upper()]
		controls_label.text = "Enter/J/A Continue   R/Y Restart Stage   Esc/T/B Return Title"

func _stage_clear_result_summary() -> Dictionary:
	if stage != null and is_instance_valid(stage) and stage.has_method("stage_clear_summary"):
		return stage.stage_clear_summary()
	return {
		"rank": "C",
		"score": 0,
		"luma": 0,
		"health": 0,
		"max_health": 1
	}

func _format_stage_clear_result_summary(summary: Dictionary) -> String:
	return "RANK %s | Score %d | Luma %d\nHealth %d/%d" % [
		str(summary.get("rank", "C")),
		int(summary.get("score", 0)),
		int(summary.get("luma", 0)),
		int(summary.get("health", 0)),
		int(summary.get("max_health", 1))
	]

func _prepare_result_overlay() -> void:
	_ensure_title_layer()
	title_layer.visible = true
	_set_title_logo_visible(false)
	_set_hero_select_header_visible(false)
	_set_result_overlay_visible(true)
	_set_hero_cards_visible(false)
	label.position = Vector2(140, 104)
	label.size = Vector2(1000, 356)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 27)

func _start_next_campaign_stage() -> void:
	_clear_stage()
	_start_stage(stage_order[current_stage_index])

func _restart_current_stage() -> void:
	var restart_stage_id: String = stage_order[clampi(current_stage_index, 0, stage_order.size() - 1)]
	if stage != null and is_instance_valid(stage):
		restart_stage_id = stage.stage_id
	elif last_completed_stage_id != "":
		restart_stage_id = last_completed_stage_id
	var restart_index := stage_order.find(restart_stage_id)
	if restart_index >= 0:
		current_stage_index = restart_index
	_clear_stage()
	_start_stage(restart_stage_id)

func _restart_last_completed_stage() -> void:
	if last_completed_stage_id == "":
		_restart_current_stage()
		return
	var restart_index := stage_order.find(last_completed_stage_id)
	current_stage_index = restart_index if restart_index >= 0 else 0
	_clear_stage()
	_start_stage(last_completed_stage_id)

func _return_to_title_from_flow() -> void:
	current_stage_index = 0
	_show_title()

func _toggle_pause() -> void:
	_set_pause_state(not get_tree().paused)

func _set_pause_state(should_pause: bool, pause_message := "PAUSED\nEsc / Start to resume") -> void:
	_ensure_pause_layer()
	get_tree().paused = should_pause
	if pause_text_label != null:
		pause_text_label.text = pause_message
	if paused_overlay != null:
		paused_overlay.visible = should_pause
	if pause_layer != null:
		pause_layer.visible = should_pause
	if title_layer != null and mode == "stage":
		title_layer.visible = false
	if not should_pause:
		focus_pause_active = false

func _handle_focus_lost() -> void:
	if mode != "stage" or get_tree().paused:
		return
	focus_pause_active = true
	_suspend_stage_audio_for_focus_loss()
	_set_pause_state(true, "PAUSED\nWindow focus lost\nEsc / Start to resume")

func _handle_focus_returned() -> void:
	if mode == "stage" and focus_pause_active:
		_resume_stage_audio_after_focus_return()
		if pause_text_label != null:
			pause_text_label.text = "PAUSED\nEsc / Start to resume"

func _suspend_stage_audio_for_focus_loss() -> void:
	if stage == null or not is_instance_valid(stage) or stage.audio_manager == null:
		return
	if stage.audio_manager.has_method("suspend_for_focus_loss"):
		stage.audio_manager.suspend_for_focus_loss()

func _resume_stage_audio_after_focus_return() -> void:
	if stage == null or not is_instance_valid(stage) or stage.audio_manager == null:
		return
	if stage.audio_manager.has_method("resume_after_focus_return"):
		stage.audio_manager.resume_after_focus_return()

func _clear_stage() -> void:
	get_tree().paused = false
	focus_pause_active = false
	if pause_layer != null:
		pause_layer.visible = false
	if paused_overlay != null:
		paused_overlay.visible = false
	if stage != null and is_instance_valid(stage):
		if stage.has_method("set_demo_autoplay"):
			stage.set_demo_autoplay(false)
		stage.queue_free()
	stage = null
	stage1_demo_active = false

func _ensure_title_layer() -> void:
	if title_layer != null:
		title_layer.visible = true
		_ensure_pause_layer()
		return
	title_layer = CanvasLayer.new()
	title_layer.layer = 60
	add_child(title_layer)
	_build_title_backdrop(title_layer)
	_draw_title_vehicle(title_layer)
	title_logo_group = _build_title_logo_lockup(title_layer)
	hero_select_header_group = _build_hero_select_header(title_layer)
	result_overlay_group = _build_result_overlay_frame(title_layer)
	label = Label.new()
	label.position = Vector2(190, 58)
	label.size = Vector2(900, 190)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 32)
	label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.62))
	title_layer.add_child(label)
	controls_label = Label.new()
	controls_label.position = Vector2(140, 632)
	controls_label.size = Vector2(1000, 62)
	controls_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	controls_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	controls_label.add_theme_font_size_override("font_size", 16)
	controls_label.add_theme_color_override("font_color", Color(0.72, 1.0, 0.82))
	title_layer.add_child(controls_label)
	_build_roster_preview(title_layer)
	_set_hero_cards_visible(false)
	_ensure_pause_layer()

func _ensure_pause_layer() -> void:
	if pause_layer != null:
		return
	pause_layer = CanvasLayer.new()
	pause_layer.layer = 80
	pause_layer.visible = false
	add_child(pause_layer)
	paused_overlay = ColorRect.new()
	paused_overlay.color = Color(0, 0, 0, 0.62)
	paused_overlay.size = Vector2(1280, 720)
	paused_overlay.visible = false
	pause_layer.add_child(paused_overlay)
	pause_text_label = Label.new()
	pause_text_label.text = "PAUSED\nEsc / Start to resume"
	pause_text_label.position = Vector2(520, 300)
	pause_text_label.add_theme_font_size_override("font_size", 30)
	paused_overlay.add_child(pause_text_label)

func _build_title_logo_lockup(parent: Node) -> Node2D:
	var group := Node2D.new()
	group.name = "title-logo-lockup"
	group.position = Vector2(92, 66)
	parent.add_child(group)
	var shadow := Label.new()
	shadow.name = "title-logo-shadow"
	shadow.text = "RIFT\nROAD"
	shadow.position = Vector2(8, 10)
	shadow.size = Vector2(360, 172)
	shadow.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	shadow.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	shadow.add_theme_font_size_override("font_size", 76)
	shadow.add_theme_color_override("font_color", Color(0.02, 0.018, 0.015, 0.72))
	group.add_child(shadow)
	var logo := Label.new()
	logo.name = "title-logo-main"
	logo.text = "RIFT\nROAD"
	logo.position = Vector2(0, 0)
	logo.size = Vector2(360, 172)
	logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	logo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	logo.add_theme_font_size_override("font_size", 76)
	logo.add_theme_color_override("font_color", Color(1.0, 0.86, 0.56))
	group.add_child(logo)
	var crack := Polygon2D.new()
	crack.name = "title-logo-rift-crack"
	crack.polygon = PackedVector2Array([
		Vector2(137, 6), Vector2(162, 6), Vector2(146, 76),
		Vector2(172, 76), Vector2(124, 168), Vector2(139, 92),
		Vector2(114, 92)
	])
	crack.color = Color(0.45, 1.0, 0.70, 0.72)
	group.add_child(crack)
	var subtitle_ribbon := Polygon2D.new()
	subtitle_ribbon.name = "title-subtitle-ribbon"
	subtitle_ribbon.position = Vector2(4, 170)
	subtitle_ribbon.polygon = PackedVector2Array([Vector2(18, 0), Vector2(372, 0), Vector2(350, 42), Vector2(0, 42)])
	subtitle_ribbon.color = Color(0.83, 0.31, 0.10, 0.88)
	group.add_child(subtitle_ribbon)
	var subtitle := Label.new()
	subtitle.name = "title-subtitle-text"
	subtitle.text = "BEASTS OF THE AFTERGLOW"
	subtitle.position = Vector2(28, 175)
	subtitle.size = Vector2(320, 32)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 21)
	subtitle.add_theme_color_override("font_color", Color(1.0, 0.91, 0.62))
	group.add_child(subtitle)
	var start_plate := Polygon2D.new()
	start_plate.name = "title-start-plate"
	start_plate.position = Vector2(438, 228)
	start_plate.polygon = PackedVector2Array([Vector2(18, 0), Vector2(402, 0), Vector2(382, 58), Vector2(0, 58)])
	start_plate.color = Color(0.025, 0.030, 0.035, 0.62)
	group.add_child(start_plate)
	var start_edge := Line2D.new()
	start_edge.name = "title-start-plate-edge"
	start_edge.position = start_plate.position
	start_edge.points = PackedVector2Array([Vector2(18, 2), Vector2(402, 2), Vector2(382, 58), Vector2(0, 58), Vector2(18, 2)])
	start_edge.default_color = Color(0.25, 1.0, 0.66, 0.55)
	start_edge.width = 2.0
	group.add_child(start_edge)
	return group

func _set_title_logo_visible(visible_state: bool) -> void:
	if title_logo_group != null and is_instance_valid(title_logo_group):
		title_logo_group.visible = visible_state

func _build_hero_select_header(parent: Node) -> Node2D:
	var group := Node2D.new()
	group.name = "hero-select-header"
	group.visible = false
	parent.add_child(group)
	var shadow := Polygon2D.new()
	shadow.name = "hero-select-header-shadow"
	shadow.position = Vector2(418, 72)
	shadow.polygon = PackedVector2Array([Vector2(34, 0), Vector2(456, 0), Vector2(424, 98), Vector2(0, 98)])
	shadow.color = Color(0.0, 0.0, 0.0, 0.34)
	group.add_child(shadow)
	var frame := Polygon2D.new()
	frame.name = "hero-select-header-frame"
	frame.position = Vector2(408, 62)
	frame.polygon = PackedVector2Array([Vector2(38, 0), Vector2(464, 0), Vector2(430, 98), Vector2(0, 98)])
	frame.color = Color(0.025, 0.030, 0.036, 0.58)
	group.add_child(frame)
	var border := Line2D.new()
	border.name = "hero-select-header-border"
	border.position = frame.position
	border.points = PackedVector2Array([Vector2(38, 0), Vector2(464, 0), Vector2(430, 98), Vector2(0, 98), Vector2(38, 0)])
	border.default_color = Color(0.25, 1.0, 0.66, 0.46)
	border.width = 2.0
	group.add_child(border)
	var ribbon := Polygon2D.new()
	ribbon.name = "hero-select-route-ribbon"
	ribbon.position = Vector2(454, 50)
	ribbon.polygon = PackedVector2Array([Vector2(28, 0), Vector2(380, 0), Vector2(354, 36), Vector2(0, 36)])
	ribbon.color = Color(0.83, 0.31, 0.10, 0.86)
	group.add_child(ribbon)
	var route := Label.new()
	route.name = "hero-select-route-label"
	route.text = "ARCADE CAMPAIGN"
	route.position = Vector2(480, 53)
	route.size = Vector2(320, 30)
	route.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	route.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	route.add_theme_font_size_override("font_size", 18)
	route.add_theme_color_override("font_color", Color(1.0, 0.91, 0.62))
	group.add_child(route)
	var command := Label.new()
	command.name = "hero-select-command-label"
	command.text = "Choose Hero"
	command.position = Vector2(430, 100)
	command.size = Vector2(420, 44)
	command.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	command.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	command.add_theme_font_size_override("font_size", 32)
	command.add_theme_color_override("font_color", Color(1.0, 0.91, 0.62))
	group.add_child(command)
	return group

func _set_hero_select_header_visible(visible_state: bool) -> void:
	if hero_select_header_group != null and is_instance_valid(hero_select_header_group):
		hero_select_header_group.visible = visible_state

func _build_result_overlay_frame(parent: Node) -> Node2D:
	var group := Node2D.new()
	group.name = "result-overlay-frame"
	group.position = Vector2(0, 0)
	group.visible = false
	parent.add_child(group)
	var shadow := Polygon2D.new()
	shadow.name = "result-overlay-shadow"
	shadow.position = Vector2(162, 112)
	shadow.polygon = PackedVector2Array([Vector2(42, 0), Vector2(982, 0), Vector2(932, 368), Vector2(0, 368)])
	shadow.color = Color(0.0, 0.0, 0.0, 0.40)
	group.add_child(shadow)
	var frame := Polygon2D.new()
	frame.name = "result-clear-frame"
	frame.position = Vector2(148, 96)
	frame.polygon = PackedVector2Array([Vector2(48, 0), Vector2(984, 0), Vector2(934, 368), Vector2(0, 368)])
	frame.color = Color(0.025, 0.030, 0.036, 0.66)
	group.add_child(frame)
	var border := Line2D.new()
	border.name = "result-clear-border"
	border.position = frame.position
	border.points = PackedVector2Array([Vector2(48, 0), Vector2(984, 0), Vector2(934, 368), Vector2(0, 368), Vector2(48, 0)])
	border.default_color = Color(0.25, 1.0, 0.66, 0.58)
	border.width = 3.0
	group.add_child(border)
	var ribbon := Polygon2D.new()
	ribbon.name = "result-route-ribbon"
	ribbon.position = Vector2(352, 84)
	ribbon.polygon = PackedVector2Array([Vector2(28, 0), Vector2(594, 0), Vector2(560, 50), Vector2(0, 50)])
	ribbon.color = Color(0.82, 0.30, 0.10, 0.84)
	group.add_child(ribbon)
	var control_rail := Line2D.new()
	control_rail.name = "result-control-rail"
	control_rail.points = PackedVector2Array([Vector2(398, 598), Vector2(882, 598)])
	control_rail.default_color = Color(0.25, 1.0, 0.66, 0.42)
	control_rail.width = 3.0
	group.add_child(control_rail)
	for offset in [0.0, 18.0, 36.0]:
		var slash := Line2D.new()
		slash.name = "stage-clear-accent-slash"
		slash.points = PackedVector2Array([
			Vector2(1012 + offset, 118),
			Vector2(982 + offset, 152)
		])
		slash.default_color = Color(1.0, 0.76, 0.34, 0.80)
		slash.width = 3.0
		group.add_child(slash)
	return group

func _set_result_overlay_visible(visible_state: bool) -> void:
	if result_overlay_group != null and is_instance_valid(result_overlay_group):
		result_overlay_group.visible = visible_state

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
	var hero_id := str(profile.get("id", ""))
	_build_hero_card_frame(card, hero_id)
	var sprite_path := _hero_sprite_path(hero_id)
	var texture := _load_runtime_texture(sprite_path)
	var portrait_well := _build_hero_portrait_well(card, hero_id, texture != null)
	if texture != null:
		var hero_sprite := Sprite2D.new()
		hero_sprite.name = "hero-card-%s-sprite" % str(profile.get("name", "hero")).to_lower().replace(" ", "-")
		hero_sprite.texture = texture
		hero_sprite.centered = true
		hero_sprite.position = Vector2(60, 78)
		var scale_factor: float = minf(104.0 / texture.get_width(), 142.0 / texture.get_height())
		hero_sprite.scale = Vector2(scale_factor, scale_factor)
		portrait_well.add_child(hero_sprite)
	else:
		_build_planned_hero_badge(card, hero_id)
	var text := Label.new()
	text.position = Vector2(134, 32)
	text.size = Vector2(126, 102)
	var stats: Dictionary = profile.get("stats", {})
	text.text = "%d\n%s\n%s" % [
		index + 1,
		profile.get("name", "Hero"),
		profile.get("role", "fighter")
	]
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.add_theme_font_size_override("font_size", 16)
	text.add_theme_color_override("font_color", Color(1.0, 0.9, 0.68))
	card.add_child(text)
	_build_hero_stat_pips(card, stats, hero_id)
	return card

func _build_hero_card_frame(card: Node2D, hero_id: String) -> void:
	var accent := _hero_accent_color(hero_id)
	var shadow := Polygon2D.new()
	shadow.name = "hero-card-drop-shadow"
	shadow.position = Vector2(8, 10)
	shadow.polygon = _hero_card_points()
	shadow.color = Color(0.0, 0.0, 0.0, 0.46)
	card.add_child(shadow)
	var selected_glow := Polygon2D.new()
	selected_glow.name = "hero-card-selected-glow"
	selected_glow.polygon = PackedVector2Array([
		Vector2(HERO_CARD_SLANT - 10, -10),
		Vector2(HERO_CARD_SIZE.x + 12, -10),
		Vector2(HERO_CARD_SIZE.x - HERO_CARD_SLANT + 12, HERO_CARD_SIZE.y + 10),
		Vector2(-10, HERO_CARD_SIZE.y + 10)
	])
	selected_glow.color = accent.lightened(0.18)
	selected_glow.modulate.a = 0.22
	selected_glow.visible = false
	card.add_child(selected_glow)
	var panel := Polygon2D.new()
	panel.name = "selection-panel"
	panel.set_meta("presentation_role", "hero-select-canted-frame")
	panel.polygon = _hero_card_points()
	panel.color = Color(0.055, 0.060, 0.072, 0.90)
	card.add_child(panel)
	var top_edge := Line2D.new()
	top_edge.name = "hero-card-neon-edge"
	top_edge.points = PackedVector2Array([Vector2(HERO_CARD_SLANT, 5), Vector2(HERO_CARD_SIZE.x - 4, 5), Vector2(HERO_CARD_SIZE.x - 18, 20)])
	top_edge.default_color = accent
	top_edge.width = 5.0
	card.add_child(top_edge)
	var lower_rail := Line2D.new()
	lower_rail.name = "hero-card-lower-rail"
	lower_rail.points = PackedVector2Array([Vector2(16, HERO_CARD_SIZE.y - 18), Vector2(HERO_CARD_SIZE.x - HERO_CARD_SLANT - 8, HERO_CARD_SIZE.y - 18)])
	lower_rail.default_color = accent.darkened(0.22)
	lower_rail.width = 2.0
	card.add_child(lower_rail)
	for offset in [0.0, 14.0]:
		var slash := Line2D.new()
		slash.name = "hero-card-corner-slash"
		slash.points = PackedVector2Array([
			Vector2(HERO_CARD_SIZE.x - 28 + offset, HERO_CARD_SIZE.y - 45),
			Vector2(HERO_CARD_SIZE.x - 56 + offset, HERO_CARD_SIZE.y - 16)
		])
		slash.default_color = accent
		slash.width = 2.0
		card.add_child(slash)

func _build_hero_portrait_well(card: Node2D, hero_id: String, has_texture: bool) -> Node2D:
	var well := Node2D.new()
	well.name = "hero-card-portrait-well"
	well.position = Vector2(18, 42)
	card.add_child(well)
	var backing := Polygon2D.new()
	backing.name = "hero-card-portrait-backing"
	backing.polygon = PackedVector2Array([Vector2(12, 0), Vector2(108, 0), Vector2(94, 132), Vector2(0, 132)])
	backing.color = _hero_accent_color(hero_id).darkened(0.76)
	backing.modulate.a = 0.52 if has_texture else 0.70
	well.add_child(backing)
	var border := Line2D.new()
	border.name = "hero-card-portrait-border"
	border.points = PackedVector2Array([Vector2(12, 0), Vector2(108, 0), Vector2(94, 132), Vector2(0, 132), Vector2(12, 0)])
	border.default_color = _hero_accent_color(hero_id)
	border.width = 2.0
	well.add_child(border)
	return well

func _build_planned_hero_badge(card: Node2D, hero_id: String) -> void:
	var silhouette := Polygon2D.new()
	silhouette.name = "planned-hero-silhouette"
	silhouette.position = Vector2(78, 132)
	silhouette.polygon = _hero_silhouette(hero_id)
	silhouette.color = _hero_body_color(hero_id)
	silhouette.modulate.a = 0.42
	card.add_child(silhouette)
	var icon := Label.new()
	icon.position = Vector2(30, 76)
	icon.size = Vector2(88, 24)
	icon.text = "PLANNED HERO"
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.add_theme_font_size_override("font_size", 10)
	icon.add_theme_color_override("font_color", _hero_accent_color(hero_id))
	card.add_child(icon)
	for rib in range(4):
		var rib_line := ColorRect.new()
		rib_line.name = "planned-hero-readiness-rib"
		rib_line.position = Vector2(42, 118 + rib * 10)
		rib_line.size = Vector2(54 - rib * 4, 4)
		rib_line.color = _hero_accent_color(hero_id).darkened(float(rib) * 0.08)
		card.add_child(rib_line)

func _build_hero_stat_pips(card: Node2D, stats: Dictionary, hero_id: String) -> void:
	var meter_names := ["P", "S", "C", "D"]
	var stat_keys := ["power", "speed", "control", "defense"]
	for i in range(meter_names.size()):
		var stat_label := Label.new()
		stat_label.position = Vector2(136, 132 + i * 12)
		stat_label.size = Vector2(16, 10)
		stat_label.text = meter_names[i]
		stat_label.add_theme_font_size_override("font_size", 9)
		stat_label.add_theme_color_override("font_color", Color(1.0, 0.90, 0.68))
		card.add_child(stat_label)
		var stat_key: String = stat_keys[i]
		var value := clampi(int(stats.get(stat_key, 3)), 1, 5)
		for pip in range(5):
			var meter := ColorRect.new()
			meter.name = "hero-stat-pip"
			meter.position = Vector2(154 + pip * 16, 136 + i * 12)
			meter.size = Vector2(11, 4)
			meter.color = _hero_accent_color(hero_id) if pip < value else Color(0.11, 0.12, 0.13, 0.70)
			card.add_child(meter)

func _hero_card_points() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(HERO_CARD_SLANT, 0),
		Vector2(HERO_CARD_SIZE.x, 0),
		Vector2(HERO_CARD_SIZE.x - HERO_CARD_SLANT, HERO_CARD_SIZE.y),
		Vector2(0, HERO_CARD_SIZE.y)
	])

func _selected_hero_card_color(hero_id: String) -> Color:
	return _hero_accent_color(hero_id).darkened(0.70)

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
		var hero_id := str(hero_roster[index].get("id", "")) if index < hero_roster.size() else ""
		var selected_glow = card.get_node_or_null("hero-card-selected-glow")
		if selected_glow != null:
			selected_glow.visible = index == selected_hero_index
		if panel != null:
			panel.color = _selected_hero_card_color(hero_id) if index == selected_hero_index else Color(0.055, 0.060, 0.072, 0.90)
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
