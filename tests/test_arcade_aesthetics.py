def test_stage_backdrop_draws_arcade_layers(project_root):
    backdrop = (project_root / "scripts" / "stage_backdrop.gd").read_text()

    assert "class_name StageBackdrop" in backdrop
    assert "_draw_gradient_sky" in backdrop
    assert "_draw_parallax_ruins" in backdrop
    assert "_draw_luma_particles" in backdrop
    assert "_draw_vehicle_set_piece" in backdrop
    assert "_draw_foreground_atmosphere" in backdrop
    assert "biome" in backdrop


def test_stage_manager_uses_backdrop_renderer(project_root):
    stage_manager = (project_root / "scripts" / "stage_manager.gd").read_text()

    assert "stage_backdrop.gd" in stage_manager
    assert "_build_arcade_backdrop" in stage_manager
    assert "StageBackdrop" in stage_manager


def test_title_screen_has_arcade_presentation(project_root):
    app_root = (project_root / "scripts" / "app_root.gd").read_text()

    assert "_build_title_backdrop" in app_root
    assert "_build_hero_card" in app_root
    assert "_draw_title_vehicle" in app_root
    assert "ARCADE CAMPAIGN" in app_root


def test_characters_use_arcade_sprite_details(project_root):
    player = (project_root / "scripts" / "player_controller.gd").read_text()
    enemy = (project_root / "scripts" / "enemy_actor.gd").read_text()

    assert "_draw_sprite_outline" in player
    assert "_draw_motion_smear" in player
    assert "_animation_bob" in player
    assert "_draw_sprite_outline" in enemy
    assert "_draw_luma_highlight" in enemy

