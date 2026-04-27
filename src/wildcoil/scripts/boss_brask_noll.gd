extends CharacterBody2D
class_name BossBraskNoll

signal defeated
signal attack_landed(damage)
signal summon_requested

var display_name := "Brask Noll"
var max_health := 360
var health := 360
var attack_damage := 20
var move_speed := 135.0
var target: Node2D
var phase_two := false
var stunned_timer := 0.0
var action_timer := 1.0
var active_move := "axe_swing"
var telegraph_timer := 0.0
var charge_velocity := 0.0
var hurt_flash := 0.0

func setup(profile: Dictionary) -> void:
	display_name = profile.get("name", display_name)
	max_health = int(profile.get("max_health", max_health))
	health = max_health
	attack_damage = int(profile.get("attack_damage", attack_damage))
	move_speed = float(profile.get("move_speed", move_speed))
	queue_redraw()

func _physics_process(delta: float) -> void:
	if health <= 0 or target == null:
		return
	hurt_flash = maxf(hurt_flash - delta, 0.0)
	stunned_timer = maxf(stunned_timer - delta, 0.0)
	if stunned_timer > 0.0:
		queue_redraw()
		return
	if telegraph_timer > 0.0:
		telegraph_timer -= delta
		if active_move == "charge":
			position.x += charge_velocity * delta
			if position.x <= 105.0 or position.x >= 1175.0:
				stunned_timer = 1.2
				telegraph_timer = 0.0
				charge_velocity = 0.0
		elif telegraph_timer <= 0.0:
			if active_move == "summon_grunts":
				summon_requested.emit()
			elif position.distance_to(target.position) < 120.0:
				attack_landed.emit(attack_damage + (6 if phase_two else 0))
		z_index = int(position.y)
		queue_redraw()
		return

	action_timer -= delta
	if action_timer <= 0.0:
		_pick_next_move()
		return

	var offset := target.position - position
	if offset.length() > 96.0:
		velocity = offset.normalized() * move_speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	z_index = int(position.y)
	queue_redraw()

func _pick_next_move() -> void:
	var moves := ["axe_swing", "ground_slam", "charge", "summon_grunts"]
	if phase_two:
		moves.append("double_swing")
	active_move = moves[randi() % moves.size()]
	telegraph_timer = 0.55 if active_move != "charge" else 0.95
	if active_move == "charge":
		charge_velocity = sign(target.position.x - position.x) * 520.0
	action_timer = 1.2 if phase_two else 1.55

func body_rect() -> Rect2:
	return Rect2(position - Vector2(42, 82), Vector2(84, 82))

func apply_damage(amount: int, source_x: float) -> void:
	if stunned_timer > 0.0:
		amount += 8
	health = max(health - amount, 0)
	position.x += sign(position.x - source_x) * 12.0
	hurt_flash = 0.12
	if not phase_two and health <= int(max_health * 0.5):
		phase_two = true
		action_timer = 0.25
	if health <= 0:
		defeated.emit()
		queue_free()
	queue_redraw()

func _draw() -> void:
	var color := Color(0.22, 0.22, 0.24) if hurt_flash <= 0.0 else Color(1.0, 0.86, 0.42)
	draw_rect(Rect2(Vector2(-42, -82), Vector2(84, 82)), color)
	draw_rect(Rect2(Vector2(-28, -100), Vector2(56, 18)), Color(0.07, 0.06, 0.06))
	draw_rect(Rect2(Vector2(22, -68), Vector2(58, 12)), Color(0.66, 0.66, 0.7))
	if telegraph_timer > 0.0:
		var danger := Color(1.0, 0.1, 0.04, 0.28)
		draw_rect(Rect2(Vector2(-72, -92), Vector2(144, 96)), danger)
	if stunned_timer > 0.0:
		draw_circle(Vector2(0, -112), 16.0, Color(0.8, 0.92, 1.0, 0.6))
