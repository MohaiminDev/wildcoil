class_name PlayerController
extends CharacterBody2D

const InputActions = preload("res://scripts/core/input_actions.gd")
const CharacterProfileLibrary = preload("res://scripts/core/character_profile_library.gd")
const PlayerCombatModel = preload("res://scripts/core/player_combat_model.gd")
const PlayerMotorModel = preload("res://scripts/core/player_motor_model.gd")

const DEFAULT_STAGE_BOUNDS := Vector2(-760.0, 760.0)
const RESPAWN_FLOOR_Y := 140.0
const CAMERA_LIMIT_TOP := -320
const CAMERA_LIMIT_BOTTOM := 220

var stage: Node
var movement_model := PlayerMotorModel.new()
var combat_model := PlayerCombatModel.new()
var movement_state: Dictionary = {}
var combat_state: Dictionary = {}
var character_definition: Dictionary = {}

@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	InputActions.ensure_default_actions()
	apply_character_definition(character_definition)
	movement_state = movement_model.make_default_state()
	combat_state = combat_model.make_default_state()
	queue_redraw()


func _physics_process(delta: float) -> void:
	if stage != null and stage.has_method("is_hitstop_active") and stage.call("is_hitstop_active"):
		queue_redraw()
		return

	movement_state["on_floor"] = is_on_floor()
	movement_state["velocity"] = velocity

	combat_state = combat_model.advance(combat_state, {
		"light_pressed": Input.is_action_just_pressed(InputActions.LIGHT_ATTACK),
		"heavy_pressed": Input.is_action_just_pressed(InputActions.HEAVY_ATTACK),
		"launcher_pressed": Input.is_action_just_pressed(InputActions.LAUNCH_ATTACK),
		"special_pressed": Input.is_action_just_pressed(InputActions.SPECIAL_ATTACK),
		"restart_checkpoint": Input.is_action_just_pressed(InputActions.RESTART_CHECKPOINT),
	}, delta)
	if bool(combat_state.get("requested_checkpoint_reset", false)) and stage != null:
		stage.call("reset_to_checkpoint")
		return

	var movement_locked := combat_model.is_movement_locked(combat_state)
	var input_snapshot := {
		"move": 0.0 if movement_locked else Input.get_axis(InputActions.MOVE_LEFT, InputActions.MOVE_RIGHT),
		"jump_pressed": false if movement_locked else Input.is_action_just_pressed(InputActions.JUMP),
		"dodge_pressed": false if movement_locked else Input.is_action_just_pressed(InputActions.DODGE),
	}
	movement_state = movement_model.advance(movement_state, input_snapshot, delta)
	velocity = movement_state["velocity"]
	move_and_slide()
	movement_state["velocity"] = velocity
	movement_state["on_floor"] = is_on_floor()

	var attack_event: Dictionary = combat_state.get("attack_event", {})
	if not attack_event.is_empty() and stage != null:
		stage.call("resolve_player_attack", attack_event, global_position, get_facing())
		combat_state["attack_event"] = {}

	var stage_bounds := get_stage_bounds()
	global_position.x = clampf(global_position.x, stage_bounds.x, stage_bounds.y)
	update_camera_bounds(stage_bounds)
	if global_position.y > 520.0:
		reset_to_checkpoint(Vector2(global_position.x, RESPAWN_FLOOR_Y))

	queue_redraw()


func get_debug_status() -> String:
	var movement_name := "grounded"
	if float(movement_state.get("dodge_timer", 0.0)) > 0.0:
		movement_name = "dodging"
	elif not bool(movement_state.get("on_floor", true)):
		movement_name = "airborne"
	return "%s  HP: %d  Combat: %s  Move: %s  Pos: (%.0f, %.0f)  Vel: (%.0f, %.0f)" % [
		str(character_definition.get("name", "Operator")),
		get_health(),
		combat_model.get_state_name(combat_state),
		movement_name,
		global_position.x,
		global_position.y,
		velocity.x,
		velocity.y,
	]


func get_health() -> int:
	return int(combat_state.get("health", combat_model.get_max_health()))


func get_facing() -> float:
	return float(movement_state.get("facing", 1.0))


func can_take_damage() -> bool:
	return float(combat_state.get("invulnerable_timer", 0.0)) <= 0.0 and float(movement_state.get("dodge_timer", 0.0)) <= 0.0


func apply_enemy_attack(profile: Dictionary, attacker_facing: float, attacker_position: Vector2) -> bool:
	if not can_take_damage():
		return false

	var distance := global_position.x - attacker_position.x
	if attacker_facing > 0.0 and distance < -18.0:
		return false
	if attacker_facing < 0.0 and distance > 18.0:
		return false
	if absf(distance) > float(profile.get("reach", 0.0)):
		return false

	combat_state = combat_model.apply_damage(combat_state, int(profile.get("damage", 0)), float(profile.get("stun", 0.28)))
	if not bool(combat_state.get("took_damage", false)):
		return false

	velocity.x = float(profile.get("knockback_x", 0.0)) * attacker_facing
	velocity.y = float(profile.get("knockback_y", -180.0))
	movement_state["velocity"] = velocity
	return true


