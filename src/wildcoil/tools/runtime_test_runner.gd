extends SceneTree

const PERFORMANCE_SAMPLE_FRAMES := 240
const PERFORMANCE_FRAME_BUDGET_MS := 33.3
const PERFORMANCE_MAX_FRAME_MS := 120.0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var mode := "smoke"
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		mode = args[0]
	var ok := _run_smoke()
	if ok and mode == "stage1_flow":
		ok = await _run_stage1_flow()
	if ok and mode == "stage1_autoplay":
		ok = await _run_stage1_autoplay()
	if ok and mode == "stage1_road_collapse":
		ok = await _run_stage1_road_collapse()
	if ok and mode == "stage1_brask_story":
		ok = await _run_stage1_brask_story()
	if ok and mode == "stage1_opening_story":
		ok = await _run_stage1_opening_story()
	if ok and mode == "stage1_pickup_clarity":
		ok = await _run_stage1_pickup_clarity()
	if ok and mode == "hero_select_preview":
		ok = await _run_hero_select_preview()
	if ok and mode == "stage1_restart_flow":
		ok = await _run_stage1_restart_flow()
	if ok and mode == "controller_title_flow":
		ok = await _run_controller_title_flow()
	if ok and mode == "keyboard_fallback_flow":
		ok = await _run_keyboard_fallback_flow()
	if ok and mode == "stage1_focus_resume":
		ok = await _run_stage1_focus_resume()
	if ok and mode == "stage1_performance_sample":
		ok = await _run_stage1_performance_sample()
	if ok:
		print("RIFT_ROAD_RUNTIME_OK %s" % mode)
		quit(0)
	else:
		printerr("RIFT_ROAD_RUNTIME_FAILED %s" % mode)
		quit(1)

func _run_smoke() -> bool:
	var required := [
		"res://project.godot",
		"res://scenes/app_root.tscn",
		"res://scenes/player.tscn",
		"res://scenes/enemy_actor.tscn",
		"res://scenes/boss_brask_noll.tscn",
		"res://scenes/stages/sunset_overpass.tscn",
		"res://data/characters.json",
		"res://data/enemies.json",
		"res://data/bosses.json",
		"res://data/stages.json"
	]
	for path in required:
		if not FileAccess.file_exists(path):
			printerr("Missing required path: %s" % path)
			return false
	return _validate_json("res://data/characters.json", "heroes") and _validate_json("res://data/enemies.json", "enemies") and _validate_json("res://data/bosses.json", "bosses") and _validate_json("res://data/stages.json", "stages")

func _validate_json(path: String, key: String) -> bool:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		printerr("Invalid JSON dictionary: %s" % path)
		return false
	if not parsed.has(key):
		printerr("Missing JSON key %s in %s" % [key, path])
		return false
	return true

