extends Node2D

const ContentCatalog = preload("res://scripts/core/content_catalog.gd")
const InputActions = preload("res://scripts/core/input_actions.gd")
const InputDeviceState = preload("res://scripts/core/input_device_state.gd")
const PlaceholderAudioLibrary = preload("res://scripts/core/placeholder_audio_library.gd")
const ProgressionProfile = preload("res://scripts/core/progression_profile.gd")

@onready var status_label: Label = $HUD/Margin/Panel/VBox/Status
@onready var objective_label: Label = $HUD/Margin/Panel/VBox/Objective
@onready var boss_label: Label = $HUD/Margin/Panel/VBox/BossLabel
@onready var boss_bar: ProgressBar = $HUD/Margin/Panel/VBox/BossBar
@onready var controls_label: Label = $HUD/Margin/Panel/VBox/Controls
@onready var pause_overlay: CanvasLayer = $PauseOverlay
@onready var pause_body: Label = $PauseOverlay/Center/Panel/VBox/Body
@onready var mission_overlay: CanvasLayer = $MissionOverlay
@onready var mission_title: Label = $MissionOverlay/Center/Panel/VBox/Title
@onready var mission_body: Label = $MissionOverlay/Center/Panel/VBox/Body
@onready var mission_footer: Label = $MissionOverlay/Center/Panel/VBox/Footer
@onready var explore_loop: AudioStreamPlayer = $Audio/ExploreLoop
@onready var combat_loop: AudioStreamPlayer = $Audio/CombatLoop
@onready var clear_loop: AudioStreamPlayer = $Audio/ClearLoop
@onready var boss_loop: AudioStreamPlayer = $Audio/BossLoop
@onready var spectacle_stinger: AudioStreamPlayer = $Audio/SpectacleStinger

var catalog: ContentCatalog
var profile: ProgressionProfile
var input_device_state := InputDeviceState.new()
var player_controller: CharacterBody2D
var stage_root: Node
var active_audio_state := ""
var faux_fullscreen := false
var windowed_size := Vector2i(1600, 900)
var windowed_position := Vector2i(120, 80)
var frontend_mode := "menu"
var stage_result_recorded := false
var frontend_notice := ""
var active_stage_id := ""
var active_character_id := ""
var did_bootstrap := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	InputActions.ensure_default_actions()
	input_device_state.refresh_connected_gamepads()
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	configure_audio_players()
	if not bootstrap_runtime():
		return

	update_status_label()
	update_pause_overlay()
	update_frontend_overlay()
	update_audio_state()


func _input(event: InputEvent) -> void:
	input_device_state.handle_event(event)
	var key_event := event as InputEventKey
	if key_event != null and key_event.echo:
		return

	if event.is_action_pressed(InputActions.FULLSCREEN):
		toggle_fullscreen()
		get_viewport().set_input_as_handled()
		return

	if frontend_mode != "playing":
		handle_frontend_input(event)
		return

	if event.is_action_pressed(InputActions.PAUSE):
		set_game_paused(not get_tree().paused)
		get_viewport().set_input_as_handled()
	elif get_tree().paused and event.is_action_pressed(InputActions.RESTART_CHECKPOINT):
		restart_checkpoint()
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	if frontend_mode == "playing":
		var stage_summary := get_stage_summary()
		if bool(stage_summary.get("stage_complete", false)) and not stage_result_recorded:
			record_stage_completion(stage_summary)
	update_status_label()
	update_pause_overlay()
	update_frontend_overlay()
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


