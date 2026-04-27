import json


def load_json(project_root, relative_path):
    with (project_root / relative_path).open() as handle:
        return json.load(handle)


def test_mvp_hero_roster_defines_raya_and_nika(project_root):
    data = load_json(project_root, "data/characters.json")
    heroes = {hero["id"]: hero for hero in data["heroes"]}

    assert {"raya_flint", "nika_sol"}.issubset(heroes)
    assert heroes["raya_flint"]["role"] == "balanced mechanic"
    assert heroes["nika_sol"]["role"] == "agile scout"
    assert heroes["raya_flint"]["max_health"] > heroes["nika_sol"]["max_health"]
    assert heroes["nika_sol"]["move_speed"] > heroes["raya_flint"]["move_speed"]

    for hero in heroes.values():
        assert len(hero["palette"]) == 3
        assert {"light_attack", "jump_attack", "dash", "special", "grab"}.issubset(
            set(hero["actions"])
        )


def test_enemy_profiles_define_grunt_runner_and_brute(project_root):
    data = load_json(project_root, "data/enemies.json")
    enemies = {enemy["id"]: enemy for enemy in data["enemies"]}

    assert {"iron_veil_grunt", "iron_veil_runner", "iron_veil_brute"}.issubset(enemies)
    assert enemies["iron_veil_runner"]["move_speed"] > enemies["iron_veil_grunt"]["move_speed"]
    assert enemies["iron_veil_brute"]["max_health"] > enemies["iron_veil_grunt"]["max_health"]
    assert enemies["iron_veil_brute"]["telegraph_seconds"] > enemies["iron_veil_runner"]["telegraph_seconds"]


def test_brask_noll_boss_profile_has_required_moves(project_root):
    data = load_json(project_root, "data/bosses.json")
    bosses = {boss["id"]: boss for boss in data["bosses"]}
    brask = bosses["brask_noll"]

    assert brask["phase_change_health_ratio"] == 0.5
    assert {"axe_swing", "ground_slam", "charge", "summon_grunts", "double_swing"}.issubset(
        set(brask["moves"])
    )
    assert brask["stun_condition"] == "charge_hits_wall"


def test_sunset_overpass_stage_flow(project_root):
    data = load_json(project_root, "data/stages.json")
    stages = {stage["id"]: stage for stage in data["stages"]}
    stage = stages["sunset_overpass"]

    assert stage["title"] == "Sunset Overpass"
    assert stage["boss_id"] == "brask_noll"
    assert len(stage["waves"]) >= 3
    assert stage["ending_cutscene"].endswith("points toward the jungle lab.")

