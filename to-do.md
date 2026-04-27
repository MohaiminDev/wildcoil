# Wildcoil Task Tracker

## Project Goal
Build an original macOS-first arcade-heritage action game that proves satisfying combat feel, clear readability, distinct identity, practical macOS delivery, and future open-source readiness before expanding into a small solo-first MVP.

## Product Thesis
Wildcoil should deliver a controller-first, stage-based action game with immediate melee satisfaction, strong spectacle in the first three minutes, readable enemy intent, and a strange wilderness-plus-machine-ruin identity that feels original rather than referential.

## Current Milestone
Keyboard-First External Beta Production

## Backlog Status
The Phase 1 through tester-release tasks below are complete. The active production-readiness backlog is the keyboard-first external beta path, targeting an unsigned macOS beta build with cohesive self-authored presentation, keyboard-first playability, and external tester evidence before wider claims.

## Commit Gate
- Complete one task at a time.
- Run that task's full validation checklist before committing.
- Commit and push immediately after the task is green.
- Do not commit or push failing work.

## PENDING

### [PROD-02] Prepare cohesive beta polish
- Outcome: Remove debug-looking or prototype-only presentation from the normal player flow while keeping self-authored placeholder visuals and audio only where they read as intentional beta style.
- Validation:
  - [ ] Mission board, HUD, pause/options, first-run briefing, and ending copy read as beta-facing rather than debug-facing.
  - [ ] The current test suite passes.
  - [ ] Manual smoke confirms no UI copy or layout change blocks the keyboard flow.
- Dependencies: [PROD-01]

### [PROD-03] Harden unsigned macOS packaging
- Outcome: Update the beta build label, package naming, checksum flow, isolated-save launch guidance, and unsigned macOS install notes for the keyboard-first beta.
- Validation:
  - [ ] Build label is `keyboard-beta-v1`.
  - [ ] `scripts/package_macos.sh` produces `Wildcoil-keyboard-beta-v1-macos.zip` and a matching `.sha256` sidecar.
  - [ ] README and release notes document unsigned launch guidance and known limitations.
  - [ ] The current test suite passes.
- Dependencies: [PROD-02]

### [PROD-04] Record Computer Use release smoke evidence
- Outcome: Launch the packaged app with an isolated save profile, inspect the macOS app window with Computer Use, confirm the mission board renders, verify visible keyboard-first state changes, and record the evidence.
- Validation:
  - [ ] Packaged app launches from the exported bundle with an isolated save profile.
  - [ ] Computer Use inspection confirms the beta mission board renders.
  - [ ] Smoke notes are recorded in the playtest and macOS build docs.
  - [ ] The current test suite passes.
- Dependencies: [PROD-03]

### [PROD-05] Run external keyboard tester round
- Outcome: Send the unsigned keyboard beta to at least 5 keyboard-first testers, collect feedback, and log install friction, first-combat clarity, cheap damage, performance/audio/windowing issues, replay desire, and originality comparisons.
- Validation:
  - [ ] At least 5 keyboard-first tester sessions are recorded, or the exact tester-availability blocker is documented.
  - [ ] Repeated findings are reflected in the playtest log and risk register.
  - [ ] Any release-blocking repeated issue is converted into a follow-up task before new scope is added.
- Dependencies: [PROD-04]

### [PROD-06] Apply evidence-driven beta patches
- Outcome: Fix repeated keyboard-beta blockers before adding scope, prioritizing launch/install friction, keyboard confusion, unreadable combat, cheap damage, save/progression bugs, and performance regressions.
- Validation:
  - [ ] Each patch references the tester evidence or documented risk that justified it.
  - [ ] Controller hardware issues remain documented but non-blocking for keyboard beta v1.
  - [ ] The current test suite passes after every patch.
- Dependencies: [PROD-05]

### [PROD-07] Publish final keyboard beta release candidate
- Outcome: Run the final regression, package the unsigned beta, publish `v0.2.0-keyboard-beta`, verify the hosted release asset, and record release-candidate evidence.
- Validation:
  - [ ] `./scripts/check.sh` passes.
  - [ ] `./scripts/package_macos.sh` produces the final ZIP and checksum.
  - [ ] The performance sample suite passes.
  - [ ] Packaged-app keyboard smoke passes with an isolated save profile.
  - [ ] Hosted ZIP download, checksum verification, unzip, and first-launch smoke pass.
