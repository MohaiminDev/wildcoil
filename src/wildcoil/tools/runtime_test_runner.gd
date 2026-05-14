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
	if ok and mode == "stage1_kian_default_lead":
		ok = await _run_stage1_kian_default_lead()
	if ok and mode == "reference_grunt_contract":
		ok = await _run_reference_grunt_contract()
	if ok and mode == "kian_combat_responsiveness":
		ok = await _run_kian_combat_responsiveness()
	if ok and mode == "kian_attack_timing_windows":
		ok = await _run_kian_attack_timing_windows()
	if ok and mode == "grunt_attack_hitbox_contract":
		ok = await _run_grunt_attack_hitbox_contract()
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
	if ok and mode == "controller_hotplug_status":
		ok = await _run_controller_hotplug_status()
	if ok and mode == "keyboard_fallback_flow":
		ok = await _run_keyboard_fallback_flow()
	if ok and mode == "keyboard_text_confirm_flow":
		ok = await _run_keyboard_text_confirm_flow()
	if ok and mode == "stage1_focus_resume":
		ok = await _run_stage1_focus_resume()
	if ok and mode == "exported_smoke_focus_guard":
		ok = await _run_exported_smoke_focus_guard()
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
	if not app.controls_label.text.contains("Kian") or not app.controls_label.text.contains("Tor"):
		printerr("Hero select controls did not expose hero choices")
		return false
	app.selected_hero = "kian_vale"
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
	if stage.player == null or stage.player.hero_id != "kian_vale":
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

func _run_stage1_kian_default_lead() -> bool:
	var packed: PackedScene = load("res://scenes/app_root.tscn")
	if packed == null:
		printerr("Could not load app root scene")
		return false
	var app = packed.instantiate()
	root.add_child(app)
	await process_frame
	await process_frame
	var roster_ok: bool = app.hero_roster.size() >= 4 and app.hero_roster[0].get("id", "") == "kian_vale" and app.hero_roster[1].get("id", "") == "tor_bram"
	var default_ok: bool = app.selected_hero == "kian_vale" and app.selected_hero_index == 0
	app._show_character_select()
	await process_frame
	app._show_hero_capability_preview()
	await process_frame
	app._confirm_hero_and_start()
	await process_frame
	await process_frame
	var stage_ok: bool = app.mode == "stage" and app.stage != null and app.stage.player != null and app.stage.hero_id == "kian_vale" and app.stage.player.hero_id == "kian_vale"
	print("RIFT_ROAD_KIAN_DEFAULT_LEAD roster=%s default=%s stage=%s" % [
		str(roster_ok).to_lower(),
		str(default_ok).to_lower(),
		str(stage_ok).to_lower()
	])
	var ok := roster_ok and default_ok and stage_ok
	if not ok:
		printerr("Kian was not the default Stage 1 lead")
	app.queue_free()
	await process_frame
	return ok

