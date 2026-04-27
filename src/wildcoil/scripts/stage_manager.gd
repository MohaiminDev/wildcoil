extends Node2D
class_name StageManager

signal stage_completed(text)
signal game_over

const PLAYER_SCENE := preload("res://scenes/player.tscn")
const BOSS_SCENE := preload("res://scenes/boss_brask_noll.tscn")
const StageBackdrop := preload("res://scripts/stage_backdrop.gd")
const ArcadeCombatFx := preload("res://scripts/arcade_combat_fx.gd")

var hero_id := "raya_flint"
var stage_id := "sunset_overpass"
var stage_data := {}
var character_profiles := {}
var boss_profiles := {}
var player
var hud
var debug_overlay
var pickup_manager
var wave_spawner
var combat_fx: ArcadeCombatFx
var enemies: Array = []
var boss
var wave_index := -1
var boss_started := false
var complete := false
var camera: Camera2D
var animated_art: Array = []
var stage_time := 0.0
var active_arena_markers: Array = []
var hit_registry := {}
var camera_punch_timer := 0.0
var camera_punch_strength := 0.0
var biome_palette := {
	"sky": Color(0.94, 0.46, 0.18),
	"road": Color(0.16, 0.15, 0.15),
	"accent": Color(0.2, 1.0, 0.58),
	"shadow": Color(0.09, 0.13, 0.14, 0.45)
}

func _ready() -> void:
	character_profiles = _load_profiles("res://data/characters.json", "heroes")
	boss_profiles = _load_profiles("res://data/bosses.json", "bosses")
	stage_data = _load_profiles("res://data/stages.json", "stages")[stage_id]
	_apply_biome_palette()
	_build_background()
	_build_player()
	_build_systems()
	_start_next_wave()

func _process(delta: float) -> void:
	stage_time += delta
	_animate_stage_art(delta)
	_tick_camera_punch(delta)
	if complete:
		return
	_handle_combat()
	pickup_manager.collect_near(player)
	hud.update_player(player)
	hud.update_boss(boss)
	debug_overlay.update_debug(player, _living_enemy_count(), "player + attack + enemy boxes")
	if _living_enemy_count() == 0 and not boss_started:
		_start_next_wave()
	if boss_started and (boss == null or not is_instance_valid(boss)) and not complete:
		complete = true
		hud.show_notice(stage_data["ending_cutscene"])
		_spawn_victory_banner(stage_data["ending_cutscene"])
		stage_completed.emit(stage_data["ending_cutscene"])

func _load_profiles(path: String, key: String) -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	var profiles := {}
	for item in parsed.get(key, []):
		profiles[item["id"]] = item
	return profiles

func _build_background() -> void:
	_build_arcade_backdrop()
	var road := ColorRect.new()
	road.color = biome_palette["road"]
	road.position = Vector2(0, 330)
	road.size = Vector2(1280, 300)
	add_child(road)
	for stripe in range(8):
		var lane := ColorRect.new()
		lane.color = biome_palette["accent"].lightened(0.35)
		lane.position = Vector2(70 + stripe * 160, 462)
		lane.size = Vector2(72, 7)
		add_child(lane)
	_build_sundrifter()
	_build_transport_cages()
	for j in range(10):
		var crystal := ColorRect.new()
		crystal.color = biome_palette["accent"]
		crystal.position = Vector2(70 + j * 125, 585 - (j % 3) * 20)
		crystal.size = Vector2(16, 42)
		add_child(crystal)
		animated_art.append({"node": crystal, "kind": "pulse", "base": crystal.position, "speed": 1.5 + j * 0.1, "amount": 8.0})

func _build_arcade_backdrop() -> void:
	var backdrop = StageBackdrop.new()
	backdrop.configure(stage_data, biome_palette)
	backdrop.z_index = -200
	add_child(backdrop)