func _run_stage1_flow() -> bool:
	var packed: PackedScene = load("res://scenes/app_root.tscn")
	if packed == null:
		printerr("Could not load app root scene")
		return false
	var app = packed.instantiate()
	root.add_child(app)
	await process_frame
	await process_frame
	if app.mode != "title":
		printerr("Expected title mode, got %s" % app.mode)
		return false
	if app.title_logo_group == null or not app.title_logo_group.visible:
		printerr("Title logo lockup was not visible")
		return false
	var title_logo = app.title_logo_group.get_node_or_null("title-logo-main")
	if title_logo == null or not title_logo.text.contains("RIFT"):
		printerr("Title logo did not expose game title")
		return false
	if app.controls_label == null or not app.controls_label.text.contains("Attack J"):
		printerr("Title controls were not visible")
		return false
	app._show_character_select()
	await process_frame
	if app.mode != "character_select":
		printerr("Expected character select mode, got %s" % app.mode)
		return false
	if not app.controls_label.text.contains("Raya") or not app.controls_label.text.contains("Nika"):
		printerr("Hero select controls did not expose hero choices")
		return false
	app.selected_hero = "nika_sol"
	app._start_campaign()
	await process_frame
	await process_frame
	if app.mode != "stage" or app.stage == null:
		printerr("Stage did not start")
		return false
	var stage = app.stage
	if stage.stage_id != "sunset_overpass":
		printerr("Expected Sunset Overpass, got %s" % stage.stage_id)
		return false
	if stage.player == null or stage.player.hero_id != "nika_sol":
		printerr("Selected hero was not passed into Stage 1")
		return false
	if stage.hud == null or stage.combat_fx == null:
		printerr("Stage UI and combat FX were not built")
		return false
	var wave_total: int = stage.stage_data["waves"].size()
	for i in range(wave_total):
		if stage.wave_index != i:
			printerr("Expected wave %d, got %d" % [i, stage.wave_index])
			return false
		if stage.enemies.size() == 0:
			printerr("Wave %d spawned no enemies" % i)
			return false
		_clear_spawned_enemies(stage)
		stage._start_next_wave()
		await process_frame
	if not stage.boss_started or stage.boss == null:
		printerr("Boss did not start after Stage 1 waves")
		return false
	if not stage.hud.boss_bar.visible:
		printerr("Boss HUD was not visible")
		return false
	stage.boss.apply_damage(stage.boss.max_health + 1000, stage.player.position.x)
	await process_frame
	await process_frame
	if app.mode != "stage_clear":
		printerr("Expected stage_clear mode after boss defeat, got %s" % app.mode)
		return false
	if not app.label.text.contains("STAGE CLEAR"):
		printerr("Stage clear label was not shown")
		return false
	if not app.label.text.contains("RANK ") or not app.label.text.contains("Score") or not app.label.text.contains("Luma") or not app.label.text.contains("Health"):
		printerr("Stage clear label did not show score/rank summary")
		return false
	if _any_visible_hero_card(app):
		printerr("Stage clear retained visible hero-select cards")
		return false
	if app.stage != null and app.stage.combat_fx != null and app.title_layer.layer <= app.stage.combat_fx.layer:
		printerr("Stage clear overlay layer is below combat FX")
		return false
	if app.label.autowrap_mode == TextServer.AUTOWRAP_OFF or app.label.size.x < 980:
		printerr("Stage clear label is not configured to wrap long text")
		return false
	app.queue_free()
	await process_frame
	return true

func _run_stage1_autoplay() -> bool:
	var packed: PackedScene = load("res://scenes/stages/sunset_overpass.tscn")
	if packed == null:
		printerr("Could not load Stage 1 scene")
		return false
	var stage = packed.instantiate()
	stage.hero_id = "raya_flint"
	stage.stage_id = "sunset_overpass"
	root.add_child(stage)
	await process_frame
	await process_frame
	if stage.player == null or not stage.has_method("set_demo_autoplay"):
		printerr("Stage 1 did not expose demo autoplay controls")
		stage.queue_free()
		return false
	stage.player.max_health = 999
	stage.player.health = 999
	var start_position: Vector2 = stage.player.position
	stage.set_demo_autoplay(true)
	for _i in range(150):
		await physics_frame
		await process_frame
	var moved: bool = stage.player.position.distance_to(start_position) > 24.0
	var attacked: bool = stage.player.attack_step > 0 or stage.player.combo_count > 0
	var demo_enabled: bool = stage.demo_autoplay_active and stage.player.demo_control_active
	stage.set_demo_autoplay(false)
	stage.queue_free()
	for _i in range(5):
		await process_frame
	if not demo_enabled:
		printerr("Stage 1 autoplay did not enable player demo control")
		return false
	if not moved:
		printerr("Stage 1 autoplay did not move the player")
		return false
	if not attacked:
		printerr("Stage 1 autoplay did not trigger player attacks")
		return false
	return true

