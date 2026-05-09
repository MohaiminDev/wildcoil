# Rift Road Task Tracker

## Project Goal

Make the running game UI and Stage 1 presentation as polished as the generated north-star images while keeping the current Godot game, story bible, and original `Rift Road: Beasts of the Afterglow` identity.

The current build can prove flow, combat scaffolding, and packaging, but it does not visually match the approved generated images yet. The next work must replace rectangle/polygon prototype presentation with actual Stage 1 art assets and premium HUD/menu treatment, then prove the result through real launched-game screenshots and manual playtest.

## Product Thesis

Rift Road should feel like a new 1990s arcade road adventure: fast side-scrolling action, warm prehistoric-future staging, expressive human characters, big readable enemies, punchy but non-bloody impact effects, and strong originality safeguards.

## Current Milestone

Production Vertical Slice - Asset-Backed Stage 1 Visual Slice

## Active Story Source

- [`docs/game-story.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/game-story.md) is the story bible and product direction.
- [`docs/design-docs/stage1-visual-north-star.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/design-docs/stage1-visual-north-star.md) locks the approved concept-image direction for Stage 1.
- [`docs/design-docs/stage1-visual-production-recovery.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/design-docs/stage1-visual-production-recovery.md) defines the recovery path from prototype shapes to asset-backed visuals.
- [`docs/design-docs/assets/stage1-visual-north-star.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/design-docs/assets/stage1-visual-north-star.png) is the UI/combat/presentation quality bar.
- [`docs/design-docs/assets/stage1-background-north-star.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/design-docs/assets/stage1-background-north-star.png) is the Stage 1 environment quality bar.
- [`docs/superpowers/plans/2026-04-27-rift-road-mvp.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/superpowers/plans/2026-04-27-rift-road-mvp.md) records the first playable implementation plan.

## Vertical Slice Target

The playable path is: title screen, hero select, Stage 1 cinematic start, enemy waves, Brask Noll boss, victory screen, restart or return-to-title flow, and packaged macOS zip.

The visual target is the approved north-star direction: modern stylized arcade realism with pixel-art-inspired readability, cinematic sunset highway ruins, jungle depth, luma glow, dramatic sparks and dust, strong silhouettes, clean premium HUD and menus, no modern 3D realism, no generic cyberpunk drift, and no copied characters, UI, layouts, stages, sprites, logos, vehicles, or music from existing games.

## Current Truth

- Mechanically playable prototype: yes.
- Production-grade visual/UI match to north-star images: no.
- Manual playtest evidence: current Codex/Computer Use run opened the Godot app directly into Stage 1 and verified the image-backed background, Raya, denser Iron Veil waves, HUD, cinematic background motion, moving dinosaur/glider silhouettes, combat autoplay, and camera/combat feedback.
- Latest capture note: Computer Use and System Events did not expose the Godot accessibility window, but CoreGraphics did expose the current exported Rift Road app window. Current proof includes both the exported macOS window capture and a scripted normal-renderer Godot viewport capture after fixing the Raya/Nika texture swap.
- Current proof artifacts:
  - Current exported Rift Road app window screenshot: [`docs/playtest-captures/stage1-current-rift-road-export-window.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-current-rift-road-export-window.png)
  - Current exported Rift Road app window motion capture: [`docs/playtest-captures/stage1-current-rift-road-export-window.mov`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-current-rift-road-export-window.mov)
  - Clean exported-app keyflow proof, title input to Stage 1: [`docs/playtest-captures/stage1-manual-keyflow-export-window.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-manual-keyflow-export-window.png), [`docs/playtest-captures/stage1-manual-keyflow-export-window.mov`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-manual-keyflow-export-window.mov)
  - Current Stage 1 motion capture from the Godot runtime viewport: [`docs/playtest-captures/stage1-motion-current-runtime.mp4`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-motion-current-runtime.mp4)
  - Current motion sample frames: [`docs/playtest-captures/stage1-motion-current-sample-01.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-motion-current-sample-01.png), [`docs/playtest-captures/stage1-motion-current-sample-02.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-motion-current-sample-02.png), [`docs/playtest-captures/stage1-motion-current-sample-03.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-motion-current-sample-03.png)
  - Four-hero roster/capability UI screenshot: [`docs/playtest-captures/hero-roster-capabilities-window.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/hero-roster-capabilities-window.png)
  - Static launched-game screenshot: [`docs/playtest-captures/stage1-cinematic-fight-window.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-cinematic-fight-window.png)
  - Short motion capture: [`docs/playtest-captures/stage1-cinematic-fight-window.mov`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-cinematic-fight-window.mov)
  - Earlier visual slice screenshot: [`docs/playtest-captures/stage1-generated-slice.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-generated-slice.png)

