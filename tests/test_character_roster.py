from __future__ import annotations

from conftest import PROJECT_DIR, parse_result_line, run_godot


def test_character_roster_suite_unlocks_and_persists_loadout() -> None:
    result = run_godot(
        "--headless",
        "--path",
        str(PROJECT_DIR),
        "--script",
        "res://tools/runtime_test_runner.gd",
        "--",
        "--suite",
        "character_roster",
    )
    combined_output = result.stdout + result.stderr
    assert result.returncode == 0, combined_output

    payload = parse_result_line(combined_output)
    assert payload["passed"] is True
    assert payload["initial_unlocked_character_ids"] == ["mira_coil"]
    assert payload["unlocked_character_ids"] == ["mira_coil", "zeph_rush"]
    assert payload["selected_character_id"] == "zeph_rush"
    assert payload["zeph_move_speed"] > payload["mira_move_speed"]
    assert payload["zeph_max_health"] < payload["mira_max_health"]