func _apply_biome_palette() -> void:
	match stage_data.get("biome", "sunset_highway"):
		"blue_jungle":
			biome_palette = {"sky": Color(0.05, 0.16, 0.28), "road": Color(0.07, 0.18, 0.16), "accent": Color(0.25, 1.0, 0.78), "shadow": Color(0.03, 0.24, 0.16, 0.82)}
		"market_lanterns":
			biome_palette = {"sky": Color(0.18, 0.12, 0.25), "road": Color(0.21, 0.15, 0.12), "accent": Color(1.0, 0.58, 0.22), "shadow": Color(0.16, 0.09, 0.12, 0.82)}
		"crystal_canyon":
			biome_palette = {"sky": Color(0.18, 0.24, 0.4), "road": Color(0.10, 0.11, 0.16), "accent": Color(0.45, 0.82, 1.0), "shadow": Color(0.12, 0.10, 0.18, 0.82)}
		"volcanic_factory":
			biome_palette = {"sky": Color(0.55, 0.12, 0.08), "road": Color(0.12, 0.08, 0.07), "accent": Color(1.0, 0.28, 0.08), "shadow": Color(0.22, 0.12, 0.09, 0.86)}
		"storm_badlands":
			biome_palette = {"sky": Color(0.23, 0.18, 0.36), "road": Color(0.20, 0.15, 0.11), "accent": Color(0.72, 0.32, 1.0), "shadow": Color(0.11, 0.10, 0.16, 0.82)}
		"underground_roots":
			biome_palette = {"sky": Color(0.03, 0.08, 0.16), "road": Color(0.06, 0.10, 0.11), "accent": Color(0.22, 0.92, 1.0), "shadow": Color(0.02, 0.18, 0.22, 0.82)}
		"rift_citadel":
			biome_palette = {"sky": Color(0.10, 0.06, 0.16), "road": Color(0.11, 0.10, 0.15), "accent": Color(1.0, 0.76, 0.24), "shadow": Color(0.18, 0.14, 0.22, 0.88)}
		_:
			biome_palette = {"sky": Color(0.94, 0.46, 0.18), "road": Color(0.16, 0.15, 0.15), "accent": Color(0.2, 1.0, 0.58), "shadow": Color(0.09, 0.13, 0.14, 0.45)}

func _animate_stage_art(_delta: float) -> void:
	for item in animated_art:
		var node = item["node"]
		if node == null or not is_instance_valid(node):
			continue
		var kind: String = str(item["kind"])
		if kind == "drift":
			node.position.x = item["base"].x + sin(stage_time * item["speed"] + item.get("phase", 0.0)) * item["amount"]
		elif kind == "pulse":
			var glow := 0.65 + sin(stage_time * item["speed"]) * 0.25
			if node is CanvasItem:
				node.modulate = Color(1.0, 1.0, 1.0, glow)

func _build_sundrifter() -> void:
	var crawler := Node2D.new()
	crawler.name = "Sundrifter"
	crawler.position = Vector2(150, 315)
	add_child(crawler)
	var body := Polygon2D.new()
	body.polygon = PackedVector2Array([Vector2(-92, 20), Vector2(-54, -30), Vector2(64, -36), Vector2(105, 8), Vector2(82, 34), Vector2(-80, 35)])
	body.color = Color(0.88, 0.44, 0.16)
	crawler.add_child(body)
	var glass := ColorRect.new()
	glass.position = Vector2(-22, -24)
	glass.size = Vector2(48, 22)
	glass.color = Color(0.4, 0.9, 1.0, 0.72)
	crawler.add_child(glass)
	for wheel_x in [-64, 68]:
		var wheel := Polygon2D.new()
		wheel.polygon = _ellipse_points(Vector2(wheel_x, 38), Vector2(28, 28), 20)
		wheel.color = Color(0.05, 0.05, 0.06)
		crawler.add_child(wheel)
		var hub := Polygon2D.new()
		hub.polygon = _ellipse_points(Vector2(wheel_x, 38), Vector2(12, 12), 16)
		hub.color = Color(0.82, 0.78, 0.58)
		crawler.add_child(hub)
	animated_art.append({"node": crawler, "kind": "drift", "base": crawler.position, "speed": 0.9, "amount": 18.0})

func _build_transport_cages() -> void:
	for i in range(3):
		var cage := Node2D.new()
		cage.name = "TransportCage%d" % i
		cage.position = Vector2(760 + i * 92, 332)
		add_child(cage)
		var frame := ColorRect.new()
		frame.position = Vector2(-30, -46)
		frame.size = Vector2(60, 45)
		frame.color = Color(0.18, 0.18, 0.2, 0.82)
		cage.add_child(frame)
		for bar in range(4):
			var line := ColorRect.new()
			line.position = Vector2(-25 + bar * 16, -45)
			line.size = Vector2(4, 44)
			line.color = Color(0.72, 0.72, 0.76)
			cage.add_child(line)
		var eye := ColorRect.new()
		eye.position = Vector2(-5, -30)
		eye.size = Vector2(10, 5)
		eye.color = Color(0.2, 1.0, 0.55)
		cage.add_child(eye)
		animated_art.append({"node": eye, "kind": "pulse", "base": eye.position, "speed": 2.0 + i, "amount": 2.0})

