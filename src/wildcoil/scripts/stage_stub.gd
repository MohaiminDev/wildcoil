extends Node2D

const CHECKPOINT_POSITION := Vector2(-500.0, 140.0)
const DUMMY_POSITION := Vector2(140.0, 140.0)

@onready var player: PlayerController = $Player
@onready var combat_dummy: CombatDummy = $CombatDummy

const SKY_COLOR := Color("0b1720")
const MIST_COLOR := Color("183342")
const GROUND_COLOR := Color("2e4a39")
const COIL_COLOR := Color("6ee0b5")
const SPARK_COLOR := Color("ffc65c")

var checkpoint_reset_count := 0
var hitstop_timer := 0.0


func _ready() -> void:
	var player_ref := get_player()
	var dummy_ref := get_combat_dummy()
	if player_ref != null:
		player_ref.stage = self
	if dummy_ref != null:
		dummy_ref.stage = self
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


func get_combat_dummy() -> CombatDummy:
	if combat_dummy == null:
		return get_node_or_null("CombatDummy")
	return combat_dummy


func resolve_player_attack(profile: Dictionary, attacker_position: Vector2, facing: float) -> bool:
	var dummy_ref := get_combat_dummy()
	if dummy_ref != null and dummy_ref.take_hit(profile, facing, attacker_position):
		apply_hitstop(float(profile.get("hitstop", 0.04)))
		return true
	return false


func resolve_dummy_attack(profile: Dictionary, attacker_position: Vector2, facing: float) -> bool:
	var player_ref := get_player()
	if player_ref != null and player_ref.apply_enemy_attack(profile, facing, attacker_position):
		apply_hitstop(float(profile.get("hitstop", 0.05)))
		if player_ref.get_health() <= 0:
			reset_to_checkpoint()
		return true
	return false


func reset_to_checkpoint() -> void:
	checkpoint_reset_count += 1
	var player_ref := get_player()
	var dummy_ref := get_combat_dummy()
	if player_ref != null:
		player_ref.reset_to_checkpoint(CHECKPOINT_POSITION)
	if dummy_ref != null:
		dummy_ref.stage = self
		dummy_ref.reset_to_spawn(DUMMY_POSITION)
	hitstop_timer = 0.0


func is_hitstop_active() -> bool:
	return hitstop_timer > 0.0


func apply_hitstop(duration: float) -> void:
	hitstop_timer = maxf(hitstop_timer, duration)


func get_debug_stage_status() -> String:
	var dummy_ref := get_combat_dummy()
	if dummy_ref == null:
		return "Dummy systems booting"
	return "Dummy HP: %d  Dummy state: %s  Checkpoint resets: %d" % [
		dummy_ref.health,
		dummy_ref.get_state_name(),
		checkpoint_reset_count - 1,
	]