func _run_reference_grunt_contract() -> bool:
	var packed: PackedScene = load("res://scenes/stages/sunset_overpass.tscn")
	if packed == null:
		printerr("Could not load Stage 1 scene")
		return false
	var stage = packed.instantiate()
	stage.hero_id = "kian_vale"
	stage.stage_id = "sunset_overpass"
	root.add_child(stage)
	await process_frame
	await process_frame
	if stage.player == null or stage.enemies.size() != 1:
		printerr("Reference grunt contract expected one opening enemy")
		stage.queue_free()
		return false
	var grunt = stage.enemies[0]
	grunt.cinematic_entry_active = false
	grunt.position = stage.player.position + Vector2(190, 0)
	grunt.attack_cooldown = 0.0
	var approach_seen := false
	var spacing_seen := false
	var telegraph_seen := false
	var attack_seen := false
	var flinch_seen := false
	var recover_seen := false
	var defeated_seen := false
	stage.player.max_health = 999
	stage.player.health = 999
	for _i in range(150):
		await physics_frame
		await process_frame
		if grunt == null or not is_instance_valid(grunt):
			break
		approach_seen = approach_seen or grunt.combat_state == "approach"
		var direct_distance: float = grunt.position.distance_to(stage.player.position)
		spacing_seen = spacing_seen or grunt.combat_state == "spacing" or (grunt.velocity.length() < 1.0 and direct_distance <= grunt.attack_range + 18.0)
		telegraph_seen = telegraph_seen or grunt.combat_state == "telegraph"
		attack_seen = attack_seen or grunt.combat_state == "attack" or grunt.attack_has_landed
		if telegraph_seen and attack_seen:
			break
	if grunt == null or not is_instance_valid(grunt):
		printerr("Reference grunt disappeared before damage response check")
		stage.queue_free()
		return false
	grunt.apply_damage(12, stage.player.position.x)
	await physics_frame
	await process_frame
	flinch_seen = grunt.combat_state == "flinch" or grunt.hurt_flash > 0.0
	for _i in range(25):
		await physics_frame
		await process_frame
		if grunt == null or not is_instance_valid(grunt):
			break
		recover_seen = recover_seen or grunt.combat_state == "recover" or grunt.combat_state == "spacing" or grunt.combat_state == "approach"
		if recover_seen:
			break
	if grunt != null and is_instance_valid(grunt):
		grunt.apply_damage(999, stage.player.position.x)
		await process_frame
		defeated_seen = grunt.combat_state == "defeated" or grunt.health <= 0
	print("RIFT_ROAD_REFERENCE_GRUNT approach=%s spacing=%s telegraph=%s attack=%s flinch=%s recover=%s defeated=%s" % [
		str(approach_seen).to_lower(),
		str(spacing_seen).to_lower(),
		str(telegraph_seen).to_lower(),
		str(attack_seen).to_lower(),
		str(flinch_seen).to_lower(),
		str(recover_seen).to_lower(),
		str(defeated_seen).to_lower()
	])
	var ok := approach_seen and spacing_seen and telegraph_seen and attack_seen and flinch_seen and recover_seen and defeated_seen
	if not ok:
		printerr("Reference grunt did not satisfy combat behavior contract")
	stage.queue_free()
	await process_frame
	return ok

func _run_kian_combat_responsiveness() -> bool:
	var combo_reset := await _check_kian_combo_reset()
	var special_area := await _check_kian_special_area_hits_enemies()
	var dodge_avoids := await _check_kian_dodge_avoids_grunt_attack()
	print("RIFT_ROAD_KIAN_COMBAT_RESPONSIVENESS combo_reset=%s special_area=%s dodge_avoids=%s" % [
		str(combo_reset).to_lower(),
		str(special_area).to_lower(),
		str(dodge_avoids).to_lower()
	])
	if not combo_reset:
		printerr("Kian combo chain did not reset after the combo window")
	if not special_area:
		printerr("Kian special did not damage an enemy inside the special area")
	if not dodge_avoids:
		printerr("Kian dodge did not avoid a readable grunt attack")
	return combo_reset and special_area and dodge_avoids

func _check_kian_combo_reset() -> bool:
	var packed: PackedScene = load("res://scenes/stages/sunset_overpass.tscn")
	if packed == null:
		printerr("Could not load Stage 1 scene")
		return false
	var stage = packed.instantiate()
	stage.hero_id = "kian_vale"
	stage.stage_id = "sunset_overpass"
	root.add_child(stage)
	await process_frame
	await process_frame
	var player = stage.player
	if player == null:
		stage.queue_free()
		await process_frame
		return false
	player.attack_step = 2
	player.combo_timer = 0.01
	player.attack_timer = 0.0
	await physics_frame
	await process_frame
	var reset_seen: bool = player.attack_step == 0
	if player.has_method("_start_light_attack"):
		player._start_light_attack()
	var restarts_at_one: bool = player.attack_step == 1
	stage.queue_free()
	await process_frame
	return reset_seen and restarts_at_one

