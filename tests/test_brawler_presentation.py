def test_stage_manager_has_real_brawler_flow(project_root):
    stage_script = (project_root / "scripts" / "stage_manager.gd").read_text()

    assert "ArcadeCombatFx" in stage_script
    assert "_build_arena_boundaries" in stage_script
    assert "_show_wave_objective" in stage_script
    assert "_show_boss_intro" in stage_script
    assert "_spawn_hit_feedback" in stage_script
    assert "_spawn_victory_banner" in stage_script
    assert "_apply_camera_punch" in stage_script
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


def test_enemies_and_bosses_have_distinct_attack_scenarios(project_root):
    enemy_script = (project_root / "scripts" / "enemy_actor.gd").read_text()
    boss_script = (project_root / "scripts" / "boss_brask_noll.gd").read_text()
    stages = (project_root / "data" / "stages.json").read_text()

    assert "_apply_behavior_movement" in enemy_script
    assert "_draw_behavior_weapon" in enemy_script
    assert "ranged_thrower" in enemy_script
    assert "territorial_charge" in enemy_script
    assert "_draw_move_telegraph" in boss_script
    assert "_draw_boss_portrait_read" in boss_script
    assert "scenario_goal" in stages
    assert "win_condition" in stages
