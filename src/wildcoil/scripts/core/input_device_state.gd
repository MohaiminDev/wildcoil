class_name InputDeviceState
extends RefCounted

const SCHEME_KEYBOARD := "keyboard"
const SCHEME_CONTROLLER := "controller"

var active_scheme := SCHEME_KEYBOARD
var active_device_id := -1
var connected_gamepads: Array[int] = []


func refresh_connected_gamepads() -> void:
	connected_gamepads.clear()
	for device in Input.get_connected_joypads():
		connected_gamepads.append(int(device))


func handle_event(event: InputEvent) -> void:
	if event is InputEventJoypadButton and event.pressed:
		active_scheme = SCHEME_CONTROLLER
		active_device_id = event.device
		if not connected_gamepads.has(event.device):
			connected_gamepads.append(event.device)
	elif event is InputEventJoypadMotion and absf(event.axis_value) >= 0.25:
		active_scheme = SCHEME_CONTROLLER
		active_device_id = event.device
		if not connected_gamepads.has(event.device):
			connected_gamepads.append(event.device)
	elif event is InputEventKey and event.pressed and not event.echo:
		active_scheme = SCHEME_KEYBOARD
		active_device_id = -1


func handle_connection_change(device: int, connected: bool) -> void:
	if connected:
		if not connected_gamepads.has(device):
			connected_gamepads.append(device)
		active_scheme = SCHEME_CONTROLLER
		active_device_id = device
	else:
		connected_gamepads.erase(device)
		if active_scheme == SCHEME_CONTROLLER and active_device_id == device:
			active_scheme = SCHEME_KEYBOARD
			active_device_id = -1


func describe_status() -> String:
	var controller_suffix := "none"
	if not connected_gamepads.is_empty():
		var labels: Array[String] = []
		for device in connected_gamepads:
			labels.append(str(device))
		controller_suffix = ", ".join(labels)
	return "Input: %s  Connected pads: %d [%s]" % [active_scheme, connected_gamepads.size(), controller_suffix]
