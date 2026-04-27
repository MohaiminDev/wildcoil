extends Node2D

const ContentCatalog = preload("res://scripts/core/content_catalog.gd")
const InputActions = preload("res://scripts/core/input_actions.gd")
const InputDeviceState = preload("res://scripts/core/input_device_state.gd")
const PlaceholderAudioLibrary = preload("res://scripts/core/placeholder_audio_library.gd")
const ProgressionProfile = preload("res://scripts/core/progression_profile.gd")

@onready var hud_panel: PanelContainer = $HUD/Margin/Panel
@onready var status_label: Label = $HUD/Margin/Panel/VBox/Status
@onready var objective_label: Label = $HUD/Margin/Panel/VBox/Objective
@onready var boss_label: Label = $HUD/Margin/Panel/VBox/BossLabel
@onready var boss_bar: ProgressBar = $HUD/Margin/Panel/VBox/BossBar
@onready var controls_label: Label = $HUD/Margin/Panel/VBox/Controls
@onready var pause_overlay: CanvasLayer = $PauseOverlay
@onready var pause_shade: ColorRect = $PauseOverlay/Shade
@onready var pause_panel: PanelContainer = $PauseOverlay/Center/Panel
@onready var pause_body: Label = $PauseOverlay/Center/Panel/VBox/Body
@onready var mission_overlay: CanvasLayer = $MissionOverlay
@onready var mission_panel: PanelContainer = $MissionOverlay/Center/Panel
@onready var mission_title: Label = $MissionOverlay/Center/Panel/VBox/Title
@onready var mission_body: Label = $MissionOverlay/Center/Panel/VBox/Body
@onready var mission_footer: Label = $MissionOverlay/Center/Panel/VBox/Footer
@onready var explore_loop: AudioStreamPlayer = $Audio/ExploreLoop
@onready var combat_loop: AudioStreamPlayer = $Audio/CombatLoop
@onready var clear_loop: AudioStreamPlayer = $Audio/ClearLoop
@onready var boss_loop: AudioStreamPlayer = $Audio/BossLoop
@onready var spectacle_stinger: AudioStreamPlayer = $Audio/SpectacleStinger

const MUSIC_BASE_VOLUMES := {
	"explore": -18.0,
	"combat": -16.0,
	"clear": -18.0,
	"boss": -14.0,
}
const MENU_CONTROLS_PROMPT := "Menu: A/D or Left/Right mission  W/S or Up/Down hunter  Enter/Space deploy  Esc options"
const STAGE_CONTROLS_PROMPT := "Stage: A/D or arrows move  W/Space jump  Shift/C dodge  J/K/L/; attacks  Esc pause  R restart  F/F11 fullscreen"
const OPTIONS_FOOTER_PROMPT := "W/S or Up/Down focus  A/D or Left/Right or Enter change  Esc close"
const RESULTS_FOOTER_PROMPT := "Enter or Space to return to the mission board"
const MISSION_FOOTER_PROMPT := "A/D or Left/Right switch mission  W/S or Up/Down switch hunter  Enter or Space deploy  Esc options"
const PAUSE_FOOTER_PROMPT := "Esc resume  R restart checkpoint  F/F11 toggle fullscreen"
const SFX_BASE_VOLUMES := {
	"spectacle": -13.0,
}
const SCREEN_FLASH_LEVELS := [1.0, 0.4, 0.0]
const AUDIO_LEVELS := [0.0, -6.0, -12.0]

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
var menu_panel_mode := "board"
var selected_option_index := 0
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

	apply_profile_options()
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
		set_game_paused(not is_tree_paused())
		get_viewport().set_input_as_handled()
	elif is_tree_paused() and event.is_action_pressed(InputActions.RESTART_CHECKPOINT):
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
	explore_loop.volume_db = MUSIC_BASE_VOLUMES["explore"]
	combat_loop.stream = PlaceholderAudioLibrary.make_combat_loop()
	combat_loop.volume_db = MUSIC_BASE_VOLUMES["combat"]
	clear_loop.stream = PlaceholderAudioLibrary.make_clear_loop()
	clear_loop.volume_db = MUSIC_BASE_VOLUMES["clear"]
	boss_loop.stream = PlaceholderAudioLibrary.make_boss_loop()
	boss_loop.volume_db = MUSIC_BASE_VOLUMES["boss"]
	spectacle_stinger.stream = PlaceholderAudioLibrary.make_spectacle_stinger()
	spectacle_stinger.volume_db = SFX_BASE_VOLUMES["spectacle"]


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
	apply_profile_options()
	return true


