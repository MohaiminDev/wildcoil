extends CharacterBody2D
class_name BossBraskNoll

signal defeated
signal attack_landed(damage)
signal summon_requested
signal move_telegraphed(move_name)
signal phase_changed

const VisualAssetLoader := preload("res://scripts/visual_asset_loader.gd")

var display_name := "Brask Noll"
var boss_id := "brask_noll"
var palette := "steel_red"
var arena_hazard := "collapsing_overpass"
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
var animation_time := 0.0
var visual_sprites := {}

func setup(profile: Dictionary) -> void:
	boss_id = profile.get("id", boss_id)
	display_name = profile.get("name", display_name)
	palette = profile.get("palette", palette)
	arena_hazard = profile.get("arena_hazard", arena_hazard)
	max_health = int(profile.get("max_health", max_health))
	health = max_health
	attack_damage = int(profile.get("attack_damage", attack_damage))
	move_speed = float(profile.get("move_speed", move_speed))
	_load_visual_sprites()
	queue_redraw()

func _physics_process(delta: float) -> void:
	animation_time += delta
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
	move_telegraphed.emit(active_move)

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
		phase_changed.emit()
	if health <= 0:
		defeated.emit()
		queue_free()
	queue_redraw()

func _draw() -> void:
	var color := _boss_color() if hurt_flash <= 0.0 else Color(1.0, 0.86, 0.42)
	_draw_contact_shadow()
	_draw_cinematic_afterimage(color)
	if not _draw_visual_sprite(color):
		draw_line(Vector2(-18, -35), Vector2(-30, 0), Color(0.06, 0.06, 0.07), 12.0)
		draw_line(Vector2(18, -35), Vector2(30, 0), Color(0.06, 0.06, 0.07), 12.0)
		draw_polygon([Vector2(-48, -88), Vector2(44, -90), Vector2(58, -36), Vector2(33, -18), Vector2(-38, -18), Vector2(-58, -42)], [color])
		draw_rect(Rect2(Vector2(-31, -104), Vector2(62, 21)), Color(0.07, 0.06, 0.06))
		draw_rect(Rect2(Vector2(-21, -98), Vector2(42, 5)), Color(1.0, 0.72, 0.18))
		draw_line(Vector2(-42, -72), Vector2(-78, -38), Color(0.46, 0.47, 0.5), 10.0)
		_draw_hydraulic_axe()
		_draw_boss_signature()
		_draw_boss_portrait_read()
	if telegraph_timer > 0.0:
		_draw_move_telegraph()
	if stunned_timer > 0.0:
		draw_circle(Vector2(0, -112), 16.0, Color(0.8, 0.92, 1.0, 0.6))
	_draw_boss_motion_details()

func _load_visual_sprites() -> void:
	visual_sprites.clear()
	var loader := VisualAssetLoader.new()
	for state in ["idle", "attack", "hurt"]:
		var texture := loader.actor_texture("brask_noll", state)
		if texture != null:
			visual_sprites[state] = texture

func _draw_visual_sprite(modulate_color: Color) -> bool:
	var state := _current_visual_sprite_state()
	var texture: Texture2D = visual_sprites.get(state, visual_sprites.get("idle", null))
	if texture == null:
		return false
	var target_size := Vector2(292, 292)
	var bob := sin(animation_time * 4.8) * 2.0
	if telegraph_timer > 0.0:
		bob += sin(animation_time * 28.0) * 2.5
	var draw_pos := Vector2(-target_size.x * 0.5, -target_size.y + 14 + bob)
	var facing := -1.0
	if target != null and target.position.x > position.x:
		facing = 1.0
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1.0))
	draw_texture_rect(texture, Rect2(draw_pos, target_size), false, modulate_color)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	return true

func _current_visual_sprite_state() -> String:
	if hurt_flash > 0.0:
		return "hurt"
	if telegraph_timer > 0.0:
		return "attack"
	return "idle"