- Dependencies: [PROD-06]

## DONE

### [PROD-01] Harden keyboard-first beta playability
- Outcome: Made the full player flow readable and dependable with keyboard alone, including mission board navigation, character selection, deploy, combat, pause or resume, restart, fullscreen, options, and ending flow.
- Validation:
  - [x] Player-facing prompts and release-facing docs prioritize keyboard controls.
  - [x] Automated input and runtime suites pass.
  - [x] Manual macOS smoke confirmed the keyboard-first mission board prompt set in the live Godot runtime.
- Dependencies: [PROD-00]
- Completed: 2026-04-27

### [PROD-00] Clear current tracker and baseline
- Outcome: Confirm the tracker has no old pending tasks, run the baseline validation gate, and add the keyboard-first external beta production backlog.
- Validation:
  - [x] `to-do.md` had no existing pending tasks before the production backlog was added.
  - [x] `./scripts/check.sh` passed with 23 tests on 2026-04-27.
  - [x] The keyboard-first beta backlog is recorded using only `PENDING` and `DONE` task buckets.
- Dependencies: None
- Completed: 2026-04-27

### [REL-01] Publish the tester release
- Outcome: Push the final code, create a release tag, attach the macOS build, and publish release notes plus install or known-issues guidance.
- Validation:
  - [x] The release tag and release notes exist.
  - [x] The macOS build artifact is attached or the exact publish blocker is documented.
  - [x] The current test suite passes.
- Dependencies: [P3-05]
- Completed: 2026-03-05

### [P3-05] Run the release-candidate regression pass
- Outcome: Execute the full regression, performance, input, packaging, and release-candidate checks and fix release blockers only.
- Validation:
  - [x] Regression, packaging, and performance notes are recorded in the docs set.
  - [x] No known release blocker remains open.
  - [x] The current test suite passes.
- Dependencies: [P3-04]
- Completed: 2026-03-05

### [P3-04] Add onboarding, progression, and accessibility polish
- Outcome: Finalize onboarding prompts, progression flow, options, accessibility settings, save migration safety, and balance tuning.
- Validation:
  - [x] Automated tests cover save migration and options persistence.
  - [x] Manual smoke checks confirm onboarding and accessibility flows work.
  - [x] The current test suite passes.
- Dependencies: [P3-03]
- Completed: 2026-03-05

### [P3-03] Build Stage 3 and finale
- Outcome: Add the final stage, the last enemy archetype, the final boss, and the ending flow.
- Validation:
  - [x] Stage 3 and the ending are playable end-to-end.
  - [x] Content validation tests cover the final stage and boss definitions.
  - [x] The current test suite passes.
- Dependencies: [P3-02]
- Completed: 2026-03-05

### [P3-02] Build Stage 2
- Outcome: Add the midgame stage, two new enemy archetypes, and one new hazard language.
- Validation:
  - [x] Stage 2 is playable end-to-end.
  - [x] Content validation tests cover the new stage and enemy definitions.
  - [x] The current test suite passes.
- Dependencies: [P3-01]
- Completed: 2026-03-05

### [P2-02] Implement progression and validation systems
- Outcome: Add save/load, stage select, rank/time scoring, unlock tracking, and content validation checks.
- Validation:
  - [x] Automated tests cover save/load, scoring, unlocks, and content validation.
  - [x] Manual smoke checks confirm saves persist and load safely.
  - [x] The current test suite passes.
- Dependencies: [P2-01]
- Completed: 2026-03-05 (`e66be2c`)

### [P2-03] Harden the production pipeline
- Outcome: Update provenance, dependency and license review, packaging notes, and automated build/test flow for ongoing production.
- Validation:
  - [x] [`docs/asset_provenance_register.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/asset_provenance_register.md) is current for all committed dependencies and placeholder assets.
  - [x] [`docs/macos_build_and_distribution.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/macos_build_and_distribution.md) reflects the active build workflow.
  - [x] The current test suite passes.
- Dependencies: [P2-02]
- Completed: 2026-03-05 (`07a95ed`)

