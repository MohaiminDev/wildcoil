extends CharacterBody2D
class_name EnemyActor

signal defeated(enemy)
signal attack_landed(enemy, damage)

const VisualAssetLoader := preload("res://scripts/visual_asset_loader.gd")
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
var attack_recover_timer := 0.0
var flinch_timer := 0.0
var defeat_timer := 0.0
var hurt_flash := 0.0
var behavior_phase := 0.0
var facing := -1
var combat_state := "idle"
var attack_has_landed := false
var visual_sprites := {}
var arcade_slot_index := 0
var arcade_slot_count := 1
var cinematic_entry_active := false
var cinematic_entry_target := Vector2.ZERO
var cinematic_entry_speed := 0.0

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
	_load_visual_sprites()
	queue_redraw()

func configure_arcade_slot(index: int, total: int) -> void:
	arcade_slot_index = index
	arcade_slot_count = maxi(total, 1)

func start_cinematic_entry(target_position: Vector2, entry_speed: float) -> void:
	cinematic_entry_target = target_position
	cinematic_entry_speed = maxf(entry_speed, move_speed)
	cinematic_entry_active = true
	attack_cooldown = maxf(attack_cooldown, 1.35 if behavior == "reference_melee" else 0.9)

func _physics_process(delta: float) -> void:
	if defeat_timer > 0.0:
		defeat_timer = maxf(defeat_timer - delta, 0.0)
		combat_state = "defeated"
		velocity = Vector2.ZERO
		if defeat_timer <= 0.0:
			queue_free()
		queue_redraw()
		return
	if health <= 0 or target == null:
		return
	hurt_flash = maxf(hurt_flash - delta, 0.0)
	attack_cooldown = maxf(attack_cooldown - delta, 0.0)
	attack_recover_timer = maxf(attack_recover_timer - delta, 0.0)
	behavior_phase += delta

	if cinematic_entry_active:
		combat_state = "approach"
		_tick_cinematic_entry(delta)
		move_and_slide()
		z_index = int(position.y)
		queue_redraw()
		return

	var direct_offset := target.position - position
	var distance := direct_offset.length()
	if absf(direct_offset.x) > 2.0:
		facing = sign(direct_offset.x)
	var movement_offset := _arcade_engagement_offset(direct_offset)
	if flinch_timer > 0.0:
		flinch_timer = maxf(flinch_timer - delta, 0.0)
		combat_state = "flinch"
		velocity = Vector2(sign(position.x - target.position.x) * move_speed * 0.42, 0.0)
	elif attack_recover_timer > 0.0:
		combat_state = "recover"
		velocity = Vector2(-float(facing) * move_speed * 0.18, sin(behavior_phase * 8.0) * move_speed * 0.08)
	elif telegraph_timer > 0.0:
		telegraph_timer -= delta
		combat_state = "telegraph"
		if telegraph_timer <= 0.0 and distance <= attack_range + 18.0 and not attack_has_landed:
			combat_state = "attack"
			attack_has_landed = true
			attack_landed.emit(self, attack_damage)
			attack_recover_timer = 0.42
		velocity = Vector2.ZERO
	else:
		_apply_behavior_movement(movement_offset, distance, delta)
		if attack_cooldown <= 0.0 and _can_start_attack(distance):
			telegraph_timer = telegraph_seconds
			attack_has_landed = false
			combat_state = "telegraph"
			attack_cooldown = _attack_recovery_cooldown()

	move_and_slide()
	z_index = int(position.y)
	queue_redraw()

func _tick_cinematic_entry(_delta: float) -> void:
	var offset: Vector2 = cinematic_entry_target - position
	if absf(offset.x) > 2.0:
		facing = sign(offset.x)
	if offset.length() <= 10.0:
		position = cinematic_entry_target
		velocity = Vector2.ZERO
		cinematic_entry_active = false
		return
	var weave := Vector2(0.0, sin(behavior_phase * 10.0 + float(arcade_slot_index)) * 18.0)
	velocity = (offset + weave).normalized() * cinematic_entry_speed

func body_rect() -> Rect2:
	return Rect2(position - Vector2(BODY_SIZE.x * 0.5, BODY_SIZE.y), BODY_SIZE)

