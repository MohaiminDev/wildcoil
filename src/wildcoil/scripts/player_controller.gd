extends CharacterBody2D
class_name PlayerController

signal defeated

const VisualAssetLoader := preload("res://scripts/visual_asset_loader.gd")
const BODY_SIZE := Vector2(34, 58)
const FLOOR_TOP := 330.0
const FLOOR_BOTTOM := 620.0
const FLOOR_LEFT := 80.0
const FLOOR_RIGHT := 1200.0
const CONTROLLER_DEADZONE := 0.22
const CONTROLLER_ATTACK_BUTTONS := [JOY_BUTTON_X]
const CONTROLLER_JUMP_BUTTONS := [JOY_BUTTON_A]
const CONTROLLER_SPECIAL_BUTTONS := [JOY_BUTTON_Y, JOY_BUTTON_RIGHT_SHOULDER]
const CONTROLLER_DASH_BUTTONS := [JOY_BUTTON_B, JOY_BUTTON_LEFT_SHOULDER]

var hero_id := "raya_flint"
var display_name := "Raya Flint"
var max_health := 120
var health := 120
var move_speed := 245.0
var dash_speed := 620.0
var attack_damage := 18
var special_damage := 34
var special_cost := 50
var special_meter := 0
var luma_shards := 0
var score := 0
var combat_timing := {}

var facing := 1
var dash_timer := 0.0
var dash_cooldown := 0.0
var dodge_invulnerable_timer := 0.0
var dodge_recovery_timer := 0.0
var attack_timer := 0.0
var attack_lunge_timer := 0.0
var special_timer := 0.0
var attack_total_duration := 0.0
var special_total_duration := 0.0
var current_attack_timing := {}
var current_special_timing := {}
var invulnerable_timer := 0.0
var jump_timer := 0.0
var fake_height := 0.0
var is_knocked_down := false
var animation_time := 0.0
var attack_step := 0
var combo_count := 0
var combo_timer := 0.0
var attack_buffer_timer := 0.0
var special_buffer_timer := 0.0
var attack_key_down := false
var special_key_down := false
var demo_control_active := false
var demo_move_vector := Vector2.ZERO
var demo_attack_pressed := false
var demo_special_pressed := false
var demo_dash_pressed := false
var demo_jump_pressed := false
var visual_sprites := {}

func setup(profile: Dictionary) -> void:
	hero_id = profile.get("id", hero_id)
	display_name = profile.get("name", display_name)
	max_health = int(profile.get("max_health", max_health))
	health = max_health
	move_speed = float(profile.get("move_speed", move_speed))
	dash_speed = float(profile.get("dash_speed", dash_speed))
	attack_damage = int(profile.get("attack_damage", attack_damage))
	special_damage = int(profile.get("special_damage", special_damage))
	special_cost = int(profile.get("special_cost", special_cost))
	combat_timing = profile.get("combat_timing", {})
	_load_visual_sprites()
	queue_redraw()

