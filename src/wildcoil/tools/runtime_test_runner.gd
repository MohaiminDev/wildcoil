extends SceneTree

const ContentCatalog = preload("res://scripts/core/content_catalog.gd")
const EnemyProfileLibrary = preload("res://scripts/core/enemy_profile_library.gd")
const InputActions = preload("res://scripts/core/input_actions.gd")
const InputDeviceState = preload("res://scripts/core/input_device_state.gd")
const PlayerCombatModel = preload("res://scripts/core/player_combat_model.gd")
const PlayerMotorModel = preload("res://scripts/core/player_motor_model.gd")


func _initialize() -> void:
	var suite := "smoke"
	var args := OS.get_cmdline_user_args()
	for index in range(args.size()):
		if args[index] == "--suite" and index + 1 < args.size():
			suite = args[index + 1]

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
	player.global_position.x = 740.0
	stage_instance.call("advance_stage_flow", 0.1)
	var final_summary: Dictionary = stage_instance.call("get_stage_summary")

	var passed: bool = str(initial_summary.get("phase", "")) == "approach" and float(combat_summary.get("first_combat_seconds", -1.0)) >= 0.0 and float(spectacle_summary.get("spectacle_seconds", -1.0)) >= 0.0 and str(spectacle_summary.get("audio_state", "")) == "spectacle" and bool(final_summary.get("stage_complete", false)) and str(final_summary.get("rank", "--")) != "--"
	var payload := {
		"initial_phase": str(initial_summary.get("phase", "")),
		"first_combat_seconds": float(combat_summary.get("first_combat_seconds", -1.0)),
		"spectacle_seconds": float(spectacle_summary.get("spectacle_seconds", -1.0)),
		"final_phase": str(final_summary.get("phase", "")),
		"stage_complete": bool(final_summary.get("stage_complete", false)),
		"rank": str(final_summary.get("rank", "--")),
		"passed": passed,
		"errors": [] if passed else ["first playable stage flow did not reach encounter, spectacle, and clear states"],
	}
	stage_instance.free()
	return payload
