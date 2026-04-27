from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PROJECT_DIR = ROOT / "src" / "wildcoil"
CATALOG_PATH = PROJECT_DIR / "data" / "content_catalog.json"


def test_content_catalog_matches_scaffold_contract() -> None:
    data = json.loads(CATALOG_PATH.read_text())

    assert data["build_label"] == "phase3-finale"
    assert len(data["characters"]) == 2
    assert len(data["stages"]) == 4

    first_character = data["characters"][0]
    assert first_character["id"] == "mira_coil"
    assert first_character["playstyle"] == "balanced_striker"
    assert first_character["locked"] is False
    assert "onboarding_tip" in first_character

    second_character = data["characters"][1]
    assert second_character["id"] == "zeph_rush"
    assert second_character["playstyle"] == "agile_disruptor"
    assert second_character["locked"] is True
    assert "onboarding_tip" in second_character

    first_stage = data["stages"][0]
    assert first_stage["id"] == "relay_clearing"
    assert first_stage["order"] == 1
    assert first_stage["spectacle_target_seconds"] == 180
    assert first_stage["boss_objective"] == "Break the relay warden"
    assert first_stage["reward_character_id"] == "zeph_rush"
    assert "briefing" in first_stage

    second_stage = data["stages"][1]
    assert second_stage["id"] == "coil_depths"
    assert second_stage["order"] == 2
    assert second_stage["locked"] is True
    assert second_stage["boss_objective"] == "Break the Rift Colossus"
    assert "briefing" in second_stage

    third_stage = data["stages"][2]
    assert third_stage["id"] == "storm_crown"
    assert third_stage["order"] == 3
    assert third_stage["locked"] is True
    assert third_stage["ending_title"] == "Ending: Crown Quieted"
    assert "briefing" in third_stage

    fourth_stage = data["stages"][3]
    assert fourth_stage["id"] == "road_relic_run"
    assert fourth_stage["order"] == 4
    assert fourth_stage["locked"] is False
    assert fourth_stage["boss_objective"] == "Break the Road Tyrant"
    assert "briefing" in fourth_stage


def test_catalog_scene_paths_exist() -> None:
    data = json.loads(CATALOG_PATH.read_text())

    for stage in data["stages"]:
        relative_scene = stage["scene"].removeprefix("res://")
        scene_path = PROJECT_DIR / relative_scene
        assert scene_path.exists(), f"Missing scene file for stage {stage['id']}: {scene_path}"
