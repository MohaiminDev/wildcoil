extends Node2D

const FLOOR_Y := 560.0
const STAGE_WIDTH := 1280.0
const STAGE_HEIGHT := 720.0
const PLAYER_START := Vector2(220.0, FLOOR_Y)
const ENEMY_START := Vector2(920.0, FLOOR_Y)

@onready var player = $Player
@onready var enemy = $Enemy
@onready var info_label: Label = $CanvasLayer/InfoLabel
@onready var status_label: Label = $CanvasLayer/StatusLabel
@onready var bench_label: Label = $CanvasLayer/BenchLabel

var autoplay := false
var benchmark_mode := false
var benchmark_reported := false
var elapsed := 0.0
var fps_samples: Array[float] = []
var lowest_fps := 9999.0
var flash_timer := 0.0


func _ready() -> void:
    ensure_default_input_map()

    var user_args := OS.get_cmdline_user_args()
    autoplay = "--autoplay" in user_args
    benchmark_mode = "--benchmark-spike" in user_args

    player.stage = self
    enemy.stage = self
    player.autoplay = autoplay

    reset_stage_state()
    update_labels()
    queue_redraw()


func _physics_process(delta: float) -> void:
    elapsed += delta
    flash_timer = maxf(flash_timer - delta, 0.0)

    if benchmark_mode and elapsed >= 2.0:
        var fps := float(Engine.get_frames_per_second())
        fps_samples.append(fps)
        lowest_fps = minf(lowest_fps, fps)

    update_labels()
    queue_redraw()

    if benchmark_mode and not benchmark_reported and elapsed >= 10.0:
        benchmark_reported = true
        print("WILDCOIL_SPIKE_BENCHMARK avg_fps=%.2f low_fps=%.2f samples=%d" % [get_average_fps(), lowest_fps, fps_samples.size()])
        get_tree().quit()


func _draw() -> void:
    var flash_strength := 0.08 + flash_timer * 0.35
    draw_rect(Rect2(Vector2.ZERO, Vector2(STAGE_WIDTH, STAGE_HEIGHT)), Color(0.05 + flash_strength, 0.11 + flash_strength, 0.16 + flash_strength))
    draw_rect(Rect2(Vector2(0.0, 520.0), Vector2(STAGE_WIDTH, 220.0)), Color(0.10, 0.19, 0.16))

    for rib in range(6):
        var x := 140.0 + rib * 180.0
        draw_line(Vector2(x, 520), Vector2(x + 40.0, 190.0 + float(rib % 2) * 36.0), Color(0.31, 0.24, 0.16, 0.8), 14.0)
        draw_line(Vector2(x + 40.0, 190.0 + float(rib % 2) * 36.0), Vector2(x + 86.0, 112.0), Color(0.46, 0.34, 0.18, 0.7), 8.0)

    for arc in range(5):
        var origin := Vector2(180.0 + arc * 220.0, 210.0 + float(arc % 2) * 20.0)
        draw_arc(origin, 22.0 + arc * 3.0, 0.0, TAU * 0.65, 18, Color(0.23, 0.82, 0.72, 0.28), 4.0)

    if flash_timer > 0.0:
        draw_line(Vector2(800, 64), Vector2(720, 220), Color(0.72, 0.97, 1.0, 0.8), 5.0)
        draw_line(Vector2(720, 220), Vector2(760, 330), Color(0.72, 0.97, 1.0, 0.8), 4.0)
        draw_line(Vector2(760, 330), Vector2(710, 430), Color(0.72, 0.97, 1.0, 0.8), 3.0)


func resolve_player_attack(profile: Dictionary, attacker_x: float, facing: float) -> bool:
    if enemy.is_down():
        return false

    var distance: float = enemy.global_position.x - attacker_x
    if facing > 0.0 and distance < -20.0:
        return false
    if facing < 0.0 and distance > 20.0:
        return false
    if absf(distance) > float(profile["reach"]):
        return false

    enemy.take_hit(profile, facing)
    if int(profile["damage"]) >= 28:
        flash_timer = 0.18
    return true


