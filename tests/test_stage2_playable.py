from __future__ import annotations

from conftest import PROJECT_DIR, parse_result_line, run_godot


def test_stage2_playable_suite_passes() -> None:
    result = run_godot(
        "--headless",
        "--path",
        str(PROJECT_DIR),
        "--script",
        "res://tools/runtime_test_runner.gd",
        "--",
        "--suite",
        "stage2_playable",
    )
    combined_output = result.stdout + result.stderr
    assert result.returncode == 0, combined_output

    payload = parse_result_line(combined_output)
    assert payload["passed"] is True
    assert "rail_lancer" in payload["enemy_ids"]
    assert "arc_seeder" in payload["enemy_ids"]
    assert payload["hazard_cycle_count"] >= 1
    assert payload["hazard_state"] in {"telegraph", "active", "cooldown"}
    assert payload["boss_name"] == "Rift Colossus"
    assert payload["stage_complete"] is True
