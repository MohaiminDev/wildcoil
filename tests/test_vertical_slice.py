from __future__ import annotations

from conftest import PROJECT_DIR, parse_result_line, run_godot


def test_vertical_slice_stage_suite_passes() -> None:
    result = run_godot(
        "--headless",
        "--path",
        str(PROJECT_DIR),
        "--script",
        "res://tools/runtime_test_runner.gd",
        "--",
        "--suite",
        "vertical_slice",
    )
    combined_output = result.stdout + result.stderr
    assert result.returncode == 0, combined_output

    payload = parse_result_line(combined_output)
    assert payload["passed"] is True
    assert payload["boss_seen"] is True
    assert payload["boss_state"] == "down"
    assert payload["stage_complete"] is True
    assert payload["rank"] in {"S", "A", "B", "C"}