## Commit Gate

- Complete one tracker task at a time.
- Run that task's full validation checklist before committing.
- Commit and push immediately after the task is green when a commit/push is requested.
- Do not commit or push failing work.
- Do not mark this visual/UI goal done from tests alone; it requires launched-game screenshots and manual playtest notes.
- Keep task buckets to `PENDING` and `DONE`.

## PENDING

### [RR-PROD-02] Convert placeholder characters toward human arcade sprites
- Outcome: Improve Raya, Nika, enemies, and Brask so they read as human or humanoid arcade characters instead of simple blocks.
- Focus: Heads, torsos, arms, legs, stances, outlines, attack poses, and body proportions visible at gameplay zoom.
- Validation:
  - [ ] Screenshot review shows each actor has a readable body shape at 1280x720.
  - [ ] No copied character sprites, names, costumes, or poses are introduced.
- Dependencies: [RR-PROD-01]

### [RR-PROD-03] Push the visual style toward modern retro-action readability
- Outcome: Add stronger outlines, disciplined color, crisp scaling, cinematic lighting cues, and premium arcade readability.
- Focus: Original modern retro-action presentation without copying any existing game characters, UI, stages, sprites, logos, or layouts.
- Validation:
  - [ ] `python3 -m pytest tests/test_visual_content.py -v` passes.
  - [ ] `python3 -m pytest tests/test_arcade_aesthetics.py -v` passes.
  - [ ] Headless Godot launch succeeds after style changes.
- Dependencies: [RR-PROD-02]

### [RR-PROD-04] Build a jungle-road ruins Stage 1 presentation pass
- Outcome: Make Sunset Overpass look more like a detailed arcade stage with ruined road, jungle growth, broken railings or signage, warm sunset, luma plants, and background depth.
- Validation:
  - [ ] `godot --path src/wildcoil --headless --quit-after 3` launches without script errors.
  - [ ] Captured gameplay screenshot shows visible stage layers and road depth.
- Dependencies: [RR-PROD-03]

### [RR-PROD-05] Improve fight readability and impact
- Outcome: Add clearer punch and kick arcs, hit sparks, knockback, hit pause, input buffering, shadow blobs, enemy flinch poses, and non-bloody impact effects.
- Validation:
  - [ ] Combat screenshot or autoplay capture shows readable impact timing and feedback.
  - [ ] Basic input buffering prevents missed attack presses during recovery.
  - [ ] Hit effects remain original and non-bloody.
- Dependencies: [RR-PROD-04]

### [RR-PROD-06] Make Stage 1 flow reliable
- Outcome: Ensure title screen, hero select, Stage 1 start, waves, boss, victory, restart, and quit work without relying on debug-only instructions.
- Validation:
  - [ ] One full autoplay or manual run reaches victory without script errors.
  - [ ] Restart or return-to-title path works after victory or failure.
- Dependencies: [RR-PROD-05]

### [RR-PROD-07] Polish HUD for arcade readability
- Outcome: Improve player name, health, special meter, score or luma, boss bar, and objective labels.
- Focus: Original arcade cabinet readability at 1280x720 without copying existing arcade HUD layouts.
- Validation:
  - [ ] HUD is readable in a 1280x720 screenshot.
  - [ ] Boss bar and objective text do not overlap combat action.
- Dependencies: [RR-PROD-06]