func bootstrap_runtime() -> bool:
	if did_bootstrap:
		return catalog != null and profile != null
	catalog = ContentCatalog.load_default()
	var validation_errors := catalog.validate()
	if not validation_errors.is_empty():
		status_label.text = "Catalog errors:\n%s" % "\n".join(validation_errors)
		push_error(status_label.text)
		return false

	profile = ProgressionProfile.load_or_create("", catalog)
	frontend_notice = profile.last_status_message
	if not profile.recovered_backup_path.is_empty():
		frontend_notice += " Backup archived at %s." % profile.recovered_backup_path
	sync_selection_from_profile()

	var window := get_window()
	if window != null:
		windowed_size = window.size
		windowed_position = window.position
	set_faux_fullscreen(bool(profile.get_option_value("faux_fullscreen", false)), false)
	did_bootstrap = true
	return true


func handle_frontend_input(event: InputEvent) -> void:
	if frontend_mode == "results" and event.is_action_pressed(InputActions.MENU_BACK):
		return_to_mission_board()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed(InputActions.MENU_CONFIRM):
		if frontend_mode == "results":
			return_to_mission_board()
		else:
			start_selected_stage()
		get_viewport().set_input_as_handled()
		return

	if frontend_mode != "menu":
		return

	if event.is_action_pressed(InputActions.MENU_LEFT):
		cycle_selected_stage(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(InputActions.MENU_RIGHT):
		cycle_selected_stage(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(InputActions.MENU_UP):
		cycle_selected_character(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(InputActions.MENU_DOWN):
		cycle_selected_character(1)
		get_viewport().set_input_as_handled()


func sync_selection_from_profile() -> void:
	if profile == null:
		return
	active_stage_id = profile.get_selected_stage_id()
	active_character_id = profile.get_selected_character_id()

	if active_stage_id.is_empty():
		active_stage_id = catalog.get_first_stage_id()
		profile.set_selected_stage_id(active_stage_id, catalog)
	if active_character_id.is_empty():
		active_character_id = catalog.get_first_character_id()
		profile.set_selected_character_id(active_character_id, catalog)


func cycle_selected_stage(step: int) -> void:
	var unlocked_stage_ids := profile.get_unlocked_stage_ids()
	if unlocked_stage_ids.size() <= 1:
		return
	var current_index := unlocked_stage_ids.find(active_stage_id)
	if current_index < 0:
		current_index = 0
	var next_index := wrapi(current_index + step, 0, unlocked_stage_ids.size())
	active_stage_id = unlocked_stage_ids[next_index]
	profile.set_selected_stage_id(active_stage_id, catalog)
	profile.save()
	frontend_notice = "Selected mission: %s." % str(get_selected_stage_definition().get("name", "Unknown Stage"))


func cycle_selected_character(step: int) -> void:
	var unlocked_character_ids := profile.get_unlocked_character_ids()
	if unlocked_character_ids.size() <= 1:
		return
	var current_index := unlocked_character_ids.find(active_character_id)
	if current_index < 0:
		current_index = 0
	var next_index := wrapi(current_index + step, 0, unlocked_character_ids.size())
	active_character_id = unlocked_character_ids[next_index]
	profile.set_selected_character_id(active_character_id, catalog)
	profile.save()
	frontend_notice = "Selected hunter: %s." % str(get_selected_character_definition().get("name", "Unknown Hunter"))


func start_selected_stage() -> void:
	if not bootstrap_runtime():
		frontend_notice = "Mission board failed to bootstrap."
		return
	var stage_definition := get_selected_stage_definition()
	var character_definition := get_selected_character_definition()
	var scene_path := str(stage_definition.get("scene", ""))
	if scene_path.is_empty() and catalog != null:
		stage_definition = catalog.get_first_stage()
		active_stage_id = str(stage_definition.get("id", active_stage_id))
		scene_path = str(stage_definition.get("scene", ""))
	if active_character_id.is_empty():
		active_character_id = str(character_definition.get("id", ""))
		if active_character_id.is_empty() and catalog != null:
			active_character_id = catalog.get_first_character_id()
			character_definition = catalog.get_character_by_id(active_character_id)
	var packed_scene := load(scene_path) as PackedScene
	if packed_scene == null:
		frontend_notice = "Failed to load the selected stage scene."
		return

	profile.set_selected_stage_id(active_stage_id, catalog)
	profile.set_selected_character_id(active_character_id, catalog)
	profile.save()

	teardown_stage()
	stage_root = packed_scene.instantiate()
	stage_root.name = "StageRuntime"
	add_child(stage_root)
	move_child(stage_root, 0)
	player_controller = stage_root.get_node_or_null("Player") as CharacterBody2D
	if stage_root.has_method("configure_run"):
		stage_root.call("configure_run", {
			"stage_definition": stage_definition,
			"character_definition": character_definition,
			"save_record": profile.get_stage_result(active_stage_id),
		})
	elif player_controller != null and player_controller.has_method("apply_character_definition"):
		player_controller.call("apply_character_definition", character_definition)
	stage_result_recorded = false
	frontend_mode = "playing"
	active_audio_state = ""
	frontend_notice = "Deployed to %s with %s." % [
		str(stage_definition.get("name", "Unknown Stage")),
		str(character_definition.get("name", "Unknown Hunter")),
	]
	get_tree().paused = false


func record_stage_completion(stage_summary: Dictionary) -> void:
	if profile == null:
		return
	var stage_id := active_stage_id if not active_stage_id.is_empty() else catalog.get_first_stage_id()
	var rank := str(stage_summary.get("rank", "C"))
	var finish_seconds := float(stage_summary.get("finish_seconds", -1.0))
	var progression_summary := profile.record_stage_clear(stage_id, rank, finish_seconds, catalog)
	stage_result_recorded = true
	frontend_mode = "results"
	sync_selection_from_profile()
	frontend_notice = build_completion_notice(stage_id, rank, finish_seconds, progression_summary)
	get_tree().paused = false


func build_completion_notice(stage_id: String, rank: String, finish_seconds: float, progression_summary: Dictionary) -> String:
	var notice_lines := [
		"%s cleared with rank %s in %s." % [
			str(catalog.get_stage_by_id(stage_id).get("name", stage_id)),
			rank,
			format_optional_seconds(finish_seconds),
		]
	]
	if bool(progression_summary.get("new_best_rank", false)):
		notice_lines.append("New best rank recorded.")
	if bool(progression_summary.get("new_best_time", false)):
		notice_lines.append("New best clear time recorded.")
	var unlocked_stage_id := str(progression_summary.get("unlocked_stage_id", ""))
	if not unlocked_stage_id.is_empty():
		notice_lines.append("Unlocked mission: %s." % str(catalog.get_stage_by_id(unlocked_stage_id).get("name", unlocked_stage_id)))
	var unlocked_character_id := str(progression_summary.get("unlocked_character_id", ""))
	if not unlocked_character_id.is_empty():
		notice_lines.append("Unlocked hunter: %s." % str(catalog.get_character_by_id(unlocked_character_id).get("name", unlocked_character_id)))
	notice_lines.append("Profile saved to %s." % profile.get_absolute_save_path())
	return "\n".join(notice_lines)


func return_to_mission_board() -> void:
	teardown_stage()
	frontend_mode = "menu"
	stage_result_recorded = false
	get_tree().paused = false
	active_audio_state = ""
	frontend_notice = "Mission board ready."


func teardown_stage() -> void:
	if stage_root != null:
		if stage_root.get_parent() != null:
			stage_root.get_parent().remove_child(stage_root)
		stage_root.queue_free()
	stage_root = null
	player_controller = null


func set_game_paused(should_pause: bool) -> void:
	if frontend_mode != "playing":
		should_pause = false
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
	set_faux_fullscreen(not faux_fullscreen, true)
	update_pause_overlay()
	update_frontend_overlay()


func set_faux_fullscreen(should_enable: bool, persist_setting: bool) -> void:
	var window := get_window()
	if window == null:
		return
	if should_enable and not faux_fullscreen:
		windowed_size = window.size
		windowed_position = window.position
		var screen_id := DisplayServer.window_get_current_screen()
		window.borderless = true
		window.mode = Window.MODE_WINDOWED
		window.position = DisplayServer.screen_get_position(screen_id)
		window.size = DisplayServer.screen_get_size(screen_id)
		faux_fullscreen = true
	elif not should_enable and faux_fullscreen:
		window.borderless = false
		window.mode = Window.MODE_WINDOWED
		window.size = windowed_size
		window.position = windowed_position
		faux_fullscreen = false
	if persist_setting and profile != null:
		profile.set_option_value("faux_fullscreen", faux_fullscreen)
		profile.save()
		frontend_notice = profile.last_status_message


func update_status_label() -> void:
	var stage_name := str(get_selected_stage_definition().get("name", "Unknown Stage"))
	var movement_text := "Mission board ready"
	if player_controller != null and player_controller.has_method("get_debug_status"):
		movement_text = player_controller.call("get_debug_status")

	status_label.text = "Wildcoil mission board\nBuild: %s  Stage: %s\n%s\n%s" % [
		get_build_label(),
		stage_name,
		input_device_state.describe_status(),
		movement_text,
	]

	var stage_summary := get_stage_summary()
	if stage_root != null:
		objective_label.text = "Objective: %s\nPhase: %s  Time: %s  Enemies: %d\nFirst fight: %s  Spectacle: %s  Rank: %s" % [
			str(stage_summary.get("objective", "Booting stage objective")),
			str(stage_summary.get("phase", "boot")),
			format_seconds(float(stage_summary.get("elapsed_seconds", 0.0))),
			int(stage_summary.get("live_enemy_count", 0)),
			format_optional_seconds(float(stage_summary.get("first_combat_seconds", -1.0))),
			format_optional_seconds(float(stage_summary.get("spectacle_seconds", -1.0))),
			str(stage_summary.get("rank", "--")),
		]
	else:
		objective_label.text = "Selected route: %s\nSelected hunter: %s\nCleared stages: %d/%d  Unlocked hunters: %d/%d\nBest record: %s" % [
			stage_name,
			str(get_selected_character_definition().get("name", "Unknown Hunter")),
			profile.get_cleared_stage_ids().size() if profile != null else 0,
			catalog.get_stage_ids().size() if catalog != null else 0,
			profile.get_unlocked_character_ids().size() if profile != null else 0,
			catalog.get_character_ids().size() if catalog != null else 0,
			profile.describe_stage_result(active_stage_id) if profile != null else "No profile loaded",
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

	controls_label.text = "Menu: A/D or Left/Right mission  W/S or Up/Down hunter  Enter deploy\nController: D-pad browse  A deploy  B back  Start pause  F or F11 fullscreen\nStage: A/D move  Space/W jump  Shift/C dodge  J/K/L/; attacks  R restart"


func update_pause_overlay() -> void:
	pause_overlay.visible = frontend_mode == "playing" and get_tree().paused
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


func update_frontend_overlay() -> void:
	mission_overlay.visible = frontend_mode != "playing"
	if not mission_overlay.visible:
		return

	var stage_definition := get_selected_stage_definition()
	var character_definition := get_selected_character_definition()
	var stage_name := str(stage_definition.get("name", "Unknown Stage"))
	var character_name := str(character_definition.get("name", "Unknown Hunter"))
	var view_label := "Borderless fullscreen" if faux_fullscreen else "Windowed"
	var progress_text := "Cleared stages: %d/%d  Unlocked missions: %d/%d  Unlocked hunters: %d/%d" % [
		profile.get_cleared_stage_ids().size() if profile != null else 0,
		catalog.get_stage_ids().size() if catalog != null else 0,
		profile.get_unlocked_stage_ids().size() if profile != null else 0,
		catalog.get_stage_ids().size() if catalog != null else 0,
		profile.get_unlocked_character_ids().size() if profile != null else 0,
		catalog.get_character_ids().size() if catalog != null else 0,
	]
	var note_text := "" if frontend_notice.is_empty() else "\nNotice: %s" % frontend_notice

	if frontend_mode == "results":
		mission_title.text = "Stage Clear"
		mission_body.text = "Mission: %s\nHunter: %s\nView: %s\n%s\nBest record: %s\nSave path: %s%s" % [
			stage_name,
			character_name,
			view_label,
			progress_text,
			profile.describe_stage_result(active_stage_id) if profile != null else "--",
			profile.get_absolute_save_path() if profile != null else "--",
			note_text,
		]
		mission_footer.text = "Enter or B to return to the mission board"
	else:
		mission_title.text = "Mission Board"
		mission_body.text = "Mission: %s\nBiome: %s  Stage order: %d/%d\nHunter: %s (%s)\nView: %s\n%s\nBest record: %s\nSave path: %s%s" % [
			stage_name,
			str(stage_definition.get("biome", "unknown_biome")),
			int(stage_definition.get("order", 1)),
			catalog.get_stage_ids().size() if catalog != null else 1,
			character_name,
			str(character_definition.get("playstyle", "unknown")),
			view_label,
			progress_text,
			profile.describe_stage_result(active_stage_id) if profile != null else "--",
			profile.get_absolute_save_path() if profile != null else "--",
			note_text,
		]
		mission_footer.text = "A/D or Left/Right switch mission  W/S or Up/Down switch hunter  Enter or A deploy"


func update_audio_state() -> void:
	var desired_state := "explore"
	if stage_root != null and stage_root.has_method("get_audio_state"):
		desired_state = str(stage_root.call("get_audio_state"))
	if desired_state == active_audio_state:
		return
	active_audio_state = desired_state
	match desired_state:
		"explore":
			play_loop(explore_loop)
			stop_player(combat_loop)
			stop_player(clear_loop)
			stop_player(boss_loop)
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


func get_selected_stage_definition() -> Dictionary:
	if not bootstrap_runtime():
		return {}
	if catalog == null:
		return {}
	var stage_definition := catalog.get_stage_by_id(active_stage_id)
	if stage_definition.is_empty():
		stage_definition = catalog.get_first_stage()
	return stage_definition


func get_selected_character_definition() -> Dictionary:
	if not bootstrap_runtime():
		return {}
	if catalog == null:
		return {}
	var character_definition := catalog.get_character_by_id(active_character_id)
	if character_definition.is_empty():
		character_definition = catalog.get_character_by_id(catalog.get_first_character_id())
	return character_definition


func get_frontend_summary() -> Dictionary:
	bootstrap_runtime()
	return {
		"mode": frontend_mode,
		"selected_stage_id": active_stage_id,
		"selected_character_id": active_character_id,
		"stage_active": stage_root != null,
		"unlocked_stage_ids": profile.get_unlocked_stage_ids() if profile != null else [],
		"unlocked_character_ids": profile.get_unlocked_character_ids() if profile != null else [],
		"cleared_stage_ids": profile.get_cleared_stage_ids() if profile != null else [],
		"best_stage_result": profile.get_stage_result(active_stage_id) if profile != null else {},
		"save_path": profile.get_absolute_save_path() if profile != null else "",
		"notice": frontend_notice,
	}


func debug_start_selected_stage() -> void:
	bootstrap_runtime()
	start_selected_stage()


func debug_complete_selected_stage(rank: String, finish_seconds: float) -> void:
	record_stage_completion({
		"stage_complete": true,
		"rank": rank,
		"finish_seconds": finish_seconds,
	})


func debug_reset_profile() -> void:
	if not bootstrap_runtime():
		return
	if profile == null:
		return
	profile.reset(catalog)
	frontend_notice = profile.last_status_message
	teardown_stage()
	frontend_mode = "menu"
	sync_selection_from_profile()


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
