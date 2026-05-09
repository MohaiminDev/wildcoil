class_name StormWardenBoss
extends Node2D

const EnemyProfileLibrary = preload("res://scripts/core/enemy_profile_library.gd")

const GROUND_Y := 140.0
const ARENA_MIN_X := 180.0
const ARENA_MAX_X := 700.0
const INTRO_DURATION := 1.1
const GRAVITY := 1600.0

var stage: Node
var profile: Dictionary = {}
var spawn_position := Vector2.ZERO
var velocity := Vector2.ZERO
var facing := -1.0
var health := 0
var max_health := 0
var hitstun_timer := 0.0
var attack_cooldown := 0.6
var attack_windup := 0.0
var attack_mode := ""
var current_state := "intro"
var intro_timer := INTRO_DURATION
var boss_phase := 1
var pattern_index := 0
var phase_flash_timer := 0.0
var defeated := false


func _ready() -> void:
	ensure_profile_loaded()
	spawn_position = global_position
	reset_to_spawn(global_position)
	queue_redraw()


func _physics_process(delta: float) -> void:
	if stage != null and stage.has_method("is_hitstop_active") and stage.call("is_hitstop_active"):
		queue_redraw()
		return

	phase_flash_timer = maxf(phase_flash_timer - delta, 0.0)
	hitstun_timer = maxf(hitstun_timer - delta, 0.0)
	attack_cooldown = maxf(attack_cooldown - delta, 0.0)
	if defeated:
		velocity = Vector2.ZERO
		queue_redraw()
		return

	if current_state == "intro":
		intro_timer = maxf(intro_timer - delta, 0.0)
		var intro_progress := 1.0 - intro_timer / INTRO_DURATION
		global_position = Vector2(spawn_position.x, lerpf(spawn_position.y - 220.0, spawn_position.y, intro_progress))
		if intro_timer <= 0.0:
			current_state = "active"
			global_position = spawn_position
			attack_cooldown = 0.55
		queue_redraw()
		return

	if attack_windup > 0.0:
		attack_windup = maxf(attack_windup - delta, 0.0)
		if attack_windup <= 0.0:
			perform_attack()

	if current_state == "active" and health > 0:
		update_behavior(delta)

	velocity.y += GRAVITY * delta
	global_position += velocity * delta
	if global_position.y > GROUND_Y:
		global_position.y = GROUND_Y
		velocity.y = 0.0
	global_position.x = clampf(global_position.x, ARENA_MIN_X, ARENA_MAX_X)
	velocity.x = move_toward(velocity.x, 0.0, 920.0 * delta)
	queue_redraw()


func update_behavior(delta: float) -> void:
	var player := get_player()
	if player == null:
		return
	var distance := player.global_position.x - global_position.x
	if absf(distance) > 12.0:
		facing = sign(distance)

	if hitstun_timer > 0.0 or attack_windup > 0.0:
		return

	var desired_range := 180.0 if boss_phase == 1 else 150.0
	var move_speed := float(profile.get("walk_speed", 86.0)) * (1.0 if boss_phase == 1 else 1.18)
	if absf(distance) > desired_range + 40.0:
		velocity.x = move_toward(velocity.x, sign(distance) * move_speed, 820.0 * delta)
	elif absf(distance) < desired_range - 24.0:
		velocity.x = move_toward(velocity.x, -sign(distance) * move_speed * 0.72, 820.0 * delta)

	if attack_cooldown <= 0.0:
		choose_attack(distance)


