class_name EnemyProfileLibrary
extends RefCounted

const PROFILES := {
	"needle_hound": {
		"id": "needle_hound",
		"display_name": "Needle Hound",
		"archetype": "striker",
		"health": 52,
		"walk_speed": 108.0,
		"engage_range": 220.0,
		"attack_range": 88.0,
		"attack_windup": 0.24,
		"damage": 10,
		"knockback_x": 180.0,
		"knockback_y": -160.0,
		"stun": 0.18,
		"hitstop": 0.04,
		"color": "f06b6b",
		"accent": "ffd8b1",
		"is_elite": false,
	},
	"spore_slinger": {
		"id": "spore_slinger",
		"display_name": "Spore Slinger",
		"archetype": "ranged",
		"health": 44,
		"walk_speed": 72.0,
		"engage_range": 360.0,
		"preferred_range": 240.0,
		"attack_range": 380.0,
		"attack_windup": 0.48,
		"damage": 9,
		"knockback_x": 140.0,
		"knockback_y": -120.0,
		"stun": 0.16,
		"hitstop": 0.03,
		"projectile_speed": 260.0,
		"projectile_range": 360.0,
		"color": "a274ff",
		"accent": "efd7ff",
		"is_elite": false,
	},
	"coil_brute": {
		"id": "coil_brute",
		"display_name": "Coil Brute",
		"archetype": "brute",
		"health": 96,
		"walk_speed": 62.0,
		"engage_range": 260.0,
		"attack_range": 118.0,
		"attack_windup": 0.56,
		"damage": 18,
		"knockback_x": 280.0,
		"knockback_y": -220.0,
		"stun": 0.26,
		"hitstop": 0.06,
		"color": "c85f42",
		"accent": "ffd5a1",
		"is_elite": true,
	},
	"rail_lancer": {
		"id": "rail_lancer",
		"display_name": "Rail Lancer",
		"archetype": "skirmisher",
		"health": 56,
		"walk_speed": 156.0,
		"engage_range": 320.0,
		"attack_range": 92.0,
		"attack_windup": 0.18,
		"damage": 11,
		"knockback_x": 210.0,
		"knockback_y": -170.0,
		"stun": 0.17,
		"hitstop": 0.04,
		"color": "4fe6b8",
		"accent": "eafff4",
		"is_elite": false,
	},
	"arc_seeder": {
		"id": "arc_seeder",
		"display_name": "Arc Seeder",
		"archetype": "artillery",
		"health": 58,
		"walk_speed": 68.0,
		"engage_range": 520.0,
		"preferred_range": 340.0,
		"attack_range": 540.0,
		"attack_windup": 0.54,
		"damage": 12,
		"knockback_x": 170.0,
		"knockback_y": -150.0,
		"stun": 0.18,
		"hitstop": 0.04,
		"projectile_speed": 220.0,
		"projectile_range": 560.0,
		"projectile_radius": 26.0,
		"color": "74d7ff",
		"accent": "e8fbff",
		"is_elite": false,
	},
	"ward_mason": {
		"id": "ward_mason",
		"display_name": "Ward Mason",
		"archetype": "sentinel",
		"health": 84,
		"walk_speed": 52.0,
		"engage_range": 320.0,
		"attack_range": 144.0,
		"attack_windup": 0.44,
		"damage": 16,
		"knockback_x": 250.0,
		"knockback_y": -210.0,
		"stun": 0.21,
		"hitstop": 0.05,
		"color": "d9865f",
		"accent": "ffe3c1",
		"is_elite": false,
	},
	"storm_warden": {
		"id": "storm_warden",
		"display_name": "Storm Warden",
		"archetype": "boss",
		"health": 240,
		"walk_speed": 96.0,
		"engage_range": 520.0,
		"attack_range": 150.0,
		"attack_windup": 0.44,
		"damage": 20,
		"knockback_x": 320.0,
		"knockback_y": -240.0,
		"stun": 0.22,
		"hitstop": 0.08,
		"projectile_speed": 320.0,
		"projectile_range": 520.0,
		"dash_speed": 540.0,
		"color": "e0b45e",
		"accent": "fff4ba",
		"is_elite": true,
		"is_boss": true,
	},
	"rift_colossus": {
		"id": "rift_colossus",
		"display_name": "Rift Colossus",
		"archetype": "boss",
		"health": 300,
		"walk_speed": 90.0,
		"engage_range": 560.0,
		"attack_range": 168.0,
		"attack_windup": 0.42,
		"damage": 22,
		"knockback_x": 340.0,
		"knockback_y": -250.0,
		"stun": 0.24,
		"hitstop": 0.08,
		"projectile_speed": 360.0,
		"projectile_range": 560.0,
		"dash_speed": 620.0,
		"color": "7fd6ff",
		"accent": "fff0c9",
		"is_elite": true,
		"is_boss": true,
	},
	"crown_engine": {
		"id": "crown_engine",
		"display_name": "Crown Engine",
		"archetype": "boss",
		"health": 380,
		"walk_speed": 104.0,
		"engage_range": 620.0,
		"attack_range": 176.0,
		"attack_windup": 0.38,
		"damage": 24,
		"knockback_x": 360.0,
		"knockback_y": -260.0,
		"stun": 0.26,
		"hitstop": 0.08,
		"projectile_speed": 390.0,
		"projectile_range": 620.0,
		"dash_speed": 700.0,
		"color": "f4b36e",
		"accent": "fff6cf",
		"is_elite": true,
		"is_boss": true,
	},
}


static func get_profile(enemy_id: String) -> Dictionary:
	if not PROFILES.has(enemy_id):
		return {}
	var profile: Dictionary = PROFILES[enemy_id]
	return profile.duplicate(true)


static func get_profile_ids() -> Array[String]:
	var ids: Array[String] = []
	for enemy_id in PROFILES.keys():
		ids.append(str(enemy_id))
	ids.sort()
	return ids


static func validate_profiles() -> Array[String]:
	var errors: Array[String] = []
	for enemy_id in get_profile_ids():
		var profile := get_profile(enemy_id)
		if str(profile.get("archetype", "")).is_empty():
			errors.append("%s missing archetype" % enemy_id)
		if int(profile.get("health", 0)) <= 0:
			errors.append("%s missing health" % enemy_id)
		if float(profile.get("attack_range", 0.0)) <= 0.0:
			errors.append("%s missing attack range" % enemy_id)
		if float(profile.get("attack_windup", 0.0)) <= 0.0:
			errors.append("%s missing attack windup" % enemy_id)
	return errors
