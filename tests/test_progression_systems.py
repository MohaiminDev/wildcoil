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
    assert payload["unlocked_character_ids"] == ["mira_coil", "zeph_rush"]
    assert payload["reset_mode"] == "menu"


def test_save_migration_suite_preserves_progression_and_new_defaults(tmp_path: Path) -> None:
    save_path = tmp_path / "wildcoil_save_migration_profile.json"

    result = run_godot(
        "--headless",
        "--path",
        str(PROJECT_DIR),
        "--script",
        "res://tools/runtime_test_runner.gd",
        "--",
        "--suite",
        "save_migration",
        "--save-path",
        str(save_path),
    )
    combined_output = result.stdout + result.stderr
    assert result.returncode == 0, combined_output

    payload = parse_result_line(combined_output)
    assert payload["passed"] is True
    assert payload["version"] == 2
    assert payload["selected_stage_id"] == "coil_depths"
    assert payload["selected_character_id"] == "zeph_rush"
    assert payload["seen_stage_briefing_ids"] == ["relay_clearing"]
    assert payload["high_contrast_hud"] is True
    assert payload["screen_flash_strength"] == pytest.approx(0.4)
    assert payload["auto_pause_on_focus_loss"] is False


def test_options_accessibility_suite_persists_runtime_settings(tmp_path: Path) -> None:
    save_path = tmp_path / "wildcoil_options_accessibility_profile.json"

    result = run_godot(
        "--headless",
        "--path",
        str(PROJECT_DIR),
        "--script",
        "res://tools/runtime_test_runner.gd",
        "--",
        "--suite",
        "options_accessibility",
        "--save-path",
        str(save_path),
    )
    combined_output = result.stdout + result.stderr
    assert result.returncode == 0, combined_output

    payload = parse_result_line(combined_output)
    assert payload["passed"] is True
    assert payload["menu_panel_mode"] == "options"
    assert payload["saved_options"]["high_contrast_hud"] is True
    assert payload["saved_options"]["reduced_motion"] is True
    assert payload["saved_options"]["screen_flash_strength"] == pytest.approx(0.0)
    assert payload["saved_options"]["auto_pause_on_focus_loss"] is False
    assert payload["stage_reduced_motion"] is True
    assert payload["stage_screen_flash_strength"] == pytest.approx(0.0)
    assert payload["runtime_stage_active"] is True
    assert payload["seen_stage_briefing_ids"] == ["relay_clearing"]


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
    assert payload["live_catalog_stage_ids"] == ["relay_clearing", "coil_depths", "storm_crown"]
    assert payload["live_catalog_character_ids"] == ["mira_coil", "zeph_rush"]
    assert payload["invalid_error_count"] >= 2


def test_character_loadout_suite_unlocks_and_selects_second_character(tmp_path: Path) -> None:
    save_path = tmp_path / "wildcoil_character_loadout.json"

    result = run_godot(
        "--headless",
        "--path",
        str(PROJECT_DIR),
        "--script",
        "res://tools/runtime_test_runner.gd",
        "--",
        "--suite",
        "character_loadout",
        "--save-path",
        str(save_path),
    )
    combined_output = result.stdout + result.stderr
    assert result.returncode == 0, combined_output

    payload = parse_result_line(combined_output)
    assert payload["passed"] is True
    assert payload["unlocked_before"] == ["mira_coil"]
    assert payload["unlocked_after_clear"] == ["mira_coil", "zeph_rush"]
    assert payload["selected_character_id"] == "zeph_rush"
    assert payload["zeph_snapshot"]["move_speed"] > payload["mira_snapshot"]["move_speed"]
    assert payload["zeph_snapshot"]["max_health"] < payload["mira_snapshot"]["max_health"]
    assert payload["zeph_snapshot"]["special_cooldown"] < payload["mira_snapshot"]["special_cooldown"]
