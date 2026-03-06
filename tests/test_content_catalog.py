from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PROJECT_DIR = ROOT / "src" / "wildcoil"
CATALOG_PATH = PROJECT_DIR / "data" / "content_catalog.json"


def test_content_catalog_matches_scaffold_contract() -> None:
    data = json.loads(CATALOG_PATH.read_text())

    assert data["build_label"] == "phase3-second-playable"
    assert len(data["characters"]) == 2
    assert len(data["stages"]) == 1

    first_character = data["characters"][0]
    assert first_character["id"] == "mira_coil"
    assert first_character["playstyle"] == "balanced_striker"
    assert first_character["locked"] is False

    second_character = data["characters"][1]
    assert second_character["id"] == "zeph_rush"
    assert second_character["playstyle"] == "agile_disruptor"
    assert second_character["locked"] is True

    first_stage = data["stages"][0]
    assert first_stage["id"] == "relay_clearing"
    assert first_stage["order"] == 1
    assert first_stage["spectacle_target_seconds"] == 180
    assert first_stage["boss_objective"] == "Break the relay warden"
    assert first_stage["reward_character_id"] == "zeph_rush"


def test_catalog_scene_paths_exist() -> None:
    data = json.loads(CATALOG_PATH.read_text())

    for stage in data["stages"]:
        relative_scene = stage["scene"].removeprefix("res://")
        scene_path = PROJECT_DIR / relative_scene
        assert scene_path.exists(), f"Missing scene file for stage {stage['id']}: {scene_path}"
