class_name InputActions
extends RefCounted

const MOVE_LEFT: StringName = &"move_left"
const MOVE_RIGHT: StringName = &"move_right"
const JUMP: StringName = &"jump"
const DODGE: StringName = &"dodge"
const PAUSE: StringName = &"pause"


static func ensure_default_actions() -> void:
	ensure_action(MOVE_LEFT)
	ensure_action(MOVE_RIGHT)
	ensure_action(JUMP)
	ensure_action(DODGE)
	ensure_action(PAUSE)

	add_key(MOVE_LEFT, KEY_A)
	add_key(MOVE_LEFT, KEY_LEFT)
	add_key(MOVE_RIGHT, KEY_D)
	add_key(MOVE_RIGHT, KEY_RIGHT)
	add_key(JUMP, KEY_SPACE)
	add_key(JUMP, KEY_W)
	add_key(DODGE, KEY_SHIFT)
	add_key(DODGE, KEY_C)
	add_key(PAUSE, KEY_ESCAPE)

	add_joy_motion(MOVE_LEFT, JOY_AXIS_LEFT_X, -1.0)
	add_joy_motion(MOVE_RIGHT, JOY_AXIS_LEFT_X, 1.0)
	add_joy_button(JUMP, JOY_BUTTON_A)
	add_joy_button(DODGE, JOY_BUTTON_B)
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
