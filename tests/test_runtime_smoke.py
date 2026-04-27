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