func _physics_process(delta: float) -> void:
	animation_time += delta
	_tick_timers(delta)
	if health <= 0:
		return

	var input_vector := Vector2.ZERO
	if demo_control_active:
		input_vector = demo_move_vector.limit_length(1.0)
	else:
		if Input.is_action_pressed("move_left"):
			input_vector.x -= 1.0
		if Input.is_action_pressed("move_right"):
			input_vector.x += 1.0
		if Input.is_action_pressed("move_up"):
			input_vector.y -= 1.0
		if Input.is_action_pressed("move_down"):
			input_vector.y += 1.0
		input_vector += _read_controller_move()
	if input_vector.x != 0:
		facing = sign(input_vector.x)

	var dash_pressed := demo_dash_pressed if demo_control_active else _dash_pressed()
	if dash_pressed and dash_cooldown <= 0.0:
		begin_dodge()

	var jump_pressed := demo_jump_pressed if demo_control_active else _jump_pressed()
	if jump_pressed and jump_timer <= 0.0 and fake_height <= 0.0:
		jump_timer = 0.52

	var attack_pressed := demo_attack_pressed if demo_control_active else _attack_pressed()
	if attack_pressed and not attack_key_down:
		if attack_timer <= 0.0:
			_start_light_attack()
		else:
			attack_buffer_timer = 0.18
	attack_key_down = attack_pressed

	var special_pressed := demo_special_pressed if demo_control_active else _special_pressed()
	if special_pressed and not special_key_down:
		if special_timer <= 0.0 and special_meter >= special_cost:
			_start_special_attack()
		else:
			special_buffer_timer = 0.20
	special_key_down = special_pressed

	if attack_timer <= 0.0 and attack_buffer_timer > 0.0:
		attack_buffer_timer = 0.0
		_start_light_attack()

	if special_timer <= 0.0 and special_buffer_timer > 0.0 and special_meter >= special_cost:
		special_buffer_timer = 0.0
		_start_special_attack()

	var speed := dash_speed if dash_timer > 0.0 else move_speed
	velocity = input_vector.normalized() * speed
	if attack_lunge_timer > 0.0:
		velocity.x += float(facing) * (460.0 + float(attack_step) * 55.0)
		velocity.y *= 0.35
	move_and_slide()
	position.x = clamp(position.x, FLOOR_LEFT, FLOOR_RIGHT)
	position.y = clamp(position.y, FLOOR_TOP, FLOOR_BOTTOM)
	z_index = int(position.y)
	queue_redraw()

func _start_light_attack() -> void:
	attack_step = (attack_step % 3) + 1
	current_attack_timing = _attack_timing_for_step(attack_step)
	attack_total_duration = _timing_duration(current_attack_timing)
	attack_timer = attack_total_duration
	attack_lunge_timer = float(current_attack_timing.get("lunge", 0.075 + float(attack_step) * 0.012))

func _start_special_attack() -> void:
	special_meter -= special_cost
	current_special_timing = _special_timing()
	special_total_duration = _timing_duration(current_special_timing)
	special_timer = special_total_duration
	attack_lunge_timer = float(current_special_timing.get("lunge", 0.13))

func begin_dodge() -> void:
	dash_timer = 0.18 if hero_id == "kian_vale" else 0.15
	dodge_invulnerable_timer = 0.14 if hero_id == "kian_vale" else 0.11
	dodge_recovery_timer = 0.10
	dash_cooldown = 0.52

func set_demo_control(active: bool) -> void:
	demo_control_active = active
	if not active:
		set_demo_intent(Vector2.ZERO, false, false, false, false)
		attack_key_down = false
		special_key_down = false

func set_demo_intent(move_vector: Vector2, attack_pressed: bool, dash_pressed := false, special_pressed := false, jump_pressed := false) -> void:
	demo_move_vector = move_vector.limit_length(1.0)
	demo_attack_pressed = attack_pressed
	demo_dash_pressed = dash_pressed
	demo_special_pressed = special_pressed
	demo_jump_pressed = jump_pressed

func _read_controller_move() -> Vector2:
	var move := Vector2.ZERO
	for joy_id in Input.get_connected_joypads():
		var axis_x := Input.get_joy_axis(joy_id, JOY_AXIS_LEFT_X)
		var axis_y := Input.get_joy_axis(joy_id, JOY_AXIS_LEFT_Y)
		if absf(axis_x) > CONTROLLER_DEADZONE and absf(axis_x) > absf(move.x):
			move.x = axis_x
		if absf(axis_y) > CONTROLLER_DEADZONE and absf(axis_y) > absf(move.y):
			move.y = axis_y
		if Input.is_joy_button_pressed(joy_id, JOY_BUTTON_DPAD_LEFT):
			move.x = -1.0
		elif Input.is_joy_button_pressed(joy_id, JOY_BUTTON_DPAD_RIGHT):
			move.x = 1.0
		if Input.is_joy_button_pressed(joy_id, JOY_BUTTON_DPAD_UP):
			move.y = -1.0
		elif Input.is_joy_button_pressed(joy_id, JOY_BUTTON_DPAD_DOWN):
			move.y = 1.0
	return move.limit_length(1.0)

