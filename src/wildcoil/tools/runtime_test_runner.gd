extends SceneTree

const ContentCatalog = preload("res://scripts/core/content_catalog.gd")
const EnemyProfileLibrary = preload("res://scripts/core/enemy_profile_library.gd")
const InputActions = preload("res://scripts/core/input_actions.gd")
const InputDeviceState = preload("res://scripts/core/input_device_state.gd")
const PlayerCombatModel = preload("res://scripts/core/player_combat_model.gd")
const PlayerMotorModel = preload("res://scripts/core/player_motor_model.gd")
const ProgressionProfile = preload("res://scripts/core/progression_profile.gd")


func _initialize() -> void:
	var suite := "smoke"
	var save_path := ""
	var args := OS.get_cmdline_user_args()
	for index in range(args.size()):
		if args[index] == "--suite" and index + 1 < args.size():
			suite = args[index + 1]
		if args[index] == "--save-path" and index + 1 < args.size():
			save_path = args[index + 1]

	var catalog := ContentCatalog.load_default()
	var errors := catalog.validate()
	var payload := {
		"suite": suite,
		"passed": errors.is_empty(),
		"errors": errors,
		"build_label": catalog.build_label,
		"stage_ids": catalog.get_stage_ids(),
		"character_count": catalog.characters.size(),
	}

	if suite == "stage_scene" and errors.is_empty():
		var stage_definition := catalog.get_first_stage()
		var packed_scene := load(str(stage_definition.get("scene", ""))) as PackedScene
		if packed_scene == null:
			payload["passed"] = false
			payload["errors"] = ["default stage failed to load"]
		else:
			var stage_instance := packed_scene.instantiate()
			get_root().add_child(stage_instance)
			payload["stage_root_name"] = stage_instance.name
			payload["player_present"] = stage_instance.get_node_or_null("Player") != null
			payload["enemy_count"] = int(stage_instance.call("get_enemy_nodes").size())
			payload["dummy_present"] = stage_instance.call("get_combat_dummy") != null
			stage_instance.free()

	if suite == "movement_model":
		payload.merge(run_movement_model_suite(), true)

	if suite == "input_device":
		payload.merge(run_input_device_suite(), true)

	if suite == "combat_model":
		payload.merge(run_combat_model_suite(), true)

	if suite == "damage_rules":
		payload.merge(run_damage_rules_suite(), true)

	if suite == "checkpoint_reset" and errors.is_empty():
		payload.merge(run_checkpoint_reset_suite(catalog), true)

	if suite == "enemy_profiles":
		payload.merge(run_enemy_profile_suite(), true)

	if suite == "enemy_stage" and errors.is_empty():
		payload.merge(run_enemy_stage_suite(catalog), true)

	if suite == "first_playable" and errors.is_empty():
		payload.merge(run_first_playable_suite(catalog), true)

	if suite == "vertical_slice" and errors.is_empty():
		payload.merge(run_vertical_slice_suite(catalog), true)

	if suite == "progression" and errors.is_empty():
		payload.merge(run_progression_suite(catalog, save_path), true)

	if suite == "frontend_shell" and errors.is_empty():
		payload.merge(run_frontend_shell_suite(), true)

	if suite == "content_validation":
		payload.merge(run_content_validation_suite(catalog), true)

	print("WILDCOIL_TEST_RESULTS %s" % JSON.stringify(payload))
	quit(0 if payload["passed"] else 1)


func run_movement_model_suite() -> Dictionary:
	var model := PlayerMotorModel.new()
	var move_state := model.make_default_state()
	move_state = model.advance(move_state, {"move": 1.0}, 1.0 / 60.0)

	var jump_state := model.make_default_state()
	jump_state = model.advance(jump_state, {"jump_pressed": true}, 1.0 / 60.0)

	var dodge_state := model.make_default_state()
	dodge_state = model.advance(dodge_state, {"move": -1.0, "dodge_pressed": true}, 1.0 / 60.0)
	var dodge_followup := model.advance(dodge_state, {"move": 0.0}, 1.0 / 60.0)

	var checks := {
		"move_velocity_x": snappedf((move_state["velocity"] as Vector2).x, 0.01),
		"jump_velocity_y": snappedf((jump_state["velocity"] as Vector2).y, 0.01),
		"dodge_velocity_x": snappedf((dodge_state["velocity"] as Vector2).x, 0.01),
		"dodge_timer": snappedf(float(dodge_state["dodge_timer"]), 0.001),
		"dodge_followup_velocity_x": snappedf((dodge_followup["velocity"] as Vector2).x, 0.01),
	}
	var move_velocity_x: float = checks["move_velocity_x"]
	var jump_velocity_y: float = checks["jump_velocity_y"]
	var dodge_velocity_x: float = checks["dodge_velocity_x"]
	var dodge_timer: float = checks["dodge_timer"]
	var dodge_followup_velocity_x: float = checks["dodge_followup_velocity_x"]
	var passed: bool = move_velocity_x > 0.0 and jump_velocity_y < 0.0 and dodge_velocity_x < 0.0 and dodge_timer > 0.0 and dodge_followup_velocity_x < 0.0
	checks["passed"] = passed
	if not passed:
		checks["errors"] = ["movement model failed one or more locomotion expectations"]
	return checks


