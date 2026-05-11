extends Node2D
class_name StageManager

signal stage_completed(text)
signal game_over

const PLAYER_SCENE := preload("res://scenes/player.tscn")
const BOSS_SCENE := preload("res://scenes/boss_brask_noll.tscn")
const StageBackdrop := preload("res://scripts/stage_backdrop.gd")
const ArcadeCombatFx := preload("res://scripts/arcade_combat_fx.gd")
const VisualAssetLoader := preload("res://scripts/visual_asset_loader.gd")

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
var audio_manager
var visual_assets: VisualAssetLoader
var enemies: Array = []
var boss
var wave_index := -1
var boss_started := false
var complete := false
var camera: Camera2D
var animated_art: Array = []
var cinematic_motion_actors: Array = []
var stage_time := 0.0
var active_arena_markers: Array = []
var hit_registry := {}
var camera_punch_timer := 0.0
var camera_punch_strength := 0.0
var attack_fx_cooldown := 0.0
var hit_stop_active := false
var demo_autoplay_active := false
var demo_autoplay_time := 0.0
var road_collapse_triggered := false
var road_collapse_active := false
var road_collapse_timer := 0.0
var road_collapse_group: Node2D
var last_boss_story_beat := ""
var last_pickup_notice := ""
var pickup_drop_count := 0
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
	visual_assets = VisualAssetLoader.new()
	_apply_biome_palette()
	_build_background()
	_build_player()
	_build_systems()
	_start_next_wave()

func _process(delta: float) -> void:
	stage_time += delta
	attack_fx_cooldown = maxf(attack_fx_cooldown - delta, 0.0)
	_animate_stage_art(delta)
	_tick_cinematic_stage_motion(delta)
	_tick_cinematic_camera(delta)
	_tick_camera_punch(delta)
	_tick_road_collapse(delta)
	if complete:
		if demo_autoplay_active and player != null and player.has_method("set_demo_intent"):
			player.set_demo_intent(Vector2.ZERO, false)
		return
	if road_collapse_active:
		hud.update_player(player)
		debug_overlay.update_debug(player, _living_enemy_count(), "road collapse set piece")
		return
	if demo_autoplay_active:
		_tick_demo_autoplay(delta)
	_tick_belt_scroll_composition(delta)
	_handle_combat()
	pickup_manager.collect_near(player)
	hud.update_player(player)
	hud.update_boss(boss)
	debug_overlay.update_debug(player, _living_enemy_count(), "player + attack + enemy boxes")
	if _living_enemy_count() == 0 and not boss_started:
		_advance_after_wave()
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
	var loaded_asset_layers := false
	if stage_id == "sunset_overpass":
		loaded_asset_layers = visual_assets.add_stage1_background_layers(self)
		if loaded_asset_layers:
			_register_asset_layer_motion()
	if not loaded_asset_layers:
		_build_arcade_backdrop()
		_build_background_dinosaurs()
		_build_jungle_ruins()
		var road := ColorRect.new()
		road.color = biome_palette["road"]
		road.position = Vector2(0, 330)
		road.size = Vector2(1280, 300)
		add_child(road)
		_build_cracked_overpass_depth()
		_build_broken_guardrails()
		_build_luma_road_cracks()
	if not loaded_asset_layers:
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
	_build_premium_readability_grade()
	_build_stage1_asset_set_dressing()
	_build_cinematic_stage_motion()

func _build_premium_readability_grade() -> void:
	if stage_id != "sunset_overpass":
		return
	var sunset_grade := ColorRect.new()
	sunset_grade.name = "premium-sunset-grade"
	sunset_grade.position = Vector2(0, 0)
	sunset_grade.size = Vector2(1280, 360)
	sunset_grade.color = Color(1.0, 0.34, 0.08, 0.055)
	sunset_grade.z_index = -94
	sunset_grade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(sunset_grade)
	var fight_plane_shadow := ColorRect.new()
	fight_plane_shadow.name = "premium-fight-plane-shadow"
	fight_plane_shadow.position = Vector2(0, 382)
	fight_plane_shadow.size = Vector2(1280, 226)
	fight_plane_shadow.color = Color(0.015, 0.018, 0.018, 0.13)
	fight_plane_shadow.z_index = -93
	fight_plane_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fight_plane_shadow)
	var luma_rim := ColorRect.new()
	luma_rim.name = "premium-luma-rim"
	luma_rim.position = Vector2(0, 592)
	luma_rim.size = Vector2(1280, 48)
	luma_rim.color = Color(0.18, 1.0, 0.62, 0.055)
	luma_rim.z_index = -92
	luma_rim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(luma_rim)
	for i in range(2):
		var lane := Line2D.new()
		lane.name = "premium-readability-lane"
		lane.default_color = Color(1.0, 0.72, 0.32, 0.16)
		lane.width = 2.0
		var y := 438.0 + float(i) * 126.0
		lane.points = PackedVector2Array([Vector2(56, y), Vector2(1224, y - 18.0)])
		lane.z_index = -91
		add_child(lane)

