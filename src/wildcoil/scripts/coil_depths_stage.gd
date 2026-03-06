extends Node2D

const ENEMY_PROJECTILE_SCENE = preload("res://scenes/enemy_projectile.tscn")

const CHECKPOINT_POSITION := Vector2(-560.0, 140.0)
const ENEMY_SPAWNS := {
	"RailLancer": Vector2(80.0, 140.0),
	"ArcSeeder": Vector2(340.0, 140.0),
	"NeedleHound": Vector2(620.0, 140.0),
	"CoilBrute": Vector2(860.0, 140.0),
}
const WORLD_BOUNDS := Vector2(-900.0, 1840.0)
const OPENING_BOUNDS := Vector2(-900.0, 980.0)
const BOSS_ARENA_BOUNDS := Vector2(1020.0, 1840.0)
const FIRST_FIGHT_TRIGGER_X := -180.0
const BOSS_TRIGGER_X := 1180.0
const RELAY_CORE_X := 1460.0
const BOSS_SPAWN_POSITION := Vector2(1460.0, 140.0)
const SPECTACLE_DURATION := 4.2
const BOSS_INTRO_DURATION := 1.8
const SPECTACLE_TARGET_SECONDS := 210.0
const HAZARD_LANES := [220.0, 520.0, 820.0, 1180.0, 1480.0]
const HAZARD_TELEGRAPH_DURATION := 0.9
const HAZARD_ACTIVE_DURATION := 0.55
const HAZARD_COOLDOWN_DURATION := 0.8
const HAZARD_RADIUS := 54.0

@onready var player: PlayerController = $Player
@onready var enemies_root: Node2D = $Enemies
@onready var projectile_root: Node2D = $Projectiles
@onready var boss: BossActor = $Boss

const SKY_COLOR := Color("061017")
const HAZE_COLOR := Color("10202b")
const MIST_COLOR := Color("18313e")
const GROUND_COLOR := Color("223942")
const BRUSH_COLOR := Color("315666")
const COIL_COLOR := Color("7fd6ff")
const SPARK_COLOR := Color("ffc971")
const RELAY_COLOR := Color("eef9ff")

@export var stage_id := "coil_depths"

var checkpoint_reset_count := 0
var hitstop_timer := 0.0
var elapsed_time := 0.0
var stage_phase := "approach"
var stage_objective := "Push into the relay clearing"
var first_combat_time := -1.0
var spectacle_time := -1.0
var finish_time := -1.0
var spectacle_timer := 0.0
var spectacle_progress := 0.0
var boss_intro_timer := 0.0
var boss_seen := false
var stage_complete := false
var screen_flash_timer := 0.0
var run_context: Dictionary = {}
var stage_definition: Dictionary = {}
var hazard_state := "idle"
var hazard_timer := 0.0
var hazard_lane_index := -1
var hazard_cycle_count := 0


func _ready() -> void:
	var player_ref := get_player()
	if player_ref != null:
		player_ref.stage = self
	for enemy in get_enemy_nodes():
		enemy.stage = self
	var boss_actor := get_boss_actor()
	if boss_actor != null:
		boss_actor.stage = self
	reset_to_checkpoint()
	queue_redraw()


func configure_run(new_run_context: Dictionary) -> void:
	run_context = new_run_context.duplicate(true)
	if typeof(run_context.get("stage_definition", {})) == TYPE_DICTIONARY:
		stage_definition = run_context.get("stage_definition", {}).duplicate(true)
		stage_id = str(stage_definition.get("id", stage_id))
	if stage_phase == "approach":
		stage_objective = get_opening_objective()
	var player_ref := get_player()
	if player_ref != null and player_ref.has_method("apply_character_definition"):
		player_ref.call("apply_character_definition", run_context.get("character_definition", {}))


func _physics_process(delta: float) -> void:
	hitstop_timer = maxf(hitstop_timer - delta, 0.0)
	advance_stage_flow(delta)
	queue_redraw()


