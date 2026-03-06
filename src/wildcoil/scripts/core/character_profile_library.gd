class_name CharacterProfileLibrary
extends RefCounted

const PROFILES := {
	"mira_coil": {
		"id": "mira_coil",
		"name": "Mira Coil",
		"playstyle": "balanced_striker",
		"base_color": "2fe4b6",
		"hurt_color": "ff8d73",
		"dodge_color": "8dc8ff",
		"air_color": "ffc65c",
		"attack_color": "ffe18c",
		"accent_color": "f5f7fb",
		"body_size": Vector2(34.0, 78.0),
		"move_speed": 340.0,
		"acceleration": 2600.0,
		"friction": 3000.0,
		"gravity": 1680.0,
		"jump_velocity": -690.0,
		"dodge_speed": 680.0,
		"dodge_time": 0.18,
		"dodge_cooldown": 0.42,
		"max_health": 100,
		"damage_invulnerability": 0.45,
		"hitstun_duration": 0.28,
		"special_cooldown": 2.4,
		"light_chain": [
			{
				"id": "mira_light_1",
				"kind": "light",
				"duration": 0.20,
				"hit_time": 0.09,
				"damage": 8,
				"reach": 86.0,
				"knockback_x": 120.0,
				"knockback_y": -30.0,
				"stun": 0.12,
				"hitstop": 0.04,
			},
			{
				"id": "mira_light_2",
				"kind": "light",
				"duration": 0.22,
				"hit_time": 0.10,
				"damage": 10,
				"reach": 92.0,
				"knockback_x": 150.0,
				"knockback_y": -40.0,
				"stun": 0.14,
				"hitstop": 0.05,
			},
			{
				"id": "mira_light_3",
				"kind": "light",
				"duration": 0.28,
				"hit_time": 0.13,
				"damage": 14,
				"reach": 108.0,
				"knockback_x": 220.0,
				"knockback_y": -70.0,
				"stun": 0.18,
				"hitstop": 0.07,
			},
		],
		"heavy_profile": {
			"id": "mira_heavy_finisher",
			"kind": "heavy",
			"duration": 0.40,
			"hit_time": 0.19,
			"damage": 24,
			"reach": 126.0,
			"knockback_x": 280.0,
			"knockback_y": -90.0,
			"stun": 0.24,
			"hitstop": 0.09,
		},
		"launcher_profile": {
			"id": "mira_launcher",
			"kind": "launcher",
			"duration": 0.32,
			"hit_time": 0.15,
			"damage": 18,
			"reach": 102.0,
			"knockback_x": 160.0,
			"knockback_y": -460.0,
			"stun": 0.24,
			"hitstop": 0.08,
		},
		"special_profile": {
			"id": "mira_coil_pulse",
			"kind": "special",
			"duration": 0.46,
			"hit_time": 0.22,
			"damage": 12,
			"reach": 170.0,
			"knockback_x": 320.0,
			"knockback_y": -140.0,
			"stun": 0.26,
			"hitstop": 0.10,
			"is_radial": true,
		},
	},
	"zeph_rush": {
		"id": "zeph_rush",
		"name": "Zeph Rush",
		"playstyle": "agile_disruptor",
		"base_color": "6fbfff",
		"hurt_color": "ff9f7c",
		"dodge_color": "d6f1ff",
		"air_color": "ffe08c",
		"attack_color": "f2f7ff",
		"accent_color": "eef6ff",
		"body_size": Vector2(28.0, 74.0),
		"move_speed": 420.0,
		"acceleration": 3200.0,
		"friction": 3400.0,
		"gravity": 1620.0,
		"jump_velocity": -760.0,
		"dodge_speed": 820.0,
		"dodge_time": 0.14,
		"dodge_cooldown": 0.28,
		"max_health": 86,
		"damage_invulnerability": 0.38,
		"hitstun_duration": 0.24,
		"special_cooldown": 1.8,
		"light_chain": [
			{
				"id": "zeph_light_1",
				"kind": "light",
				"duration": 0.16,
				"hit_time": 0.07,
				"damage": 7,
				"reach": 80.0,
				"knockback_x": 90.0,
				"knockback_y": -24.0,
				"stun": 0.10,
				"hitstop": 0.03,
			},
			{
				"id": "zeph_light_2",
				"kind": "light",
				"duration": 0.18,
				"hit_time": 0.08,
				"damage": 8,
				"reach": 86.0,
				"knockback_x": 112.0,
				"knockback_y": -34.0,
				"stun": 0.12,
				"hitstop": 0.04,
			},
			{
				"id": "zeph_light_3",
				"kind": "light",
				"duration": 0.24,
				"hit_time": 0.10,
				"damage": 11,
				"reach": 98.0,
				"knockback_x": 170.0,
				"knockback_y": -54.0,
				"stun": 0.15,
				"hitstop": 0.05,
			},
		],
		"heavy_profile": {
			"id": "zeph_cyclone_cut",
			"kind": "heavy",
			"duration": 0.28,
			"hit_time": 0.12,
			"damage": 18,
			"reach": 118.0,
			"knockback_x": 220.0,
			"knockback_y": -70.0,
			"stun": 0.20,
			"hitstop": 0.07,
		},
		"launcher_profile": {
			"id": "zeph_sky_rake",
			"kind": "launcher",
			"duration": 0.24,
			"hit_time": 0.10,
			"damage": 16,
			"reach": 112.0,
			"knockback_x": 150.0,
			"knockback_y": -560.0,
			"stun": 0.22,
			"hitstop": 0.07,
		},
		"special_profile": {
			"id": "zeph_static_bloom",
			"kind": "special",
			"duration": 0.30,
			"hit_time": 0.14,
			"damage": 10,
			"reach": 210.0,
			"knockback_x": 260.0,
			"knockback_y": -110.0,
			"stun": 0.22,
			"hitstop": 0.08,
			"is_radial": true,
		},
	},
}


