class_name PlayerMotorModel
extends RefCounted

const DEFAULT_TUNING := {
	"move_speed": 340.0,
	"acceleration": 2600.0,
	"friction": 3000.0,
	"gravity": 1680.0,
	"jump_velocity": -690.0,
	"dodge_speed": 680.0,
	"dodge_time": 0.18,
	"dodge_cooldown": 0.42,
}

var tuning := DEFAULT_TUNING.duplicate(true)


func make_default_state() -> Dictionary:
	return {
		"velocity": Vector2.ZERO,
		"facing": 1.0,
		"on_floor": true,
		"dodge_timer": 0.0,
		"dodge_cooldown": 0.0,
	}


func set_tuning(new_tuning: Dictionary) -> void:
	tuning = DEFAULT_TUNING.duplicate(true)
	for key in new_tuning.keys():
		if tuning.has(key):
			tuning[key] = new_tuning[key]


func get_tuning_snapshot() -> Dictionary:
	return tuning.duplicate(true)


func advance(state: Dictionary, input_state: Dictionary, delta: float) -> Dictionary:
	var next_state := state.duplicate(true)
	var velocity: Vector2 = next_state.get("velocity", Vector2.ZERO)
	var on_floor := bool(next_state.get("on_floor", false))
	var dodge_timer := maxf(float(next_state.get("dodge_timer", 0.0)) - delta, 0.0)
	var dodge_cooldown := maxf(float(next_state.get("dodge_cooldown", 0.0)) - delta, 0.0)
	var move_input := clampf(float(input_state.get("move", 0.0)), -1.0, 1.0)
	var jump_pressed := bool(input_state.get("jump_pressed", false))
	var dodge_pressed := bool(input_state.get("dodge_pressed", false))

	next_state["dodge_timer"] = dodge_timer
	next_state["dodge_cooldown"] = dodge_cooldown

	if on_floor and velocity.y > 0.0:
		velocity.y = 0.0
	elif not on_floor:
		velocity.y += float(tuning["gravity"]) * delta

	if dodge_pressed and on_floor and dodge_timer <= 0.0 and dodge_cooldown <= 0.0:
		if absf(move_input) > 0.12:
			next_state["facing"] = sign(move_input)
		next_state["dodge_timer"] = float(tuning["dodge_time"])
		next_state["dodge_cooldown"] = float(tuning["dodge_cooldown"])
		velocity.x = float(next_state["facing"]) * float(tuning["dodge_speed"])
		velocity.y = minf(velocity.y, 0.0)
		next_state["velocity"] = velocity
		return next_state

	if float(next_state["dodge_timer"]) > 0.0:
		velocity.x = float(next_state["facing"]) * float(tuning["dodge_speed"])
		next_state["velocity"] = velocity
		return next_state

	if absf(move_input) > 0.12:
		next_state["facing"] = sign(move_input)
		velocity.x = move_toward(velocity.x, move_input * float(tuning["move_speed"]), float(tuning["acceleration"]) * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, float(tuning["friction"]) * delta)

	if jump_pressed and on_floor:
		velocity.y = float(tuning["jump_velocity"])
		next_state["on_floor"] = false

	next_state["velocity"] = velocity
	return next_state