func advance_stage_flow(delta: float) -> void:
	elapsed_time += delta
	screen_flash_timer = maxf(screen_flash_timer - delta, 0.0)
	var player_ref := get_player()
	if player_ref == null:
		return

	if stage_phase == "approach" and player_ref.global_position.x >= FIRST_FIGHT_TRIGGER_X:
		start_first_fight()

	if stage_phase == "combat" and get_live_enemy_count() == 0:
		trigger_spectacle()

	if stage_phase == "spectacle":
		spectacle_timer = maxf(spectacle_timer - delta, 0.0)
		spectacle_progress = 1.0 - spectacle_timer / SPECTACLE_DURATION
		if spectacle_timer <= 0.0:
			stage_phase = "advance"
			stage_objective = get_mid_stage_objective()
			spectacle_progress = 1.0
	elif spectacle_time >= 0.0:
		spectacle_progress = 1.0

	update_hazard_cycle(delta)

	if stage_phase == "advance" and player_ref.global_position.x >= BOSS_TRIGGER_X:
		start_boss_intro()

	if stage_phase == "boss_intro":
		boss_intro_timer = maxf(boss_intro_timer - delta, 0.0)
		if boss_intro_timer <= 0.0:
			start_boss_fight()

	var boss_actor := get_boss_actor()
	if stage_phase == "boss" and boss_actor != null and boss_actor.is_defeated():
		complete_stage()


func _draw() -> void:
	draw_rect(Rect2(-1200.0, -540.0, 3600.0, 1080.0), SKY_COLOR, true)
	draw_rect(Rect2(-1200.0, -210.0, 3600.0, 380.0), HAZE_COLOR, true)
	draw_rect(Rect2(-1200.0, -120.0, 3600.0, 280.0), MIST_COLOR, true)
	draw_rect(Rect2(-1200.0, 140.0, 3600.0, 420.0), GROUND_COLOR, true)
	draw_background_props()
	draw_foreground_props()
	draw_goal_beacon()
	if stage_phase == "combat":
		draw_opening_barrier()
	if stage_phase == "spectacle" or spectacle_time >= 0.0:
		draw_spectacle_event()
	if stage_phase == "advance" or stage_phase == "boss_intro" or stage_phase == "boss":
		draw_vent_hazards()
	if stage_phase == "boss_intro" or stage_phase == "boss" or stage_complete:
		draw_relay_arena()
	if stage_phase == "boss_intro" or stage_phase == "boss":
		draw_boss_barrier()
	if screen_flash_timer > 0.0:
		draw_rect(Rect2(-1200.0, -540.0, 3600.0, 1080.0), Color(1.0, 0.97, 0.83, minf(screen_flash_timer * 0.34, 0.34)), true)


func draw_background_props() -> void:
	draw_circle(Vector2(-520.0, -120.0), 150.0, Color("0e2430"))
	draw_circle(Vector2(320.0, -180.0), 130.0, COIL_COLOR)
	draw_circle(Vector2(1360.0, -220.0), 220.0, Color("122535"))
	draw_rect(Rect2(760.0, -30.0, 520.0, 24.0), Color("5f86a3"), true)
	draw_rect(Rect2(1140.0, -90.0, 560.0, 22.0), Color("3b5d74"), true)
	draw_line(Vector2(-620.0, -200.0), Vector2(220.0, 20.0), Color(0.84, 0.96, 1.0, 0.42), 7.0)
	draw_line(Vector2(-200.0, -180.0), Vector2(1080.0, 12.0), Color(0.54, 0.87, 1.0, 0.30), 4.0)
	draw_line(Vector2(920.0, -200.0), Vector2(RELAY_CORE_X, -120.0), Color(1.0, 0.79, 0.42, 0.46), 4.0)


