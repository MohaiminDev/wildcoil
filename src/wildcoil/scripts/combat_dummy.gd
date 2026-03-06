class_name CombatDummy
extends Node2D

const GROUND_Y := 140.0
const GRAVITY := 1600.0
const ATTACK_RANGE := 136.0
const WALK_SPEED := 78.0
const MAX_HEALTH := 88

var stage: Node
var health := MAX_HEALTH
var spawn_position := Vector2.ZERO
var velocity := Vector2.ZERO
var facing := -1.0
var hitstun_timer := 0.0
var attack_cooldown := 0.9
var attack_windup := 0.0
var attack_pending := false
var dead_timer := 0.0


func _ready() -> void:
	spawn_position = global_position
	queue_redraw()


func _physics_process(delta: float) -> void:
	if stage != null and stage.has_method("is_hitstop_active") and stage.call("is_hitstop_active"):
		queue_redraw()
		return

	hitstun_timer = maxf(hitstun_timer - delta, 0.0)
	attack_cooldown = maxf(attack_cooldown - delta, 0.0)
	dead_timer = maxf(dead_timer - delta, 0.0)
	if attack_windup > 0.0:
		attack_windup = maxf(attack_windup - delta, 0.0)
		if attack_windup <= 0.0 and attack_pending and stage != null:
			attack_pending = false
			stage.call("resolve_dummy_attack", get_attack_profile(), global_position, facing)
			attack_cooldown = 1.2

	if health > 0:
		update_behavior(delta)

	velocity.y += GRAVITY * delta
	global_position += velocity * delta
	if global_position.y > GROUND_Y:
		global_position.y = GROUND_Y
		velocity.y = 0.0
	velocity.x = move_toward(velocity.x, 0.0, 1100.0 * delta)
	queue_redraw()


func update_behavior(delta: float) -> void:
	var player := get_player()
	if player == null:
		return
	var distance := player.global_position.x - global_position.x
	if absf(distance) > 8.0:
		facing = sign(distance)

	if hitstun_timer > 0.0:
		return

	if attack_pending:
		return

	if absf(distance) > ATTACK_RANGE and absf(distance) < 360.0:
		velocity.x = move_toward(velocity.x, sign(distance) * WALK_SPEED, 580.0 * delta)
	elif attack_cooldown <= 0.0 and absf(distance) <= ATTACK_RANGE:
		attack_pending = true
		attack_windup = 0.36


func take_hit(profile: Dictionary, attacker_facing: float, attacker_position: Vector2) -> bool:
	if health <= 0:
		return false
	var distance := global_position.x - attacker_position.x
	var is_radial := bool(profile.get("is_radial", false))
	if not is_radial:
		if attacker_facing > 0.0 and distance < -18.0:
			return false
		if attacker_facing < 0.0 and distance > 18.0:
			return false
	if absf(distance) > float(profile.get("reach", 0.0)):
		return false

	health = maxi(health - int(profile.get("damage", 0)), 0)
	hitstun_timer = float(profile.get("stun", 0.16))
	attack_pending = false
	attack_windup = 0.0
	attack_cooldown = 0.48
	velocity.x = float(profile.get("knockback_x", 0.0)) * attacker_facing
	velocity.y = float(profile.get("knockback_y", 0.0))
	if health <= 0:
		dead_timer = 0.8
	return true


func get_attack_profile() -> Dictionary:
	return {
		"id": "dummy_slash",
		"damage": 14,
		"reach": 90.0,
		"knockback_x": 220.0,
		"knockback_y": -210.0,
		"stun": 0.24,
		"hitstop": 0.05,
	}


func get_player() -> Node2D:
	if stage != null and stage.has_method("get_player"):
		return stage.call("get_player")
	return null


func reset_to_spawn(new_position: Vector2) -> void:
	spawn_position = new_position
	global_position = new_position
	velocity = Vector2.ZERO
	health = MAX_HEALTH
	facing = -1.0
	hitstun_timer = 0.0
	attack_cooldown = 0.9
	attack_windup = 0.0
	attack_pending = false
	dead_timer = 0.0


func get_state_name() -> String:
	if health <= 0:
		return "down"
	if hitstun_timer > 0.0:
		return "stunned"
	if attack_pending:
		return "telegraph"
	return "idle"


func _draw() -> void:
	var body_color := Color("f06b6b")
	if health <= 0:
		body_color = Color("5f5f6c")
	elif hitstun_timer > 0.0:
		body_color = Color("ffb17c")
	elif attack_pending:
		body_color = Color("ffd86c")

	draw_rect(Rect2(Vector2(-20.0, -72.0), Vector2(40.0, 72.0)), body_color)
	draw_rect(Rect2(Vector2(-8.0, -92.0), Vector2(16.0, 20.0)), Color("fee8d7"))
	draw_line(Vector2(-10.0 * facing, -26.0), Vector2(26.0 * facing, -8.0), Color("fff4cb"), 5.0)
	if attack_pending:
		draw_rect(Rect2(Vector2(18.0 * facing - 60.0, -68.0), Vector2(70.0, 34.0)), Color(1.0, 0.9, 0.5, 0.25))
