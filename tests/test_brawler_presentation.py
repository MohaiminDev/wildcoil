import json


def test_stage_manager_has_real_brawler_flow(project_root):
    stage_script = (project_root / "scripts" / "stage_manager.gd").read_text()

    assert "ArcadeCombatFx" in stage_script
    assert "_build_arena_boundaries" in stage_script
    assert "_assign_arcade_enemy_slots" in stage_script
    assert "_tick_belt_scroll_composition" in stage_script
    assert "_apply_enemy_spacing" in stage_script
    assert "set_demo_autoplay" in stage_script
    assert "_tick_demo_autoplay" in stage_script
    assert "_nearest_demo_target" in stage_script
    assert "_show_wave_objective" in stage_script
    assert "_show_boss_intro" in stage_script
    assert "_spawn_hit_feedback" in stage_script
    assert "_spawn_victory_banner" in stage_script
    assert "_apply_camera_punch" in stage_script
    assert "_tick_cinematic_camera" in stage_script
    assert "_cinematic_focus_point" in stage_script
    assert "_emit_combat_motion_dust" in stage_script
    assert "stage_data.get(\"scenario_goal\"" in stage_script


def test_combat_fx_draws_arcade_fighting_feedback(project_root):
    fx_script = (project_root / "scripts" / "arcade_combat_fx.gd").read_text()

    assert "class_name ArcadeCombatFx" in fx_script
    assert "show_stage_card" in fx_script
    assert "show_boss_intro" in fx_script
    assert "show_victory_banner" in fx_script
    assert "spawn_hit_spark" in fx_script
    assert "spawn_attack_arc" in fx_script
    assert "spawn_damage_number" in fx_script
    assert "COMBO" in fx_script


def test_hud_and_player_surface_win_combat_rules(project_root):
    hud_script = (project_root / "scripts" / "hud_controller.gd").read_text()
    player_script = (project_root / "scripts" / "player_controller.gd").read_text()

    assert "objective_label" in hud_script
    assert "combo_label" in hud_script
    assert "update_objective" in hud_script
    assert "update_combo" in hud_script
    assert "combo_count" in player_script
    assert "register_hit" in player_script
    assert "_draw_combo_charge" in player_script
    assert "attack_step" in player_script
    assert "attack_lunge_timer" in player_script
    assert "set_demo_control" in player_script
    assert "set_demo_intent" in player_script
    assert "attack_buffer_timer" in player_script
    assert "special_rect" in player_script
    assert "_visual_squash_scale" in player_script
    assert "_visual_tilt" in player_script
    assert "_make_panel" in hud_script


def test_enemies_and_bosses_have_distinct_attack_scenarios(project_root):
    enemy_script = (project_root / "scripts" / "enemy_actor.gd").read_text()
    boss_script = (project_root / "scripts" / "boss_brask_noll.gd").read_text()
    stages = (project_root / "data" / "stages.json").read_text()
    wave_spawner = (project_root / "scripts" / "wave_spawner.gd").read_text()

    assert "_apply_behavior_movement" in enemy_script
    assert "configure_arcade_slot" in enemy_script
    assert "start_cinematic_entry" in enemy_script
    assert "_tick_cinematic_entry" in enemy_script
    assert "cinematic_entry_active" in enemy_script
    assert "_arcade_engagement_offset" in enemy_script
    assert "_visual_squash_scale" in enemy_script
    assert "_draw_behavior_weapon" in enemy_script
    assert "start_cinematic_entry" in wave_spawner
    assert "offscreen_start" in wave_spawner
    assert "ranged_thrower" in enemy_script
    assert "territorial_charge" in enemy_script
    assert "_draw_move_telegraph" in boss_script
    assert "_draw_boss_portrait_read" in boss_script
    assert "move_telegraphed" in boss_script
    assert "phase_changed" in boss_script
    assert "scenario_goal" in stages
    assert "win_condition" in stages


def test_stage_has_hit_stop_and_audio_hooks(project_root):
    stage_script = (project_root / "scripts" / "stage_manager.gd").read_text()
    audio_script = (project_root / "scripts" / "audio_manager.gd").read_text()

    assert "_apply_hit_stop" in stage_script
    assert "Engine.time_scale" in stage_script
    assert "play_stage_music" in stage_script
    assert "play_boss_warning" in stage_script
    assert "AudioStreamWAV" in audio_script
    assert "play_victory" in audio_script