func handle_frontend_input(event: InputEvent) -> void:
	if frontend_mode == "results" and event.is_action_pressed(InputActions.MENU_BACK):
		return_to_mission_board()
		get_viewport().set_input_as_handled()
		return

	if frontend_mode == "menu" and event.is_action_pressed(InputActions.MENU_BACK):
		toggle_options_menu()
		get_viewport().set_input_as_handled()
		return

	if frontend_mode == "menu" and menu_panel_mode == "options":
		if event.is_action_pressed(InputActions.MENU_UP):
			cycle_option_selection(-1)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed(InputActions.MENU_DOWN):
			cycle_option_selection(1)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed(InputActions.MENU_LEFT):
			adjust_selected_option(-1)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed(InputActions.MENU_RIGHT) or event.is_action_pressed(InputActions.MENU_CONFIRM):
			adjust_selected_option(1)
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
	if profile.mark_stage_briefing_seen(active_stage_id):
		frontend_notice = "Briefing logged for %s." % str(stage_definition.get("name", active_stage_id))
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
	apply_stage_accessibility_options()
	stage_result_recorded = false
	frontend_mode = "playing"
	menu_panel_mode = "board"
	active_audio_state = ""
	frontend_notice = "Deployed to %s with %s." % [
		str(stage_definition.get("name", "Unknown Stage")),
		str(character_definition.get("name", "Unknown Hunter")),
	]
	set_tree_paused_state(false)


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
	set_tree_paused_state(false)


