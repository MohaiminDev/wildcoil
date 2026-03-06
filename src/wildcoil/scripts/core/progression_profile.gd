class_name ProgressionProfile
extends RefCounted

const SAVE_VERSION := 1
const DEFAULT_SAVE_PATH := "user://wildcoil_profile.json"
const BACKUP_SUFFIX := ".bak"
const TEMP_SUFFIX := ".tmp"
const ContentCatalog = preload("res://scripts/core/content_catalog.gd")

var save_path := DEFAULT_SAVE_PATH
var data: Dictionary = {}
var last_status_message := ""
var recovered_backup_path := ""


static func load_or_create(path: String, catalog: ContentCatalog) -> ProgressionProfile:
	var profile := ProgressionProfile.new()
	profile.save_path = profile._resolve_save_path(path)
	profile.data = profile._build_normalized_data({}, catalog)
	profile.last_status_message = ""
	profile.recovered_backup_path = ""
	var status_message := "Created a new pilot profile."

	if FileAccess.file_exists(profile.save_path):
		var primary_payload := profile._read_profile_payload(profile.save_path)
		if bool(primary_payload.get("ok", false)):
			profile.data = profile._build_normalized_data(primary_payload.get("data", {}), catalog)
			status_message = "Loaded pilot profile."
		else:
			var backup_path := profile.get_backup_path()
			var backup_payload := profile._read_profile_payload(backup_path)
			if bool(backup_payload.get("ok", false)):
				profile.data = profile._build_normalized_data(backup_payload.get("data", {}), catalog)
				profile._backup_corrupt_save(str(primary_payload.get("reason", "invalid json")))
				status_message = "Recovered the pilot profile from backup storage."
			else:
				profile._backup_corrupt_save(str(primary_payload.get("reason", "invalid json")))
				status_message = "Recovered a corrupt profile file and rebuilt defaults."
	elif FileAccess.file_exists(profile.get_backup_path()):
		var backup_payload := profile._read_profile_payload(profile.get_backup_path())
		if bool(backup_payload.get("ok", false)):
			profile.data = profile._build_normalized_data(backup_payload.get("data", {}), catalog)
			status_message = "Recovered the pilot profile from backup storage."

	profile.save()
	profile.last_status_message = status_message
	return profile


func save() -> void:
	_ensure_parent_directory(save_path)
	var temp_path := "%s%s" % [save_path, TEMP_SUFFIX]
	var handle := FileAccess.open(temp_path, FileAccess.WRITE)
	if handle == null:
		push_error("Failed to open save path for writing: %s" % save_path)
		last_status_message = "Failed to save the pilot profile."
		return
	handle.store_string(JSON.stringify(data, "\t"))
	handle.close()
	var backup_path := get_backup_path()
	if FileAccess.file_exists(save_path):
		_remove_if_present(backup_path)
		var backup_error := DirAccess.rename_absolute(_absolute_path(save_path), _absolute_path(backup_path))
		if backup_error != OK:
			push_error("Failed to rotate save backup at %s" % save_path)
			_remove_if_present(temp_path)
			last_status_message = "Failed to rotate the pilot profile backup."
			return
	_remove_if_present(save_path)
	var promote_error := DirAccess.rename_absolute(_absolute_path(temp_path), _absolute_path(save_path))
	if promote_error != OK:
		push_error("Failed to promote temporary save at %s" % save_path)
		last_status_message = "Failed to finalize the pilot profile save."
		return
	last_status_message = "Saved pilot profile."


func reset(catalog: ContentCatalog) -> void:
	data = _build_normalized_data({}, catalog)
	save()
	last_status_message = "Reset the pilot profile."


func get_selected_stage_id() -> String:
	return str(data.get("selected_stage_id", ""))


func set_selected_stage_id(stage_id: String, catalog: ContentCatalog) -> bool:
	if not catalog.has_stage(stage_id) or not is_stage_unlocked(stage_id):
		return false
	data["selected_stage_id"] = stage_id
	return true


func get_selected_character_id() -> String:
	return str(data.get("selected_character_id", ""))


func set_selected_character_id(character_id: String, catalog: ContentCatalog) -> bool:
	if not catalog.has_character(character_id) or not is_character_unlocked(character_id):
		return false
	data["selected_character_id"] = character_id
	return true