### [P2-04] Run the vertical-slice test pass
- Outcome: Playtest the vertical slice, fix blockers, and lock the MVP expansion target.
- Validation:
  - [x] [`docs/playtest_log.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest_log.md) records the slice test round.
  - [x] Blocking findings are fixed or explicitly accepted.
  - [x] The current test suite passes.
- Dependencies: [P2-03]
- Completed: 2026-03-05 (`e771dff`)

### [P3-01] Add the second playable character
- Outcome: Introduce a second character with a meaningfully different mobility and combat profile.
- Validation:
  - [x] Automated tests cover deterministic roster, unlock, and loadout behavior.
  - [x] Manual smoke checks confirm the second character changes play feel meaningfully.
  - [x] The current test suite passes.
- Dependencies: [P2-04]
- Completed: 2026-03-05 (`7ae767d`)

### [P2-01] Promote Stage 1 into a vertical slice
- Outcome: Upgrade Stage 1 with target-leaning art/audio, cleaner camera and VFX discipline, and a full boss fight.
- Validation:
  - [x] The slice is playable end-to-end with updated visuals and audio.
  - [x] Manual smoke checks confirm readability did not regress.
  - [x] The current test suite passes.
- Dependencies: [P1-07]
- Completed: 2026-03-05 (`3a28ad6`)

### [P1-07] Run the Phase 1 playtest gate
- Outcome: Capture 5 to 8 external playtests, fix repeated clarity or fairness issues, and document the gate result.
- Validation:
  - [x] [`docs/playtest_log.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest_log.md) contains 5 to 8 sessions or clearly documents the blocker if outside testers are unavailable.
  - [x] Repeated issues are reflected in [`docs/risk_register.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/risk_register.md) and resolved or accepted.
  - [x] The current test suite passes.
- Dependencies: [P1-06]
- Completed: 2026-03-05

### [P1-06] Export and verify the first macOS build
- Outcome: Produce a tester-ready Apple Silicon build and record build evidence, smoke results, and known issues.
- Validation:
  - [x] A macOS build artifact exists.
  - [x] Apple Silicon launch and packaging notes are recorded in [`docs/macos_build_and_distribution.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/macos_build_and_distribution.md).
  - [x] The current test suite passes.
- Dependencies: [P1-05]
- Completed: 2026-03-05

### [P1-05] Build Stage 1 first playable
- Outcome: Deliver one short stage with a first fight inside 30 seconds, a spectacle beat inside 3 minutes, a checkpoint, HUD, pause or restart flow, and placeholder audio.
- Validation:
  - [x] Manual playthrough confirms first combat and spectacle timing targets.
  - [x] HUD, pause, and restart flows work in windowed and fullscreen modes.
  - [x] The current test suite passes.
- Dependencies: [P1-04]
- Completed: 2026-03-05

### [P1-04] Implement enemy systems
- Outcome: Add the shared enemy framework, three starter archetypes, and the elite/miniboss foundation.
- Validation:
  - [x] Automated tests cover spawn/state/content validation rules that can be deterministic.
  - [x] Manual smoke checks confirm enemy telegraphs and reactions are readable.
  - [x] The current test suite passes.
- Dependencies: [P1-03]
- Completed: 2026-03-05

### [P1-03] Implement the combat core
- Outcome: Add light attacks, heavy finisher, launcher or sweep, crowd-control special, hitstop, damage, invulnerability windows, and checkpoint reset behavior.
- Validation:
  - [x] Automated tests cover combat-state rules, damage resolution, and checkpoint reset behavior.
  - [x] Manual smoke checks confirm hits feel responsive and readable.
  - [x] The current test suite passes.
- Dependencies: [P1-02]
- Completed: 2026-03-05

### [P1-02] Implement player locomotion and input
- Outcome: Ship the first playable controller layer with run, jump, dodge, controller hot-plug, keyboard fallback, and remapping-safe actions.
- Validation:
  - [x] Automated tests cover the deterministic movement and input-state rules that can be unit tested.
  - [x] Manual smoke checks confirm controller and keyboard input are both playable.
  - [x] The current test suite passes.
- Dependencies: [P1-01]
- Completed: 2026-03-05