func resolve_enemy_attack(damage: int, attacker_x: float, facing: float, reach: float, knockback: float) -> bool:
    if not player.can_take_damage():
        return false

    var distance: float = player.global_position.x - attacker_x
    if facing > 0.0 and distance < -16.0:
        return false
    if facing < 0.0 and distance > 16.0:
        return false
    if absf(distance) > reach:
        return false

    player.take_damage(damage, knockback * facing)
    return true


func on_player_defeated() -> void:
    player.reset_to_checkpoint(PLAYER_START)
    enemy.reset_to_home()
    flash_timer = 0.14


func on_enemy_defeated() -> void:
    flash_timer = 0.32


func get_enemy() -> Node:
    return enemy


func reset_stage_state() -> void:
    player.reset_to_checkpoint(PLAYER_START)
    enemy.reset_to_spawn(ENEMY_START)


func get_average_fps() -> float:
    if fps_samples.is_empty():
        return 0.0
    var total := 0.0
    for value in fps_samples:
        total += value
    return total / float(fps_samples.size())


func update_labels() -> void:
    info_label.text = "Wildcoil Godot Spike\nMove: A/D or arrows  Jump: Space/W  Dodge: Shift/C  Light: J/Z  Heavy: K/X\nController: left stick, A jump, B dodge, X light, Y heavy"
    status_label.text = "Player HP: %d    Enemy HP: %d    Enemy State: %s    Mode: %s" % [
        player.health,
        enemy.health,
        enemy.get_state_name(),
        "autoplay" if autoplay else "manual"
    ]

    var bench_text := "Checklist: run, jump, dodge, combo string, heavy finisher, enemy telegraph, controller mapping, macOS export."
    if benchmark_mode:
        bench_text = "Benchmark running: avg %.1f FPS, low %.1f FPS, elapsed %.1fs." % [get_average_fps(), lowest_fps if lowest_fps < 9999.0 else 0.0, elapsed]
    elif autoplay:
        bench_text = "Autoplay enabled for unattended smoke runs."
    bench_label.text = bench_text


func ensure_default_input_map() -> void:
    ensure_action("move_left")
    ensure_action("move_right")
    ensure_action("jump")
    ensure_action("dodge")
    ensure_action("light_attack")
    ensure_action("heavy_attack")

    add_key("move_left", KEY_A)
    add_key("move_left", KEY_LEFT)
    add_key("move_right", KEY_D)
    add_key("move_right", KEY_RIGHT)
    add_key("jump", KEY_SPACE)
    add_key("jump", KEY_W)
    add_key("dodge", KEY_SHIFT)
    add_key("dodge", KEY_C)
    add_key("light_attack", KEY_J)
    add_key("light_attack", KEY_Z)
    add_key("heavy_attack", KEY_K)
    add_key("heavy_attack", KEY_X)

    add_joy_motion("move_left", JOY_AXIS_LEFT_X, -1.0)
    add_joy_motion("move_right", JOY_AXIS_LEFT_X, 1.0)
    add_joy_button("jump", JOY_BUTTON_A)
    add_joy_button("dodge", JOY_BUTTON_B)
    add_joy_button("light_attack", JOY_BUTTON_X)
    add_joy_button("heavy_attack", JOY_BUTTON_Y)


func ensure_action(action_name: StringName) -> void:
    if not InputMap.has_action(action_name):
        InputMap.add_action(action_name)


func add_key(action_name: StringName, keycode: int) -> void:
    for event in InputMap.action_get_events(action_name):
        if event is InputEventKey and event.physical_keycode == keycode:
            return
    var input_event := InputEventKey.new()
    input_event.physical_keycode = keycode
    InputMap.action_add_event(action_name, input_event)


func add_joy_button(action_name: StringName, button_index: JoyButton) -> void:
    for event in InputMap.action_get_events(action_name):
        if event is InputEventJoypadButton and event.button_index == button_index:
            return
    var input_event := InputEventJoypadButton.new()
    input_event.button_index = button_index
    InputMap.action_add_event(action_name, input_event)


func add_joy_motion(action_name: StringName, axis: JoyAxis, axis_value: float) -> void:
    for event in InputMap.action_get_events(action_name):
        if event is InputEventJoypadMotion and event.axis == axis and is_equal_approx(event.axis_value, axis_value):
            return
    var input_event := InputEventJoypadMotion.new()
    input_event.axis = axis
    input_event.axis_value = axis_value
    InputMap.action_add_event(action_name, input_event)