func _is_controller_button_pressed(buttons: Array) -> bool:
	for joy_id in Input.get_connected_joypads():
		for button in buttons:
			if Input.is_joy_button_pressed(joy_id, int(button)):
				return true
	return false

func _attack_pressed() -> bool:
	return Input.is_action_pressed("attack") or _is_controller_button_pressed(CONTROLLER_ATTACK_BUTTONS)

func _jump_pressed() -> bool:
	return Input.is_action_pressed("jump") or _is_controller_button_pressed(CONTROLLER_JUMP_BUTTONS)

func _special_pressed() -> bool:
	return Input.is_action_pressed("special") or _is_controller_button_pressed(CONTROLLER_SPECIAL_BUTTONS)

func _dash_pressed() -> bool:
	return Input.is_action_pressed("dash") or _is_controller_button_pressed(CONTROLLER_DASH_BUTTONS)

func _tick_timers(delta: float) -> void:
	dash_timer = maxf(dash_timer - delta, 0.0)
	dash_cooldown = maxf(dash_cooldown - delta, 0.0)
	dodge_invulnerable_timer = maxf(dodge_invulnerable_timer - delta, 0.0)
	dodge_recovery_timer = maxf(dodge_recovery_timer - delta, 0.0)
	attack_timer = maxf(attack_timer - delta, 0.0)
	attack_lunge_timer = maxf(attack_lunge_timer - delta, 0.0)
	special_timer = maxf(special_timer - delta, 0.0)
	attack_buffer_timer = maxf(attack_buffer_timer - delta, 0.0)
	special_buffer_timer = maxf(special_buffer_timer - delta, 0.0)
	invulnerable_timer = maxf(invulnerable_timer - delta, 0.0)
	combo_timer = maxf(combo_timer - delta, 0.0)
	if combo_timer <= 0.0:
		combo_count = 0
		if attack_timer <= 0.0:
			attack_step = 0
			attack_total_duration = 0.0
			current_attack_timing = {}
	if jump_timer > 0.0:
		jump_timer = maxf(jump_timer - delta, 0.0)
		var progress := 1.0 - (jump_timer / 0.52)
		fake_height = sin(progress * PI) * 54.0
	else:
		fake_height = 0.0

func is_attack_active() -> bool:
	if attack_timer <= 0.0:
		return false
	return _timing_window_active(current_attack_timing, attack_total_duration - attack_timer)

func is_special_active() -> bool:
	if special_timer <= 0.0:
		return false
	return _timing_window_active(current_special_timing, special_total_duration - special_timer)

func attack_rect() -> Rect2:
	var hitbox: Dictionary = current_attack_timing.get("hitbox", {})
	var width := float(hitbox.get("width", 82.0 + float(attack_step) * 11.0))
	var height := float(hitbox.get("height", 58.0))
	var origin_x := position.x + 16.0 if facing >= 0 else position.x - width - 16.0
	return Rect2(Vector2(origin_x, position.y - 64.0 - fake_height), Vector2(width, height))

func special_rect() -> Rect2:
	var hitbox: Dictionary = current_special_timing.get("hitbox", {})
	var width := float(hitbox.get("width", 168.0))
	var height := float(hitbox.get("height", 168.0))
	return Rect2(position - Vector2(width * 0.5, height * 0.62 + fake_height), Vector2(width, height))

func body_rect() -> Rect2:
	return Rect2(position - Vector2(BODY_SIZE.x * 0.5, BODY_SIZE.y), BODY_SIZE)

func apply_damage(amount: int, source_x: float) -> void:
	if invulnerable_timer > 0.0 or dodge_invulnerable_timer > 0.0 or health <= 0:
		return
	health = max(health - amount, 0)
	invulnerable_timer = 0.75
	position.x += sign(position.x - source_x) * 22.0
	if health <= 0:
		defeated.emit()
	queue_redraw()

