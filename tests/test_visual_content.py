import json


def load_json(project_root, relative_path):
    with (project_root / relative_path).open() as handle:
        return json.load(handle)


def test_stage_one_has_humans_creatures_and_set_pieces(project_root):
    stage = load_json(project_root, "data/stages.json")["stages"][0]
    wave_enemy_ids = {enemy_id for wave in stage["waves"] for enemy_id in wave["enemies"]}

    assert {"iron_veil_grunt", "iron_veil_runner", "iron_veil_brute"}.issubset(wave_enemy_ids)
    assert {"frightened_raptorling", "hornbeak_dinosaur"}.issubset(wave_enemy_ids)
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

