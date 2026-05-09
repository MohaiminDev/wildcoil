extends SceneTree

const STAGE_SCENE := preload("res://scenes/stages/sunset_overpass.tscn")

var stage
var frame_count := 0
var output_path := "res://stage1_capture.png"
var capture_requested := false

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		output_path = str(args[0])
	root.size = Vector2i(1280, 720)
	stage = STAGE_SCENE.instantiate()
	stage.hero_id = "raya_flint"
	stage.stage_id = "sunset_overpass"
	root.add_child(stage)

func _process(_delta: float) -> bool:
	frame_count += 1
	if frame_count == 45:
		_arrange_capture_scene()
	if frame_count >= 90 and not capture_requested:
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
