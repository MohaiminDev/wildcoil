# Wildcoil Task Tracker

## Project Goal
Build an original macOS-first arcade-heritage action game that proves satisfying combat feel, clear readability, distinct identity, practical macOS delivery, and future open-source readiness before expanding into a small solo-first MVP.

## Product Thesis
Wildcoil should deliver a controller-first, stage-based action game with immediate melee satisfaction, strong spectacle in the first three minutes, readable enemy intent, and a strange wilderness-plus-machine-ruin identity that feels original rather than referential.

## Current Milestone
Phase 0 - Discovery and Direction Lock

## Commit Gate
- Complete one task at a time.
- Run that task's full validation checklist before committing.
- Commit and push immediately after the task is green.
- Do not commit or push failing work.

## PENDING

### [P0-02] Approve the Wildcoil concept direction
- Outcome: Mark `Wildcoil` as the approved concept winner across the Phase 0 docs and keep MVP scope solo-first.
- Validation:
  - [ ] [`docs/game_spec.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/game_spec.md) explicitly says the concept is approved, not just recommended.
  - [ ] [`README.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/README.md) and this tracker reflect the approved direction and MVP target.
  - [ ] [`docs/risk_register.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/risk_register.md) is updated for the locked concept direction.
- Dependencies: [DOC-04]

### [P0-03] Verify the engine toolchain on this machine
- Outcome: Confirm local availability or installation status for Godot, Unity, Unreal, Xcode, and the minimum macOS export prerequisites needed for the engine comparison.
- Validation:
  - [ ] Local commands or app locations are recorded for Godot, Unity, Unreal, `xcodebuild`, and package tooling.
  - [ ] Any missing prerequisites or auth blockers are documented in [`docs/engine_matrix.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/engine_matrix.md).
  - [ ] The machine-specific setup state is clear enough to start or explain each spike.
- Dependencies: [P0-02]

### [P0-04] Build the Godot micro-spike
- Outcome: Implement the fixed spike checklist in Godot with movement, dodge, combo, one enemy, controller input, keyboard fallback, and a macOS export artifact.
- Validation:
  - [ ] Godot spike project runs locally.
  - [ ] macOS export result and packaging notes are logged in [`docs/engine_matrix.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/engine_matrix.md).
  - [ ] FPS/frame-time notes and workflow observations are recorded.
- Dependencies: [P0-03]

### [P0-05] Build the Unity micro-spike
- Outcome: Implement the same fixed spike checklist in Unity and capture export, workflow, and controller evidence.
- Validation:
  - [ ] Unity spike project runs locally, or the exact machine/auth blocker is documented with evidence.
  - [ ] macOS export result and packaging notes are logged in [`docs/engine_matrix.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/engine_matrix.md).
  - [ ] FPS/frame-time notes and workflow observations are recorded.
- Dependencies: [P0-03]

### [P0-06] Build the Unreal micro-spike
- Outcome: Implement the same fixed spike checklist in Unreal and capture export, workflow, and controller evidence.
- Validation:
  - [ ] Unreal spike project runs locally, or the exact machine/auth blocker is documented with evidence.
  - [ ] macOS export result and packaging notes are logged in [`docs/engine_matrix.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/engine_matrix.md).
  - [ ] FPS/frame-time notes and workflow observations are recorded.
- Dependencies: [P0-03]

### [P0-07] Lock the initial engine path and freeze the backlog
- Outcome: Score the three engines, choose the winner with the documented tie-break, update risks, and lock the production backlog.
- Validation:
  - [ ] Weighted totals are filled in [`docs/engine_matrix.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/engine_matrix.md).
  - [ ] [`docs/game_spec.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/game_spec.md) names the chosen engine path.
  - [ ] [`docs/risk_register.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/risk_register.md) and this tracker reflect the engine decision and frozen backlog.
- Dependencies: [P0-04], [P0-05], [P0-06]

