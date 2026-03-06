from __future__ import annotations

from conftest import PROJECT_DIR, parse_result_line, run_godot


def test_stage3_finale_suite_passes() -> None:
    result = run_godot(
        "--headless",
        "--path",
        str(PROJECT_DIR),
        "--script",
        "res://tools/runtime_test_runner.gd",
        "--",
        "--suite",
        "stage3_finale",
    )
    combined_output = result.stdout + result.stderr
    assert result.returncode == 0, combined_output

    payload = parse_result_line(combined_output)
    assert payload["passed"] is True
    assert "ward_mason" in payload["enemy_ids"]
    assert payload["hazard_cycle_count"] >= 1
    assert payload["hazard_state"] in {"telegraph", "active", "cooldown"}
    assert payload["boss_name"] == "Crown Engine"
    assert payload["stage_complete"] is True


def test_finale_notice_suite_exposes_the_ending_flow(tmp_path) -> None:
    save_path = tmp_path / "wildcoil_finale_notice.json"

    result = run_godot(
        "--headless",
        "--path",
        str(PROJECT_DIR),
        "--script",
        "res://tools/runtime_test_runner.gd",
        "--",
        "--suite",
        "finale_notice",
        env={"WILDCOIL_PROFILE_PATH": str(save_path)},
    )
    combined_output = result.stdout + result.stderr
    assert result.returncode == 0, combined_output

    payload = parse_result_line(combined_output)
    assert payload["passed"] is True
    assert payload["mode"] == "results"
    assert "Crown Quieted" in payload["notice"]