func draw_foreground_props() -> void:
	draw_rect(Rect2(-620.0, 112.0, 2700.0, 20.0), Color("a6d9f2"), true)
	draw_rect(Rect2(-700.0, 132.0, 48.0, 186.0), Color("244654"), true)
	draw_rect(Rect2(60.0, 132.0, 48.0, 164.0), Color("244654"), true)
	draw_rect(Rect2(760.0, 132.0, 48.0, 220.0), Color("244654"), true)
	draw_rect(Rect2(1300.0, 132.0, 48.0, 252.0), Color("244654"), true)
	draw_rect(Rect2(CHECKPOINT_POSITION + Vector2(-18.0, -110.0), Vector2(10.0, 110.0)), Color("f9db8a"), true)
	draw_rect(Rect2(CHECKPOINT_POSITION + Vector2(-32.0, -110.0), Vector2(38.0, 12.0)), Color("fff0b7"), true)
	draw_rect(Rect2(260.0, 132.0, 96.0, 180.0), BRUSH_COLOR, true)
	draw_rect(Rect2(1040.0, 132.0, 120.0, 240.0), BRUSH_COLOR, true)
	draw_rect(Rect2(1620.0, 132.0, 132.0, 280.0), BRUSH_COLOR, true)


func draw_goal_beacon() -> void:
	if stage_phase == "approach" or stage_phase == "combat" or stage_phase == "spectacle":
		draw_phase_marker(FIRST_FIGHT_TRIGGER_X, Color("93e0ff"))
	else:
		draw_phase_marker(BOSS_TRIGGER_X, RELAY_COLOR)
		draw_rect(Rect2(Vector2(BOSS_TRIGGER_X - 18.0, -90.0), Vector2(18.0, 230.0)), RELAY_COLOR, true)
		draw_rect(Rect2(Vector2(BOSS_TRIGGER_X - 36.0, -98.0), Vector2(54.0, 16.0)), Color("fff4ba"), true)


func draw_phase_marker(marker_x: float, marker_color: Color) -> void:
	draw_line(Vector2(marker_x, -210.0), Vector2(marker_x, -150.0), marker_color, 5.0)
	draw_circle(Vector2(marker_x, -224.0), 10.0, marker_color)


func draw_opening_barrier() -> void:
	var barrier_alpha := 0.20 + 0.10 * absf(sin(elapsed_time * 5.8))
	var barrier_color := Color(0.51, 0.84, 1.0, barrier_alpha)
	draw_rect(Rect2(Vector2(980.0, -280.0), Vector2(24.0, 440.0)), barrier_color, true)
	draw_rect(Rect2(Vector2(998.0, -280.0), Vector2(16.0, 440.0)), Color(0.89, 0.98, 1.0, barrier_alpha + 0.08), true)


func draw_spectacle_event() -> void:
	var progress := clampf(spectacle_progress, 0.0, 1.0)
	for lane_x in HAZARD_LANES:
		var wave_progress := clampf(progress - absf(lane_x - RELAY_CORE_X) / 2200.0, 0.0, 1.0)
		if wave_progress <= 0.0:
			continue
		var wave_height := 90.0 + 210.0 * wave_progress
		draw_rect(Rect2(Vector2(lane_x - 16.0, 140.0 - wave_height), Vector2(32.0, wave_height)), Color(0.78, 0.93, 1.0, 0.10 + 0.20 * wave_progress), true)
	draw_circle(Vector2(RELAY_CORE_X, -160.0), 48.0 + 34.0 * progress, Color(1.0, 0.83, 0.54, 0.30))
	draw_line(Vector2(RELAY_CORE_X, -160.0), Vector2(1080.0, 18.0), Color(0.98, 0.90, 0.64, 0.62), 5.0)
	draw_line(Vector2(RELAY_CORE_X, -160.0), Vector2(420.0, 16.0), Color(0.84, 0.96, 1.0, 0.48), 4.0)


