# Rift Road MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Stage 1 playable macOS prototype for `Rift Road: Beasts of the Afterglow`.

**Architecture:** Use Godot 4.x under `src/wildcoil`, with small scenes and scripts for player control, combat boxes, enemy AI, wave spawning, stage flow, HUD, pickups, boss behavior, and debug overlay. Keep deterministic gameplay rules covered by `pytest` tests that drive the real Godot project headlessly where possible.

**Tech Stack:** Godot 4.x, GDScript, pytest, macOS export tooling, original placeholder assets only.

---

## File Structure

- Create: `src/wildcoil/project.godot` as the production Godot project.
- Create: `src/wildcoil/scenes/app_root.tscn` for boot, menu routing, stage loading, pause, and game over flow.
- Create: `src/wildcoil/scenes/player.tscn` and `src/wildcoil/scripts/player_controller.gd` for hero movement and combat states.
- Create: `src/wildcoil/scenes/enemy_actor.tscn` and `src/wildcoil/scripts/enemy_actor.gd` for grunt, runner, and brute behavior.
- Create: `src/wildcoil/scenes/boss_brask_noll.tscn` and `src/wildcoil/scripts/boss_brask_noll.gd` for Stage 1 boss behavior.
- Create: `src/wildcoil/scenes/stages/sunset_overpass.tscn` and `src/wildcoil/scripts/stage_manager.gd` for Stage 1 flow.
- Create: `src/wildcoil/scripts/wave_spawner.gd`, `camera_controller.gd`, `hud_controller.gd`, `pickup_manager.gd`, `debug_overlay.gd`, and `audio_manager.gd`.
- Create: `src/wildcoil/data/characters.json`, `enemies.json`, `bosses.json`, and `stages.json` for data-driven tuning.
- Create: `src/wildcoil/tools/runtime_test_runner.gd` for headless Godot runtime checks.
- Create: `tests/conftest.py` and focused `tests/test_*.py` files for runtime smoke, content validation, input, combat, enemy waves, boss flow, and Stage 1 completion.
- Modify: `README.md` with install, run, test, and package commands as soon as the Godot project is introduced.
- Modify: `docs/asset_provenance_register.md` whenever placeholder assets or sounds are added.
- Modify: `docs/macos_build_and_distribution.md` once packaging commands are known.
- Modify: `to-do.md` after each tracker task is completed.

## Task Sequence

### Task 1: Production Godot Scaffold

**Files:**
- Create: `src/wildcoil/project.godot`
- Create: `src/wildcoil/scenes/app_root.tscn`
- Create: `src/wildcoil/scripts/app_root.gd`
- Create: `src/wildcoil/tools/runtime_test_runner.gd`
- Create: `tests/test_runtime_smoke.py`
- Modify: `README.md`

- [ ] **Step 1: Add a failing runtime smoke test**

```python
def test_godot_project_launches_headlessly(godot_runner):
    result = godot_runner("--headless", "--quit-after", "1")
    assert result.returncode == 0
```

- [ ] **Step 2: Run test to verify it fails**

Run: `python -m pytest tests/test_runtime_smoke.py -v`

Expected: FAIL because the production Godot project and test runner are not wired yet.

- [ ] **Step 3: Create the minimal Godot project and app root**

Create `src/wildcoil/project.godot` with a 1280 x 720 window, `app_root.tscn` as the main scene, and a trivial `app_root.gd` that can boot and quit headlessly.

- [ ] **Step 4: Run test to verify it passes**

Run: `python -m pytest tests/test_runtime_smoke.py -v`

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add README.md src/wildcoil tests/test_runtime_smoke.py
git commit -m "feat: scaffold rift road godot project"
```

### Task 2: Character Data and Hero Select Shell

**Files:**
- Create: `src/wildcoil/data/characters.json`
- Create: `src/wildcoil/scripts/core/character_profile_library.gd`
- Create: `tests/test_character_roster.py`

- [ ] **Step 1: Add character roster validation tests**

Verify Raya and Nika exist, have unique stats, unique palettes, and required actions: attack, jump, dash, special, grab, and interact.

- [ ] **Step 2: Run test to verify it fails**

Run: `python -m pytest tests/test_character_roster.py -v`

Expected: FAIL because character data does not exist.

- [ ] **Step 3: Add Raya and Nika data**

Add data-driven profiles for Raya as the balanced mechanic and Nika as the fast scout. Include health, speed, dash, attack timing, special cost, palette tags, and signature move names.

- [ ] **Step 4: Run test to verify it passes**

Run: `python -m pytest tests/test_character_roster.py -v`

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add src/wildcoil/data/characters.json src/wildcoil/scripts/core/character_profile_library.gd tests/test_character_roster.py
git commit -m "feat: add rift road hero roster data"
```

### Task 3: Belt-Scroll Player Movement

**Files:**
- Create: `src/wildcoil/scenes/player.tscn`
- Create: `src/wildcoil/scripts/player_controller.gd`
- Create: `src/wildcoil/scripts/core/player_motor_model.gd`
- Create: `tests/test_player_input.py`

