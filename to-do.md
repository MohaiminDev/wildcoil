# Rift Road Task Tracker

## Project Goal

Make the running Godot game feel like a polished Stage 1 episode of `Rift Road: Beasts of the Afterglow`: a modern cinematic 2D arcade brawler that looks alive, feels responsive, runs well on the target M1 iMac, and keeps the repair-versus-extraction story clear through play.

The current build can prove flow, combat scaffolding, packaging, and several launched-game presentation passes, but it still does not satisfy the updated 2026-05-11 slice spec. The next work must prioritize missing Stage 1 episode beats and feel gates before any broader market-facing claim: opening story/bark delivery, physical-device validation, and real playtest evidence.

## Product Thesis

Rift Road should feel like a modern cinematic 2D arcade road adventure: responsive belt-scroll brawler combat, warm prehistoric-future staging, expressive HD 2D characters with arcade/pixel-art influence, big readable enemies, punchy but non-bloody impact effects, short playable story beats, and strong originality safeguards.

## Current Milestone

Production Vertical Slice - Asset-Backed Stage 1 Visual Slice

## Active Story Source

- [`docs/game_spec.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/game_spec.md) is the living game spec and current product-behavior bar.
- [`docs/game-story.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/game-story.md) is the story bible and product direction.
- [`docs/design-docs/stage1-visual-north-star.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/design-docs/stage1-visual-north-star.md) locks the approved concept-image direction for Stage 1.
- [`docs/design-docs/stage1-visual-production-recovery.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/design-docs/stage1-visual-production-recovery.md) defines the recovery path from prototype shapes to asset-backed visuals.
- [`docs/design-docs/assets/stage1-visual-north-star.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/design-docs/assets/stage1-visual-north-star.png) is the UI/combat/presentation quality bar.
- [`docs/design-docs/assets/stage1-background-north-star.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/design-docs/assets/stage1-background-north-star.png) is the Stage 1 environment quality bar.
- [`docs/superpowers/plans/2026-04-27-rift-road-mvp.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/superpowers/plans/2026-04-27-rift-road-mvp.md) records the first playable implementation plan.

## Vertical Slice Target

The playable path is: title screen, hero select, Stage 1 cinematic start, Raya/Nika combat, readable enemy waves, simple pickups, road-collapse set piece into a lower service-lane beat, Brask Noll boss with readable heavy-attack/stun lesson, Brask escape and route-to-Glassleaf consequence, Stage Clear score/rank summary, restart or return-to-title flow, and packaged macOS zip.

The visual target is the approved north-star direction: modern stylized arcade realism with pixel-art-inspired readability, cinematic sunset highway ruins, jungle depth, luma glow, dramatic sparks and dust, strong silhouettes, clean premium HUD and menus, no modern 3D realism, no generic cyberpunk drift, and no copied characters, UI, layouts, stages, sprites, logos, vehicles, or music from existing games.

## Current Truth

- Mechanically playable prototype: yes.
- Production-grade visual/UI match to north-star images: no.
- Manual playtest evidence: current Codex run opened the rebuilt exported macOS app through LaunchServices, advanced title -> hero select -> Stage 1 with real key input, and sent movement/attack input while the easier four-enemy opening wave stayed playable with health/HUD visible.
- Controller baseline: simulated Godot runtime smoke covers controller title -> hero select -> Stage 1 and pause/resume; gameplay code supports left stick/D-pad movement plus X/A/Y/B/LB/RB/Start actions. Physical controller devices are not tested yet.
- Controller evidence gate: `bash scripts/check_controller_evidence.sh` reads `docs/controller_validation.md` and currently reports `RIFT_ROAD_CONTROLLER_EVIDENCE blocked` because no physical controller-family sessions have been recorded.
- Latest capture note: the exported macOS app supports a repeatable launched-app viewport smoke capture path that is not dependent on the current macOS Space being visible to `screencapture`; the latest title smoke capture now shows a branded Rift Road logo lockup and start plate, the latest hero-select smoke capture shows canted arcade cards, selected-card glow, portrait wells, planned-hero silhouettes, stat pips, and a canted arcade header/ribbon instead of plain heading text, the latest gameplay capture shows the Stage 1 intro as a centered slim strap above the combatants with non-ellipsized `Free the transport cages` copy plus a slimmer top HUD that exposes more sunset/backdrop area, the latest post-intro combat capture shows the running fight after the intro strap has cleared with a one-line objective rail and no stale center wave notice, the latest pickup smoke capture shows distinct health and luma/meter pickup markers from the launched exported app, the latest road-collapse smoke capture shows luma fractures and the exposed service lane after the opening cage-loading fight, the latest Brask intro smoke capture shows the boss story banner from the launched exported app, the latest Stage Clear smoke capture shows rank, score, luma, and health summary text in the canted arcade result frame, the Game Over/retry smoke capture shows the fail-state result text and controls, and the post-retry smoke capture shows Stage 1 gameplay after restarting from the Game Over path.
- Package audit: `bash scripts/audit_macos_package.sh` reports `RIFT_ROAD_PACKAGE_AUDIT internal-only`; the bundle signature verifies, but Developer ID authority, Apple Team ID, notarization, Gatekeeper acceptance, and stapled ticket validation are not present.
- Signing preflight: `bash scripts/check_macos_signing_env.sh` reports `RIFT_ROAD_SIGNING_PREFLIGHT blocked`; required non-secret inputs are `RIFT_ROAD_APPLE_TEAM_ID`, `RIFT_ROAD_DEVELOPER_ID_APPLICATION`, and `RIFT_ROAD_NOTARY_KEYCHAIN_PROFILE`.
- Second-machine evidence: `bash scripts/check_second_machine_evidence.sh` reads `docs/playtest-captures/second-machine-latest/` and currently reports `RIFT_ROAD_SECOND_MACHINE_EVIDENCE blocked` because no clean-machine proof files have been recorded.
- Exported-app smoke: `bash scripts/smoke_exported_macos_app.sh` extracts `build/macos/Rift Road.zip`, launches the `.app` with `--rift-road-smoke-stage1` and `--rift-road-smoke-capture-dir=...`, captures title, hero-select, Stage 1 gameplay, post-intro combat, pickup clarity, road-collapse, Stage Clear, Game Over/retry, and post-retry gameplay viewport screenshots from the running exported app, and reports `RIFT_ROAD_EXPORTED_APP_SMOKE ok`.
- Exported-app performance: `bash scripts/sample_exported_app_performance.sh` launches the packaged `.app`, records `docs/playtest-captures/exported-app-performance-latest/stage1-exported-performance.json`, and reports `RIFT_ROAD_EXPORTED_PERF stage1` on local Apple Silicon Mac A (`arm64`, `Apple M1`, `iMac21,2`) with latest local 1280x720 windowed steady-state result `avg_ms=1.476`, `max_ms=1.515` after 8 startup/render warmup frames. A local 1920x1080 windowed run records `avg_ms=3.199`, `max_ms=6.652` in `docs/playtest-captures/exported-app-performance-windowed-1080p-latest/stage1-exported-performance.json`, and a local fullscreen run records `avg_ms=1.583`, `max_ms=2.793` in `docs/playtest-captures/exported-app-performance-fullscreen-latest/stage1-exported-performance.json`.
- Release-candidate gate: `bash scripts/check_release_candidate.sh` combines checks, package, audit, exported-app smoke, and performance sample, then reports `RIFT_ROAD_RELEASE_GATE blocked` until package and player-evidence gates are resolved.
- Known-tester packet: `bash scripts/prepare_known_tester_packet.sh` creates `build/known-tester-packet/latest/` with the current internal-only zip, manifest, validation logs, package audit, smoke captures, performance JSON, host profile, and playtest docs for supervised known-tester sessions.
- Playtest evidence gate: `bash scripts/check_playtest_evidence.sh` reads `docs/playtest_log.md` and currently reports `RIFT_ROAD_PLAYTEST_EVIDENCE blocked` because no external session rows have been recorded.
- 2026-05-11 spec/story realignment: [`docs/game_spec.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/game_spec.md) and [`docs/game-story.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/game-story.md) now make the first success condition feel-focused, not market-demand-focused: the Stage 1 slice must feel good, look alive, and be satisfying to replay on an M1 iMac before public-playtest or marketability claims. Current missing spec-critical beats include opening comic-panel/dialogue structure, physical controller/second-machine validation, and external playtest evidence.
- Performance sample: `stage1_performance_sample` reports `RIFT_ROAD_PERF stage1` with latest local result `avg_ms=16.592`, `max_ms=23.251`.
- Public playtest gate: [`docs/public_playtest_gate.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/public_playtest_gate.md) defines the external session protocol and explicitly blocks marketable/player-loved claims until external evidence exists.
- Market-readiness audit: [`docs/market-readiness-audit-2026-05-10.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/market-readiness-audit-2026-05-10.md) maps every active marketability requirement to evidence and gaps; the active goal is not complete.
- Current proof artifacts:
  - Cinematic banner proof with shortened round banner copy: [`docs/playtest-captures/stage1-cinematic-banner-proof.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-cinematic-banner-proof.png)
  - Fresh exported macOS app title screenshot from the rebuilt zip: [`docs/playtest-captures/stage1-exported-app-title-window.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-exported-app-title-window.png)
  - Fresh exported macOS app Stage 1 screenshot after title -> hero select -> Stage 1 keyflow: [`docs/playtest-captures/stage1-exported-app-gameplay-window.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-exported-app-gameplay-window.png)
  - Fresh exported macOS app manual input screenshot after movement/attack key input: [`docs/playtest-captures/stage1-exported-app-manual-input-window.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-exported-app-manual-input-window.png)
  - Repeatable exported-app smoke title screenshot: [`docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-title.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-title.png)
  - Repeatable exported-app smoke hero-select screenshot: [`docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-hero-select.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-hero-select.png)
  - Repeatable exported-app smoke gameplay screenshot: [`docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-gameplay.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-gameplay.png)
  - Repeatable exported-app smoke post-intro combat screenshot: [`docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-combat.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-combat.png)
  - Repeatable exported-app smoke pickup screenshot: [`docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-pickups.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-pickups.png)
  - Repeatable exported-app smoke road-collapse screenshot: [`docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-road-collapse.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-road-collapse.png)
  - Repeatable exported-app smoke Brask intro screenshot: [`docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-brask-intro.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-brask-intro.png)
  - Repeatable exported-app smoke Stage Clear screenshot: [`docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-stage-clear.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-stage-clear.png)
  - Repeatable exported-app smoke Game Over/retry screenshot: [`docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-game-over.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-game-over.png)
  - Repeatable exported-app smoke post-retry gameplay screenshot: [`docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-retry-gameplay.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-retry-gameplay.png)
  - Boss HUD readability proof with player HUD, objective panel, score/luma, and boss bar visible at 1280x720: [`docs/playtest-captures/stage1-boss-hud-readability-proof.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-boss-hud-readability-proof.png)
  - Combat impact proof screenshot with non-bloody burst, timing ring, speed lines, damage/combo feedback, and enemy flinch: [`docs/playtest-captures/stage1-combat-impact-proof.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-combat-impact-proof.png)
  - Jungle-road ruins pass runtime screenshot with ruined signs, cages, rubble, and luma plant clusters: [`docs/playtest-captures/stage1-jungle-road-ruins-pass.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-jungle-road-ruins-pass.png)
  - Premium readability pass runtime screenshot with upgraded HUD and fight-plane grading: [`docs/playtest-captures/stage1-premium-readability-pass.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-premium-readability-pass.png)
  - Cinematic motion slice screenshot after the actor motion pass: [`docs/playtest-captures/stage1-cinematic-motion-slice.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-cinematic-motion-slice.png)
  - Cinematic motion slice frame sequence: [`docs/playtest-captures/stage1-cinematic-motion-slice-frames/`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-cinematic-motion-slice-frames/)
  - Nika and Brask boss proof screenshot from the Godot runtime: [`docs/playtest-captures/stage1-nika-brask-boss-proof.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-nika-brask-boss-proof.png)
  - Current exported macOS app window screenshot after the motion pass: [`docs/playtest-captures/stage1-exported-app-post-motion-window.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-exported-app-post-motion-window.png)
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