func draw_relay_arena() -> void:
	draw_circle(Vector2(RELAY_CORE_X, -140.0), 82.0, Color(0.88, 0.96, 1.0, 0.18))
	draw_circle(Vector2(RELAY_CORE_X, -140.0), 44.0, Color(1.0, 0.90, 0.62, 0.34))
	draw_rect(Rect2(Vector2(RELAY_CORE_X - 8.0, -80.0), Vector2(16.0, 220.0)), RELAY_COLOR, true)
	draw_rect(Rect2(Vector2(1180.0, 40.0), Vector2(320.0, 18.0)), Color("7cb0ca"), true)
	draw_rect(Rect2(Vector2(1460.0, -8.0), Vector2(220.0, 18.0)), Color("7cb0ca"), true)
	if boss_seen:
		draw_line(Vector2(1040.0, -60.0), Vector2(1820.0, -60.0), Color(0.55, 0.86, 1.0, 0.20), 3.0)


func draw_boss_barrier() -> void:
	var barrier_alpha := 0.18 + 0.10 * absf(sin(elapsed_time * 6.8))
	draw_rect(Rect2(Vector2(BOSS_ARENA_BOUNDS.x - 14.0, -300.0), Vector2(18.0, 470.0)), Color(0.60, 0.86, 1.0, barrier_alpha), true)
	draw_rect(Rect2(Vector2(BOSS_ARENA_BOUNDS.y + 6.0, -300.0), Vector2(18.0, 470.0)), Color(0.60, 0.86, 1.0, barrier_alpha), true)


func draw_vent_hazards() -> void:
	for lane_x in get_hazard_lane_positions():
		if hazard_state == "telegraph":
			draw_rect(Rect2(Vector2(lane_x - 22.0, 108.0), Vector2(44.0, 32.0)), Color(0.98, 0.86, 0.54, 0.26), true)
			draw_rect(Rect2(Vector2(lane_x - 6.0, -120.0), Vector2(12.0, 260.0)), Color(0.70, 0.88, 1.0, 0.12), true)
		elif hazard_state == "active":
			draw_rect(Rect2(Vector2(lane_x - 18.0, -260.0), Vector2(36.0, 400.0)), Color(0.82, 0.96, 1.0, 0.26), true)
			draw_rect(Rect2(Vector2(lane_x - 30.0, 98.0), Vector2(60.0, 42.0)), Color(1.0, 0.89, 0.54, 0.42), true)
		elif hazard_state == "cooldown":
			draw_rect(Rect2(Vector2(lane_x - 20.0, 110.0), Vector2(40.0, 24.0)), Color(0.69, 0.90, 1.0, 0.10), true)


func get_player() -> CharacterBody2D:
	if player == null:
		return get_node_or_null("Player")
	return player


func get_enemy_nodes() -> Array[EnemyActor]:
	var enemies: Array[EnemyActor] = []
	var root := enemies_root
	if root == null:
		root = get_node_or_null("Enemies")
	if root == null:
		return enemies
	for child in root.get_children():
		if child is EnemyActor:
			enemies.append(child)
	return enemies


func get_boss_actor() -> BossActor:
	if boss == null:
		return get_node_or_null("Boss") as BossActor
	return boss


func get_combat_dummy() -> EnemyActor:
	var enemies := get_enemy_nodes()
	if enemies.is_empty():
		return null
	return enemies[0]


func get_live_enemy_count() -> int:
	var count := 0
	for enemy in get_enemy_nodes():
		if enemy.health > 0:
			count += 1
	return count


func get_elite_enemy() -> EnemyActor:
	for enemy in get_enemy_nodes():
		if enemy.is_elite():
			return enemy
	return null


func get_stage_bounds() -> Vector2:
	match stage_phase:
		"approach", "combat", "spectacle":
			return OPENING_BOUNDS
		"boss_intro", "boss":
			return BOSS_ARENA_BOUNDS
		_:
			return WORLD_BOUNDS


