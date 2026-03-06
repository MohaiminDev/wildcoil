class_name EnemyActor
extends Node2D

const EnemyProfileLibrary = preload("res://scripts/core/enemy_profile_library.gd")

const GROUND_Y := 140.0
const GRAVITY := 1600.0
const DEFAULT_STAGE_BOUNDS := Vector2(-760.0, 760.0)

@export var enemy_id := "needle_hound"

var stage: Node
var profile: Dictionary = {}
var health := -1
var spawn_position := Vector2.ZERO
var velocity := Vector2.ZERO
var facing := -1.0
var hitstun_timer := 0.0
var attack_cooldown := 0.7
var attack_windup := 0.0
var attack_pending := false
var dead_timer := 0.0


func _ready() -> void:
	ensure_profile_loaded()
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
			var archetype := str(profile.get("archetype", ""))
			if archetype == "ranged" or archetype == "artillery":
				stage.call("spawn_enemy_projectile", self, get_attack_profile())
				attack_cooldown = 1.8 if archetype == "artillery" else 1.6
			else:
				stage.call("resolve_enemy_attack", get_attack_profile(), global_position, facing)
				if archetype == "skirmisher":
					attack_cooldown = 0.82
				else:
					attack_cooldown = 1.2 if not bool(profile.get("is_elite", false)) else 1.6

	if health > 0:
		update_behavior(delta)

	velocity.y += GRAVITY * delta
	global_position += velocity * delta
	if global_position.y > GROUND_Y:
		global_position.y = GROUND_Y
		velocity.y = 0.0
	var stage_bounds := get_stage_bounds()
	global_position.x = clampf(global_position.x, stage_bounds.x, stage_bounds.y)
	velocity.x = move_toward(velocity.x, 0.0, 1200.0 * delta)
	queue_redraw()


func update_behavior(delta: float) -> void:
	var player := get_player()
	if player == null:
		return
	var distance := player.global_position.x - global_position.x
	if absf(distance) > 8.0:
		facing = sign(distance)

	if hitstun_timer > 0.0 or attack_pending:
		return

	var archetype := str(profile.get("archetype", ""))
	var preferred_range := float(profile.get("preferred_range", profile.get("attack_range", 90.0)))
	var walk_speed := float(profile.get("walk_speed", 72.0))
	var engage_range := float(profile.get("engage_range", 240.0))
	if archetype == "ranged" or archetype == "artillery":
		if absf(distance) < preferred_range - 30.0:
			velocity.x = move_toward(velocity.x, -sign(distance) * walk_speed, 600.0 * delta)
		elif absf(distance) > preferred_range + 30.0 and absf(distance) < engage_range + 120.0:
			velocity.x = move_toward(velocity.x, sign(distance) * walk_speed, 600.0 * delta)
	elif archetype == "skirmisher":
		if absf(distance) < float(profile.get("attack_range", 90.0)) * 0.55:
			velocity.x = move_toward(velocity.x, -sign(distance) * walk_speed * 0.82, 900.0 * delta)
		elif absf(distance) <= engage_range + 80.0:
			velocity.x = move_toward(velocity.x, sign(distance) * walk_speed * 1.08, 980.0 * delta)
	elif absf(distance) <= engage_range:
		velocity.x = move_toward(velocity.x, sign(distance) * walk_speed, 600.0 * delta)

	if attack_cooldown <= 0.0 and absf(distance) <= float(profile.get("attack_range", 90.0)):
		attack_pending = true
		attack_windup = float(profile.get("attack_windup", 0.3))


func take_hit(attack_profile: Dictionary, attacker_facing: float, attacker_position: Vector2) -> bool:
	ensure_profile_loaded()
	if health <= 0:
		return false
	var distance := global_position.x - attacker_position.x
	var is_radial := bool(attack_profile.get("is_radial", false))
	if not is_radial:
		if attacker_facing > 0.0 and distance < -18.0:
			return false
		if attacker_facing < 0.0 and distance > 18.0:
			return false
	if absf(distance) > float(attack_profile.get("reach", 0.0)):
		return false

	health = maxi(health - int(attack_profile.get("damage", 0)), 0)
	hitstun_timer = float(attack_profile.get("stun", 0.18))
	attack_pending = false
	attack_windup = 0.0
	attack_cooldown = 0.45
	velocity.x = float(attack_profile.get("knockback_x", 0.0)) * attacker_facing
	velocity.y = float(attack_profile.get("knockback_y", 0.0))
	if health <= 0:
		dead_timer = 0.8
	return true


func get_attack_profile() -> Dictionary:
	ensure_profile_loaded()
	return {
		"id": "%s_attack" % enemy_id,
		"damage": int(profile.get("damage", 0)),
		"reach": float(profile.get("attack_range", 0.0)),
		"knockback_x": float(profile.get("knockback_x", 0.0)),
		"knockback_y": float(profile.get("knockback_y", 0.0)),
		"stun": float(profile.get("stun", 0.18)),
		"hitstop": float(profile.get("hitstop", 0.04)),
		"projectile_speed": float(profile.get("projectile_speed", 0.0)),
		"projectile_range": float(profile.get("projectile_range", 0.0)),
		"projectile_radius": float(profile.get("projectile_radius", 20.0)),
	}


func get_player() -> Node2D:
	if stage != null and stage.has_method("get_player"):
		return stage.call("get_player")
	return null


func get_stage_bounds() -> Vector2:
	if stage != null and stage.has_method("get_stage_bounds"):
		return stage.call("get_stage_bounds")
	return DEFAULT_STAGE_BOUNDS


func reset_to_spawn(new_position: Vector2) -> void:
	ensure_profile_loaded()
	spawn_position = new_position
	global_position = new_position
	velocity = Vector2.ZERO
	health = int(profile.get("health", 1))
	facing = -1.0
	hitstun_timer = 0.0
	attack_cooldown = 0.7
	attack_windup = 0.0
	attack_pending = false
	dead_timer = 0.0


func get_state_name() -> String:
	ensure_profile_loaded()
	if health <= 0:
		return "down"
	if hitstun_timer > 0.0:
		return "stunned"
	if attack_pending:
		return "telegraph"
	return "idle"


func is_elite() -> bool:
	ensure_profile_loaded()
	return bool(profile.get("is_elite", false))


func ensure_profile_loaded() -> void:
	if profile.is_empty():
		profile = EnemyProfileLibrary.get_profile(enemy_id)
	if health < 0 and not profile.is_empty():
		health = int(profile.get("health", 1))


func _draw() -> void:
	var body_color := Color(str(profile.get("color", "f06b6b")))
	if health <= 0:
		body_color = Color("5f5f6c")
	elif hitstun_timer > 0.0:
		body_color = Color("ffb17c")
	elif attack_pending:
		body_color = Color("ffd86c")

	var size := Vector2(42.0, 76.0)
	if is_elite():
		size = Vector2(58.0, 98.0)
	draw_rect(Rect2(Vector2(-size.x * 0.5, -size.y), size), body_color)
	draw_rect(Rect2(Vector2(-10.0, -size.y - 18.0), Vector2(20.0, 18.0)), Color(str(profile.get("accent", "fee8d7"))))
	draw_line(Vector2(-12.0 * facing, -size.y * 0.46), Vector2(26.0 * facing, -size.y * 0.28), Color("fff4cb"), 5.0)
	if attack_pending:
		draw_rect(Rect2(Vector2(18.0 * facing - 60.0, -size.y + 8.0), Vector2(76.0, 34.0)), Color(1.0, 0.9, 0.5, 0.25))