func _build_stage1_asset_set_dressing() -> void:
	if stage_id != "sunset_overpass":
		return
	_build_ruined_overpass_sign(Vector2(166, 352), "NORTH PASS", -8.0)
	_build_ruined_overpass_sign(Vector2(1038, 344), "EMBER REST", 5.0)
	_build_transport_cage_silhouette(Vector2(798, 366))
	_build_transport_cage_silhouette(Vector2(900, 378))
	_build_luma_plant_cluster(Vector2(104, 602), 0.88)
	_build_luma_plant_cluster(Vector2(1138, 590), 1.08)
	_build_luma_plant_cluster(Vector2(646, 624), 0.72)
	_build_road_rubble_cluster(Vector2(230, 612), 1.0)
	_build_road_rubble_cluster(Vector2(520, 596), 0.82)
	_build_road_rubble_cluster(Vector2(1004, 610), 1.12)

func _build_ruined_overpass_sign(pos: Vector2, label_text: String, angle: float) -> void:
	var root := Node2D.new()
	root.name = "stage1-ruined-signpost"
	root.position = pos
	root.rotation_degrees = angle
	root.z_index = -84
	add_child(root)
	var post := Line2D.new()
	post.default_color = Color(0.12, 0.13, 0.12, 0.78)
	post.width = 7.0
	post.points = PackedVector2Array([Vector2(-36, 58), Vector2(-24, -12)])
	root.add_child(post)
	var panel := ColorRect.new()
	panel.position = Vector2(-76, -48)
	panel.size = Vector2(142, 48)
	panel.color = Color(0.05, 0.14, 0.13, 0.72)
	root.add_child(panel)
	var border := Line2D.new()
	border.default_color = Color(0.94, 0.62, 0.30, 0.56)
	border.width = 2.0
	border.points = PackedVector2Array([Vector2(-76, -48), Vector2(66, -48), Vector2(66, 0), Vector2(-76, 0), Vector2(-76, -48)])
	root.add_child(border)
	var label := Label.new()
	label.text = label_text
	label.position = Vector2(-67, -39)
	label.size = Vector2(124, 22)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.56, 0.72))
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.95))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	root.add_child(label)
	var vine := Line2D.new()
	vine.default_color = Color(0.12, 0.54, 0.22, 0.50)
	vine.width = 4.0
	vine.points = PackedVector2Array([Vector2(-64, -47), Vector2(-46, -16), Vector2(-52, 12)])
	root.add_child(vine)

func _build_luma_plant_cluster(pos: Vector2, scale_factor: float) -> void:
	var root := Node2D.new()
	root.name = "stage1-luma-plant-cluster"
	root.position = pos
	root.scale = Vector2(scale_factor, scale_factor)
	root.z_index = -72
	add_child(root)
	for i in range(5):
		var blade := Polygon2D.new()
		var x := -26.0 + float(i) * 13.0
		var h := 28.0 + float(i % 3) * 9.0
		blade.polygon = PackedVector2Array([Vector2(x, 0), Vector2(x + 7, -h), Vector2(x + 15, 0)])
		blade.color = Color(0.07, 0.42, 0.18, 0.78)
		root.add_child(blade)
	for i in range(3):
		var crystal := Polygon2D.new()
		var x2 := -12.0 + float(i) * 13.0
		crystal.polygon = PackedVector2Array([Vector2(x2, -6), Vector2(x2 + 8, -30), Vector2(x2 + 17, -6), Vector2(x2 + 7, 4)])
		crystal.color = Color(0.24, 1.0, 0.62, 0.48)
		root.add_child(crystal)
	animated_art.append({"node": root, "kind": "pulse", "base": root.position, "speed": 1.7 + scale_factor, "amount": 4.0})

func _build_road_rubble_cluster(pos: Vector2, scale_factor: float) -> void:
	var root := Node2D.new()
	root.name = "stage1-road-rubble"
	root.position = pos
	root.scale = Vector2(scale_factor, scale_factor)
	root.z_index = -71
	add_child(root)
	for i in range(6):
		var rock := Polygon2D.new()
		var x := -44.0 + float(i) * 18.0
		var y := -float(i % 3) * 4.0
		rock.polygon = PackedVector2Array([
			Vector2(x, y),
			Vector2(x + 16.0, y - 7.0),
			Vector2(x + 30.0, y + 2.0),
			Vector2(x + 22.0, y + 12.0),
			Vector2(x + 4.0, y + 10.0)
		])
		rock.color = Color(0.10, 0.095, 0.082, 0.76).lightened(float(i % 3) * 0.05)
		root.add_child(rock)

func _build_transport_cage_silhouette(pos: Vector2) -> void:
	var root := Node2D.new()
	root.name = "stage1-transport-cage-silhouette"
	root.position = pos
	root.z_index = -83
	add_child(root)
	var frame := ColorRect.new()
	frame.position = Vector2(-44, -48)
	frame.size = Vector2(88, 48)
	frame.color = Color(0.035, 0.04, 0.045, 0.58)
	root.add_child(frame)
	var border := Line2D.new()
	border.default_color = Color(0.84, 0.66, 0.40, 0.38)
	border.width = 2.0
	border.points = PackedVector2Array([Vector2(-44, -48), Vector2(44, -48), Vector2(44, 0), Vector2(-44, 0), Vector2(-44, -48)])
	root.add_child(border)
	for i in range(5):
		var bar := Line2D.new()
		bar.default_color = Color(0.55, 0.56, 0.52, 0.42)
		bar.width = 3.0
		var x := -34.0 + float(i) * 17.0
		bar.points = PackedVector2Array([Vector2(x, -46), Vector2(x + 4, -2)])
		root.add_child(bar)
	var eye := ColorRect.new()
	eye.position = Vector2(-7, -30)
	eye.size = Vector2(14, 4)
	eye.color = Color(0.24, 1.0, 0.62, 0.44)
	root.add_child(eye)

