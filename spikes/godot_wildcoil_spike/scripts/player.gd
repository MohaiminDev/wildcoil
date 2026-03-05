extends CharacterBody2D

const FLOOR_Y := 560.0
const STAGE_MIN_X := 50.0
const STAGE_MAX_X := 1230.0
const MOVE_SPEED := 280.0
const JUMP_VELOCITY := -520.0
const GRAVITY := 1380.0
const DODGE_SPEED := 640.0
const DODGE_TIME := 0.22
const DODGE_COOLDOWN := 0.45

const LIGHT_CHAIN := [
    {"duration": 0.24, "damage": 12, "reach": 86.0, "knockback": 180.0, "stun": 0.15},
    {"duration": 0.26, "damage": 14, "reach": 92.0, "knockback": 210.0, "stun": 0.18},
    {"duration": 0.32, "damage": 18, "reach": 108.0, "knockback": 280.0, "stun": 0.24}
]
const HEAVY_PROFILE := {"duration": 0.38, "damage": 32, "reach": 118.0, "knockback": 360.0, "stun": 0.32}

var stage = null
var autoplay := false
var facing := 1.0
var health := 100

var dodge_timer := 0.0
var dodge_cooldown := 0.0
var attack_timer := 0.0
var attack_hit_timer := 0.0
var attack_profile: Dictionary = {}
var attack_kind := ""
var combo_index := -1
var combo_queue := false
var attack_applied := false
var invulnerable_timer := 0.0
var hitstun_timer := 0.0
var ai_action_cooldown := 0.0


func _physics_process(delta: float) -> void:
    queue_redraw()

    dodge_cooldown = maxf(dodge_cooldown - delta, 0.0)
    invulnerable_timer = maxf(invulnerable_timer - delta, 0.0)
    hitstun_timer = maxf(hitstun_timer - delta, 0.0)
    ai_action_cooldown = maxf(ai_action_cooldown - delta, 0.0)

    if not is_on_floor():
        velocity.y += GRAVITY * delta
    elif velocity.y > 0.0:
        velocity.y = 0.0

    if hitstun_timer > 0.0:
        velocity.x = move_toward(velocity.x, 0.0, 1800.0 * delta)
    elif dodge_timer > 0.0:
        dodge_timer = maxf(dodge_timer - delta, 0.0)
        velocity.x = facing * DODGE_SPEED
    elif attack_timer > 0.0:
        advance_attack(delta)
    else:
        process_ground_actions(delta)

    move_and_slide()

    global_position.x = clampf(global_position.x, STAGE_MIN_X, STAGE_MAX_X)
    if global_position.y > FLOOR_Y + 200.0:
        global_position.y = FLOOR_Y


func process_ground_actions(delta: float) -> void:
    var direction := 0.0

    if autoplay:
        direction = get_autoplay_direction()
        if try_autoplay_actions():
            return
    else:
        direction = Input.get_axis("move_left", "move_right")
        if Input.is_action_just_pressed("dodge") and dodge_cooldown <= 0.0:
            start_dodge()
            return
        if Input.is_action_just_pressed("heavy_attack"):
            start_heavy()
            return
        if Input.is_action_just_pressed("light_attack"):
            start_light_attack(0)
            return

    if absf(direction) > 0.12:
        facing = sign(direction)
        velocity.x = direction * MOVE_SPEED
    else:
        velocity.x = move_toward(velocity.x, 0.0, 2200.0 * delta)

    if not autoplay and Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = JUMP_VELOCITY


func try_autoplay_actions() -> bool:
    if stage == null:
        return false

    var target = stage.get_enemy()
    if target == null or target.is_down():
        return false

    var distance: float = target.global_position.x - global_position.x
    if absf(distance) > 8.0:
        facing = sign(distance)

    if target.is_attack_dangerous() and absf(distance) < 110.0 and dodge_cooldown <= 0.0 and is_on_floor() and ai_action_cooldown <= 0.0:
        start_dodge()
        ai_action_cooldown = 0.18
        return true

    if absf(distance) <= 112.0 and ai_action_cooldown <= 0.0:
        if target.health <= 30 and randi() % 2 == 0:
            start_heavy()
        else:
            start_light_attack(0)
        ai_action_cooldown = 0.16
        return true

    return false


