extends CharacterBody2D
class_name PlayerController

signal defeated

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
var special_timer := 0.0
var invulnerable_timer := 0.0
var jump_timer := 0.0
var fake_height := 0.0
var is_knocked_down := false

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
	queue_redraw()

func _physics_process(delta: float) -> void:
	_tick_timers(delta)
	if health <= 0:
		return

	var input_vector := Vector2.ZERO
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

	if Input.is_key_pressed(KEY_I) and dash_cooldown <= 0.0:
		dash_timer = 0.13
		dash_cooldown = 0.52

	if Input.is_key_pressed(KEY_K) and jump_timer <= 0.0 and fake_height <= 0.0:
		jump_timer = 0.52

	if Input.is_key_pressed(KEY_J) and attack_timer <= 0.0:
		attack_timer = 0.30

	if Input.is_key_pressed(KEY_L) and special_timer <= 0.0 and special_meter >= special_cost:
		special_meter -= special_cost
		special_timer = 0.38

	var speed := dash_speed if dash_timer > 0.0 else move_speed
	velocity = input_vector.normalized() * speed
	move_and_slide()
	position.x = clamp(position.x, FLOOR_LEFT, FLOOR_RIGHT)
	position.y = clamp(position.y, FLOOR_TOP, FLOOR_BOTTOM)
	z_index = int(position.y)
	queue_redraw()

func _tick_timers(delta: float) -> void:
	dash_timer = maxf(dash_timer - delta, 0.0)
	dash_cooldown = maxf(dash_cooldown - delta, 0.0)
	attack_timer = maxf(attack_timer - delta, 0.0)
	special_timer = maxf(special_timer - delta, 0.0)
	invulnerable_timer = maxf(invulnerable_timer - delta, 0.0)
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
	return Rect2(Vector2(position.x + facing * 18.0 - 22.0, position.y - 52.0 - fake_height), Vector2(64, 48))

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

func heal(amount: int) -> void:
	health = mini(health + amount, max_health)
	queue_redraw()

func _draw() -> void:
	var body_color := Color(0.95, 0.38, 0.12) if hero_id == "raya_flint" else Color(0.55, 0.18, 0.95)
	var alpha := 0.45 if invulnerable_timer > 0.0 else 1.0
	body_color.a = alpha
	draw_rect(Rect2(Vector2(-17, -58 - fake_height), BODY_SIZE), body_color)
	draw_rect(Rect2(Vector2(-10, -72 - fake_height), Vector2(20, 16)), Color(0.98, 0.86, 0.64, alpha))
	if is_attack_active():
		draw_rect(Rect2(Vector2(facing * 18 - 22, -52 - fake_height), Vector2(64, 48)), Color(1.0, 0.82, 0.25, 0.35))
	if is_special_active():
		draw_circle(Vector2(0, -30 - fake_height), 76.0, Color(0.56, 0.88, 1.0, 0.25))