func _motion_frame(rate: float = 8.0, frames: int = 4) -> int:
	return int(floor(animation_time * rate)) % maxi(frames, 1)

func _draw_contact_shadow() -> void:
	var width := 60.0
	if active_move == "charge" and telegraph_timer > 0.0:
		width = 76.0
	elif stunned_timer > 0.0:
		width = 68.0
	_draw_flat_ellipse(Vector2(0, -2), Vector2(width, 10), Color(0, 0, 0, 0.32))

func _draw_cinematic_afterimage(modulate_color: Color) -> void:
	if telegraph_timer <= 0.0 and charge_velocity == 0.0 and hurt_flash <= 0.0:
		return
	var texture: Texture2D = visual_sprites.get(_current_visual_sprite_state(), visual_sprites.get("idle", null))
	if texture == null:
		return
	var target_size := Vector2(292, 292)
	var facing := _boss_facing()
	var tint := Color(modulate_color.r, modulate_color.g, modulate_color.b, 0.18)
	if active_move == "charge":
		tint = Color(1.0, 0.34, 0.12, 0.20)
	elif hurt_flash > 0.0:
		tint = Color(1.0, 0.92, 0.56, 0.22)
	for i in range(3):
		var offset := -facing * float(i + 1) * (18.0 if active_move == "charge" else 10.0)
		var draw_pos := Vector2(-target_size.x * 0.5 + offset, -target_size.y + 14 + sin(animation_time * 4.8) * 1.2)
		var fade := 1.0 - float(i) * 0.28
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1.0))
		draw_texture_rect(texture, Rect2(draw_pos, target_size), false, Color(tint.r, tint.g, tint.b, tint.a * fade))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_boss_motion_details() -> void:
	var frame := _motion_frame(9.0, 4)
	if telegraph_timer > 0.0:
		var warning := Color(1.0, 0.38, 0.12, 0.22 + sin(animation_time * 18.0) * 0.08)
		draw_arc(Vector2(0, -70), 94.0 + float(frame) * 5.0, -0.15, PI + 0.2, 28, warning, 7.0)
		draw_line(Vector2(-78, -20), Vector2(78, -24), Color(1.0, 0.68, 0.18, 0.30), 4.0)
	if phase_two:
		draw_arc(Vector2(0, -74), 118.0, 0.0, TAU, 36, Color(1.0, 0.24, 0.10, 0.18), 5.0)
	if stunned_timer > 0.0:
		for i in range(3):
			draw_circle(Vector2(-26.0 + float(i) * 26.0, -128.0 - float(frame)), 4.0, Color(0.72, 0.92, 1.0, 0.65))

func _boss_facing() -> float:
	if target != null and target.position.x > position.x:
		return 1.0
	return -1.0

func _boss_color() -> Color:
	match palette:
		"crystal_green":
			return Color(0.18, 0.55, 0.36)
		"market_violet":
			return Color(0.42, 0.16, 0.58)
		"rail_iron":
			return Color(0.25, 0.27, 0.32)
		"ash_exoframe":
			return Color(0.45, 0.16, 0.09)
		"storm_lab":
			return Color(0.20, 0.22, 0.48)
		"underroot_blue":
			return Color(0.11, 0.38, 0.52)
		"gold_luma":
			return Color(0.62, 0.46, 0.12)
		_:
			return Color(0.22, 0.22, 0.24)

