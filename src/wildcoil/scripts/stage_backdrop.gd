extends Node2D
class_name StageBackdrop

var stage_data := {}
var palette := {}
var biome := "sunset_highway"
var time := 0.0
var particle_specs: Array = []

func configure(next_stage_data: Dictionary, next_palette: Dictionary) -> void:
	stage_data = next_stage_data
	palette = next_palette
	biome = stage_data.get("biome", "sunset_highway")
	_build_particle_specs()
	queue_redraw()

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	_draw_gradient_sky()
	_draw_far_landforms()
	_draw_parallax_ruins()
	_draw_vehicle_set_piece()
	_draw_luma_particles()
	_draw_foreground_atmosphere()

func _draw_gradient_sky() -> void:
	var sky: Color = palette.get("sky", Color(0.94, 0.46, 0.18))
	for i in range(18):
		var t := float(i) / 17.0
		var band: Color = sky.darkened(t * 0.38).lightened((1.0 - t) * 0.12)
		draw_rect(Rect2(0, i * 22, 1280, 24), band)
	var glow_color: Color = palette.get("accent", Color(0.2, 1.0, 0.58))
	draw_circle(Vector2(1030, 112), 116, Color(glow_color.r, glow_color.g, glow_color.b, 0.13))
	draw_circle(Vector2(1030, 112), 72 + sin(time * 0.8) * 6, Color(1.0, 0.78, 0.28, 0.72))

func _draw_far_landforms() -> void:
	var shadow: Color = palette.get("shadow", Color(0.09, 0.13, 0.14, 0.45))
	for i in range(5):
		var x := -80 + i * 300 + sin(time * 0.12 + i) * 8
		var peak := 160 + (i % 2) * 35
		draw_polygon([
			Vector2(x, 330),
			Vector2(x + 160, peak),
			Vector2(x + 350, 330)
		], [shadow.darkened(0.15)])
	if biome == "storm_badlands" or biome == "rift_citadel":
		for i in range(4):
			var x1 := 170 + i * 290 + sin(time * 1.8 + i) * 24
			draw_line(Vector2(x1, 52), Vector2(x1 - 46, 162), palette.get("accent", Color.WHITE), 3.0)
			draw_line(Vector2(x1 - 46, 162), Vector2(x1 + 22, 238), palette.get("accent", Color.WHITE), 2.0)

func _draw_parallax_ruins() -> void:
	var shadow: Color = palette.get("shadow", Color(0.09, 0.13, 0.14, 0.45))
	var accent: Color = palette.get("accent", Color(0.2, 1.0, 0.58))
	for i in range(8):
		var x := 40 + i * 175 + sin(time * 0.22 + i) * 9
		var h := 125 + (i % 4) * 36
		draw_rect(Rect2(x, 292 - h, 70, h), shadow)
		draw_rect(Rect2(x + 10, 304 - h, 10, h - 20), shadow.lightened(0.08))
		draw_rect(Rect2(x + 38, 304 - h, 10, h - 28), shadow.lightened(0.06))
		if i % 2 == 0:
			draw_rect(Rect2(x + 14, 276 - h, 26, 8), accent.darkened(0.1))
	for i in range(9):
		var vine_x := 20 + i * 150 + sin(time * 0.85 + i) * 5
		draw_line(Vector2(vine_x, 190), Vector2(vine_x - 16, 360), Color(0.04, 0.45, 0.18, 0.74), 5.0)
		draw_circle(Vector2(vine_x - 10, 250 + sin(time + i) * 8), 12, Color(0.10, 0.60, 0.28, 0.6))

func _draw_vehicle_set_piece() -> void:
	if biome == "crystal_canyon":
		for i in range(7):
			var x := i * 210 - fmod(time * 90.0, 210.0)
			draw_rect(Rect2(x, 314, 145, 32), Color(0.13, 0.13, 0.16))
			draw_circle(Vector2(x + 24, 350), 13, Color(0.03, 0.03, 0.04))
			draw_circle(Vector2(x + 110, 350), 13, Color(0.03, 0.03, 0.04))
	elif biome == "storm_badlands":
		var x := 180 + sin(time * 1.2) * 34
		draw_polygon([Vector2(x - 110, 318), Vector2(x - 60, 270), Vector2(x + 70, 264), Vector2(x + 122, 310), Vector2(x + 90, 344), Vector2(x - 90, 344)], [Color(0.88, 0.44, 0.16)])
		for wheel_x in [x - 70, x + 82]:
			draw_circle(Vector2(wheel_x, 350), 28, Color(0.03, 0.03, 0.04))
			draw_circle(Vector2(wheel_x, 350), 12, Color(0.9, 0.78, 0.45))
	else:
		for i in range(3):
			var x2 := 175 + i * 320 + sin(time * 0.2 + i) * 18
			var y2 := 258 + (i % 2) * 24
			draw_polygon([Vector2(x2 - 70, y2), Vector2(x2 + 5, y2 - 62), Vector2(x2 + 82, y2 - 24), Vector2(x2 + 44, y2 + 9), Vector2(x2 - 28, y2 + 12)], [Color(0.02, 0.05, 0.06, 0.48)])
			draw_line(Vector2(x2 + 54, y2 - 16), Vector2(x2 + 116, y2 - 52), Color(0.02, 0.05, 0.06, 0.42), 8.0)

func _draw_luma_particles() -> void:
	var accent: Color = palette.get("accent", Color(0.2, 1.0, 0.58))
	for spec in particle_specs:
		var phase: float = time * float(spec["speed"]) + float(spec["phase"])
		var pos: Vector2 = spec["pos"] + Vector2(sin(phase) * float(spec["sway"]), -fmod(time * float(spec["rise"]) + float(spec["offset"]), 380.0))
		while pos.y < 40:
			pos.y += 380.0
		draw_circle(pos, spec["radius"], Color(accent.r, accent.g, accent.b, 0.22 + sin(phase) * 0.14))

func _draw_foreground_atmosphere() -> void:
	var accent: Color = palette.get("accent", Color(0.2, 1.0, 0.58))
	for i in range(12):
		var x := -80 + i * 130 + fmod(time * (18 + i % 3 * 9), 180.0)
		draw_line(Vector2(x, 625), Vector2(x + 34, 560), Color(accent.r, accent.g, accent.b, 0.18), 2.0)
	draw_rect(Rect2(0, 626, 1280, 94), Color(0.02, 0.025, 0.03, 0.26))

func _build_particle_specs() -> void:
	particle_specs.clear()
	for i in range(42):
		particle_specs.append({
			"pos": Vector2(20 + (i * 91) % 1240, 70 + (i * 47) % 360),
			"radius": 1.5 + float(i % 4),
			"speed": 0.7 + float(i % 5) * 0.2,
			"phase": float(i) * 0.7,
			"sway": 8.0 + float(i % 6) * 3.0,
			"rise": 10.0 + float(i % 5) * 8.0,
			"offset": float(i * 23)
		})