func _register_asset_layer_motion() -> void:
	for child in get_children():
		if child == null or not is_instance_valid(child):
			continue
		var child_name := str(child.name)
		if child_name == "asset-layer-far_sky_ruins":
			animated_art.append({"node": child, "kind": "pulse", "base": child.position, "speed": 0.35, "amount": 1.0})
		elif child_name == "asset-layer-mid_overpass":
			animated_art.append({"node": child, "kind": "drift", "base": child.position, "speed": 0.28, "amount": 5.0})
		elif child_name == "asset-layer-foreground_atmosphere":
			animated_art.append({"node": child, "kind": "drift", "base": child.position, "speed": 0.55, "amount": 10.0})

func _build_cinematic_stage_motion() -> void:
	if stage_id != "sunset_overpass":
		return
	for i in range(3):
		var dinosaur := _build_cinematic_dinosaur(i % 2 == 0, i)
		dinosaur.name = "cinematic-dinosaur-%d" % i
		dinosaur.position = Vector2(-420.0 - float(i) * 360.0, 250.0 + float(i % 2) * 24.0)
		var dino_scale := 0.24 + float(i % 2) * 0.07
		dinosaur.scale = Vector2(dino_scale, dino_scale)
		dinosaur.z_index = -238 + i
		add_child(dinosaur)
		cinematic_motion_actors.append({"node": dinosaur, "kind": "dinosaur", "base": dinosaur.position, "speed": 34.0 + float(i) * 7.0, "loop_width": 1840.0, "phase": float(i) * 0.45, "scale": dino_scale})
	for i in range(9):
		var dust := Line2D.new()
		dust.name = "cinematic-road-dust-%d" % i
		dust.default_color = Color(0.92, 0.64, 0.34, 0.16)
		dust.width = 3.0 + float(i % 3)
		dust.points = PackedVector2Array([Vector2.ZERO, Vector2(46 + i * 4, -5 + (i % 2) * 4)])
		dust.position = Vector2(-180.0 + float(i) * 170.0, 432.0 + float(i % 4) * 38.0)
		dust.z_index = -86
		add_child(dust)
		cinematic_motion_actors.append({"node": dust, "kind": "dust", "base": dust.position, "speed": 68.0 + float(i) * 5.0, "loop_width": 1500.0, "phase": float(i) * 0.3})
	var glider := _build_cinematic_glider()
	glider.name = "cinematic-sky-glider"
	glider.position = Vector2(1380, 158)
	glider.scale = Vector2(0.48, 0.48)
	glider.z_index = -242
	add_child(glider)
	cinematic_motion_actors.append({"node": glider, "kind": "glider", "base": glider.position, "speed": -48.0, "loop_width": 1680.0, "phase": 0.0, "scale": 0.48})

func _tick_cinematic_stage_motion(_delta: float) -> void:
	for item in cinematic_motion_actors:
		var node = item.get("node", null)
		if node == null or not is_instance_valid(node):
			continue
		var kind: String = str(item.get("kind", ""))
		var base: Vector2 = item.get("base", Vector2.ZERO)
		var speed: float = float(item.get("speed", 0.0))
		var loop_width: float = float(item.get("loop_width", 1280.0))
		var phase: float = float(item.get("phase", 0.0))
		var base_scale: float = float(item.get("scale", 1.0))
		if kind == "glider":
			node.position.x = 1380.0 - fmod(stage_time * absf(speed) + phase * 300.0, loop_width)
			node.position.y = base.y + sin(stage_time * 1.7 + phase) * 12.0
			node.scale = Vector2(base_scale, base_scale * (0.92 + sin(stage_time * 9.0) * 0.08))
		else:
			node.position.x = -360.0 + fmod(stage_time * speed + phase * 260.0, loop_width)
			node.position.y = base.y + sin(stage_time * (2.0 + phase)) * (4.0 if kind == "dinosaur" else 2.0)
			if kind == "dinosaur":
				node.scale = Vector2(base_scale, base_scale * (0.96 + sin(stage_time * 7.0 + phase) * 0.035))
			elif kind == "dust" and node is CanvasItem:
				node.modulate = Color(1.0, 1.0, 1.0, 0.55 + sin(stage_time * 4.0 + phase) * 0.25)

