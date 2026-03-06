class_name EnemyProjectile
extends Node2D

var stage: Node
var direction := 1.0
var speed := 240.0
var remaining_distance := 320.0
var attack_profile: Dictionary = {}
var radius := 18.0


func _physics_process(delta: float) -> void:
	if stage != null and stage.has_method("is_hitstop_active") and stage.call("is_hitstop_active"):
		queue_redraw()
		return

	var distance_step := speed * delta
	global_position.x += distance_step * direction
	remaining_distance -= distance_step
	queue_redraw()

	if stage != null and stage.has_method("resolve_enemy_attack"):
		var hit: bool = stage.call("resolve_enemy_attack", attack_profile, global_position, direction)
		if hit:
			queue_free()
			return

	if remaining_distance <= 0.0:
		queue_free()


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, Color("caa7ff"))
	draw_circle(Vector2.ZERO, radius * 0.45, Color("f4e7ff"))
