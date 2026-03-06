from __future__ import annotations

from conftest import PROJECT_DIR, parse_result_line, run_godot


def test_enemy_profiles_suite_passes() -> None:
    result = run_godot(
        "--headless",
        "--path",
        str(PROJECT_DIR),
        "--script",
        "res://tools/runtime_test_runner.gd",
        "--",
        "--suite",
        "enemy_profiles",
    )
    combined_output = result.stdout + result.stderr
    assert result.returncode == 0, combined_output

    payload = parse_result_line(combined_output)
    assert payload["passed"] is True
    assert len(payload["profile_ids"]) >= 6
    assert "arc_seeder" in payload["profile_ids"]
    assert "rail_lancer" in payload["profile_ids"]
    assert payload["elite_count"] >= 1


def test_enemy_stage_suite_passes() -> None:
    result = run_godot(
        "--headless",
        "--path",
        str(PROJECT_DIR),
        "--script",
        "res://tools/runtime_test_runner.gd",
        "--",
        "--suite",
        "enemy_stage",
    )
    combined_output = result.stdout + result.stderr
    assert result.returncode == 0, combined_output

    payload = parse_result_line(combined_output)
    assert payload["passed"] is True
    assert payload["enemy_count"] >= 3
    assert payload["elite_present"] is True
    assert payload["live_enemy_count"] >= 3
