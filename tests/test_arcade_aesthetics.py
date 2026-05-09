def test_stage_backdrop_draws_arcade_layers(project_root):
    backdrop = (project_root / "scripts" / "stage_backdrop.gd").read_text()

    assert "class_name StageBackdrop" in backdrop
    assert "_draw_gradient_sky" in backdrop
    assert "_draw_parallax_ruins" in backdrop
    assert "_draw_luma_particles" in backdrop
    assert "_draw_vehicle_set_piece" in backdrop
    assert "_draw_foreground_atmosphere" in backdrop
    assert "biome" in backdrop


def test_stage_manager_draws_cracked_overpass_depth(project_root):
    stage_manager = (project_root / "scripts" / "stage_manager.gd").read_text()

    assert "_build_cracked_overpass_depth" in stage_manager
    assert "_build_broken_guardrails" in stage_manager
    assert "_build_luma_road_cracks" in stage_manager
    assert "_build_cinematic_stage_motion" in stage_manager
    assert "_tick_cinematic_stage_motion" in stage_manager
    assert "_build_cinematic_dinosaur" in stage_manager
    assert "cinematic-dinosaur" in stage_manager
    assert "cinematic-road-dust" in stage_manager
    assert "cracked elevated highway" in stage_manager
    assert "service-lane-shadow" in stage_manager
    assert "_register_asset_layer_motion" in stage_manager
    assert "asset-layer-foreground_atmosphere" in stage_manager
    assert "_configure_stage_camera" in stage_manager
    assert "limit_bottom = 720" in stage_manager


def test_stage_manager_uses_backdrop_renderer(project_root):
    stage_manager = (project_root / "scripts" / "stage_manager.gd").read_text()

    assert "stage_backdrop.gd" in stage_manager
    assert "_build_arcade_backdrop" in stage_manager
    assert "StageBackdrop" in stage_manager
    assert "VisualAssetLoader" in stage_manager
    assert "add_stage1_background_layers" in stage_manager


def test_visual_asset_loader_supports_asset_backed_backgrounds(project_root):
    loader = (project_root / "scripts" / "visual_asset_loader.gd").read_text()

    assert "class_name VisualAssetLoader" in loader
    assert "visual_assets.json" in loader
    assert "Sprite2D" in loader
    assert "ResourceLoader.exists" in loader
    assert "has_stage1_background_assets" in loader
    assert "actor_texture" in loader
    assert "actor_state_paths" in loader


def test_title_screen_has_arcade_presentation(project_root):
    app_root = (project_root / "scripts" / "app_root.gd").read_text()

    assert "_build_title_backdrop" in app_root
    assert "_build_hero_card" in app_root
    assert "_show_hero_capability_preview" in app_root
    assert "_build_roster_preview" in app_root
    assert "_build_planned_hero_badge" in app_root
    assert "PLANNED HERO" in app_root
    assert "selected_hero_index" in app_root
    assert "_draw_title_vehicle" in app_root
    assert "controls_label" in app_root
    assert "Attack J" in app_root
    assert "ARCADE CAMPAIGN" in app_root
    assert "Kian Vale" in app_root
    assert "Tor Bram" in app_root


def test_characters_use_arcade_sprite_details(project_root):
    player = (project_root / "scripts" / "player_controller.gd").read_text()
    enemy = (project_root / "scripts" / "enemy_actor.gd").read_text()

    assert "_draw_sprite_outline" in player
    assert "_draw_motion_smear" in player
    assert "_animation_bob" in player
    assert "_load_visual_sprites" in player
    assert "_draw_visual_sprite" in player
    assert "draw_set_transform" in player
    assert "_draw_sprite_outline" in enemy
    assert "_draw_luma_highlight" in enemy
    assert "_load_visual_sprites" in enemy
    assert "_draw_visual_sprite" in enemy
    assert "_current_visual_sprite_state" in enemy
    assert "_visual_target_size" in enemy
    assert "_visual_motion_amount" in enemy


def test_enemies_have_readable_humanoid_silhouettes(project_root):
    enemy = (project_root / "scripts" / "enemy_actor.gd").read_text()

    assert "_draw_humanoid_limb_outline" in enemy
    assert "_draw_human_armor_panels" in enemy
    assert "_draw_enemy_flinch_pose" in enemy
    assert "helmet_eye_slit" in enemy


def test_brask_can_use_manifest_backed_sprite_art(project_root):
    boss = (project_root / "scripts" / "boss_brask_noll.gd").read_text()

    assert "VisualAssetLoader" in boss
    assert "_load_visual_sprites" in boss
    assert "_draw_visual_sprite" in boss
    assert "brask_noll" in boss
    assert "animation_time" in boss