func resolve_player_attack(profile: Dictionary, attacker_position: Vector2, facing: float) -> bool:
	var hit_any := false
	for enemy in get_enemy_nodes():
		if enemy.take_hit(profile, facing, attacker_position):
			hit_any = true
			if not bool(profile.get("is_radial", false)):
				break
	var boss_actor := get_boss_actor()
	if boss_actor != null and boss_actor.visible and boss_actor.take_hit(profile, facing, attacker_position):
		hit_any = true
	if hit_any:
		if stage_phase == "approach":
			start_first_fight()
		apply_hitstop(float(profile.get("hitstop", 0.04)))
	return hit_any


func resolve_enemy_attack(profile: Dictionary, attacker_position: Vector2, facing: float) -> bool:
	if stage_phase == "approach":
		start_first_fight()
	var player_ref := get_player()
	if player_ref != null and player_ref.apply_enemy_attack(profile, facing, attacker_position):
		apply_hitstop(float(profile.get("hitstop", 0.05)))
		if player_ref.get_health() <= 0:
			reset_to_checkpoint()
		return true
	return false


func spawn_enemy_projectile(enemy: EnemyActor, profile: Dictionary) -> void:
	var projectile := ENEMY_PROJECTILE_SCENE.instantiate() as EnemyProjectile
	projectile.stage = self
	projectile.direction = enemy.facing
	projectile.speed = float(profile.get("projectile_speed", 240.0))
	projectile.remaining_distance = float(profile.get("projectile_range", 320.0))
	projectile.radius = float(profile.get("projectile_radius", 20.0))
	projectile.global_position = enemy.global_position + Vector2(24.0 * enemy.facing, -44.0)
	projectile.attack_profile = {
		"id": "%s_projectile" % enemy.enemy_id,
		"damage": int(profile.get("damage", 0)),
		"reach": 26.0,
		"knockback_x": float(profile.get("knockback_x", 0.0)),
		"knockback_y": float(profile.get("knockback_y", -120.0)),
		"stun": float(profile.get("stun", 0.14)),
		"hitstop": float(profile.get("hitstop", 0.03)),
	}
	projectile_root.add_child(projectile)


func spawn_boss_projectiles(origin: Vector2, facing: float, phase_two: bool) -> void:
	var lane_offsets := [-70.0, -30.0, 10.0]
	if phase_two:
		lane_offsets = [-94.0, -54.0, -14.0, 26.0, 66.0]
	for lane_offset in lane_offsets:
		var projectile := ENEMY_PROJECTILE_SCENE.instantiate() as EnemyProjectile
		projectile.stage = self
		projectile.direction = facing
		projectile.speed = 300.0 if not phase_two else 340.0
		projectile.remaining_distance = 500.0
		projectile.radius = 22.0 if not phase_two else 26.0
		projectile.global_position = origin + Vector2(46.0 * facing, lane_offset)
		projectile.attack_profile = {
			"id": "storm_warden_burst",
			"damage": 12 if not phase_two else 14,
			"reach": 30.0,
			"knockback_x": 220.0,
			"knockback_y": -120.0,
			"stun": 0.16,
			"hitstop": 0.03,
		}
		projectile_root.add_child(projectile)


func start_first_fight() -> void:
	if first_combat_time >= 0.0:
		return
	first_combat_time = elapsed_time
	stage_phase = "combat"
	stage_objective = "Break the ventguard ambush"


func trigger_spectacle() -> void:
	if spectacle_time >= 0.0:
		return
	spectacle_time = elapsed_time
	spectacle_timer = SPECTACLE_DURATION
	spectacle_progress = 0.0
	stage_phase = "spectacle"
	stage_objective = "The depth coils overload. Read the vents and push through."
	screen_flash_timer = 1.0


func start_boss_intro() -> void:
	if boss_seen:
		return
	boss_seen = true
	stage_phase = "boss_intro"
	stage_objective = get_boss_intro_objective()
	boss_intro_timer = BOSS_INTRO_DURATION
	screen_flash_timer = 0.8
	var boss_actor := get_boss_actor()
	if boss_actor != null:
		boss_actor.begin_intro(BOSS_SPAWN_POSITION, BOSS_INTRO_DURATION)