func _build_cinematic_dinosaur(long_neck: bool, variant: int) -> Node2D:
	var root := Node2D.new()
	var color := Color(0.025, 0.035, 0.035, 0.22)
	if variant % 2 == 1:
		color = Color(0.05, 0.045, 0.038, 0.18)
	var body := Polygon2D.new()
	body.polygon = _ellipse_points(Vector2(0, 0), Vector2(72, 26), 18)
	body.color = color
	root.add_child(body)
	var tail := Polygon2D.new()
	tail.polygon = PackedVector2Array([Vector2(-58, -4), Vector2(-136, -20), Vector2(-66, 16)])
	tail.color = color
	root.add_child(tail)
	var neck := Line2D.new()
	neck.default_color = color
	neck.width = 18.0 if long_neck else 13.0
	if long_neck:
		neck.points = PackedVector2Array([Vector2(48, -12), Vector2(92, -72), Vector2(128, -94)])
	else:
		neck.points = PackedVector2Array([Vector2(48, -8), Vector2(92, -30)])
	root.add_child(neck)
	var head := Polygon2D.new()
	head.position = Vector2(135, -94) if long_neck else Vector2(102, -32)
	head.polygon = PackedVector2Array([Vector2(-18, -8), Vector2(20, -7), Vector2(28, 5), Vector2(-12, 13)])
	head.color = color
	root.add_child(head)
	for leg in range(4):
		var line := Line2D.new()
		line.default_color = color
		line.width = 10.0
		var x := -42.0 + float(leg) * 28.0
		var stride := -8.0 if leg % 2 == 0 else 8.0
		line.points = PackedVector2Array([Vector2(x, 18), Vector2(x + stride, 64), Vector2(x + stride + 18, 66)])
		root.add_child(line)
	return root

func _build_cinematic_glider() -> Node2D:
	var root := Node2D.new()
	var wing := Polygon2D.new()
	wing.polygon = PackedVector2Array([Vector2(-82, 0), Vector2(0, -28), Vector2(82, 0), Vector2(18, 12), Vector2(0, 2), Vector2(-18, 12)])
	wing.color = Color(0.03, 0.035, 0.04, 0.22)
	root.add_child(wing)
	var body := Line2D.new()
	body.default_color = Color(0.03, 0.035, 0.04, 0.24)
	body.width = 7.0
	body.points = PackedVector2Array([Vector2(-10, 2), Vector2(34, 6), Vector2(62, 18)])
	root.add_child(body)
	return root

func _build_cracked_overpass_depth() -> void:
	var road_shadow := Polygon2D.new()
	road_shadow.name = "service-lane-shadow"
	road_shadow.polygon = PackedVector2Array([
		Vector2(0, 430),
		Vector2(1280, 385),
		Vector2(1280, 632),
		Vector2(0, 632)
	])
	road_shadow.color = Color(0.04, 0.045, 0.048, 0.42)
	add_child(road_shadow)
	var shoulder := Polygon2D.new()
	shoulder.name = "cracked elevated highway shoulder"
	shoulder.polygon = PackedVector2Array([
		Vector2(0, 330),
		Vector2(1280, 330),
		Vector2(1240, 382),
		Vector2(36, 398)
	])
	shoulder.color = biome_palette["road"].lightened(0.12)
	add_child(shoulder)
	for i in range(7):
		var slab := Polygon2D.new()
		var x := float(i) * 190.0 - 35.0
		slab.polygon = PackedVector2Array([
			Vector2(x, 392),
			Vector2(x + 150, 384 + float(i % 2) * 8.0),
			Vector2(x + 188, 620),
			Vector2(x - 18, 620)
		])
		slab.color = biome_palette["road"].lightened(0.03 + float(i % 3) * 0.03)
		add_child(slab)

func _build_broken_guardrails() -> void:
	for i in range(9):
		var post := ColorRect.new()
		post.name = "broken-guardrail-post"
		post.color = Color(0.56, 0.58, 0.55, 0.82)
		post.position = Vector2(42 + i * 148, 318 + (i % 3) * 7)
		post.size = Vector2(9, 46 - (i % 2) * 14)
		add_child(post)
	for i in range(5):
		var rail := Line2D.new()
		rail.name = "broken-guardrail-span"
		rail.default_color = Color(0.72, 0.70, 0.62, 0.72)
		rail.width = 5.0
		var x := 62 + i * 255
		rail.points = PackedVector2Array([Vector2(x, 326 + (i % 2) * 12), Vector2(x + 164, 312 + (i % 3) * 10)])
		add_child(rail)

func _build_luma_road_cracks() -> void:
	for i in range(11):
		var crack := Line2D.new()
		crack.name = "luma-road-crack"
		crack.default_color = biome_palette["accent"].darkened(0.05)
		crack.width = 2.0 + float(i % 3)
		var x := 60 + i * 111
		var y := 430 + (i % 4) * 42
		crack.points = PackedVector2Array([
			Vector2(x, y),
			Vector2(x + 26, y + 18),
			Vector2(x + 12, y + 42),
			Vector2(x + 54, y + 68)
		])
		add_child(crack)
		animated_art.append({"node": crack, "kind": "pulse", "base": crack.position, "speed": 1.2 + i * 0.08, "amount": 2.0})

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
		elif kind == "fade_drift":
			node.position.x = item["base"].x + sin(stage_time * item["speed"]) * item["amount"]
			node.position.y = item["base"].y - absf(sin(stage_time * item["speed"])) * item["amount"] * 0.45
			if node is CanvasItem:
				var fade := maxf(0.0, 0.7 - fmod(stage_time * item["speed"], 0.7))
				node.modulate = Color(1.0, 1.0, 1.0, fade)

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
	player.position = Vector2(350, 520)
	player.defeated.connect(func(): game_over.emit())
	add_child(player)
	camera = Camera2D.new()
	player.add_child(camera)
	_configure_stage_camera()
	camera.make_current()