func run_input_device_suite() -> Dictionary:
	InputActions.ensure_default_actions()
	var device_state := InputDeviceState.new()
	device_state.refresh_connected_gamepads()

	var keyboard_event := InputEventKey.new()
	keyboard_event.pressed = true
	keyboard_event.physical_keycode = KEY_A
	device_state.handle_event(keyboard_event)

	device_state.handle_connection_change(7, true)
	var controller_event := InputEventJoypadButton.new()
	controller_event.device = 7
	controller_event.button_index = JOY_BUTTON_A
	controller_event.pressed = true
	device_state.handle_event(controller_event)
	device_state.handle_connection_change(7, false)

	var action_names := [
		InputActions.MOVE_LEFT,
		InputActions.MOVE_RIGHT,
		InputActions.JUMP,
		InputActions.DODGE,
		InputActions.LIGHT_ATTACK,
		InputActions.HEAVY_ATTACK,
		InputActions.LAUNCH_ATTACK,
		InputActions.SPECIAL_ATTACK,
		InputActions.FULLSCREEN,
		InputActions.MENU_LEFT,
		InputActions.MENU_RIGHT,
		InputActions.MENU_UP,
		InputActions.MENU_DOWN,
		InputActions.MENU_CONFIRM,
		InputActions.MENU_BACK,
	]
	var all_actions_present := true
	for action_name in action_names:
		all_actions_present = all_actions_present and InputMap.has_action(action_name)

	var passed: bool = all_actions_present and device_state.active_scheme == InputDeviceState.SCHEME_KEYBOARD
	return {
		"actions_present": all_actions_present,
		"connected_pad_count": device_state.connected_gamepads.size(),
		"active_scheme": device_state.active_scheme,
		"passed": passed,
		"errors": [] if passed else ["input actions or device tracking failed"],
	}


func run_combat_model_suite() -> Dictionary:
	var model := PlayerCombatModel.new()
	var light_state := model.make_default_state()
	light_state = model.advance(light_state, {"light_pressed": true}, 0.0)
	light_state = model.advance(light_state, {"light_pressed": true}, 0.11)
	light_state = model.advance(light_state, {"light_pressed": false}, 0.11)

	var heavy_state := model.make_default_state()
	heavy_state = model.advance(heavy_state, {"heavy_pressed": true}, 0.0)
	heavy_state = model.advance(heavy_state, {"heavy_pressed": false}, 0.21)
	var heavy_event: Dictionary = heavy_state.get("attack_event", {})

	var launcher_state := model.make_default_state()
	launcher_state = model.advance(launcher_state, {"launcher_pressed": true}, 0.0)
	launcher_state = model.advance(launcher_state, {"launcher_pressed": false}, 0.16)
	var launcher_event: Dictionary = launcher_state.get("attack_event", {})

	var special_state := model.make_default_state()
	special_state = model.advance(special_state, {"special_pressed": true}, 0.0)
	special_state = model.advance(special_state, {"special_pressed": false}, 0.23)
	var special_event: Dictionary = special_state.get("attack_event", {})

	var light_attack_kind := str(light_state.get("attack_kind", ""))
	var passed: bool = light_attack_kind == "light" and str(heavy_event.get("kind", "")) == "heavy" and str(launcher_event.get("kind", "")) == "launcher" and str(special_event.get("kind", "")) == "special" and float(special_state.get("special_cooldown", 0.0)) > 0.0
	return {
		"light_attack_kind": light_attack_kind,
		"heavy_kind": str(heavy_event.get("kind", "")),
		"launcher_kind": str(launcher_event.get("kind", "")),
		"special_kind": str(special_event.get("kind", "")),
		"special_cooldown": float(special_state.get("special_cooldown", 0.0)),
		"passed": passed,
		"errors": [] if passed else ["combat model did not emit the expected attack events"],
	}


