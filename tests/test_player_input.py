from __future__ import annotations

from conftest import PROJECT_DIR, parse_result_line, run_godot


def test_movement_model_suite_passes() -> None:
    result = run_godot(
        "--headless",
        "--path",
        str(PROJECT_DIR),
        "--script",
        "res://tools/runtime_test_runner.gd",
        "--",
        "--suite",
        "movement_model",
    )
    combined_output = result.stdout + result.stderr
    assert result.returncode == 0, combined_output

    payload = parse_result_line(combined_output)
    assert payload["passed"] is True
    assert payload["move_velocity_x"] > 0.0
    assert payload["jump_velocity_y"] < 0.0
    assert payload["dodge_velocity_x"] < 0.0
    assert payload["dodge_timer"] > 0.0


def test_input_device_suite_passes() -> None:
    result = run_godot(
        "--headless",
        "--path",
        str(PROJECT_DIR),
        "--script",
        "res://tools/runtime_test_runner.gd",
        "--",
        "--suite",
        "input_device",
    )
    combined_output = result.stdout + result.stderr
    assert result.returncode == 0, combined_output

    payload = parse_result_line(combined_output)
    assert payload["passed"] is True
    assert payload["actions_present"] is True
    assert payload["active_scheme"] == "keyboard"
    assert payload["connected_pad_count"] == 0
