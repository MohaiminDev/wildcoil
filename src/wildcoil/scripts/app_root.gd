extends Node2D

const ContentCatalog = preload("res://scripts/core/content_catalog.gd")
const InputActions = preload("res://scripts/core/input_actions.gd")
const InputDeviceState = preload("res://scripts/core/input_device_state.gd")
const PlaceholderAudioLibrary = preload("res://scripts/core/placeholder_audio_library.gd")

@onready var status_label: Label = $HUD/Margin/Panel/VBox/Status
@onready var objective_label: Label = $HUD/Margin/Panel/VBox/Objective
@onready var boss_label: Label = $HUD/Margin/Panel/VBox/BossLabel
@onready var boss_bar: ProgressBar = $HUD/Margin/Panel/VBox/BossBar
@onready var controls_label: Label = $HUD/Margin/Panel/VBox/Controls
@onready var pause_overlay: CanvasLayer = $PauseOverlay
@onready var pause_body: Label = $PauseOverlay/Center/Panel/VBox/Body
@onready var explore_loop: AudioStreamPlayer = $Audio/ExploreLoop
@onready var combat_loop: AudioStreamPlayer = $Audio/CombatLoop
@onready var clear_loop: AudioStreamPlayer = $Audio/ClearLoop
@onready var boss_loop: AudioStreamPlayer = $Audio/BossLoop
@onready var spectacle_stinger: AudioStreamPlayer = $Audio/SpectacleStinger

var catalog: ContentCatalog
var input_device_state := InputDeviceState.new()
var player_controller: CharacterBody2D
var stage_root: Node
var active_audio_state := ""
var faux_fullscreen := false
var windowed_size := Vector2i(1600, 900)
var windowed_position := Vector2i(120, 80)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	InputActions.ensure_default_actions()
	input_device_state.refresh_connected_gamepads()
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	configure_audio_players()

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
	move_child(stage_root, 0)
	player_controller = stage_root.get_node_or_null("Player") as CharacterBody2D
	var window := get_window()
	if window != null:
		windowed_size = window.size
		windowed_position = window.position
	update_status_label()
	update_pause_overlay()
	update_audio_state()


func _input(event: InputEvent) -> void:
	input_device_state.handle_event(event)
	var key_event := event as InputEventKey
	if key_event != null and key_event.echo:
		return
	var is_pause_key: bool = key_event != null and key_event.pressed and key_event.physical_keycode == KEY_ESCAPE
	var is_fullscreen_key: bool = key_event != null and key_event.pressed and (key_event.physical_keycode == KEY_F11 or key_event.physical_keycode == KEY_F)
	var is_restart_key: bool = key_event != null and key_event.pressed and key_event.physical_keycode == KEY_R
	if event.is_action_pressed(InputActions.PAUSE) or is_pause_key:
		set_game_paused(not get_tree().paused)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(InputActions.FULLSCREEN) or is_fullscreen_key:
		toggle_fullscreen()
		get_viewport().set_input_as_handled()
	elif get_tree().paused and (event.is_action_pressed(InputActions.RESTART_CHECKPOINT) or is_restart_key):
		restart_checkpoint()
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	update_status_label()
	update_pause_overlay()
	update_audio_state()


func configure_audio_players() -> void:
	explore_loop.stream = PlaceholderAudioLibrary.make_explore_loop()
	explore_loop.volume_db = -18.0
	combat_loop.stream = PlaceholderAudioLibrary.make_combat_loop()
	combat_loop.volume_db = -16.0
	clear_loop.stream = PlaceholderAudioLibrary.make_clear_loop()
	clear_loop.volume_db = -18.0
	boss_loop.stream = PlaceholderAudioLibrary.make_boss_loop()
	boss_loop.volume_db = -14.0
	spectacle_stinger.stream = PlaceholderAudioLibrary.make_spectacle_stinger()
	spectacle_stinger.volume_db = -13.0


func set_game_paused(should_pause: bool) -> void:
	get_tree().paused = should_pause
	for player in [explore_loop, combat_loop, clear_loop, boss_loop, spectacle_stinger]:
		player.stream_paused = should_pause
	update_pause_overlay()


func restart_checkpoint() -> void:
	if stage_root != null and stage_root.has_method("reset_to_checkpoint"):
		stage_root.call("reset_to_checkpoint")
	set_game_paused(false)
	update_status_label()
	update_audio_state()


func toggle_fullscreen() -> void:
	var window := get_window()
	if window == null:
		return
	if not faux_fullscreen:
		windowed_size = window.size
		windowed_position = window.position
		var screen_id := DisplayServer.window_get_current_screen()
		window.borderless = true
		window.mode = Window.MODE_WINDOWED
		window.position = DisplayServer.screen_get_position(screen_id)
		window.size = DisplayServer.screen_get_size(screen_id)
		faux_fullscreen = true
	else:
		window.borderless = false
		window.mode = Window.MODE_WINDOWED
		window.size = windowed_size
		window.position = windowed_position
		faux_fullscreen = false
	update_pause_overlay()