func run_damage_rules_suite() -> Dictionary:
	var model := PlayerCombatModel.new()
	var damaged_state := model.make_default_state()
	damaged_state = model.apply_damage(damaged_state, 18, 0.3)
	var blocked_state := model.apply_damage(damaged_state, 18, 0.3)
	var passed: bool = int(damaged_state.get("health", 0)) == PlayerCombatModel.MAX_HEALTH - 18 and bool(damaged_state.get("took_damage", false)) and int(blocked_state.get("health", 0)) == int(damaged_state.get("health", 0)) and not bool(blocked_state.get("took_damage", true))
	return {
		"health_after_first_hit": int(damaged_state.get("health", 0)),
		"health_after_second_hit": int(blocked_state.get("health", 0)),
		"first_hit_registered": bool(damaged_state.get("took_damage", false)),
		"second_hit_blocked": not bool(blocked_state.get("took_damage", true)),
		"passed": passed,
		"errors": [] if passed else ["damage resolution or invulnerability rules failed"],
	}


func run_checkpoint_reset_suite(catalog: ContentCatalog) -> Dictionary:
	var stage_definition := catalog.get_first_stage()
	var packed_scene := load(str(stage_definition.get("scene", ""))) as PackedScene
	if packed_scene == null:
		return {
			"passed": false,
			"errors": ["default stage scene failed to load for checkpoint reset suite"],
		}

	var stage_instance := packed_scene.instantiate()
	get_root().add_child(stage_instance)
	var player := stage_instance.get_node_or_null("Player") as PlayerController
	var dummy := stage_instance.call("get_combat_dummy") as EnemyActor
	if player == null or dummy == null:
		stage_instance.free()
		return {
			"passed": false,
			"errors": ["player or combat dummy was missing from the default stage"],
		}
	player.apply_enemy_attack(dummy.get_attack_profile(), 1.0, player.global_position - Vector2(10.0, 0.0))
	stage_instance.call("reset_to_checkpoint")

	var expected_enemy_health := int(dummy.profile.get("health", dummy.health))
	var passed: bool = player.get_health() == PlayerCombatModel.MAX_HEALTH and dummy.health == expected_enemy_health and int(stage_instance.get("checkpoint_reset_count")) >= 1
	var payload := {
		"player_health": player.get_health(),
		"dummy_health": dummy.health,
		"expected_dummy_health": expected_enemy_health,
		"checkpoint_reset_count": int(stage_instance.get("checkpoint_reset_count")),
		"passed": passed,
		"errors": [] if passed else ["checkpoint reset did not restore player and dummy state"],
	}
	stage_instance.free()
	return payload


func run_enemy_profile_suite() -> Dictionary:
	var errors := EnemyProfileLibrary.validate_profiles()
	var ids := EnemyProfileLibrary.get_profile_ids()
	var elite_count := 0
	for enemy_id in ids:
		var profile := EnemyProfileLibrary.get_profile(enemy_id)
		if bool(profile.get("is_elite", false)):
			elite_count += 1
	var passed: bool = errors.is_empty() and ids.size() >= 3 and elite_count >= 1
	return {
		"profile_ids": ids,
		"elite_count": elite_count,
		"passed": passed,
		"errors": errors if not passed else [],
	}


func run_enemy_stage_suite(catalog: ContentCatalog) -> Dictionary:
	var stage_definition := catalog.get_first_stage()
	var packed_scene := load(str(stage_definition.get("scene", ""))) as PackedScene
	if packed_scene == null:
		return {
			"passed": false,
			"errors": ["default stage scene failed to load for enemy stage suite"],
		}

	var stage_instance := packed_scene.instantiate()
	get_root().add_child(stage_instance)
	var enemies: Array = stage_instance.call("get_enemy_nodes")
	var elite_enemy := stage_instance.call("get_elite_enemy") as EnemyActor
	var passed: bool = enemies.size() >= 3 and elite_enemy != null
	var payload := {
		"enemy_count": enemies.size(),
		"elite_present": elite_enemy != null,
		"live_enemy_count": int(stage_instance.call("get_live_enemy_count")),
		"passed": passed,
		"errors": [] if passed else ["stage did not expose three enemies plus an elite foundation"],
	}
	stage_instance.free()
	return payload


