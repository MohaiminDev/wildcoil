# Rift Road Task Tracker

## Project Goal

Build an original macOS-first 2D side-scrolling arcade beat-'em-up, `Rift Road: Beasts of the Afterglow`, that proves satisfying combat feel, readable belt-scroll arenas, distinct hero identities, practical Godot/macOS delivery, and strong originality safeguards before expanding beyond Stage 1.

## Product Thesis

Rift Road should feel like a new 1990s-inspired arcade road adventure: fast action, colorful prehistoric-future staging, expressive silhouettes, heroic banter, big readable bosses, and a theme of coexistence over extraction.

## Current Milestone

Rift Road Phase 1 - Stage 1 Playable Prototype

## Active Story Source

- [`docs/game-story.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/game-story.md) is the current story bible and product direction.
- [`docs/superpowers/plans/2026-04-27-rift-road-mvp.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/superpowers/plans/2026-04-27-rift-road-mvp.md) is the implementation plan for the first playable.

## Commit Gate

- Complete one tracker task at a time.
- Run that task's full validation checklist before committing.
- Commit and push immediately after the task is green when a commit/push is requested.
- Do not commit or push failing work.
- Keep task buckets to `PENDING` and `DONE`.

## PENDING

None currently. Next work should be playtest, tuning, or replacing placeholder art/audio after this Stage 1 prototype is reviewed.

## DONE

### [RR-P1-14] Add real brawler fight presentation and win feedback
- Outcome: Added runtime fight cards, scenario objectives, boss intro banners, arena boundary markers, hit sparks, attack arcs, damage numbers, combo HUD feedback, camera punch, stronger enemy behavior differences, boss move telegraphs, and explicit win conditions for every stage.
- Validation:
  - [x] `python3 -m pytest tests/test_brawler_presentation.py -v` passes.
  - [x] `godot --path src/wildcoil --headless --quit-after 3` launches without script errors.
  - [x] `bash scripts/check.sh` passes.
- Dependencies: [RR-P1-13]
- Completed: 2026-04-27

### [RR-P1-13] Upgrade arcade aesthetics and presentation
- Outcome: Added animated biome backdrops, stronger title presentation, hero select cards, Sundrifter title art, character motion smears, sprite outlines, and luma enemy highlights so the prototype reads more like an arcade action game instead of a collision-box prototype.
- Validation:
  - [x] `python3 -m pytest tests/test_arcade_aesthetics.py -v` passes.
  - [x] `godot --path src/wildcoil --headless --quit-after 3` launches without script errors.
  - [x] `bash scripts/check.sh` passes.
  - [x] `bash scripts/package_macos.sh` creates `build/macos/Rift Road.zip`.
- Dependencies: [RR-P1-10]
- Completed: 2026-04-27

### [RR-P1-10] Package and validate the macOS prototype
- Outcome: Added local check/run/package scripts, Godot export preset, build documentation, and a packaged macOS prototype at `build/macos/Rift Road.zip`.
- Validation:
  - [x] `bash scripts/check.sh` passes.
  - [x] `bash scripts/package_macos.sh` creates `build/macos/Rift Road.zip`.
  - [x] macOS build notes document Godot version, commands, artifact path, and export dependency.
- Dependencies: [RR-P1-09]
- Completed: 2026-04-27