func _draw_boss_signature() -> void:
	match boss_id:
		"glassback":
			for i in range(5):
				draw_polygon([Vector2(-42 + i * 20, -92), Vector2(-30 + i * 20, -126), Vector2(-18 + i * 20, -92)], [Color(0.45, 1.0, 0.72, 0.85)])
		"sable_rin":
			draw_line(Vector2(-62, -70), Vector2(-116, -116), Color(0.9, 0.9, 0.94), 4.0)
			draw_line(Vector2(62, -70), Vector2(116, -116), Color(0.9, 0.9, 0.94), 4.0)
		"rail_maw":
			draw_rect(Rect2(Vector2(-70, -35), Vector2(140, 28)), Color(0.1, 0.1, 0.11))
			for i in range(5):
				draw_circle(Vector2(-52 + i * 26, -20), 8, Color(0.45, 0.45, 0.48))
		"vorrak":
			draw_rect(Rect2(Vector2(-72, -74), Vector2(34, 70)), Color(0.12, 0.12, 0.14))
			draw_rect(Rect2(Vector2(38, -74), Vector2(34, 70)), Color(0.12, 0.12, 0.14))
		"klade_mobile_lab":
			draw_rect(Rect2(Vector2(-66, -128), Vector2(132, 28)), Color(0.18, 0.9, 1.0, 0.55))
			draw_circle(Vector2(0, -114), 12, Color(1.0, 0.2, 0.9))
		"echo_queen":
			draw_polygon([Vector2(-52, -92), Vector2(0, -140), Vector2(52, -92)], [Color(0.22, 0.92, 1.0, 0.45)])
		"mara_deep_crown":
			draw_circle(Vector2(0, -122), 24, Color(1.0, 0.78, 0.25, 0.45))
			draw_line(Vector2(-92, -110), Vector2(92, -110), Color(1.0, 0.78, 0.25), 5.0)

func _draw_hydraulic_axe() -> void:
	draw_line(Vector2(35, -72), Vector2(92, -28), Color(0.62, 0.62, 0.66), 9.0)
	draw_rect(Rect2(Vector2(66, -78), Vector2(36, 16)), Color(0.3, 0.32, 0.35))
	draw_polygon([Vector2(96, -88), Vector2(130, -68), Vector2(95, -48)], [Color(0.82, 0.82, 0.86)])
	draw_polygon([Vector2(93, -86), Vector2(68, -68), Vector2(93, -50)], [Color(0.5, 0.52, 0.56)])
	draw_circle(Vector2(80, -70), 5, Color(1.0, 0.72, 0.18))

func _draw_move_telegraph() -> void:
	match active_move:
		"charge":
			draw_rect(Rect2(Vector2(-180, -72), Vector2(360, 66)), Color(1.0, 0.18, 0.08, 0.20))
			draw_line(Vector2(-155, -38), Vector2(155, -38), Color(1.0, 0.32, 0.15, 0.72), 7.0)
		"ground_slam":
			for radius in [42.0, 78.0, 114.0]:
				draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, Color(1.0, 0.58, 0.12, 0.36), 5.0)
		"summon_grunts":
			draw_circle(Vector2(-78, -46), 22.0, Color(0.25, 1.0, 0.7, 0.32))
			draw_circle(Vector2(78, -46), 22.0, Color(0.25, 1.0, 0.7, 0.32))
		"double_swing":
			draw_arc(Vector2(0, -58), 108.0, -2.8, 0.3, 24, Color(1.0, 0.2, 0.08, 0.45), 10.0)
			draw_arc(Vector2(0, -58), 88.0, -0.2, 2.9, 24, Color(1.0, 0.72, 0.12, 0.34), 7.0)
		_:
			draw_rect(Rect2(Vector2(-72, -92), Vector2(144, 96)), Color(1.0, 0.1, 0.04, 0.28))

func _draw_boss_portrait_read() -> void:
	var glow := Color(1.0, 0.72, 0.18, 0.42) if phase_two else Color(0.95, 0.95, 0.82, 0.24)
	draw_arc(Vector2(0, -72), 70.0, -0.2, PI + 0.2, 20, glow, 4.0)
	draw_circle(Vector2(-14, -96), 3.0, Color(1.0, 0.78, 0.18))
	draw_circle(Vector2(14, -96), 3.0, Color(1.0, 0.78, 0.18))

func _draw_flat_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := []
	for i in range(24):
		var angle := TAU * float(i) / 24.0
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	draw_polygon(points, [color])