func start_boss_fight() -> void:
	stage_phase = "boss"
	stage_objective = get_boss_objective()
	var boss_actor := get_boss_actor()
	if boss_actor != null:
		boss_actor.activate()


func complete_stage() -> void:
	if stage_complete:
		return
	stage_complete = true
	finish_time = elapsed_time
	stage_phase = "clear"
	stage_objective = get_clear_objective()
	screen_flash_timer = 0.9


func reset_to_checkpoint() -> void:
	checkpoint_reset_count += 1
	var player_ref := get_player()
	var projectile_container := projectile_root
	if projectile_container == null:
		projectile_container = get_node_or_null("Projectiles")
	if player_ref != null:
		player_ref.reset_to_checkpoint(CHECKPOINT_POSITION)
	for enemy in get_enemy_nodes():
		enemy.stage = self
		enemy.reset_to_spawn(ENEMY_SPAWNS.get(enemy.name, enemy.global_position))
	var boss_actor := get_boss_actor()
	if boss_actor != null:
		boss_actor.stage = self
		boss_actor.reset_to_spawn(BOSS_SPAWN_POSITION)
	if projectile_container != null:
		for projectile in projectile_container.get_children():
			projectile.queue_free()
	hitstop_timer = 0.0
	elapsed_time = 0.0
	stage_phase = "approach"
	stage_objective = get_opening_objective()
	first_combat_time = -1.0
	spectacle_time = -1.0
	finish_time = -1.0
	spectacle_timer = 0.0
	spectacle_progress = 0.0
	boss_intro_timer = 0.0
	boss_seen = false
	stage_complete = false
	screen_flash_timer = 0.0
	hazard_state = "idle"
	hazard_timer = 0.0
	hazard_lane_index = -1
	hazard_cycle_count = 0


func is_hitstop_active() -> bool:
	return hitstop_timer > 0.0


func apply_hitstop(duration: float) -> void:
	hitstop_timer = maxf(hitstop_timer, duration)


func get_audio_state() -> String:
	match stage_phase:
		"combat":
			return "combat"
		"spectacle":
			return "spectacle"
		"boss_intro", "boss":
			return "boss"
		"clear":
			return "victory"
		_:
			return "explore"


func update_hazard_cycle(delta: float) -> void:
	if not (stage_phase == "advance" or stage_phase == "boss_intro" or stage_phase == "boss"):
		hazard_state = "idle"
		hazard_timer = 0.0
		return
	hazard_timer = maxf(hazard_timer - delta, 0.0)
	match hazard_state:
		"idle":
			start_hazard_telegraph()
		"telegraph":
			if hazard_timer <= 0.0:
				hazard_state = "active"
				hazard_timer = HAZARD_ACTIVE_DURATION
				screen_flash_timer = maxf(screen_flash_timer, 0.22)
		"active":
			apply_hazard_damage()
			if hazard_timer <= 0.0:
				hazard_state = "cooldown"
				hazard_timer = HAZARD_COOLDOWN_DURATION
		"cooldown":
			if hazard_timer <= 0.0:
				start_hazard_telegraph()


func start_hazard_telegraph() -> void:
	hazard_lane_index = wrapi(hazard_lane_index + 1, 0, HAZARD_LANES.size())
	hazard_state = "telegraph"
	hazard_timer = HAZARD_TELEGRAPH_DURATION
	hazard_cycle_count += 1


func get_hazard_lane_positions() -> Array[float]:
	if hazard_lane_index < 0:
		return []
	var active_lanes: Array[float] = [HAZARD_LANES[hazard_lane_index]]
	if stage_phase == "boss":
		active_lanes.append(HAZARD_LANES[(hazard_lane_index + 2) % HAZARD_LANES.size()])
	return active_lanes


