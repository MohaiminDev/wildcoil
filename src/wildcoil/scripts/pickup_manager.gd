extends Node2D
class_name PickupManager

signal picked_up(kind)

const PICKUP_DEFINITIONS := {
	"glowfruit": {
		"display_name": "Glowfruit",
		"short_label": "HP",
		"heal": 18,
		"meter": 0,
		"luma": 0,
		"score": 0,
		"outer_color": Color(0.42, 1.0, 0.58),
		"inner_color": Color(0.95, 1.0, 0.72),
		"shape": "fruit"
	},
	"luma_shard": {
		"display_name": "Luma Shard",
		"short_label": "METER",
		"heal": 0,
		"meter": 16,
		"luma": 1,
		"score": 50,
		"outer_color": Color(0.30, 0.95, 1.0),
		"inner_color": Color(0.92, 1.0, 1.0),
		"shape": "shard"
	},
	"medkit": {
		"display_name": "Medkit",
		"short_label": "BIG HP",
		"heal": 42,
		"meter": 0,
		"luma": 0,
		"score": 0,
		"outer_color": Color(1.0, 0.42, 0.32),
		"inner_color": Color(1.0, 0.92, 0.82),
		"shape": "kit"
	}
}

var pickups: Array[Dictionary] = []

func spawn_pickup(kind: String, pos: Vector2) -> void:
	pickups.append({"kind": kind, "position": pos})
	queue_redraw()

func collect_near(player) -> void:
	for index in range(pickups.size() - 1, -1, -1):
		var item := pickups[index]
		if player.position.distance_to(item["position"]) <= 40.0:
			var kind := str(item["kind"])
			var definition := _definition(kind)
			var heal_amount := int(definition.get("heal", 0))
			var meter_amount := int(definition.get("meter", 0))
			if heal_amount > 0:
				player.heal(heal_amount)
			if meter_amount > 0 and player.has_method("add_meter"):
				player.add_meter(meter_amount)
			player.luma_shards += int(definition.get("luma", 0))
			player.score += int(definition.get("score", 0))
			picked_up.emit(kind)
			pickups.remove_at(index)
	queue_redraw()

func pickup_notice(kind: String) -> String:
	var definition := _definition(kind)
	var parts: Array[String] = []
	var heal_amount := int(definition.get("heal", 0))
	var meter_amount := int(definition.get("meter", 0))
	var luma_amount := int(definition.get("luma", 0))
	if heal_amount > 0:
		parts.append("+%d HP" % heal_amount)
	if luma_amount > 0:
		parts.append("+%d Luma" % luma_amount)
	if meter_amount > 0:
		parts.append("+%d Meter" % meter_amount)
	if parts.is_empty():
		return str(definition.get("display_name", kind))
	return "%s  %s" % [str(definition.get("display_name", kind)), " | ".join(parts)]

func _draw() -> void:
	for item in pickups:
		_draw_pickup_marker(item)

func _definition(kind: String) -> Dictionary:
	var definition: Dictionary = PICKUP_DEFINITIONS.get(kind, PICKUP_DEFINITIONS["glowfruit"])
	return definition

func _draw_pickup_marker(item: Dictionary) -> void:
	var kind := str(item.get("kind", "glowfruit"))
	var definition := _definition(kind)
	var local_position := to_local(item["position"])
	var outer_color: Color = definition.get("outer_color", Color(0.42, 1.0, 0.58))
	var inner_color: Color = definition.get("inner_color", Color(0.95, 1.0, 0.72))
	draw_arc(local_position, 17.0, 0.0, TAU, 28, Color(outer_color.r, outer_color.g, outer_color.b, 0.62), 2.0)
	match str(definition.get("shape", "fruit")):
		"shard":
			_draw_luma_shard(local_position, outer_color, inner_color)
		"kit":
			_draw_medkit(local_position, outer_color, inner_color)
		_:
			_draw_glowfruit(local_position, outer_color, inner_color)

func _draw_glowfruit(center: Vector2, outer_color: Color, inner_color: Color) -> void:
	draw_circle(center, 12.0, outer_color)
	draw_circle(center, 6.0, inner_color)
	draw_polygon(PackedVector2Array([
		center + Vector2(2, -12),
		center + Vector2(14, -19),
		center + Vector2(10, -8)
	]), PackedColorArray([Color(0.20, 0.82, 0.36), Color(0.20, 0.82, 0.36), Color(0.20, 0.82, 0.36)]))

func _draw_luma_shard(center: Vector2, outer_color: Color, inner_color: Color) -> void:
	draw_polygon(PackedVector2Array([
		center + Vector2(0, -16),
		center + Vector2(13, -1),
		center + Vector2(0, 16),
		center + Vector2(-13, -1)
	]), PackedColorArray([outer_color, outer_color, outer_color, outer_color]))
	draw_polygon(PackedVector2Array([
		center + Vector2(0, -8),
		center + Vector2(6, 0),
		center + Vector2(0, 9),
		center + Vector2(-6, 0)
	]), PackedColorArray([inner_color, inner_color, inner_color, inner_color]))

func _draw_medkit(center: Vector2, outer_color: Color, inner_color: Color) -> void:
	draw_rect(Rect2(center - Vector2(13, 10), Vector2(26, 20)), outer_color)
	draw_rect(Rect2(center - Vector2(9, 6), Vector2(18, 12)), inner_color)
	draw_rect(Rect2(center - Vector2(2, 8), Vector2(4, 16)), outer_color)
	draw_rect(Rect2(center - Vector2(8, 2), Vector2(16, 4)), outer_color)