func _check_kian_special_area_hits_enemies() -> bool:
	var packed: PackedScene = load("res://scenes/stages/sunset_overpass.tscn")
	if packed == null:
		printerr("Could not load Stage 1 scene")
		return false
	var stage = packed.instantiate()
	stage.hero_id = "kian_vale"
	stage.stage_id = "sunset_overpass"
	root.add_child(stage)
	await process_frame
	await process_frame
	if stage.player == null or stage.enemies.is_empty():
		stage.queue_free()
		await process_frame
		return false
	var player = stage.player
	var enemy = stage.enemies[0]
	enemy.cinematic_entry_active = false
	enemy.position = player.position + Vector2(0, -92)
	enemy.health = enemy.max_health
	player.attack_step = 1
	player.facing = 1
	player.special_meter = 100
	player.special_timer = 0.0
	player.attack_timer = 0.0
	if player.has_method("_start_special_attack"):
		player._start_special_attack()
	for _i in range(10):
		await physics_frame
		await process_frame
	stage._handle_combat()
	await process_frame
	var hit_seen: bool = enemy.health < enemy.max_health
	stage.queue_free()
	await process_frame
	return hit_seen

func _check_kian_dodge_avoids_grunt_attack() -> bool:
	var packed: PackedScene = load("res://scenes/stages/sunset_overpass.tscn")
	if packed == null:
		printerr("Could not load Stage 1 scene")
		return false
	var stage = packed.instantiate()
	stage.hero_id = "kian_vale"
	stage.stage_id = "sunset_overpass"
	root.add_child(stage)
	await process_frame
	await process_frame
	if stage.player == null or stage.enemies.is_empty():
		stage.queue_free()
		await process_frame
		return false
	var player = stage.player
	var enemy = stage.enemies[0]
	player.max_health = 200
	player.health = 200
	player.position = Vector2(420, 520)
	player.facing = 1
	enemy.cinematic_entry_active = false
	enemy.position = player.position + Vector2(54, 0)
	enemy.facing = -1
	enemy.attack_cooldown = 0.0
	enemy.telegraph_timer = 0.035
	enemy.attack_has_landed = false
	enemy.combat_state = "telegraph"
	if player.has_method("begin_dodge"):
		player.begin_dodge()
	else:
		player.dash_timer = 0.13
	for _i in range(8):
		await physics_frame
		await process_frame
	var avoided: bool = player.health == 200
	stage.queue_free()
	await process_frame
	return avoided

func _run_kian_attack_timing_windows() -> bool:
	var packed: PackedScene = load("res://scenes/stages/sunset_overpass.tscn")
	if packed == null:
		printerr("Could not load Stage 1 scene")
		return false
	var stage = packed.instantiate()
	stage.hero_id = "kian_vale"
	stage.stage_id = "sunset_overpass"
	root.add_child(stage)
	await process_frame
	await process_frame
	var player = stage.player
	if player == null:
		stage.queue_free()
		await process_frame
		return false
	player.attack_step = 0
	player.combo_timer = 0.0
	player.attack_timer = 0.0
	if player.has_method("_start_light_attack"):
		player._start_light_attack()
	var timing: Dictionary = player.current_attack_timing if "current_attack_timing" in player else {}
	var has_data := timing.has("startup") and timing.has("active") and timing.has("recovery") and timing.has("hitbox")
	var startup_seen := false
	var active_seen := false
	var recovery_seen := false
	var hitbox_seen := false
	if has_data:
		startup_seen = not player.is_attack_active()
		var startup_frames := maxi(1, int(ceil(float(timing["startup"]) * 60.0)) + 1)
		for _i in range(startup_frames):
			await physics_frame
			await process_frame
		active_seen = player.is_attack_active()
		var hitbox: Dictionary = timing["hitbox"]
		var rect: Rect2 = player.attack_rect()
		hitbox_seen = absf(rect.size.x - float(hitbox["width"])) <= 0.1 and absf(rect.size.y - float(hitbox["height"])) <= 0.1
		var active_frames := maxi(1, int(ceil(float(timing["active"]) * 60.0)) + 2)
		for _i in range(active_frames):
			await physics_frame
			await process_frame
		recovery_seen = player.attack_timer > 0.0 and not player.is_attack_active()
	print("RIFT_ROAD_KIAN_ATTACK_TIMING data=%s startup=%s active=%s recovery=%s hitbox=%s" % [
		str(has_data).to_lower(),
		str(startup_seen).to_lower(),
		str(active_seen).to_lower(),
		str(recovery_seen).to_lower(),
		str(hitbox_seen).to_lower()
	])
	var ok := has_data and startup_seen and active_seen and recovery_seen and hitbox_seen
	if not ok:
		printerr("Kian light attack timing did not use data-driven startup/active/recovery windows")
	stage.queue_free()
	await process_frame
	return ok