func get_unlocked_stage_ids() -> Array[String]:
	return _to_string_array(data.get("unlocked_stage_ids", []))


func get_unlocked_character_ids() -> Array[String]:
	return _to_string_array(data.get("unlocked_character_ids", []))


func get_available_stage_ids(catalog: ContentCatalog) -> Array[String]:
	var ids: Array[String] = []
	for stage_id in catalog.get_stage_ids():
		if is_stage_unlocked(stage_id):
			ids.append(stage_id)
	return ids


func get_available_character_ids(catalog: ContentCatalog) -> Array[String]:
	var ids: Array[String] = []
	for character_id in catalog.get_character_ids():
		if is_character_unlocked(character_id):
			ids.append(character_id)
	return ids


func is_stage_unlocked(stage_id: String) -> bool:
	return get_unlocked_stage_ids().has(stage_id)


func is_character_unlocked(character_id: String) -> bool:
	return get_unlocked_character_ids().has(character_id)


func get_cleared_stage_ids() -> Array[String]:
	return _to_string_array(data.get("cleared_stage_ids", []))


func get_stage_result(stage_id: String) -> Dictionary:
	var results: Dictionary = data.get("best_stage_results", {})
	var result_variant: Variant = results.get(stage_id, {})
	if typeof(result_variant) != TYPE_DICTIONARY:
		return {}
	var result: Dictionary = result_variant
	return result.duplicate(true)


func get_option_value(option_id: String, default_value: Variant = null) -> Variant:
	var options: Dictionary = data.get("options", {})
	return options.get(option_id, default_value)


func set_option_value(option_id: String, option_value: Variant) -> void:
	var options: Dictionary = data.get("options", {})
	options[option_id] = option_value
	data["options"] = options


func record_stage_clear(stage_id: String, rank: String, finish_seconds: float, catalog: ContentCatalog) -> Dictionary:
	var result_summary := {
		"first_clear": false,
		"new_best_rank": false,
		"new_best_time": false,
		"unlocked_stage_id": "",
		"unlocked_character_id": "",
	}
	if not catalog.has_stage(stage_id):
		return result_summary

	var cleared_stage_ids := get_cleared_stage_ids()
	if not cleared_stage_ids.has(stage_id):
		cleared_stage_ids.append(stage_id)
		data["cleared_stage_ids"] = cleared_stage_ids
		result_summary["first_clear"] = true

	var best_stage_results: Dictionary = data.get("best_stage_results", {})
	var existing_result := get_stage_result(stage_id)
	var best_rank := str(existing_result.get("best_rank", ""))
	var best_time_seconds := float(existing_result.get("best_time_seconds", -1.0))

	if _compare_rank(rank, best_rank) > 0:
		best_rank = rank
		result_summary["new_best_rank"] = true
	if best_time_seconds < 0.0 or finish_seconds < best_time_seconds:
		best_time_seconds = finish_seconds
		result_summary["new_best_time"] = true

	best_stage_results[stage_id] = {
		"best_rank": best_rank,
		"best_time_seconds": best_time_seconds,
	}
	data["best_stage_results"] = best_stage_results

	var next_stage_id := catalog.get_next_stage_id(stage_id)
	if not next_stage_id.is_empty() and not is_stage_unlocked(next_stage_id):
		var unlocked_stage_ids := get_unlocked_stage_ids()
		unlocked_stage_ids.append(next_stage_id)
		data["unlocked_stage_ids"] = unlocked_stage_ids
		result_summary["unlocked_stage_id"] = next_stage_id

	var stage_definition := catalog.get_stage_by_id(stage_id)
	var reward_character_id := str(stage_definition.get("reward_character_id", ""))
	if not reward_character_id.is_empty() and catalog.has_character(reward_character_id) and not is_character_unlocked(reward_character_id):
		var unlocked_character_ids := get_unlocked_character_ids()
		unlocked_character_ids.append(reward_character_id)
		data["unlocked_character_ids"] = unlocked_character_ids
		result_summary["unlocked_character_id"] = reward_character_id

	_select_safe_defaults(catalog)
	save()
	last_status_message = "Saved pilot profile after a stage clear."
	return result_summary