func _configure_stage_camera() -> void:
	camera.position_smoothing_enabled = false
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = 1280
	camera.limit_bottom = 720

func _build_systems() -> void:
	wave_spawner = load("res://scripts/wave_spawner.gd").new()
	add_child(wave_spawner)
	pickup_manager = load("res://scripts/pickup_manager.gd").new()
	add_child(pickup_manager)
	pickup_manager.picked_up.connect(_on_pickup_collected)
	hud = load("res://scripts/hud_controller.gd").new()
	add_child(hud)
	combat_fx = ArcadeCombatFx.new()
	add_child(combat_fx)
	audio_manager = load("res://scripts/audio_manager.gd").new()
	add_child(audio_manager)
	audio_manager.play_stage_music()
	audio_manager.play_stage_start()
	debug_overlay = load("res://scripts/debug_overlay.gd").new()
	add_child(debug_overlay)
	hud.show_notice(stage_data["opening_cutscene"])
	hud.update_objective(_stage_hud_goal("Win the fight"))

func _start_next_wave() -> void:
	wave_index += 1
	var waves: Array = stage_data["waves"]
	if wave_index >= waves.size():
		_start_boss()
		return
	var wave: Dictionary = waves[wave_index]
	_build_arena_boundaries(float(wave["arena_x"]))
	enemies = wave_spawner.spawn_wave(self, wave["enemies"], player, float(wave["arena_x"]))
	_assign_arcade_enemy_slots(enemies)
	for enemy in enemies:
		enemy.defeated.connect(_on_enemy_defeated)
		enemy.attack_landed.connect(_on_enemy_attack)
	_show_wave_objective(wave_index)

func _advance_after_wave() -> void:
	if _should_trigger_road_collapse():
		_trigger_road_collapse()
		return
	_start_next_wave()

func _should_trigger_road_collapse() -> bool:
	if road_collapse_triggered or road_collapse_active:
		return false
	for event in stage_data.get("stage_events", []):
		if event.get("id", "") == "road_collapse" and int(event.get("trigger_after_wave", -1)) == wave_index:
			return true
	return false

func _road_collapse_event() -> Dictionary:
	for event in stage_data.get("stage_events", []):
		if event.get("id", "") == "road_collapse":
			return event
	return {}

func _trigger_road_collapse() -> void:
	var event := _road_collapse_event()
	road_collapse_triggered = true
	road_collapse_active = true
	road_collapse_timer = 1.55
	_clear_arena_boundaries()
	_build_road_collapse_set_piece()
	_apply_camera_punch(14.0)
	audio_manager.play_heavy()
	hud.update_objective("Service lane exposed | Wave %d/%d" % [int(event.get("resume_wave", wave_index + 1)) + 1, stage_data["waves"].size()])
	hud.show_notice("Road collapse\nRegain the lower lane.", 1.2)
	combat_fx.show_stage_event(str(event.get("title", "ROAD COLLAPSE")), str(event.get("body", "Service lane exposed.")))

func _tick_road_collapse(delta: float) -> void:
	if not road_collapse_active:
		return
	road_collapse_timer = maxf(road_collapse_timer - delta, 0.0)
	if road_collapse_timer > 0.0:
		return
	road_collapse_active = false
	if road_collapse_group != null and is_instance_valid(road_collapse_group):
		road_collapse_group.modulate.a = 0.82
	_start_next_wave()

func _build_road_collapse_set_piece() -> void:
	if road_collapse_group != null and is_instance_valid(road_collapse_group):
		road_collapse_group.queue_free()
	road_collapse_group = Node2D.new()
	road_collapse_group.name = "stage1-road-collapse-set-piece"
	road_collapse_group.z_index = -65
	add_child(road_collapse_group)
	var service_lane := Polygon2D.new()
	service_lane.name = "stage1-service-lane-exposed"
	service_lane.polygon = PackedVector2Array([
		Vector2(0, 478),
		Vector2(1280, 430),
		Vector2(1280, 642),
		Vector2(0, 668)
	])
	service_lane.color = Color(0.035, 0.050, 0.045, 0.48)
	road_collapse_group.add_child(service_lane)
	for i in range(7):
		var fracture := Line2D.new()
		fracture.name = "stage1-road-collapse-fracture"
		fracture.default_color = Color(0.30, 1.0, 0.68, 0.72)
		fracture.width = 3.0 + float(i % 3)
		var x := 130.0 + float(i) * 170.0
		var y := 430.0 + float(i % 2) * 36.0
		fracture.points = PackedVector2Array([
			Vector2(x, y),
			Vector2(x + 48.0, y + 42.0),
			Vector2(x + 22.0, y + 86.0),
			Vector2(x + 86.0, y + 126.0)
		])
		road_collapse_group.add_child(fracture)
		animated_art.append({"node": fracture, "kind": "pulse", "base": fracture.position, "speed": 2.4 + float(i) * 0.12, "amount": 2.0})
	for i in range(4):
		var slab := Polygon2D.new()
		slab.name = "stage1-collapsed-road-slab"
		var x2 := 210.0 + float(i) * 260.0
		slab.polygon = PackedVector2Array([
			Vector2(x2, 486),
			Vector2(x2 + 172, 468 + float(i % 2) * 18.0),
			Vector2(x2 + 206, 552),
			Vector2(x2 + 34, 576)
		])
		slab.color = Color(0.09, 0.085, 0.074, 0.68)
		road_collapse_group.add_child(slab)
	var spike := Line2D.new()
	spike.name = "stage1-luma-extraction-spike-overload"
	spike.default_color = Color(0.34, 1.0, 0.72, 0.82)
	spike.width = 7.0
	spike.points = PackedVector2Array([Vector2(706, 622), Vector2(682, 442), Vector2(736, 356)])
	road_collapse_group.add_child(spike)

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
	boss.move_telegraphed.connect(_on_boss_move_telegraphed)
	boss.phase_changed.connect(_on_boss_phase_changed)
	add_child(boss)
	_show_boss_intro()