func build_completion_notice(stage_id: String, rank: String, finish_seconds: float, progression_summary: Dictionary) -> String:
	var stage_definition := catalog.get_stage_by_id(stage_id)
	var notice_lines := [
		"%s cleared with rank %s in %s." % [
			str(stage_definition.get("name", stage_id)),
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
	var ending_title := str(stage_definition.get("ending_title", ""))
	var ending_summary := str(stage_definition.get("ending_summary", ""))
	if not ending_title.is_empty():
		notice_lines.append(ending_title)
	if not ending_summary.is_empty():
		notice_lines.append(ending_summary)
	notice_lines.append("Profile saved to %s." % profile.get_absolute_save_path())
	return "\n".join(notice_lines)


func return_to_mission_board() -> void:
	teardown_stage()
	frontend_mode = "menu"
	menu_panel_mode = "board"
	stage_result_recorded = false
	set_tree_paused_state(false)
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
	set_tree_paused_state(should_pause)
	for audio_player in [explore_loop, combat_loop, clear_loop, boss_loop, spectacle_stinger]:
		if audio_player != null:
			audio_player.stream_paused = should_pause
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


func toggle_options_menu() -> void:
	if frontend_mode != "menu":
		return
	if menu_panel_mode == "options":
		menu_panel_mode = "board"
		frontend_notice = "Mission board ready."
	else:
		menu_panel_mode = "options"
		selected_option_index = 0
		frontend_notice = "Opened comfort and accessibility options."


func cycle_option_selection(step: int) -> void:
	var option_entries := get_option_entries()
	if option_entries.is_empty():
		return
	selected_option_index = wrapi(selected_option_index + step, 0, option_entries.size())
	frontend_notice = "Option focus: %s." % str(option_entries[selected_option_index].get("label", "Setting"))


func adjust_selected_option(step: int) -> void:
	var option_entries := get_option_entries()
	if option_entries.is_empty():
		return
	selected_option_index = clampi(selected_option_index, 0, option_entries.size() - 1)
	var entry: Dictionary = option_entries[selected_option_index]
	var option_id := str(entry.get("id", ""))
	match option_id:
		"high_contrast_hud", "reduced_motion", "auto_pause_on_focus_loss":
			set_named_option(option_id, not bool(profile.get_option_value(option_id, false)))
		"screen_flash_strength":
			cycle_named_option(option_id, SCREEN_FLASH_LEVELS, step)
		"music_volume_db", "sfx_volume_db":
			cycle_named_option(option_id, AUDIO_LEVELS, step)
		"faux_fullscreen":
			set_faux_fullscreen(not faux_fullscreen, true)
			apply_profile_options()
			frontend_notice = "View mode: %s." % ("borderless fullscreen" if faux_fullscreen else "windowed")
		"close":
			toggle_options_menu()


func set_named_option(option_id: String, option_value: Variant) -> void:
	if profile == null:
		return
	profile.set_option_value(option_id, option_value)
	profile.save()
	apply_profile_options()
	frontend_notice = "%s: %s." % [describe_option_label(option_id), describe_option_value(option_id, option_value)]


func cycle_named_option(option_id: String, levels: Array, step: int) -> void:
	if profile == null:
		return
	var current_value: Variant = profile.get_option_value(option_id, levels[0])
	var current_index := levels.find(current_value)
	if current_index < 0:
		current_index = 0
	var next_index := wrapi(current_index + step, 0, levels.size())
	set_named_option(option_id, levels[next_index])


func get_option_entries() -> Array[Dictionary]:
	var options := get_profile_option_snapshot()
	return [
		{
			"id": "high_contrast_hud",
			"label": "High-contrast HUD",
			"value": describe_option_value("high_contrast_hud", options.get("high_contrast_hud", false)),
		},
		{
			"id": "reduced_motion",
			"label": "Reduced motion",
			"value": describe_option_value("reduced_motion", options.get("reduced_motion", false)),
		},
		{
			"id": "screen_flash_strength",
			"label": "Screen flash",
			"value": describe_option_value("screen_flash_strength", options.get("screen_flash_strength", 1.0)),
		},
		{
			"id": "auto_pause_on_focus_loss",
			"label": "Auto-pause on focus loss",
			"value": describe_option_value("auto_pause_on_focus_loss", options.get("auto_pause_on_focus_loss", true)),
		},
		{
			"id": "music_volume_db",
			"label": "Music mix",
			"value": describe_option_value("music_volume_db", options.get("music_volume_db", 0.0)),
		},
		{
			"id": "sfx_volume_db",
			"label": "SFX mix",
			"value": describe_option_value("sfx_volume_db", options.get("sfx_volume_db", 0.0)),
		},
		{
			"id": "faux_fullscreen",
			"label": "View mode",
			"value": describe_option_value("faux_fullscreen", options.get("faux_fullscreen", false)),
		},
		{
			"id": "close",
			"label": "Back to mission board",
			"value": "Close",
		},
	]


func get_profile_option_snapshot() -> Dictionary:
	if profile == null:
		return {
			"faux_fullscreen": faux_fullscreen,
			"music_volume_db": 0.0,
			"sfx_volume_db": 0.0,
			"high_contrast_hud": false,
			"reduced_motion": false,
			"screen_flash_strength": 1.0,
			"auto_pause_on_focus_loss": true,
		}
	return {
		"faux_fullscreen": faux_fullscreen,
		"music_volume_db": float(profile.get_option_value("music_volume_db", 0.0)),
		"sfx_volume_db": float(profile.get_option_value("sfx_volume_db", 0.0)),
		"high_contrast_hud": bool(profile.get_option_value("high_contrast_hud", false)),
		"reduced_motion": bool(profile.get_option_value("reduced_motion", false)),
		"screen_flash_strength": clampf(float(profile.get_option_value("screen_flash_strength", 1.0)), 0.0, 1.0),
		"auto_pause_on_focus_loss": bool(profile.get_option_value("auto_pause_on_focus_loss", true)),
	}


func describe_option_label(option_id: String) -> String:
	for entry in get_option_entries():
		if str(entry.get("id", "")) == option_id:
			return str(entry.get("label", option_id))
	return option_id


func describe_option_value(option_id: String, option_value: Variant) -> String:
	match option_id:
		"high_contrast_hud", "reduced_motion", "auto_pause_on_focus_loss":
			return "On" if bool(option_value) else "Off"
		"faux_fullscreen":
			return "Borderless fullscreen" if bool(option_value) else "Windowed"
		"screen_flash_strength":
			var flash_value := clampf(float(option_value), 0.0, 1.0)
			if flash_value <= 0.05:
				return "Off"
			if flash_value <= 0.45:
				return "Low"
			return "Full"
		"music_volume_db", "sfx_volume_db":
			var volume_value := float(option_value)
			if is_equal_approx(volume_value, 0.0):
				return "Full"
			if is_equal_approx(volume_value, -6.0):
				return "Reduced"
			return "Low"
		_:
			return str(option_value)


func apply_profile_options() -> void:
	apply_hud_theme()
	apply_audio_mix()
	apply_stage_accessibility_options()


func apply_hud_theme() -> void:
	if hud_panel == null or pause_panel == null or mission_panel == null:
		return
	var high_contrast := bool(get_profile_option_snapshot().get("high_contrast_hud", false))
	var panel_tint := Color("fff9f1") if not high_contrast else Color("f3f0a6")
	var font_color := Color("f7f5ef") if not high_contrast else Color("16120f")
	var accent_color := Color("f0d0a8") if not high_contrast else Color("16120f")
	hud_panel.self_modulate = panel_tint
	pause_panel.self_modulate = panel_tint
	mission_panel.self_modulate = panel_tint
	pause_shade.color = Color(0, 0, 0, 0.72 if not high_contrast else 0.82)
	for label in [status_label, objective_label, boss_label, controls_label, pause_body, mission_title, mission_body, mission_footer]:
		label.add_theme_color_override("font_color", font_color)
	status_label.add_theme_font_size_override("font_size", 18 if not high_contrast else 22)
	objective_label.add_theme_font_size_override("font_size", 18 if not high_contrast else 22)
	boss_label.add_theme_font_size_override("font_size", 18 if not high_contrast else 20)
	controls_label.add_theme_font_size_override("font_size", 16 if not high_contrast else 18)
	pause_body.add_theme_font_size_override("font_size", 18 if not high_contrast else 20)
	mission_title.add_theme_font_size_override("font_size", 30 if not high_contrast else 34)
	mission_body.add_theme_font_size_override("font_size", 20 if not high_contrast else 22)
	mission_footer.add_theme_font_size_override("font_size", 18 if not high_contrast else 20)
	boss_bar.self_modulate = accent_color
	hud_panel.custom_minimum_size = Vector2(700, 250) if not high_contrast else Vector2(760, 286)
	mission_panel.custom_minimum_size = Vector2(860, 380) if not high_contrast else Vector2(940, 430)
	pause_panel.custom_minimum_size = Vector2(620, 220) if not high_contrast else Vector2(680, 250)


func apply_audio_mix() -> void:
	if explore_loop == null or combat_loop == null or clear_loop == null or boss_loop == null or spectacle_stinger == null:
		return
	var options := get_profile_option_snapshot()
	var master_shift := float(profile.get_option_value("master_volume_db", 0.0)) if profile != null else 0.0
	var music_shift := float(options.get("music_volume_db", 0.0)) + master_shift
	var sfx_shift := float(options.get("sfx_volume_db", 0.0)) + master_shift
	explore_loop.volume_db = MUSIC_BASE_VOLUMES["explore"] + music_shift
	combat_loop.volume_db = MUSIC_BASE_VOLUMES["combat"] + music_shift
	clear_loop.volume_db = MUSIC_BASE_VOLUMES["clear"] + music_shift
	boss_loop.volume_db = MUSIC_BASE_VOLUMES["boss"] + music_shift
	spectacle_stinger.volume_db = SFX_BASE_VOLUMES["spectacle"] + sfx_shift


func apply_stage_accessibility_options() -> void:
	if stage_root == null or not stage_root.has_method("apply_accessibility_options"):
		return
	var options := get_profile_option_snapshot()
	stage_root.call("apply_accessibility_options", {
		"reduced_motion": bool(options.get("reduced_motion", false)),
		"screen_flash_strength": float(options.get("screen_flash_strength", 1.0)),
	})


func build_progress_text() -> String:
	return "Cleared stages: %d/%d  Unlocked missions: %d/%d  Unlocked hunters: %d/%d" % [
		profile.get_cleared_stage_ids().size() if profile != null else 0,
		catalog.get_stage_ids().size() if catalog != null else 0,
		profile.get_unlocked_stage_ids().size() if profile != null else 0,
		catalog.get_stage_ids().size() if catalog != null else 0,
		profile.get_unlocked_character_ids().size() if profile != null else 0,
		catalog.get_character_ids().size() if catalog != null else 0,
	]


func build_progression_hint(stage_definition: Dictionary) -> String:
	if profile == null or catalog == null:
		return "Profile booting."
	var stage_id := str(stage_definition.get("id", ""))
	if not profile.get_cleared_stage_ids().has(stage_id):
		var next_unlocks: Array[String] = []
		var reward_character_id := str(stage_definition.get("reward_character_id", ""))
		if not reward_character_id.is_empty() and not profile.is_character_unlocked(reward_character_id):
			next_unlocks.append("hunter %s" % str(catalog.get_character_by_id(reward_character_id).get("name", reward_character_id)))
		var next_stage_id := catalog.get_next_stage_id(stage_id)
		if not next_stage_id.is_empty() and not profile.is_stage_unlocked(next_stage_id):
			next_unlocks.append("mission %s" % str(catalog.get_stage_by_id(next_stage_id).get("name", next_stage_id)))
		if next_unlocks.is_empty():
			return "Clear this mission to lock in a better rank and time."
		return "Clear this mission to unlock %s." % " and ".join(next_unlocks)
	var next_stage_id := catalog.get_next_stage_id(stage_id)
	if not next_stage_id.is_empty():
		return "Next target: %s." % str(catalog.get_stage_by_id(next_stage_id).get("name", next_stage_id))
	return "Final route cleared. Chase a better rank or time."


func build_stage_briefing_text(stage_definition: Dictionary, character_definition: Dictionary) -> String:
	var stage_id := str(stage_definition.get("id", ""))
	var briefing_intro := "Mission briefing"
	if profile != null and not profile.has_seen_stage_briefing(stage_id):
		briefing_intro = "First-run briefing"
	var stage_briefing := str(stage_definition.get("briefing", stage_definition.get("summary", "No mission briefing available.")))
	var hunter_tip := str(character_definition.get("onboarding_tip", character_definition.get("summary", "No hunter notes available.")))
	return "%s: %s\nHunter note: %s\nProgression: %s" % [
		briefing_intro,
		stage_briefing,
		hunter_tip,
		build_progression_hint(stage_definition),
	]


func build_options_body() -> String:
	var lines := [
		"Comfort options stay in the pilot profile and apply immediately.",
		"Use W/S or Up/Down to focus a setting and A/D or Left/Right or Enter to change it.",
	]
	var option_entries := get_option_entries()
	selected_option_index = clampi(selected_option_index, 0, max(option_entries.size() - 1, 0))
	for index in range(option_entries.size()):
		var entry: Dictionary = option_entries[index]
		var prefix := ">" if index == selected_option_index else " "
		lines.append("%s %s: %s" % [
			prefix,
			str(entry.get("label", "Setting")),
			str(entry.get("value", "")),
		])
	return "\n".join(lines)


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
		var briefing_status := "reviewed"
		if profile != null and not profile.has_seen_stage_briefing(active_stage_id):
			briefing_status = "pending"
		objective_label.text = "Selected route: %s\nSelected hunter: %s\nCleared stages: %d/%d  Unlocked hunters: %d/%d\nBest record: %s" % [
			stage_name,
			str(get_selected_character_definition().get("name", "Unknown Hunter")),
			profile.get_cleared_stage_ids().size() if profile != null else 0,
			catalog.get_stage_ids().size() if catalog != null else 0,
			profile.get_unlocked_character_ids().size() if profile != null else 0,
			catalog.get_character_ids().size() if catalog != null else 0,
			"%s  Briefing %s" % [
				profile.describe_stage_result(active_stage_id) if profile != null else "No profile loaded",
				briefing_status,
			],
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

	controls_label.text = "%s\n%s" % [MENU_CONTROLS_PROMPT, STAGE_CONTROLS_PROMPT]


func update_pause_overlay() -> void:
	pause_overlay.visible = frontend_mode == "playing" and is_tree_paused()
	if not pause_overlay.visible:
		return
	var stage_summary := get_stage_summary()
	var fullscreen_label := "Fullscreen" if faux_fullscreen else "Windowed"
	pause_body.text = "Objective: %s\nTime: %s  Checkpoint resets: %d\nView: %s\n%s" % [
		str(stage_summary.get("objective", "Resume the relay run")),
		format_seconds(float(stage_summary.get("elapsed_seconds", 0.0))),
		int(stage_summary.get("checkpoint_resets", 0)),
		fullscreen_label,
		PAUSE_FOOTER_PROMPT,
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
	var ending_summary := str(stage_definition.get("ending_summary", ""))
	var progress_text := build_progress_text()
	var note_text := "" if frontend_notice.is_empty() else "\nNotice: %s" % frontend_notice

	if frontend_mode == "results":
		mission_title.text = str(stage_definition.get("ending_title", "Stage Clear"))
		var ending_text := "" if ending_summary.is_empty() else "\nEnding: %s" % ending_summary
		mission_body.text = "Mission: %s\nHunter: %s\nView: %s\n%s\nBest record: %s\nNext step: %s\nSave path: %s%s%s" % [
			stage_name,
			character_name,
			view_label,
			progress_text,
			profile.describe_stage_result(active_stage_id) if profile != null else "--",
			build_progression_hint(stage_definition),
			profile.get_absolute_save_path() if profile != null else "--",
			note_text,
			ending_text,
		]
		mission_footer.text = RESULTS_FOOTER_PROMPT
	elif menu_panel_mode == "options":
		mission_title.text = "Comfort and Accessibility"
		mission_body.text = "%s\nSave path: %s%s" % [
			build_options_body(),
			profile.get_absolute_save_path() if profile != null else "--",
			note_text,
		]
		mission_footer.text = OPTIONS_FOOTER_PROMPT
	else:
		mission_title.text = "Mission Board"
		mission_body.text = "Mission: %s\nBiome: %s  Stage order: %d/%d\nHunter: %s (%s)\nProfile: %s\nView: %s\n%s\n%s\nBest record: %s\nSave path: %s%s" % [
			stage_name,
			str(stage_definition.get("biome", "unknown_biome")),
			int(stage_definition.get("order", 1)),
			catalog.get_stage_ids().size() if catalog != null else 1,
			character_name,
			str(character_definition.get("playstyle", "unknown")),
			str(character_definition.get("summary", "No hunter summary available.")),
			view_label,
			progress_text,
			build_stage_briefing_text(stage_definition, character_definition),
			profile.describe_stage_result(active_stage_id) if profile != null else "--",
			profile.get_absolute_save_path() if profile != null else "--",
			note_text,
		]
		mission_footer.text = MISSION_FOOTER_PROMPT


func get_keyboard_prompt_contract() -> Dictionary:
	return {
		"menu_controls": MENU_CONTROLS_PROMPT,
		"stage_controls": STAGE_CONTROLS_PROMPT,
		"options_footer": OPTIONS_FOOTER_PROMPT,
		"results_footer": RESULTS_FOOTER_PROMPT,
		"mission_footer": MISSION_FOOTER_PROMPT,
		"pause_footer": PAUSE_FOOTER_PROMPT,
	}


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
	if not player.is_inside_tree():
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
		"menu_panel_mode": menu_panel_mode,
		"selected_stage_id": active_stage_id,
		"selected_character_id": active_character_id,
		"stage_active": stage_root != null,
		"unlocked_stage_ids": profile.get_unlocked_stage_ids() if profile != null else [],
		"unlocked_character_ids": profile.get_unlocked_character_ids() if profile != null else [],
		"cleared_stage_ids": profile.get_cleared_stage_ids() if profile != null else [],
		"seen_stage_briefing_ids": profile.get_seen_stage_briefing_ids() if profile != null else [],
		"best_stage_result": profile.get_stage_result(active_stage_id) if profile != null else {},
		"options": get_profile_option_snapshot(),
		"briefing_pending": profile != null and not profile.has_seen_stage_briefing(active_stage_id),
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


func debug_open_options_menu() -> void:
	if not bootstrap_runtime():
		return
	if menu_panel_mode != "options":
		toggle_options_menu()


func debug_set_option_value(option_id: String, option_value: Variant) -> void:
	if not bootstrap_runtime():
		return
	if option_id == "faux_fullscreen":
		set_faux_fullscreen(bool(option_value), true)
		apply_profile_options()
		return
	set_named_option(option_id, option_value)


func debug_get_stage_accessibility() -> Dictionary:
	if stage_root != null and stage_root.has_method("get_stage_summary"):
		return stage_root.call("get_stage_summary")
	return {}


func debug_reset_profile() -> void:
	if not bootstrap_runtime():
		return
	if profile == null:
		return
	profile.reset(catalog)
	frontend_notice = profile.last_status_message
	teardown_stage()
	frontend_mode = "menu"
	menu_panel_mode = "board"
	sync_selection_from_profile()
	apply_profile_options()


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


func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_WM_WINDOW_FOCUS_OUT]:
		if frontend_mode == "playing" and profile != null and bool(profile.get_option_value("auto_pause_on_focus_loss", true)):
			set_game_paused(true)
			frontend_notice = "Auto-paused after focus loss."


func _on_joy_connection_changed(device: int, connected: bool) -> void:
	input_device_state.handle_connection_change(device, connected)


func set_tree_paused_state(should_pause: bool) -> void:
	if not is_inside_tree():
		return
	var tree := get_tree()
	if tree != null:
		tree.paused = should_pause


func is_tree_paused() -> bool:
	if not is_inside_tree():
		return false
	var tree := get_tree()
	return tree != null and tree.paused
