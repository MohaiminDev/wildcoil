extends CharacterBody2D
class_name EnemyActor

signal defeated(enemy)
signal attack_landed(enemy, damage)

const BODY_SIZE := Vector2(34, 52)

var enemy_id := "iron_veil_grunt"
var display_name := "Iron Veil Grunt"
var species := "human"
var behavior := "basic_melee"
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
	species = profile.get("species", species)
	behavior = profile.get("behavior", behavior)
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
	if species == "machine":
		_draw_machine_enemy()
	elif species == "creature":
		_draw_creature_enemy()
	else:
		_draw_human_enemy()

func _draw_human_enemy() -> void:
	var color := Color(0.34, 0.39, 0.44)
	if enemy_id == "iron_veil_runner":
		color = Color(0.38, 0.52, 0.74)
	elif enemy_id == "iron_veil_brute":
		color = Color(0.48, 0.16, 0.14)
	elif enemy_id == "shield_guard":
		color = Color(0.24, 0.32, 0.44)
	elif enemy_id == "scrap_hurler":
		color = Color(0.52, 0.38, 0.20)
	elif enemy_id == "elite_commando":
		color = Color(0.12, 0.12, 0.16)
	if hurt_flash > 0.0:
		color = Color(1.0, 0.9, 0.5)
	var scale_boost := 1.25 if enemy_id == "iron_veil_brute" else 1.0
	_draw_flat_ellipse(Vector2(0, -2), Vector2(25 * scale_boost, 7), Color(0.0, 0.0, 0.0, 0.28))
	draw_rect(Rect2(Vector2(-13 * scale_boost, -55 * scale_boost), Vector2(26 * scale_boost, 36 * scale_boost)), color)
	draw_rect(Rect2(Vector2(-19 * scale_boost, -49 * scale_boost), Vector2(10 * scale_boost, 27 * scale_boost)), Color(0.11, 0.11, 0.12))
	draw_rect(Rect2(Vector2(9 * scale_boost, -49 * scale_boost), Vector2(10 * scale_boost, 27 * scale_boost)), Color(0.11, 0.11, 0.12))
	draw_rect(Rect2(Vector2(-11 * scale_boost, -20 * scale_boost), Vector2(8 * scale_boost, 20 * scale_boost)), Color(0.08, 0.08, 0.09))
	draw_rect(Rect2(Vector2(3 * scale_boost, -20 * scale_boost), Vector2(8 * scale_boost, 20 * scale_boost)), Color(0.08, 0.08, 0.09))
	draw_rect(Rect2(Vector2(-12 * scale_boost, -73 * scale_boost), Vector2(24 * scale_boost, 18 * scale_boost)), Color(0.06, 0.06, 0.07))
	draw_rect(Rect2(Vector2(-7 * scale_boost, -68 * scale_boost), Vector2(14 * scale_boost, 4 * scale_boost)), Color(1.0, 0.7, 0.22))
	if enemy_id == "iron_veil_brute":
		draw_rect(Rect2(Vector2(20, -61), Vector2(38, 9)), Color(0.6, 0.6, 0.64))
		draw_rect(Rect2(Vector2(46, -67), Vector2(12, 22)), Color(0.42, 0.42, 0.45))
	elif enemy_id == "shield_guard":
		draw_rect(Rect2(Vector2(20, -60), Vector2(15, 44)), Color(0.62, 0.64, 0.68))
	elif enemy_id == "scrap_hurler":
		draw_circle(Vector2(43, -48), 9, Color(0.55, 0.55, 0.58))
	elif enemy_id == "drone_tech" or enemy_id == "bio_handler":
		draw_circle(Vector2(36, -48), 10, Color(0.25, 0.95, 0.65, 0.8))
	elif enemy_id == "elite_commando":
		draw_line(Vector2(-28, -66), Vector2(28, -20), Color(1.0, 0.72, 0.18), 4.0)
	elif enemy_id == "iron_veil_runner":
		draw_line(Vector2(18, -50), Vector2(48, -26), Color(0.82, 0.82, 0.86), 4.0)
	else:
		draw_line(Vector2(16, -47), Vector2(38, -35), Color(0.7, 0.72, 0.75), 5.0)
	if telegraph_timer > 0.0:
		draw_rect(Rect2(Vector2(-28, -58), Vector2(56, 60)), Color(1.0, 0.08, 0.04, 0.25))