func update_status_label() -> void:
	var stage_name := "Unknown Stage"
	if catalog != null:
		stage_name = str(catalog.get_first_stage().get("name", "Unknown Stage"))

	var stage_summary := get_stage_summary()
	var movement_text := "Awaiting player scene"
	if player_controller != null and player_controller.has_method("get_debug_status"):
		movement_text = player_controller.call("get_debug_status")

	status_label.text = "Wildcoil first playable\nBuild: %s  Stage: %s\n%s\n%s" % [
		get_build_label(),
		stage_name,
		input_device_state.describe_status(),
		movement_text,
	]
	objective_label.text = "Objective: %s\nPhase: %s  Time: %s  Enemies: %d\nFirst fight: %s  Spectacle: %s  Rank: %s" % [
		str(stage_summary.get("objective", "Booting stage objective")),
		str(stage_summary.get("phase", "boot")),
		format_seconds(float(stage_summary.get("elapsed_seconds", 0.0))),
		int(stage_summary.get("live_enemy_count", 0)),
		format_optional_seconds(float(stage_summary.get("first_combat_seconds", -1.0))),
		format_optional_seconds(float(stage_summary.get("spectacle_seconds", -1.0))),
		str(stage_summary.get("rank", "--")),
	]
	var boss_active := bool(stage_summary.get("boss_active", false))
	boss_label.visible = boss_active
	boss_bar.visible = boss_active
	if boss_active:
		boss_label.text = "%s  %s" % [
			str(stage_summary.get("boss_name", "Boss")),
			str(stage_summary.get("boss_state", "idle")),
		]
		boss_bar.value = clampf(float(stage_summary.get("boss_health_ratio", 0.0)) * 100.0, 0.0, 100.0)
	controls_label.text = "Esc pause  F or F11 fullscreen  R restart\nMove: A/D or arrows  Jump: Space/W  Dodge: Shift/C\nLight: J/Z  Heavy: K/X  Launch: L/V  Pulse: ;/B"


func update_pause_overlay() -> void:
	pause_overlay.visible = get_tree().paused
	if not pause_overlay.visible:
		return
	var stage_summary := get_stage_summary()
	var fullscreen_label := "Fullscreen" if faux_fullscreen else "Windowed"
	pause_body.text = "Objective: %s\nTime: %s  Checkpoint resets: %d\nView: %s\nEsc resume  R restart checkpoint  F or F11 toggle fullscreen" % [
		str(stage_summary.get("objective", "Resume the relay run")),
		format_seconds(float(stage_summary.get("elapsed_seconds", 0.0))),
		int(stage_summary.get("checkpoint_resets", 0)),
		fullscreen_label,
	]


func update_audio_state() -> void:
	if stage_root == null or not stage_root.has_method("get_audio_state"):
		return
	var desired_state := str(stage_root.call("get_audio_state"))
	if desired_state == active_audio_state:
		return
	active_audio_state = desired_state
	match desired_state:
		"explore":
			play_loop(explore_loop)
			stop_player(combat_loop)
			stop_player(clear_loop)
		"combat":
			play_loop(combat_loop)
			stop_player(explore_loop)
			stop_player(clear_loop)
			stop_player(boss_loop)
		"spectacle":
			stop_player(explore_loop)
			stop_player(combat_loop)
			stop_player(clear_loop)
			stop_player(boss_loop)
			if not spectacle_stinger.playing:
				spectacle_stinger.play()
		"boss":
			play_loop(boss_loop)
			stop_player(explore_loop)
			stop_player(combat_loop)
			stop_player(clear_loop)
		"victory":
			play_loop(clear_loop)
			stop_player(explore_loop)
			stop_player(combat_loop)
			stop_player(boss_loop)
		_:
			play_loop(explore_loop)
			stop_player(combat_loop)
			stop_player(clear_loop)
			stop_player(boss_loop)


func play_loop(player: AudioStreamPlayer) -> void:
	if player.stream == null:
		return
	if not player.playing:
		player.play()


func stop_player(player: AudioStreamPlayer) -> void:
	if player.playing:
		player.stop()


func get_stage_summary() -> Dictionary:
	if stage_root != null and stage_root.has_method("get_stage_summary"):
		return stage_root.call("get_stage_summary")
	return {}


func get_build_label() -> String:
	if catalog == null:
		return "unknown"
	return catalog.build_label


func format_seconds(value: float) -> String:
	return "%.1fs" % maxf(value, 0.0)


func format_optional_seconds(value: float) -> String:
	if value < 0.0:
		return "--"
	return format_seconds(value)


func _on_joy_connection_changed(device: int, connected: bool) -> void:
	input_device_state.handle_connection_change(device, connected)