func add_meter(amount: int) -> void:
	special_meter = mini(special_meter + amount, 100)

func register_hit() -> void:
	combo_count += 1
	combo_timer = 1.45
	add_meter(4 + mini(combo_count, 8))
	score += combo_count * 3

func current_attack_damage() -> int:
	var step_bonus := int(current_attack_timing.get("damage_bonus", attack_step * (5 if hero_id == "kian_vale" else 3)))
	return attack_damage + step_bonus

func _attack_timing_for_step(step: int) -> Dictionary:
	var combo: Array = combat_timing.get("light_combo", [])
	for move in combo:
		if int(move.get("step", 0)) == step:
			return move
	if hero_id == "kian_vale":
		return {
			"startup": 0.07 + float(step - 1) * 0.015,
			"active": 0.12 + float(step - 1) * 0.02,
			"recovery": 0.19 + float(step - 1) * 0.055,
			"lunge": 0.10 + float(step) * 0.02,
			"damage_bonus": step * 5,
			"hitbox": {"width": 98.0 + float(step) * 16.0, "height": 66.0}
		}
	return {
		"startup": 0.06,
		"active": 0.12,
		"recovery": 0.08 + float(step) * 0.045,
		"lunge": 0.075 + float(step) * 0.012,
		"damage_bonus": step * 3,
		"hitbox": {"width": 82.0 + float(step) * 11.0, "height": 58.0}
	}

func _special_timing() -> Dictionary:
	var timing: Dictionary = combat_timing.get("special", {})
	if not timing.is_empty():
		return timing
	if hero_id == "kian_vale":
		return {"startup": 0.13, "active": 0.30, "recovery": 0.13, "lunge": 0.18, "hitbox": {"width": 168.0, "height": 168.0}}
	return {"startup": 0.08, "active": 0.22, "recovery": 0.08, "lunge": 0.13, "hitbox": {"width": 168.0, "height": 168.0}}

func _timing_duration(timing: Dictionary) -> float:
	return float(timing.get("startup", 0.0)) + float(timing.get("active", 0.0)) + float(timing.get("recovery", 0.0))

func _timing_window_active(timing: Dictionary, elapsed: float) -> bool:
	var startup := float(timing.get("startup", 0.0))
	var active := float(timing.get("active", 0.0))
	return elapsed >= startup and elapsed < startup + active

func heal(amount: int) -> void:
	health = mini(health + amount, max_health)
	queue_redraw()

func _draw() -> void:
	var alpha := 0.45 if invulnerable_timer > 0.0 else 1.0
	var bob := _animation_bob()
	_draw_contact_shadow(alpha)
	_draw_cinematic_afterimage(alpha)
	_draw_motion_smear(alpha)
	if not _draw_visual_sprite(alpha, bob):
		_draw_sprite_outline(Vector2(0, bob - fake_height), alpha)
		match hero_id:
			"kian_vale":
				_draw_kian(alpha, bob)
			"nika_sol":
				_draw_nika(alpha, bob)
			"tor_bram":
				_draw_tor(alpha, bob)
			_:
				_draw_raya(alpha, bob)
	_draw_combo_charge(alpha)
	_draw_hero_motion_details(alpha, bob)
	if is_attack_active():
		var arc_color := Color(1.0, 0.82, 0.25, 0.38) if attack_step < 3 else Color(1.0, 0.42, 0.18, 0.46)
		draw_rect(Rect2(Vector2(facing * 18 - 22, -52 - fake_height), Vector2(64 + attack_step * 8, 48)), arc_color)
	if is_special_active():
		draw_circle(Vector2(0, -30 - fake_height), 76.0, Color(0.56, 0.88, 1.0, 0.25))

func _animation_bob() -> float:
	var movement_factor := 1.0 if velocity.length() > 8.0 else 0.35
	return sin(animation_time * 11.0) * 3.0 * movement_factor