### [RR-PROD-15] Verify physical controller devices
- Outcome: The exported macOS app is tested with at least two controller families plus keyboard fallback, with device names and blockers recorded.
- Validation:
  - [ ] Record controller family 1 and family 2 in `docs/macos_build_and_distribution.md`.
  - [ ] Confirm title, hero select, Stage 1 movement, attack, jump, special, dash, pause, and cancel/back on each controller.
  - [ ] Confirm keyboard fallback still completes the same flow.
- Dependencies: [RR-PROD-12]

### [RR-PROD-14] Run recorded external-style playtest gate
- Outcome: A human tester session or equivalent recorded session covers title -> Stage 1 -> clear/fail/retry with notes on confusion, unfair damage, delight, replay intent, and originality.
- Validation:
  - [ ] Playtest notes are captured in `docs/playtest_log.md` or a dated capture note.
  - [ ] A video or screenshot sequence supports the notes.
  - [ ] Marketability claims are updated only if evidence supports them.
- Dependencies: [RR-PROD-15]

## DONE

### [RR-PROD-48] Add simple pickup clarity
- Outcome: Stage 1 pickups now use distinct data-driven health and luma/meter definitions, clearer visual markers, collection notices, pickup audio, and a repeatable launched-app pickup clarity screenshot.
- Validation:
  - [x] Added a regression that `PickupManager` defines `glowfruit` and `luma_shard` with display names, short labels, effects, colors, and dedicated draw helpers, and that `StageManager` surfaces collection feedback.
  - [x] Added runtime smoke coverage for `stage1_pickup_clarity` proving Glowfruit heals and Luma Shard increases luma/meter/score in the running Stage 1 scene.
  - [x] Added exported-app smoke coverage for `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-pickups.png`.
  - [x] `python3 -m pytest tests/test_brawler_presentation.py::test_pickups_are_distinct_and_surface_collection_feedback tests/test_runtime_smoke.py::test_stage_one_pickups_apply_clear_health_and_luma_effects tests/test_scripts_and_docs.py::test_exported_app_smoke_script_captures_pickup_clarity_viewport -q` passes.
  - [x] `bash scripts/check.sh` passes with 88 tests and Godot runtime smoke.
  - [x] `bash scripts/package_macos.sh` regenerated `build/macos/Rift Road.zip`.
  - [x] `bash scripts/smoke_exported_macos_app.sh` reports `RIFT_ROAD_EXPORTED_APP_SMOKE ok` with `pickup_capture=.../stage1-exported-app-smoke-pickups.png`.
  - [x] Manual visual inspection of `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-pickups.png` confirms the launched-app pickup markers are visible and distinct; this is pickup clarity evidence, not a human balance/playtest claim.
- Progress:
  - 2026-05-11: Added data-driven pickup effects, distinct markers, collection feedback, runtime smoke, and launched-app pickup capture.
- Dependencies: [RR-PROD-47]
- Completed: 2026-05-11

### [RR-PROD-47] Add Brask intro, phase, and escape story beats
- Outcome: Brask now has Stage 1 boss-story beats for entrance, phase escalation, and escape consequence, surfaced through existing HUD/combat banner presentation without adding long dialogue pauses.
- Validation:
  - [x] Added a regression that Stage 1 data includes `boss_story` intro, phase, and escape lines and that `StageManager` routes those lines through boss-story helpers.
  - [x] Added runtime smoke coverage for `stage1_brask_story` proving intro, phase, and escape beats surface in the running stage.
  - [x] Added exported-app smoke coverage for `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-brask-intro.png`.
  - [x] `python3 -m pytest tests/test_brawler_presentation.py::test_stage_one_has_brask_story_beats tests/test_runtime_smoke.py::test_stage_one_brask_story_beats_surface_in_runtime tests/test_scripts_and_docs.py::test_exported_app_smoke_script_captures_brask_intro_viewport -q` passes.
  - [x] `python3 -m pytest tests/test_runtime_smoke.py::test_stage_one_title_to_victory_flow tests/test_runtime_smoke.py::test_stage_one_brask_story_beats_surface_in_runtime tests/test_runtime_smoke.py::test_stage_one_restart_and_return_to_title_flow -q` passes.
  - [x] `bash scripts/check.sh` passes with 85 tests and Godot runtime smoke.
  - [x] `bash scripts/package_macos.sh` regenerated `build/macos/Rift Road.zip`.
  - [x] `bash scripts/smoke_exported_macos_app.sh` reports `RIFT_ROAD_EXPORTED_APP_SMOKE ok` with `brask_intro_capture=.../stage1-exported-app-smoke-brask-intro.png`.
  - [x] Manual visual inspection of `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-brask-intro.png` confirms the launched-app boss intro banner shows Brask's story line; this is story-presentation evidence, not a full human boss playtest.
- Progress:
  - 2026-05-11: Added data-driven Brask intro, phase-change, and escape story beats plus repeatable launched-app Brask intro capture.
- Dependencies: [RR-PROD-46]
- Completed: 2026-05-11