func _run_grunt_attack_hitbox_contract() -> bool:
	var packed: PackedScene = load("res://scenes/stages/sunset_overpass.tscn")
	if packed == null:
		printerr("Could not load Stage 1 scene")
		return false
	var stage = packed.instantiate()
	stage.hero_id = "kian_vale"
	stage.stage_id = "sunset_overpass"
	root.add_child(stage)
	await process_frame
	await process_frame
	if stage.player == null or stage.enemies.is_empty():
		stage.queue_free()
		await process_frame
		return false
	var player = stage.player
	var enemy = stage.enemies[0]
	player.max_health = 200
	player.health = 200
	player.position = Vector2(420, 500)
	enemy.cinematic_entry_active = false
	enemy.position = player.position + Vector2(48, 118)
	enemy.facing = -1
	stage._on_enemy_attack(enemy, 17)
	await process_frame
	var whiff_seen: bool = player.health == 200
	enemy.position = player.position + Vector2(48, 0)
	stage._on_enemy_attack(enemy, 17)
	await process_frame
	var hit_seen: bool = player.health == 183
	print("RIFT_ROAD_GRUNT_ATTACK_HITBOX whiff=%s hit=%s" % [
		str(whiff_seen).to_lower(),
		str(hit_seen).to_lower()
	])
	var ok := whiff_seen and hit_seen
	if not ok:
		printerr("Grunt attack did not require enemy hitbox and player hurtbox overlap")
	stage.queue_free()
	await process_frame
	return ok

func _run_stage1_autoplay() -> bool:
	var packed: PackedScene = load("res://scenes/stages/sunset_overpass.tscn")
	if packed == null:
		printerr("Could not load Stage 1 scene")
		return false
	var stage = packed.instantiate()
	stage.hero_id = "kian_vale"
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
	stage.hero_id = "kian_vale"
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
	stage.hero_id = "kian_vale"
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
	stage.hero_id = "kian_vale"
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
	stage.hero_id = "kian_vale"
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
	app.selected_hero_index = 1
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
	if app.label == null or not app.label.text.contains("CAPABILITIES") or not app.label.text.contains("Tor Bram") or not app.label.text.contains("PLANNED HERO"):
		printerr("Hero capability preview did not show selected hero details")
		app.queue_free()
		return false
	app._confirm_hero_and_start()
	await process_frame
	await process_frame
	var planned_blocked: bool = app.mode == "hero_preview" and app.stage == null
	if not planned_blocked:
		printerr("Planned hero preview started Stage 1 instead of staying preview-only")
		app.queue_free()
		return false
	app.selected_hero_index = 0
	app._show_hero_capability_preview()
	await process_frame
	app._confirm_hero_and_start()
	await process_frame
	await process_frame
	var playable_started: bool = app.mode == "stage" and app.stage != null and app.stage.hero_id == "kian_vale"
	if not playable_started:
		printerr("Playable Kian preview did not start Stage 1")
		app.queue_free()
		return false
	print("RIFT_ROAD_PLANNED_HERO_LOCK blocked=%s playable_start=%s" % [str(planned_blocked).to_lower(), str(playable_started).to_lower()])
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
	app.selected_hero = "kian_vale"
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
	_press_controller_button(app, JOY_BUTTON_LEFT_SHOULDER)
	await process_frame
	if app.selected_hero_index != 0:
		printerr("Controller did not cycle from planned Tor preview to playable Kian")
		app.queue_free()
		return false
	_press_controller_button(app, JOY_BUTTON_A)
	await process_frame
	_press_controller_button(app, JOY_BUTTON_A)
	await process_frame
	await process_frame
	if app.mode != "stage" or app.stage == null or app.stage.hero_id != "kian_vale":
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