### [P1-01] Create the production scaffold
- Outcome: Add the chosen engine project, `src/`, `tests/`, provenance logging updates, repeatable build/test commands, and CI or scripted validation hooks.
- Validation:
  - [ ] The repo contains runtime code in `src/` and automated tests in `tests/`.
  - [ ] [`README.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/README.md) documents install, run, and test commands.
  - [ ] The initial automated test suite passes locally.
- Dependencies: [P0-07]

### [P1-02] Implement player locomotion and input
- Outcome: Ship the first playable controller layer with run, jump, dodge, controller hot-plug, keyboard fallback, and remapping-safe actions.
- Validation:
  - [ ] Automated tests cover the deterministic movement and input-state rules that can be unit tested.
  - [ ] Manual smoke checks confirm controller and keyboard input are both playable.
  - [ ] The current test suite passes.
- Dependencies: [P1-01]

### [P1-03] Implement the combat core
- Outcome: Add light attacks, heavy finisher, launcher or sweep, crowd-control special, hitstop, damage, invulnerability windows, and checkpoint reset behavior.
- Validation:
  - [ ] Automated tests cover combat-state rules, damage resolution, and checkpoint reset behavior.
  - [ ] Manual smoke checks confirm hits feel responsive and readable.
  - [ ] The current test suite passes.
- Dependencies: [P1-02]

### [P1-04] Implement enemy systems
- Outcome: Add the shared enemy framework, three starter archetypes, and the elite/miniboss foundation.
- Validation:
  - [ ] Automated tests cover spawn/state/content validation rules that can be deterministic.
  - [ ] Manual smoke checks confirm enemy telegraphs and reactions are readable.
  - [ ] The current test suite passes.
- Dependencies: [P1-03]

### [P1-05] Build Stage 1 first playable
- Outcome: Deliver one short stage with a first fight inside 30 seconds, a spectacle beat inside 3 minutes, a checkpoint, HUD, pause or restart flow, and placeholder audio.
- Validation:
  - [ ] Manual playthrough confirms first combat and spectacle timing targets.
  - [ ] HUD, pause, and restart flows work in windowed and fullscreen modes.
  - [ ] The current test suite passes.
- Dependencies: [P1-04]

### [P1-06] Export and verify the first macOS build
- Outcome: Produce a tester-ready Apple Silicon build and record build evidence, smoke results, and known issues.
- Validation:
  - [ ] A macOS build artifact exists.
  - [ ] Apple Silicon launch and packaging notes are recorded in [`docs/macos_build_and_distribution.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/macos_build_and_distribution.md).
  - [ ] The current test suite passes.
- Dependencies: [P1-05]

### [P1-07] Run the Phase 1 playtest gate
- Outcome: Capture 5 to 8 external playtests, fix repeated clarity or fairness issues, and document the gate result.
- Validation:
  - [ ] [`docs/playtest_log.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest_log.md) contains 5 to 8 sessions or clearly documents the blocker if outside testers are unavailable.
  - [ ] Repeated issues are reflected in [`docs/risk_register.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/risk_register.md) and resolved or accepted.
  - [ ] The current test suite passes.
- Dependencies: [P1-06]

### [P2-01] Promote Stage 1 into a vertical slice
- Outcome: Upgrade Stage 1 with target-leaning art/audio, cleaner camera and VFX discipline, and a full boss fight.
- Validation:
  - [ ] The slice is playable end-to-end with updated visuals and audio.
  - [ ] Manual smoke checks confirm readability did not regress.
  - [ ] The current test suite passes.
- Dependencies: [P1-07]

### [P2-02] Implement progression and validation systems
- Outcome: Add save/load, stage select, rank/time scoring, unlock tracking, and content validation checks.
- Validation:
  - [ ] Automated tests cover save/load, scoring, unlocks, and content validation.
  - [ ] Manual smoke checks confirm saves persist and load safely.
  - [ ] The current test suite passes.
- Dependencies: [P2-01]

### [P2-03] Harden the production pipeline
- Outcome: Update provenance, dependency and license review, packaging notes, and automated build/test flow for ongoing production.
- Validation:
  - [ ] [`docs/asset_provenance_register.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/asset_provenance_register.md) is current for all committed dependencies and placeholder assets.
  - [ ] [`docs/macos_build_and_distribution.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/macos_build_and_distribution.md) reflects the active build workflow.
  - [ ] The current test suite passes.
