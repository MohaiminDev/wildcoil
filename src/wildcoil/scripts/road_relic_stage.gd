extends "res://scripts/stage_stub.gd"

const ROAD_SKY := Color("10171c")
const ROAD_HAZE := Color("24303a")
const ROAD_DUST := Color("4f4739")
const ROAD_ASPHALT := Color("2c2f33")
const ROAD_SHOULDER := Color("80684c")
const SUN_COLOR := Color("f4c56f")
const BONE_COLOR := Color("e9dfc4")
const CAR_BODY := Color("6bc0c8")
const CAR_TRIM := Color("f4e8b0")
const TAR_COLOR := Color("181714")

var roadster_setpiece_seen := false


func _draw() -> void:
	draw_rect(Rect2(-1200.0, -540.0, 3600.0, 1080.0), ROAD_SKY, true)
	draw_rect(Rect2(-1200.0, -230.0, 3600.0, 400.0), ROAD_HAZE, true)
	draw_rect(Rect2(-1200.0, 36.0, 3600.0, 360.0), ROAD_DUST, true)
	draw_rect(Rect2(-1200.0, 118.0, 3600.0, 72.0), ROAD_ASPHALT, true)
	draw_rect(Rect2(-1200.0, 190.0, 3600.0, 360.0), ROAD_SHOULDER, true)
	draw_road_marks()
	draw_fossil_backdrop()
	draw_roadside_relics()
	draw_goal_beacon()
	if stage_phase == "combat":
		draw_junk_barricade()
	if stage_phase == "spectacle" or spectacle_time >= 0.0:
		draw_spectacle_event()
	if stage_phase == "boss_intro" or stage_phase == "boss" or stage_complete:
		draw_boss_arena()
	if stage_phase == "boss_intro" or stage_phase == "boss":
		draw_boss_barrier()
	if screen_flash_timer > 0.0:
		draw_rect(Rect2(-1200.0, -540.0, 3600.0, 1080.0), Color(1.0, 0.92, 0.70, minf(screen_flash_timer * 0.28 * screen_flash_strength, 0.28 * screen_flash_strength)), true)


func draw_road_marks() -> void:
	for marker_index in range(12):
		var marker_x := -1060.0 + float(marker_index) * 280.0
		draw_rect(Rect2(Vector2(marker_x, 148.0), Vector2(116.0, 8.0)), Color("d9c98f"), true)


func draw_fossil_backdrop() -> void:
	draw_circle(Vector2(-520.0, -150.0), 106.0, SUN_COLOR)
	draw_line(Vector2(-120.0, 42.0), Vector2(160.0, -118.0), BONE_COLOR, 10.0)
	draw_line(Vector2(160.0, -118.0), Vector2(360.0, 18.0), BONE_COLOR, 10.0)
	draw_circle(Vector2(390.0, 10.0), 38.0, Color(0.91, 0.87, 0.76, 0.55))
	for rib_index in range(5):
		var rib_x := 20.0 + float(rib_index) * 54.0
		draw_arc(Vector2(rib_x, -34.0), 44.0, PI * 0.12, PI * 0.88, 16, BONE_COLOR, 5.0)
	draw_rect(Rect2(760.0, 10.0, 620.0, 22.0), Color("6d5d4b"), true)
	draw_rect(Rect2(860.0, -18.0, 34.0, 118.0), Color("6d5d4b"), true)
	draw_rect(Rect2(1240.0, -44.0, 34.0, 146.0), Color("6d5d4b"), true)


func draw_roadside_relics() -> void:
	draw_roadster(Vector2(-360.0, 112.0), -1.0, 0.82, Color("b45a42"))
	draw_roadster(Vector2(520.0, 112.0), 1.0, 0.72, Color("596f9d"))
	draw_rect(Rect2(Vector2(1040.0, 126.0), Vector2(220.0, 32.0)), TAR_COLOR, true)
	draw_rect(Rect2(Vector2(1100.0, 90.0), Vector2(82.0, 48.0)), Color("343332"), true)
	draw_circle(Vector2(1040.0, 140.0), 18.0, Color("111111"))
	draw_circle(Vector2(1228.0, 140.0), 18.0, Color("111111"))


func draw_goal_beacon() -> void:
	if stage_phase == "approach" or stage_phase == "combat" or stage_phase == "spectacle":
		draw_phase_marker(FIRST_FIGHT_TRIGGER_X, Color("f4dd9b"))
	else:
		draw_phase_marker(BOSS_TRIGGER_X, Color("ffe6a0"))
		draw_rect(Rect2(Vector2(BOSS_TRIGGER_X - 20.0, -82.0), Vector2(20.0, 222.0)), BONE_COLOR, true)
		draw_circle(Vector2(BOSS_TRIGGER_X - 10.0, -96.0), 22.0, BONE_COLOR)