func describe_stage_result(stage_id: String) -> String:
	var result := get_stage_result(stage_id)
	if result.is_empty():
		return "No clear record yet"
	return "Best rank %s  Best time %s" % [
		str(result.get("best_rank", "--")),
		_format_optional_seconds(float(result.get("best_time_seconds", -1.0))),
	]


func get_absolute_save_path() -> String:
	return _absolute_path(save_path)


func get_backup_path() -> String:
	return "%s%s" % [save_path, BACKUP_SUFFIX]


func _build_normalized_data(raw_variant: Variant, catalog: ContentCatalog) -> Dictionary:
	var default_stage_id := catalog.get_first_stage_id()
	var default_character_id := catalog.get_first_character_id()
	var default_unlocked_stage_ids := catalog.get_default_stage_ids()
	var default_unlocked_character_ids := catalog.get_default_character_ids()
	var normalized := {
		"version": SAVE_VERSION,
		"selected_stage_id": default_stage_id,
		"selected_character_id": default_character_id,
		"unlocked_stage_ids": default_unlocked_stage_ids.duplicate(),
		"unlocked_character_ids": default_unlocked_character_ids.duplicate(),
		"cleared_stage_ids": [],
		"best_stage_results": {},
		"options": {
			"faux_fullscreen": false,
			"master_volume_db": 0.0,
			"music_volume_db": 0.0,
			"sfx_volume_db": 0.0,
			"high_contrast_hud": false,
			"reduced_motion": false,
			"screen_flash_strength": 1.0,
			"auto_pause_on_focus_loss": true,
		},
	}
	if typeof(raw_variant) != TYPE_DICTIONARY:
		return normalized

	var raw: Dictionary = raw_variant
	var valid_stage_ids := catalog.get_stage_ids()
	var valid_character_ids := catalog.get_character_ids()

	var unlocked_stage_ids := _filter_ids(raw.get("unlocked_stage_ids", []), valid_stage_ids)
	if unlocked_stage_ids.is_empty():
		unlocked_stage_ids = default_unlocked_stage_ids.duplicate()
	var unlocked_character_ids := _filter_ids(raw.get("unlocked_character_ids", []), valid_character_ids)
	if unlocked_character_ids.is_empty():
		unlocked_character_ids = default_unlocked_character_ids.duplicate()

	normalized["unlocked_stage_ids"] = unlocked_stage_ids
	normalized["unlocked_character_ids"] = unlocked_character_ids
	normalized["cleared_stage_ids"] = _filter_ids(raw.get("cleared_stage_ids", []), valid_stage_ids)

	var raw_results: Variant = raw.get("best_stage_results", {})
	if typeof(raw_results) == TYPE_DICTIONARY:
		var sanitized_results: Dictionary = {}
		for stage_id in (raw_results as Dictionary).keys():
			var stage_key := str(stage_id)
			if not valid_stage_ids.has(stage_key):
				continue
			var result_variant: Variant = (raw_results as Dictionary)[stage_id]
			if typeof(result_variant) != TYPE_DICTIONARY:
				continue
			var result: Dictionary = result_variant
			sanitized_results[stage_key] = {
				"best_rank": str(result.get("best_rank", "")),
				"best_time_seconds": float(result.get("best_time_seconds", -1.0)),
			}
		normalized["best_stage_results"] = sanitized_results

	var options: Dictionary = normalized.get("options", {}).duplicate(true)
	var raw_options: Variant = raw.get("options", {})
	if typeof(raw_options) == TYPE_DICTIONARY:
		for option_key in (raw_options as Dictionary).keys():
			if options.has(option_key):
				options[option_key] = (raw_options as Dictionary)[option_key]
	normalized["options"] = options

	var selected_stage_id := str(raw.get("selected_stage_id", default_stage_id))
	if not unlocked_stage_ids.has(selected_stage_id):
		selected_stage_id = unlocked_stage_ids[0] if not unlocked_stage_ids.is_empty() else default_stage_id
	normalized["selected_stage_id"] = selected_stage_id

	var selected_character_id := str(raw.get("selected_character_id", default_character_id))
	if not unlocked_character_ids.has(selected_character_id):
		selected_character_id = unlocked_character_ids[0] if not unlocked_character_ids.is_empty() else default_character_id
	normalized["selected_character_id"] = selected_character_id
	return normalized


