class_name PlayerMotorModel
extends RefCounted

const MOVE_SPEED := 340.0
const ACCELERATION := 2600.0
const FRICTION := 3000.0
const GRAVITY := 1680.0
const JUMP_VELOCITY := -690.0
const DODGE_SPEED := 680.0
const DODGE_TIME := 0.18
const DODGE_COOLDOWN := 0.42


func make_default_state() -> Dictionary:
	return {
		"velocity": Vector2.ZERO,
		"facing": 1.0,
		"on_floor": true,
		"dodge_timer": 0.0,
		"dodge_cooldown": 0.0,
	}


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
		velocity.y += GRAVITY * delta

	if dodge_pressed and on_floor and dodge_timer <= 0.0 and dodge_cooldown <= 0.0:
		if absf(move_input) > 0.12:
			next_state["facing"] = sign(move_input)
		next_state["dodge_timer"] = DODGE_TIME
		next_state["dodge_cooldown"] = DODGE_COOLDOWN
		velocity.x = float(next_state["facing"]) * DODGE_SPEED
		velocity.y = minf(velocity.y, 0.0)
		next_state["velocity"] = velocity
		return next_state

	if float(next_state["dodge_timer"]) > 0.0:
		velocity.x = float(next_state["facing"]) * DODGE_SPEED
		next_state["velocity"] = velocity
		return next_state

	if absf(move_input) > 0.12:
		next_state["facing"] = sign(move_input)
		velocity.x = move_toward(velocity.x, move_input * MOVE_SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)

	if jump_pressed and on_floor:
		velocity.y = JUMP_VELOCITY
		next_state["on_floor"] = false

	next_state["velocity"] = velocity
	return next_state
