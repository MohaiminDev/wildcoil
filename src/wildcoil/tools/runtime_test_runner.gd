extends SceneTree

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
	if ok and mode == "hero_select_preview":
		ok = await _run_hero_select_preview()
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
	if app.label == null or not app.label.text.contains("RIFT ROAD"):
		printerr("Title label did not expose game title")
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

func _clear_spawned_enemies(stage) -> void:
	for enemy in stage.enemies:
		if enemy != null and is_instance_valid(enemy):
			enemy.queue_free()
	stage.enemies.clear()
