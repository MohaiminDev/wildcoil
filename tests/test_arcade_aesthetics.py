import json


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


def test_hero_select_cards_use_canted_arcade_frames(project_root):
    app_root = (project_root / "scripts" / "app_root.gd").read_text()

    assert "HERO_CARD_SIZE := Vector2(284, 198)" in app_root
    assert "HERO_CARD_SLANT := 22.0" in app_root
    assert "_build_hero_card_frame" in app_root
    assert "_build_hero_portrait_well" in app_root
    assert "_build_hero_stat_pips" in app_root
    assert "hero-select-canted-frame" in app_root
    assert "hero-card-selected-glow" in app_root
    assert "hero-card-neon-edge" in app_root
    assert "planned-hero-silhouette" in app_root
    assert "hero-stat-pip" in app_root
    assert "selected_glow.visible" in app_root


def test_hero_select_uses_canted_arcade_header(project_root):
    app_root = (project_root / "scripts" / "app_root.gd").read_text()

    assert "hero_select_header_group" in app_root
    assert "_build_hero_select_header" in app_root
    assert "_set_hero_select_header_visible" in app_root
    assert "hero-select-header-frame" in app_root
    assert "hero-select-route-ribbon" in app_root
    assert "hero-select-command-label" in app_root
    assert "_set_hero_select_header_visible(true)" in app_root
    assert "_set_hero_select_header_visible(false)" in app_root
    assert "label.text = \"\"" in app_root


def test_title_screen_uses_branded_logo_lockup(project_root):
    app_root = (project_root / "scripts" / "app_root.gd").read_text()

    assert "_build_title_logo_lockup" in app_root
    assert "_set_title_logo_visible" in app_root
    assert "title-logo-lockup" in app_root
    assert "title-logo-shadow" in app_root
    assert "title-logo-rift-crack" in app_root
    assert "title-subtitle-ribbon" in app_root
    assert "title-start-plate" in app_root
    assert "RIFT\\nROAD" in app_root
    assert "BEASTS OF THE AFTERGLOW" in app_root
    assert "_set_title_logo_visible(false)" in app_root


def test_result_screens_use_canted_arcade_overlay(project_root):
    app_root = (project_root / "scripts" / "app_root.gd").read_text()

    assert "_build_result_overlay_frame" in app_root
    assert "_set_result_overlay_visible" in app_root
    assert "result-overlay-frame" in app_root
    assert "result-clear-frame" in app_root
    assert "result-route-ribbon" in app_root
    assert "result-control-rail" in app_root
    assert "stage-clear-accent-slash" in app_root
    assert "_set_result_overlay_visible(true)" in app_root
    assert "_set_result_overlay_visible(false)" in app_root


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


def test_stage_one_has_premium_readability_grade(project_root):
    stage_manager = (project_root / "scripts" / "stage_manager.gd").read_text()

    assert "_build_premium_readability_grade" in stage_manager
    assert "premium-sunset-grade" in stage_manager
    assert "premium-fight-plane-shadow" in stage_manager
    assert "premium-luma-rim" in stage_manager
    assert "premium-readability-lane" in stage_manager


def test_hud_uses_asset_backed_arcade_portrait_and_meter_ticks(project_root):
    hud = (project_root / "scripts" / "hud_controller.gd").read_text()

    assert "VisualAssetLoader" in hud
    assert "PLAYER_PANEL_SIZE := Vector2(320, 74)" in hud
    assert "PLAYER_PORTRAIT_SIZE := Vector2(52, 58)" in hud
    assert "SCORE_PANEL_SIZE := Vector2(256, 54)" in hud
    assert "OBJECTIVE_PANEL_SIZE := Vector2(444, 38)" in hud
    assert "_make_arcade_panel" in hud
    assert "_make_portrait_frame" in hud
    assert "_update_portrait_texture" in hud
    assert "_make_bar_ticks" in hud
    assert "_hero_accent_color" in hud
    assert "TextureRect" in hud
    assert "actor_texture" in hud
    assert "bar-tick" in hud
    assert "Color(0.025, 0.028, 0.032, 0.68)" in hud
    assert "Color(0.025, 0.028, 0.032, 0.62)" in hud
    assert "Color(0.025, 0.028, 0.032, 0.58)" in hud


def test_stage_one_objective_rail_uses_compact_hud_copy(project_root):
    stage_data = json.loads((project_root / "data" / "stages.json").read_text())
    stage_one = next(stage for stage in stage_data["stages"] if stage["id"] == "sunset_overpass")
    hud = (project_root / "scripts" / "hud_controller.gd").read_text()
    stage_manager = (project_root / "scripts" / "stage_manager.gd").read_text()

    assert len(stage_one["scenario_goal"]) > 42
    assert stage_one["hud_goal"] == "Free caged dinos"
    assert len(stage_one["hud_goal"]) <= 20
    assert "OBJECTIVE_PANEL_SIZE := Vector2(444, 38)" in hud
    assert "OBJECTIVE_LABEL_SIZE := Vector2(396, 20)" in hud
    assert "AUTOWRAP_OFF" in hud
    assert "_stage_hud_goal" in stage_manager
    assert "stage_data.get(\"hud_goal\"" in stage_manager


def test_stage_one_intro_card_uses_non_ellipsized_goal_copy(project_root):
    stage_data = json.loads((project_root / "data" / "stages.json").read_text())
    stage_one = next(stage for stage in stage_data["stages"] if stage["id"] == "sunset_overpass")
    stage_manager = (project_root / "scripts" / "stage_manager.gd").read_text()

    assert stage_one["scenario_goal"] == "Break the Iron Veil roadblock and free the transport cages"
    assert stage_one["stage_card_goal"] == "Free the transport cages"
    assert stage_one["stage_card_goal"] != stage_one["scenario_goal"]
    assert len(stage_one["stage_card_goal"]) <= 46
    assert "_stage_card_goal" in stage_manager
    assert "stage_data.get(\"stage_card_goal\"" in stage_manager
    assert "combat_fx.show_stage_card(stage_data[\"title\"], stage_card_goal, next_wave_index)" in stage_manager


def test_wave_notice_auto_clears_after_intro_strap(project_root):
    hud = (project_root / "scripts" / "hud_controller.gd").read_text()
    stage_manager = (project_root / "scripts" / "stage_manager.gd").read_text()

    assert "var notice_timer := 0.0" in hud
    assert "func _process(delta: float) -> void:" in hud
    assert "func show_notice(text: String, duration := 0.0) -> void:" in hud
    assert "func clear_notice() -> void:" in hud
    assert "notice_timer -= delta" in hud
    assert "clear_notice()" in hud
    assert "hud.show_notice(\"%s\\nWave %d\" % [stage_data[\"title\"], next_wave_index + 1], 1.25)" in stage_manager


def test_asset_backed_stage_one_has_jungle_road_ruins_set_dressing(project_root):
    stage_manager = (project_root / "scripts" / "stage_manager.gd").read_text()

    assert "_build_stage1_asset_set_dressing" in stage_manager
    assert "_build_ruined_overpass_sign" in stage_manager
    assert "_build_luma_plant_cluster" in stage_manager
    assert "_build_road_rubble_cluster" in stage_manager
    assert "_build_transport_cage_silhouette" in stage_manager
    assert "stage1-ruined-signpost" in stage_manager
    assert "stage1-luma-plant-cluster" in stage_manager
    assert "stage1-road-rubble" in stage_manager
    assert "stage1-transport-cage-silhouette" in stage_manager
