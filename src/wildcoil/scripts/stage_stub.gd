extends Node2D

const ENEMY_PROJECTILE_SCENE = preload("res://scenes/enemy_projectile.tscn")

const CHECKPOINT_POSITION := Vector2(-500.0, 140.0)
const ENEMY_SPAWNS := {
	"NeedleHound": Vector2(60.0, 140.0),
	"SporeSlinger": Vector2(320.0, 140.0),
	"CoilBrute": Vector2(560.0, 140.0),
}

@onready var player: PlayerController = $Player
@onready var enemies_root: Node2D = $Enemies
@onready var projectile_root: Node2D = $Projectiles

const SKY_COLOR := Color("0b1720")
const MIST_COLOR := Color("183342")
const GROUND_COLOR := Color("2e4a39")
const COIL_COLOR := Color("6ee0b5")
const SPARK_COLOR := Color("ffc65c")

var checkpoint_reset_count := 0
var hitstop_timer := 0.0


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
		apply_hitstop(float(profile.get("hitstop", 0.04)))
	return hit_any


func resolve_enemy_attack(profile: Dictionary, attacker_position: Vector2, facing: float) -> bool:
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


func is_hitstop_active() -> bool:
	return hitstop_timer > 0.0


func apply_hitstop(duration: float) -> void:
	hitstop_timer = maxf(hitstop_timer, duration)


func get_debug_stage_status() -> String:
	var elite_enemy := get_elite_enemy()
	var elite_state := "none"
	var projectile_count := 0
	var projectile_container := projectile_root
	if projectile_container == null:
		projectile_container = get_node_or_null("Projectiles")
	if projectile_container != null:
		projectile_count = projectile_container.get_child_count()
	if elite_enemy != null:
		elite_state = elite_enemy.get_state_name()
	return "Enemies up: %d/3  Elite: %s  Projectiles: %d  Checkpoint resets: %d" % [
		get_live_enemy_count(),
		elite_state,
		projectile_count,
		checkpoint_reset_count - 1,
	]
