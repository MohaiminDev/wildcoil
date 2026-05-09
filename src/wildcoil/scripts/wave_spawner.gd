extends Node
class_name WaveSpawner

const ENEMY_SCENE := preload("res://scenes/enemy_actor.tscn")

var enemy_profiles := {}

func _ready() -> void:
	enemy_profiles = _load_profiles("res://data/enemies.json", "enemies")

func _load_profiles(path: String, key: String) -> Dictionary:
	var text := FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(text)
	var profiles := {}
	for item in parsed.get(key, []):
		profiles[item["id"]] = item
	return profiles

func spawn_wave(parent: Node, enemy_ids: Array, player, center_x: float) -> Array:
	var spawned := []
	for index in enemy_ids.size():
		var enemy = ENEMY_SCENE.instantiate()
		enemy.setup(enemy_profiles[enemy_ids[index]])
		enemy.target = player
		var side: float = 1.0 if index % 2 == 0 else -1.0
		var rank: float = floor(float(index) * 0.5)
		var lane: float = float(index % 3) - 1.0
		var final_position := Vector2(
			clamp(center_x + side * (118.0 + rank * 64.0), 92.0, 1188.0),
			clamp(478.0 + lane * 46.0 + float(index % 2) * 18.0, 352.0, 604.0)
		)
		var offscreen_start := Vector2(-170.0, final_position.y) if side < 0.0 else Vector2(1450.0, final_position.y)
		enemy.position = offscreen_start
		parent.add_child(enemy)
		if enemy.has_method("start_cinematic_entry"):
			enemy.start_cinematic_entry(final_position, enemy.move_speed * (1.45 + float(index % 3) * 0.12))
		spawned.append(enemy)
	return spawned
