class_name ContentCatalog
extends RefCounted

const DEFAULT_PATH := "res://data/content_catalog.json"

var build_label: String = ""
var characters: Array = []
var stages: Array = []


static func load_default() -> ContentCatalog:
	return load_from_path(DEFAULT_PATH)


static func load_from_path(path: String) -> ContentCatalog:
	var json_text := FileAccess.get_file_as_string(path)
	if json_text.is_empty():
		push_error("Content catalog is missing: %s" % path)
		return ContentCatalog.new()

	var parsed: Variant = JSON.parse_string(json_text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Content catalog did not parse as a dictionary: %s" % path)
		return ContentCatalog.new()

	var parsed_dict: Dictionary = parsed
	var catalog := ContentCatalog.new()
	catalog.build_label = str(parsed_dict.get("build_label", ""))
	catalog.characters = parsed_dict.get("characters", [])
	catalog.stages = parsed_dict.get("stages", [])
	return catalog


func validate() -> Array[String]:
	var errors: Array[String] = []
	if build_label.is_empty():
		errors.append("build_label is required")
	if characters.is_empty():
		errors.append("at least one character entry is required")
	if stages.is_empty():
		errors.append("at least one stage entry is required")

	var seen_stage_ids: Dictionary = {}
	for stage_variant in stages:
		if typeof(stage_variant) != TYPE_DICTIONARY:
			errors.append("stage entry must be a dictionary")
			continue
		var stage: Dictionary = stage_variant
		var stage_id := str(stage.get("id", ""))
		var scene_path := str(stage.get("scene", ""))
		if stage_id.is_empty():
			errors.append("stage id is required")
		elif seen_stage_ids.has(stage_id):
			errors.append("duplicate stage id: %s" % stage_id)
		else:
			seen_stage_ids[stage_id] = true
		if scene_path.is_empty():
			errors.append("stage %s is missing a scene path" % stage_id)
		elif not ResourceLoader.exists(scene_path):
			errors.append("stage %s references a missing scene: %s" % [stage_id, scene_path])

	for character_variant in characters:
		if typeof(character_variant) != TYPE_DICTIONARY:
			errors.append("character entry must be a dictionary")
			continue
		var character: Dictionary = character_variant
		if str(character.get("id", "")).is_empty():
			errors.append("character id is required")
		if str(character.get("name", "")).is_empty():
			errors.append("character name is required")

	return errors


func get_first_stage() -> Dictionary:
	if stages.is_empty():
		return {}
	var stage: Dictionary = stages[0]
	return stage


func get_stage_ids() -> Array[String]:
	var ids: Array[String] = []
	for stage_variant in stages:
		if typeof(stage_variant) != TYPE_DICTIONARY:
			continue
		var stage: Dictionary = stage_variant
		ids.append(str(stage.get("id", "")))
	return ids