- Dependencies: [P2-02]

### [P2-04] Run the vertical-slice test pass
- Outcome: Playtest the vertical slice, fix blockers, and lock the MVP expansion target.
- Validation:
  - [ ] [`docs/playtest_log.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest_log.md) records the slice test round.
  - [ ] Blocking findings are fixed or explicitly accepted.
  - [ ] The current test suite passes.
- Dependencies: [P2-03]

### [P3-01] Add the second playable character
- Outcome: Introduce a second character with a meaningfully different mobility and combat profile.
- Validation:
  - [ ] Automated tests cover deterministic roster, unlock, and loadout behavior.
  - [ ] Manual smoke checks confirm the second character changes play feel meaningfully.
  - [ ] The current test suite passes.
- Dependencies: [P2-04]

### [P3-02] Build Stage 2
- Outcome: Add the midgame stage, two new enemy archetypes, and one new hazard language.
- Validation:
  - [ ] Stage 2 is playable end-to-end.
  - [ ] Content validation tests cover the new stage and enemy definitions.
  - [ ] The current test suite passes.
- Dependencies: [P3-01]

### [P3-03] Build Stage 3 and finale
- Outcome: Add the final stage, the last enemy archetype, the final boss, and the ending flow.
- Validation:
  - [ ] Stage 3 and the ending are playable end-to-end.
  - [ ] Content validation tests cover the final stage and boss definitions.
  - [ ] The current test suite passes.
- Dependencies: [P3-02]

### [P3-04] Add onboarding, progression, and accessibility polish
- Outcome: Finalize onboarding prompts, progression flow, options, accessibility settings, save migration safety, and balance tuning.
- Validation:
  - [ ] Automated tests cover save migration and options persistence.
  - [ ] Manual smoke checks confirm onboarding and accessibility flows work.
  - [ ] The current test suite passes.
- Dependencies: [P3-03]

### [P3-05] Run the release-candidate regression pass
- Outcome: Execute the full regression, performance, input, packaging, and release-candidate checks and fix release blockers only.
- Validation:
  - [ ] Regression, packaging, and performance notes are recorded in the docs set.
  - [ ] No known release blocker remains open.
  - [ ] The current test suite passes.
- Dependencies: [P3-04]

### [REL-01] Publish the tester release
- Outcome: Push the final code, create a release tag, attach the macOS build, and publish release notes plus install or known-issues guidance.
- Validation:
  - [ ] The release tag and release notes exist.
  - [ ] The macOS build artifact is attached or the exact publish blocker is documented.
  - [ ] The current test suite passes.
- Dependencies: [P3-05]

## DONE

### [DOC-04] Simplify the public task tracker
- Outcome: Keep `to-do.md` focused on `PENDING` and `DONE` only, with task-by-task outcome, validation, and dependency fields.
- Validation:
  - [x] [`to-do.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/to-do.md) uses `PENDING` and `DONE` as the only task buckets.
  - [x] Every task entry includes outcome, validation, and dependency details.
  - [x] The tracker documents the one-task-at-a-time green-test commit gate.
- Dependencies: None
- Completed: 2026-03-05

### [P0-01] Draft the Schedule A-aligned living spec
- Outcome: [`docs/game_spec.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/game_spec.md) exists with all Schedule A section headings, ranked concepts, and a recommended winner.
- Validation: Section-by-section cross-check against Schedule A on 2026-03-05.
- Dependencies: Contract review and development plan inputs.

### [DOC-01] Create the contract-aligned task tracker
- Outcome: `to-do.md` exists with the contract-required sections.
- Validation: Cross-checked against Sections 19-21 and 30 of the contract on 2026-03-05.
- Dependencies: Contract review.

### [DOC-02] Create the initial planning docs set
- Outcome: The Phase 0 public planning scaffold is in place and internally consistent.
- Validation: File set review and link check on 2026-03-05.
- Dependencies: Contract review and development plan inputs.

### [DOC-03] Update contributor entry points
- Outcome: `README.md` points to the active docs and `AGENTS.md` records durable planning conventions.
- Validation: Manual review of repo entry points on 2026-03-05.
- Dependencies: [DOC-01], [DOC-02]
