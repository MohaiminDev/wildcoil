extends Node2D

const ContentCatalog = preload("res://scripts/core/content_catalog.gd")

@onready var status_label: Label = $HUD/Margin/Status

var catalog: ContentCatalog


func _ready() -> void:
	catalog = ContentCatalog.load_default()
	var validation_errors := catalog.validate()
	if not validation_errors.is_empty():
		status_label.text = "Catalog errors:\n%s" % "\n".join(validation_errors)
		push_error(status_label.text)
		return

	var stage_definition := catalog.get_first_stage()
	var scene_path := str(stage_definition.get("scene", ""))
	var packed_scene := load(scene_path) as PackedScene
	if packed_scene == null:
		status_label.text = "Failed to load stage scene: %s" % scene_path
		push_error(status_label.text)
		return

	var stage_instance := packed_scene.instantiate()
	stage_instance.name = "StageRuntime"
	add_child(stage_instance)

	status_label.text = "Wildcoil scaffold ready\nBuild: %s\nStage: %s\nCharacters: %d" % [
		catalog.build_label,
		str(stage_definition.get("name", "Unknown Stage")),
		catalog.characters.size(),
	]
