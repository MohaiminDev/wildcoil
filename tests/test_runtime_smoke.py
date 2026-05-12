from pathlib import Path


def test_godot_project_launches_headlessly(project_root, godot_runner):
    assert (project_root / "project.godot").exists()

    result = godot_runner(
        "--headless",
        "--script",
        str(project_root / "tools" / "runtime_test_runner.gd"),
        "--",
        "smoke",
    )

    assert result.returncode == 0, result.stderr + result.stdout
    assert "RIFT_ROAD_RUNTIME_OK" in result.stdout


def test_stage_one_title_to_victory_flow(project_root, godot_runner):
    result = godot_runner(
        "--headless",
        "--script",
        str(project_root / "tools" / "runtime_test_runner.gd"),
        "--",
        "stage1_flow",
    )

    assert result.returncode == 0, result.stderr + result.stdout
    assert "RIFT_ROAD_RUNTIME_OK stage1_flow" in result.stdout


def test_stage_one_autoplay_moves_and_attacks(project_root, godot_runner):
    result = godot_runner(
        "--headless",
        "--script",
        str(project_root / "tools" / "runtime_test_runner.gd"),
        "--",
        "stage1_autoplay",
    )

    assert result.returncode == 0, result.stderr + result.stdout
    assert "RIFT_ROAD_RUNTIME_OK stage1_autoplay" in result.stdout


def test_stage_one_road_collapse_event_resumes_service_lane(project_root, godot_runner):
    result = godot_runner(
        "--headless",
        "--script",
        str(project_root / "tools" / "runtime_test_runner.gd"),
        "--",
        "stage1_road_collapse",
    )

    assert result.returncode == 0, result.stderr + result.stdout
    assert "RIFT_ROAD_ROAD_COLLAPSE triggered=true resumed=true" in result.stdout
    assert "RIFT_ROAD_RUNTIME_OK stage1_road_collapse" in result.stdout


def test_stage_one_brask_story_beats_surface_in_runtime(project_root, godot_runner):
    result = godot_runner(
        "--headless",
        "--script",
        str(project_root / "tools" / "runtime_test_runner.gd"),
        "--",
        "stage1_brask_story",
    )

    assert result.returncode == 0, result.stderr + result.stdout
    assert "RIFT_ROAD_BRASK_STORY intro=true phase=true escape=true" in result.stdout
    assert "RIFT_ROAD_RUNTIME_OK stage1_brask_story" in result.stdout


def test_stage_one_opening_story_and_barks_surface_in_runtime(project_root, godot_runner):
    result = godot_runner(
        "--headless",
        "--script",
        str(project_root / "tools" / "runtime_test_runner.gd"),
        "--",
        "stage1_opening_story",
    )

    assert result.returncode == 0, result.stderr + result.stdout
    assert "RIFT_ROAD_OPENING_STORY panels=true barks=true" in result.stdout
    assert "RIFT_ROAD_RUNTIME_OK stage1_opening_story" in result.stdout


def test_stage_one_pickups_apply_clear_health_and_luma_effects(project_root, godot_runner):
    result = godot_runner(
        "--headless",
        "--script",
        str(project_root / "tools" / "runtime_test_runner.gd"),
        "--",
        "stage1_pickup_clarity",
    )

    assert result.returncode == 0, result.stderr + result.stdout
    assert "RIFT_ROAD_PICKUPS glowfruit=true luma_shard=true notice=true" in result.stdout
    assert "RIFT_ROAD_RUNTIME_OK stage1_pickup_clarity" in result.stdout


def test_character_select_preview_starts_selected_hero(project_root, godot_runner):
    result = godot_runner(
        "--headless",
        "--script",
        str(project_root / "tools" / "runtime_test_runner.gd"),
        "--",
        "hero_select_preview",
    )

    assert result.returncode == 0, result.stderr + result.stdout
    assert "RIFT_ROAD_RUNTIME_OK hero_select_preview" in result.stdout


def test_stage_one_restart_and_return_to_title_flow(project_root, godot_runner):
    result = godot_runner(
        "--headless",
        "--script",
        str(project_root / "tools" / "runtime_test_runner.gd"),
        "--",
        "stage1_restart_flow",
    )

    assert result.returncode == 0, result.stderr + result.stdout
    assert "RIFT_ROAD_RUNTIME_OK stage1_restart_flow" in result.stdout