func _run_controller_hotplug_status() -> bool:
	var packed: PackedScene = load("res://scenes/app_root.tscn")
	if packed == null:
		printerr("Could not load app root scene")
		return false
	var app = packed.instantiate()
	root.add_child(app)
	await process_frame
	await process_frame
	app._on_joy_connection_changed(4, true)
	await process_frame
	var connected_ok: bool = app.controller_hotplug_events == 1 and app.controller_status_text.contains("Controller connected") and app.controls_label.text.contains("Controller connected")
	app._show_character_select()
	await process_frame
	var prompt_ok: bool = app.controls_label.text.contains("Controller connected")
	app._on_joy_connection_changed(4, false)
	await process_frame
	var disconnected_ok: bool = app.controller_hotplug_events == 2 and app.controller_status_text.contains("Controller disconnected") and app.controls_label.text.contains("Controller disconnected") and not app.controls_label.text.contains("Controller connected:")
	print("RIFT_ROAD_CONTROLLER_HOTPLUG connected=%s disconnected=%s prompt=%s events=%d" % [
		str(connected_ok),
		str(disconnected_ok),
		str(prompt_ok),
		app.controller_hotplug_events
	])
	var ok: bool = connected_ok and disconnected_ok and prompt_ok and app.controller_hotplug_events == 2
	if not ok:
		printerr("Controller hot-plug status did not update cleanly")
	app.queue_free()
	await process_frame
	return ok

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
	_press_keyboard_menu_key(app, KEY_2)
	await process_frame
	hero_select_ok = hero_select_ok and app.selected_hero_index == 1 and app.mode == "hero_preview"
	if not hero_select_ok:
		printerr("Keyboard roster key did not open the selected hero preview")
		app.queue_free()
		await process_frame
		return false
	_press_keyboard_menu_key(app, KEY_ESCAPE)
	await process_frame
	var cancel_ok: bool = app.mode == "character_select"
	_press_keyboard_menu_key(app, KEY_1)
	await process_frame
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

func _run_keyboard_text_confirm_flow() -> bool:
	var packed: PackedScene = load("res://scenes/app_root.tscn")
	if packed == null:
		printerr("Could not load app root scene")
		return false
	var app = packed.instantiate()
	root.add_child(app)
	await process_frame
	await process_frame
	app._show_character_select()
	app.selected_hero_index = 0
	app._show_hero_capability_preview()
	await process_frame
	_press_text_keyboard_menu_key(app, 0, 106)
	await process_frame
	await process_frame
	var started: bool = app.mode == "stage" and app.stage != null and app.stage.player != null
	print("RIFT_ROAD_KEYBOARD_TEXT_CONFIRM started=%s" % str(started))
	if not started:
		printerr("Keyboard text-style J event did not start Stage 1")
	app.queue_free()
	await process_frame
	return started

func _run_stage1_focus_resume() -> bool:
	var packed: PackedScene = load("res://scenes/app_root.tscn")
	if packed == null:
		printerr("Could not load app root scene")
		return false
	var app = packed.instantiate()
	root.add_child(app)
	await process_frame
	await process_frame
	app.selected_hero = "kian_vale"
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

func _run_exported_smoke_focus_guard() -> bool:
	var packed: PackedScene = load("res://scenes/app_root.tscn")
	if packed == null:
		printerr("Could not load app root scene")
		return false
	var app = packed.instantiate()
	root.add_child(app)
	await process_frame
	await process_frame
	app.selected_hero = "kian_vale"
	app._start_campaign()
	await process_frame
	await process_frame
	if app.mode != "stage" or app.stage == null:
		printerr("Stage did not start before exported smoke focus guard")
		app.queue_free()
		return false
	app.smoke_capture_active = true
	app._handle_focus_lost()
	await process_frame
	var pause_blocked: bool = not paused and not app.focus_pause_active
	var overlay_hidden: bool = app.pause_layer == null or (not app.pause_layer.visible and app.paused_overlay != null and not app.paused_overlay.visible)
	print("RIFT_ROAD_EXPORTED_SMOKE_FOCUS_GUARD paused=%s overlay=%s focus_active=%s" % [
		str(paused).to_lower(),
		str(not overlay_hidden).to_lower(),
		str(app.focus_pause_active).to_lower()
	])
	var ok := pause_blocked and overlay_hidden
	if not ok:
		printerr("Exported smoke focus guard allowed focus-loss pause")
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

func _press_text_keyboard_menu_key(app, physical_keycode: int, unicode_value: int) -> void:
	var event := InputEventKey.new()
	event.keycode = 0
	event.physical_keycode = physical_keycode
	event.unicode = unicode_value
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
	stage.hero_id = "kian_vale"
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