### [RR-PROD-46] Add Stage Clear score/rank summary
- Outcome: Stage Clear now gives the player a replay-facing result summary with rank, score, luma, and health without adding a separate results screen or interrupting the restart/continue flow.
- Validation:
  - [x] Added a regression that `StageManager` exposes `stage_clear_summary()` and `AppRoot` formats a result summary containing `RANK`, `Score`, `Luma`, and `Health`.
  - [x] Added runtime smoke coverage that fails unless the Stage Clear label shows rank, score, luma, and health.
  - [x] `python3 -m pytest tests/test_brawler_presentation.py::test_stage_clear_surfaces_score_rank_summary tests/test_runtime_smoke.py::test_stage_one_title_to_victory_flow -q` passes.
  - [x] `python3 -m pytest tests/test_runtime_smoke.py::test_stage_one_title_to_victory_flow tests/test_runtime_smoke.py::test_stage_one_restart_and_return_to_title_flow tests/test_scripts_and_docs.py::test_exported_app_smoke_script_captures_stage_clear_viewport -q` passes.
  - [x] `bash scripts/check.sh` passes with 82 tests and Godot runtime smoke.
  - [x] `bash scripts/package_macos.sh` regenerated `build/macos/Rift Road.zip`.
  - [x] `bash scripts/smoke_exported_macos_app.sh` reports `RIFT_ROAD_EXPORTED_APP_SMOKE ok` and refreshed `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-stage-clear.png`.
  - [x] Manual visual inspection of `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-stage-clear.png` confirms the Stage Clear result frame shows rank, score, luma, and health; this is replay-goal UI evidence, not a human playtest.
- Progress:
  - 2026-05-11: Added the minimal Stage Clear result summary requested by the updated Stage 1 slice spec.
- Dependencies: [RR-PROD-45]
- Completed: 2026-05-11

### [RR-PROD-45] Add the Stage 1 road-collapse set piece
- Outcome: Stage 1 delivers the updated spec's first wow moment: after the cage-loading fight, luma extraction overloads the overpass, the camera/stage presentation sells a brief road-collapse beat, and play resumes quickly on a lower service-lane combat beat without hiding incoming threats.
- Validation:
  - [x] Added a regression that Stage 1 data and `StageManager` expose a road-collapse stage event after the cage-loading wave and before Brask.
  - [x] Added runtime smoke coverage for `stage1_road_collapse` so the event can be reached without script errors and play resumes after the collapse.
  - [x] Added exported-app smoke coverage for `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-road-collapse.png`.
  - [x] `python3 -m pytest tests/test_brawler_presentation.py::test_stage_one_has_road_collapse_set_piece tests/test_runtime_smoke.py::test_stage_one_road_collapse_event_resumes_service_lane tests/test_scripts_and_docs.py::test_exported_app_smoke_script_captures_road_collapse_viewport -q` passes.
  - [x] `python3 -m pytest tests/test_runtime_smoke.py::test_stage_one_title_to_victory_flow tests/test_runtime_smoke.py::test_stage_one_autoplay_moves_and_attacks tests/test_runtime_smoke.py::test_stage_one_road_collapse_event_resumes_service_lane -q` passes.
  - [x] `bash scripts/check.sh` passes with 81 tests and Godot runtime smoke.
  - [x] `bash scripts/package_macos.sh` regenerated `build/macos/Rift Road.zip`.
  - [x] `bash scripts/smoke_exported_macos_app.sh` reports `RIFT_ROAD_EXPORTED_APP_SMOKE ok` with `road_collapse_capture=.../stage1-exported-app-smoke-road-collapse.png`.
  - [x] Manual visual inspection of `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-road-collapse.png` confirms the event reads as luma-driven road failure with exposed service-lane geometry; this is launched-app set-piece evidence, not a human playtest or final art claim.
- Progress:
  - 2026-05-10: Added the Stage 1 road-collapse beat, runtime resume check, exported-app smoke capture, and updated handoff/audit evidence.
- Dependencies: [RR-PROD-44]
- Completed: 2026-05-10

### [RR-PROD-44] Remove Stage 1 intro strap ellipsis
- Outcome: Stage 1 keeps the full `scenario_goal`, but the transient stage card now uses compact `stage_card_goal` display copy, so the launched gameplay intro strap reads `Free the transport cages` instead of ellipsizing the full scenario line.
- Validation:
  - [x] Added a regression that Stage 1 preserves the full `scenario_goal`, defines shorter `stage_card_goal` copy, and routes the intro stage card through `_stage_card_goal`.
  - [x] Verified the regression fails before implementation and passes after implementation.
  - [x] `python3 -m pytest tests/test_arcade_aesthetics.py::test_stage_one_intro_card_uses_non_ellipsized_goal_copy tests/test_arcade_aesthetics.py::test_stage_one_objective_rail_uses_compact_hud_copy tests/test_brawler_presentation.py::test_stage_intro_banner_preserves_combat_plane -q` passes.
  - [x] `python3 -m pytest tests/test_runtime_smoke.py::test_stage_one_title_to_victory_flow tests/test_runtime_smoke.py::test_stage_one_autoplay_moves_and_attacks -q` passes.
  - [x] `bash scripts/check.sh` passes with 78 tests and Godot runtime smoke.
  - [x] `bash scripts/package_macos.sh` regenerated `build/macos/Rift Road.zip`.
  - [x] `bash scripts/smoke_exported_macos_app.sh` reports `RIFT_ROAD_EXPORTED_APP_SMOKE ok` and refreshed `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-gameplay.png`.
  - [x] Manual visual inspection of `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-gameplay.png` confirms the intro strap reads `Free the transport cages` without ellipsis; this is incremental launched-app polish, not final art or a human playtest.
- Progress:
  - 2026-05-10: Replaced the launched Stage 1 intro card's full scenario line with compact display copy after the smoke gameplay capture showed ellipsized objective text.
- Dependencies: [RR-PROD-41]

### [RR-PROD-43] Polish hero-select header treatment
- Outcome: Replaced the plain floating hero-select heading with a canted arcade header/ribbon so the menu title belongs to the same interface family as the updated hero cards.
- Validation:
  - [x] Added a regression that `AppRoot` builds `hero_select_header_group` with a canted header frame, route ribbon, command label, and screen-specific visibility toggles while suppressing the old plain heading text.
  - [x] Verified the regression fails before implementation and passes after implementation.
  - [x] `python3 -m pytest tests/test_arcade_aesthetics.py::test_hero_select_uses_canted_arcade_header tests/test_arcade_aesthetics.py::test_hero_select_cards_use_canted_arcade_frames tests/test_runtime_smoke.py::test_character_select_preview_starts_selected_hero -q` passes.
  - [x] `bash scripts/check.sh` passes with 77 tests and Godot runtime smoke.
  - [x] `bash scripts/package_macos.sh` regenerated `build/macos/Rift Road.zip`.
  - [x] `bash scripts/smoke_exported_macos_app.sh` reports `RIFT_ROAD_EXPORTED_APP_SMOKE ok` and refreshed `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-hero-select.png`.
  - [x] Manual visual inspection of `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-hero-select.png` confirms the hero-select screen uses a canted arcade header/ribbon without overlapping cards or bottom controls; this is incremental launched-app polish, not final art or a human playtest.
- Progress:
  - 2026-05-10: Polished the launched hero-select header to replace the last plain heading text on that menu.
- Dependencies: [RR-PROD-32]
- Completed: 2026-05-10

### [RR-PROD-42] Auto-clear transient wave notice text
- Outcome: Added timed HUD notices and made Stage 1 wave-start text expire, so the launched post-intro combat capture no longer keeps stale centered `Sunset Overpass / Wave 1` text over the sky after the intro strap has cleared.
- Validation:
  - [x] Added a regression that `HUDController` has a `notice_timer`, `_process` countdown, `clear_notice()`, timed `show_notice(...)`, and that StageManager passes a duration for wave-start notices.
  - [x] Verified the regression fails before implementation and passes after implementation.
  - [x] `python3 -m pytest tests/test_arcade_aesthetics.py::test_wave_notice_auto_clears_after_intro_strap tests/test_arcade_aesthetics.py::test_stage_one_objective_rail_uses_compact_hud_copy tests/test_arcade_aesthetics.py::test_hud_uses_asset_backed_arcade_portrait_and_meter_ticks -q` passes.
  - [x] `python3 -m pytest tests/test_runtime_smoke.py::test_stage_one_title_to_victory_flow tests/test_runtime_smoke.py::test_stage_one_autoplay_moves_and_attacks tests/test_brawler_presentation.py::test_hud_and_player_surface_win_combat_rules -q` passes.
  - [x] `bash scripts/check.sh` passes with 76 tests and Godot runtime smoke.
  - [x] `bash scripts/package_macos.sh` regenerated `build/macos/Rift Road.zip`.
  - [x] `bash scripts/smoke_exported_macos_app.sh` reports `RIFT_ROAD_EXPORTED_APP_SMOKE ok` and refreshed `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-combat.png`.
  - [x] Manual visual inspection of `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-combat.png` confirms the stale centered wave notice is gone while the one-line objective rail remains visible; this is incremental launched-app polish, not a human playtest.
