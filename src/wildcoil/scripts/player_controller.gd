class_name PlayerController
extends CharacterBody2D

const InputActions = preload("res://scripts/core/input_actions.gd")
const PlayerMotorModel = preload("res://scripts/core/player_motor_model.gd")

const STAGE_MIN_X := -760.0
const STAGE_MAX_X := 760.0
const RESPAWN_FLOOR_Y := 140.0

var movement_model := PlayerMotorModel.new()
var movement_state: Dictionary = {}


func _ready() -> void:
	InputActions.ensure_default_actions()
	movement_state = movement_model.make_default_state()
	queue_redraw()


func _physics_process(delta: float) -> void:
	movement_state["on_floor"] = is_on_floor()
	movement_state["velocity"] = velocity

	var input_snapshot := {
		"move": Input.get_axis(InputActions.MOVE_LEFT, InputActions.MOVE_RIGHT),
		"jump_pressed": Input.is_action_just_pressed(InputActions.JUMP),
		"dodge_pressed": Input.is_action_just_pressed(InputActions.DODGE),
	}
	movement_state = movement_model.advance(movement_state, input_snapshot, delta)
	velocity = movement_state["velocity"]
	move_and_slide()
	velocity = get_real_velocity()
	movement_state["velocity"] = velocity
	movement_state["on_floor"] = is_on_floor()

	global_position.x = clampf(global_position.x, STAGE_MIN_X, STAGE_MAX_X)
	if global_position.y > 520.0:
		global_position.y = RESPAWN_FLOOR_Y
		velocity = Vector2.ZERO
		movement_state = movement_model.make_default_state()

	queue_redraw()


func get_debug_status() -> String:
	var state_name := "grounded"
	if float(movement_state.get("dodge_timer", 0.0)) > 0.0:
		state_name = "dodging"
	elif not bool(movement_state.get("on_floor", true)):
		state_name = "airborne"
	return "Player state: %s  Pos: (%.0f, %.0f)  Vel: (%.0f, %.0f)" % [
		state_name,
		global_position.x,
		global_position.y,
		velocity.x,
		velocity.y,
	]


func _draw() -> void:
	var body_color := Color("2fe4b6")
	if float(movement_state.get("dodge_timer", 0.0)) > 0.0:
		body_color = Color("8dc8ff")
	elif not bool(movement_state.get("on_floor", true)):
		body_color = Color("ffc65c")

	var facing := float(movement_state.get("facing", 1.0))
	draw_rect(Rect2(Vector2(-17.0, -78.0), Vector2(34.0, 78.0)), body_color)
	draw_rect(Rect2(Vector2(-7.0, -98.0), Vector2(14.0, 18.0)), Color("f5f7fb"))
	draw_line(Vector2(-10.0 * facing, -30.0), Vector2(22.0 * facing, -10.0), Color("ffe6a6"), 5.0)
	if float(movement_state.get("dodge_timer", 0.0)) > 0.0:
		draw_rect(Rect2(Vector2(-30.0, -82.0), Vector2(60.0, 82.0)), Color(0.55, 0.82, 1.0, 0.2))