def test_actors_have_cinematic_motion_language(project_root):
    player_script = (project_root / "scripts" / "player_controller.gd").read_text()
    enemy_script = (project_root / "scripts" / "enemy_actor.gd").read_text()
    boss_script = (project_root / "scripts" / "boss_brask_noll.gd").read_text()

    for script in [player_script, enemy_script, boss_script]:
        assert "_motion_frame" in script
        assert "_draw_cinematic_afterimage" in script
        assert "_draw_contact_shadow" in script

    assert "_draw_hero_motion_details" in player_script
    assert "_draw_enemy_motion_details" in enemy_script
    assert "_draw_boss_motion_details" in boss_script


def test_capture_tool_supports_nika_boss_evidence(project_root):
    capture_script = (project_root / "tools" / "capture_stage_screenshot.gd").read_text()

    assert "capture_hero_id" in capture_script
    assert "capture_mode" in capture_script
    assert "stage.hero_id = capture_hero_id" in capture_script
    assert "_arrange_boss_capture_scene" in capture_script
    assert "brask_noll" in capture_script
    assert "nika_sol" in capture_script


def test_combat_impact_has_layered_non_bloody_feedback(project_root):
    fx_script = (project_root / "scripts" / "arcade_combat_fx.gd").read_text()
    stage_script = (project_root / "scripts" / "stage_manager.gd").read_text()
    capture_script = (project_root / "tools" / "capture_stage_screenshot.gd").read_text()

    assert "non_bloody_impact_palette" in fx_script
    assert "spawn_impact_burst" in fx_script
    assert "_build_impact_ring" in fx_script
    assert "_build_directional_speed_lines" in fx_script
    assert "_build_hit_stop_flash" in fx_script
    assert "spawn_impact_burst" in stage_script
    assert "_arrange_impact_capture_scene" in capture_script
    assert "capture_mode == \"impact\"" in capture_script


def test_app_flow_exposes_restart_and_return_to_title_controls(project_root):
    app_root = (project_root / "scripts" / "app_root.gd").read_text()
    runtime_runner = (project_root / "tools" / "runtime_test_runner.gd").read_text()

    assert "_restart_current_stage" in app_root
    assert "_restart_last_completed_stage" in app_root
    assert "_return_to_title_from_flow" in app_root
    assert "Restart Stage" in app_root
    assert "Return Title" in app_root
    assert "stage1_restart_flow" in runtime_runner


def test_stage_clear_surfaces_score_rank_summary(project_root):
    app_root = (project_root / "scripts" / "app_root.gd").read_text()
    stage_script = (project_root / "scripts" / "stage_manager.gd").read_text()

    assert "stage_clear_summary" in stage_script
    assert "_stage_clear_result_summary" in app_root
    assert "_format_stage_clear_result_summary" in app_root
    assert "RANK" in app_root
    assert "Score %d" in app_root
    assert "Luma %d" in app_root
    assert "Health %d/%d" in app_root


def test_audio_and_cinematic_polish_have_named_placeholder_hooks(project_root):
    audio_script = (project_root / "scripts" / "audio_manager.gd").read_text()
    fx_script = (project_root / "scripts" / "arcade_combat_fx.gd").read_text()
    stage_script = (project_root / "scripts" / "stage_manager.gd").read_text()
    capture_script = (project_root / "tools" / "capture_stage_screenshot.gd").read_text()
    provenance = (project_root.parent.parent / "docs" / "asset_provenance_register.md").read_text()

    for hook in ["play_stage_start", "play_wave_start", "play_boss_intro", "play_stage_clear"]:
        assert hook in audio_script
        assert "audio_manager.%s" % hook in stage_script

    assert "_play_chord" in audio_script
    assert "_short_banner_body" in fx_script
    assert "COMBO hits build special meter" not in fx_script
    assert "capture_mode == \"banner\"" in capture_script
    assert "Generated procedural audio tones" in provenance


def test_stage_intro_banner_preserves_combat_plane(project_root):
    fx_script = (project_root / "scripts" / "arcade_combat_fx.gd").read_text()

    assert "STAGE_CARD_WIDTH := 760.0" in fx_script
    assert "STAGE_CARD_HEIGHT := 58.0" in fx_script
    assert "STAGE_CARD_FONT_SIZE := 18" in fx_script
    assert "STAGE_CARD_BODY_LIMIT := 46" in fx_script
    assert "STAGE_CARD_Y_RATIO := 0.17" in fx_script
    assert "Color(0.05, 0.06, 0.08, 0.52)" in fx_script
    assert "STAGE_CARD_HEIGHT" in fx_script[fx_script.index("func show_stage_card"):fx_script.index("func show_boss_intro")]
    assert "STAGE_CARD_WIDTH" in fx_script[fx_script.index("func show_stage_card"):fx_script.index("func show_boss_intro")]
    assert "STAGE_CARD_Y_RATIO" in fx_script[fx_script.index("func show_stage_card"):fx_script.index("func show_boss_intro")]
    assert "banner_width := 0.0" in fx_script
    assert "banner_width_resolved" in fx_script
    assert "(SCREEN_SIZE.x - banner_width_resolved) * 0.5" in fx_script
    assert "_short_banner_body(body, body_limit)" in fx_script


