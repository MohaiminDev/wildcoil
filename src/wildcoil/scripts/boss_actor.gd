class_name BossActor
extends Node2D

const EnemyProfileLibrary = preload("res://scripts/core/enemy_profile_library.gd")

const GROUND_Y := 140.0
const GRAVITY := 1600.0

@export var enemy_id := "storm_warden"

var stage: Node
var profile: Dictionary = {}
var health := -1
var max_health := 1
var velocity := Vector2.ZERO
var facing := -1.0
var hitstun_timer := 0.0
var attack_cooldown := 0.9
var attack_windup := 0.0
var attack_pending := ""
var dash_timer := 0.0
var dash_hit_timer := 0.0
var intro_timer := 0.0
var phase_two := false
var spawn_position := Vector2.ZERO
var attack_index := 0


func _ready() -> void:
	ensure_profile_loaded()
	spawn_position = global_position
	reset_to_spawn(spawn_position)


func _physics_process(delta: float) -> void:
	if stage != null and stage.has_method("is_hitstop_active") and stage.call("is_hitstop_active"):
		queue_redraw()
		return

	if not visible:
		return

	hitstun_timer = maxf(hitstun_timer - delta, 0.0)
	attack_cooldown = maxf(attack_cooldown - delta, 0.0)
	dash_hit_timer = maxf(dash_hit_timer - delta, 0.0)

	if intro_timer > 0.0:
		intro_timer = maxf(intro_timer - delta, 0.0)
		queue_redraw()
		return

	if attack_windup > 0.0:
		attack_windup = maxf(attack_windup - delta, 0.0)
		if attack_windup <= 0.0 and not attack_pending.is_empty():
			execute_attack(attack_pending)
			attack_pending = ""

	if dash_timer > 0.0:
		dash_timer = maxf(dash_timer - delta, 0.0)
		velocity.x = facing * float(profile.get("dash_speed", 520.0))
		if dash_hit_timer <= 0.0 and stage != null:
			var dash_hit: bool = stage.call("resolve_enemy_attack", get_attack_profile("dash"), global_position, facing)
			if dash_hit:
				dash_hit_timer = 0.18
		if dash_timer <= 0.0:
			velocity.x = 0.0

	if health > 0 and active_for_combat():
		update_phase_state()
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
	if hitstun_timer > 0.0 or dash_timer > 0.0 or not attack_pending.is_empty():
		return
	var player := get_player()
	if player == null:
		return
	var distance := player.global_position.x - global_position.x
	if absf(distance) > 6.0:
		facing = sign(distance)

	var walk_speed := float(profile.get("walk_speed", 88.0))
	if absf(distance) > 180.0:
		velocity.x = move_toward(velocity.x, sign(distance) * walk_speed, 720.0 * delta)

	if attack_cooldown <= 0.0:
		start_attack(distance)


func start_attack(distance: float) -> void:
	var pattern := get_attack_pattern()
	var next_attack := pattern[attack_index % pattern.size()]
	attack_index += 1
	if absf(distance) > 240.0 and next_attack == "slam":
		next_attack = "burst"
	attack_pending = next_attack
	attack_windup = 0.34 if next_attack == "dash" else float(profile.get("attack_windup", 0.42))


func execute_attack(attack_id: String) -> void:
	match attack_id:
		"slam":
			if stage != null:
				stage.call("resolve_enemy_attack", get_attack_profile("slam"), global_position, facing)
			attack_cooldown = 1.1
		"burst":
			if stage != null and stage.has_method("spawn_boss_projectiles"):
				stage.call("spawn_boss_projectiles", global_position, facing, phase_two)
			attack_cooldown = 1.4 if not phase_two else 1.0
		"dash":
			dash_timer = 0.34
			dash_hit_timer = 0.0
			attack_cooldown = 1.5 if not phase_two else 1.1
		_:
			attack_cooldown = 1.0


func get_attack_pattern() -> Array[String]:
	if phase_two:
		return ["burst", "dash", "slam", "burst"]
	return ["slam", "burst", "dash"]


func get_attack_profile(attack_id: String) -> Dictionary:
	match attack_id:
		"dash":
			return {
				"id": "storm_warden_dash",
				"damage": 18,
				"reach": 110.0,
				"knockback_x": 340.0,
				"knockback_y": -180.0,
				"stun": 0.24,
				"hitstop": 0.06,
			}
		"slam":
			return {
				"id": "storm_warden_slam",
				"damage": int(profile.get("damage", 20)),
				"reach": 150.0,
				"knockback_x": float(profile.get("knockback_x", 320.0)),
				"knockback_y": float(profile.get("knockback_y", -240.0)),
				"stun": float(profile.get("stun", 0.22)),
				"hitstop": float(profile.get("hitstop", 0.08)),
			}
		_:
			return {
				"id": "storm_warden_attack",
				"damage": int(profile.get("damage", 18)),
				"reach": float(profile.get("attack_range", 140.0)),
				"knockback_x": float(profile.get("knockback_x", 260.0)),
				"knockback_y": float(profile.get("knockback_y", -200.0)),
				"stun": float(profile.get("stun", 0.18)),
				"hitstop": float(profile.get("hitstop", 0.06)),
			}


