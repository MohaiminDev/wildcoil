extends Node2D
class_name StageManager

signal stage_completed(text)
signal game_over

const PLAYER_SCENE := preload("res://scenes/player.tscn")
const BOSS_SCENE := preload("res://scenes/boss_brask_noll.tscn")

var hero_id := "raya_flint"
var stage_data := {}
var character_profiles := {}
var boss_profiles := {}
var player
var hud
var debug_overlay
var pickup_manager
var wave_spawner
var enemies: Array = []
var boss
var wave_index := -1
var boss_started := false
var complete := false
var camera: Camera2D

func _ready() -> void:
	character_profiles = _load_profiles("res://data/characters.json", "heroes")
	boss_profiles = _load_profiles("res://data/bosses.json", "bosses")
	stage_data = _load_profiles("res://data/stages.json", "stages")["sunset_overpass"]
	_build_background()
	_build_player()
	_build_systems()
	_start_next_wave()

func _process(_delta: float) -> void:
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
		stage_completed.emit(stage_data["ending_cutscene"])

func _load_profiles(path: String, key: String) -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	var profiles := {}
	for item in parsed.get(key, []):
		profiles[item["id"]] = item
	return profiles

func _build_background() -> void:
	var sky := ColorRect.new()
	sky.color = Color(0.94, 0.46, 0.18)
	sky.size = Vector2(1280, 720)
	add_child(sky)
	var sun := Polygon2D.new()
	sun.polygon = _ellipse_points(Vector2(1040, 110), Vector2(88, 88), 36)
	sun.color = Color(1.0, 0.78, 0.28, 0.85)
	add_child(sun)
	_build_background_dinosaurs()
	for i in range(6):
		var ruin := ColorRect.new()
		ruin.color = Color(0.20, 0.16, 0.22, 0.82)
		ruin.position = Vector2(80 + i * 210, 210 + (i % 2) * 40)
		ruin.size = Vector2(95, 220)
		add_child(ruin)
	_build_jungle_ruins()
	var road := ColorRect.new()
	road.color = Color(0.16, 0.15, 0.15)
	road.position = Vector2(0, 330)
	road.size = Vector2(1280, 300)
	add_child(road)
	for stripe in range(8):
		var lane := ColorRect.new()
		lane.color = Color(0.86, 0.74, 0.42, 0.55)
		lane.position = Vector2(70 + stripe * 160, 462)
		lane.size = Vector2(72, 7)
		add_child(lane)
	_build_sundrifter()
	_build_transport_cages()
	for j in range(10):
		var crystal := ColorRect.new()
		crystal.color = Color(0.2, 1.0, 0.58, 0.76)
		crystal.position = Vector2(70 + j * 125, 585 - (j % 3) * 20)
		crystal.size = Vector2(16, 42)
		add_child(crystal)

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

func _build_jungle_ruins() -> void:
	for i in range(9):
		var vine := ColorRect.new()
		vine.position = Vector2(35 + i * 138, 250)
		vine.size = Vector2(8, 160 + (i % 3) * 30)
		vine.color = Color(0.08, 0.42, 0.16, 0.72)
		add_child(vine)
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
	debug_overlay = load("res://scripts/debug_overlay.gd").new()
	add_child(debug_overlay)
	hud.show_notice(stage_data["opening_cutscene"])

func _start_next_wave() -> void:
	wave_index += 1
	var waves: Array = stage_data["waves"]
	if wave_index >= waves.size():
		_start_boss()
		return
	var wave: Dictionary = waves[wave_index]
	enemies = wave_spawner.spawn_wave(self, wave["enemies"], player, float(wave["arena_x"]))
	for enemy in enemies:
		enemy.defeated.connect(_on_enemy_defeated)
		enemy.attack_landed.connect(_on_enemy_attack)
	hud.show_notice("Wave %d | Iron Veil roadblock" % [wave_index + 1])

func _start_boss() -> void:
	boss_started = true
	boss = BOSS_SCENE.instantiate()
	boss.setup(boss_profiles[stage_data["boss_id"]])
	boss.position = Vector2(940, 500)
	boss.target = player
	boss.defeated.connect(_on_boss_defeated)
	boss.attack_landed.connect(func(amount): player.apply_damage(amount, boss.position.x))
	boss.summon_requested.connect(_summon_boss_grunts)
	add_child(boss)
	hud.show_notice("Brask Noll blocks the road.")

func _summon_boss_grunts() -> void:
	var adds: Array = wave_spawner.spawn_wave(self, ["iron_veil_grunt", "iron_veil_runner"], player, boss.position.x - 160.0)
	for enemy in adds:
		enemy.defeated.connect(_on_enemy_defeated)
		enemy.attack_landed.connect(_on_enemy_attack)
	enemies.append_array(adds)

func _handle_combat() -> void:
	if player.is_attack_active() or player.is_special_active():
		for enemy in enemies.duplicate():
			if enemy != null and is_instance_valid(enemy) and player.attack_rect().intersects(enemy.body_rect()):
				enemy.apply_damage(player.attack_damage, player.position.x)
				player.add_meter(6)
		if boss != null and is_instance_valid(boss):
			var hit_rect: Rect2 = player.attack_rect()
			if player.is_special_active():
				hit_rect = Rect2(player.position - Vector2(84, 104), Vector2(168, 168))
			if hit_rect.intersects(boss.body_rect()):
				boss.apply_damage(player.special_damage if player.is_special_active() else player.attack_damage, player.position.x)
				player.add_meter(8)

func _on_enemy_defeated(enemy) -> void:
	player.score += enemy.score_value
	if randi() % 3 == 0:
		pickup_manager.spawn_pickup("glowfruit", enemy.position)

func _on_enemy_attack(enemy, amount: int) -> void:
	player.apply_damage(amount, enemy.position.x)

func _on_boss_defeated() -> void:
	player.score += 1500
	boss = null

func _living_enemy_count() -> int:
	var count := 0
	for enemy in enemies:
		if enemy != null and is_instance_valid(enemy):
			count += 1
	return count
