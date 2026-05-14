extends RefCounted
class_name VisualAssetLoader

const MANIFEST_PATH := "res://data/visual_assets.json"

var manifest := {}

func _init() -> void:
	manifest = _load_manifest()

func has_stage1_background_assets() -> bool:
	for layer in stage1_background_layers():
		var path := str(layer.get("path", ""))
		if path != "" and ResourceLoader.exists(path):
			return true
	return false

func stage1_background_layers() -> Array:
	return manifest.get("stage1", {}).get("background_layers", [])

func actor_state_paths(actor_id: String) -> Dictionary:
	return manifest.get("stage1", {}).get("actors", {}).get(actor_id, {})

func actor_texture(actor_id: String, state: String) -> Texture2D:
	var states := actor_state_paths(actor_id)
	var path := str(states.get(state, ""))
	if path == "":
		path = str(states.get("idle", ""))
	return _load_texture(path)

func add_stage1_background_layers(parent: Node) -> bool:
	var loaded_any := false
	for layer in stage1_background_layers():
		var path := str(layer.get("path", ""))
		var texture := _load_texture(path)
		if texture == null:
			continue
		var sprite := Sprite2D.new()
		sprite.name = "asset-layer-%s" % str(layer.get("id", "unnamed"))
		sprite.texture = texture
		sprite.centered = false
		sprite.position = _array_to_vector(layer.get("position", [0, 0]))
		var target_size := _array_to_vector(layer.get("size", [texture.get_width(), texture.get_height()]))
		if texture.get_width() > 0 and texture.get_height() > 0:
			sprite.scale = Vector2(target_size.x / texture.get_width(), target_size.y / texture.get_height())
		sprite.z_index = int(layer.get("z_index", -220))
		parent.add_child(sprite)
		loaded_any = true
	return loaded_any

func _load_manifest() -> Dictionary:
	if not FileAccess.file_exists(MANIFEST_PATH):
		return {}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed

func _load_texture(path: String) -> Texture2D:
	if path == "":
		return null
	if ResourceLoader.exists(path):
		return load(path)
	if not FileAccess.file_exists(path):
		return null
	var image := Image.new()
	var error := image.load(path)
	if error != OK:
		return null
	return ImageTexture.create_from_image(image)

func _array_to_vector(value) -> Vector2:
	if typeof(value) != TYPE_ARRAY or value.size() < 2:
		return Vector2.ZERO
	return Vector2(float(value[0]), float(value[1]))