func _build_background_dinosaurs() -> void:
	for i in range(3):
		var dino := Polygon2D.new()
		var x := 160 + i * 320
		var y := 255 + (i % 2) * 25
		dino.polygon = PackedVector2Array([
			Vector2(x - 52, y),
			Vector2(x + 10, y - 48),
			Vector2(x + 76, y - 20),
			Vector2(x + 42, y + 4),
			Vector2(x - 20, y + 8)
		])
		dino.color = Color(0.09, 0.13, 0.14, 0.45)
		add_child(dino)
		animated_art.append({"node": dino, "kind": "drift", "base": dino.position, "speed": 0.25 + i * 0.08, "amount": 20.0})

func _build_jungle_ruins() -> void:
	for i in range(9):
		var vine := ColorRect.new()
		vine.position = Vector2(35 + i * 138, 250)
		vine.size = Vector2(8, 160 + (i % 3) * 30)
		vine.color = Color(0.08, 0.42, 0.16, 0.72)
		add_child(vine)
		animated_art.append({"node": vine, "kind": "drift", "base": vine.position, "speed": 0.5 + i * 0.07, "amount": 4.0})
	for i in range(5):
		var sign := ColorRect.new()
		sign.position = Vector2(150 + i * 230, 300)
		sign.size = Vector2(70, 22)
		sign.color = Color(0.45, 0.22, 0.08)
		add_child(sign)

