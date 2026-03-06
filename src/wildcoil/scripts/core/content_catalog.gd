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

	return from_dictionary(parsed)


static func from_dictionary(parsed: Dictionary) -> ContentCatalog:
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

	var seen_character_ids: Dictionary = {}
	for character_variant in characters:
		if typeof(character_variant) != TYPE_DICTIONARY:
			errors.append("character entry must be a dictionary")
			continue
		var character: Dictionary = character_variant
		var character_id := str(character.get("id", ""))
		if character_id.is_empty():
			errors.append("character id is required")
		elif seen_character_ids.has(character_id):
			errors.append("duplicate character id: %s" % character_id)
		else:
			seen_character_ids[character_id] = true
		if str(character.get("name", "")).is_empty():
			errors.append("character %s is missing a name" % character_id)
		if str(character.get("playstyle", "")).is_empty():
			errors.append("character %s is missing a playstyle" % character_id)

	var seen_stage_ids: Dictionary = {}
	var seen_stage_orders: Dictionary = {}
	for stage_variant in stages:
		if typeof(stage_variant) != TYPE_DICTIONARY:
			errors.append("stage entry must be a dictionary")
			continue
		var stage: Dictionary = stage_variant
		var stage_id := str(stage.get("id", ""))
		var scene_path := str(stage.get("scene", ""))
		var stage_order := int(stage.get("order", 0))
		if stage_id.is_empty():
			errors.append("stage id is required")
		elif seen_stage_ids.has(stage_id):
			errors.append("duplicate stage id: %s" % stage_id)
		else:
			seen_stage_ids[stage_id] = true
		if str(stage.get("name", "")).is_empty():
			errors.append("stage %s is missing a display name" % stage_id)
		if stage_order <= 0:
			errors.append("stage %s requires a positive order" % stage_id)
		elif seen_stage_orders.has(stage_order):
			errors.append("duplicate stage order: %d" % stage_order)
		else:
			seen_stage_orders[stage_order] = stage_id
		if scene_path.is_empty():
			errors.append("stage %s is missing a scene path" % stage_id)
		elif not ResourceLoader.exists(scene_path):
			errors.append("stage %s references a missing scene: %s" % [stage_id, scene_path])
		var reward_character_id := str(stage.get("reward_character_id", ""))
		if not reward_character_id.is_empty() and not seen_character_ids.has(reward_character_id):
			errors.append("stage %s references unknown reward_character_id: %s" % [stage_id, reward_character_id])

	return errors


func get_first_stage() -> Dictionary:
	var ordered_stages := get_ordered_stages()
	if ordered_stages.is_empty():
		return {}
	var stage: Dictionary = ordered_stages[0]
	return stage


func get_first_stage_id() -> String:
	return str(get_first_stage().get("id", ""))


func get_stage_by_id(stage_id: String) -> Dictionary:
	for stage_variant in stages:
		if typeof(stage_variant) != TYPE_DICTIONARY:
			continue
		var stage: Dictionary = stage_variant
		if str(stage.get("id", "")) == stage_id:
			return stage
	return {}


func get_stage_ids() -> Array[String]:
	var ids: Array[String] = []
	for stage in get_ordered_stages():
		ids.append(str(stage.get("id", "")))
	return ids


func get_default_stage_ids() -> Array[String]:
	var ids: Array[String] = []
	for stage in get_ordered_stages():
		if not bool(stage.get("locked", false)):
			ids.append(str(stage.get("id", "")))
	if ids.is_empty() and not get_first_stage_id().is_empty():
		ids.append(get_first_stage_id())
	return ids


func get_next_stage_id(stage_id: String) -> String:
	var stage_ids := get_stage_ids()
	var stage_index := stage_ids.find(stage_id)
	if stage_index < 0 or stage_index + 1 >= stage_ids.size():
		return ""
	return stage_ids[stage_index + 1]


func has_stage(stage_id: String) -> bool:
	return not get_stage_by_id(stage_id).is_empty()


func get_character_by_id(character_id: String) -> Dictionary:
	for character_variant in characters:
		if typeof(character_variant) != TYPE_DICTIONARY:
			continue
		var character: Dictionary = character_variant
		if str(character.get("id", "")) == character_id:
			return character
	return {}


func get_first_character_id() -> String:
	if characters.is_empty():
		return ""
	var first_character := get_character_by_id(get_character_ids()[0])
	return str(first_character.get("id", ""))


func get_character_ids() -> Array[String]:
	var ids: Array[String] = []
	for character_variant in characters:
		if typeof(character_variant) != TYPE_DICTIONARY:
			continue
		var character: Dictionary = character_variant
		ids.append(str(character.get("id", "")))
	return ids


func get_default_character_ids() -> Array[String]:
	var ids: Array[String] = []
	for character_variant in characters:
		if typeof(character_variant) != TYPE_DICTIONARY:
			continue
		var character: Dictionary = character_variant
		if not bool(character.get("locked", false)):
			ids.append(str(character.get("id", "")))
	if ids.is_empty() and not get_first_character_id().is_empty():
		ids.append(get_first_character_id())
	return ids


func has_character(character_id: String) -> bool:
	return not get_character_by_id(character_id).is_empty()


func get_ordered_stages() -> Array[Dictionary]:
	var ordered_stages: Array[Dictionary] = []
	for stage_variant in stages:
		if typeof(stage_variant) != TYPE_DICTIONARY:
			continue
		ordered_stages.append((stage_variant as Dictionary).duplicate(true))
	ordered_stages.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return int(left.get("order", 0)) < int(right.get("order", 0))
	)
	return ordered_stages
