from __future__ import annotations

from conftest import PROJECT_DIR, parse_result_line, run_godot


def test_runtime_smoke_suite_passes() -> None:
    result = run_godot(
        "--headless",
        "--path",
        str(PROJECT_DIR),
        "--script",
        "res://tools/runtime_test_runner.gd",
        "--",
        "--suite",
        "smoke",
    )
    combined_output = result.stdout + result.stderr
    assert result.returncode == 0, combined_output

    payload = parse_result_line(combined_output)
    assert payload["passed"] is True
    assert payload["build_label"] == "phase3-stage2"
    assert payload["stage_ids"] == ["relay_clearing", "coil_depths"]
    assert payload["character_count"] == 2


def test_default_stage_scene_instantiates() -> None:
    result = run_godot(
        "--headless",
        "--path",
        str(PROJECT_DIR),
        "--script",
        "res://tools/runtime_test_runner.gd",
        "--",
        "--suite",
        "stage_scene",
    )
    combined_output = result.stdout + result.stderr
    assert result.returncode == 0, combined_output

    payload = parse_result_line(combined_output)
    assert payload["passed"] is True
    assert payload["stage_root_name"] == "RelayClearing"