### [RR-P1-09] Complete menus, cutscene, debug overlay, and audio placeholders
- Outcome: Added title screen, character select, Stage 1 opening and ending text, debug overlay toggle, FPS/player/enemy/collision summary, and placeholder audio hooks.
- Validation:
  - [x] `python3 -m pytest tests -v` passes.
  - [x] `godot --path src/wildcoil --headless --quit-after 2` launches without script errors.
  - [x] [`docs/asset_provenance_register.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/asset_provenance_register.md) records placeholder asset provenance.
- Dependencies: [RR-P1-08]
- Completed: 2026-04-27

### [RR-P1-08] Implement Brask Noll boss fight
- Outcome: Added Brask Noll with axe swing, charge, wall stun, slam/summon behavior, phase-two aggression, boss health bar, defeat flow, and Stage 1 completion trigger.
- Validation:
  - [x] Boss content tests cover required profile moves, stun condition, and phase-change ratio.
  - [x] Headless Godot launch parses and loads the boss scene.
  - [x] Boss design uses original placeholder visuals and data.
- Dependencies: [RR-P1-07]
- Completed: 2026-04-27

### [RR-P1-07] Add HUD, pickups, pause, and game over
- Outcome: Added health bar, special meter, luma score, glowfruit pickup behavior, pause overlay, restart-to-title flow, and game over screen.
- Validation:
  - [x] Runtime file tests confirm HUD and system scripts exist.
  - [x] Headless Godot launch parses and loads UI scripts.
  - [x] Pickup names and visuals are original placeholders.
- Dependencies: [RR-P1-06]
- Completed: 2026-04-27

### [RR-P1-06] Build Sunset Overpass wave flow
- Outcome: Added Stage 1 arena flow, wave spawning, placeholder parallax-like background layers, lower road space, and transition to Brask Noll.
- Validation:
  - [x] Stage content tests cover Stage 1 title, waves, boss id, and ending cutscene.
  - [x] Headless Godot launch parses and loads the stage scene.
  - [x] Backgrounds use original programmatic placeholder shapes.
- Dependencies: [RR-P1-05]
- Completed: 2026-04-27

### [RR-P1-05] Add grunt, runner, and brute enemies
- Outcome: Implemented Iron Veil grunt, runner, and brute with data profiles, simple approach/telegraph/attack behavior, damage, defeat, and score values.
- Validation:
  - [x] Enemy profile tests confirm grunt, runner, and brute tuning differences.
  - [x] Headless Godot launch parses and loads enemy scripts.
  - [x] Enemy visuals are original placeholders.
- Dependencies: [RR-P1-04]
- Completed: 2026-04-27

### [RR-P1-04] Build the combat hitbox and damage core
- Outcome: Added light attack, jump attack support, special attack, attack rectangles, health, knockback, invulnerability, meter gain/spend, and simple hit feedback.
- Validation:
  - [x] Runtime smoke confirms gameplay scripts parse in Godot.
  - [x] Headless Godot launch starts without script errors.
  - [x] Combat behavior is implemented through local original code.
- Dependencies: [RR-P1-03]
- Completed: 2026-04-27

### [RR-P1-03] Implement belt-scroll movement and keyboard controls
- Outcome: Added WASD/arrow movement, fake jump, dash/dodge, stage bounds, and Y-position sorting on a belt-scroll plane.
- Validation:
  - [x] Runtime smoke confirms player script exists and loads.
  - [x] Headless Godot launch starts without script errors.
  - [x] Controls match the story bible: attack `J`, jump `K`, special `L`, interact `U`, dash `I`, pause `Esc`.
- Dependencies: [RR-P1-02]
- Completed: 2026-04-27

### [RR-P1-02] Add Raya and Nika as data-driven heroes
- Outcome: Added character data and a hero select shell for Raya Flint and Nika Sol with distinct stats, palettes, combat profile, and signature moves.
- Validation:
  - [x] Character roster tests confirm both heroes exist and are mechanically distinct.
  - [x] Hero select supports choosing Raya or Nika.
  - [x] No copied character assets are introduced.
- Dependencies: [RR-P1-01]
- Completed: 2026-04-27

### [RR-P1-01] Scaffold the production Godot project
- Outcome: Created the Godot 4.x project under `src/wildcoil`, added a bootable app root, wired a headless runtime smoke test, and documented run/test commands.
- Validation:
  - [x] `python3 -m pytest tests/test_runtime_smoke.py -v` passes.
  - [x] `godot --path src/wildcoil --headless --quit-after 2` launches without runtime script errors.
  - [x] [`README.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/README.md) documents the current run, test, and package commands.
- Dependencies: [RR-DOC-01]
- Completed: 2026-04-27

### [RR-DOC-01] Lock the Rift Road story direction
- Outcome: Added the Rift Road story bible, updated the project entry point, and rebuilt the tracker around the Stage 1 MVP path.
- Validation:
  - [x] [`docs/game-story.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/game-story.md) captures the concept, heroes, world, antagonists, stages, MVP scope, development order, and originality checklist.
  - [x] [`to-do.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/to-do.md) uses only `PENDING` and `DONE` buckets.
  - [x] The previous Wildcoil planning tasks remain recorded below as completed/superseded history.
- Dependencies: User-provided Rift Road story prompt.
- Completed: 2026-04-27

### [LEGACY-P1-01] Build the combat sandbox first playable
- Outcome: Superseded by the Rift Road Stage 1 MVP path.
- Validation:
  - [x] Replaced by [RR-P1-01] through [RR-P1-10].