func reset_to_checkpoint(checkpoint_position: Vector2) -> void:
	global_position = checkpoint_position
	velocity = Vector2.ZERO
	movement_state = movement_model.make_default_state()
	combat_state = combat_model.reset_for_checkpoint(combat_state)


func apply_character_definition(new_character_definition: Dictionary) -> void:
	character_definition = CharacterProfileLibrary.merge_character_definition(new_character_definition)
	movement_model.set_tuning(character_definition.get("motor", {}))
	combat_model.set_tuning(character_definition.get("combat", {}))
	movement_state = movement_model.make_default_state()
	combat_state = combat_model.make_default_state()
	velocity = Vector2.ZERO
	queue_redraw()


func get_loadout_snapshot() -> Dictionary:
	var motor_tuning := movement_model.get_tuning_snapshot()
	var combat_tuning := combat_model.get_tuning_snapshot()
	var light_state := combat_model.start_light(combat_model.make_default_state(), 0)
	var heavy_state := combat_model.start_attack(combat_model.make_default_state(), combat_model.get_heavy_profile(), "heavy", -1)
	var special_state := combat_model.start_attack(combat_model.make_default_state(), combat_model.get_special_profile(), "special", -1)
	return {
		"id": str(character_definition.get("id", "")),
		"name": str(character_definition.get("name", "Operator")),
		"playstyle": str(character_definition.get("playstyle", "unknown")),
		"move_speed": float(motor_tuning.get("move_speed", 0.0)),
		"jump_velocity": float(motor_tuning.get("jump_velocity", 0.0)),
		"dodge_speed": float(motor_tuning.get("dodge_speed", 0.0)),
		"dodge_time": float(motor_tuning.get("dodge_time", 0.0)),
		"max_health": combat_model.get_max_health(),
		"special_cooldown": float(combat_tuning.get("special_cooldown", 0.0)),
		"light_damage": int((light_state.get("attack_profile", {}) as Dictionary).get("damage", 0)),
		"heavy_damage": int((heavy_state.get("attack_profile", {}) as Dictionary).get("damage", 0)),
		"special_damage": int((special_state.get("attack_profile", {}) as Dictionary).get("damage", 0)),
	}


func get_stage_bounds() -> Vector2:
	if stage != null and stage.has_method("get_stage_bounds"):
		return stage.call("get_stage_bounds")
	return DEFAULT_STAGE_BOUNDS


func update_camera_bounds(stage_bounds: Vector2) -> void:
	if camera == null:
		return
	camera.limit_left = int(stage_bounds.x)
	camera.limit_right = int(stage_bounds.y)
	camera.limit_top = CAMERA_LIMIT_TOP
	camera.limit_bottom = CAMERA_LIMIT_BOTTOM


func _draw() -> void:
	var palette: Dictionary = character_definition.get("palette", {})
	var body_color := Color(str(palette.get("body", "2fe4b6")))
	if float(combat_state.get("hitstun_timer", 0.0)) > 0.0:
		body_color = Color(str(palette.get("hurt", "ff8d73")))
	elif float(movement_state.get("dodge_timer", 0.0)) > 0.0:
		body_color = Color(str(palette.get("dodge", "8dc8ff")))
	elif not bool(movement_state.get("on_floor", true)):
		body_color = Color(str(palette.get("air", "ffc65c")))
	elif combat_model.is_attack_active(combat_state):
		body_color = Color(str(palette.get("attack", "ffe18c")))

	var facing := get_facing()
	var body_size: Vector2 = character_definition.get("body_size", Vector2(34.0, 78.0))
	draw_rect(Rect2(Vector2(-body_size.x * 0.5, -body_size.y), body_size), body_color)
	draw_rect(Rect2(Vector2(-7.0, -body_size.y - 20.0), Vector2(14.0, 18.0)), Color(str(palette.get("head", "f5f7fb"))))
	draw_line(Vector2(-10.0 * facing, -30.0), Vector2(22.0 * facing, -10.0), Color("ffe6a6"), 5.0)
	if float(movement_state.get("dodge_timer", 0.0)) > 0.0:
		draw_rect(Rect2(Vector2(-body_size.x, -body_size.y - 4.0), Vector2(body_size.x * 2.0, body_size.y + 4.0)), Color(0.55, 0.82, 1.0, 0.2))
	if combat_model.is_attack_active(combat_state):
		var attack_profile: Dictionary = combat_state.get("attack_profile", {})
		var reach := float(attack_profile.get("reach", 72.0))
		var left := body_size.x * 0.5 + 2.0 if facing > 0.0 else body_size.x * 0.5 + 2.0 - reach
		draw_rect(Rect2(Vector2(left, -body_size.y + 4.0), Vector2(reach, 42.0)), Color(1.0, 0.88, 0.60, 0.22))
