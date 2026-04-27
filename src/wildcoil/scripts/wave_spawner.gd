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
		enemy.position = Vector2(center_x + 90.0 + index * 68.0, 410.0 + (index % 3) * 52.0)
		parent.add_child(enemy)
		spawned.append(enemy)
	return spawned
