extends SceneTree

const STAGE_SCENE := preload("res://scenes/stages/sunset_overpass.tscn")
const BOSS_CAPTURE_ID := "brask_noll"

var stage
var frame_count := 0
var output_path := "res://stage1_capture.png"
var capture_hero_id := "raya_flint"
var capture_mode := "wave"
var capture_requested := false

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		output_path = str(args[0])
	if args.size() > 1:
		capture_hero_id = _normalized_hero_id(str(args[1]))
	if args.size() > 2:
		capture_mode = str(args[2])
	root.size = Vector2i(1280, 720)
	stage = STAGE_SCENE.instantiate()
	stage.hero_id = capture_hero_id
	stage.stage_id = "sunset_overpass"
	root.add_child(stage)

func _process(_delta: float) -> bool:
	frame_count += 1
	if frame_count == 45 and capture_mode != "banner":
		_arrange_capture_scene()
	var target_capture_frame := 35 if capture_mode == "banner" else 52 if capture_mode == "impact" else 90
	if frame_count >= target_capture_frame and not capture_requested:
		capture_requested = true
		_save_capture()
	return false

func _save_capture() -> void:
	await process_frame
	var viewport_texture := root.get_texture()
	if viewport_texture == null:
		push_error("Unable to capture Stage 1 screenshot: root viewport has no texture.")
		quit(1)
		return
	var image := viewport_texture.get_image()
	if image == null:
		push_error("Unable to capture Stage 1 screenshot: root viewport image is null.")
		quit(1)
		return
	image.save_png(output_path)
	if stage != null and is_instance_valid(stage):
		stage.queue_free()
	await process_frame
	quit()

func _arrange_capture_scene() -> void:
	if stage == null or not is_instance_valid(stage):
		return
	if capture_mode == "impact":
		_arrange_impact_capture_scene()
		return
	if capture_mode == "boss":
		_arrange_boss_capture_scene()
		return
	_arrange_wave_capture_scene()

func _arrange_wave_capture_scene() -> void:
	if stage.player != null:
		stage.player.position = Vector2(350, 520)
		stage.player.facing = 1
		stage.player.attack_timer = 0.0
		stage.player.velocity = Vector2.ZERO
		stage.player.set_physics_process(false)
	if stage.hud != null:
		stage.hud.show_notice("")
	if stage.combat_fx != null:
		for child in stage.combat_fx.get_children():
			child.queue_free()
	for index in range(stage.enemies.size()):
		var enemy = stage.enemies[index]
		if enemy == null or not is_instance_valid(enemy):
			continue
		enemy.position = Vector2(560 + index * 118, 514 + (index % 2) * 24)
		enemy.facing = -1
		enemy.velocity = Vector2.ZERO
		enemy.telegraph_timer = 0.0
		enemy.target = null
		enemy.set_physics_process(false)

func _arrange_impact_capture_scene() -> void:
	var target_enemy = _isolate_first_capture_enemy()
	if stage.player != null:
		stage.player.position = Vector2(350, 520)
		stage.player.facing = 1
		stage.player.attack_step = 2
		stage.player.attack_timer = 0.18
		stage.player.attack_lunge_timer = 0.06
		stage.player.combo_count = 3
		stage.player.combo_timer = 1.1
		stage.player.velocity = Vector2.ZERO
		stage.player.set_physics_process(false)
	if target_enemy != null and is_instance_valid(target_enemy):
		target_enemy.position = Vector2(474, 520)
		target_enemy.facing = -1
		target_enemy.velocity = Vector2.ZERO
		target_enemy.hurt_flash = 0.18
		target_enemy.telegraph_timer = 0.0
		target_enemy.target = null
		target_enemy.set_physics_process(false)
	if stage.hud != null:
		stage.hud.show_notice("")
		stage.hud.update_objective("Impact proof: readable non-bloody hit feedback")
		stage.hud.update_player(stage.player)
	if stage.combat_fx != null and target_enemy != null and is_instance_valid(target_enemy):
		for child in stage.combat_fx.get_children():
			child.queue_free()
		var impact_world: Vector2 = target_enemy.position + Vector2(-10, -54)
		var impact_screen: Vector2 = stage.get_global_transform_with_canvas() * impact_world
		stage.combat_fx.spawn_attack_arc(stage.get_global_transform_with_canvas() * (stage.player.position + Vector2(48, -48)), 1)
		stage.combat_fx.spawn_hit_spark(impact_screen, Color(1.0, 0.78, 0.18), true)
		stage.combat_fx.spawn_impact_burst(impact_screen, 1, true)
		stage.combat_fx.spawn_damage_number(impact_screen, 31, 3)

func _arrange_boss_capture_scene() -> void:
	_clear_capture_enemies()
	if stage.has_method("_start_boss") and not stage.boss_started:
		stage._start_boss()
	if stage.player != null:
		stage.player.position = Vector2(330, 526)
		stage.player.facing = 1
		stage.player.attack_timer = 0.19
		stage.player.attack_lunge_timer = 0.06
		stage.player.special_timer = 0.0
		stage.player.special_meter = 74
		stage.player.velocity = Vector2.ZERO
		stage.player.set_physics_process(false)
	if stage.boss != null and is_instance_valid(stage.boss):
		stage.boss.position = Vector2(780, 526)
		stage.boss.target = stage.player
		stage.boss.active_move = "charge"
		stage.boss.telegraph_timer = 0.44
		stage.boss.charge_velocity = 0.0
		stage.boss.phase_two = true
		stage.boss.hurt_flash = 0.0
		stage.boss.set_physics_process(false)
	if stage.hud != null:
		stage.hud.show_notice("")
		stage.hud.update_objective("Defeat Brask Noll before he breaks the overpass")
		stage.hud.update_player(stage.player)
		stage.hud.update_boss(stage.boss)
	if stage.combat_fx != null:
		for child in stage.combat_fx.get_children():
			child.queue_free()

func _clear_capture_enemies() -> void:
	for enemy in stage.enemies:
		if enemy != null and is_instance_valid(enemy):
			enemy.queue_free()
	stage.enemies.clear()

func _isolate_first_capture_enemy():
	var kept_enemy = null
	for enemy in stage.enemies:
		if enemy == null or not is_instance_valid(enemy):
			continue
		if kept_enemy == null:
			kept_enemy = enemy
		else:
			enemy.queue_free()
	stage.enemies.clear()
	if kept_enemy != null and is_instance_valid(kept_enemy):
		stage.enemies.append(kept_enemy)
	return kept_enemy

func _normalized_hero_id(value: String) -> String:
	match value:
		"nika", "nika_sol":
			return "nika_sol"
		"raya", "raya_flint":
			return "raya_flint"
		_:
			return value
