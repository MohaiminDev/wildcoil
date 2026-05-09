extends SceneTree

const STAGE_SCENE := preload("res://scenes/stages/sunset_overpass.tscn")

var stage
var frame_count := 0
var saved_frames := 0
var output_dir := "res://stage1_motion_frames"
var target_frames := 144
var warmup_frames := 18

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		output_dir = str(args[0])
	if args.size() > 1:
		target_frames = maxi(int(args[1]), 1)
	DirAccess.make_dir_recursive_absolute(output_dir)
	root.size = Vector2i(1280, 720)
	stage = STAGE_SCENE.instantiate()
	stage.hero_id = "raya_flint"
	stage.stage_id = "sunset_overpass"
	root.add_child(stage)

func _process(_delta: float) -> bool:
	frame_count += 1
	if frame_count == 3:
		_prepare_autoplay_scene()
	if frame_count <= warmup_frames:
		return false
	_save_frame()
	if saved_frames >= target_frames:
		if stage != null and is_instance_valid(stage):
			stage.queue_free()
		await process_frame
		quit()
	return false

func _prepare_autoplay_scene() -> void:
	if stage == null or not is_instance_valid(stage) or stage.player == null:
		return
	stage.player.max_health = 999
	stage.player.health = 999
	stage.player.attack_damage = mini(stage.player.attack_damage, 6)
	stage.player.special_damage = mini(stage.player.special_damage, 14)
	stage.player.invulnerable_timer = 0.0
	if stage.has_method("set_demo_autoplay"):
		stage.set_demo_autoplay(true)

func _save_frame() -> void:
	var viewport_texture := root.get_texture()
	if viewport_texture == null:
		push_error("Unable to capture Stage 1 motion: root viewport has no texture.")
		quit(1)
		return
	var image := viewport_texture.get_image()
	if image == null:
		push_error("Unable to capture Stage 1 motion: root viewport image is null.")
		quit(1)
		return
	var frame_path := "%s/frame_%04d.png" % [output_dir, saved_frames]
	var err := image.save_png(frame_path)
	if err != OK:
		push_error("Unable to save Stage 1 motion frame: %s" % frame_path)
		quit(1)
		return
	saved_frames += 1
