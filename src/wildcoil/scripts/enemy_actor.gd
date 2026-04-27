extends CharacterBody2D
class_name EnemyActor

signal defeated(enemy)
signal attack_landed(enemy, damage)

const BODY_SIZE := Vector2(34, 52)

var enemy_id := "iron_veil_grunt"
var display_name := "Iron Veil Grunt"
var max_health := 42
var health := 42
var move_speed := 145.0
var attack_damage := 8
var attack_range := 54.0
var telegraph_seconds := 0.22
var score_value := 100
var target: Node2D
var attack_cooldown := 0.7
var telegraph_timer := 0.0
var hurt_flash := 0.0

func setup(profile: Dictionary) -> void:
	enemy_id = profile.get("id", enemy_id)
	display_name = profile.get("name", display_name)
	max_health = int(profile.get("max_health", max_health))
	health = max_health
	move_speed = float(profile.get("move_speed", move_speed))
	attack_damage = int(profile.get("attack_damage", attack_damage))
	attack_range = float(profile.get("attack_range", attack_range))
	telegraph_seconds = float(profile.get("telegraph_seconds", telegraph_seconds))
	score_value = int(profile.get("score", score_value))
	queue_redraw()

func _physics_process(delta: float) -> void:
	if health <= 0 or target == null:
		return
	hurt_flash = maxf(hurt_flash - delta, 0.0)
	attack_cooldown = maxf(attack_cooldown - delta, 0.0)

	var offset := target.position - position
	var distance := offset.length()
	if telegraph_timer > 0.0:
		telegraph_timer -= delta
		if telegraph_timer <= 0.0 and distance <= attack_range + 18.0:
			attack_landed.emit(self, attack_damage)
		velocity = Vector2.ZERO
	elif distance > attack_range:
		velocity = offset.normalized() * move_speed
	else:
		velocity = Vector2.ZERO
		if attack_cooldown <= 0.0:
			telegraph_timer = telegraph_seconds
			attack_cooldown = 1.1

	move_and_slide()
	z_index = int(position.y)
	queue_redraw()

func body_rect() -> Rect2:
	return Rect2(position - Vector2(BODY_SIZE.x * 0.5, BODY_SIZE.y), BODY_SIZE)

func apply_damage(amount: int, source_x: float) -> void:
	health = max(health - amount, 0)
	position.x += sign(position.x - source_x) * 24.0
	hurt_flash = 0.12
	if health <= 0:
		defeated.emit(self)
		queue_free()
	queue_redraw()

func _draw() -> void:
	var color := Color(0.34, 0.39, 0.44)
	if enemy_id == "iron_veil_runner":
		color = Color(0.38, 0.52, 0.74)
	elif enemy_id == "iron_veil_brute":
		color = Color(0.48, 0.16, 0.14)
	if hurt_flash > 0.0:
		color = Color(1.0, 0.9, 0.5)
	draw_rect(Rect2(Vector2(-17, -52), BODY_SIZE), color)
	draw_rect(Rect2(Vector2(-12, -66), Vector2(24, 14)), Color(0.06, 0.06, 0.07))
	if telegraph_timer > 0.0:
		draw_rect(Rect2(Vector2(-28, -58), Vector2(56, 60)), Color(1.0, 0.08, 0.04, 0.25))

