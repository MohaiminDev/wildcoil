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
    assert result.returncode == 0, result.stdout + result.stderr

    payload = parse_result_line(result.stdout)
    assert payload["passed"] is True
    assert payload["build_label"] == "phase1-scaffold"
    assert payload["stage_ids"] == ["relay_clearing"]
    assert payload["character_count"] == 1


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
    assert result.returncode == 0, result.stdout + result.stderr

    payload = parse_result_line(result.stdout)
    assert payload["passed"] is True
    assert payload["stage_root_name"] == "RelayClearing"