func run_first_playable_suite(catalog: ContentCatalog) -> Dictionary:
	var stage_definition := catalog.get_first_stage()
	var packed_scene := load(str(stage_definition.get("scene", ""))) as PackedScene
	if packed_scene == null:
		return {
			"passed": false,
			"errors": ["default stage scene failed to load for first playable suite"],
		}

	var stage_instance := packed_scene.instantiate()
	get_root().add_child(stage_instance)
	var player := stage_instance.call("get_player") as PlayerController
	if player == null:
		stage_instance.free()
		return {
			"passed": false,
			"errors": ["default stage did not expose a player for first playable suite"],
		}

	var initial_summary: Dictionary = stage_instance.call("get_stage_summary")
	player.global_position.x = -80.0
	stage_instance.call("advance_stage_flow", 0.1)
	var combat_summary: Dictionary = stage_instance.call("get_stage_summary")
	for enemy in stage_instance.call("get_enemy_nodes"):
		if enemy is EnemyActor:
			enemy.health = 0
	stage_instance.call("advance_stage_flow", 0.1)
	var spectacle_summary: Dictionary = stage_instance.call("get_stage_summary")
	stage_instance.call("advance_stage_flow", 4.0)
	var final_summary: Dictionary = stage_instance.call("get_stage_summary")

	var passed: bool = str(initial_summary.get("phase", "")) == "approach" and float(combat_summary.get("first_combat_seconds", -1.0)) >= 0.0 and float(spectacle_summary.get("spectacle_seconds", -1.0)) >= 0.0 and str(spectacle_summary.get("audio_state", "")) == "spectacle" and str(final_summary.get("phase", "")) == "advance"
	var payload := {
		"initial_phase": str(initial_summary.get("phase", "")),
		"first_combat_seconds": float(combat_summary.get("first_combat_seconds", -1.0)),
		"spectacle_seconds": float(spectacle_summary.get("spectacle_seconds", -1.0)),
		"final_phase": str(final_summary.get("phase", "")),
		"stage_complete": bool(final_summary.get("stage_complete", false)),
		"passed": passed,
		"errors": [] if passed else ["first playable stage flow did not reach encounter, spectacle, and boss-approach states"],
	}
	stage_instance.free()
	return payload


func run_vertical_slice_suite(catalog: ContentCatalog) -> Dictionary:
	var stage_definition := catalog.get_first_stage()
	var packed_scene := load(str(stage_definition.get("scene", ""))) as PackedScene
	if packed_scene == null:
		return {
			"passed": false,
			"errors": ["default stage scene failed to load for vertical slice suite"],
		}

	var stage_instance := packed_scene.instantiate()
	get_root().add_child(stage_instance)
	var player := stage_instance.call("get_player") as PlayerController
	var boss_actor := stage_instance.call("get_boss_actor") as BossActor
	if player == null or boss_actor == null:
		stage_instance.free()
		return {
			"passed": false,
			"errors": ["stage did not expose player and boss actors for vertical slice suite"],
		}

	player.global_position.x = -80.0
	stage_instance.call("advance_stage_flow", 0.1)
	for enemy in stage_instance.call("get_enemy_nodes"):
		if enemy is EnemyActor:
			enemy.health = 0
	stage_instance.call("advance_stage_flow", 4.0)
	player.global_position.x = 980.0
	stage_instance.call("advance_stage_flow", 0.1)
	stage_instance.call("advance_stage_flow", 2.0)
	boss_actor.health = 0
	stage_instance.call("advance_stage_flow", 0.1)
	var final_summary: Dictionary = stage_instance.call("get_stage_summary")
	var passed: bool = bool(final_summary.get("boss_seen", false)) and bool(final_summary.get("stage_complete", false)) and str(final_summary.get("rank", "--")) != "--"
	var payload := {
		"boss_seen": bool(final_summary.get("boss_seen", false)),
		"boss_state": str(final_summary.get("boss_state", "")),
		"stage_complete": bool(final_summary.get("stage_complete", false)),
		"rank": str(final_summary.get("rank", "--")),
		"passed": passed,
		"errors": [] if passed else ["vertical slice did not reach boss and clear states"],
	}
	stage_instance.free()
	return payload


