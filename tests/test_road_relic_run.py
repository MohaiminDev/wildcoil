from __future__ import annotations

import json
from pathlib import Path

from conftest import PROJECT_DIR, parse_result_line, run_godot


CATALOG_PATH = PROJECT_DIR / "data" / "content_catalog.json"


def test_road_relic_run_is_playable_from_the_catalog() -> None:
    data = json.loads(CATALOG_PATH.read_text())

    road_stage = next(stage for stage in data["stages"] if stage["id"] == "road_relic_run")

    assert road_stage["name"] == "Road Relic Run"
    assert road_stage["locked"] is False
    assert "fossil highway" in road_stage["summary"].lower()
    assert "Cadillac" not in json.dumps(road_stage)


def test_road_relic_run_suite_passes() -> None:
    result = run_godot(
        "--headless",
        "--path",
        str(PROJECT_DIR),
        "--script",
        "res://tools/runtime_test_runner.gd",
        "--",
        "--suite",
        "road_relic_run",
    )
    combined_output = result.stdout + result.stderr
    assert result.returncode == 0, combined_output

    payload = parse_result_line(combined_output)
    assert payload["passed"] is True
    assert payload["enemy_ids"] == ["hornback_brawler", "raptor_runner", "tar_spitter"]
    assert payload["boss_name"] == "Road Tyrant"
    assert payload["stage_complete"] is True
    assert payload["roadster_setpiece_seen"] is True