func _run_stage1_road_collapse() -> bool:
	var packed: PackedScene = load("res://scenes/stages/sunset_overpass.tscn")
	if packed == null:
		printerr("Could not load Stage 1 scene")
		return false
	var stage = packed.instantiate()
	stage.hero_id = "raya_flint"
	stage.stage_id = "sunset_overpass"
	root.add_child(stage)
	await process_frame
	await process_frame
	if stage.wave_index != 0:
		printerr("Expected Stage 1 to start on wave 0, got %d" % stage.wave_index)
		stage.queue_free()
		return false
	_clear_spawned_enemies(stage)
	stage._advance_after_wave()
	await process_frame
	var triggered: bool = stage.road_collapse_triggered and stage.road_collapse_active
	if not triggered:
		printerr("Road collapse did not trigger after wave 0")
		stage.queue_free()
		return false
	if stage.get_node_or_null("stage1-road-collapse-set-piece") == null:
		printerr("Road collapse visual set piece was not created")
		stage.queue_free()
		return false
	for _i in range(40):
		stage._tick_road_collapse(0.05)
		await process_frame
		if not stage.road_collapse_active:
			break
	var resumed: bool = (not stage.road_collapse_active) and stage.wave_index == 1 and stage.enemies.size() > 0
	var triggered_text := "true" if triggered else "false"
	var resumed_text := "true" if resumed else "false"
	print("RIFT_ROAD_ROAD_COLLAPSE triggered=%s resumed=%s wave=%d enemies=%d" % [triggered_text, resumed_text, stage.wave_index, stage.enemies.size()])
	stage.queue_free()
	await process_frame
	if not resumed:
		printerr("Road collapse did not resume into service-lane wave")
		return false
	return true

func _run_stage1_brask_story() -> bool:
	var packed: PackedScene = load("res://scenes/stages/sunset_overpass.tscn")
	if packed == null:
		printerr("Could not load Stage 1 scene")
		return false
	var stage = packed.instantiate()
	stage.hero_id = "raya_flint"
	stage.stage_id = "sunset_overpass"
	root.add_child(stage)
	await process_frame
	await process_frame
	var waves: Array = stage.stage_data.get("waves", [])
	for _i in range(waves.size()):
		_clear_spawned_enemies(stage)
		stage._start_next_wave()
		await process_frame
	if not stage.boss_started or stage.boss == null or not is_instance_valid(stage.boss):
		printerr("Stage 1 Brask story check did not reach the boss")
		stage.queue_free()
		return false
	var story: Dictionary = stage._boss_story()
	var intro_line := str(story.get("intro_line", ""))
	var intro_seen: bool = intro_line != "" and stage.last_boss_story_beat.contains(intro_line)
	stage.boss.apply_damage(int(stage.boss.max_health * 0.55), stage.player.position.x)
	await process_frame
	var phase_line := str(story.get("phase_line", ""))
	var phase_seen: bool = phase_line != "" and stage.last_boss_story_beat.contains(phase_line)
	stage._on_boss_defeated()
	var escape_line := str(story.get("escape_line", ""))
	var escape_seen: bool = escape_line != "" and stage.last_boss_story_beat.contains(escape_line)
	var intro_text := "true" if intro_seen else "false"
	var phase_text := "true" if phase_seen else "false"
	var escape_text := "true" if escape_seen else "false"
	print("RIFT_ROAD_BRASK_STORY intro=%s phase=%s escape=%s" % [intro_text, phase_text, escape_text])
	stage.queue_free()
	await process_frame
	if not intro_seen or not phase_seen or not escape_seen:
		printerr("Stage 1 Brask story beats were not all surfaced")
		return false
	return true

func _run_stage1_opening_story() -> bool:
	var packed: PackedScene = load("res://scenes/stages/sunset_overpass.tscn")
	if packed == null:
		printerr("Could not load Stage 1 scene")
		return false
	var stage = packed.instantiate()
	stage.hero_id = "raya_flint"
	stage.stage_id = "sunset_overpass"
	root.add_child(stage)
	await process_frame
	await process_frame
	var panels: Array = stage._opening_story_panels()
	var first_panel_seen: bool = panels.size() >= 3 and stage.last_story_beat.contains("Sundrifter Approach") and stage.last_story_beat.contains("drill marks")
	stage._show_opening_story_panel(1)
	await process_frame
	var second_panel_seen: bool = stage.last_story_beat.contains("Cage Line") and stage.last_story_beat.contains("Nika") and stage.last_story_beat.contains("cages")
	stage._show_opening_story_panel(2)
	await process_frame
	var third_panel_seen: bool = stage.last_story_beat.contains("Repair The Route") and stage.last_story_beat.contains("routes")
	stage._show_story_bark("cage_loading", "", 0.5)
	await process_frame
	var bark_seen: bool = stage.last_story_beat.contains("Nika") and stage.last_story_beat.contains("Cages on the right")
	var panels_seen: bool = first_panel_seen and second_panel_seen and third_panel_seen
	print("RIFT_ROAD_OPENING_STORY panels=%s barks=%s" % [
		"true" if panels_seen else "false",
		"true" if bark_seen else "false"
	])
	stage.queue_free()
	await process_frame
	if not panels_seen or not bark_seen:
		printerr("Stage 1 opening story panels or barks were not surfaced")
		return false
	return true

