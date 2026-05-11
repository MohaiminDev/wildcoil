# Cinematic Motion Vertical Slice Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move the current playable Stage 1 Godot app toward a production-level cinematic brawler by adding denser actor motion presentation, combat readability, and validation captures without replacing the existing Rift Road runtime.

**Architecture:** Keep `src/wildcoil` as the single playable app. Add presentation-only motion helpers inside the existing actor scripts, reuse the current manifest-backed sprites, and leave collision, AI, waves, story, controls, and packaging flow intact.

**Tech Stack:** Godot 4.x, GDScript, Python `pytest`, existing screenshot/motion capture tools.

---

## Research Notes

- Godot 4.6.2 is the current official maintenance release line checked during this pass; keep repo docs at `Godot 4.x` until the project pins a version.
- Godot's official 2D sprite animation guidance supports state-driven sprite animation with either `AnimatedSprite2D`/`SpriteFrames` or `AnimationPlayer`. The current repo already has state-specific actor textures, so the smallest safe slice is to improve state motion and readability before replacing assets with full sprite sheets.
- Godot's official 2D particle guidance supports transient impact, dust, and glow systems. The current repo already uses lightweight `Node2D`, `Line2D`, and `ColorRect` effects, so this slice should extend those instead of introducing a new VFX dependency.
- Godot's official macOS export workflow supports a single exported app/zip path. Keep `bash scripts/package_macos.sh` as the release path and do not split the prototype into a separate launcher or browser app.

## Task 1: Lock Motion Presentation Expectations

**Files:**
- Modify: `tests/test_brawler_presentation.py`

- [x] **Step 1: Write the failing test**

```python
def test_actors_have_cinematic_motion_language(project_root):
    player_script = (project_root / "scripts" / "player_controller.gd").read_text()
    enemy_script = (project_root / "scripts" / "enemy_actor.gd").read_text()
    boss_script = (project_root / "scripts" / "boss_brask_noll.gd").read_text()

    for script in [player_script, enemy_script, boss_script]:
        assert "_motion_frame" in script
        assert "_draw_cinematic_afterimage" in script
        assert "_draw_contact_shadow" in script

    assert "_draw_hero_motion_details" in player_script
    assert "_draw_enemy_motion_details" in enemy_script
    assert "_draw_boss_motion_details" in boss_script
```

- [x] **Step 2: Run test to verify it fails**

Run: `python3 -m pytest tests/test_brawler_presentation.py::test_actors_have_cinematic_motion_language -v`

Expected: fail because the new motion helper names do not exist yet.

## Task 2: Add Presentation-Only Actor Motion

**Files:**
- Modify: `src/wildcoil/scripts/player_controller.gd`
- Modify: `src/wildcoil/scripts/enemy_actor.gd`
- Modify: `src/wildcoil/scripts/boss_brask_noll.gd`

- [x] **Step 1: Add player motion helpers**

Add `_motion_frame`, `_draw_cinematic_afterimage`, `_draw_contact_shadow`, and `_draw_hero_motion_details` to make existing player sprites feel animated through frame-stepped bob, attack smears, contact shadow scaling, state highlights, and special-meter glow.

- [x] **Step 2: Add enemy motion helpers**

Add the same shared motion vocabulary plus `_draw_enemy_motion_details` so Iron Veil actors and creatures get readable entry, walk, telegraph, hurt, and attack staging without changing hitboxes or AI.

- [x] **Step 3: Add boss motion helpers**

Add `_draw_boss_motion_details` and afterimage/shadow helpers so Brask's telegraphs, charge, stun, phase two, and hurt states read more cinematically in motion.

- [x] **Step 4: Run the focused presentation test**

Run: `python3 -m pytest tests/test_brawler_presentation.py::test_actors_have_cinematic_motion_language -v`

Expected: pass.

## Task 3: Validate And Capture Evidence

**Files:**
- Modify: `to-do.md`
- Generate: `docs/playtest-captures/stage1-cinematic-motion-slice.png`
- Generate: `docs/playtest-captures/stage1-cinematic-motion-slice-frames/`

- [x] **Step 1: Run current automated validation**

Run: `python3 -m pytest tests -v`

Expected: all tests pass.

- [x] **Step 2: Run the repo check script**

Run: `bash scripts/check.sh`

Expected: Python tests, docs check, and headless Godot smoke pass.

- [x] **Step 3: Capture a real runtime screenshot**

Run: `godot --path src/wildcoil --script res://tools/capture_stage_screenshot.gd -- docs/playtest-captures/stage1-cinematic-motion-slice.png`

Expected: screenshot includes Stage 1, hero, enemies, HUD, and the motion-presentation pass.

- [x] **Step 4: Capture a short runtime motion sample**

Run: `godot --path src/wildcoil --script res://tools/capture_stage_motion.gd -- docs/playtest-captures/stage1-cinematic-motion-slice-frames 72`

Expected: frame sequence shows actors moving/attacking with the new presentation layer.

- [x] **Step 5: Update tracker**

Record evidence paths and the remaining visual gaps in `to-do.md`. Do not call the full production-level goal complete.