- Progress:
  - 2026-05-10: Cleared a lingering UI artifact found in the launched post-intro combat capture.
- Dependencies: [RR-PROD-41]
- Completed: 2026-05-10

### [RR-PROD-41] Compact the Stage 1 objective rail copy
- Outcome: Added a short Stage 1 HUD objective and reduced the top-center objective rail so the launched combat capture keeps the mission readable on one line without turning the sky area into a paragraph panel.
- Validation:
  - [x] Added a regression that Stage 1 keeps the full `scenario_goal`, adds compact `hud_goal` copy, uses a smaller one-line objective rail, and routes wave HUD text through `_stage_hud_goal`.
  - [x] Verified the regression fails before implementation and passes after implementation.
  - [x] `python3 -m pytest tests/test_arcade_aesthetics.py::test_stage_one_objective_rail_uses_compact_hud_copy tests/test_arcade_aesthetics.py::test_hud_uses_asset_backed_arcade_portrait_and_meter_ticks -q` passes.
  - [x] `python3 -m pytest tests/test_runtime_smoke.py::test_stage_one_title_to_victory_flow tests/test_runtime_smoke.py::test_stage_one_autoplay_moves_and_attacks tests/test_brawler_presentation.py::test_hud_and_player_surface_win_combat_rules -q` passes.
  - [x] `bash scripts/check.sh` passes with 75 tests and Godot runtime smoke.
  - [x] `bash scripts/package_macos.sh` regenerated `build/macos/Rift Road.zip`.
  - [x] `bash scripts/smoke_exported_macos_app.sh` reports `RIFT_ROAD_EXPORTED_APP_SMOKE ok` and refreshed `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-combat.png`.
  - [x] Manual visual inspection of `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-combat.png` confirms the objective rail now reads as a single line while preserving the combat view; this is incremental UI polish, not final HUD art.
- Progress:
  - 2026-05-10: Replaced long combat-HUD objective copy with a short HUD-specific Stage 1 goal after reviewing the launched post-intro combat capture.
- Dependencies: [RR-PROD-40]
- Completed: 2026-05-10

### [RR-PROD-40] Add launched post-intro combat smoke capture
- Outcome: Extended the exported-app smoke path with a timer-backed post-intro combat capture so the packaged app records a cleaner running-fight viewport after the Stage 1 intro strap has faded.
- Validation:
  - [x] Added a regression that the exported-app smoke script, `AppRoot`, market handoff, and readiness audit all reference `stage1-exported-app-smoke-combat.png`, and that the combat capture helper waits on a timer before saving the viewport.
  - [x] Verified the regression fails before implementation and passes after implementation.
  - [x] `python3 -m pytest tests/test_scripts_and_docs.py::test_exported_app_smoke_script_captures_post_intro_combat_viewport -q` passes.
  - [x] `python3 -m pytest tests/test_scripts_and_docs.py::test_exported_app_smoke_script_captures_launched_viewport tests/test_scripts_and_docs.py::test_exported_app_smoke_script_captures_post_intro_combat_viewport tests/test_scripts_and_docs.py::test_exported_app_smoke_script_captures_stage_clear_viewport tests/test_scripts_and_docs.py::test_exported_app_smoke_script_captures_game_over_viewport tests/test_scripts_and_docs.py::test_exported_app_smoke_script_captures_retry_gameplay_viewport -q` passes.
  - [x] `bash scripts/check.sh` passes with 74 tests and Godot runtime smoke.
  - [x] `bash scripts/package_macos.sh` regenerated `build/macos/Rift Road.zip`.
  - [x] `bash scripts/smoke_exported_macos_app.sh` reports `RIFT_ROAD_EXPORTED_APP_SMOKE ok` with `combat_capture=.../stage1-exported-app-smoke-combat.png`.
  - [x] Manual visual inspection of `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-combat.png` confirms the screenshot shows running Stage 1 combat after the intro strap is gone; this is launched-app evidence, not a human playtest or north-star match claim.
- Progress:
  - 2026-05-10: Added less obstructed launched-game combat proof after the Stage 1 intro presentation finishes.
- Dependencies: [RR-PROD-39]
- Completed: 2026-05-10

### [RR-PROD-39] Slim the Stage 1 top HUD footprint
- Outcome: Reduced the player, objective, and score HUD panel footprint and opacity so the launched Stage 1 gameplay capture keeps the current health, special, score, luma, objective, combo, portrait, and meter information while exposing more of the sunset/backdrop composition.
- Validation:
  - [x] Added a regression that the HUD uses compact player, portrait, score, and objective panel constants plus lighter top-panel alpha values.
  - [x] Verified the regression fails before implementation and passes after implementation.
  - [x] `python3 -m pytest tests/test_arcade_aesthetics.py::test_hud_uses_asset_backed_arcade_portrait_and_meter_ticks -q` passes.
  - [x] `python3 -m pytest tests/test_arcade_aesthetics.py::test_hud_uses_asset_backed_arcade_portrait_and_meter_ticks tests/test_brawler_presentation.py::test_hud_and_player_surface_win_combat_rules tests/test_runtime_smoke.py::test_stage_one_title_to_victory_flow -q` passes.
  - [x] `bash scripts/check.sh` passes with 73 tests and Godot runtime smoke.
  - [x] `bash scripts/package_macos.sh` regenerated `build/macos/Rift Road.zip`.
  - [x] `bash scripts/smoke_exported_macos_app.sh` reports `RIFT_ROAD_EXPORTED_APP_SMOKE ok` and refreshed `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-gameplay.png`.
  - [x] Manual visual inspection of `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-gameplay.png` confirms the top HUD is slimmer and less opaque while remaining readable; this is incremental HUD polish, not final interface art.
- Progress:
  - 2026-05-10: Reduced top HUD mass after comparing the latest launched gameplay screenshot against the north-star's cleaner arcade interface direction.
- Dependencies: [RR-PROD-38]
- Completed: 2026-05-10

### [RR-PROD-38] Compact Stage 1 intro banner into a centered strap
- Outcome: Further reduced the Stage 1 intro banner from a broad full-width overlay into a centered 760px by 58px strap so the launched-game gameplay capture keeps the combat lane and background silhouettes more open.
- Validation:
  - [x] Added a regression that the stage card uses compact width/height/font/body constants, a lighter overlay color, a HUD-adjacent y ratio, and centered optional banner-width plumbing.
  - [x] Verified the regression fails before implementation and passes after implementation.
  - [x] `python3 -m pytest tests/test_brawler_presentation.py::test_stage_intro_banner_preserves_combat_plane -q` passes.
  - [x] `python3 -m pytest tests/test_brawler_presentation.py -q` passes.
  - [x] `bash scripts/check.sh` passes with 73 tests and Godot runtime smoke.
  - [x] `bash scripts/package_macos.sh` regenerated `build/macos/Rift Road.zip`.
  - [x] `bash scripts/smoke_exported_macos_app.sh` reports `RIFT_ROAD_EXPORTED_APP_SMOKE ok` and refreshed `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-gameplay.png`.
  - [x] Manual visual inspection of `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-gameplay.png` confirms the stage intro now reads as a centered slim strap above the combatants; this is incremental polish, not a north-star visual match.
- Progress:
  - 2026-05-10: Made the Stage 1 intro presentation more HUD-adjacent and less lane-covering after inspecting the launched exported-app capture against the north-star reference.
- Dependencies: [RR-PROD-31]
- Completed: 2026-05-10

### [RR-PROD-37] Bundle manual-gate checklists in tester packet
- Outcome: The known-tester packet includes the controller and second-machine validation checklists needed to record the remaining manual release blockers during supervised sessions.
- Validation:
  - [x] Added a regression that `scripts/prepare_known_tester_packet.sh`, `docs/public_playtest_gate.md`, the handoff note, and this tracker all reference the controller and second-machine checklists.
  - [x] Verified the regression fails before implementation and passes after implementation.
  - [x] `python3 -m pytest tests/test_scripts_and_docs.py::test_known_tester_packet_script_collects_internal_build_evidence tests/test_scripts_and_docs.py::test_known_tester_packet_includes_manual_gate_checklists -q` passes.
  - [x] `bash scripts/prepare_known_tester_packet.sh` reports `RIFT_ROAD_KNOWN_TESTER_PACKET internal-only` and its embedded `scripts/check.sh` run passes with 73 tests and Godot runtime smoke.
  - [x] Generated packet manifest advertises `docs/controller_validation.md` and `docs/second_machine_validation.md`.
  - [x] Generated packet includes non-empty `build/known-tester-packet/latest/docs/controller_validation.md` and `build/known-tester-packet/latest/docs/second_machine_validation.md`.