func _run_stage1_pickup_clarity() -> bool:
	var packed: PackedScene = load("res://scenes/stages/sunset_overpass.tscn")
	if packed == null:
		printerr("Could not load Stage 1 scene")
		return false
	var stage = packed.instantiate()
	stage.hero_id = "raya_flint"
	stage.stage_id = "sunset_overpass"
	root.add_child(stage)
	await process_frame
	await process_frame
	if stage.player == null or stage.pickup_manager == null:
		printerr("Stage 1 pickup clarity check did not build player or pickup manager")
		stage.queue_free()
		return false
	var damaged_health: int = maxi(stage.player.max_health - 40, 1)
	stage.player.health = damaged_health
	stage.pickup_manager.spawn_pickup("glowfruit", stage.player.position)
	stage.pickup_manager.collect_near(stage.player)
	await process_frame
	var glowfruit_seen: bool = stage.player.health > damaged_health and stage.last_pickup_notice.contains("Glowfruit") and stage.last_pickup_notice.contains("HP")
	var luma_before: int = stage.player.luma_shards
	var meter_before: int = stage.player.special_meter
	var score_before: int = stage.player.score
	stage.pickup_manager.spawn_pickup("luma_shard", stage.player.position)
	stage.pickup_manager.collect_near(stage.player)
	await process_frame
	var luma_seen: bool = stage.player.luma_shards > luma_before and stage.player.special_meter > meter_before and stage.player.score > score_before
	var notice_seen: bool = stage.last_pickup_notice.contains("Luma Shard") and stage.last_pickup_notice.contains("Meter")
	print("RIFT_ROAD_PICKUPS glowfruit=%s luma_shard=%s notice=%s" % [
		"true" if glowfruit_seen else "false",
		"true" if luma_seen else "false",
		"true" if notice_seen else "false"
	])
	stage.queue_free()
	await process_frame
	if not glowfruit_seen or not luma_seen or not notice_seen:
		printerr("Stage 1 pickups did not expose clear health and luma effects")
		return false
	return true

func _run_hero_select_preview() -> bool:
	var packed: PackedScene = load("res://scenes/app_root.tscn")
	if packed == null:
		printerr("Could not load app root scene")
		return false
	var app = packed.instantiate()
	root.add_child(app)
	await process_frame
	await process_frame
	app._show_character_select()
	await process_frame
	if app.hero_roster.size() < 4:
		printerr("Character select did not expose four heroes")
		app.queue_free()
		return false
	app.selected_hero_index = 3
	app._show_hero_capability_preview()
	await process_frame
	if app.mode != "hero_preview":
		printerr("Expected hero_preview mode, got %s" % app.mode)
		app.queue_free()
		return false
	if app.selected_hero != "tor_bram":
		printerr("Preview did not select Tor Bram")
		app.queue_free()
		return false
	if app.label == null or not app.label.text.contains("CAPABILITIES") or not app.label.text.contains("Tor Bram"):
		printerr("Hero capability preview did not show selected hero details")
		app.queue_free()
		return false
	app._confirm_hero_and_start()
	await process_frame
	await process_frame
	if app.mode != "stage" or app.stage == null or app.stage.hero_id != "tor_bram":
		printerr("Confirmed hero preview did not start Stage 1 with selected hero")
		app.queue_free()
		return false
	app.queue_free()
	await process_frame
	return true