func choose_attack(distance: float) -> void:
	var phase_one_pattern := ["sweep", "orbs", "crush"]
	var phase_two_pattern := ["orbs", "crush", "burst", "sweep"]
	var pattern := phase_one_pattern if boss_phase == 1 else phase_two_pattern
	attack_mode = pattern[pattern_index % pattern.size()]
	pattern_index += 1
	if absf(distance) < 120.0 and attack_mode == "orbs":
		attack_mode = "sweep"
	if absf(distance) > 260.0 and attack_mode == "sweep":
		attack_mode = "orbs"

	match attack_mode:
		"sweep":
			attack_windup = 0.42
		"orbs":
			attack_windup = 0.58
		"crush":
			attack_windup = 0.50
		"burst":
			attack_windup = 0.62
		_:
			attack_windup = 0.44

	if stage != null and stage.has_method("apply_camera_shake"):
		stage.call("apply_camera_shake", 5.0 if boss_phase == 1 else 8.0, 0.12)


func perform_attack() -> void:
	if stage == null:
		return
	match attack_mode:
		"sweep":
			stage.call("resolve_enemy_attack", {
				"id": "storm_warden_sweep",
				"damage": 18,
				"reach": 168.0,
				"knockback_x": 260.0,
				"knockback_y": -180.0,
				"stun": 0.28,
				"hitstop": 0.06,
			}, global_position, facing)
			stage.call("apply_camera_shake", 10.0, 0.18)
			attack_cooldown = 1.05 if boss_phase == 1 else 0.82
		"orbs":
			var projectile_profile := {
				"id": "storm_warden_orb",
				"damage": 14 if boss_phase == 1 else 16,
				"reach": 28.0,
				"knockback_x": 190.0,
				"knockback_y": -120.0,
				"stun": 0.20,
				"hitstop": 0.04,
			}
			stage.call("spawn_scripted_projectile", global_position + Vector2(24.0 * facing, -70.0), facing, float(profile.get("projectile_speed", 320.0)), float(profile.get("projectile_range", 520.0)), projectile_profile)
			stage.call("spawn_scripted_projectile", global_position + Vector2(36.0 * facing, -32.0), facing, float(profile.get("projectile_speed", 320.0)) * 0.88, float(profile.get("projectile_range", 520.0)) * 0.82, projectile_profile)
			attack_cooldown = 1.18 if boss_phase == 1 else 0.96
		"crush":
			stage.call("resolve_enemy_attack", {
				"id": "storm_warden_crush",
				"damage": 20 if boss_phase == 1 else 24,
				"reach": 210.0,
				"knockback_x": 340.0,
				"knockback_y": -220.0,
				"stun": 0.32,
				"hitstop": 0.08,
			}, global_position, facing)
			velocity.x = float(profile.get("dash_speed", 520.0)) * facing
			stage.call("apply_camera_shake", 12.0, 0.24)
			attack_cooldown = 1.28 if boss_phase == 1 else 1.02
		"burst":
			stage.call("resolve_enemy_attack", {
				"id": "storm_warden_burst",
				"damage": 16,
				"reach": 196.0,
				"knockback_x": 300.0,
				"knockback_y": -160.0,
				"stun": 0.26,
				"hitstop": 0.06,
			}, global_position, facing)
			stage.call("spawn_scripted_projectile", global_position + Vector2(12.0 * facing, -48.0), facing, float(profile.get("projectile_speed", 320.0)) * 1.08, float(profile.get("projectile_range", 520.0)), {
				"id": "storm_warden_burst_orb",
				"damage": 12,
				"reach": 26.0,
				"knockback_x": 180.0,
				"knockback_y": -100.0,
				"stun": 0.18,
				"hitstop": 0.04,
			})
			stage.call("apply_camera_shake", 14.0, 0.26)
			attack_cooldown = 1.38
		_:
			attack_cooldown = 1.0
	attack_mode = ""