def test_controller_title_to_stage_flow(project_root, godot_runner):
    result = godot_runner(
        "--headless",
        "--script",
        str(project_root / "tools" / "runtime_test_runner.gd"),
        "--",
        "controller_title_flow",
    )

    assert result.returncode == 0, result.stderr + result.stdout
    assert "RIFT_ROAD_RUNTIME_OK controller_title_flow" in result.stdout


def test_controller_hotplug_status_updates_ui_and_runtime_state(project_root, godot_runner):
    result = godot_runner(
        "--headless",
        "--script",
        str(project_root / "tools" / "runtime_test_runner.gd"),
        "--",
        "controller_hotplug_status",
    )

    assert result.returncode == 0, result.stderr + result.stdout
    assert "RIFT_ROAD_CONTROLLER_HOTPLUG connected=true disconnected=true prompt=true events=2" in result.stdout
    assert "RIFT_ROAD_RUNTIME_OK controller_hotplug_status" in result.stdout


def test_keyboard_fallback_title_to_stage_and_action_flow(project_root, godot_runner):
    result = godot_runner(
        "--headless",
        "--script",
        str(project_root / "tools" / "runtime_test_runner.gd"),
        "--",
        "keyboard_fallback_flow",
    )

    assert result.returncode == 0, result.stderr + result.stdout
    assert (
        "RIFT_ROAD_KEYBOARD_FALLBACK "
        "title=true hero_select=true movement=true attack=true jump=true special=true dash=true pause=true cancel=true"
    ) in result.stdout
    assert "RIFT_ROAD_RUNTIME_OK keyboard_fallback_flow" in result.stdout


def test_keyboard_text_confirm_event_starts_stage_one(project_root, godot_runner):
    result = godot_runner(
        "--headless",
        "--script",
        str(project_root / "tools" / "runtime_test_runner.gd"),
        "--",
        "keyboard_text_confirm_flow",
    )

    assert result.returncode == 0, result.stderr + result.stdout
    assert "RIFT_ROAD_KEYBOARD_TEXT_CONFIRM started=true" in result.stdout
    assert "RIFT_ROAD_RUNTIME_OK keyboard_text_confirm_flow" in result.stdout


def test_stage_one_focus_loss_pauses_and_resumes(project_root, godot_runner):
    result = godot_runner(
        "--headless",
        "--script",
        str(project_root / "tools" / "runtime_test_runner.gd"),
        "--",
        "stage1_focus_resume",
    )

    assert result.returncode == 0, result.stderr + result.stdout
    assert "RIFT_ROAD_FOCUS_RESUME focus_pause=true overlay=true audio=true resume=true" in result.stdout
    assert "RIFT_ROAD_RUNTIME_OK stage1_focus_resume" in result.stdout


def test_stage_one_performance_sample_stays_within_budget(project_root, godot_runner):
    result = godot_runner(
        "--headless",
        "--script",
        str(project_root / "tools" / "runtime_test_runner.gd"),
        "--",
        "stage1_performance_sample",
        timeout=30,
    )

    assert result.returncode == 0, result.stderr + result.stdout
    assert "RIFT_ROAD_PERF stage1" in result.stdout
    assert "RIFT_ROAD_RUNTIME_OK stage1_performance_sample" in result.stdout


def test_required_runtime_files_exist(project_root):
    required_paths = [
        "project.godot",
        "scenes/app_root.tscn",
        "scenes/player.tscn",
        "scenes/enemy_actor.tscn",
        "scenes/boss_brask_noll.tscn",
        "scenes/stages/sunset_overpass.tscn",
        "scripts/app_root.gd",
        "scripts/player_controller.gd",
        "scripts/enemy_actor.gd",
        "scripts/boss_brask_noll.gd",
        "scripts/stage_manager.gd",
        "scripts/wave_spawner.gd",
        "scripts/hud_controller.gd",
        "scripts/debug_overlay.gd",
        "scripts/audio_manager.gd",
    ]

    missing = [path for path in required_paths if not (project_root / path).exists()]

    assert missing == []


def test_project_main_scene_is_app_root(project_root):
    project_file = Path(project_root / "project.godot")

    assert 'run/main_scene="res://scenes/app_root.tscn"' in project_file.read_text()
