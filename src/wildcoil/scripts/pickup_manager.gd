extends Node2D
class_name PickupManager

signal picked_up(kind)

var pickups: Array[Dictionary] = []

func spawn_pickup(kind: String, pos: Vector2) -> void:
	pickups.append({"kind": kind, "position": pos})
	queue_redraw()

func collect_near(player) -> void:
	for index in range(pickups.size() - 1, -1, -1):
		var item := pickups[index]
		if player.position.distance_to(item["position"]) <= 40.0:
			match item["kind"]:
				"glowfruit":
					player.heal(18)
				"canteen":
					player.heal(12)
				"protein_tin":
					player.heal(26)
				"field_bandage":
					player.heal(20)
			player.luma_shards += 1
			picked_up.emit(item["kind"])
			pickups.remove_at(index)
	queue_redraw()

func _draw() -> void:
	for item in pickups:
		draw_circle(to_local(item["position"]), 12.0, Color(0.42, 1.0, 0.58))
		draw_circle(to_local(item["position"]), 6.0, Color(0.95, 1.0, 0.72))
