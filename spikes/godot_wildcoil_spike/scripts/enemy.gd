extends CharacterBody2D

const FLOOR_Y := 560.0
const STAGE_MIN_X := 50.0
const STAGE_MAX_X := 1230.0
const MOVE_SPEED := 165.0
const GRAVITY := 1380.0
const TELEGRAPH_TIME := 0.55
const LUNGE_TIME := 0.2
const RECOVER_TIME := 0.34

var stage = null
var facing := -1.0
var health := 72
var state_name := "hunt"
var cooldown := 0.4
var telegraph_timer := 0.0
var lunge_timer := 0.0
var recover_timer := 0.0
var stun_timer := 0.0
var respawn_timer := 0.0
var attack_applied := false
var spawn_point := Vector2(920.0, FLOOR_Y)


func _physics_process(delta: float) -> void:
    queue_redraw()

    cooldown = maxf(cooldown - delta, 0.0)

    if not is_on_floor():
        velocity.y += GRAVITY * delta
    elif velocity.y > 0.0:
        velocity.y = 0.0

    match state_name:
        "down":
            process_down(delta)
        "stunned":
            process_stunned(delta)
        "telegraph":
            process_telegraph(delta)
        "lunge":
            process_lunge(delta)
        "recover":
            process_recover(delta)
        _:
            process_hunt(delta)

    move_and_slide()

    global_position.x = clampf(global_position.x, STAGE_MIN_X, STAGE_MAX_X)
    if global_position.y > FLOOR_Y + 180.0:
        global_position.y = FLOOR_Y


func process_hunt(delta: float) -> void:
    if stage == null:
        velocity.x = 0.0
        return

    var player = stage.player
    if player == null:
        velocity.x = 0.0
        return

    var distance: float = player.global_position.x - global_position.x
    if absf(distance) > 12.0:
        facing = sign(distance)

    if absf(distance) > 96.0:
        velocity.x = facing * MOVE_SPEED
        return

    velocity.x = move_toward(velocity.x, 0.0, 1800.0 * delta)
    if cooldown <= 0.0:
        state_name = "telegraph"
        telegraph_timer = TELEGRAPH_TIME


func process_telegraph(delta: float) -> void:
    telegraph_timer = maxf(telegraph_timer - delta, 0.0)
    velocity.x = move_toward(velocity.x, 0.0, 2200.0 * delta)
    if telegraph_timer <= 0.0:
        state_name = "lunge"
        lunge_timer = LUNGE_TIME
        attack_applied = false


func process_lunge(delta: float) -> void:
    velocity.x = facing * 420.0

    if not attack_applied and stage != null:
        attack_applied = stage.resolve_enemy_attack(18, global_position.x, facing, 82.0, 280.0)

    lunge_timer = maxf(lunge_timer - delta, 0.0)
    if lunge_timer <= 0.0:
        state_name = "recover"
        recover_timer = RECOVER_TIME
        cooldown = 0.95


func process_recover(delta: float) -> void:
    recover_timer = maxf(recover_timer - delta, 0.0)
    velocity.x = move_toward(velocity.x, 0.0, 1600.0 * delta)
    if recover_timer <= 0.0:
        state_name = "hunt"


func process_stunned(delta: float) -> void:
    stun_timer = maxf(stun_timer - delta, 0.0)
    velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
    if stun_timer <= 0.0:
        state_name = "hunt"


func process_down(delta: float) -> void:
    respawn_timer = maxf(respawn_timer - delta, 0.0)
    velocity = Vector2.ZERO
    if respawn_timer <= 0.0:
        reset_to_home()


func take_hit(profile: Dictionary, attacker_facing: float) -> void:
    if is_down():
        return

    health = max(health - int(profile["damage"]), 0)
    state_name = "stunned"
    stun_timer = float(profile["stun"])
    velocity.x = float(profile["knockback"]) * attacker_facing
    velocity.y = -170.0
    cooldown = 0.5

    if health <= 0:
        state_name = "down"
        respawn_timer = 2.2
        velocity = Vector2.ZERO
        if stage != null:
            stage.on_enemy_defeated()


func is_down() -> bool:
    return state_name == "down"


func is_attack_dangerous() -> bool:
    return state_name == "telegraph" or state_name == "lunge"


func get_state_name() -> String:
    return state_name


func reset_to_spawn(position_on_floor: Vector2) -> void:
    spawn_point = position_on_floor
    reset_to_home()


func reset_to_home() -> void:
    global_position = spawn_point
    velocity = Vector2.ZERO
    health = 72
    state_name = "hunt"
    cooldown = 0.6
    telegraph_timer = 0.0
    lunge_timer = 0.0
    recover_timer = 0.0
    stun_timer = 0.0
    respawn_timer = 0.0
    attack_applied = false


func _draw() -> void:
    var body_color := Color(0.84, 0.37, 0.30)
    if state_name == "telegraph":
        body_color = Color(0.96, 0.66, 0.30)
    elif state_name == "lunge":
        body_color = Color(0.99, 0.44, 0.22)
    elif state_name == "stunned":
        body_color = Color(0.65, 0.50, 0.96)
    elif state_name == "down":
        body_color = Color(0.22, 0.21, 0.28, 0.8)

    draw_rect(Rect2(Vector2(-20.0, -68.0), Vector2(40.0, 68.0)), body_color)
    draw_rect(Rect2(Vector2(-8.0, -86.0), Vector2(16.0, 16.0)), Color(0.96, 0.93, 0.85))
    draw_line(Vector2(-14.0 * facing, -24.0), Vector2(18.0 * facing, -18.0), Color(0.95, 0.83, 0.62), 4.0)

    if state_name == "telegraph":
        draw_rect(Rect2(Vector2(-50.0, -102.0), Vector2(100.0, 10.0)), Color(1.0, 0.74, 0.26, 0.42))
    elif state_name == "lunge":
        var attack_position := Vector2(12.0, -56.0)
        if facing < 0.0:
            attack_position.x = -68.0
        draw_rect(Rect2(attack_position, Vector2(56.0, 34.0)), Color(1.0, 0.62, 0.26, 0.34))