### [P1-01] Create the production scaffold
- Outcome: Add the chosen engine project, `src/`, `tests/`, provenance logging updates, repeatable build/test commands, and CI or scripted validation hooks.
- Validation:
  - [x] The repo contains runtime code in `src/` and automated tests in `tests/`.
  - [x] [`README.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/README.md) documents install, run, and test commands.
  - [x] The initial automated test suite passes locally.
- Dependencies: [P0-07]
- Completed: 2026-03-05

### [P0-07] Lock the initial engine path and freeze the backlog
- Outcome: Score the three engines, choose the winner with the documented tie-break, update risks, and lock the production backlog.
- Validation:
  - [x] Weighted totals are filled in [`docs/engine_matrix.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/engine_matrix.md).
  - [x] [`docs/game_spec.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/game_spec.md) names the chosen engine path.
  - [x] [`docs/risk_register.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/risk_register.md) and this tracker reflect the engine decision and frozen backlog.
- Dependencies: [P0-04], [P0-05], [P0-06]
- Completed: 2026-03-05

### [DOC-04] Simplify the public task tracker
- Outcome: Keep `to-do.md` focused on `PENDING` and `DONE` only, with task-by-task outcome, validation, and dependency fields.
- Validation:
  - [x] [`to-do.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/to-do.md) uses `PENDING` and `DONE` as the only task buckets.
  - [x] Every task entry includes outcome, validation, and dependency details.
  - [x] The tracker documents the one-task-at-a-time green-test commit gate.
- Dependencies: None
- Completed: 2026-03-05

### [P0-02] Approve the Wildcoil concept direction
- Outcome: Mark `Wildcoil` as the approved concept winner across the Phase 0 docs and keep MVP scope solo-first.
- Validation:
  - [x] [`docs/game_spec.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/game_spec.md) explicitly says the concept is approved, not just recommended.
  - [x] [`README.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/README.md) and this tracker reflect the approved direction and MVP target.
  - [x] [`docs/risk_register.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/risk_register.md) is updated for the locked concept direction.
- Dependencies: [DOC-04]
- Completed: 2026-03-05

### [P0-03] Verify the engine toolchain on this machine
- Outcome: Confirm local availability or installation status for Godot, Unity, Unreal, Xcode, and the minimum macOS export prerequisites needed for the engine comparison.
- Validation:
  - [x] Local commands or app locations are recorded for Godot, Unity, Unreal, `xcodebuild`, and package tooling.
  - [x] Any missing prerequisites or auth blockers are documented in [`docs/engine_matrix.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/engine_matrix.md).
  - [x] The machine-specific setup state is clear enough to start or explain each spike.
- Dependencies: [P0-02]
- Completed: 2026-03-05

### [P0-04] Build the Godot micro-spike
- Outcome: Implement the fixed spike checklist in Godot with movement, dodge, combo, one enemy, controller input, keyboard fallback, and a macOS export artifact.
- Validation:
  - [x] Godot spike project runs locally.
  - [x] macOS export result and packaging notes are logged in [`docs/engine_matrix.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/engine_matrix.md).
  - [x] FPS/frame-time notes and workflow observations are recorded.
- Dependencies: [P0-03]
- Completed: 2026-03-05

### [P0-05] Build the Unity micro-spike
- Outcome: Implement the same fixed spike checklist in Unity and capture export, workflow, and controller evidence.
- Validation:
  - [x] Unity spike project runs locally, or the exact machine/auth blocker is documented with evidence.
  - [x] macOS export result and packaging notes are logged in [`docs/engine_matrix.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/engine_matrix.md).
  - [x] FPS/frame-time notes and workflow observations are recorded.
- Dependencies: [P0-03]
- Completed: 2026-03-05

### [P0-06] Build the Unreal micro-spike
- Outcome: Implement the same fixed spike checklist in Unreal and capture export, workflow, and controller evidence.
- Validation:
  - [x] Unreal spike project runs locally, or the exact machine/auth blocker is documented with evidence.
  - [x] macOS export result and packaging notes are logged in [`docs/engine_matrix.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/engine_matrix.md).
  - [x] FPS/frame-time notes and workflow observations are recorded.
- Dependencies: [P0-03]
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