- Progress:
  - 2026-05-10: Reduced known-tester handoff friction by bundling the exact manual-gate checklists needed for controller and second-machine evidence.
- Dependencies: [RR-PROD-27], [RR-PROD-29], [RR-PROD-30]
- Completed: 2026-05-10

### [RR-PROD-36] Add launched post-retry gameplay proof
- Outcome: Extended the exported-app smoke path so the packaged app now restarts Stage 1 from the Game Over presentation and captures a post-retry gameplay viewport from the running exported app.
- Validation:
  - [x] Added a regression that the exported-app smoke script, `AppRoot`, market handoff, and readiness audit all reference `stage1-exported-app-smoke-retry-gameplay.png`.
  - [x] Verified the regression fails before implementation and passes after implementation.
  - [x] `python3 -m pytest tests/test_scripts_and_docs.py::test_exported_app_smoke_script_captures_launched_viewport tests/test_scripts_and_docs.py::test_exported_app_smoke_script_captures_stage_clear_viewport tests/test_scripts_and_docs.py::test_exported_app_smoke_script_captures_game_over_viewport tests/test_scripts_and_docs.py::test_exported_app_smoke_script_captures_retry_gameplay_viewport -q` passes.
  - [x] `bash scripts/check.sh` passes with 72 tests and Godot runtime smoke.
  - [x] `bash scripts/package_macos.sh` regenerated `build/macos/Rift Road.zip`.
  - [x] `bash scripts/smoke_exported_macos_app.sh` reports `RIFT_ROAD_EXPORTED_APP_SMOKE ok` with `retry_gameplay_capture=.../stage1-exported-app-smoke-retry-gameplay.png`.
  - [x] Manual visual inspection of `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-retry-gameplay.png` confirms Stage 1 gameplay returns after the Game Over path; this is launched-app restart proof, not a human fail/retry playtest.
- Progress:
  - 2026-05-10: Closed the repeatable launched-app evidence gap between Game Over presentation and returning to Stage 1 gameplay.
- Dependencies: [RR-PROD-35]
- Completed: 2026-05-10

### [RR-PROD-35] Add launched Game Over/retry smoke capture
- Outcome: Extended the exported-app smoke path so the packaged app now captures the Game Over/retry presentation after the Stage Clear proof, using the same canted arcade result treatment from the running exported app.
- Validation:
  - [x] Added a regression that the exported-app smoke script, `AppRoot`, market handoff, and readiness audit all reference `stage1-exported-app-smoke-game-over.png`.
  - [x] Verified the regression fails before implementation and passes after implementation.
  - [x] `python3 -m pytest tests/test_scripts_and_docs.py::test_exported_app_smoke_script_captures_launched_viewport tests/test_scripts_and_docs.py::test_exported_app_smoke_script_captures_stage_clear_viewport tests/test_scripts_and_docs.py::test_exported_app_smoke_script_captures_game_over_viewport -q` passes.
  - [x] `bash scripts/check.sh` passes with 71 tests and Godot runtime smoke.
  - [x] `bash scripts/package_macos.sh` regenerated `build/macos/Rift Road.zip`.
  - [x] `bash scripts/smoke_exported_macos_app.sh` reports `RIFT_ROAD_EXPORTED_APP_SMOKE ok` with `game_over_capture=.../stage1-exported-app-smoke-game-over.png`.
  - [x] Manual visual inspection of `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-game-over.png` confirms the Game Over screen has readable restart and return-title prompts in the framed result treatment; this is presentation smoke, not a human fail/retry playtest.
- Progress:
  - 2026-05-10: Closed the repeatable launched-app evidence gap for the fail-state result screen without claiming player-facing fail/retry feel is proven.
- Dependencies: [RR-PROD-34]
- Completed: 2026-05-10

### [RR-PROD-34] Polish Stage Clear result overlay
- Outcome: Added a reusable canted arcade result frame behind Stage Clear/Game Over/final result text while preserving existing restart, continue, return-title, and long-text wrapping behavior.
- Validation:
  - [x] Added a regression that `AppRoot` builds a result overlay frame, clear frame, route ribbon, control rail, and stage-clear accent slashes.
  - [x] Verified the regression fails before implementation and passes after implementation.
  - [x] `python3 -m pytest tests/test_arcade_aesthetics.py::test_result_screens_use_canted_arcade_overlay tests/test_runtime_smoke.py::test_stage_one_title_to_victory_flow tests/test_runtime_smoke.py::test_stage_one_restart_and_return_to_title_flow -q` passes.
  - [x] `bash scripts/check.sh` passes with 70 tests and Godot runtime smoke.
  - [x] `bash scripts/package_macos.sh` regenerated `build/macos/Rift Road.zip`.
  - [x] `bash scripts/smoke_exported_macos_app.sh` reports `RIFT_ROAD_EXPORTED_APP_SMOKE ok` and refreshed the exported-app smoke screenshots.
  - [x] Manual visual inspection of `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-stage-clear.png` confirms Stage Clear now uses a framed arcade result treatment and keeps text readable; this is incremental polish, not final result-screen art.
- Progress:
  - 2026-05-10: Improved the launched Stage Clear screen's presentation while preserving the existing wrapped story copy and next-stage prompt.
- Dependencies: [RR-PROD-33]
- Completed: 2026-05-10

### [RR-PROD-33] Polish title-screen branded lockup
- Outcome: Replaced the plain title headline treatment with a branded procedural Rift Road logo lockup, rift crack, subtitle ribbon, and start plate while preserving title input and flow behavior.
- Validation:
  - [x] Added a regression that `AppRoot` builds a visible title logo lockup with title shadow, rift crack, subtitle ribbon, and start plate.
  - [x] Verified the regression fails before implementation and passes after implementation.
  - [x] Updated the runtime smoke contract to verify the title logo group instead of requiring the shared flow label to contain the title text.
  - [x] `python3 -m pytest tests/test_arcade_aesthetics.py::test_title_screen_has_arcade_presentation tests/test_arcade_aesthetics.py::test_hero_select_cards_use_canted_arcade_frames tests/test_arcade_aesthetics.py::test_title_screen_uses_branded_logo_lockup tests/test_runtime_smoke.py::test_character_select_preview_starts_selected_hero tests/test_runtime_smoke.py::test_stage_one_title_to_victory_flow tests/test_runtime_smoke.py::test_stage_one_restart_and_return_to_title_flow -q` passes.
  - [x] `bash scripts/check.sh` passes with 69 tests and Godot runtime smoke.
  - [x] `bash scripts/package_macos.sh` regenerated `build/macos/Rift Road.zip`.
  - [x] `bash scripts/smoke_exported_macos_app.sh` reports `RIFT_ROAD_EXPORTED_APP_SMOKE ok` and refreshed the exported-app smoke screenshots.
  - [x] Manual visual inspection of `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-title.png` confirms the title now reads as branded UI instead of only centered text; this is incremental polish, not final key art.
- Progress:
  - 2026-05-10: Improved the launched title screen's first impression while keeping the current Rift Road identity and control prompts.
- Dependencies: [RR-PROD-32]
- Completed: 2026-05-10

### [RR-PROD-32] Polish hero-select arcade card presentation
- Outcome: Reworked the hero-select cards from flat prototype panels into canted arcade cards with selected-card glow, portrait wells, planned-hero silhouettes, neon edges, and stat pips while preserving current hero-select controls and behavior.
- Validation:
  - [x] Added a regression that `AppRoot` builds canted hero-select card frames, portrait wells, planned-hero silhouettes, selected-card glow, and stat pips.
  - [x] Verified the regression fails before implementation and passes after implementation.
  - [x] `python3 -m pytest tests/test_arcade_aesthetics.py::test_title_screen_has_arcade_presentation tests/test_arcade_aesthetics.py::test_hero_select_cards_use_canted_arcade_frames tests/test_runtime_smoke.py::test_character_select_preview_starts_selected_hero tests/test_runtime_smoke.py::test_stage_one_title_to_victory_flow -q` passes.
  - [x] `bash scripts/check.sh` passes with 68 tests and Godot runtime smoke.
  - [x] `bash scripts/package_macos.sh` regenerated `build/macos/Rift Road.zip`.
  - [x] `bash scripts/smoke_exported_macos_app.sh` reports `RIFT_ROAD_EXPORTED_APP_SMOKE ok` and refreshed the exported-app smoke screenshots.
  - [x] Manual visual inspection of `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-hero-select.png` confirms the hero-select cards read less like flat placeholder panels; this is incremental polish, not a north-star visual match.
- Progress:
  - 2026-05-10: Improved the launched hero-select card treatment to better match the Stage 1 HUD/interface family while keeping current roster behavior intact.
- Dependencies: [RR-PROD-22]
- Completed: 2026-05-10

