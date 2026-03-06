from __future__ import annotations

from conftest import PROJECT_DIR, parse_result_line, run_godot


def test_combat_model_suite_passes() -> None:
    result = run_godot(
        "--headless",
        "--path",
        str(PROJECT_DIR),
        "--script",
        "res://tools/runtime_test_runner.gd",
        "--",
        "--suite",
        "combat_model",
    )
    combined_output = result.stdout + result.stderr
    assert result.returncode == 0, combined_output

    payload = parse_result_line(combined_output)
    assert payload["passed"] is True
    assert payload["light_attack_kind"] == "light"
    assert payload["heavy_kind"] == "heavy"
    assert payload["launcher_kind"] == "launcher"
    assert payload["special_kind"] == "special"
    assert payload["special_cooldown"] > 0.0


def test_damage_rules_suite_passes() -> None:
    result = run_godot(
        "--headless",
        "--path",
        str(PROJECT_DIR),
        "--script",
        "res://tools/runtime_test_runner.gd",
        "--",
        "--suite",
        "damage_rules",
    )
    combined_output = result.stdout + result.stderr
    assert result.returncode == 0, combined_output

    payload = parse_result_line(combined_output)
    assert payload["passed"] is True
    assert payload["health_after_first_hit"] < 100
    assert payload["health_after_second_hit"] == payload["health_after_first_hit"]
    assert payload["first_hit_registered"] is True
    assert payload["second_hit_blocked"] is True


def test_checkpoint_reset_suite_passes() -> None:
    result = run_godot(
        "--headless",
        "--path",
        str(PROJECT_DIR),
        "--script",
        "res://tools/runtime_test_runner.gd",
        "--",
        "--suite",
        "checkpoint_reset",
    )
    combined_output = result.stdout + result.stderr
    assert result.returncode == 0, combined_output

    payload = parse_result_line(combined_output)
    assert payload["passed"] is True
    assert payload["player_health"] == 100
    assert payload["dummy_health"] > 0
    assert payload["checkpoint_reset_count"] >= 1