func _run_stage1_restart_flow() -> bool:
	var packed: PackedScene = load("res://scenes/app_root.tscn")
	if packed == null:
		printerr("Could not load app root scene")
		return false
	var app = packed.instantiate()
	root.add_child(app)
	await process_frame
	await process_frame
	app.selected_hero = "raya_flint"
	app._start_campaign()
	await process_frame
	await process_frame
	if app.mode != "stage" or app.stage == null:
		printerr("Stage did not start for restart flow")
		app.queue_free()
		return false
	var first_stage_id: String = app.stage.stage_id
	app._on_stage_completed("test clear")
	await process_frame
	if app.mode != "stage_clear":
		printerr("Expected stage_clear before restart, got %s" % app.mode)
		app.queue_free()
		return false
	if app.controls_label == null or not app.controls_label.text.contains("Restart Stage") or not app.controls_label.text.contains("Return Title"):
		printerr("Stage clear controls did not expose restart and title actions")
		app.queue_free()
		return false
	app._restart_last_completed_stage()
	await process_frame
	await process_frame
	if app.mode != "stage" or app.stage == null or app.stage.stage_id != first_stage_id:
		printerr("Restart last completed stage did not relaunch Stage 1")
		app.queue_free()
		return false
	app._on_game_over()
	await process_frame
	if app.mode != "game_over" or not app.controls_label.text.contains("Restart Stage"):
		printerr("Game over did not expose restart controls")
		app.queue_free()
		return false
	app._restart_current_stage()
	await process_frame
	await process_frame
	if app.mode != "stage" or app.stage == null or app.stage.stage_id != first_stage_id:
		printerr("Game over restart did not relaunch the current stage")
		app.queue_free()
		return false
	app._return_to_title_from_flow()
	await process_frame
	if app.mode != "title" or app.stage != null:
		printerr("Return-to-title did not clear stage")
		app.queue_free()
		return false
	app.queue_free()
	await process_frame
	return true

func _run_controller_title_flow() -> bool:
	var packed: PackedScene = load("res://scenes/app_root.tscn")
	if packed == null:
		printerr("Could not load app root scene")
		return false
	var app = packed.instantiate()
	root.add_child(app)
	await process_frame
	await process_frame
	_press_controller_button(app, JOY_BUTTON_A)
	await process_frame
	if app.mode != "character_select":
		printerr("Controller confirm did not advance title to character select")
		app.queue_free()
		return false
	_press_controller_button(app, JOY_BUTTON_RIGHT_SHOULDER)
	await process_frame
	if app.selected_hero_index != 1:
		printerr("Controller shoulder did not cycle hero selection")
		app.queue_free()
		return false
	_press_controller_button(app, JOY_BUTTON_A)
	await process_frame
	if app.mode != "hero_preview":
		printerr("Controller confirm did not open hero preview")
		app.queue_free()
		return false
	_press_controller_button(app, JOY_BUTTON_B)
	await process_frame
	if app.mode != "character_select":
		printerr("Controller cancel did not return to character select")
		app.queue_free()
		return false
	_press_controller_button(app, JOY_BUTTON_A)
	await process_frame
	_press_controller_button(app, JOY_BUTTON_A)
	await process_frame
	await process_frame
	if app.mode != "stage" or app.stage == null:
		printerr("Controller confirm did not start Stage 1")
		app.queue_free()
		return false
	_press_controller_button(app, JOY_BUTTON_START)
	await process_frame
	if not paused or not app.paused_overlay.visible:
		printerr("Controller start did not pause Stage 1")
		app.queue_free()
		return false
	_press_controller_button(app, JOY_BUTTON_START)
	await process_frame
	if paused or app.paused_overlay.visible:
		printerr("Controller start did not resume Stage 1")
		app.queue_free()
		return false
	app.queue_free()
	await process_frame
	return true