### [RR-PROD-31] Reduce Stage 1 intro banner occlusion
- Outcome: Tuned the Stage 1 intro banner into a shorter, lighter strap so the launched-game gameplay capture preserves more background and combat-plane visibility while retaining the round/objective text.
- Validation:
  - [x] Added a regression that Stage 1 stage-card constants keep the intro banner below the top HUD and below the previous large overlay height.
  - [x] `python3 -m pytest tests/test_brawler_presentation.py::test_stage_intro_banner_preserves_combat_plane tests/test_brawler_presentation.py::test_audio_and_cinematic_polish_have_named_placeholder_hooks -q` passes.
  - [x] `bash scripts/check.sh` passes with 67 tests and Godot runtime smoke.
  - [x] `bash scripts/package_macos.sh` regenerated `build/macos/Rift Road.zip`.
  - [x] `bash scripts/smoke_exported_macos_app.sh` reports `RIFT_ROAD_EXPORTED_APP_SMOKE ok` and refreshed the exported-app smoke screenshots.
  - [x] Manual visual inspection of `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-gameplay.png` confirms the stage intro banner is shorter/lighter and less occlusive than the previous broad overlay; this is incremental polish, not a north-star visual match.
- Progress:
  - 2026-05-10: Reduced the opening Stage 1 banner's combat-plane coverage after comparing the exported-app capture against the north-star reference.
- Dependencies: [RR-PROD-24]
- Completed: 2026-05-10

### [RR-PROD-30] Add physical controller evidence gate command
- Outcome: Added a repeatable controller-evidence verifier so release-candidate status is mechanically blocked until two real controller families plus keyboard fallback are tested on the exported macOS app.
- Validation:
  - [x] `scripts/check_controller_evidence.sh` reports `RIFT_ROAD_CONTROLLER_EVIDENCE blocked` while `docs/controller_validation.md` only has templates.
  - [x] `docs/controller_validation.md` defines the required controller family, device name, evidence capture, title, hero select, Stage 1 movement, attack, jump, special, dash, pause, and cancel/back checks.
  - [x] `scripts/check_release_candidate.sh` includes the controller evidence gate as a release-candidate blocker.
- Progress:
  - 2026-05-10: Converted the physical-controller gap into an executable blocker without claiming simulated Godot joypad events are physical device proof.
- Dependencies: [RR-PROD-12], [RR-PROD-28]
- Completed: 2026-05-10

### [RR-PROD-29] Add second-machine evidence gate command
- Outcome: Added a repeatable clean-machine verifier so release-candidate status is mechanically blocked until a real second Apple Silicon Mac records install and launch proof.
- Validation:
  - [x] `scripts/check_second_machine_evidence.sh` reports `RIFT_ROAD_SECOND_MACHINE_EVIDENCE blocked` while `docs/playtest-captures/second-machine-latest/` has no proof files.
  - [x] `docs/second_machine_validation.md` defines the required host profile, install smoke, Gatekeeper result, and launched-game screenshot artifact names.
  - [x] `scripts/check_release_candidate.sh` includes the second-machine evidence gate as a release-candidate blocker.
- Progress:
  - 2026-05-10: Converted the second-machine install gap into an executable blocker without claiming local-machine package launch is production deployment proof.
- Dependencies: [RR-PROD-20], [RR-PROD-27]
- Completed: 2026-05-10

### [RR-PROD-28] Add playtest evidence gate command
- Outcome: Added a repeatable playtest-evidence verifier so public-playtest-candidate status is mechanically blocked until real external session rows exist.
- Validation:
  - [x] `scripts/check_playtest_evidence.sh` reads `docs/playtest_log.md` and reports `RIFT_ROAD_PLAYTEST_EVIDENCE blocked` while the log only has the template row.
  - [x] The verifier requires at least five completed sessions, one `machine=second-mac` row, two physical `controller-family=<family>` inputs, and majority replay intent before reporting `RIFT_ROAD_PLAYTEST_EVIDENCE public-playtest-candidate`.
  - [x] `scripts/check_release_candidate.sh` includes the playtest evidence gate as a release-candidate blocker.
- Progress:
  - 2026-05-10: Turned the external-session threshold into an executable blocker without inventing player evidence or weakening the marketability standard.
- Dependencies: [RR-PROD-18], [RR-PROD-27]
- Completed: 2026-05-10

### [RR-PROD-27] Add known-tester packet command
- Outcome: Added a repeatable command that creates a known-tester packet for supervised internal sessions while preserving the current public-distribution blockers.
- Validation:
  - [x] `scripts/prepare_known_tester_packet.sh` rebuilds the package, runs validation, captures signing/package/smoke/performance logs, copies evidence directories, and writes `manifest.md`.
  - [x] The packet copies `Rift Road.zip`, `docs/public_playtest_gate.md`, the playtest log template, the market-readiness audit, exported-app smoke captures, performance JSON, and host profile.
  - [x] The packet status remains `internal-only` unless the package audit reaches `RIFT_ROAD_PACKAGE_AUDIT release-candidate`.
- Progress:
  - 2026-05-10: Made the next external-session handoff repeatable without claiming public distribution or market readiness.
- Dependencies: [RR-PROD-26]
- Completed: 2026-05-10

### [RR-PROD-26] Record local Apple Silicon performance host
- Outcome: Recorded the local machine profile behind the current exported-app performance numbers so target-hardware claims are scoped to Apple Silicon Mac A instead of an unnamed dev box.
- Validation:
  - [x] Host commands report `arm64`, `Apple M1`, `iMac21,2`, `16 GB`, macOS `26.5`.
  - [x] Host evidence is recorded in `docs/playtest-captures/performance-host-latest/host-profile.md`.
  - [x] Performance docs and the market-readiness audit distinguish local Apple Silicon Mac A evidence from still-missing second-machine proof.
- Progress:
  - 2026-05-10: Reduced the target-hardware ambiguity without claiming second-machine, packaging, or release-candidate readiness.
- Dependencies: [RR-PROD-25]
- Completed: 2026-05-10

### [RR-PROD-25] Add local fullscreen exported-app performance evidence
- Outcome: Added a separate local fullscreen performance artifact for the packaged macOS app so fullscreen display mode is no longer grouped with windowed-only evidence.
- Validation:
  - [x] Current command: `RIFT_ROAD_PERF_WINDOW_SIZE=1920x1080 RIFT_ROAD_PERF_WINDOW_MODE=fullscreen bash scripts/sample_exported_app_performance.sh build/macos/Rift\ Road.zip docs/playtest-captures/exported-app-performance-fullscreen-latest`
  - [x] Latest local fullscreen result: `avg_ms=1.583`, `max_ms=2.793`, `budget_ms=33.3`, `max_budget_ms=120.0`, `window_size=1920x1080`, `window_mode=fullscreen`.
  - [x] `docs/performance_budget.md`, `docs/public_playtest_gate.md`, and the market-readiness audit distinguish local fullscreen evidence from still-missing target-hardware and second-machine proof.
- Progress:
  - 2026-05-10: Reduced the rendered-app display-mode evidence gap without claiming target hardware, second-machine, or release-candidate readiness.
- Dependencies: [RR-PROD-23]
- Completed: 2026-05-10

### [RR-PROD-24] Add launched-app Stage Clear proof
- Outcome: Extended the exported-app smoke path so the packaged app now captures a Stage Clear viewport after fast-forwarding the actual Stage 1 wave and boss-complete path.
- Validation:
  - [x] `AppRoot` writes `stage1-exported-app-smoke-stage-clear.png` from the launched exported app after reaching `stage_clear`.
  - [x] `scripts/smoke_exported_macos_app.sh` waits for and validates title, hero-select, gameplay, and Stage Clear PNGs.
  - [x] Stage Clear result UI hides stale hero-select cards, renders above stage combat FX, and wraps long story text inside the viewport.
  - [x] Current command result: `RIFT_ROAD_EXPORTED_APP_SMOKE ok`.
- Progress:
  - 2026-05-10: Closed the evidence gap where repeatable launched-app smoke proved Stage 1 start but not the Stage Clear presentation path; the first capture exposed result-screen card/layer/text issues, which are now covered by runtime regressions.
- Dependencies: [RR-PROD-22]
- Completed: 2026-05-10

### [RR-PROD-23] Add exported-app windowed performance mode evidence
- Outcome: The exported-app performance sampler can now request and record window size/mode, so local 1280x720 and 1920x1080 windowed Stage 1 samples are distinguishable in the JSON evidence.
- Validation:
  - [x] `scripts/sample_exported_app_performance.sh` accepts `RIFT_ROAD_PERF_WINDOW_SIZE` and `RIFT_ROAD_PERF_WINDOW_MODE`.
  - [x] `AppRoot` supports `--rift-road-render-perf-window-size=...` and `--rift-road-render-perf-window-mode=...`.
  - [x] `stage1-exported-performance.json` includes `window_size` and `window_mode`.
  - [x] Current 1280x720 windowed result: `avg_ms=1.476`, `max_ms=1.515`, `budget_ms=33.3`, `max_budget_ms=120.0`.
  - [x] Current 1920x1080 windowed result: `avg_ms=3.199`, `max_ms=6.652`, `budget_ms=33.3`, `max_budget_ms=120.0`.
