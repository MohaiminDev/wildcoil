extends CharacterBody2D
class_name PlayerController

signal defeated

const VisualAssetLoader := preload("res://scripts/visual_asset_loader.gd")
const BODY_SIZE := Vector2(34, 58)
const FLOOR_TOP := 330.0
const FLOOR_BOTTOM := 620.0
const FLOOR_LEFT := 80.0
const FLOOR_RIGHT := 1200.0

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

var facing := 1
var dash_timer := 0.0
var dash_cooldown := 0.0
var attack_timer := 0.0
var attack_lunge_timer := 0.0
var special_timer := 0.0
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
		if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
			input_vector.x -= 1.0
		if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
			input_vector.x += 1.0
		if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
			input_vector.y -= 1.0
		if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
			input_vector.y += 1.0
	if input_vector.x != 0:
		facing = sign(input_vector.x)

	var dash_pressed := demo_dash_pressed if demo_control_active else Input.is_key_pressed(KEY_I)
	if dash_pressed and dash_cooldown <= 0.0:
		dash_timer = 0.13
		dash_cooldown = 0.52

	var jump_pressed := demo_jump_pressed if demo_control_active else Input.is_key_pressed(KEY_K)
	if jump_pressed and jump_timer <= 0.0 and fake_height <= 0.0:
		jump_timer = 0.52

	var attack_pressed := demo_attack_pressed if demo_control_active else Input.is_key_pressed(KEY_J)
	if attack_pressed and not attack_key_down:
		if attack_timer <= 0.0:
			_start_light_attack()
		else:
			attack_buffer_timer = 0.18
	attack_key_down = attack_pressed

	var special_pressed := demo_special_pressed if demo_control_active else Input.is_key_pressed(KEY_L)
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
	attack_timer = 0.26 + float(attack_step) * 0.045
	attack_lunge_timer = 0.075 + float(attack_step) * 0.012

func _start_special_attack() -> void:
	special_meter -= special_cost
	special_timer = 0.38
	attack_lunge_timer = 0.13

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

func _tick_timers(delta: float) -> void:
	dash_timer = maxf(dash_timer - delta, 0.0)
	dash_cooldown = maxf(dash_cooldown - delta, 0.0)
	attack_timer = maxf(attack_timer - delta, 0.0)
	attack_lunge_timer = maxf(attack_lunge_timer - delta, 0.0)
	special_timer = maxf(special_timer - delta, 0.0)
	attack_buffer_timer = maxf(attack_buffer_timer - delta, 0.0)
	special_buffer_timer = maxf(special_buffer_timer - delta, 0.0)
	invulnerable_timer = maxf(invulnerable_timer - delta, 0.0)
	combo_timer = maxf(combo_timer - delta, 0.0)
	if combo_timer <= 0.0:
		combo_count = 0
	if jump_timer > 0.0:
		jump_timer = maxf(jump_timer - delta, 0.0)
		var progress := 1.0 - (jump_timer / 0.52)
		fake_height = sin(progress * PI) * 54.0
	else:
		fake_height = 0.0

func is_attack_active() -> bool:
	return attack_timer > 0.11 and attack_timer < 0.24

func is_special_active() -> bool:
	return special_timer > 0.08 and special_timer < 0.30

func attack_rect() -> Rect2:
	var width := 82.0 + float(attack_step) * 11.0
	var height := 58.0
	var origin_x := position.x + 16.0 if facing >= 0 else position.x - width - 16.0
	return Rect2(Vector2(origin_x, position.y - 64.0 - fake_height), Vector2(width, height))

func special_rect() -> Rect2:
	return Rect2(position - Vector2(84, 104 + fake_height), Vector2(168, 168))

func body_rect() -> Rect2:
	return Rect2(position - Vector2(BODY_SIZE.x * 0.5, BODY_SIZE.y), BODY_SIZE)

func apply_damage(amount: int, source_x: float) -> void:
	if invulnerable_timer > 0.0 or health <= 0:
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
	return attack_damage + attack_step * 3

func heal(amount: int) -> void:
	health = mini(health + amount, max_health)
	queue_redraw()

func _draw() -> void:
	var alpha := 0.45 if invulnerable_timer > 0.0 else 1.0
	var bob := _animation_bob()
	_draw_flat_ellipse(Vector2(0, -2), Vector2(28, 7), Color(0, 0, 0, 0.28))
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
	if is_attack_active():
		var arc_color := Color(1.0, 0.82, 0.25, 0.38) if attack_step < 3 else Color(1.0, 0.42, 0.18, 0.46)
		draw_rect(Rect2(Vector2(facing * 18 - 22, -52 - fake_height), Vector2(64 + attack_step * 8, 48)), arc_color)
	if is_special_active():
		draw_circle(Vector2(0, -30 - fake_height), 76.0, Color(0.56, 0.88, 1.0, 0.25))

func _animation_bob() -> float:
	var movement_factor := 1.0 if velocity.length() > 8.0 else 0.35
	return sin(animation_time * 11.0) * 3.0 * movement_factor

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
	var green := Color(0.22, 0.72, 0.42, alpha)
	var white := Color(0.86, 0.92, 0.86, alpha)
	var blue := Color(0.08, 0.16, 0.32, alpha)
	var skin := Color(0.58, 0.38, 0.25, alpha)
	draw_line(Vector2(-9, -28 + y), Vector2(-20, 0 + y), blue, 6.0)
	draw_line(Vector2(9, -28 + y), Vector2(20, 0 + y), blue, 6.0)
	draw_polygon([Vector2(-18, -64 + y), Vector2(18, -65 + y), Vector2(22, -30 + y), Vector2(-20, -28 + y)], [white])
	draw_rect(Rect2(Vector2(-13, -58 + y), Vector2(26, 28)), green)
	draw_circle(Vector2(0, -79 + y), 13, skin)
	draw_rect(Rect2(Vector2(-18, -88 + y), Vector2(36, 8)), Color(0.62, 1.0, 0.74, alpha))
	draw_line(Vector2(-18, -50 + y), Vector2(-54 * facing, -32 + y), green, 5.0)
	draw_line(Vector2(16, -54 + y), Vector2(62 * facing, -80 + y), Color(0.72, 0.95, 1.0, alpha), 5.0)
	draw_line(Vector2(62 * facing, -86 + y), Vector2(62 * facing, -18 + y), Color(0.72, 0.95, 1.0, alpha), 4.0)
	draw_circle(Vector2(58 * facing, -50 + y), 11, Color(0.3, 1.0, 0.7, 0.42 * alpha))
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