func run_progression_suite(catalog: ContentCatalog, save_path: String) -> Dictionary:
	var fixture_catalog := ContentCatalog.from_dictionary({
		"build_label": "phase2-progression-fixture",
		"characters": [
			{
				"id": "mira_coil",
				"name": "Mira Coil",
				"playstyle": "balanced_striker",
				"locked": false,
			},
			{
				"id": "zeph_rush",
				"name": "Zeph Rush",
				"playstyle": "agile_disruptor",
				"locked": true,
			},
		],
		"stages": [
			{
				"id": "relay_clearing",
				"name": "Relay Clearing",
				"scene": "res://scenes/stages/relay_clearing.tscn",
				"order": 1,
				"biome": "storm_basin_edge",
				"spectacle_target_seconds": 180,
				"reward_character_id": "zeph_rush",
			},
			{
				"id": "coil_depths",
				"name": "Coil Depths",
				"scene": "res://scenes/stages/relay_clearing.tscn",
				"order": 2,
				"biome": "coil_depths",
				"spectacle_target_seconds": 180,
			},
		],
	})
	var working_save_path := save_path if not save_path.is_empty() else "user://wildcoil_progression_test.json"
	var preserve_save := not save_path.is_empty()
	var corrupt_save_path := "%s.corrupt-source.json" % working_save_path.get_basename()
	delete_path_if_present(working_save_path)
	delete_path_if_present(corrupt_save_path)
	delete_corrupt_backups(working_save_path)
	delete_corrupt_backups(corrupt_save_path)

	var profile := ProgressionProfile.load_or_create(working_save_path, fixture_catalog)
	var initial_stage_id := profile.get_selected_stage_id()
	var initial_character_id := profile.get_selected_character_id()
	var set_stage_ok := profile.set_selected_stage_id(fixture_catalog.get_first_stage_id(), fixture_catalog)
	var set_character_ok := profile.set_selected_character_id(fixture_catalog.get_first_character_id(), fixture_catalog)
	profile.set_option_value("high_contrast_hud", true)
	profile.save()
	profile.record_stage_clear(fixture_catalog.get_first_stage_id(), "B", 148.2, fixture_catalog)
	profile.record_stage_clear(fixture_catalog.get_first_stage_id(), "A", 132.4, fixture_catalog)

	var reloaded_profile := ProgressionProfile.load_or_create(working_save_path, fixture_catalog)
	var stage_result := reloaded_profile.get_stage_result(fixture_catalog.get_first_stage_id())

	write_text_file(corrupt_save_path, "{ not valid json")
	var recovered_profile := ProgressionProfile.load_or_create(corrupt_save_path, fixture_catalog)
	var passed: bool = initial_stage_id == fixture_catalog.get_first_stage_id() and initial_character_id == fixture_catalog.get_first_character_id() and set_stage_ok and set_character_ok and reloaded_profile.get_cleared_stage_ids().has(fixture_catalog.get_first_stage_id()) and reloaded_profile.get_unlocked_stage_ids().has("coil_depths") and reloaded_profile.get_unlocked_character_ids().has("zeph_rush") and str(stage_result.get("best_rank", "")) == "A" and is_equal_approx(float(stage_result.get("best_time_seconds", -1.0)), 132.4) and bool(reloaded_profile.get_option_value("high_contrast_hud", false)) and recovered_profile.recovered_backup_path != "" and FileAccess.file_exists(recovered_profile.recovered_backup_path)
	var payload := {
		"save_path": working_save_path,
		"selected_stage_id": reloaded_profile.get_selected_stage_id(),
		"selected_character_id": reloaded_profile.get_selected_character_id(),
		"cleared_stage_ids": reloaded_profile.get_cleared_stage_ids(),
		"unlocked_stage_ids": reloaded_profile.get_unlocked_stage_ids(),
		"unlocked_character_ids": reloaded_profile.get_unlocked_character_ids(),
		"best_rank": str(stage_result.get("best_rank", "")),
		"best_time_seconds": float(stage_result.get("best_time_seconds", -1.0)),
		"option_persisted": bool(reloaded_profile.get_option_value("high_contrast_hud", false)),
		"corrupt_recovered": recovered_profile.recovered_backup_path != "",
		"passed": passed,
		"errors": [] if passed else ["progression profile failed to persist options, unlocks, clear state, or corruption recovery"],
	}
	if not preserve_save:
		delete_path_if_present(working_save_path)
	delete_path_if_present(corrupt_save_path)
	return payload