func _ellipse_points(center: Vector2, radius: Vector2, count: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in range(count):
		var angle := TAU * float(i) / float(count)
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	return points

func _build_player() -> void:
	player = PLAYER_SCENE.instantiate()
	player.setup(character_profiles[hero_id])
	player.position = Vector2(150, 520)
	player.defeated.connect(func(): game_over.emit())
	add_child(player)
	camera = Camera2D.new()
	camera.position_smoothing_enabled = true
	player.add_child(camera)
	camera.make_current()

func _build_systems() -> void:
	wave_spawner = load("res://scripts/wave_spawner.gd").new()
	add_child(wave_spawner)
	pickup_manager = load("res://scripts/pickup_manager.gd").new()
	add_child(pickup_manager)
	hud = load("res://scripts/hud_controller.gd").new()
	add_child(hud)
	combat_fx = ArcadeCombatFx.new()
	add_child(combat_fx)
	debug_overlay = load("res://scripts/debug_overlay.gd").new()
	add_child(debug_overlay)
	hud.show_notice(stage_data["opening_cutscene"])
	hud.update_objective(stage_data.get("scenario_goal", "Win the fight"))

func _start_next_wave() -> void:
	wave_index += 1
	var waves: Array = stage_data["waves"]
	if wave_index >= waves.size():
		_start_boss()
		return
	var wave: Dictionary = waves[wave_index]
	_build_arena_boundaries(float(wave["arena_x"]))
	enemies = wave_spawner.spawn_wave(self, wave["enemies"], player, float(wave["arena_x"]))
	for enemy in enemies:
		enemy.defeated.connect(_on_enemy_defeated)
		enemy.attack_landed.connect(_on_enemy_attack)
	_show_wave_objective(wave_index)

func _start_boss() -> void:
	boss_started = true
	_clear_arena_boundaries()
	boss = BOSS_SCENE.instantiate()
	boss.setup(boss_profiles[stage_data["boss_id"]])
	boss.position = Vector2(940, 500)
	boss.target = player
	boss.defeated.connect(_on_boss_defeated)
	boss.attack_landed.connect(func(amount): player.apply_damage(amount, boss.position.x))
	boss.summon_requested.connect(_summon_boss_grunts)
	add_child(boss)
	_show_boss_intro()

func _summon_boss_grunts() -> void:
	var adds: Array = wave_spawner.spawn_wave(self, ["iron_veil_grunt", "iron_veil_runner"], player, boss.position.x - 160.0)
	for enemy in adds:
		enemy.defeated.connect(_on_enemy_defeated)
		enemy.attack_landed.connect(_on_enemy_attack)
	enemies.append_array(adds)

func _handle_combat() -> void:
	if not player.is_attack_active() and not player.is_special_active():
		hit_registry.clear()
		return
	if player.is_attack_active() or player.is_special_active():
		combat_fx.spawn_attack_arc(_world_to_screen(player.position + Vector2(player.facing * 34, -48)), player.facing)
		for enemy in enemies.duplicate():
			if enemy != null and is_instance_valid(enemy) and player.attack_rect().intersects(enemy.body_rect()):
				var key := "enemy_%d" % enemy.get_instance_id()
				if hit_registry.has(key):
					continue
				hit_registry[key] = true
				var damage: int = player.special_damage if player.is_special_active() else player.current_attack_damage()
				enemy.apply_damage(damage, player.position.x)
				player.register_hit()
				_spawn_hit_feedback(enemy.position + Vector2(0, -46), damage, player.is_special_active())
		if boss != null and is_instance_valid(boss):
			var hit_rect: Rect2 = player.attack_rect()
			if player.is_special_active():
				hit_rect = Rect2(player.position - Vector2(84, 104), Vector2(168, 168))
			if hit_rect.intersects(boss.body_rect()):
				var boss_key := "boss_%d" % boss.get_instance_id()
				if hit_registry.has(boss_key):
					return
				hit_registry[boss_key] = true
				var boss_damage: int = player.special_damage if player.is_special_active() else player.current_attack_damage()
				boss.apply_damage(boss_damage, player.position.x)
				player.register_hit()
				_spawn_hit_feedback(boss.position + Vector2(0, -72), boss_damage, true)

func _on_enemy_defeated(enemy) -> void:
	player.score += enemy.score_value
	if randi() % 3 == 0:
		pickup_manager.spawn_pickup("glowfruit", enemy.position)

func _on_enemy_attack(enemy, amount: int) -> void:
	player.apply_damage(amount, enemy.position.x)
	combat_fx.spawn_hit_spark(_world_to_screen(player.position + Vector2(0, -48)), Color(1.0, 0.18, 0.08), false)
	_apply_camera_punch(4.0)

func _on_boss_defeated() -> void:
	player.score += 1500
	boss = null

func _living_enemy_count() -> int:
	var count := 0
	for enemy in enemies:
		if enemy != null and is_instance_valid(enemy):
			count += 1
	return count

func _show_wave_objective(next_wave_index: int) -> void:
	var objective: String = stage_data.get("scenario_goal", "Defeat the enemy wave")
	hud.update_objective("%s | Wave %d/%d" % [objective, next_wave_index + 1, stage_data["waves"].size()])
	hud.show_notice("%s\nWave %d" % [stage_data["title"], next_wave_index + 1])
	combat_fx.show_stage_card(stage_data["title"], objective, next_wave_index)

func _show_boss_intro() -> void:
	var boss_goal: String = stage_data.get("win_condition", "Defeat the boss")
	hud.update_objective(boss_goal)
	hud.show_notice("%s enters! %s" % [boss.display_name, boss_goal])
	combat_fx.show_boss_intro(boss.display_name, boss.arena_hazard)
	_apply_camera_punch(9.0)

func _spawn_hit_feedback(world_position: Vector2, damage: int, big: bool) -> void:
	var screen_position := _world_to_screen(world_position)
	combat_fx.spawn_hit_spark(screen_position, Color(1.0, 0.76, 0.18), big)
	combat_fx.spawn_damage_number(screen_position, damage, player.combo_count)
	_apply_camera_punch(7.0 if big else 3.0)

func _spawn_victory_banner(text: String) -> void:
	combat_fx.show_victory_banner(text)

func _world_to_screen(world_position: Vector2) -> Vector2:
	return get_global_transform_with_canvas() * world_position

func _apply_camera_punch(strength: float) -> void:
	camera_punch_timer = 0.16
	camera_punch_strength = maxf(camera_punch_strength, strength)

func _tick_camera_punch(delta: float) -> void:
	if camera == null:
		return
	if camera_punch_timer <= 0.0:
		camera.offset = Vector2.ZERO
		camera_punch_strength = 0.0
		return
	camera_punch_timer = maxf(camera_punch_timer - delta, 0.0)
	camera.offset = Vector2(randf_range(-camera_punch_strength, camera_punch_strength), randf_range(-camera_punch_strength, camera_punch_strength))

func _build_arena_boundaries(arena_x: float) -> void:
	_clear_arena_boundaries()
	for side in [-1, 1]:
		var marker := ColorRect.new()
		marker.color = Color(0.9, 0.28, 0.08, 0.35)
		marker.position = Vector2(arena_x + side * 250.0, 330)
		marker.size = Vector2(8, 290)
		add_child(marker)
		active_arena_markers.append(marker)
		var glow := ColorRect.new()
		glow.color = biome_palette["accent"].lightened(0.25)
		glow.position = marker.position + Vector2(-4, 0)
		glow.size = Vector2(16, 290)
		add_child(glow)
		active_arena_markers.append(glow)

func _clear_arena_boundaries() -> void:
	for marker in active_arena_markers:
		if marker != null and is_instance_valid(marker):
			marker.queue_free()
	active_arena_markers.clear()
