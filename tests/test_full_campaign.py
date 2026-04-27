import json


def load_json(project_root, relative_path):
    with (project_root / relative_path).open() as handle:
        return json.load(handle)


def test_campaign_has_eight_playable_stages(project_root):
    data = load_json(project_root, "data/stages.json")
    stages = data["stages"]

    assert len(stages) == 8
    assert [stage["act"] for stage in stages] == list(range(1, 9))
    assert stages[0]["id"] == "sunset_overpass"
    assert stages[-1]["id"] == "deep_crown_citadel"
    for stage in stages:
        assert len(stage["waves"]) >= 3
        assert stage["boss_id"]
        assert stage["biome"]
        assert len(stage["set_pieces"]) >= 3
        assert stage["opening_cutscene"]
        assert stage["ending_cutscene"]


def test_campaign_has_unique_boss_per_stage(project_root):
    stages = load_json(project_root, "data/stages.json")["stages"]
    bosses = {boss["id"]: boss for boss in load_json(project_root, "data/bosses.json")["bosses"]}
    stage_bosses = [stage["boss_id"] for stage in stages]

    assert len(set(stage_bosses)) == 8
    assert set(stage_bosses).issubset(bosses)
    for boss_id in stage_bosses:
        boss = bosses[boss_id]
        assert len(boss["moves"]) >= 4
        assert boss["arena_hazard"]
        assert boss["palette"]


def test_enemy_roster_supports_full_campaign(project_root):
    enemies = load_json(project_root, "data/enemies.json")["enemies"]
    species = {enemy["species"] for enemy in enemies}
    enemy_ids = {enemy["id"] for enemy in enemies}

    assert len(enemies) >= 12
    assert {"human", "creature", "machine"}.issubset(species)
    assert {
        "shield_guard",
        "scrap_hurler",
        "drone_mite",
        "ashscale_dinosaur",
        "cliff_glider",
        "crystal_leech",
        "echo_raptor"
    }.issubset(enemy_ids)


def test_app_root_implements_campaign_progression(project_root):
    app_root = (project_root / "scripts" / "app_root.gd").read_text()
    stage_manager = (project_root / "scripts" / "stage_manager.gd").read_text()

    assert "stage_order" in app_root
    assert "_start_next_campaign_stage" in app_root
    assert "final_ending" in app_root
    assert "stage_id" in stage_manager
    assert "_animate_stage_art" in stage_manager
    assert "_apply_biome_palette" in stage_manager