func draw_junk_barricade() -> void:
	var barrier_alpha := get_pulse_alpha(0.22, 0.08, 5.2)
	draw_rect(Rect2(Vector2(742.0, 70.0), Vector2(34.0, 82.0)), Color(0.95, 0.69, 0.34, barrier_alpha), true)
	draw_rect(Rect2(Vector2(772.0, 78.0), Vector2(60.0, 20.0)), Color(0.98, 0.88, 0.58, barrier_alpha + 0.08), true)
	draw_rect(Rect2(Vector2(778.0, 112.0), Vector2(70.0, 20.0)), Color(0.98, 0.88, 0.58, barrier_alpha + 0.08), true)


func draw_spectacle_event() -> void:
	var progress := clampf(spectacle_progress, 0.0, 1.0)
	var car_x := lerpf(-900.0, 1160.0, progress)
	var dust_alpha := 0.18 + sin(progress * PI) * 0.22
	draw_rect(Rect2(Vector2(car_x - 220.0, 92.0), Vector2(380.0, 82.0)), Color(0.92, 0.74, 0.45, dust_alpha), true)
	draw_roadster(Vector2(car_x, 110.0), 1.0, 1.15, CAR_BODY)
	draw_line(Vector2(car_x + 68.0, 78.0), Vector2(car_x + 160.0, 38.0), Color(1.0, 0.92, 0.58, 0.55), 6.0)
	draw_circle(Vector2(car_x + 180.0, 28.0), 22.0, Color(1.0, 0.84, 0.46, 0.34))
	for pack_index in range(3):
		var runner_x := car_x - 160.0 - float(pack_index) * 92.0
		draw_line(Vector2(runner_x, 124.0), Vector2(runner_x + 36.0, 94.0), Color("5faf7c"), 8.0)
		draw_circle(Vector2(runner_x + 48.0, 84.0), 12.0, Color("5faf7c"))
	roadster_setpiece_seen = true


func draw_boss_arena() -> void:
	draw_rect(Rect2(Vector2(980.0, 104.0), Vector2(460.0, 22.0)), Color("b29562"), true)
	draw_circle(Vector2(RELAY_CORE_X, -130.0), 70.0, Color(1.0, 0.80, 0.42, 0.18))
	draw_line(Vector2(RELAY_CORE_X - 80.0, -88.0), Vector2(RELAY_CORE_X + 80.0, -172.0), BONE_COLOR, 9.0)
	draw_line(Vector2(RELAY_CORE_X - 70.0, -162.0), Vector2(RELAY_CORE_X + 88.0, -82.0), BONE_COLOR, 9.0)
	draw_rect(Rect2(Vector2(RELAY_CORE_X - 9.0, -78.0), Vector2(18.0, 218.0)), Color("ffe6a0"), true)


func draw_boss_barrier() -> void:
	var barrier_alpha := get_pulse_alpha(0.18, 0.10, 6.0)
	draw_rect(Rect2(Vector2(BOSS_ARENA_BOUNDS.x - 14.0, -300.0), Vector2(18.0, 470.0)), Color(1.0, 0.79, 0.44, barrier_alpha), true)
	draw_rect(Rect2(Vector2(BOSS_ARENA_BOUNDS.y + 6.0, -300.0), Vector2(18.0, 470.0)), Color(1.0, 0.79, 0.44, barrier_alpha), true)


func draw_roadster(origin: Vector2, direction: float, scale: float, body_color: Color) -> void:
	draw_rect(Rect2(origin + Vector2(-74.0, -38.0) * scale, Vector2(148.0, 42.0) * scale), body_color, true)
	draw_rect(Rect2(origin + Vector2(-34.0, -70.0) * scale, Vector2(74.0, 36.0) * scale), body_color.lightened(0.22), true)
	draw_rect(Rect2(origin + Vector2(8.0 * direction, -62.0) * scale, Vector2(34.0, 22.0) * scale), CAR_TRIM, true)
	draw_rect(Rect2(origin + Vector2(58.0 * direction, -28.0) * scale, Vector2(34.0, 14.0) * scale), CAR_TRIM, true)
	draw_circle(origin + Vector2(-48.0, 2.0) * scale, 18.0 * scale, Color("111111"))
	draw_circle(origin + Vector2(50.0, 2.0) * scale, 18.0 * scale, Color("111111"))
	draw_circle(origin + Vector2(-48.0, 2.0) * scale, 8.0 * scale, Color("cfd3cf"))
	draw_circle(origin + Vector2(50.0, 2.0) * scale, 8.0 * scale, Color("cfd3cf"))


func trigger_spectacle() -> void:
	if spectacle_time >= 0.0:
		return
	super.trigger_spectacle()
	roadster_setpiece_seen = true
	stage_objective = str(stage_definition.get("spectacle_objective", "Roadster charge breaks the fossil blockade. Push through."))


func reset_to_checkpoint() -> void:
	super.reset_to_checkpoint()
	roadster_setpiece_seen = false


func get_stage_summary() -> Dictionary:
	var summary := super.get_stage_summary()
	summary["roadster_setpiece_seen"] = roadster_setpiece_seen
	return summary