func _select_safe_defaults(catalog: ContentCatalog) -> void:
	var selected_stage_id := get_selected_stage_id()
	if not is_stage_unlocked(selected_stage_id):
		var unlocked_stage_ids := get_unlocked_stage_ids()
		data["selected_stage_id"] = unlocked_stage_ids[0] if not unlocked_stage_ids.is_empty() else catalog.get_first_stage_id()

	var selected_character_id := get_selected_character_id()
	if not is_character_unlocked(selected_character_id):
		var unlocked_character_ids := get_unlocked_character_ids()
		data["selected_character_id"] = unlocked_character_ids[0] if not unlocked_character_ids.is_empty() else catalog.get_first_character_id()


func _filter_ids(raw_ids: Variant, valid_ids: Array[String]) -> Array[String]:
	var filtered: Array[String] = []
	if typeof(raw_ids) != TYPE_ARRAY:
		return filtered
	for raw_id in raw_ids:
		var candidate := str(raw_id)
		if valid_ids.has(candidate) and not filtered.has(candidate):
			filtered.append(candidate)
	return filtered


func _to_string_array(raw_ids: Variant) -> Array[String]:
	var ids: Array[String] = []
	if typeof(raw_ids) != TYPE_ARRAY:
		return ids
	for raw_id in raw_ids:
		ids.append(str(raw_id))
	return ids


func _compare_rank(new_rank: String, existing_rank: String) -> int:
	var rank_scores := {
		"S": 4,
		"A": 3,
		"B": 2,
		"C": 1,
	}
	return int(rank_scores.get(new_rank, 0)) - int(rank_scores.get(existing_rank, 0))


func _ensure_parent_directory(path: String) -> void:
	var absolute_path := path
	if path.begins_with("user://"):
		absolute_path = ProjectSettings.globalize_path(path)
	var base_dir := absolute_path.get_base_dir()
	DirAccess.make_dir_recursive_absolute(base_dir)


func _resolve_save_path(path: String) -> String:
	if not path.is_empty():
		return path
	var env_save_path := OS.get_environment("WILDCOIL_SAVE_PATH")
	if not env_save_path.is_empty():
		return env_save_path
	var env_override := OS.get_environment("WILDCOIL_PROFILE_PATH")
	if not env_override.is_empty():
		return env_override
	return DEFAULT_SAVE_PATH


func _read_profile_payload(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {
			"ok": false,
			"reason": "missing file",
		}
	var raw_text := FileAccess.get_file_as_string(path)
	if raw_text.strip_edges().is_empty():
		return {
			"ok": false,
			"reason": "empty file",
		}
	var json := JSON.new()
	var parse_error := json.parse(raw_text)
	if parse_error != OK:
		return {
			"ok": false,
			"reason": "invalid json",
		}
	var parsed: Variant = json.data
	if typeof(parsed) != TYPE_DICTIONARY:
		return {
			"ok": false,
			"reason": "invalid json",
		}
	return {
		"ok": true,
		"data": parsed,
	}


func _absolute_path(path: String) -> String:
	if path.begins_with("user://"):
		return ProjectSettings.globalize_path(path)
	return path


func _remove_if_present(path: String) -> void:
	var absolute_path := _absolute_path(path)
	if FileAccess.file_exists(path) or FileAccess.file_exists(absolute_path):
		DirAccess.remove_absolute(absolute_path)


func _backup_corrupt_save(reason: String) -> void:
	var absolute_path := _absolute_path(save_path)
	if not FileAccess.file_exists(save_path) and not FileAccess.file_exists(absolute_path):
		return
	var timestamp := Time.get_datetime_string_from_system().replace(":", "-")
	var backup_path := "%s.corrupt-%s" % [absolute_path, timestamp]
	var rename_error := DirAccess.rename_absolute(absolute_path, backup_path)
	if rename_error == OK:
		recovered_backup_path = backup_path
	else:
		push_warning("Failed to back up corrupt profile (%s): %s" % [reason, error_string(rename_error)])


func _format_optional_seconds(value: float) -> String:
	if value < 0.0:
		return "--"
	return "%.1fs" % value
