extends SceneTree

const ContentCatalog = preload("res://scripts/core/content_catalog.gd")
const InputActions = preload("res://scripts/core/input_actions.gd")
const InputDeviceState = preload("res://scripts/core/input_device_state.gd")
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
			payload["stage_root_name"] = stage_instance.name
			if stage_instance.has_method("get_player"):
				payload["player_present"] = stage_instance.call("get_player") != null
			stage_instance.free()

	if suite == "movement_model":
		payload.merge(run_movement_model_suite(), true)

	if suite == "input_device":
		payload.merge(run_input_device_suite(), true)

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