func take_hit(attack_profile: Dictionary, attacker_facing: float, attacker_position: Vector2) -> bool:
	if not visible or intro_timer > 0.0 or health <= 0:
		return false
	var distance := global_position.x - attacker_position.x
	var is_radial := bool(attack_profile.get("is_radial", false))
	if not is_radial:
		if attacker_facing > 0.0 and distance < -22.0:
			return false
		if attacker_facing < 0.0 and distance > 22.0:
			return false
	if absf(distance) > float(attack_profile.get("reach", 0.0)):
		return false

	health = maxi(health - int(attack_profile.get("damage", 0)), 0)
	hitstun_timer = float(attack_profile.get("stun", 0.18))
	attack_pending = ""
	attack_windup = 0.0
	dash_timer = 0.0
	velocity.x = float(attack_profile.get("knockback_x", 0.0)) * attacker_facing * 0.4
	velocity.y = float(attack_profile.get("knockback_y", 0.0)) * 0.35
	update_phase_state()
	return true


func begin_intro(position: Vector2, duration: float) -> void:
	ensure_profile_loaded()
	global_position = position
	visible = true
	intro_timer = duration
	attack_pending = ""
	attack_windup = 0.0
	velocity = Vector2.ZERO
	facing = -1.0


func activate() -> void:
	visible = true
	intro_timer = 0.0
	attack_cooldown = 0.8


func reset_to_spawn(new_position: Vector2) -> void:
	ensure_profile_loaded()
	spawn_position = new_position
	global_position = new_position
	health = int(profile.get("health", 1))
	max_health = health
	velocity = Vector2.ZERO
	facing = -1.0
	hitstun_timer = 0.0
	attack_cooldown = 0.9
	attack_windup = 0.0
	attack_pending = ""
	dash_timer = 0.0
	dash_hit_timer = 0.0
	intro_timer = 0.0
	phase_two = false
	attack_index = 0
	visible = false


func update_phase_state() -> void:
	if health > 0 and health <= int(max_health / 2):
		phase_two = true


func active_for_combat() -> bool:
	return visible and intro_timer <= 0.0 and health > 0


func is_active() -> bool:
	return active_for_combat()


func is_defeated() -> bool:
	return visible and health <= 0


func get_health_ratio() -> float:
	if max_health <= 0:
		return 0.0
	return float(health) / float(max_health)


func get_display_name() -> String:
	return str(profile.get("display_name", "Boss"))


func get_state_name() -> String:
	if not visible:
		return "hidden"
	if health <= 0:
		return "down"
	if intro_timer > 0.0:
		return "charging"
	if dash_timer > 0.0:
		return "dashing"
	if attack_windup > 0.0:
		return "telegraph"
	if phase_two:
		return "phase_two"
	return "idle"


func get_player() -> Node2D:
	if stage != null and stage.has_method("get_player"):
		return stage.call("get_player")
	return null


func get_stage_bounds() -> Vector2:
	if stage != null and stage.has_method("get_stage_bounds"):
		return stage.call("get_stage_bounds")
	return Vector2(-760.0, 1480.0)


func ensure_profile_loaded() -> void:
	if profile.is_empty():
		profile = EnemyProfileLibrary.get_profile(enemy_id)


func _draw() -> void:
	if not visible:
		return
	var body_color := Color(str(profile.get("color", "e0b45e")))
	if health <= 0:
		body_color = Color("706257")
	elif hitstun_timer > 0.0:
		body_color = Color("ffd39a")
	elif dash_timer > 0.0:
		body_color = Color("fff7c8")
	elif attack_windup > 0.0:
		body_color = Color("ffe69c")

	var size := Vector2(92.0, 148.0)
	draw_rect(Rect2(Vector2(-size.x * 0.5, -size.y), size), body_color)
	draw_rect(Rect2(Vector2(-18.0, -size.y - 26.0), Vector2(36.0, 26.0)), Color(str(profile.get("accent", "fff4ba"))))
	draw_line(Vector2(-28.0 * facing, -80.0), Vector2(46.0 * facing, -52.0), Color("fff7de"), 8.0)
	draw_circle(Vector2(0.0, -70.0), 38.0, Color(0.98, 0.93, 0.74, 0.22))
	if phase_two:
		draw_circle(Vector2.ZERO, 86.0, Color(0.97, 0.87, 0.41, 0.15))
	if intro_timer > 0.0:
		draw_circle(Vector2.ZERO, 112.0 + 16.0 * sin((1.0 - intro_timer) * 9.0), Color(0.88, 1.0, 0.94, 0.16))
	if attack_windup > 0.0:
		draw_rect(Rect2(Vector2(20.0 * facing - 110.0, -112.0), Vector2(140.0, 56.0)), Color(1.0, 0.94, 0.70, 0.22))