- Dependencies: Legacy Phase 0 gate.
- Completed: 2026-04-27 as planning migration.

### [LEGACY-P1-02] Package a tester-ready macOS build
- Outcome: Superseded by the Rift Road macOS packaging task.
- Validation:
  - [x] Replaced by [RR-P1-10].
- Dependencies: Legacy engine choice and first playable.
- Completed: 2026-04-27 as planning migration.

### [LEGACY-P2-01] Define vertical slice promotion criteria
- Outcome: Superseded by the Rift Road MVP success criteria and Stage 1 task sequence.
- Validation:
  - [x] Rift Road promotion criteria are captured in [`docs/game-story.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/game-story.md) and the PENDING tracker.
- Dependencies: Legacy Phase 1 gate.
- Completed: 2026-04-27 as planning migration.

### [LEGACY-P0-02] Run the Godot micro-spike
- Outcome: Superseded by the user's direction to prefer Godot 4.x for the Rift Road playable prototype.
- Validation:
  - [x] Godot is the active implementation path for [RR-P1-01].
- Dependencies: Legacy engine matrix.
- Completed: 2026-04-27 as planning migration.

### [LEGACY-P0-03] Run the Unity micro-spike
- Outcome: Superseded by the user's direction to prefer Godot 4.x for the Rift Road playable prototype.
- Validation:
  - [x] Unity is no longer an active Phase 0 blocker for this story direction.
- Dependencies: Legacy engine matrix.
- Completed: 2026-04-27 as planning migration.

### [LEGACY-P0-04] Run the Unreal micro-spike
- Outcome: Superseded by the user's direction to prefer Godot 4.x for the Rift Road playable prototype.
- Validation:
  - [x] Unreal is no longer an active Phase 0 blocker for this story direction.
- Dependencies: Legacy engine matrix.
- Completed: 2026-04-27 as planning migration.

### [LEGACY-P0-05] Score engines and lock the initial engine path
- Outcome: Superseded by the Rift Road MVP decision to proceed with Godot unless implementation evidence proves otherwise.
- Validation:
  - [x] Active implementation tasks target Godot 4.x.
- Dependencies: Legacy engine spikes.
- Completed: 2026-04-27 as planning migration.

### [LEGACY-P0-06] Lock the milestone backlog for Phase 1
- Outcome: Superseded by the Rift Road tracker and implementation plan.
- Validation:
  - [x] [RR-P1-01] through [RR-P1-10] define the current backlog.
- Dependencies: Legacy concept and engine approval.
- Completed: 2026-04-27 as planning migration.

### [VAL-01] Approve the recommended concept direction
- Outcome: Superseded by explicit user approval of `Rift Road: Beasts of the Afterglow` as the new working story.
- Validation:
  - [x] The new direction is recorded in [`docs/game-story.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/game-story.md).
- Dependencies: User story prompt.
- Completed: 2026-04-27

### [VAL-02] Convert pre-spike engine notes into measured scores
- Outcome: Superseded by the Godot-first Rift Road MVP path.
- Validation:
  - [x] Engine scoring is no longer a prerequisite for Stage 1 prototype work.
- Dependencies: Legacy engine spikes.
- Completed: 2026-04-27 as planning migration.

### [P0-01] Draft the Schedule A-aligned living spec
- Outcome: `docs/game_spec.md` exists with the original Schedule A-aligned working draft.
- Validation:
  - [x] Section-by-section cross-check against Schedule A on 2026-03-05.
- Dependencies: Contract review and development plan inputs.
- Completed: 2026-03-05

### [DOC-01] Create the contract-aligned task tracker
- Outcome: `to-do.md` exists with project tasks, validation, and milestone state.
- Validation:
  - [x] Cross-checked against Sections 19-21 and 30 of the contract on 2026-03-05.
- Dependencies: Contract review.
- Completed: 2026-03-05

### [DOC-02] Create the initial planning docs set
- Outcome: The Phase 0 public planning scaffold is in place.
- Validation:
  - [x] File set review and link check on 2026-03-05.
- Dependencies: Contract review and development plan inputs.
- Completed: 2026-03-05

### [DOC-03] Update contributor entry points
- Outcome: `README.md` points to the active docs and `AGENTS.md` records durable planning conventions.
- Validation:
  - [x] Manual review of repo entry points on 2026-03-05.
- Dependencies: [DOC-01], [DOC-02]
- Completed: 2026-03-05