func _summon_boss_grunts() -> void:
	var adds: Array = wave_spawner.spawn_wave(self, ["iron_veil_grunt", "iron_veil_runner"], player, boss.position.x - 160.0)
	_assign_arcade_enemy_slots(adds)
	for enemy in adds:
		enemy.defeated.connect(_on_enemy_defeated)
		enemy.attack_landed.connect(_on_enemy_attack)
	enemies.append_array(adds)

func _assign_arcade_enemy_slots(spawned: Array) -> void:
	for index in range(spawned.size()):
		var enemy = spawned[index]
		if enemy != null and is_instance_valid(enemy) and enemy.has_method("configure_arcade_slot"):
			enemy.configure_arcade_slot(index, spawned.size())

func _tick_belt_scroll_composition(_delta: float) -> void:
	_apply_enemy_spacing()

func _apply_enemy_spacing() -> void:
	for i in range(enemies.size()):
		var first = enemies[i]
		if first == null or not is_instance_valid(first):
			continue
		for j in range(i + 1, enemies.size()):
			var second = enemies[j]
			if second == null or not is_instance_valid(second):
				continue
			var delta: Vector2 = second.position - first.position
			var distance: float = delta.length()
			var minimum: float = 58.0
			if distance <= 0.01:
				delta = Vector2(1.0, 0.0)
				distance = 1.0
			if distance < minimum:
				var push: Vector2 = delta.normalized() * ((minimum - distance) * 0.5)
				first.position -= push
				second.position += push
				first.position.x = clamp(first.position.x, 80.0, 1200.0)
				second.position.x = clamp(second.position.x, 80.0, 1200.0)
				first.position.y = clamp(first.position.y, 330.0, 620.0)
				second.position.y = clamp(second.position.y, 330.0, 620.0)

func _handle_combat() -> void:
	if not player.is_attack_active() and not player.is_special_active():
		hit_registry.clear()
		return
	if player.is_attack_active() or player.is_special_active():
		if attack_fx_cooldown <= 0.0:
			combat_fx.spawn_attack_arc(_world_to_screen(player.position + Vector2(player.facing * 34, -48)), player.facing)
			attack_fx_cooldown = 0.08
		for enemy in enemies.duplicate():
			if enemy != null and is_instance_valid(enemy) and player.attack_rect().intersects(enemy.body_rect()):
				var key := "enemy_%d" % enemy.get_instance_id()
				if hit_registry.has(key):
					continue
				hit_registry[key] = true
				var damage: int = player.special_damage if player.is_special_active() else player.current_attack_damage()
				var enemy_feedback_position: Vector2 = enemy.position + Vector2(0, -46)
				enemy.apply_damage(damage, player.position.x)
				player.register_hit()
				_spawn_hit_feedback(enemy_feedback_position, damage, player.is_special_active())
		if boss != null and is_instance_valid(boss):
			var hit_rect: Rect2 = player.attack_rect()
			if player.is_special_active():
				hit_rect = player.special_rect()
			if hit_rect.intersects(boss.body_rect()):
				var boss_key := "boss_%d" % boss.get_instance_id()
				if hit_registry.has(boss_key):
					return
				hit_registry[boss_key] = true
				var boss_damage: int = player.special_damage if player.is_special_active() else player.current_attack_damage()
				var boss_feedback_position: Vector2 = boss.position + Vector2(0, -72)
				boss.apply_damage(boss_damage, player.position.x)
				player.register_hit()
				_spawn_hit_feedback(boss_feedback_position, boss_damage, true)

func _on_enemy_defeated(enemy) -> void:
	player.score += enemy.score_value
	var drop_kind := _pickup_kind_for_drop()
	if drop_kind != "":
		pickup_manager.spawn_pickup(drop_kind, enemy.position)

func _pickup_kind_for_drop() -> String:
	if pickup_drop_count == 0:
		pickup_drop_count += 1
		return "glowfruit"
	if randi() % 3 != 0:
		return ""
	pickup_drop_count += 1
	return "luma_shard" if pickup_drop_count % 2 == 0 else "glowfruit"

func _on_pickup_collected(kind: String) -> void:
	last_pickup_notice = pickup_manager.pickup_notice(kind)
	if hud != null and last_pickup_notice != "":
		hud.show_notice(last_pickup_notice, 1.1)
	if audio_manager != null:
		audio_manager.play_pickup()

func _on_enemy_attack(enemy, amount: int) -> void:
	player.apply_damage(amount, enemy.position.x)
	audio_manager.play_heavy()
	combat_fx.spawn_hit_spark(_world_to_screen(player.position + Vector2(0, -48)), Color(1.0, 0.18, 0.08), false)
	combat_fx.spawn_impact_burst(_world_to_screen(player.position + Vector2(0, -48)), -player.facing, false)
	_apply_camera_punch(4.0)

