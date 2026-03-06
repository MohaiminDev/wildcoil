extends Node2D

const ENEMY_PROJECTILE_SCENE = preload("res://scenes/enemy_projectile.tscn")

const CHECKPOINT_POSITION := Vector2(-500.0, 140.0)
const ENEMY_SPAWNS := {
	"NeedleHound": Vector2(60.0, 140.0),
	"SporeSlinger": Vector2(320.0, 140.0),
	"CoilBrute": Vector2(560.0, 140.0),
}
const FIRST_FIGHT_TRIGGER_X := -120.0
const EXIT_TRIGGER_X := 720.0
const SPECTACLE_DURATION := 3.6
const SPECTACLE_TARGET_SECONDS := 180.0

@onready var player: PlayerController = $Player
@onready var enemies_root: Node2D = $Enemies
@onready var projectile_root: Node2D = $Projectiles

const SKY_COLOR := Color("0b1720")
const MIST_COLOR := Color("183342")
const GROUND_COLOR := Color("2e4a39")
const COIL_COLOR := Color("6ee0b5")
const SPARK_COLOR := Color("ffc65c")
const RELAY_COLOR := Color("dffff3")

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
var stage_complete := false
var screen_flash_timer := 0.0


func _ready() -> void:
	var player_ref := get_player()
	if player_ref != null:
		player_ref.stage = self
	for enemy in get_enemy_nodes():
		enemy.stage = self
	reset_to_checkpoint()
	queue_redraw()


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
			stage_objective = "Reach the energized relay beacon"
			spectacle_progress = 1.0
	elif spectacle_time >= 0.0:
		spectacle_progress = 1.0

	if stage_phase == "advance" and player_ref.global_position.x >= EXIT_TRIGGER_X:
		complete_stage()


func _draw() -> void:
	draw_rect(Rect2(-960.0, -540.0, 1920.0, 1080.0), SKY_COLOR, true)
	draw_rect(Rect2(-960.0, -160.0, 1920.0, 300.0), MIST_COLOR, true)
	draw_rect(Rect2(-960.0, 140.0, 1920.0, 400.0), GROUND_COLOR, true)
	draw_rect(Rect2(80.0, 20.0, 280.0, 24.0), Color("7cbca2"), true)
	draw_circle(Vector2(-420.0, -60.0), 170.0, COIL_COLOR)
	draw_circle(Vector2(260.0, -120.0), 110.0, SPARK_COLOR)
	draw_rect(Rect2(-520.0, 112.0, 980.0, 20.0), Color("8fdac0"), true)
	draw_rect(Rect2(-620.0, 132.0, 44.0, 168.0), Color("264634"), true)
	draw_rect(Rect2(300.0, 132.0, 44.0, 168.0), Color("264634"), true)
	draw_line(Vector2(-470.0, -130.0), Vector2(360.0, 24.0), Color("d7fff0"), 9.0)
	draw_line(Vector2(-440.0, -178.0), Vector2(384.0, -20.0), Color("4bdca7"), 4.0)
	draw_line(Vector2(160.0, 30.0), Vector2(280.0, -82.0), Color("ffc65c"), 4.0)
	draw_rect(Rect2(CHECKPOINT_POSITION + Vector2(-18.0, -110.0), Vector2(10.0, 110.0)), Color("f9db8a"), true)
	draw_rect(Rect2(CHECKPOINT_POSITION + Vector2(-32.0, -110.0), Vector2(38.0, 12.0)), Color("fff0b7"), true)

	draw_goal_beacon()
	draw_phase_marker()
	if stage_phase == "combat":
		draw_combat_barrier()
	if spectacle_time >= 0.0:
		draw_spectacle_event()
	if screen_flash_timer > 0.0:
		draw_rect(Rect2(-960.0, -540.0, 1920.0, 1080.0), Color(1.0, 0.97, 0.83, minf(screen_flash_timer * 0.32, 0.32)), true)


func draw_goal_beacon() -> void:
	var beacon_color := Color("5a7f72")
	if stage_phase == "advance" or stage_complete:
		beacon_color = Color("dffff3")
	draw_rect(Rect2(Vector2(EXIT_TRIGGER_X - 14.0, -90.0), Vector2(18.0, 230.0)), beacon_color, true)
	draw_rect(Rect2(Vector2(EXIT_TRIGGER_X - 36.0, -98.0), Vector2(54.0, 16.0)), Color("fff4ba"), true)
	if stage_phase == "advance" or stage_complete:
		draw_circle(Vector2(EXIT_TRIGGER_X - 4.0, -112.0), 24.0 + 6.0 * sin(elapsed_time * 4.0), Color(0.88, 1.0, 0.95, 0.25))