func attack_rect() -> Rect2:
	var width := attack_range + 18.0
	var height := 62.0
	if enemy_id == "iron_veil_brute":
		width += 18.0
		height += 16.0
	var origin_x := position.x + 16.0 if facing >= 0 else position.x - width - 16.0
	return Rect2(Vector2(origin_x, position.y - 68.0), Vector2(width, height))

func apply_damage(amount: int, source_x: float) -> void:
	if defeat_timer > 0.0 or health <= 0:
		return
	health = max(health - amount, 0)
	position.x += sign(position.x - source_x) * 24.0
	hurt_flash = 0.18
	flinch_timer = 0.26
	telegraph_timer = 0.0
	attack_recover_timer = maxf(attack_recover_timer, 0.16)
	combat_state = "flinch"
	if health <= 0:
		combat_state = "defeated"
		defeat_timer = 0.28
		defeated.emit(self)
	queue_redraw()

func _draw() -> void:
	_draw_contact_shadow()
	_draw_cinematic_afterimage()
	if not _draw_visual_sprite():
		_draw_sprite_outline()
		if species == "machine":
			_draw_machine_enemy()
		elif species == "creature":
			_draw_creature_enemy()
		else:
			_draw_human_enemy()
	elif telegraph_timer > 0.0:
		draw_rect(Rect2(Vector2(-31, -86), Vector2(62, 88)), Color(1.0, 0.08, 0.04, 0.22))
	_draw_luma_highlight()
	_draw_enemy_motion_details()

func _load_visual_sprites() -> void:
	visual_sprites.clear()
	var loader := VisualAssetLoader.new()
	for state in ["idle", "walk", "attack", "hurt"]:
		var texture := loader.actor_texture(enemy_id, state)
		if texture != null:
			visual_sprites[state] = texture

