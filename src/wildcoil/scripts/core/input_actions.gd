class_name InputActions
extends RefCounted

const MOVE_LEFT: StringName = &"move_left"
const MOVE_RIGHT: StringName = &"move_right"
const JUMP: StringName = &"jump"
const DODGE: StringName = &"dodge"
const LIGHT_ATTACK: StringName = &"light_attack"
const HEAVY_ATTACK: StringName = &"heavy_attack"
const LAUNCH_ATTACK: StringName = &"launch_attack"
const SPECIAL_ATTACK: StringName = &"special_attack"
const RESTART_CHECKPOINT: StringName = &"restart_checkpoint"
const PAUSE: StringName = &"pause"


static func ensure_default_actions() -> void:
	ensure_action(MOVE_LEFT)
	ensure_action(MOVE_RIGHT)
	ensure_action(JUMP)
	ensure_action(DODGE)
	ensure_action(LIGHT_ATTACK)
	ensure_action(HEAVY_ATTACK)
	ensure_action(LAUNCH_ATTACK)
	ensure_action(SPECIAL_ATTACK)
	ensure_action(RESTART_CHECKPOINT)
	ensure_action(PAUSE)

	add_key(MOVE_LEFT, KEY_A)
	add_key(MOVE_LEFT, KEY_LEFT)
	add_key(MOVE_RIGHT, KEY_D)
	add_key(MOVE_RIGHT, KEY_RIGHT)
	add_key(JUMP, KEY_SPACE)
	add_key(JUMP, KEY_W)
	add_key(DODGE, KEY_SHIFT)
	add_key(DODGE, KEY_C)
	add_key(LIGHT_ATTACK, KEY_J)
	add_key(LIGHT_ATTACK, KEY_Z)
	add_key(HEAVY_ATTACK, KEY_K)
	add_key(HEAVY_ATTACK, KEY_X)
	add_key(LAUNCH_ATTACK, KEY_L)
	add_key(LAUNCH_ATTACK, KEY_V)
	add_key(SPECIAL_ATTACK, KEY_SEMICOLON)
	add_key(SPECIAL_ATTACK, KEY_B)
	add_key(RESTART_CHECKPOINT, KEY_R)
	add_key(PAUSE, KEY_ESCAPE)

	add_joy_motion(MOVE_LEFT, JOY_AXIS_LEFT_X, -1.0)
	add_joy_motion(MOVE_RIGHT, JOY_AXIS_LEFT_X, 1.0)
	add_joy_button(JUMP, JOY_BUTTON_A)
	add_joy_button(DODGE, JOY_BUTTON_B)
	add_joy_button(LIGHT_ATTACK, JOY_BUTTON_X)
	add_joy_button(HEAVY_ATTACK, JOY_BUTTON_Y)
	add_joy_button(LAUNCH_ATTACK, JOY_BUTTON_RIGHT_SHOULDER)
	add_joy_button(SPECIAL_ATTACK, JOY_BUTTON_LEFT_SHOULDER)
	add_joy_button(PAUSE, JOY_BUTTON_START)


static func ensure_action(action_name: StringName) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)


static func add_key(action_name: StringName, keycode: int) -> void:
	for event in InputMap.action_get_events(action_name):
		if event is InputEventKey and event.physical_keycode == keycode:
			return
	var input_event := InputEventKey.new()
	input_event.physical_keycode = keycode
	InputMap.action_add_event(action_name, input_event)


static func add_joy_button(action_name: StringName, button_index: JoyButton) -> void:
	for event in InputMap.action_get_events(action_name):
		if event is InputEventJoypadButton and event.button_index == button_index:
			return
	var input_event := InputEventJoypadButton.new()
	input_event.button_index = button_index
	InputMap.action_add_event(action_name, input_event)


static func add_joy_motion(action_name: StringName, axis: JoyAxis, axis_value: float) -> void:
	for event in InputMap.action_get_events(action_name):
		if event is InputEventJoypadMotion and event.axis == axis and is_equal_approx(event.axis_value, axis_value):
			return
	var input_event := InputEventJoypadMotion.new()
	input_event.axis = axis
	input_event.axis_value = axis_value
	InputMap.action_add_event(action_name, input_event)