func _motion_frame(rate: float = 10.0, frames: int = 4) -> int:
	return int(floor(animation_time * rate)) % maxi(frames, 1)

func _load_visual_sprites() -> void:
	visual_sprites.clear()
	var loader := VisualAssetLoader.new()
	for state in ["idle", "walk", "attack", "hurt"]:
		var texture := loader.actor_texture(hero_id, state)
		if texture != null:
			visual_sprites[state] = texture

func _draw_visual_sprite(alpha: float, bob: float) -> bool:
	var state := _current_visual_sprite_state()
	var texture: Texture2D = visual_sprites.get(state, visual_sprites.get("idle", null))
	if texture == null:
		return false
	var target_size := Vector2(172, 202)
	var attack_offset := float(facing) * (10.0 if attack_lunge_timer > 0.0 else 0.0)
	var draw_pos := Vector2(-target_size.x * 0.5 + attack_offset, -target_size.y + 12 + bob - fake_height)
	var squash := _visual_squash_scale()
	draw_set_transform(Vector2.ZERO, _visual_tilt(), Vector2(float(facing) * squash.x, squash.y))
	draw_texture_rect(texture, Rect2(draw_pos, target_size), false, Color(1.0, 1.0, 1.0, alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	return true

func _visual_squash_scale() -> Vector2:
	if attack_lunge_timer > 0.0:
		return Vector2(1.08, 0.96)
	if dash_timer > 0.0:
		return Vector2(1.13, 0.93)
	if velocity.length() > 8.0:
		var walk := sin(animation_time * 13.0)
		return Vector2(1.0 + absf(walk) * 0.035, 1.0 - absf(walk) * 0.025)
	return Vector2(1.0, 1.0 + sin(animation_time * 4.5) * 0.012)

func _visual_tilt() -> float:
	if attack_lunge_timer > 0.0:
		return deg_to_rad(-4.0 * float(facing))
	if dash_timer > 0.0:
		return deg_to_rad(-6.0 * float(facing))
	if velocity.length() > 8.0:
		return deg_to_rad(sin(animation_time * 8.0) * 1.6 * float(facing))
	return 0.0

func _current_visual_sprite_state() -> String:
	if invulnerable_timer > 0.0:
		return "hurt"
	if is_attack_active() or is_special_active():
		return "attack"
	if velocity.length() > 8.0:
		return "walk"
	return "idle"

func _draw_contact_shadow(alpha: float) -> void:
	var squash := 1.0
	if fake_height > 0.0:
		squash = 0.72
	elif attack_lunge_timer > 0.0:
		squash = 1.18
	elif velocity.length() > 8.0:
		squash = 1.0 + absf(sin(animation_time * 12.0)) * 0.08
	_draw_flat_ellipse(Vector2(0, -2), Vector2(30 * squash, 7), Color(0, 0, 0, 0.30 * alpha))

func _draw_cinematic_afterimage(alpha: float) -> void:
	if dash_timer <= 0.0 and attack_lunge_timer <= 0.0 and special_timer <= 0.0:
		return
	var texture: Texture2D = visual_sprites.get(_current_visual_sprite_state(), visual_sprites.get("idle", null))
	if texture == null:
		return
	var target_size := Vector2(172, 202)
	var trail_color := Color(1.0, 0.58, 0.24, 0.18 * alpha) if hero_id == "raya_flint" else Color(0.64, 0.28, 1.0, 0.20 * alpha)
	if is_special_active():
		trail_color = Color(0.32, 0.9, 1.0, 0.22 * alpha)
	for i in range(3):
		var distance := float(i + 1) * (16.0 if dash_timer > 0.0 else 10.0)
		var draw_pos := Vector2(-target_size.x * 0.5 - float(facing) * distance, -target_size.y + 12 + _animation_bob() * 0.45 - fake_height)
		var fade := 1.0 - float(i) * 0.28
		draw_texture_rect(texture, Rect2(draw_pos, target_size), false, Color(trail_color.r, trail_color.g, trail_color.b, trail_color.a * fade))

func _draw_hero_motion_details(alpha: float, bob: float) -> void:
	var frame := _motion_frame(12.0, 4)
	if velocity.length() > 8.0 and fake_height <= 0.0:
		for i in range(2):
			var foot_x := (-22.0 if i == 0 else 22.0) + sin(float(frame + i) * PI * 0.5) * 5.0
			draw_line(Vector2(foot_x - 18.0, 2.0), Vector2(foot_x + 12.0, 0.0), Color(0.94, 0.68, 0.36, 0.22 * alpha), 2.0)
	if is_attack_active():
		var impact_color := Color(1.0, 0.76, 0.22, 0.58 * alpha)
		var arc_offset := Vector2(float(facing) * (44.0 + float(frame) * 2.0), -48.0 - fake_height + bob * 0.25)
		draw_arc(arc_offset, 28.0 + float(attack_step) * 8.0, -0.65, 0.82, 14, impact_color, 5.0)
		draw_line(Vector2(float(facing) * 20.0, -62.0 - fake_height), Vector2(float(facing) * 76.0, -44.0 - fake_height), Color(1.0, 0.95, 0.62, 0.52 * alpha), 3.0)
	if is_special_active():
		var pulse := 0.45 + sin(animation_time * 20.0) * 0.16
		draw_arc(Vector2(0, -48 - fake_height), 58.0 + float(frame) * 4.0, 0.0, TAU, 32, Color(0.32, 0.92, 1.0, pulse * alpha), 3.0)

func _draw_sprite_outline(offset: Vector2, alpha: float) -> void:
	var outline := Color(0.02, 0.015, 0.012, alpha)
	draw_circle(Vector2(0, -78 + offset.y), 18, outline)
	draw_rect(Rect2(Vector2(-25, -69 + offset.y), Vector2(54, 45)), outline)
	draw_line(Vector2(-16, -30 + offset.y), Vector2(-25, 2 + offset.y), outline, 11.0)
	draw_line(Vector2(16, -30 + offset.y), Vector2(25, 2 + offset.y), outline, 11.0)

func _draw_motion_smear(alpha: float) -> void:
	if dash_timer <= 0.0 and not is_attack_active():
		return
	var smear_color := Color(0.95, 0.72, 0.24, 0.18 * alpha) if hero_id == "raya_flint" else Color(0.6, 0.25, 1.0, 0.22 * alpha)
	for i in range(3):
		var back := -facing * float(i + 1) * 13.0
		draw_polygon([Vector2(back - 18, -62 - fake_height), Vector2(back + 20, -56 - fake_height), Vector2(back + 12, -22 - fake_height), Vector2(back - 25, -28 - fake_height)], [smear_color])

func _draw_combo_charge(alpha: float) -> void:
	if combo_count < 2:
		return
	var pulse := 0.35 + sin(animation_time * 18.0) * 0.18
	var color := Color(0.24, 0.92, 1.0, pulse * alpha)
	draw_arc(Vector2(0, -48 - fake_height), 42.0 + mini(combo_count, 8), 0.0, TAU, 28, color, 3.0)

func _draw_raya(alpha: float, bob: float) -> void:
	var y := -fake_height + bob
	var jacket := Color(0.95, 0.36, 0.12, alpha)
	var pants := Color(0.12, 0.12, 0.13, alpha)
	var cream := Color(0.94, 0.82, 0.58, alpha)
	var skin := Color(0.72, 0.42, 0.24, alpha)
	draw_line(Vector2(-10, -26 + y), Vector2(-18, 0 + y), pants, 7.0)
	draw_line(Vector2(10, -26 + y), Vector2(18, 0 + y), pants, 7.0)
	draw_polygon([Vector2(-20, -62 + y), Vector2(18, -64 + y), Vector2(28, -32 + y), Vector2(-22, -28 + y)], [jacket])
	draw_rect(Rect2(Vector2(-10, -55 + y), Vector2(18, 25)), cream)
	draw_line(Vector2(-15, -44 + y), Vector2(20, -50 + y), Color(1.0, 0.76, 0.36, alpha), 3.0)
	draw_circle(Vector2(0, -78 + y), 14, skin)
	draw_rect(Rect2(Vector2(-16, -90 + y), Vector2(30, 9)), Color(0.13, 0.08, 0.05, alpha))
	draw_polygon([Vector2(-20, -66 + y), Vector2(-58, -72 + y), Vector2(-20, -56 + y)], [Color(0.98, 0.72, 0.38, alpha)])
	draw_line(Vector2(16, -58 + y), Vector2(54 * facing, -36 + y), Color(0.55, 0.52, 0.48, alpha), 7.0)
	draw_line(Vector2(42 * facing, -43 + y), Vector2(64 * facing, -63 + y), Color(0.82, 0.8, 0.74, alpha), 5.0)
	draw_line(Vector2(42 * facing, -43 + y), Vector2(68 * facing, -31 + y), Color(0.82, 0.8, 0.74, alpha), 5.0)
	draw_circle(Vector2(-5, -80 + y), 2.0, Color(0.02, 0.02, 0.02, alpha))
	draw_circle(Vector2(5, -80 + y), 2.0, Color(0.02, 0.02, 0.02, alpha))

func _draw_nika(alpha: float, bob: float) -> void:
	var y := -fake_height + bob
	var violet := Color(0.55, 0.12, 0.95, alpha)
	var black := Color(0.04, 0.04, 0.06, alpha)
	var silver := Color(0.7, 0.75, 0.82, alpha)
	var skin := Color(0.62, 0.36, 0.25, alpha)
	draw_line(Vector2(-8, -26 + y), Vector2(-28, -2 + y), black, 6.0)
	draw_line(Vector2(8, -26 + y), Vector2(28, -2 + y), black, 6.0)
	draw_polygon([Vector2(-16, -64 + y), Vector2(18, -66 + y), Vector2(20, -31 + y), Vector2(-18, -29 + y)], [black])
	draw_polygon([Vector2(-13, -61 + y), Vector2(13, -63 + y), Vector2(18, -38 + y), Vector2(-15, -36 + y)], [violet])
	draw_line(Vector2(-11, -43 + y), Vector2(15, -49 + y), Color(0.92, 0.82, 1.0, alpha), 3.0)
	draw_polygon([Vector2(-20, -64 + y), Vector2(-64, -82 + y), Vector2(-24, -48 + y)], [Color(0.36, 0.08, 0.72, alpha)])
	draw_circle(Vector2(0, -78 + y), 13, skin)
	draw_rect(Rect2(Vector2(-13, -91 + y), Vector2(26, 9)), silver)
	draw_line(Vector2(15, -56 + y), Vector2(50 * facing, -44 + y), silver, 5.0)
	draw_line(Vector2(-15, -54 + y), Vector2(-45 * facing, -42 + y), violet, 4.0)
	draw_circle(Vector2(-5, -79 + y), 2.0, Color(0.02, 0.02, 0.02, alpha))
	draw_circle(Vector2(5, -79 + y), 2.0, Color(0.02, 0.02, 0.02, alpha))

func _draw_kian(alpha: float, bob: float) -> void:
	var y := -fake_height + bob
	var green := Color(0.18, 0.58, 0.34, alpha)
	var brass := Color(0.86, 0.68, 0.34, alpha)
	var blue := Color(0.06, 0.12, 0.24, alpha)
	var skin := Color(0.58, 0.38, 0.25, alpha)
	var lean := float(facing) * (6.0 if is_attack_active() else 0.0)
	draw_line(Vector2(-12 + lean, -29 + y), Vector2(-24, 0 + y), blue, 8.0)
	draw_line(Vector2(12 + lean, -29 + y), Vector2(26, 0 + y), blue, 8.0)
	draw_polygon([Vector2(-24 + lean, -66 + y), Vector2(22 + lean, -68 + y), Vector2(30 + lean, -29 + y), Vector2(-24 + lean, -27 + y)], [green])
	draw_rect(Rect2(Vector2(-14 + lean, -58 + y), Vector2(28, 30)), brass)
	draw_circle(Vector2(0 + lean, -80 + y), 14, skin)
	draw_rect(Rect2(Vector2(-19 + lean, -91 + y), Vector2(38, 9)), Color(0.09, 0.12, 0.12, alpha))
	draw_line(Vector2(-18 + lean, -51 + y), Vector2(-49 * facing, -34 + y), green, 7.0)
	var handle_start := Vector2(15 + lean, -55 + y)
	var handle_end := Vector2(74 * facing + lean, -24 + y)
	if is_attack_active():
		handle_start = Vector2(-4 + lean, -66 + y)
		handle_end = Vector2((90 + attack_step * 11) * facing + lean, -46 + y)
	elif is_special_active():
		handle_start = Vector2(-34 * facing + lean, -74 + y)
		handle_end = Vector2(50 * facing + lean, -4 + y)
	draw_line(handle_start, handle_end, Color(0.70, 0.76, 0.74, alpha), 9.0)
	draw_line(handle_start, handle_end, Color(0.96, 0.86, 0.52, 0.42 * alpha), 3.0)
	var head := handle_end
	draw_line(head + Vector2(0, -15), head + Vector2(22 * facing, -25), Color(0.86, 0.88, 0.84, alpha), 6.0)
	draw_line(head + Vector2(0, 13), head + Vector2(24 * facing, 21), Color(0.86, 0.88, 0.84, alpha), 6.0)
	draw_circle(Vector2(38 * facing + lean, -46 + y), 12, Color(0.32, 1.0, 0.68, 0.28 * alpha))
	draw_circle(Vector2(-5, -80 + y), 2.0, Color(0.02, 0.02, 0.02, alpha))
	draw_circle(Vector2(5, -80 + y), 2.0, Color(0.02, 0.02, 0.02, alpha))

func _draw_tor(alpha: float, bob: float) -> void:
	var y := -fake_height + bob
	var steel := Color(0.48, 0.50, 0.54, alpha)
	var red := Color(0.48, 0.10, 0.08, alpha)
	var tan := Color(0.66, 0.52, 0.34, alpha)
	var skin := Color(0.52, 0.34, 0.24, alpha)
	draw_line(Vector2(-16, -28 + y), Vector2(-33, 0 + y), steel, 11.0)
	draw_line(Vector2(16, -28 + y), Vector2(33, 0 + y), steel, 11.0)
	draw_polygon([Vector2(-34, -68 + y), Vector2(32, -70 + y), Vector2(42, -28 + y), Vector2(-38, -26 + y)], [steel])
	draw_rect(Rect2(Vector2(-22, -60 + y), Vector2(44, 30)), red)
	draw_circle(Vector2(0, -86 + y), 17, skin)
	draw_rect(Rect2(Vector2(-22, -101 + y), Vector2(44, 14)), tan)
	draw_line(Vector2(-32, -56 + y), Vector2(-72 * facing, -34 + y), steel, 11.0)
	draw_line(Vector2(30, -56 + y), Vector2(72 * facing, -38 + y), steel, 11.0)
	draw_circle(Vector2(75 * facing, -38 + y), 14, Color(0.18, 0.18, 0.20, alpha))
	draw_circle(Vector2(-6, -87 + y), 2.0, Color(0.02, 0.02, 0.02, alpha))
	draw_circle(Vector2(6, -87 + y), 2.0, Color(0.02, 0.02, 0.02, alpha))

func _draw_flat_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := []
	for i in range(24):
		var angle := TAU * float(i) / 24.0
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	draw_polygon(points, [color])
