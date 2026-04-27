extends SceneTree

func _init() -> void:
	var mode := "smoke"
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		mode = args[0]
	var ok := _run_smoke()
	if ok:
		print("RIFT_ROAD_RUNTIME_OK %s" % mode)
		quit(0)
	else:
		printerr("RIFT_ROAD_RUNTIME_FAILED %s" % mode)
		quit(1)

func _run_smoke() -> bool:
	var required := [
		"res://project.godot",
		"res://scenes/app_root.tscn",
		"res://scenes/player.tscn",
		"res://scenes/enemy_actor.tscn",
		"res://scenes/boss_brask_noll.tscn",
		"res://scenes/stages/sunset_overpass.tscn",
		"res://data/characters.json",
		"res://data/enemies.json",
		"res://data/bosses.json",
		"res://data/stages.json"
	]
	for path in required:
		if not FileAccess.file_exists(path):
			printerr("Missing required path: %s" % path)
			return false
	return _validate_json("res://data/characters.json", "heroes") and _validate_json("res://data/enemies.json", "enemies") and _validate_json("res://data/bosses.json", "bosses") and _validate_json("res://data/stages.json", "stages")

func _validate_json(path: String, key: String) -> bool:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		printerr("Invalid JSON dictionary: %s" % path)
		return false
	if not parsed.has(key):
		printerr("Missing JSON key %s in %s" % [key, path])
		return false
	return true

