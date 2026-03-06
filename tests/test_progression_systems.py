from __future__ import annotations

from pathlib import Path

import pytest

from conftest import PROJECT_DIR, parse_result_line, run_godot


def test_progression_suite_persists_stage_records(tmp_path: Path) -> None:
    save_path = tmp_path / "wildcoil_progression_profile.json"

    result = run_godot(
        "--headless",
        "--path",
        str(PROJECT_DIR),
        "--script",
        "res://tools/runtime_test_runner.gd",
        "--",
        "--suite",
        "progression",
        "--save-path",
        str(save_path),
    )
    combined_output = result.stdout + result.stderr
    assert result.returncode == 0, combined_output

    payload = parse_result_line(combined_output)
    assert payload["passed"] is True
    assert payload["selected_stage_id"] == "relay_clearing"
    assert payload["selected_character_id"] == "mira_coil"
    assert payload["cleared_stage_ids"] == ["relay_clearing"]
    assert payload["unlocked_stage_ids"] == ["relay_clearing", "coil_depths"]
    assert payload["unlocked_character_ids"] == ["mira_coil", "zeph_rush"]
    assert payload["best_rank"] == "A"
    assert payload["best_time_seconds"] == pytest.approx(132.4)
    assert payload["option_persisted"] is True
    assert payload["corrupt_recovered"] is True


def test_frontend_shell_suite_transitions_modes(tmp_path: Path) -> None:
    save_path = tmp_path / "wildcoil_frontend_profile.json"

    result = run_godot(
        "--headless",
        "--path",
        str(PROJECT_DIR),
        "--script",
        "res://tools/runtime_test_runner.gd",
        "--",
        "--suite",
        "frontend_shell",
        env={"WILDCOIL_PROFILE_PATH": str(save_path)},
    )
    combined_output = result.stdout + result.stderr
    assert result.returncode == 0, combined_output

    payload = parse_result_line(combined_output)
    assert payload["passed"] is True
    assert payload["initial_mode"] == "menu"
    assert payload["started_stage_active"] is True
    assert payload["results_mode"] == "results"
    assert payload["best_rank"] == "S"
    assert payload["reset_mode"] == "menu"


def test_content_validation_suite_checks_live_and_invalid_catalogs() -> None:
    result = run_godot(
        "--headless",
        "--path",
        str(PROJECT_DIR),
        "--script",
        "res://tools/runtime_test_runner.gd",
        "--",
        "--suite",
        "content_validation",
    )
    combined_output = result.stdout + result.stderr
    assert result.returncode == 0, combined_output

    payload = parse_result_line(combined_output)
    assert payload["passed"] is True
    assert payload["live_catalog_stage_ids"] == ["relay_clearing"]
    assert payload["live_catalog_character_ids"] == ["mira_coil"]
    assert payload["invalid_error_count"] >= 2