func _run_keyboard_fallback_flow() -> bool:
	var packed: PackedScene = load("res://scenes/app_root.tscn")
	if packed == null:
		printerr("Could not load app root scene")
		return false
	var app = packed.instantiate()
	root.add_child(app)
	await process_frame
	await process_frame
	var title_ok: bool = app.mode == "title" and app.controls_label.text.contains("Attack J")
	_press_keyboard_menu_key(app, KEY_ENTER)
	await process_frame
	var hero_select_ok: bool = app.mode == "character_select"
	_press_keyboard_menu_key(app, KEY_3)
	await process_frame
	hero_select_ok = hero_select_ok and app.selected_hero_index == 2 and app.mode == "hero_preview"
	if not hero_select_ok:
		printerr("Keyboard roster key did not open the selected hero preview")
		app.queue_free()
		await process_frame
		return false
	_press_keyboard_menu_key(app, KEY_ESCAPE)
	await process_frame
	var cancel_ok: bool = app.mode == "character_select"
	_press_keyboard_menu_key(app, KEY_ENTER)
	await process_frame
	_press_keyboard_menu_key(app, KEY_ENTER)
	await process_frame
	await process_frame
	if app.mode != "stage" or app.stage == null or app.stage.player == null:
		printerr("Keyboard Enter did not start Stage 1")
		app.queue_free()
		await process_frame
		return false
	var player = app.stage.player
	player.max_health = 999
	player.health = 999
	var start_position: Vector2 = player.position
	_set_keyboard_key_state(KEY_D, true)
	for _i in range(8):
		await physics_frame
		await process_frame
	_set_keyboard_key_state(KEY_D, false)
	var movement_ok: bool = player.position.x > start_position.x + 4.0
	_set_keyboard_key_state(KEY_J, true)
	await physics_frame
	await process_frame
	_set_keyboard_key_state(KEY_J, false)
	var attack_ok: bool = player.attack_step > 0
	_set_keyboard_key_state(KEY_K, true)
	await physics_frame
	await process_frame
	_set_keyboard_key_state(KEY_K, false)
	var jump_ok: bool = player.jump_timer > 0.0 or player.fake_height > 0.0
	player.special_meter = 100
	player.special_timer = 0.0
	_set_keyboard_key_state(KEY_L, true)
	await physics_frame
	await process_frame
	_set_keyboard_key_state(KEY_L, false)
	var special_ok: bool = player.special_timer > 0.0 and player.special_meter < 100
	player.dash_cooldown = 0.0
	_set_keyboard_key_state(KEY_I, true)
	await physics_frame
	await process_frame
	_set_keyboard_key_state(KEY_I, false)
	var dash_ok: bool = player.dash_timer > 0.0
	_press_keyboard_menu_key(app, KEY_ESCAPE)
	await process_frame
	var pause_ok: bool = paused and app.paused_overlay.visible
	_press_keyboard_menu_key(app, KEY_ESCAPE)
	await process_frame
	pause_ok = pause_ok and not paused and not app.paused_overlay.visible
	print("RIFT_ROAD_KEYBOARD_FALLBACK title=%s hero_select=%s movement=%s attack=%s jump=%s special=%s dash=%s pause=%s cancel=%s" % [
		str(title_ok),
		str(hero_select_ok),
		str(movement_ok),
		str(attack_ok),
		str(jump_ok),
		str(special_ok),
		str(dash_ok),
		str(pause_ok),
		str(cancel_ok)
	])
	var ok := title_ok and hero_select_ok and movement_ok and attack_ok and jump_ok and special_ok and dash_ok and pause_ok and cancel_ok
	if not ok:
		printerr("Keyboard fallback flow did not cover every required control")
	paused = false
	_release_keyboard_keys([KEY_D, KEY_J, KEY_K, KEY_L, KEY_I])
	app.queue_free()
	await process_frame
	return ok

func _run_stage1_focus_resume() -> bool:
	var packed: PackedScene = load("res://scenes/app_root.tscn")
	if packed == null:
		printerr("Could not load app root scene")
		return false
	var app = packed.instantiate()
	root.add_child(app)
	await process_frame
	await process_frame
	app.selected_hero = "raya_flint"
	app._start_campaign()
	await process_frame
	await process_frame
	if app.mode != "stage" or app.stage == null:
		printerr("Stage did not start before focus-resume smoke")
		app.queue_free()
		return false
	app._handle_focus_lost()
	await process_frame
	var focus_pause: bool = paused
	var overlay_visible: bool = app.pause_layer != null and app.pause_layer.visible and app.paused_overlay != null and app.paused_overlay.visible and app.title_layer != null and not app.title_layer.visible
	var focus_message: bool = app.pause_text_label != null and app.pause_text_label.text.contains("Window focus lost")
	var audio_suspended: bool = app.stage.audio_manager != null and app.stage.audio_manager.focus_suspended and app.stage.audio_manager.focus_suspend_count > 0
	app._handle_focus_returned()
	await process_frame
	var returned_message: bool = app.pause_text_label != null and app.pause_text_label.text == "PAUSED\nEsc / Start to resume"
	var audio_resumed: bool = app.stage.audio_manager != null and not app.stage.audio_manager.focus_suspended and app.stage.audio_manager.focus_resume_count > 0
	_press_keyboard_menu_key(app, KEY_ESCAPE)
	await process_frame
	var resume_ok: bool = not paused and app.pause_layer != null and not app.pause_layer.visible and app.paused_overlay != null and not app.paused_overlay.visible and app.title_layer != null and not app.title_layer.visible and app.mode == "stage"
	print("RIFT_ROAD_FOCUS_RESUME focus_pause=%s overlay=%s audio=%s resume=%s" % [
		str(focus_pause and focus_message),
		str(overlay_visible),
		str(audio_suspended and audio_resumed),
		str(resume_ok and returned_message)
	])
	var ok := focus_pause and overlay_visible and focus_message and audio_suspended and audio_resumed and returned_message and resume_ok
	if not ok:
		printerr("Stage 1 focus-loss pause/resume did not recover cleanly")
	paused = false
	app.queue_free()
	await process_frame
	return ok