- [ ] **Step 1: Add deterministic movement tests**

Cover lane movement, stage bounds, dash cooldown, fake jump height, and Y-position render sorting input.

- [ ] **Step 2: Run test to verify it fails**

Run: `python -m pytest tests/test_player_input.py -v`

Expected: FAIL because the player motor does not exist.

- [ ] **Step 3: Implement movement**

Implement WASD/arrow input, run movement on the belt-scroll plane, dash on `I`, fake jump on `K`, and bounds clamping.

- [ ] **Step 4: Run test to verify it passes**

Run: `python -m pytest tests/test_player_input.py -v`

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add src/wildcoil/scenes/player.tscn src/wildcoil/scripts/player_controller.gd src/wildcoil/scripts/core/player_motor_model.gd tests/test_player_input.py
git commit -m "feat: add belt scroll player movement"
```

### Task 4: Combat Boxes and Damage Rules

**Files:**
- Create: `src/wildcoil/scripts/combat_box.gd`
- Create: `src/wildcoil/scripts/core/player_combat_model.gd`
- Create: `tests/test_player_combat.py`

- [ ] **Step 1: Add combat timing tests**

Cover startup, active, recovery, hit pause, knockback direction, invulnerability after hit, and special meter spend.

- [ ] **Step 2: Run test to verify it fails**

Run: `python -m pytest tests/test_player_combat.py -v`

Expected: FAIL because combat boxes and timing rules do not exist.

- [ ] **Step 3: Implement player combat**

Add light attack chain, jump attack, special attack, hitboxes, hurtboxes, health, knockback, invulnerability, and meter gain/spend.

- [ ] **Step 4: Run test to verify it passes**

Run: `python -m pytest tests/test_player_combat.py -v`

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add src/wildcoil/scripts/combat_box.gd src/wildcoil/scripts/core/player_combat_model.gd tests/test_player_combat.py
git commit -m "feat: add rift road combat timing"
```

### Task 5: Enemy Framework

**Files:**
- Create: `src/wildcoil/data/enemies.json`
- Create: `src/wildcoil/scenes/enemy_actor.tscn`
- Create: `src/wildcoil/scripts/enemy_actor.gd`
- Create: `src/wildcoil/scripts/core/enemy_profile_library.gd`
- Create: `tests/test_enemy_systems.py`

- [ ] **Step 1: Add enemy profile and AI tests**

Cover grunt, runner, and brute profile validation, approach behavior, attack range, spacing, damage, and telegraph state.

- [ ] **Step 2: Run test to verify it fails**

Run: `python -m pytest tests/test_enemy_systems.py -v`

Expected: FAIL because enemy data and AI do not exist.

- [ ] **Step 3: Implement enemies**

Add grunt, runner, and brute behavior with simple state machines. Limit simultaneous attackers and add spacing logic so enemies do not stack unfairly.

- [ ] **Step 4: Run test to verify it passes**

Run: `python -m pytest tests/test_enemy_systems.py -v`

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add src/wildcoil/data/enemies.json src/wildcoil/scenes/enemy_actor.tscn src/wildcoil/scripts/enemy_actor.gd src/wildcoil/scripts/core/enemy_profile_library.gd tests/test_enemy_systems.py
git commit -m "feat: add rift road enemy framework"
```

### Task 6: Stage 1 Wave Flow

**Files:**
- Create: `src/wildcoil/data/stages.json`
- Create: `src/wildcoil/scenes/stages/sunset_overpass.tscn`
- Create: `src/wildcoil/scripts/stage_manager.gd`
- Create: `src/wildcoil/scripts/wave_spawner.gd`
- Create: `src/wildcoil/scripts/camera_controller.gd`
- Create: `tests/test_stage1_sunset_overpass.py`

- [ ] **Step 1: Add stage flow tests**

Cover arena locks, wave completion, enemy counts, stage progression, and transition to boss trigger.

- [ ] **Step 2: Run test to verify it fails**

Run: `python -m pytest tests/test_stage1_sunset_overpass.py -v`

Expected: FAIL because Stage 1 flow does not exist.

- [ ] **Step 3: Implement Stage 1 wave flow**

Add Sunset Overpass with placeholder background blocks, parallax layers, combat arena locks, wave spawns, and a mid-stage lower service lane event.

- [ ] **Step 4: Run test to verify it passes**

Run: `python -m pytest tests/test_stage1_sunset_overpass.py -v`

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add src/wildcoil/data/stages.json src/wildcoil/scenes/stages/sunset_overpass.tscn src/wildcoil/scripts/stage_manager.gd src/wildcoil/scripts/wave_spawner.gd src/wildcoil/scripts/camera_controller.gd tests/test_stage1_sunset_overpass.py
git commit -m "feat: build sunset overpass wave flow"
```

### Task 7: HUD, Pickups, Pause, and Game Over

**Files:**
- Create: `src/wildcoil/scripts/hud_controller.gd`
- Create: `src/wildcoil/scripts/pickup_manager.gd`
- Create: `tests/test_ui_and_pickups.py`

- [ ] **Step 1: Add UI and pickup tests**

