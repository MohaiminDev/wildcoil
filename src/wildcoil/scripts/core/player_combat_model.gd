class_name PlayerCombatModel
extends RefCounted

const MAX_HEALTH := 100
const DAMAGE_INVULNERABILITY := 0.45
const HITSTUN_DURATION := 0.28
const SPECIAL_COOLDOWN := 2.4

const LIGHT_CHAIN := [
	{
		"id": "light_1",
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
		"id": "light_2",
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
		"id": "light_3",
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
]

const HEAVY_PROFILE := {
	"id": "heavy_finisher",
	"kind": "heavy",
	"duration": 0.40,
	"hit_time": 0.19,
	"damage": 24,
	"reach": 126.0,
	"knockback_x": 280.0,
	"knockback_y": -90.0,
	"stun": 0.24,
	"hitstop": 0.09,
}

const LAUNCHER_PROFILE := {
	"id": "launcher",
	"kind": "launcher",
	"duration": 0.32,
	"hit_time": 0.15,
	"damage": 18,
	"reach": 102.0,
	"knockback_x": 160.0,
	"knockback_y": -460.0,
	"stun": 0.24,
	"hitstop": 0.08,
}

const SPECIAL_PROFILE := {
	"id": "coil_pulse",
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
}


func make_default_state() -> Dictionary:
	return {
		"health": MAX_HEALTH,
		"attack_kind": "",
		"attack_timer": 0.0,
		"attack_hit_timer": 0.0,
		"attack_applied": false,
		"attack_profile": {},
		"attack_event": {},
		"combo_index": -1,
		"queued_light": false,
		"invulnerable_timer": 0.0,
		"hitstun_timer": 0.0,
		"special_cooldown": 0.0,
		"requested_checkpoint_reset": false,
		"took_damage": false,
	}


func advance(state: Dictionary, input_state: Dictionary, delta: float) -> Dictionary:
	var next_state := state.duplicate(true)
	next_state["attack_event"] = {}
	next_state["requested_checkpoint_reset"] = bool(input_state.get("restart_checkpoint", false))
	next_state["took_damage"] = false
	next_state["invulnerable_timer"] = maxf(float(next_state.get("invulnerable_timer", 0.0)) - delta, 0.0)
	next_state["hitstun_timer"] = maxf(float(next_state.get("hitstun_timer", 0.0)) - delta, 0.0)
	next_state["special_cooldown"] = maxf(float(next_state.get("special_cooldown", 0.0)) - delta, 0.0)

	if float(next_state["hitstun_timer"]) > 0.0:
		return next_state

	if is_attack_active(next_state):
		return advance_attack(next_state, input_state, delta)

	if bool(input_state.get("light_pressed", false)):
		return start_light(next_state, 0)
	if bool(input_state.get("heavy_pressed", false)):
		return start_attack(next_state, HEAVY_PROFILE, "heavy", -1)
	if bool(input_state.get("launcher_pressed", false)):
		return start_attack(next_state, LAUNCHER_PROFILE, "launcher", -1)
	if bool(input_state.get("special_pressed", false)) and float(next_state["special_cooldown"]) <= 0.0:
		next_state["special_cooldown"] = SPECIAL_COOLDOWN
		return start_attack(next_state, SPECIAL_PROFILE, "special", -1)

	return next_state


func apply_damage(state: Dictionary, damage: int, stun_duration: float = HITSTUN_DURATION) -> Dictionary:
	var next_state := state.duplicate(true)
	next_state["took_damage"] = false
	if float(next_state.get("invulnerable_timer", 0.0)) > 0.0:
		return next_state

	next_state["health"] = maxi(int(next_state.get("health", MAX_HEALTH)) - damage, 0)
	next_state["invulnerable_timer"] = DAMAGE_INVULNERABILITY
	next_state["hitstun_timer"] = stun_duration
	next_state["took_damage"] = true
	clear_attack_state(next_state)
	return next_state


func reset_for_checkpoint(state: Dictionary) -> Dictionary:
	var next_state := make_default_state()
	next_state["special_cooldown"] = 0.0
	return next_state


func is_attack_active(state: Dictionary) -> bool:
	return float(state.get("attack_timer", 0.0)) > 0.0


func is_movement_locked(state: Dictionary) -> bool:
	return is_attack_active(state) or float(state.get("hitstun_timer", 0.0)) > 0.0


func get_state_name(state: Dictionary) -> String:
	if float(state.get("hitstun_timer", 0.0)) > 0.0:
		return "hitstun"
	if is_attack_active(state):
		return str(state.get("attack_kind", "attacking"))
	return "ready"


func start_light(state: Dictionary, combo_index: int) -> Dictionary:
	var profile: Dictionary = LIGHT_CHAIN[combo_index]
	return start_attack(state, profile, "light", combo_index)


func start_attack(state: Dictionary, profile: Dictionary, attack_kind: String, combo_index: int) -> Dictionary:
	var next_state := state.duplicate(true)
	var attack_profile: Dictionary = profile.duplicate(true)
	next_state["attack_kind"] = attack_kind
	next_state["attack_profile"] = attack_profile
	next_state["attack_timer"] = float(attack_profile["duration"])
	next_state["attack_hit_timer"] = float(attack_profile["hit_time"])
	next_state["attack_applied"] = false
	next_state["combo_index"] = combo_index
	next_state["queued_light"] = false
	return next_state


func advance_attack(state: Dictionary, input_state: Dictionary, delta: float) -> Dictionary:
	var next_state := state.duplicate(true)
	if str(next_state.get("attack_kind", "")) == "light" and bool(input_state.get("light_pressed", false)) and int(next_state.get("combo_index", -1)) < LIGHT_CHAIN.size() - 1:
		next_state["queued_light"] = true

	next_state["attack_timer"] = maxf(float(next_state.get("attack_timer", 0.0)) - delta, 0.0)
	next_state["attack_hit_timer"] = maxf(float(next_state.get("attack_hit_timer", 0.0)) - delta, 0.0)

	if not bool(next_state.get("attack_applied", false)) and float(next_state.get("attack_hit_timer", 0.0)) <= 0.0:
		next_state["attack_applied"] = true
		var attack_profile: Dictionary = next_state.get("attack_profile", {})
		next_state["attack_event"] = attack_profile.duplicate(true)

	if float(next_state.get("attack_timer", 0.0)) <= 0.0:
		if str(next_state.get("attack_kind", "")) == "light" and bool(next_state.get("queued_light", false)) and int(next_state.get("combo_index", -1)) < LIGHT_CHAIN.size() - 1:
			clear_attack_state(next_state)
			return start_light(next_state, int(next_state.get("combo_index", -1)) + 1)
		clear_attack_state(next_state)

	return next_state


func clear_attack_state(state: Dictionary) -> void:
	state["attack_kind"] = ""
	state["attack_profile"] = {}
	state["attack_timer"] = 0.0
	state["attack_hit_timer"] = 0.0
	state["attack_applied"] = false
	state["combo_index"] = -1
	state["queued_light"] = false
