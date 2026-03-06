from __future__ import annotations

from conftest import PROJECT_DIR, parse_result_line, run_godot


def test_first_playable_stage_suite_passes() -> None:
    result = run_godot(
        "--headless",
        "--path",
        str(PROJECT_DIR),
        "--script",
        "res://tools/runtime_test_runner.gd",
        "--",
        "--suite",
        "first_playable",
    )
    combined_output = result.stdout + result.stderr
    assert result.returncode == 0, combined_output

    payload = parse_result_line(combined_output)
    assert payload["passed"] is True
    assert payload["initial_phase"] == "approach"
    assert payload["first_combat_seconds"] >= 0
    assert payload["spectacle_seconds"] >= 0
    assert payload["final_phase"] == "clear"
    assert payload["stage_complete"] is True
    assert payload["rank"] in {"S", "A", "B", "C"}