func _press_controller_button(app, button_index: int) -> void:
	var event := InputEventJoypadButton.new()
	event.button_index = button_index
	event.pressed = true
	app._unhandled_input(event)

func _press_keyboard_menu_key(app, keycode: int) -> void:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.physical_keycode = keycode
	event.pressed = true
	app._unhandled_input(event)

func _set_keyboard_key_state(keycode: int, pressed_key: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.physical_keycode = keycode
	event.pressed = pressed_key
	Input.parse_input_event(event)

func _release_keyboard_keys(keys: Array) -> void:
	for keycode in keys:
		_set_keyboard_key_state(int(keycode), false)

func _run_stage1_performance_sample() -> bool:
	var packed: PackedScene = load("res://scenes/stages/sunset_overpass.tscn")
	if packed == null:
		printerr("Could not load Stage 1 scene")
		return false
	var stage = packed.instantiate()
	stage.hero_id = "raya_flint"
	stage.stage_id = "sunset_overpass"
	root.add_child(stage)
	await process_frame
	await process_frame
	if stage.player == null or not stage.has_method("set_demo_autoplay"):
		printerr("Stage 1 did not expose performance sample hooks")
		stage.queue_free()
		return false
	stage.player.max_health = 999
	stage.player.health = 999
	stage.set_demo_autoplay(true)
	var total_ms := 0.0
	var max_ms := 0.0
	var previous_tick := Time.get_ticks_usec()
	for _i in range(PERFORMANCE_SAMPLE_FRAMES):
		await physics_frame
		await process_frame
		var current_tick := Time.get_ticks_usec()
		var frame_ms := float(current_tick - previous_tick) / 1000.0
		previous_tick = current_tick
		total_ms += frame_ms
		max_ms = maxf(max_ms, frame_ms)
	var avg_ms := total_ms / float(PERFORMANCE_SAMPLE_FRAMES)
	var alive: bool = stage.player != null and is_instance_valid(stage.player) and stage.player.health > 0
	stage.set_demo_autoplay(false)
	stage.queue_free()
	await process_frame
	print("RIFT_ROAD_PERF stage1 frames=%d avg_ms=%.3f max_ms=%.3f budget_ms=%.1f max_budget_ms=%.1f" % [
		PERFORMANCE_SAMPLE_FRAMES,
		avg_ms,
		max_ms,
		PERFORMANCE_FRAME_BUDGET_MS,
		PERFORMANCE_MAX_FRAME_MS
	])
	if not alive:
		printerr("Stage 1 performance sample killed the player")
		return false
	if avg_ms > PERFORMANCE_FRAME_BUDGET_MS:
		printerr("Stage 1 average frame sample exceeded budget: %.3f" % avg_ms)
		return false
	if max_ms > PERFORMANCE_MAX_FRAME_MS:
		printerr("Stage 1 maximum frame sample exceeded spike budget: %.3f" % max_ms)
		return false
	return true

func _clear_spawned_enemies(stage) -> void:
	for enemy in stage.enemies:
		if enemy != null and is_instance_valid(enemy):
			enemy.queue_free()
	stage.enemies.clear()

func _any_visible_hero_card(app) -> bool:
	for card in app.hero_cards:
		if card != null and is_instance_valid(card) and card.visible:
			return true
	return false