func apply_hazard_damage() -> void:
	var player_ref := get_player()
	if player_ref == null:
		return
	for lane_x in get_hazard_lane_positions():
		if absf(player_ref.global_position.x - lane_x) > HAZARD_RADIUS:
			continue
		var facing := 1.0 if player_ref.global_position.x >= lane_x else -1.0
		var hit: bool = player_ref.apply_enemy_attack({
			"id": "depth_vent_burst",
			"damage": 14,
			"reach": HAZARD_RADIUS,
			"knockback_x": 240.0,
			"knockback_y": -190.0,
			"stun": 0.18,
			"hitstop": 0.03,
		}, facing, Vector2(lane_x, player_ref.global_position.y))
		if hit:
			apply_hitstop(0.03)
			if player_ref.get_health() <= 0:
				reset_to_checkpoint()
			return


func get_stage_summary() -> Dictionary:
	var boss_actor := get_boss_actor()
	var boss_active := false
	var boss_name := "Storm Warden"
	var boss_state := "hidden"
	var boss_health_ratio := 0.0
	if boss_actor != null:
		boss_active = boss_actor.visible and not boss_actor.is_defeated()
		boss_name = boss_actor.get_display_name()
		boss_state = boss_actor.get_state_name()
		boss_health_ratio = boss_actor.get_health_ratio()
	return {
		"stage_id": stage_id,
		"stage_name": get_stage_name(),
		"phase": stage_phase,
		"objective": stage_objective,
		"elapsed_seconds": elapsed_time,
		"first_combat_seconds": first_combat_time,
		"spectacle_seconds": spectacle_time,
		"finish_seconds": finish_time,
		"stage_complete": stage_complete,
		"spectacle_target_seconds": SPECTACLE_TARGET_SECONDS,
		"checkpoint_resets": checkpoint_reset_count - 1,
		"live_enemy_count": get_live_enemy_count(),
		"audio_state": get_audio_state(),
		"rank": get_rank_label(),
		"boss_active": boss_active,
		"boss_name": boss_name,
			"boss_state": boss_state,
			"boss_health_ratio": boss_health_ratio,
			"boss_seen": boss_seen,
			"hazard_state": hazard_state,
			"hazard_cycle_count": hazard_cycle_count,
		}


func get_rank_label() -> String:
	if finish_time < 0.0:
		return "--"
	if finish_time <= 140.0:
		return "S"
	if finish_time <= 185.0:
		return "A"
	if finish_time <= 240.0:
		return "B"
	return "C"


func get_debug_stage_status() -> String:
	var boss_actor := get_boss_actor()
	var boss_state := "hidden"
	if boss_actor != null:
		boss_state = boss_actor.get_state_name()
	return "Phase: %s  Objective: %s  Enemies: %d/4  Boss: %s  Hazard: %s  Combat: %s  Spectacle: %s" % [
		stage_phase,
		stage_objective,
		get_live_enemy_count(),
		boss_state,
		hazard_state,
		format_optional_seconds(first_combat_time),
		format_optional_seconds(spectacle_time),
	]


func format_optional_seconds(value: float) -> String:
	if value < 0.0:
		return "--"
	return "%.1fs" % value


func get_stage_name() -> String:
	return str(stage_definition.get("name", "Coil Depths"))


func get_opening_objective() -> String:
	return str(stage_definition.get("opening_objective", "Descend into the coil depths"))


func get_mid_stage_objective() -> String:
	return str(stage_definition.get("mid_objective", "Read the surge vents and push for the depth core"))


func get_boss_intro_objective() -> String:
	return str(stage_definition.get("boss_intro_objective", "Brace for the colossus in the depth core"))


func get_boss_objective() -> String:
	return str(stage_definition.get("boss_objective", "Break the Rift Colossus"))


func get_clear_objective() -> String:
	return str(stage_definition.get("clear_objective", "Depth core stabilized. Stage clear."))