func _draw_creature_enemy() -> void:
	var color := Color(0.18, 0.7, 0.34)
	if enemy_id == "hornbeak_dinosaur":
		color = Color(0.75, 0.58, 0.22)
	elif enemy_id == "ashscale_dinosaur":
		color = Color(0.52, 0.18, 0.12)
	elif enemy_id == "cliff_glider":
		color = Color(0.35, 0.52, 0.78)
	elif enemy_id == "crystal_leech":
		color = Color(0.15, 0.9, 0.88)
	elif enemy_id == "echo_raptor":
		color = Color(0.18, 0.55, 0.86)
	if hurt_flash > 0.0:
		color = Color(1.0, 0.9, 0.5)
	_draw_flat_ellipse(Vector2(0, -2), Vector2(32, 8), Color(0.0, 0.0, 0.0, 0.28))
	if enemy_id == "crystal_leech":
		draw_circle(Vector2(0, -30), 20, color)
		draw_circle(Vector2(15, -34), 5, Color(0.95, 1.0, 0.75))
	elif enemy_id == "cliff_glider":
		draw_polygon([Vector2(-58, -40), Vector2(0, -70), Vector2(58, -40), Vector2(12, -28), Vector2(0, -48), Vector2(-12, -28)], [color])
		draw_circle(Vector2(12, -52), 4, Color(0.03, 0.03, 0.03))
	elif enemy_id == "hornbeak_dinosaur" or enemy_id == "ashscale_dinosaur":
		draw_polygon([Vector2(-42, -42), Vector2(12, -64), Vector2(54, -42), Vector2(23, -20), Vector2(-28, -18)], [color])
		draw_polygon([Vector2(42, -55), Vector2(78, -48), Vector2(44, -38)], [Color(1.0, 0.8, 0.24)])
		draw_circle(Vector2(28, -54), 5, Color(0.04, 0.04, 0.04))
		draw_line(Vector2(-22, -20), Vector2(-36, 0), Color(0.1, 0.1, 0.08), 6.0)
		draw_line(Vector2(16, -20), Vector2(8, 0), Color(0.1, 0.1, 0.08), 6.0)
		draw_polygon([Vector2(-40, -39), Vector2(-72, -30), Vector2(-43, -25)], [color.darkened(0.18)])
	else:
		draw_polygon([Vector2(-32, -36), Vector2(8, -54), Vector2(42, -36), Vector2(18, -18), Vector2(-24, -18)], [color])
		draw_polygon([Vector2(33, -45), Vector2(59, -41), Vector2(34, -32)], [Color(0.82, 0.98, 0.7)])
		draw_circle(Vector2(24, -45), 4, Color(0.03, 0.03, 0.03))
		draw_line(Vector2(-14, -18), Vector2(-22, 0), Color(0.08, 0.16, 0.08), 5.0)
		draw_line(Vector2(10, -18), Vector2(18, 0), Color(0.08, 0.16, 0.08), 5.0)
		draw_polygon([Vector2(-29, -34), Vector2(-58, -28), Vector2(-31, -23)], [color.darkened(0.2)])
	if telegraph_timer > 0.0:
		draw_circle(Vector2(0, -38), 44, Color(1.0, 0.1, 0.04, 0.22))

func _draw_machine_enemy() -> void:
	var color := Color(0.35, 0.38, 0.42)
	if hurt_flash > 0.0:
		color = Color(1.0, 0.9, 0.5)
	_draw_flat_ellipse(Vector2(0, -2), Vector2(24, 7), Color(0, 0, 0, 0.28))
	draw_polygon([Vector2(-25, -38), Vector2(0, -58), Vector2(25, -38), Vector2(20, -18), Vector2(-20, -18)], [color])
	draw_circle(Vector2(0, -38), 10, Color(0.2, 1.0, 0.72))
	for leg in [-24, -12, 12, 24]:
		draw_line(Vector2(0, -24), Vector2(leg, -2), Color(0.12, 0.12, 0.14), 4.0)
	if telegraph_timer > 0.0:
		draw_circle(Vector2(0, -36), 36, Color(1.0, 0.1, 0.04, 0.22))

func _draw_flat_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := []
	for i in range(24):
		var angle := TAU * float(i) / 24.0
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	draw_polygon(points, [color])
