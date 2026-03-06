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