func get_autoplay_direction() -> float:
    if stage == null:
        return 0.0
    var target = stage.get_enemy()
    if target == null or target.is_down():
        return 0.0
    var distance: float = target.global_position.x - global_position.x
    if absf(distance) > 120.0:
        return sign(distance)
    return 0.0


func start_dodge() -> void:
    dodge_timer = DODGE_TIME
    dodge_cooldown = DODGE_COOLDOWN
    invulnerable_timer = DODGE_TIME
    velocity.y = minf(velocity.y, 0.0)


func start_light_attack(step: int) -> void:
    combo_index = step
    attack_kind = "light"
    attack_profile = LIGHT_CHAIN[step].duplicate()
    attack_timer = float(attack_profile["duration"])
    attack_hit_timer = attack_timer * 0.48
    attack_applied = false
    combo_queue = false
    velocity.x *= 0.3


func start_heavy() -> void:
    attack_kind = "heavy"
    combo_index = -1
    attack_profile = HEAVY_PROFILE.duplicate()
    attack_timer = float(attack_profile["duration"])
    attack_hit_timer = attack_timer * 0.55
    attack_applied = false
    combo_queue = false
    velocity.x *= 0.15


func advance_attack(delta: float) -> void:
    attack_timer = maxf(attack_timer - delta, 0.0)
    attack_hit_timer = maxf(attack_hit_timer - delta, 0.0)
    velocity.x = move_toward(velocity.x, 0.0, 2000.0 * delta)

    if not attack_applied and attack_hit_timer <= 0.0 and stage != null:
        attack_applied = true
        stage.resolve_player_attack(attack_profile, global_position.x, facing)

    if attack_timer > 0.0:
        if not autoplay and attack_kind == "light" and Input.is_action_just_pressed("light_attack") and combo_index < LIGHT_CHAIN.size() - 1:
            combo_queue = true
        return

    if combo_queue and combo_index < LIGHT_CHAIN.size() - 1:
        start_light_attack(combo_index + 1)
        return

    attack_kind = ""
    combo_index = -1
    attack_profile.clear()


func take_damage(damage: int, knockback_x: float) -> void:
    if not can_take_damage():
        return

    health = max(health - damage, 0)
    hitstun_timer = 0.28
    invulnerable_timer = 0.35
    attack_timer = 0.0
    combo_queue = false
    attack_kind = ""
    velocity.x = knockback_x
    velocity.y = -210.0

    if health <= 0 and stage != null:
        stage.on_player_defeated()


func can_take_damage() -> bool:
    return invulnerable_timer <= 0.0 and dodge_timer <= 0.0


func reset_to_checkpoint(position_on_floor: Vector2) -> void:
    global_position = position_on_floor
    velocity = Vector2.ZERO
    health = 100
    dodge_timer = 0.0
    dodge_cooldown = 0.0
    attack_timer = 0.0
    attack_hit_timer = 0.0
    attack_kind = ""
    combo_index = -1
    combo_queue = false
    attack_applied = false
    invulnerable_timer = 0.0
    hitstun_timer = 0.0


func _draw() -> void:
    var body_color := Color(0.25, 0.84, 0.73)
    if hitstun_timer > 0.0:
        body_color = Color(1.0, 0.54, 0.45)
    elif dodge_timer > 0.0:
        body_color = Color(0.59, 0.80, 1.0)
    elif attack_timer > 0.0:
        body_color = Color(0.96, 0.70, 0.33)

    draw_rect(Rect2(Vector2(-18.0, -72.0), Vector2(36.0, 72.0)), body_color)
    draw_rect(Rect2(Vector2(-6.0, -92.0), Vector2(12.0, 18.0)), Color(0.95, 0.95, 0.98))
    draw_line(Vector2(-12.0 * facing, -26.0), Vector2(24.0 * facing, -12.0), Color(0.96, 0.77, 0.39), 5.0)

    if attack_timer > 0.0:
        var swing_color := Color(1.0, 0.77, 0.40, 0.45) if attack_kind == "heavy" else Color(0.49, 0.96, 0.88, 0.35)
        var swing_position := Vector2(18.0, -60.0)
        if facing < 0.0:
            swing_position.x = -90.0
        draw_rect(Rect2(swing_position, Vector2(72.0, 46.0)), swing_color)

    if dodge_timer > 0.0:
        draw_rect(Rect2(Vector2(-28.0, -74.0), Vector2(56.0, 78.0)), Color(0.55, 0.82, 1.0, 0.18))