- Progress:
  - 2026-05-10: Added a local windowed 1080p performance path without claiming fullscreen, target-hardware, or second-machine coverage.
- Dependencies: [RR-PROD-21]
- Completed: 2026-05-10

### [RR-PROD-22] Add repeatable launched-app hero-select proof
- Outcome: Extended the exported-app smoke path so the current packaged app now captures title, hero-select, and Stage 1 gameplay viewports from the running exported app.
- Validation:
  - [x] `AppRoot` writes `stage1-exported-app-smoke-hero-select.png` after showing the hero-select screen in the launched-app smoke flow.
  - [x] `scripts/smoke_exported_macos_app.sh` waits for and validates title, hero-select, and gameplay PNGs.
  - [x] Current command result: `RIFT_ROAD_EXPORTED_APP_SMOKE ok`.
  - [x] Latest hero-select proof shows Raya with orange mechanic art and Nika with violet scout art: [`docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-hero-select.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-hero-select.png).
- Progress:
  - 2026-05-10: Closed the evidence gap where the repeatable smoke script skipped hero-select even though the active visual goal requires title, hero select, HUD, and menus to belong to the same polished interface family.
- Dependencies: [RR-PROD-17]
- Completed: 2026-05-10

### [RR-PROD-21] Add launched-app performance sample
- Outcome: Added a packaged-app performance sampler so Stage 1 frame timing can be measured from the real exported macOS app, not only a headless runner.
- Validation:
  - [x] `scripts/sample_exported_app_performance.sh` exists and is executable.
  - [x] `AppRoot` supports `--rift-road-render-perf-sample` and writes a JSON timing artifact through `--rift-road-render-perf-output=...`.
  - [x] The script reports `RIFT_ROAD_EXPORTED_PERF stage1` when the app stays within the current frame budget.
  - [x] Latest local result: `avg_ms=1.476`, `max_ms=1.515`, `budget_ms=33.3`, `max_budget_ms=120.0`, after 8 startup/render warmup frames.
  - [x] `scripts/check_release_candidate.sh` includes the exported-app performance sample.
- Progress:
  - 2026-05-10: Added rendered-app performance evidence path and wired it into the release-candidate gate.
- Dependencies: [RR-PROD-19]
- Completed: 2026-05-10

### [RR-PROD-20] Add macOS signing preflight
- Outcome: Added a signing/notarization preflight that checks non-secret release prerequisites and blocks until real Developer ID/notary configuration exists.
- Validation:
  - [x] `scripts/check_macos_signing_env.sh` exists and is executable.
  - [x] The script checks `RIFT_ROAD_APPLE_TEAM_ID`, `RIFT_ROAD_DEVELOPER_ID_APPLICATION`, `RIFT_ROAD_NOTARY_KEYCHAIN_PROFILE`, keychain codesigning identities, `xcrun notarytool`, and Godot export-preset signing/notarization fields.
  - [x] Current command result: `RIFT_ROAD_SIGNING_PREFLIGHT blocked`.
  - [x] `scripts/check_release_candidate.sh` includes the signing preflight as a release-candidate blocker.
- Progress:
  - 2026-05-10: Converted signing/notary ambiguity into explicit missing prerequisites without committing or printing secret material.
- Dependencies: [RR-PROD-19]
- Completed: 2026-05-10

### [RR-PROD-19] Add release-candidate gate command
- Outcome: Added a single release-gate command that runs the automated validation stack and refuses a release-candidate result while package or market-evidence blockers remain.
- Validation:
  - [x] `scripts/check_release_candidate.sh` exists and is executable.
  - [x] The script runs `scripts/check.sh`, `scripts/package_macos.sh`, `scripts/audit_macos_package.sh`, `scripts/smoke_exported_macos_app.sh`, and `stage1_performance_sample`.
  - [x] Current command result: `RIFT_ROAD_RELEASE_GATE blocked`.
  - [x] Docs explain that this is a blocker, not a release approval.
- Progress:
  - 2026-05-10: The gate blocks on the current internal-only package audit plus market-readiness rows that still mark public playtest and player-love evidence as not achieved.
- Dependencies: [RR-PROD-18]
- Completed: 2026-05-10

### [RR-PROD-18] Define public playtest evidence gate
- Outcome: Added a public playtest packet that turns the marketability question into repeatable external session evidence instead of internal opinion.
- Validation:
  - [x] `docs/public_playtest_gate.md` names the build under test, package state, preflight commands, session flow, evidence threshold, interview prompts, and no-claim rules.
  - [x] `docs/playtest_log.md` links to the protocol.
  - [x] `docs/market-readiness-audit-2026-05-10.md` distinguishes having the protocol from having actual external player evidence.
- Progress:
  - 2026-05-10: Added a 5 to 8 external sessions threshold, replay intent/willingness-to-pay prompts, and explicit labels for internal vertical slice through marketable claim.
- Dependencies: [RR-PROD-17]
- Completed: 2026-05-10

### [RR-PROD-17] Add repeatable exported-app launch smoke
- Outcome: Added a local macOS smoke script that extracts the exported zip, launches the `.app`, captures title and Stage 1 viewport screenshots from the running exported app, and reports a stable success marker.
- Validation:
  - [x] Script exists and is executable at `scripts/smoke_exported_macos_app.sh`.
  - [x] Script uses the exported `build/macos/Rift Road.zip`, LaunchServices, and the app's `--rift-road-smoke-capture-dir=...` viewport capture hook.
  - [x] Current command result: `RIFT_ROAD_EXPORTED_APP_SMOKE ok`.
  - [x] Captures are recorded under `docs/playtest-captures/exported-app-smoke-latest/`.
- Progress:
  - 2026-05-10: Added repeatable launched-app proof so local package launch/capture is no longer only an ad hoc manual sequence.
- Dependencies: [RR-PROD-13]
- Completed: 2026-05-10

### [RR-PROD-16] Add repeatable Stage 1 performance sample
- Outcome: Added a Godot runtime performance sample for the Stage 1 autoplay slice and documented the current headless timing budget.
- Validation:
  - [x] `stage1_performance_sample` emits `RIFT_ROAD_PERF stage1`.
  - [x] Latest local result: `avg_ms=16.592`, `max_ms=23.251`, `budget_ms=33.3`, `max_budget_ms=120.0`.
  - [x] The performance sample exits cleanly without the previous unparented helper leak.
  - [x] `docs/performance_budget.md` records the budget, interpretation, and remaining rendered-app gaps.
- Progress:
  - 2026-05-10: Converted `VisualAssetLoader` from `Node` to `RefCounted` so helper instances do not leak during runtime sampling.
- Dependencies: [RR-PROD-12]
- Completed: 2026-05-10

### [RR-PROD-12] Add baseline controller support
- Outcome: Keyboard remains supported while a standard gamepad mapping can move, attack, jump, special, dash, pause, cycle heroes, cancel/back, and advance title/hero/start flows.
- Validation:
  - [x] Runtime controller title -> hero select -> Stage 1 -> pause/resume flow is covered by `controller_title_flow`.
  - [x] Static coverage verifies player combat controller hooks and visible gamepad prompts.
  - [x] UI prompts now expose both keyboard and gamepad controls without removing keyboard labels.
- Progress:
  - 2026-05-10: Added joypad button handling in `AppRoot`, controller movement/combat helpers in `PlayerController`, a Godot runtime smoke mode, and docs for the baseline mapping. Physical controller-device testing remains a later gate.
- Dependencies: [RR-PROD-11]
- Completed: 2026-05-10

### [RR-PROD-13] Add macOS package readiness audit
- Outcome: Added `scripts/audit_macos_package.sh` to inspect the exported zip, bundle metadata, codesign verification, Developer ID authority, export-preset signing fields, Gatekeeper assessment, and notarization ticket status.
- Validation:
  - [x] Audit command reports package structure and release-gate warnings instead of silently treating the local zip as production-ready.
  - [x] Current command result: `RIFT_ROAD_PACKAGE_AUDIT internal-only`.
  - [x] `docs/macos_build_and_distribution.md` reflects the current internal-only release gate.
  - [x] Targeted script/doc tests pass.
- Progress:
  - 2026-05-10: The current bundle signature verifies, but the audit reports no Developer ID authority, empty Apple Team ID, empty signing identity, disabled notarization, Gatekeeper rejection, and no valid stapled ticket.
- Dependencies: [RR-PROD-11]
- Completed: 2026-05-10

### [RR-PROD-11] Tune Stage 1 opening fight for marketability
- Outcome: Reduced the Stage 1 opening wave from a six-enemy pileup with a ranged harasser to a four-enemy onboarding fight, while preserving total stage density by moving the extra pressure into wave 2.
- Validation:
  - [x] Added a regression test that Stage 1 opens with a readable onboarding wave and escalates later.
  - [x] `bash scripts/check.sh` passes with 58 tests and Godot runtime smoke.
  - [x] `bash scripts/package_macos.sh` regenerated `build/macos/Rift Road.zip`.
  - [x] Fresh exported-app proof captures show title, Stage 1, and manual-input state from the rebuilt zip.
- Progress:
  - 2026-05-10: Manual exported-app playtest showed the earlier opening fight could drain health too quickly; the fix keeps the first fight readable without reducing later-stage intensity.
- Dependencies: [RR-PROD-10]
- Completed: 2026-05-10

### [RR-PROD-10] Capture proof for handoff
- Outcome: Saved gameplay screenshots and a handoff note describing what works, what is still placeholder, and what comes next.
- Validation:
  - [x] Artifact path is recorded in this tracker: [`docs/playtest-captures/stage1-marketability-handoff-2026-05-10.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-marketability-handoff-2026-05-10.md).
  - [x] Summary is suitable for a quick user handoff and explicitly avoids claiming commercial proof without external player evidence.
