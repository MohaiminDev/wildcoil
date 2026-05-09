import json


def load_json(project_root, relative_path):
    with (project_root / relative_path).open() as handle:
        return json.load(handle)


def test_stage_one_has_humans_creatures_and_set_pieces(project_root):
    stage = load_json(project_root, "data/stages.json")["stages"][0]
    wave_enemy_ids = {enemy_id for wave in stage["waves"] for enemy_id in wave["enemies"]}

    assert {"iron_veil_grunt", "iron_veil_runner", "iron_veil_brute"}.issubset(wave_enemy_ids)
    assert {"frightened_raptorling", "hornbeak_dinosaur"}.issubset(wave_enemy_ids)
    assert max(len(wave["enemies"]) for wave in stage["waves"]) >= 6
    assert sum(len(wave["enemies"]) for wave in stage["waves"]) >= 18
    assert {"sundrifter", "transport_cages", "background_dinosaur_herd", "jungle_ruins"}.issubset(
        set(stage["set_pieces"])
    )


def test_enemy_roster_includes_humans_and_animals(project_root):
    data = load_json(project_root, "data/enemies.json")
    enemies = {enemy["id"]: enemy for enemy in data["enemies"]}

    assert enemies["iron_veil_grunt"]["species"] == "human"
    assert enemies["iron_veil_runner"]["species"] == "human"
    assert enemies["iron_veil_brute"]["species"] == "human"
    assert enemies["frightened_raptorling"]["species"] == "creature"
    assert enemies["hornbeak_dinosaur"]["species"] == "creature"
    assert enemies["frightened_raptorling"]["behavior"] == "panicked_nearest_target"
    assert enemies["hornbeak_dinosaur"]["behavior"] == "territorial_charge"


def test_visual_scripts_draw_named_game_art(project_root):
    player_script = (project_root / "scripts" / "player_controller.gd").read_text()
    enemy_script = (project_root / "scripts" / "enemy_actor.gd").read_text()
    boss_script = (project_root / "scripts" / "boss_brask_noll.gd").read_text()
    stage_script = (project_root / "scripts" / "stage_manager.gd").read_text()

    assert "_draw_raya" in player_script
    assert "_draw_nika" in player_script
    assert "_draw_human_enemy" in enemy_script
    assert "_draw_creature_enemy" in enemy_script
    assert "_draw_hydraulic_axe" in boss_script
    assert "_build_sundrifter" in stage_script
    assert "_build_transport_cages" in stage_script
    assert "_build_background_dinosaurs" in stage_script


def test_stage_one_visual_asset_manifest_exists(project_root):
    manifest = load_json(project_root, "data/visual_assets.json")
    stage1 = manifest["stage1"]
    layers = {layer["id"]: layer for layer in stage1["background_layers"]}

    assert {"far_sky_ruins", "mid_overpass", "road_playfield", "foreground_atmosphere"}.issubset(
        layers
    )
    assert stage1["actors"]["raya_flint"]["idle"].endswith("raya_flint_idle.png")
    assert stage1["actors"]["raya_flint"]["walk"].endswith("raya_flint_walk.png")
    assert stage1["actors"]["nika_sol"]["idle"].endswith("nika_sol_idle.png")
    assert stage1["actors"]["nika_sol"]["walk"].endswith("nika_sol_walk.png")
    assert stage1["actors"]["iron_veil_grunt"]["idle"].endswith("iron_veil_grunt_idle.png")
    assert stage1["actors"]["iron_veil_grunt"]["walk"].endswith("iron_veil_grunt_walk.png")
    assert stage1["actors"]["iron_veil_runner"]["idle"].endswith("iron_veil_runner_idle.png")
    assert stage1["actors"]["iron_veil_brute"]["idle"].endswith("iron_veil_brute_idle.png")
    assert stage1["actors"]["scrap_hurler"]["idle"].endswith("scrap_hurler_idle.png")
    assert stage1["actors"]["frightened_raptorling"]["idle"].endswith("frightened_raptorling_idle.png")
    assert stage1["actors"]["hornbeak_dinosaur"]["idle"].endswith("hornbeak_dinosaur_idle.png")
    assert stage1["actors"]["brask_noll"]["idle"].endswith("brask_noll_idle.png")
    assert stage1["actors"]["brask_noll"]["attack"].endswith("brask_noll_attack.png")


def test_stage_one_wave_enemies_are_image_backed(project_root):
    stage = load_json(project_root, "data/stages.json")["stages"][0]
    manifest = load_json(project_root, "data/visual_assets.json")
    actor_assets = manifest["stage1"]["actors"]
    wave_enemy_ids = {enemy_id for wave in stage["waves"] for enemy_id in wave["enemies"]}

    for enemy_id in wave_enemy_ids:
        assert enemy_id in actor_assets, f"Stage 1 enemy lacks image-backed art: {enemy_id}"
        assert {"idle", "walk", "attack", "hurt"}.issubset(actor_assets[enemy_id])


def test_stage_one_runtime_visual_assets_exist(project_root):
    manifest = load_json(project_root, "data/visual_assets.json")
    stage1 = manifest["stage1"]
    asset_paths = [layer["path"] for layer in stage1["background_layers"]]

    for states in stage1["actors"].values():
        asset_paths.extend(states.values())

    for asset_path in asset_paths:
        relative_path = asset_path.removeprefix("res://")
        full_path = project_root / relative_path
        assert full_path.exists(), f"Missing runtime visual asset: {asset_path}"
        assert full_path.stat().st_size > 1024, f"Runtime visual asset is unexpectedly tiny: {asset_path}"