Cover health bar, special meter, luma shards, glowfruit, canteen, protein tin, field bandage, pause, restart, and game over.

- [ ] **Step 2: Run test to verify it fails**

Run: `python -m pytest tests/test_ui_and_pickups.py -v`

Expected: FAIL because HUD and pickup systems do not exist.

- [ ] **Step 3: Implement HUD and pickups**

Add health/special/luma display, pickup recovery rules, pause menu, restart stage, quit flow, and game-over screen.

- [ ] **Step 4: Run test to verify it passes**

Run: `python -m pytest tests/test_ui_and_pickups.py -v`

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add src/wildcoil/scripts/hud_controller.gd src/wildcoil/scripts/pickup_manager.gd tests/test_ui_and_pickups.py
git commit -m "feat: add rift road hud and pickups"
```

### Task 8: Brask Noll Boss Fight

**Files:**
- Create: `src/wildcoil/data/bosses.json`
- Create: `src/wildcoil/scenes/boss_brask_noll.tscn`
- Create: `src/wildcoil/scripts/boss_brask_noll.gd`
- Create: `tests/test_brask_noll_boss.py`

- [ ] **Step 1: Add boss behavior tests**

Cover axe swing, charge, wall stun, slam, summon, 50% phase change, boss defeat, and Stage 1 ending trigger.

- [ ] **Step 2: Run test to verify it fails**

Run: `python -m pytest tests/test_brask_noll_boss.py -v`

Expected: FAIL because Brask does not exist.

- [ ] **Step 3: Implement boss**

Add Brask Noll with readable telegraphs, core move cycle, summon windows, wall-stun weakness, phase change, and defeat animation.

- [ ] **Step 4: Run test to verify it passes**

Run: `python -m pytest tests/test_brask_noll_boss.py -v`

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add src/wildcoil/data/bosses.json src/wildcoil/scenes/boss_brask_noll.tscn src/wildcoil/scripts/boss_brask_noll.gd tests/test_brask_noll_boss.py
git commit -m "feat: add brask noll boss fight"
```

### Task 9: Menus, Cutscene, Debug Overlay, and Audio Placeholders

**Files:**
- Create: `src/wildcoil/scripts/debug_overlay.gd`
- Create: `src/wildcoil/scripts/audio_manager.gd`
- Create: `tests/test_vertical_slice.py`
- Modify: `docs/asset_provenance_register.md`

- [ ] **Step 1: Add vertical slice tests**

Cover title screen, character select, Stage 1 intro, final text cutscene, debug overlay toggle, FPS display, player position display, enemy count display, and collision box display.

- [ ] **Step 2: Run test to verify it fails**

Run: `python -m pytest tests/test_vertical_slice.py -v`

Expected: FAIL because the full slice flow is incomplete.

- [ ] **Step 3: Implement slice flow**

Add title screen, character select, Stage 1 opening lines, ending text cutscene, debug overlay, placeholder original audio hooks, and provenance entries.

- [ ] **Step 4: Run test to verify it passes**

Run: `python -m pytest tests/test_vertical_slice.py -v`

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add src/wildcoil/scripts/debug_overlay.gd src/wildcoil/scripts/audio_manager.gd docs/asset_provenance_register.md tests/test_vertical_slice.py
git commit -m "feat: complete rift road stage one slice"
```

### Task 10: macOS Packaging and Regression

**Files:**
- Create: `scripts/check.sh`
- Create: `scripts/run_game.sh`
- Create: `scripts/package_macos.sh`
- Create: `src/wildcoil/export_presets.cfg`
- Modify: `docs/macos_build_and_distribution.md`
- Modify: `to-do.md`

- [ ] **Step 1: Add packaging validation**

Create a script-level check that runs pytest, launches Godot headlessly, and verifies a macOS export can be produced or records the exact blocker.

- [ ] **Step 2: Run validation to verify it fails or reports missing export setup**

Run: `bash scripts/check.sh`

Expected: FAIL until export presets and package scripts exist.

- [ ] **Step 3: Implement packaging scripts**

Add run, check, and package scripts for local macOS development and tester builds. Document Godot version and export prerequisites.

- [ ] **Step 4: Run validation to verify it passes**

Run: `bash scripts/check.sh`

Expected: PASS, or a documented export-only blocker with all non-export tests passing.

- [ ] **Step 5: Commit**

```bash
git add scripts src/wildcoil/export_presets.cfg docs/macos_build_and_distribution.md to-do.md
git commit -m "chore: add rift road macos packaging flow"
```

## Self-Review

- Spec coverage: MVP scope covers Godot project setup, Raya/Nika, belt-scroll movement, combat, three enemy types, Stage 1, Brask Noll, pickups, HUD, pause, game over, debug overlay, cutscene, and macOS packaging.
- Deferred full-game scope: Kian, Tor, stages 2-8, advanced creature morality rewards, and final boss are intentionally outside the MVP.
- Originality coverage: placeholder assets are required to be original and provenance updates are included before any release path.
- Tracker alignment: implementation must proceed one `to-do.md` task at a time, with validation before commit.