static func get_profile(character_id: String) -> Dictionary:
	if not PROFILES.has(character_id):
		return {}
	var profile: Dictionary = PROFILES[character_id]
	return profile.duplicate(true)


static func merge_character_definition(character_definition: Dictionary) -> Dictionary:
	var character_id := str(character_definition.get("id", "mira_coil"))
	var merged_profile := get_profile(character_id)
	for key in character_definition.keys():
		merged_profile[key] = character_definition[key]
	merged_profile["motor"] = {
		"move_speed": float(merged_profile.get("move_speed", 340.0)),
		"acceleration": float(merged_profile.get("acceleration", 2600.0)),
		"friction": float(merged_profile.get("friction", 3000.0)),
		"gravity": float(merged_profile.get("gravity", 1680.0)),
		"jump_velocity": float(merged_profile.get("jump_velocity", -690.0)),
		"dodge_speed": float(merged_profile.get("dodge_speed", 680.0)),
		"dodge_time": float(merged_profile.get("dodge_time", 0.18)),
		"dodge_cooldown": float(merged_profile.get("dodge_cooldown", 0.42)),
	}
	merged_profile["combat"] = {
		"max_health": int(merged_profile.get("max_health", 100)),
		"damage_invulnerability": float(merged_profile.get("damage_invulnerability", 0.45)),
		"hitstun_duration": float(merged_profile.get("hitstun_duration", 0.28)),
		"special_cooldown": float(merged_profile.get("special_cooldown", 2.4)),
		"light_chain": (merged_profile.get("light_chain", []) as Array).duplicate(true),
		"heavy_profile": (merged_profile.get("heavy_profile", {}) as Dictionary).duplicate(true),
		"launcher_profile": (merged_profile.get("launcher_profile", {}) as Dictionary).duplicate(true),
		"special_profile": (merged_profile.get("special_profile", {}) as Dictionary).duplicate(true),
	}
	merged_profile["palette"] = {
		"body": str(merged_profile.get("base_color", "2fe4b6")),
		"hurt": str(merged_profile.get("hurt_color", "ff8d73")),
		"dodge": str(merged_profile.get("dodge_color", "8dc8ff")),
		"air": str(merged_profile.get("air_color", "ffc65c")),
		"attack": str(merged_profile.get("attack_color", "ffe18c")),
		"head": str(merged_profile.get("accent_color", "f5f7fb")),
	}
	return merged_profile


static func validate_profiles() -> Array[String]:
	var errors: Array[String] = []
	for character_id in PROFILES.keys():
		var profile := get_profile(str(character_id))
		if str(profile.get("name", "")).is_empty():
			errors.append("%s missing name" % character_id)
		if float(profile.get("move_speed", 0.0)) <= 0.0:
			errors.append("%s missing move_speed" % character_id)
		if int(profile.get("max_health", 0)) <= 0:
			errors.append("%s missing max_health" % character_id)
		if (profile.get("light_chain", []) as Array).is_empty():
			errors.append("%s missing light_chain" % character_id)
	return errors