func _draw_visual_sprite() -> bool:
	var state := _current_visual_sprite_state()
	var texture: Texture2D = visual_sprites.get(state, visual_sprites.get("idle", null))
	if texture == null:
		return false
	var target_size := _visual_target_size()
	var bob := sin(behavior_phase * _visual_motion_speed()) * _visual_motion_amount()
	var attack_lunge := 10.0 if telegraph_timer > 0.0 else 0.0
	var draw_pos := Vector2(-target_size.x * 0.5 + attack_lunge, -target_size.y + 7 + bob)
	var tint := Color.WHITE
	if hurt_flash > 0.0:
		tint = Color(1.0, 0.86, 0.62, 1.0)
	var squash := _visual_squash_scale()
	draw_set_transform(Vector2.ZERO, _visual_tilt(), Vector2(float(facing) * squash.x, squash.y))
	draw_texture_rect(texture, Rect2(draw_pos, target_size), false, tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	return true

func _visual_squash_scale() -> Vector2:
	if hurt_flash > 0.0:
		return Vector2(1.10, 0.92)
	if telegraph_timer > 0.0:
		return Vector2(1.08, 0.95)
	if velocity.length() > 8.0:
		var walk := absf(sin(behavior_phase * _visual_motion_speed()))
		return Vector2(1.0 + walk * 0.035, 1.0 - walk * 0.025)
	return Vector2(1.0, 1.0 + sin(behavior_phase * 3.0) * 0.012)

func _visual_tilt() -> float:
	if hurt_flash > 0.0:
		return deg_to_rad(5.0 * float(facing))
	if telegraph_timer > 0.0:
		return deg_to_rad(-4.0 * float(facing))
	if velocity.length() > 8.0:
		return deg_to_rad(sin(behavior_phase * 7.0) * 1.2 * float(facing))
	return 0.0

func _visual_target_size() -> Vector2:
	match enemy_id:
		"iron_veil_runner":
			return Vector2(148, 224)
		"iron_veil_brute":
			return Vector2(224, 270)
		"scrap_hurler":
			return Vector2(164, 210)
		"frightened_raptorling":
			return Vector2(150, 130)
		"hornbeak_dinosaur":
			return Vector2(238, 196)
		_:
			return Vector2(158, 188)

func _visual_motion_amount() -> float:
	if species == "creature":
		return 3.5
	if enemy_id == "iron_veil_brute":
		return 1.4
	return 2.2

func _visual_motion_speed() -> float:
	if species == "creature":
		return 8.0
	if enemy_id == "iron_veil_brute":
		return 4.0
	return 6.0

func _motion_frame(rate: float = 9.0, frames: int = 4) -> int:
	return int(floor(behavior_phase * rate)) % maxi(frames, 1)

func _current_visual_sprite_state() -> String:
	if hurt_flash > 0.0:
		return "hurt"
	if telegraph_timer > 0.0:
		return "attack"
	if velocity.length() > 8.0:
		return "walk"
	return "idle"

func _draw_contact_shadow() -> void:
	var base_width := 27.0
	if enemy_id == "iron_veil_brute":
		base_width = 42.0
	elif species == "creature":
		base_width = 38.0
	var pulse := 1.0
	if velocity.length() > 8.0:
		pulse += absf(sin(behavior_phase * _visual_motion_speed())) * 0.10
	if telegraph_timer > 0.0:
		pulse += 0.16
	_draw_flat_ellipse(Vector2(0, -2), Vector2(base_width * pulse, 7), Color(0.0, 0.0, 0.0, 0.30))

func _draw_cinematic_afterimage() -> void:
	if not cinematic_entry_active and telegraph_timer <= 0.0 and hurt_flash <= 0.0:
		return
	var texture: Texture2D = visual_sprites.get(_current_visual_sprite_state(), visual_sprites.get("idle", null))
	if texture == null:
		return
	var target_size := _visual_target_size()
	var tint := Color(1.0, 0.42, 0.20, 0.14)
	if species == "creature":
		tint = Color(0.28, 1.0, 0.68, 0.12)
	elif hurt_flash > 0.0:
		tint = Color(1.0, 0.94, 0.55, 0.18)
	for i in range(2):
		var offset := -float(facing) * float(i + 1) * (18.0 if cinematic_entry_active else 11.0)
		var bob := sin(behavior_phase * _visual_motion_speed()) * _visual_motion_amount() * 0.45
		var draw_pos := Vector2(-target_size.x * 0.5 + offset, -target_size.y + 7 + bob)
		var fade := 1.0 - float(i) * 0.35
		draw_texture_rect(texture, Rect2(draw_pos, target_size), false, Color(tint.r, tint.g, tint.b, tint.a * fade))

func _draw_enemy_motion_details() -> void:
	var frame := _motion_frame(10.0, 4)
	if velocity.length() > 8.0:
		for i in range(2):
			var y := -2.0 - float(i) * 2.0
			draw_line(Vector2(-float(facing) * (18.0 + float(frame) * 2.0), y), Vector2(-float(facing) * 44.0, y - 5.0), Color(0.86, 0.62, 0.34, 0.22), 2.0)
	if telegraph_timer > 0.0:
		var warning := Color(1.0, 0.18, 0.08, 0.30 + sin(behavior_phase * 22.0) * 0.08)
		draw_arc(Vector2(0, -48), 42.0 + float(frame) * 3.0, -0.35, PI + 0.35, 20, warning, 4.0)
		draw_line(Vector2(float(facing) * 18.0, -60.0), Vector2(float(facing) * 64.0, -38.0), Color(1.0, 0.72, 0.24, 0.48), 3.0)
	if hurt_flash > 0.0:
		draw_circle(Vector2(0, -58), 26.0 + float(frame) * 2.0, Color(1.0, 0.9, 0.45, 0.16))

func _draw_sprite_outline() -> void:
	var outline := Color(0.02, 0.015, 0.012, 0.92)
	if species == "creature":
		draw_circle(Vector2(0, -38), 34, outline)
		draw_line(Vector2(-20, -18), Vector2(-28, 2), outline, 9.0)
		draw_line(Vector2(18, -18), Vector2(24, 2), outline, 9.0)
	elif species == "machine":
		draw_circle(Vector2(0, -37), 30, outline)
	else:
		draw_circle(Vector2(0, -64), 17, outline)
		draw_rect(Rect2(Vector2(-20, -58), Vector2(40, 44)), outline)

func _draw_luma_highlight() -> void:
	var highlight := Color(0.25, 1.0, 0.72, 0.45)
	if species == "machine" or enemy_id == "crystal_leech" or enemy_id == "echo_raptor":
		draw_circle(Vector2(0, -38), 14, highlight)

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
	_draw_humanoid_limb_outline(scale_boost)
	draw_polygon([
		Vector2(-16 * scale_boost, -58 * scale_boost),
		Vector2(14 * scale_boost, -61 * scale_boost),
		Vector2(23 * scale_boost, -26 * scale_boost),
		Vector2(9 * scale_boost, -15 * scale_boost),
		Vector2(-17 * scale_boost, -18 * scale_boost),
		Vector2(-24 * scale_boost, -36 * scale_boost)
	], [color])
	_draw_human_armor_panels(scale_boost, color)
	_draw_enemy_flinch_pose(scale_boost)
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
	_draw_behavior_weapon()

func _draw_humanoid_limb_outline(scale_boost: float) -> void:
	var outline := Color(0.02, 0.015, 0.012, 0.94)
	var boot := Color(0.04, 0.04, 0.045)
	draw_line(Vector2(-11 * scale_boost, -25 * scale_boost), Vector2(-25 * scale_boost, -1), outline, 11.0 * scale_boost)
	draw_line(Vector2(10 * scale_boost, -25 * scale_boost), Vector2(24 * scale_boost, -1), outline, 11.0 * scale_boost)
	draw_line(Vector2(-17 * scale_boost, -48 * scale_boost), Vector2(-40 * scale_boost, -31 * scale_boost), outline, 10.0 * scale_boost)
	draw_line(Vector2(17 * scale_boost, -48 * scale_boost), Vector2(38 * scale_boost, -35 * scale_boost), outline, 10.0 * scale_boost)
	draw_circle(Vector2(0, -68 * scale_boost), 15.0 * scale_boost, outline)
	draw_rect(Rect2(Vector2(-28 * scale_boost, -5), Vector2(20 * scale_boost, 7)), boot)
	draw_rect(Rect2(Vector2(8 * scale_boost, -5), Vector2(20 * scale_boost, 7)), boot)

func _draw_human_armor_panels(scale_boost: float, base_color: Color) -> void:
	var armor_shadow := base_color.darkened(0.34)
	var armor_light := base_color.lightened(0.24)
	draw_line(Vector2(-15 * scale_boost, -51 * scale_boost), Vector2(16 * scale_boost, -55 * scale_boost), armor_light, 4.0 * scale_boost)
	draw_rect(Rect2(Vector2(-9 * scale_boost, -49 * scale_boost), Vector2(18 * scale_boost, 16 * scale_boost)), armor_light)
	draw_rect(Rect2(Vector2(-16 * scale_boost, -30 * scale_boost), Vector2(30 * scale_boost, 7 * scale_boost)), armor_shadow)
	draw_rect(Rect2(Vector2(-12 * scale_boost, -83 * scale_boost), Vector2(24 * scale_boost, 18 * scale_boost)), Color(0.06, 0.06, 0.07))
	var helmet_eye_slit := Rect2(Vector2(-8 * scale_boost, -77 * scale_boost), Vector2(16 * scale_boost, 4 * scale_boost))
	draw_rect(helmet_eye_slit, Color(1.0, 0.7, 0.22))
	draw_circle(Vector2(0, -62 * scale_boost), 4.0 * scale_boost, Color(0.22, 1.0, 0.66, 0.68))

func _draw_enemy_flinch_pose(scale_boost: float) -> void:
	if hurt_flash <= 0.0:
		return
	var spark := Color(1.0, 0.96, 0.56, 0.82)
	draw_line(Vector2(-29 * scale_boost, -70 * scale_boost), Vector2(-48 * scale_boost, -88 * scale_boost), spark, 3.0)
	draw_line(Vector2(28 * scale_boost, -68 * scale_boost), Vector2(46 * scale_boost, -84 * scale_boost), spark, 3.0)
	draw_arc(Vector2(0, -48 * scale_boost), 36.0 * scale_boost, -0.4, PI + 0.4, 18, spark, 3.0)

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
	_draw_behavior_weapon()

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
	_draw_behavior_weapon()

func _arcade_engagement_offset(direct_offset: Vector2) -> Vector2:
	var side: float = sign(position.x - target.position.x)
	if side == 0:
		side = 1
	var lane_index: float = float(arcade_slot_index) - float(arcade_slot_count - 1) * 0.5
	var desired_x: float = side * (attack_range - 8.0 + absf(lane_index) * 24.0)
	var desired_y: float = lane_index * 36.0
	if behavior == "ranged_thrower":
		desired_x = side * maxf(attack_range - 10.0, 118.0)
	if behavior == "territorial_charge" or species == "creature":
		desired_y *= 0.65
	var desired_position := target.position + Vector2(desired_x, desired_y)
	return desired_position - position

func _apply_behavior_movement(offset: Vector2, direct_distance: float, _delta: float) -> void:
	var distance := offset.length()
	if distance <= 0.01:
		velocity = Vector2.ZERO
		return
	var direction := offset.normalized()
	match behavior:
		"ranged_thrower":
			if direct_distance < 135.0:
				velocity = -direction * move_speed * 0.82
				combat_state = "spacing"
			elif distance > 18.0:
				velocity = direction * move_speed * 0.72
				combat_state = "approach"
			else:
				velocity = Vector2(0, sin(behavior_phase * 3.0) * move_speed * 0.25)
				combat_state = "spacing"
		"territorial_charge":
			if distance > 18.0:
				velocity = direction * move_speed * 1.18
				combat_state = "approach"
			else:
				velocity = Vector2.ZERO
				combat_state = "spacing"
		"fast_melee", "panicked_nearest_target", "sound_reactive":
			if distance > 18.0:
				var weave := Vector2(-direction.y, direction.x) * sin(behavior_phase * 5.5) * 0.38
				velocity = (direction + weave).normalized() * move_speed
				combat_state = "approach"
			else:
				velocity = Vector2.ZERO
				combat_state = "spacing"
		"front_blocker", "slow_grabber", "armored_biter":
			if distance > 18.0:
				velocity = direction * move_speed * 0.74
				combat_state = "approach"
			else:
				velocity = Vector2.ZERO
				combat_state = "spacing"
		_:
			if distance > 18.0:
				velocity = direction * move_speed
				combat_state = "approach"
			else:
				velocity = Vector2.ZERO
				combat_state = "spacing"

func _can_start_attack(distance: float) -> bool:
	if behavior == "ranged_thrower" or behavior == "summoner":
		return distance <= attack_range + 35.0
	return distance <= attack_range + 16.0 and absf(target.position.y - position.y) <= 54.0

func _attack_recovery_cooldown() -> float:
	if behavior == "ranged_thrower":
		return 1.28
	if behavior == "reference_melee":
		return 1.45
	return 1.1

func _draw_behavior_weapon() -> void:
	var weapon_color := Color(0.9, 0.88, 0.78, 0.92)
	match behavior:
		"ranged_thrower":
			draw_circle(Vector2(48 * facing, -48), 9, Color(0.72, 0.72, 0.76))
			draw_line(Vector2(8 * facing, -50), Vector2(48 * facing, -48), weapon_color, 3.0)
		"front_blocker":
			draw_rect(Rect2(Vector2(22 * facing - 9, -66), Vector2(18, 56)), Color(0.75, 0.78, 0.82, 0.9))
		"territorial_charge":
			draw_line(Vector2(40 * facing, -56), Vector2(82 * facing, -50), Color(1.0, 0.88, 0.32), 6.0)
		"skittering_machine", "summoner", "creature_support":
			draw_circle(Vector2(34 * facing, -42), 12, Color(0.25, 1.0, 0.72, 0.72))
		_:
			draw_line(Vector2(18 * facing, -50), Vector2(48 * facing, -35), weapon_color, 4.0)

func _draw_flat_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := []
	for i in range(24):
		var angle := TAU * float(i) / 24.0
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	draw_polygon(points, [color])
