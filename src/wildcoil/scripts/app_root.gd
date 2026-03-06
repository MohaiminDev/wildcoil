extends Node2D

const ContentCatalog = preload("res://scripts/core/content_catalog.gd")
const InputActions = preload("res://scripts/core/input_actions.gd")
const InputDeviceState = preload("res://scripts/core/input_device_state.gd")

@onready var status_label: Label = $HUD/Margin/Status

var catalog: ContentCatalog
var input_device_state := InputDeviceState.new()
var player_controller: CharacterBody2D
var stage_root: Node


func _ready() -> void:
	InputActions.ensure_default_actions()
	input_device_state.refresh_connected_gamepads()
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

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

	stage_root = packed_scene.instantiate()
	stage_root.name = "StageRuntime"
	add_child(stage_root)
	player_controller = stage_root.get_node_or_null("Player") as CharacterBody2D
	update_status_label()


func _input(event: InputEvent) -> void:
	input_device_state.handle_event(event)


func _process(_delta: float) -> void:
	update_status_label()


func update_status_label() -> void:
	var stage_name := "Unknown Stage"
	if catalog != null:
		stage_name = str(catalog.get_first_stage().get("name", "Unknown Stage"))

	var movement_text := "Awaiting player scene"
	if player_controller != null and player_controller.has_method("get_debug_status"):
		movement_text = player_controller.call("get_debug_status")
	var stage_text := "Stage systems booting"
	if stage_root != null and stage_root.has_method("get_debug_stage_status"):
		stage_text = stage_root.call("get_debug_stage_status")

	status_label.text = "Wildcoil first playable scaffold\nBuild: %s\nStage: %s\nCharacters: %d\n%s\n%s\n%s\nMove: A/D or arrows  Jump: Space/W  Dodge: Shift/C\nLight: J/Z  Heavy: K/X  Launch: L/V  Pulse: ;/B  Reset: R\nController: left stick, A jump, B dodge, X light, Y heavy, RB launch, LB pulse" % [
		catalog.build_label,
		stage_name,
		catalog.characters.size(),
		input_device_state.describe_status(),
		movement_text,
		stage_text,
	]


func _on_joy_connection_changed(device: int, connected: bool) -> void:
	input_device_state.handle_connection_change(device, connected)