func _on_boss_defeated() -> void:
	player.score += 1500
	audio_manager.play_victory()
	audio_manager.play_stage_clear()
	_show_boss_story_beat("escape_title", "escape_line", "BRASK ESCAPES", stage_data.get("ending_cutscene", "Brask escapes."), 1.35)
	boss = null

func stage_clear_summary() -> Dictionary:
	if player == null or not is_instance_valid(player):
		return {
			"rank": "C",
			"score": 0,
			"luma": 0,
			"health": 0,
			"max_health": 1
		}
	var health_value: int = max(player.health, 0)
	var max_health_value: int = max(player.max_health, 1)
	var score_value: int = max(player.score, 0)
	var luma_value: int = max(player.luma_shards, 0)
	return {
		"rank": _stage_clear_rank(score_value, luma_value, health_value, max_health_value),
		"score": score_value,
		"luma": luma_value,
		"health": health_value,
		"max_health": max_health_value
	}

func _stage_clear_rank(score_value: int, luma_value: int, health_value: int, max_health_value: int) -> String:
	var health_ratio := float(health_value) / float(max(max_health_value, 1))
	var adjusted_score := score_value + luma_value * 150
	if adjusted_score >= 3600 and health_ratio >= 0.75:
		return "S"
	if adjusted_score >= 2800 and health_ratio >= 0.50:
		return "A"
	if adjusted_score >= 1800:
		return "B"
	return "C"

func _on_boss_move_telegraphed(_move_name: String) -> void:
	audio_manager.play_boss_warning()

func _on_boss_phase_changed() -> void:
	audio_manager.play_heavy()
	_show_boss_story_beat("phase_title", "phase_line", "BRASK OVERDRIVE", "Watch the second swing.", 1.55)
	_apply_camera_punch(11.0)

func _living_enemy_count() -> int:
	var count := 0
	for enemy in enemies:
		if enemy != null and is_instance_valid(enemy):
			count += 1
	return count

func set_demo_autoplay(active: bool) -> void:
	demo_autoplay_active = active
	demo_autoplay_time = 0.0
	if player != null and player.has_method("set_demo_control"):
		player.set_demo_control(active)
		player.set_demo_intent(Vector2.ZERO, false)

func _tick_demo_autoplay(delta: float) -> void:
	demo_autoplay_time += delta
	if player == null or not is_instance_valid(player) or not player.has_method("set_demo_intent"):
		return
	var target_actor = _nearest_demo_target()
	if target_actor == null:
		player.set_demo_intent(Vector2(0.55, sin(demo_autoplay_time * 2.4) * 0.18), false)
		return
	var offset: Vector2 = target_actor.position - player.position
	var side: float = 1.0 if offset.x >= 0.0 else -1.0
	player.facing = int(side)
	var desired_position: Vector2 = target_actor.position - Vector2(side * 78.0, 0.0)
	desired_position.x = clamp(desired_position.x, 210.0, 1080.0)
	desired_position.y = clamp(desired_position.y, 360.0, 598.0)
	var to_slot: Vector2 = desired_position - player.position
	var aligned_y: bool = absf(offset.y) <= 46.0
	var in_strike_range: bool = absf(offset.x) <= 110.0 and aligned_y
	var move_vector: Vector2 = Vector2.ZERO
	if not in_strike_range:
		move_vector = to_slot.limit_length(1.0)
	else:
		move_vector = Vector2(0.0, sin(demo_autoplay_time * 5.0) * 0.22)
	var attack_beat: float = fmod(demo_autoplay_time, 0.72)
	var special_beat: float = fmod(demo_autoplay_time, 4.2)
	var attack_pressed: bool = in_strike_range and attack_beat < 0.12
	var dash_pressed: bool = absf(offset.x) > 210.0 and absf(offset.y) < 80.0 and fmod(demo_autoplay_time, 1.25) < 0.12
	var special_pressed: bool = player.special_meter >= player.special_cost and in_strike_range and special_beat < 0.12
	player.set_demo_intent(move_vector, attack_pressed, dash_pressed, special_pressed)

func _nearest_demo_target():
	var closest = null
	var closest_distance: float = INF
	for enemy in enemies:
		if enemy == null or not is_instance_valid(enemy):
			continue
		var distance: float = player.position.distance_squared_to(enemy.position)
		if distance < closest_distance:
			closest_distance = distance
			closest = enemy
	if boss != null and is_instance_valid(boss):
		var boss_distance: float = player.position.distance_squared_to(boss.position)
		if boss_distance < closest_distance:
			closest = boss
	return closest

func _show_wave_objective(next_wave_index: int) -> void:
	var objective: String = stage_data.get("scenario_goal", "Defeat the enemy wave")
	var hud_goal := _stage_hud_goal("Defeat the enemy wave")
	var stage_card_goal := _stage_card_goal(objective)
	hud.update_objective("%s | Wave %d/%d" % [hud_goal, next_wave_index + 1, stage_data["waves"].size()])
	hud.show_notice("%s\nWave %d" % [stage_data["title"], next_wave_index + 1], 1.25)
	audio_manager.play_wave_start()
	combat_fx.show_stage_card(stage_data["title"], stage_card_goal, next_wave_index)