- Dependencies: [RR-PROD-09]
- Completed: 2026-05-10

### [RR-PROD-09] Package the macOS vertical slice
- Outcome: Produced `build/macos/Rift Road.zip` for the team-review prototype.
- Validation:
  - [x] `bash scripts/check.sh` passes.
  - [x] `bash scripts/package_macos.sh` creates `build/macos/Rift Road.zip` (73 MB, regenerated 2026-05-10).
- Progress:
  - 2026-05-10: Rebuilt the macOS package after the HUD, Stage 1, combat, flow, and audio/cinematic polish passes.
- Dependencies: [RR-PROD-08]
- Completed: 2026-05-10

### [RR-PROD-08] Add audio and cinematic polish pass
- Outcome: Added named procedural placeholder audio cues for stage start, waves, boss intro, stage clear, hits, UI, and victory; shortened cinematic banner body copy; and added banner capture proof.
- Validation:
  - [x] Audio manager has clear stage, boss, hit, UI, and victory hooks.
  - [x] Cinematic banners are readable and short: [`docs/playtest-captures/stage1-cinematic-banner-proof.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-cinematic-banner-proof.png).
  - [x] Placeholder provenance is documented in [`docs/asset_provenance_register.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/asset_provenance_register.md).
- Progress:
  - 2026-05-10: Added named generated-tone/chord hooks, wired stage/boss/clear cues, shortened banner copy, and documented the procedural placeholder audio source.
- Dependencies: [RR-PROD-07]
- Completed: 2026-05-10

### [RR-PROD-07] Polish HUD for arcade readability
- Outcome: Improved player name, health, special meter, score/luma, objective, combo, and boss-bar presentation through the premium HUD pass and verified the boss HUD at 1280x720.
- Focus: Original arcade cabinet readability at 1280x720 without copying existing arcade HUD layouts.
- Validation:
  - [x] HUD is readable in a 1280x720 screenshot: [`docs/playtest-captures/stage1-boss-hud-readability-proof.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-boss-hud-readability-proof.png).
  - [x] Boss bar and objective text do not overlap the main combat actors in the boss HUD proof.
- Progress:
  - 2026-05-10: Captured a fresh boss HUD readability proof after replacing capture-only objective text with product-facing copy.
- Dependencies: [RR-PROD-06]
- Completed: 2026-05-10

### [RR-PROD-06] Make Stage 1 flow reliable
- Outcome: Added explicit Stage Clear and Game Over handoff controls for continuing, restarting the current or last completed stage, and returning to title without relying on debug-only paths.
- Validation:
  - [x] Full Stage 1 runtime flow reaches Stage Clear without script errors through `stage1_flow`.
  - [x] Restart and return-to-title path works after victory or failure through `stage1_restart_flow`.
- Progress:
  - 2026-05-10: Added restart/title flow methods in `AppRoot` and a Godot runtime smoke mode that verifies Stage Clear restart, Game Over restart, and return-to-title cleanup.
- Dependencies: [RR-PROD-05]
- Completed: 2026-05-10

### [RR-PROD-05] Improve fight readability and impact
- Outcome: Added a layered non-bloody impact burst with hit-stop flash, timing ring, directional speed lines, stronger combat proof capture, and StageManager wiring for player and enemy hit feedback.
- Validation:
  - [x] Combat screenshot shows readable impact timing and feedback: [`docs/playtest-captures/stage1-combat-impact-proof.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-combat-impact-proof.png).
  - [x] Basic input buffering remains present through attack and special buffer timers in `PlayerController`; `tests/test_brawler_presentation.py` covers those runtime hooks.
  - [x] Hit effects remain original and non-bloody, using gold, luma, white, and smoke impact colors.
- Progress:
  - 2026-05-10: Added tested layered impact effects in `ArcadeCombatFx`, wired them into `StageManager`, and added an impact capture mode for screenshot proof.
- Dependencies: [RR-PROD-04]
- Completed: 2026-05-10

### [RR-PROD-04] Build a jungle-road ruins Stage 1 presentation pass
- Outcome: Added original additive Stage 1 set dressing over the asset-backed background: ruined overpass signs, transport cage silhouettes, luma plant clusters, road rubble, and playfield depth cues.
- Validation:
  - [x] `godot --path src/wildcoil --headless --quit-after 3` launches without script errors.
  - [x] Captured gameplay screenshot shows visible stage layers and road depth: [`docs/playtest-captures/stage1-jungle-road-ruins-pass.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-jungle-road-ruins-pass.png).
- Progress:
  - 2026-05-10: Added tested Stage 1 set-dressing builders in `StageManager` and captured a fresh 1280x720 runtime proof image.
- Dependencies: [RR-PROD-03]
- Completed: 2026-05-10

### [RR-PROD-03] Push the visual style toward modern retro-action readability
- Outcome: Added premium HUD framing, asset-backed hero portrait treatment, segmented health/special meters, low-health warning strip, subtle sunset/fight-plane/luma grading, and readability lane cues so Stage 1 reads closer to modern retro-action presentation.
- Focus: Original modern retro-action presentation without copying any existing game characters, UI, stages, sprites, logos, or layouts.
- Validation:
  - [x] `python3 -m pytest tests/test_visual_content.py -v` passes.
  - [x] `python3 -m pytest tests/test_arcade_aesthetics.py -v` passes.
  - [x] Headless Godot launch succeeds after style changes.
  - [x] Runtime capture shows the readability pass: [`docs/playtest-captures/stage1-premium-readability-pass.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-premium-readability-pass.png).
- Progress:
  - 2026-05-10: Added tested premium readability hooks in `HUDController` and `StageManager`, then captured a fresh 1280x720 Stage 1 proof image.
- Dependencies: [RR-PROD-02]
- Completed: 2026-05-10

### [RR-PROD-02] Convert placeholder characters toward human arcade sprites
- Outcome: Improved Raya, Nika, enemies, and Brask so they read as human or humanoid arcade characters instead of simple blocks.
- Focus: Heads, torsos, arms, legs, stances, outlines, attack poses, and body proportions visible at gameplay zoom.
- Validation:
  - [x] Screenshot review shows each actor has a readable body shape at 1280x720. Raya, Iron Veil enemies, and creature/humanoid silhouettes are shown in [`docs/playtest-captures/stage1-cinematic-motion-slice.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-cinematic-motion-slice.png); Nika and Brask are shown in [`docs/playtest-captures/stage1-nika-brask-boss-proof.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-nika-brask-boss-proof.png).
  - [x] No copied character sprites, names, costumes, or poses were introduced; this pass changed presentation code and capture tooling only, with no new actor art assets.
- Progress:
  - 2026-05-10: Added a presentation-only cinematic motion pass for players, enemies, and Brask using contact shadows, state afterimages, frame-stepped arcs, hurt/telegraph highlights, and boss phase/stun motion details. This improves motion readability without changing hitboxes, AI, waves, story, or controls.
  - 2026-05-10: Packaged the current single-app macOS build at `build/macos/Rift Road.zip` and verified the exported app opens, reaches hero select, starts Stage 1, and accepts attack input through Computer Use.
  - 2026-05-10: Added an explicit Nika-vs-Brask runtime capture path and saved [`docs/playtest-captures/stage1-nika-brask-boss-proof.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-nika-brask-boss-proof.png).
- Dependencies: [RR-PROD-01]
- Completed: 2026-05-10

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