def test_stage_one_opens_with_readable_onboarding_wave(project_root):
    stages_data = json.loads((project_root / "data" / "stages.json").read_text())
    stage_one = next(stage for stage in stages_data["stages"] if stage["id"] == "sunset_overpass")
    waves = stage_one["waves"]

    opening_enemies = waves[0]["enemies"]
    later_wave_counts = [len(wave["enemies"]) for wave in waves[1:]]

    assert len(opening_enemies) <= 4
    assert "scrap_hurler" not in opening_enemies
    assert "iron_veil_brute" not in opening_enemies
    assert max(later_wave_counts) > len(opening_enemies)


def test_stage_one_has_road_collapse_set_piece(project_root):
    stages_data = json.loads((project_root / "data" / "stages.json").read_text())
    stage_one = next(stage for stage in stages_data["stages"] if stage["id"] == "sunset_overpass")
    stage_manager = (project_root / "scripts" / "stage_manager.gd").read_text()
    fx_script = (project_root / "scripts" / "arcade_combat_fx.gd").read_text()

    road_collapse = next(event for event in stage_one["stage_events"] if event["id"] == "road_collapse")

    assert road_collapse["trigger_after_wave"] == 0
    assert road_collapse["resume_wave"] == 1
    assert "luma_extraction_spikes" in stage_one["set_pieces"]
    assert "road_collapse_triggered" in stage_manager
    assert "_advance_after_wave" in stage_manager
    assert "_trigger_road_collapse" in stage_manager
    assert "_tick_road_collapse" in stage_manager
    assert "_build_road_collapse_set_piece" in stage_manager
    assert "stage1-road-collapse-fracture" in stage_manager
    assert "ROAD COLLAPSE" in stage_manager
    assert "show_stage_event" in fx_script


def test_stage_one_has_brask_story_beats(project_root):
    stages_data = json.loads((project_root / "data" / "stages.json").read_text())
    stage_one = next(stage for stage in stages_data["stages"] if stage["id"] == "sunset_overpass")
    stage_manager = (project_root / "scripts" / "stage_manager.gd").read_text()

    boss_story = stage_one["boss_story"]

    assert boss_story["intro_title"] == "BRASK NOLL"
    assert "end of the ride" in boss_story["intro_line"].lower()
    assert "road comes down" in boss_story["phase_line"].lower()
    assert "already bought" in boss_story["escape_line"].lower()
    assert "_boss_story" in stage_manager
    assert "intro_line" in stage_manager
    assert "phase_line" in stage_manager
    assert "escape_line" in stage_manager
    assert "show_stage_event" in stage_manager


def test_controller_support_is_exposed_for_menu_and_combat(project_root):
    app_root = (project_root / "scripts" / "app_root.gd").read_text()
    player = (project_root / "scripts" / "player_controller.gd").read_text()
    runner = (project_root / "tools" / "runtime_test_runner.gd").read_text()

    assert "InputEventJoypadButton" in app_root
    assert "_handle_controller_button" in app_root
    assert "JOY_BUTTON_START" in app_root
    assert "JOY_BUTTON_A" in app_root
    assert "JOY_BUTTON_B" in app_root
    assert "Gamepad:" in app_root
    assert "JOY_AXIS_LEFT_X" in player
    assert "JOY_BUTTON_X" in player
    assert "JOY_BUTTON_RIGHT_SHOULDER" in player
    assert "_read_controller_move" in player
    assert "_is_controller_button_pressed" in player
    assert "controller_title_flow" in runner


def test_stage_one_has_repeatable_performance_budget_sample(project_root):
    runner = (project_root / "tools" / "runtime_test_runner.gd").read_text()
    quality = (project_root.parent.parent / "docs" / "performance_budget.md").read_text()

    assert "stage1_performance_sample" in runner
    assert "RIFT_ROAD_PERF stage1" in runner
    assert "PERFORMANCE_FRAME_BUDGET_MS" in runner
    assert "Stage 1 Performance Budget" in quality
    assert "stage1_performance_sample" in quality


def test_app_root_exposes_exported_app_stage_smoke_argument(project_root):
    app_root = (project_root / "scripts" / "app_root.gd").read_text()

    assert "--rift-road-smoke-stage1" in app_root
    assert "_should_autostart_stage1" in app_root
    assert "OS.get_cmdline_user_args" in app_root
    assert "WILDCOIL_AUTOSTART_STAGE1" in app_root