func _stage_hud_goal(default_goal: String) -> String:
	return stage_data.get("hud_goal", stage_data.get("scenario_goal", default_goal))

func _stage_card_goal(default_goal: String) -> String:
	return stage_data.get("stage_card_goal", stage_data.get("scenario_goal", default_goal))

func _show_boss_intro() -> void:
	var boss_goal: String = stage_data.get("win_condition", "Defeat the boss")
	hud.update_objective(boss_goal)
	audio_manager.play_boss_intro()
	_show_boss_story_beat("intro_title", "intro_line", boss.display_name, boss.arena_hazard, 1.8)
	_apply_camera_punch(9.0)

func _boss_story() -> Dictionary:
	return stage_data.get("boss_story", {})

func _show_boss_story_beat(title_key: String, line_key: String, fallback_title: String, fallback_line: String, _duration: float) -> void:
	var story := _boss_story()
	var title := str(story.get(title_key, fallback_title))
	var line := str(story.get(line_key, fallback_line))
	last_boss_story_beat = "%s\n%s" % [title, line]
	hud.clear_notice()
	combat_fx.show_stage_event(title, line)

func _spawn_hit_feedback(world_position: Vector2, damage: int, big: bool) -> void:
	var screen_position := _world_to_screen(world_position)
	if big:
		audio_manager.play_heavy()
	else:
		audio_manager.play_hit()
	_emit_combat_motion_dust(world_position, big)
	combat_fx.spawn_hit_spark(screen_position, Color(1.0, 0.76, 0.18), big)
	combat_fx.spawn_impact_burst(screen_position, player.facing, big)
	combat_fx.spawn_damage_number(screen_position, damage, player.combo_count)
	_apply_camera_punch(7.0 if big else 3.0)
	_apply_hit_stop(0.085 if big else 0.055)

func _spawn_victory_banner(text: String) -> void:
	combat_fx.show_victory_banner(text)

func _world_to_screen(world_position: Vector2) -> Vector2:
	return get_global_transform_with_canvas() * world_position

func _tick_cinematic_camera(delta: float) -> void:
	if camera == null or player == null:
		return
	var focus: Vector2 = _cinematic_focus_point()
	var desired: Vector2 = (focus - player.position) * 0.055
	desired.x = clamp(desired.x, -28.0, 28.0)
	desired.y = clamp(desired.y, -10.0, 12.0)
	camera.position = camera.position.lerp(desired, minf(delta * 2.5, 1.0))
	camera.zoom = camera.zoom.lerp(Vector2(1.0, 1.0), minf(delta * 2.0, 1.0))

func _cinematic_focus_point() -> Vector2:
	var focus: Vector2 = player.position
	var target_actor = _nearest_demo_target()
	if target_actor != null:
		focus = player.position.lerp(target_actor.position, 0.42)
	return focus + Vector2(0.0, -34.0)

func _emit_combat_motion_dust(world_position: Vector2, big: bool) -> void:
	for i in range(5 if big else 3):
		var dust := Line2D.new()
		dust.name = "cinematic-combat-dust"
		dust.default_color = Color(0.86, 0.66, 0.42, 0.22)
		dust.width = 2.0 + float(i % 2)
		var direction := -1.0 if i % 2 == 0 else 1.0
		dust.points = PackedVector2Array([Vector2.ZERO, Vector2(direction * (28.0 + i * 9.0), -4.0 - i)])
		dust.position = world_position + Vector2(randf_range(-18.0, 18.0), 34.0 + randf_range(-6.0, 6.0))
		dust.z_index = int(dust.position.y) - 4
		add_child(dust)
		animated_art.append({"node": dust, "kind": "fade_drift", "base": dust.position, "speed": 2.4 + i * 0.2, "amount": 12.0 + i * 3.0})

func _apply_camera_punch(strength: float) -> void:
	camera_punch_timer = 0.16
	camera_punch_strength = maxf(camera_punch_strength, strength)

func _apply_hit_stop(duration: float) -> void:
	if hit_stop_active:
		return
	hit_stop_active = true
	Engine.time_scale = 0.18
	var timer := get_tree().create_timer(duration, false, false, true)
	timer.timeout.connect(_clear_hit_stop)

func _clear_hit_stop() -> void:
	Engine.time_scale = 1.0
	hit_stop_active = false

func _exit_tree() -> void:
	if hit_stop_active:
		_clear_hit_stop()

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
		marker.color = Color(1.0, 0.62, 0.24, 0.055)
		marker.position = Vector2(arena_x + side * 250.0, 330)
		marker.size = Vector2(5, 290)
		marker.z_index = -95
		add_child(marker)
		active_arena_markers.append(marker)
		var glow := ColorRect.new()
		glow.color = Color(0.26, 1.0, 0.68, 0.045)
		glow.position = marker.position + Vector2(-5, 0)
		glow.size = Vector2(15, 290)
		glow.z_index = -96
		add_child(glow)
		active_arena_markers.append(glow)

func _clear_arena_boundaries() -> void:
	for marker in active_arena_markers:
		if marker != null and is_instance_valid(marker):
			marker.queue_free()
	active_arena_markers.clear()