### [RR-PROD-08] Add audio and cinematic polish pass
- Outcome: Add original placeholder music/SFX hooks, punchy UI sounds, boss cues, stage/boss transition polish, and victory feedback.
- Validation:
  - [ ] Audio manager has clear stage, boss, hit, UI, and victory hooks.
  - [ ] Cinematic banners are readable and short.
  - [ ] Placeholder provenance is documented.
- Dependencies: [RR-PROD-07]

### [RR-PROD-09] Package the macOS vertical slice
- Outcome: Produce `build/macos/Rift Road.zip` for the team-review prototype.
- Validation:
  - [ ] `bash scripts/check.sh` passes.
  - [ ] `bash scripts/package_macos.sh` creates `build/macos/Rift Road.zip`.
- Dependencies: [RR-PROD-08]

### [RR-PROD-10] Capture proof for handoff
- Outcome: Save at least one gameplay screenshot and a short note describing what works, what is still placeholder, and what comes next.
- Validation:
  - [ ] Artifact path is recorded in this tracker.
  - [ ] Summary is suitable for a quick user handoff.
- Dependencies: [RR-PROD-09]

## DONE

### [RR-VIS-02] Add first image-backed actor sprites
- Outcome: Replaced Raya, Nika, Brask, and the Stage 1 wave enemy roster with manifest-backed PNG sprites for runtime use.
- Validation:
  - [x] Gameplay screenshot includes image-backed Raya and image-backed Stage 1 enemies: [`docs/playtest-captures/stage1-generated-slice.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-generated-slice.png)
  - [x] Existing hitboxes, movement, and enemy AI still pass runtime validation through `bash scripts/check.sh`.
  - [x] Generated runtime art sources and cutouts are recorded in `docs/asset_provenance_register.md`.
- Dependencies: [RR-VIS-01]
- Completed: 2026-05-09

### [RR-VIS-01] Build the asset-backed Stage 1 background slice
- Outcome: Replaced the most visible Stage 1 programmatic background shapes with imported image-backed layers for sky/ruins, overpass, road playfield, and atmosphere.
- Validation:
  - [x] `src/wildcoil/assets/stage1/backgrounds/` contains the first layer assets.
  - [x] StageManager loads image-backed layers with fallback to programmatic shapes if missing.
  - [x] A real launched-game screenshot shows Stage 1 no longer reads as only rectangle/polygon prototype art: [`docs/playtest-captures/stage1-generated-slice.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-generated-slice.png)
  - [x] `bash scripts/check.sh` passes.
- Dependencies: [RR-PROD-01]
- Completed: 2026-05-09

### [RR-PROD-01] Lock Stage 1 production north star
- Outcome: Defined the production-grade Stage 1 goal, approved visual direction, required playable path, and non-goals.
- Validation:
  - [x] Tracker clearly states the playable vertical-slice target.
  - [x] Stage 1 visual north-star doc exists and references the approved concept direction.
  - [x] The target is constrained to original Rift Road content.
- Dependencies: Current Godot prototype baseline.
- Completed: 2026-05-09

### [RR-BASELINE-01] Current playable prototype baseline
- Outcome: The active Godot project exists under `src/wildcoil` with Raya and Nika, enemy waves, Brask Noll boss, HUD, menus, Stage 1 flow, packaging scripts, and a current arcade-presentation pass.
- Validation:
  - [x] Runtime code is under `src/wildcoil`.
  - [x] Automated checks are under `tests/`.
  - [x] `bash scripts/check.sh` has previously passed.
  - [x] `bash scripts/package_macos.sh` has previously created `build/macos/Rift Road.zip`.
- Completed: 2026-04-27

### [RR-BASELINE-02] Cleared old completed-task history from active tracker
- Outcome: The long Phase 1 and legacy completed-task history was removed from the active tracker and replaced with this compact baseline so tomorrow's backlog is clear.
- Validation:
  - [x] Tracker keeps only `PENDING` and `DONE` task buckets.
  - [x] Completed implementation history is summarized instead of repeated task-by-task.
- Completed: 2026-04-27