func draw_phase_marker() -> void:
	var marker_x := FIRST_FIGHT_TRIGGER_X
	var marker_color := Color("9de7cb")
	if stage_phase == "advance" or stage_complete or spectacle_time >= 0.0:
		marker_x = EXIT_TRIGGER_X
		marker_color = RELAY_COLOR
	draw_line(Vector2(marker_x, -210.0), Vector2(marker_x, -150.0), marker_color, 5.0)
	draw_circle(Vector2(marker_x, -224.0), 10.0, marker_color)


func draw_combat_barrier() -> void:
	var barrier_alpha := 0.18 + 0.10 * absf(sin(elapsed_time * 5.0))
	var barrier_color := Color(0.47, 0.94, 0.78, barrier_alpha)
	draw_rect(Rect2(Vector2(EXIT_TRIGGER_X - 36.0, -260.0), Vector2(18.0, 420.0)), barrier_color, true)
	draw_rect(Rect2(Vector2(EXIT_TRIGGER_X - 20.0, -260.0), Vector2(14.0, 420.0)), Color(0.85, 1.0, 0.95, barrier_alpha + 0.06), true)


func draw_spectacle_event() -> void:
	var progress := spectacle_progress
	if progress < 1.0:
		progress = clampf(progress, 0.0, 1.0)
	var head_position := Vector2(lerpf(-860.0, 900.0, progress), -250.0 - sin(progress * PI) * 120.0)
	for segment_index in range(7):
		var segment_progress := progress - float(segment_index) * 0.06
		if segment_progress < 0.0:
			continue
		var segment_position := Vector2(lerpf(-900.0, 860.0, segment_progress), -220.0 - sin(segment_progress * PI) * (110.0 - 8.0 * float(segment_index)))
		draw_circle(segment_position, 58.0 - float(segment_index) * 5.5, Color(0.51, 0.98, 0.82, 0.20 + float(segment_index) * 0.03))
	draw_circle(head_position, 46.0, Color("fff0b7"))
	draw_line(head_position + Vector2(-40.0, -10.0), head_position + Vector2(44.0, 14.0), Color("103e34"), 4.0)
	draw_line(head_position + Vector2(50.0, 18.0), Vector2(EXIT_TRIGGER_X - 12.0, -100.0), Color(0.97, 0.87, 0.38, 0.72), 5.0)
	draw_line(Vector2(EXIT_TRIGGER_X - 12.0, -100.0), Vector2(280.0, 24.0), Color(0.95, 0.99, 0.87, 0.54), 4.0)


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


func resolve_player_attack(profile: Dictionary, attacker_position: Vector2, facing: float) -> bool:
	var hit_any := false
	for enemy in get_enemy_nodes():
		if enemy.take_hit(profile, facing, attacker_position):
			hit_any = true
			if not bool(profile.get("is_radial", false)):
				break
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


func start_first_fight() -> void:
	if first_combat_time >= 0.0:
		return
	first_combat_time = elapsed_time
	stage_phase = "combat"
	stage_objective = "Clear the scavenger pack"


func trigger_spectacle() -> void:
	if spectacle_time >= 0.0:
		return
	spectacle_time = elapsed_time
	spectacle_timer = SPECTACLE_DURATION
	spectacle_progress = 0.0
	stage_phase = "spectacle"
	stage_objective = "The relay wakes up. Push through the surge."
	screen_flash_timer = 1.0


func complete_stage() -> void:
	if stage_complete:
		return
	stage_complete = true
	finish_time = elapsed_time
	stage_phase = "clear"
	stage_objective = "Stage clear. Press R to rerun the checkpoint."


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
	if projectile_container != null:
		for projectile in projectile_container.get_children():
			projectile.queue_free()
	hitstop_timer = 0.0
	elapsed_time = 0.0
	stage_phase = "approach"
	stage_objective = "Push into the relay clearing"
	first_combat_time = -1.0
	spectacle_time = -1.0
	finish_time = -1.0
	spectacle_timer = 0.0
	spectacle_progress = 0.0
	stage_complete = false
	screen_flash_timer = 0.0


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
		"advance", "clear":
			return "victory"
		_:
			return "explore"


func get_stage_summary() -> Dictionary:
	return {
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
	}


func get_rank_label() -> String:
	if finish_time < 0.0:
		return "--"
	if finish_time <= 80.0:
		return "S"
	if finish_time <= 110.0:
		return "A"
	if finish_time <= 150.0:
		return "B"
	return "C"


func get_debug_stage_status() -> String:
	return "Phase: %s  Objective: %s  Enemies: %d/3  Combat: %s  Spectacle: %s  Resets: %d" % [
		stage_phase,
		stage_objective,
		get_live_enemy_count(),
		format_optional_seconds(first_combat_time),
		format_optional_seconds(spectacle_time),
		checkpoint_reset_count - 1,
	]


func format_optional_seconds(value: float) -> String:
	if value < 0.0:
		return "--"
	return "%.1fs" % value