func take_hit(attack_profile: Dictionary, attacker_facing: float, attacker_position: Vector2) -> bool:
	if current_state == "intro" or defeated:
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
	attack_windup = 0.0
	attack_mode = ""
	attack_cooldown = 0.45
	velocity.x = float(attack_profile.get("knockback_x", 0.0)) * attacker_facing * 0.7
	velocity.y = float(attack_profile.get("knockback_y", 0.0)) * 0.6
	if boss_phase == 1 and health > 0 and health <= int(round(max_health * 0.5)):
		boss_phase = 2
		phase_flash_timer = 0.6
		attack_cooldown = 0.35
		if stage != null and stage.has_method("apply_camera_shake"):
			stage.call("apply_camera_shake", 18.0, 0.32)
	if health <= 0:
		defeated = true
		current_state = "defeated"
		velocity = Vector2.ZERO
		if stage != null and stage.has_method("apply_camera_shake"):
			stage.call("apply_camera_shake", 20.0, 0.38)
	return true


func reset_to_spawn(new_position: Vector2) -> void:
	ensure_profile_loaded()
	spawn_position = new_position
	global_position = new_position + Vector2(0.0, -220.0)
	velocity = Vector2.ZERO
	facing = -1.0
	health = max_health
	hitstun_timer = 0.0
	attack_cooldown = 0.6
	attack_windup = 0.0
	attack_mode = ""
	current_state = "intro"
	intro_timer = INTRO_DURATION
	boss_phase = 1
	pattern_index = 0
	phase_flash_timer = 0.0
	defeated = false


func get_player() -> Node2D:
	if stage != null and stage.has_method("get_player"):
		return stage.call("get_player")
	return null


func ensure_profile_loaded() -> void:
	if profile.is_empty():
		profile = EnemyProfileLibrary.get_profile("storm_warden")
	if max_health <= 0:
		max_health = int(profile.get("health", 240))
	if health <= 0:
		health = max_health


func is_active() -> bool:
	return current_state == "active" and health > 0 and not defeated


func is_intro_active() -> bool:
	return current_state == "intro"


func is_defeated() -> bool:
	return defeated


func get_state_name() -> String:
	if defeated:
		return "down"
	if current_state == "intro":
		return "intro"
	if hitstun_timer > 0.0:
		return "stunned"
	if attack_windup > 0.0:
		return "telegraph_%s" % attack_mode
	return "active"


func get_health_ratio() -> float:
	if max_health <= 0:
		return 0.0
	return float(health) / float(max_health)


func _draw() -> void:
	var core_color := Color(str(profile.get("accent", "fff4ba")))
	var shell_color := Color(str(profile.get("color", "e0b45e")))
	if defeated:
		shell_color = Color("5f5f6c")
		core_color = Color("8b8791")
	elif phase_flash_timer > 0.0:
		shell_color = Color("fff0bf")
	elif hitstun_timer > 0.0:
		shell_color = Color("ff9b7e")
	elif attack_windup > 0.0:
		shell_color = Color("ffd86c")

	if boss_phase == 2 and not defeated:
		core_color = Color("a0fff2")

	draw_rect(Rect2(Vector2(-54.0, -124.0), Vector2(108.0, 124.0)), shell_color)
	draw_rect(Rect2(Vector2(-20.0, -154.0), Vector2(40.0, 30.0)), core_color)
	draw_rect(Rect2(Vector2(-72.0, -98.0), Vector2(18.0, 78.0)), shell_color.darkened(0.16))
	draw_rect(Rect2(Vector2(54.0, -98.0), Vector2(18.0, 78.0)), shell_color.darkened(0.16))
	draw_line(Vector2(-28.0 * facing, -68.0), Vector2(58.0 * facing, -28.0), Color("0b1720"), 8.0)
	draw_circle(Vector2(0.0, -84.0), 16.0, core_color)
	if attack_windup > 0.0:
		var telegraph_width := 160.0 if attack_mode == "orbs" else 120.0
		draw_rect(Rect2(Vector2(24.0 * facing - telegraph_width * 0.5, -90.0), Vector2(telegraph_width, 46.0)), Color(1.0, 0.9, 0.5, 0.18))
	if boss_phase == 2 and not defeated:
		draw_circle(Vector2(0.0, -92.0), 28.0 + 4.0 * sin(Time.get_ticks_msec() * 0.01), Color(0.63, 1.0, 0.95, 0.16))