func run_frontend_shell_suite() -> Dictionary:
	var app_scene := load("res://scenes/app_root.tscn") as PackedScene
	if app_scene == null:
		return {
			"passed": false,
			"errors": ["app root scene failed to load for frontend shell suite"],
		}

	var app_root := app_scene.instantiate()
	get_root().add_child(app_root)
	if app_root.get("catalog") == null:
		app_root.call("_ready")
	var initial_summary: Dictionary = app_root.call("get_frontend_summary")
	app_root.call("debug_start_selected_stage")
	var started_summary: Dictionary = app_root.call("get_frontend_summary")
	app_root.call("debug_complete_selected_stage", "S", 111.2)
	var results_summary: Dictionary = app_root.call("get_frontend_summary")
	app_root.call("debug_reset_profile")
	var reset_summary: Dictionary = app_root.call("get_frontend_summary")
	app_root.free()

	var best_stage_result: Dictionary = results_summary.get("best_stage_result", {})
	var passed: bool = str(initial_summary.get("mode", "")) == "menu" and bool(started_summary.get("stage_active", false)) and str(results_summary.get("mode", "")) == "results" and str(best_stage_result.get("best_rank", "")) == "S" and int((reset_summary.get("cleared_stage_ids", []) as Array).size()) == 0
	return {
		"initial_mode": str(initial_summary.get("mode", "")),
		"started_stage_active": bool(started_summary.get("stage_active", false)),
		"results_mode": str(results_summary.get("mode", "")),
		"reset_mode": str(reset_summary.get("mode", "")),
		"best_rank": str(best_stage_result.get("best_rank", "")),
		"passed": passed,
		"errors": [] if passed else ["frontend shell did not transition through menu, active stage, result, and reset flows"],
	}


func run_content_validation_suite(catalog: ContentCatalog) -> Dictionary:
	var invalid_catalog := ContentCatalog.from_dictionary({
		"build_label": "invalid-catalog",
		"characters": [
			{
				"id": "mira_coil",
				"name": "Mira Coil",
				"playstyle": "balanced_striker",
			},
		],
		"stages": [
			{
				"id": "relay_clearing",
				"name": "Relay Clearing",
				"scene": "res://scenes/stages/relay_clearing.tscn",
				"order": 1,
				"spectacle_target_seconds": 180,
				"reward_character_id": "missing_character",
			},
			{
				"id": "relay_clearing",
				"name": "Relay Clearing Again",
				"scene": "res://scenes/stages/relay_clearing.tscn",
				"order": 1,
				"spectacle_target_seconds": 180,
			},
		],
	})
	var invalid_errors := invalid_catalog.validate()
	var passed: bool = catalog.validate().is_empty() and invalid_errors.size() >= 2
	return {
		"live_catalog_stage_ids": catalog.get_stage_ids(),
		"live_catalog_character_ids": catalog.get_character_ids(),
		"invalid_error_count": invalid_errors.size(),
		"invalid_errors": invalid_errors,
		"passed": passed,
		"errors": [] if passed else ["content validation did not accept the live catalog or reject the invalid fixture"],
	}


func delete_path_if_present(path: String) -> void:
	var absolute_path := path
	if path.begins_with("user://"):
		absolute_path = ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(path) or FileAccess.file_exists(absolute_path):
		DirAccess.remove_absolute(absolute_path)


func delete_corrupt_backups(path: String) -> void:
	var absolute_path := path
	if path.begins_with("user://"):
		absolute_path = ProjectSettings.globalize_path(path)
	var base_dir := absolute_path.get_base_dir()
	var file_prefix := absolute_path.get_file()
	var directory := DirAccess.open(base_dir)
	if directory == null:
		return
	directory.list_dir_begin()
	while true:
		var entry := directory.get_next()
		if entry.is_empty():
			break
		if directory.current_is_dir():
			continue
		if entry.begins_with("%s.corrupt-" % file_prefix):
			DirAccess.remove_absolute(base_dir.path_join(entry))
	directory.list_dir_end()


func write_text_file(path: String, contents: String) -> void:
	var absolute_path := path
	if path.begins_with("user://"):
		absolute_path = ProjectSettings.globalize_path(path)
	DirAccess.make_dir_recursive_absolute(absolute_path.get_base_dir())
	var handle := FileAccess.open(path, FileAccess.WRITE)
	if handle == null:
		return
	handle.store_string(contents)
	handle.close()
