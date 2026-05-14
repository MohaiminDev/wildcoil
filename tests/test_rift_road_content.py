import json


def load_json(project_root, relative_path):
    with (project_root / relative_path).open() as handle:
        return json.load(handle)


def test_full_hero_roster_defines_four_distinct_playable_styles(project_root):
    data = load_json(project_root, "data/characters.json")
    heroes = {hero["id"]: hero for hero in data["heroes"]}

    assert {"raya_flint", "kian_vale", "nika_sol", "tor_bram"}.issubset(heroes)
    assert [hero["id"] for hero in data["heroes"]] == [
        "kian_vale",
        "tor_bram",
        "raya_flint",
        "nika_sol",
    ]
    assert heroes["kian_vale"]["role"] == "reinforced wrench brawler"
    assert heroes["tor_bram"]["role"] == "heavy defender"
    assert heroes["raya_flint"]["role"] == "balanced mechanic"
    assert heroes["nika_sol"]["role"] == "agile scout"
    assert heroes["raya_flint"]["max_health"] > heroes["nika_sol"]["max_health"]
    assert heroes["nika_sol"]["move_speed"] > heroes["raya_flint"]["move_speed"]
    assert heroes["tor_bram"]["max_health"] > heroes["raya_flint"]["max_health"]
    assert heroes["kian_vale"]["attack_damage"] > heroes["raya_flint"]["attack_damage"]

    for hero in heroes.values():
        assert len(hero["palette"]) == 3
        assert hero["capability_summary"]
        assert hero["specialty"]
        assert hero["weakness"]
        assert {"power", "speed", "control", "defense"}.issubset(hero["stats"])
        assert {"light_attack", "jump_attack", "dash", "special", "grab"}.issubset(
            set(hero["actions"])
        )


def test_kian_identity_is_reinforced_wrench_brawler_not_martial_artist(project_root):
    data = load_json(project_root, "data/characters.json")
    heroes = {hero["id"]: hero for hero in data["heroes"]}
    kian = heroes["kian_vale"]
    identity_text = " ".join(
        [
            kian["role"],
            kian["specialty"],
            kian["capability_summary"],
            " ".join(kian["signature_moves"]),
        ]
    ).lower()

    assert "wrench" in identity_text
    assert "road" in identity_text or "tool" in identity_text
    assert "heavy" in identity_text
    assert len(kian["signature_moves"]) >= 4
    banned_terms = ["kick", "karate", "kung", "ninja", "martial", "heel", "acrobatic"]
    assert not any(term in identity_text for term in banned_terms)


def test_stage_one_pivots_opening_story_and_barks_to_kian_lead(project_root):
    data = load_json(project_root, "data/stages.json")
    stage = next(stage for stage in data["stages"] if stage["id"] == "sunset_overpass")
    opening_story = stage["opening_story"]
    story_text = " ".join(
        [panel["speaker"] + " " + panel["line"] for panel in opening_story]
        + list(stage["stage_barks"].values())
    )

    assert opening_story[0]["speaker"] == "Kian"
    assert opening_story[2]["speaker"] == "Kian"
    assert "Kian:" in stage["stage_barks"]["wave_start"]
    assert "Raya:" not in stage["stage_barks"]["wave_start"]
    assert "Kian" in story_text
    assert "wrench" in story_text.lower() or "road tool" in story_text.lower()


def test_kian_and_reference_grunt_have_visual_identity_metadata(project_root):
    characters = load_json(project_root, "data/characters.json")
    enemies = load_json(project_root, "data/enemies.json")
    kian = next(hero for hero in characters["heroes"] if hero["id"] == "kian_vale")
    grunt = next(enemy for enemy in enemies["enemies"] if enemy["id"] == "iron_veil_grunt")

    assert kian["visual_identity"]["silhouette"] == "heavy road-tool stance"
    assert "wrench" in kian["visual_identity"]["prop"]
    assert grunt["visual_identity"]["silhouette"] == "salvaged mining-company gear"
    assert "tool" in grunt["visual_identity"]["prop"] or "scrap" in grunt["visual_identity"]["prop"]


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
