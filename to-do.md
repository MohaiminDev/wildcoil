# Rift Road Task Tracker

## Project Goal

Make the running Godot game feel like a polished Stage 1 episode of `Rift Road: Beasts of the Afterglow`: a modern cinematic 2D arcade brawler that looks alive, feels responsive, runs well on the target M1 iMac, and keeps the repair-versus-extraction story clear through play.

The current build can prove flow, combat scaffolding, packaging, and several launched-game presentation passes, but it still does not satisfy the updated 2026-05-11 slice spec. The next work must prioritize physical-device validation, clean-machine/release validation, and real playtest evidence before any broader market-facing claim.

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

The playable path is: title screen, hero select, Stage 1 opening Raya/Nika story panels, Raya/Nika combat, readable enemy waves, simple pickups, road-collapse set piece into a lower service-lane beat, Brask Noll boss with readable heavy-attack/stun lesson, Brask escape and route-to-Glassleaf consequence, Stage Clear score/rank summary, restart or return-to-title flow, and packaged macOS zip.

The visual target is the approved north-star direction: modern stylized arcade realism with pixel-art-inspired readability, cinematic sunset highway ruins, jungle depth, luma glow, dramatic sparks and dust, strong silhouettes, clean premium HUD and menus, no modern 3D realism, no generic cyberpunk drift, and no copied characters, UI, layouts, stages, sprites, logos, vehicles, or music from existing games.

## Current Truth

- Mechanically playable prototype: yes.
- Production-grade visual/UI match to north-star images: no.
- Manual playtest evidence: current Codex run opened the rebuilt exported macOS app through LaunchServices, advanced title -> hero select -> Stage 1 with real key input, and sent movement/attack input while the easier four-enemy opening wave stayed playable with health/HUD visible.
- Controller/keyboard baseline: simulated Godot runtime smoke covers controller title -> hero select -> Stage 1 and pause/resume; `controller_hotplug_status` covers the controller connection/disconnection status path; a keyboard-fallback runtime smoke covers title -> hero select -> preview cancel -> Stage 1 plus movement, attack, jump, special, dash, and pause/resume; and the exported-app keyboard smoke records the same keyboard path from the launched zipped app as automated JSON/capture evidence. Gameplay code supports keyboard movement/actions and left stick/D-pad movement plus X/A/Y/B/LB/RB/Start actions. A 2026-05-12 launched-app keyboard menu pass fixed text-style `j` confirm from hero preview to Stage 1, with evidence in `docs/playtest-captures/controller/20260512-keyboard-menu-confirm.md`; physical controller devices and a complete manual exported-app keyboard fallback row are still not tested yet.
- Controller evidence gate: `bash scripts/check_controller_evidence.sh` reads `docs/controller_validation.md` and currently reports `RIFT_ROAD_CONTROLLER_EVIDENCE blocked` because no physical controller-family sessions have been recorded. The gate now rejects marked sessions with missing or `TBD` build/device/connection/evidence/blocker metadata, and also blocks `Evidence capture` paths that do not point at real non-empty files, so placeholder rows cannot satisfy the manual evidence requirement.
- Controller evidence collector: `bash scripts/collect_controller_evidence.sh --help` now generates manual evidence notes and paste-ready session snippets for real exported-app controller or keyboard fallback sessions, records the selected signed package when available, but does not turn the gate green without actual tester-confirmed rows.
- Latest capture note: the exported macOS app supports a repeatable launched-app viewport smoke capture path that is not dependent on the current macOS Space being visible to `screencapture`; the latest title smoke capture now shows a branded Rift Road logo lockup and start plate, the latest hero-select smoke capture shows canted arcade cards, selected-card glow, portrait wells, planned-hero silhouettes, stat pips, and a canted arcade header/ribbon instead of plain heading text, the latest opening-story smoke capture shows a short Raya/Nika story panel about drill marks, cages, and route stakes, the latest gameplay capture shows the Stage 1 intro as a centered slim strap above the combatants with non-ellipsized `Free the transport cages` copy plus a slimmer top HUD that exposes more sunset/backdrop area, the latest post-intro combat capture shows the running fight after the intro strap has cleared with a one-line objective rail and no stale center wave notice, the latest pickup smoke capture shows distinct health and luma/meter pickup markers from the launched exported app, the latest road-collapse smoke capture shows luma fractures and the exposed service lane after the opening cage-loading fight, the latest Brask intro smoke capture shows the boss story banner from the launched exported app, the latest Stage Clear smoke capture shows rank, score, luma, and health summary text in the canted arcade result frame, the Game Over/retry smoke capture shows the fail-state result text and controls, and the post-retry smoke capture shows Stage 1 gameplay after restarting from the Game Over path.
- Package audit: `bash scripts/audit_macos_package.sh` reports `RIFT_ROAD_PACKAGE_AUDIT internal-only`; the bundle signature verifies, but Developer ID authority, Apple Team ID, notarization, Gatekeeper acceptance, and stapled ticket validation are not present.
- Godot version gate: `bash scripts/check_godot_version.sh` now requires the configured `GODOT_BIN` to report Godot 4.6.x stable before `bash scripts/check.sh` runs tests and runtime smoke.
- Signing preflight/release script: `bash scripts/check_macos_signing_env.sh` reports `RIFT_ROAD_SIGNING_PREFLIGHT blocked`; required non-secret inputs are `RIFT_ROAD_APPLE_TEAM_ID`, `RIFT_ROAD_DEVELOPER_ID_APPLICATION`, and `RIFT_ROAD_NOTARY_KEYCHAIN_PROFILE`. `docs/macos_release_inputs.example.env` now provides a redacted local setup template; real values must stay outside version control. `bash scripts/sign_notarize_macos.sh` now defines the guarded `build/macos/Rift Road-signed-notarized.zip` path, but currently reports `RIFT_ROAD_RELEASE_SIGNING blocked` until real local Apple signing/notary inputs exist.
- Second-machine evidence: `bash scripts/check_second_machine_evidence.sh` reads `docs/playtest-captures/second-machine-latest/` and currently reports `RIFT_ROAD_SECOND_MACHINE_EVIDENCE blocked` because no clean-machine proof files have been recorded. `bash scripts/collect_second_machine_evidence.sh` is now bundled for known testers so the real second Mac can generate the expected host profile, package audit log, install-smoke note, and title/gameplay captures from either `Rift Road-signed-notarized.zip` or `Rift Road.zip`, but it still requires actual second-machine execution and release-candidate package/Gatekeeper evidence.
- Exported-app smoke: `bash scripts/smoke_exported_macos_app.sh` extracts `build/macos/Rift Road.zip`, launches the `.app` with `--rift-road-smoke-stage1` and `--rift-road-smoke-capture-dir=...`, captures title, hero-select, opening story, Stage 1 gameplay, post-intro combat, pickup clarity, road-collapse, Stage Clear, Game Over/retry, and post-retry gameplay viewport screenshots from the running exported app, and reports `RIFT_ROAD_EXPORTED_APP_SMOKE ok`. The exported-app smoke, keyboard fallback smoke, and focus/resume smoke scripts now use staged capture replacement so a launch failure preserves the previous latest evidence files until a validated replacement exists. `bash scripts/smoke_exported_focus_resume.sh` records automated exported-app focus/resume JSON plus a pause-overlay viewport capture and reports `RIFT_ROAD_EXPORTED_FOCUS_RESUME ok`.
- Exported-app performance: `bash scripts/sample_exported_app_performance.sh` launches the packaged `.app`, records `docs/playtest-captures/exported-app-performance-latest/stage1-exported-performance.json`, and reports `RIFT_ROAD_EXPORTED_PERF stage1` on local Apple Silicon Mac A (`arm64`, `Apple M1`, `iMac21,2`) with latest local 1280x720 windowed steady-state result `avg_ms=14.293`, `max_ms=30.565` after 8 startup/render warmup frames. A local 1920x1080 windowed run records `avg_ms=3.199`, `max_ms=6.652` in `docs/playtest-captures/exported-app-performance-windowed-1080p-latest/stage1-exported-performance.json`, and a local fullscreen run records `avg_ms=1.583`, `max_ms=2.793` in `docs/playtest-captures/exported-app-performance-fullscreen-latest/stage1-exported-performance.json`.
- Focus-loss/resume: `stage1_focus_resume` in `src/wildcoil/tools/runtime_test_runner.gd` proves Stage 1 pauses on window focus loss, shows the pause overlay while the title layer is otherwise hidden, suspends/resumes the audio manager focus state, updates the return-focus message, and resumes cleanly with Esc. The exported-app focus/resume smoke proves the same app handler path from the launched zip, but not real audible output.
- Focus/audio evidence gate: `bash scripts/check_focus_audio_evidence.sh` reads `docs/focus_audio_validation.md` and currently reports `RIFT_ROAD_FOCUS_AUDIO_EVIDENCE blocked` because no manual audible focus-loss/resume session has been recorded. `bash scripts/collect_focus_audio_evidence.sh --help` now generates manual evidence notes and paste-ready session snippets for real exported-app focus/audio sessions, records the selected signed package when available, but it does not turn the gate green without actual human-confirmed audible output.
- Release-candidate gate: `bash scripts/check_release_candidate.sh` combines checks, package, release signing/notarization, audit, exported-app smoke, exported-app keyboard fallback smoke, exported-app focus/resume smoke, manual focus/audio evidence, and performance sample, writes `build/release-gate/latest/completion-audit.md` with an explicit Godot version-gate row from `logs/check.log`, then reports `RIFT_ROAD_RELEASE_GATE blocked` until package and player-evidence gates are resolved. If a required automated command hard-fails, the gate now records that command as a blocker and writes the completion audit before exiting with the original failing status.
- Known-tester packet: `bash scripts/prepare_known_tester_packet.sh` creates `build/known-tester-packet/latest/` with the selected zip, manifest, build commit, package SHA-256, Godot version-gate marker, validation logs, release signing status/log, package audit, smoke captures, keyboard fallback evidence, focus/resume evidence, performance JSON, host profile, second-machine evidence collector scripts, focus/audio evidence collector scripts, playtest docs, and manual gate statuses/logs for supervised known-tester sessions. It copies `Rift Road-signed-notarized.zip` when release signing succeeds and the artifact exists; otherwise it keeps using the current internal-only `Rift Road.zip`.
- Playtest evidence gate: `bash scripts/check_playtest_evidence.sh` reads `docs/playtest_log.md` and currently reports `RIFT_ROAD_PLAYTEST_EVIDENCE blocked` because no external session rows have been recorded. The gate now rejects counted rows unless their `Evidence capture` path points at a real, non-empty file.
- Playtest evidence collector: `bash scripts/collect_playtest_evidence.sh --help` now generates a non-empty session note and paste-ready `docs/playtest_log.md` row after a real external-style session, records the selected signed package when available, but it does not append rows or satisfy the gate without actual tester evidence.
- 2026-05-11 spec/story realignment: [`docs/game_spec.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/game_spec.md) and [`docs/game-story.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/game-story.md) now make the first success condition feel-focused, not market-demand-focused: the Stage 1 slice must feel good, look alive, and be satisfying to replay on an M1 iMac before public-playtest or marketability claims. Current missing spec-critical beats include physical controller/second-machine validation and external playtest evidence.
- Performance sample: `stage1_performance_sample` reports `RIFT_ROAD_PERF stage1` with latest local result `avg_ms=16.726`, `max_ms=40.161`.
- Public playtest gate: [`docs/public_playtest_gate.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/public_playtest_gate.md) defines the external session protocol and explicitly blocks marketable/player-loved claims until external evidence exists.
- Market-readiness audit: [`docs/market-readiness-audit-2026-05-10.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/market-readiness-audit-2026-05-10.md) maps every active marketability requirement to evidence and gaps; the active goal is not complete.
- Current proof artifacts:
  - Cinematic banner proof with shortened round banner copy: [`docs/playtest-captures/stage1-cinematic-banner-proof.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-cinematic-banner-proof.png)
  - Fresh exported macOS app title screenshot from the rebuilt zip: [`docs/playtest-captures/stage1-exported-app-title-window.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-exported-app-title-window.png)
  - Fresh exported macOS app Stage 1 screenshot after title -> hero select -> Stage 1 keyflow: [`docs/playtest-captures/stage1-exported-app-gameplay-window.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-exported-app-gameplay-window.png)
  - Fresh exported macOS app manual input screenshot after movement/attack key input: [`docs/playtest-captures/stage1-exported-app-manual-input-window.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/stage1-exported-app-manual-input-window.png)
  - Repeatable exported-app smoke title screenshot: [`docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-title.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-title.png)
  - Repeatable exported-app smoke hero-select screenshot: [`docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-hero-select.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-hero-select.png)
  - Repeatable exported-app smoke opening-story screenshot: [`docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-opening-story.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-opening-story.png)
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

### [RR-PROD-81] Refresh post-keyboard-fix release-gate evidence
- Outcome: The release-candidate gate was rerun after RR-PROD-80 so the tracked launched-app smoke, keyboard fallback, focus/resume, and exported-app performance evidence reflect the current keyboard input build while preserving the real release blockers.
- Validation:
  - [x] `python3 -m pytest tests/test_scripts_and_docs.py::test_exported_app_performance_docs_match_latest_json -q` failed before the docs update because the refreshed performance JSON reported `avg_ms=14.293` and `max_ms=30.565` while docs still cited the previous sample.
  - [x] `bash scripts/check_release_candidate.sh` ran outside the sandbox, passed the 117-test `bash scripts/check.sh` phase, refreshed launched exported-app smoke, keyboard fallback, focus/resume, and performance evidence, and wrote `build/release-gate/latest/completion-audit.md`.
  - [x] Release gate correctly reported `RIFT_ROAD_RELEASE_GATE blocked` for real signing/notarization, focus/audio, playtest, second-machine, controller, public-playtest, and player-love evidence gaps.
  - [x] Updated `docs/performance_budget.md`, `docs/market-readiness-audit-2026-05-10.md`, `docs/playtest-captures/stage1-marketability-handoff-2026-05-10.md`, and this tracker with the refreshed 1280x720 exported-app performance values.
  - [x] `python3 -m pytest tests/test_scripts_and_docs.py::test_exported_app_performance_docs_match_latest_json -q`
  - [x] `python3 scripts/check_agent_docs.py`
  - [x] `git diff --check`
- Progress:
  - 2026-05-12: Rebased the latest tracked launch evidence on the keyboard-menu-confirm fix without claiming public-playtest or release-candidate readiness.
- Dependencies: [RR-PROD-80]
- Completed: 2026-05-12

### [RR-PROD-80] Normalize text-style keyboard menu confirm
- Outcome: The running Godot app now normalizes menu key events through logical keycode, physical keycode, and selected printable unicode values, so text-style `j` input from the launched exported macOS app can start Stage 1 from the hero capability preview.
- Validation:
  - [x] Reproduced the launched-app issue with Computer Use: title and hero-select text input worked, but `j` did not start Stage 1 from the capability preview before the fix.
  - [x] Added a failing runtime regression for a unicode-only text-style `j` confirm event in `keyboard_text_confirm_flow`.
  - [x] Updated `AppRoot` keyboard menu handling to normalize keycode, physical keycode, and printable unicode values before matching menu actions.
  - [x] `python3 -m pytest tests/test_runtime_smoke.py::test_keyboard_text_confirm_event_starts_stage_one -q` passes.
  - [x] `python3 -m pytest tests/test_runtime_smoke.py::test_keyboard_fallback_title_to_stage_and_action_flow tests/test_runtime_smoke.py::test_keyboard_text_confirm_event_starts_stage_one -q` passes.
  - [x] `bash scripts/package_macos.sh` rebuilt `build/macos/Rift Road.zip`.
  - [x] Launched the rebuilt exported app and verified title -> hero select -> capability preview cancel/back -> `j` starts Stage 1.
  - [x] `bash scripts/smoke_exported_keyboard_fallback.sh build/macos/Rift\ Road.zip /tmp/rift-road-keyboard-text-confirm-verify` reports `RIFT_ROAD_EXPORTED_KEYBOARD_FALLBACK ok`.
  - [x] `bash scripts/check.sh` passes with 117 tests and `RIFT_ROAD_RUNTIME_OK smoke`.
- Progress:
  - 2026-05-12: Closed a real launched-app keyboard menu-confirm gap discovered while trying to reduce RR-PROD-15, without claiming physical controller or full manual keyboard fallback evidence.
- Dependencies: [RR-PROD-15]
- Completed: 2026-05-12

### [RR-PROD-79] Refresh release-gate evidence snapshot
- Outcome: The latest release-candidate audit refreshed tracked launched-app smoke, keyboard fallback, focus/resume, and exported-app performance evidence after RR-PROD-78; current docs now match `docs/playtest-captures/exported-app-performance-latest/stage1-exported-performance.json`.
- Validation:
  - [x] Added a failing docs/artifact regression that reads the latest exported-app performance JSON and requires current docs/tracker to cite the same rounded `avg_ms` and `max_ms` values.
  - [x] Ran `bash scripts/check_release_candidate.sh` outside the sandbox so the launched exported-app smoke, keyboard fallback smoke, focus/resume smoke, exported-app performance sample, and headless performance sample could execute through LaunchServices.
  - [x] Release gate wrote `build/release-gate/latest/completion-audit.md` and correctly reported `RIFT_ROAD_RELEASE_GATE blocked` for real signing/notarization, focus/audio, playtest, second-machine, controller, public-playtest, and player-love evidence gaps.
  - [x] Updated `docs/performance_budget.md`, `docs/market-readiness-audit-2026-05-10.md`, `docs/playtest-captures/stage1-marketability-handoff-2026-05-10.md`, and this tracker with the refreshed 1280x720 exported-app performance values.
  - [x] `python3 -m pytest tests/test_scripts_and_docs.py::test_exported_app_performance_docs_match_latest_json -q` passes.
  - [x] `bash scripts/check.sh` passes with 116 tests and `RIFT_ROAD_RUNTIME_OK smoke`.
- Progress:
  - 2026-05-12: Captured the current release-gate blocker state after staged smoke publishing, while keeping the active goal blocked until real external evidence and signing proof exist.
- Dependencies: [RR-PROD-78]
- Completed: 2026-05-12

### [RR-PROD-78] Preserve smoke evidence on launch failure
- Outcome: Exported-app smoke, exported-app keyboard fallback smoke, and exported-app focus/resume smoke now write artifacts to a temporary staging directory and only replace the published latest capture/JSON evidence after the new artifacts validate, preventing failed launches from erasing the previous evidence set.
- Validation:
  - [x] Added a failing behavioral regression with a fake exported package and failing `open` command that proves existing smoke artifacts survive launch failure.
  - [x] Updated `scripts/smoke_exported_macos_app.sh`, `scripts/smoke_exported_keyboard_fallback.sh`, and `scripts/smoke_exported_focus_resume.sh` to use staged capture replacement before publishing evidence files.
  - [x] Updated macOS distribution, marketability handoff, market-readiness audit, and tracker docs to describe staged capture replacement without claiming new external evidence.
  - [x] `python3 -m pytest tests/test_scripts_and_docs.py::test_exported_app_smoke_scripts_preserve_evidence_on_launch_failure -q` passes.
  - [x] `bash -n scripts/smoke_exported_macos_app.sh`, `bash -n scripts/smoke_exported_keyboard_fallback.sh`, and `bash -n scripts/smoke_exported_focus_resume.sh` pass.
  - [x] `python3 scripts/check_agent_docs.py` passes.
  - [x] `git diff --check` passes.
  - [x] `bash scripts/check.sh` passes with 115 tests and Godot runtime smoke.
- Progress:
  - 2026-05-12: Closed the evidence-preservation gap exposed by a sandboxed launch failure that could delete the latest exported-app smoke captures before replacement proof existed.
- Dependencies: [RR-PROD-77]
- Completed: 2026-05-12

### [RR-PROD-77] Require evidence files for playtest rows
- Outcome: The playtest evidence gate now requires every counted external session row to include an `Evidence capture` path that resolves to a real, non-empty note, screenshot, or video file, so public-playtest-candidate status cannot be reached from pasted table rows alone.
- Validation:
  - [x] Added a failing behavioral regression with a fake five-session playtest log that otherwise satisfies session count, second-Mac, controller-family, and replay-intent thresholds but has one missing evidence capture file.
  - [x] Updated `scripts/check_playtest_evidence.sh` to parse the `Evidence capture` column, resolve absolute and repo-relative paths, report `missing or empty evidence capture` blockers, and include evidence capture counts in its summary.
  - [x] Updated `scripts/collect_playtest_evidence.sh` and `docs/playtest_log.md` so generated rows include the session note as the evidence capture.
  - [x] Updated public playtest, macOS distribution, handoff, audit, and tracker docs to describe the stronger evidence-file requirement without claiming external sessions exist.
  - [x] `python3 -m pytest tests/test_scripts_and_docs.py::test_playtest_evidence_gate_blocks_without_external_sessions tests/test_scripts_and_docs.py::test_playtest_evidence_gate_requires_real_evidence_capture_files tests/test_scripts_and_docs.py::test_playtest_evidence_collector_scaffolds_external_session_notes -q` passes.
  - [x] `bash -n scripts/check_playtest_evidence.sh` and `bash -n scripts/collect_playtest_evidence.sh` pass.
  - [x] `python3 scripts/check_agent_docs.py` passes.
  - [x] `git diff --check` passes.
  - [x] `bash scripts/check.sh` passes with 114 tests and Godot runtime smoke.
- Progress:
  - 2026-05-12: Hardened the public-playtest evidence gate against row-only proof while keeping the current build blocked until real tester evidence exists.
- Dependencies: [RR-PROD-76]
- Completed: 2026-05-12

### [RR-PROD-76] Use selected package in manual evidence collectors
- Outcome: Manual controller, focus/audio, and playtest collectors now prefer the selected signed package when one exists in a build or known-tester packet, fall back to the unsigned zip, and record the package path/SHA in generated evidence notes.
- Validation:
  - [x] Added a failing behavioral regression with a fake known-tester packet root containing only `Rift Road-signed-notarized.zip`.
  - [x] Updated `scripts/collect_controller_evidence.sh`, `scripts/collect_focus_audio_evidence.sh`, and `scripts/collect_playtest_evidence.sh` to use `RIFT_ROAD_PACKAGE_PATH` when set, otherwise prefer `Rift Road-signed-notarized.zip` before `Rift Road.zip`.
  - [x] Updated controller, focus/audio, playtest, public gate, macOS distribution, handoff, audit, and tracker docs to describe selected-package manual evidence collection without claiming any manual evidence has been recorded.
  - [x] `python3 -m pytest tests/test_scripts_and_docs.py::test_focus_audio_evidence_collector_scaffolds_manual_audible_session tests/test_scripts_and_docs.py::test_playtest_evidence_collector_scaffolds_external_session_notes tests/test_scripts_and_docs.py::test_manual_evidence_collectors_default_to_signed_packet_artifact tests/test_scripts_and_docs.py::test_controller_evidence_collector_scaffolds_real_manual_sessions tests/test_scripts_and_docs.py::test_known_tester_packet_script_collects_internal_build_evidence -q` passes.
  - [x] `bash -n scripts/collect_controller_evidence.sh`, `bash -n scripts/collect_focus_audio_evidence.sh`, and `bash -n scripts/collect_playtest_evidence.sh` pass.
  - [x] `python3 scripts/check_agent_docs.py` passes.
  - [x] `git diff --check` passes.
  - [x] `bash scripts/check.sh` passes with 113 tests and Godot runtime smoke.
- Progress:
  - 2026-05-12: Closed the remaining signed known-tester packet friction where manual collectors could hash or block on the wrong zip after release signing.
- Dependencies: [RR-PROD-75]
- Completed: 2026-05-12

### [RR-PROD-75] Use signed artifact in tester packet
- Outcome: The known-tester packet now uses the signed/notarized release artifact when `scripts/sign_notarize_macos.sh` succeeds, hashes that selected artifact, runs artifact audit/smoke/performance checks against it, and leaves the packet marked as non-public until the remaining second-machine, controller, focus/audio, and playtest evidence gates pass.
- Validation:
  - [x] Added a failing behavioral regression with a fake packet workspace where `scripts/sign_notarize_macos.sh` writes `build/macos/Rift Road-signed-notarized.zip` and reports `RIFT_ROAD_RELEASE_SIGNING ok`.
  - [x] Updated `scripts/prepare_known_tester_packet.sh` to select `Rift Road-signed-notarized.zip` after successful release signing, copy it into the packet, record the selected package name/SHA-256, and keep the distribution warning evidence-gated.
  - [x] Updated the second-machine collector/checker to support signed known-tester packet artifacts when real second-machine proof exists.
  - [x] Updated public playtest, macOS distribution, second-machine, handoff, audit, and tracker docs to describe signed-artifact packet selection without claiming public distribution readiness.
  - [x] `python3 -m pytest tests/test_scripts_and_docs.py::test_known_tester_packet_script_collects_internal_build_evidence tests/test_scripts_and_docs.py::test_known_tester_packet_records_release_signing_status tests/test_scripts_and_docs.py::test_known_tester_packet_uses_signed_artifact_when_release_signing_succeeds tests/test_scripts_and_docs.py::test_second_machine_evidence_gate_accepts_signed_package_source tests/test_scripts_and_docs.py::test_second_machine_evidence_collector_is_bundled_for_known_testers -q` passes.
  - [x] `bash -n scripts/prepare_known_tester_packet.sh`, `bash -n scripts/collect_second_machine_evidence.sh`, and `bash -n scripts/check_second_machine_evidence.sh` pass.
  - [x] `python3 scripts/check_agent_docs.py` passes.
  - [x] `git diff --check` passes.
  - [x] `bash scripts/check.sh` passes with 112 tests and Godot runtime smoke.
- Progress:
  - 2026-05-12: Closed the packet handoff gap where successful release signing would be recorded but the known-tester packet would still copy and hash the unsigned zip.
- Dependencies: [RR-PROD-73]
- Completed: 2026-05-12

### [RR-PROD-74] Add focus/audio evidence collector
- Outcome: Manual audible focus-loss/resume sessions now have a collector that writes a non-empty evidence note plus a paste-ready `docs/focus_audio_validation.md` snippet for the existing focus/audio gate.
- Validation:
  - [x] Added a failing behavioral regression requiring `scripts/collect_focus_audio_evidence.sh` to block without confirmations, generate a focus/audio validation snippet after a real-session confirmation set, and produce a snippet accepted by `scripts/check_focus_audio_evidence.sh`.
  - [x] Added `scripts/collect_focus_audio_evidence.sh` with explicit output-device, blocker, focus pause overlay, audio-before, quiet-during-pause, audio-after-resume, and resume-control confirmations.
  - [x] Updated `docs/focus_audio_validation.md`, `docs/public_playtest_gate.md`, `docs/macos_build_and_distribution.md`, the known-tester packet, handoff, audit, and tracker references to surface the collector.
  - [x] `python3 -m pytest tests/test_scripts_and_docs.py::test_focus_audio_evidence_collector_scaffolds_manual_audible_session -q` passes.
  - [x] `bash scripts/check.sh` passes with 110 tests and Godot runtime smoke.
- Progress:
  - 2026-05-12: Reduced manual focus/audio evidence capture friction without claiming audible proof has been recorded.
- Dependencies: [RR-PROD-65], [RR-PROD-73]
- Completed: 2026-05-12

### [RR-PROD-73] Record release signing status in tester packet
- Outcome: The known-tester packet now runs the guarded release signing/notarization script as an allow-failure gate and records the release signing status plus `logs/release_signing.log` in the manifest.
- Validation:
  - [x] Added a failing behavioral regression with a fake packet workspace where `scripts/sign_notarize_macos.sh` reports `RIFT_ROAD_RELEASE_SIGNING blocked`.
  - [x] Updated `scripts/prepare_known_tester_packet.sh` to run `scripts/sign_notarize_macos.sh`, preserve `logs/release_signing.log`, surface `Release signing: blocked/ok`, and bundle the signing script for supervised tester packets.
  - [x] `python3 -m pytest tests/test_scripts_and_docs.py::test_known_tester_packet_records_release_signing_status -q` passes.
  - [x] `bash scripts/check.sh` passes with 109 tests and Godot runtime smoke.
- Progress:
  - 2026-05-12: Closed the packet evidence gap left after the release-candidate gate began using the signed/notarized artifact path.
- Dependencies: [RR-PROD-72]
- Completed: 2026-05-12

### [RR-PROD-72] Gate release candidates on signed artifact path
- Outcome: The release-candidate gate now executes the guarded signing/notarization script and accepts `RIFT_ROAD_RELEASE_SIGNING ok` as release-artifact evidence instead of only inspecting the unsigned internal zip.
- Validation:
  - [x] Added a failing regression proving a fake `RIFT_ROAD_RELEASE_SIGNING ok` run suppresses the unsigned-package-only blocker while later manual gates still keep the release gate blocked.
  - [x] Updated `scripts/check_release_candidate.sh` to run `scripts/sign_notarize_macos.sh`, preserve `logs/release_signing.log`, add signing/notarization blockers when it is missing or blocked, and include that log in the production-deployable checklist row.
  - [x] `python3 -m pytest tests/test_scripts_and_docs.py::test_release_candidate_gate_uses_signed_release_artifact_when_available -q` passes.
  - [x] `bash scripts/check.sh` passes with 108 tests and Godot runtime smoke.
- Progress:
  - 2026-05-12: Moved the release-candidate gate from preflight-only signing coverage to the real signed/notarized artifact path while keeping the current build blocked without Apple credentials.
- Dependencies: [RR-PROD-62], [RR-PROD-71]
- Completed: 2026-05-12

### [RR-PROD-71] Keep release audit on hard gate failures
- Outcome: The release-candidate gate now writes `build/release-gate/latest/completion-audit.md` even when a required automated command fails before the normal manual-blocker summary.
- Validation:
  - [x] Added a failing behavioral regression with a fake release-gate workspace where `scripts/sample_exported_app_performance.sh` exits non-zero before the later evidence gates run.
  - [x] Updated `scripts/check_release_candidate.sh` so required-command failures add a blocker, write the completion audit, print the audit path, report `RIFT_ROAD_RELEASE_GATE blocked`, and preserve the original failing exit status.
  - [x] `python3 -m pytest tests/test_scripts_and_docs.py::test_release_candidate_gate_writes_audit_on_required_command_failure -q` passes.
- Progress:
  - 2026-05-12: Closed the gap exposed by a transient exported-app performance artifact miss where the release gate could previously stop without producing the objective checklist.
- Dependencies: [RR-PROD-70]
- Completed: 2026-05-12

### [RR-PROD-70] Surface Godot version evidence in release handoff
- Outcome: Release-candidate and known-tester evidence artifacts now expose the Godot 4.6.x stable version-gate marker directly instead of leaving it implicit inside the validation log.
- Validation:
  - [x] Added a failing regression requiring `scripts/check_release_candidate.sh` and `scripts/prepare_known_tester_packet.sh` to surface `RIFT_ROAD_GODOT_VERSION ok` in release/packet evidence.
  - [x] Updated `build/release-gate/latest/completion-audit.md` generation to include a `Godot engine version gate` row backed by `logs/check.log`.
  - [x] Updated the known-tester packet manifest to print the exact `RIFT_ROAD_GODOT_VERSION ok` marker from `logs/check.log`.
  - [x] Updated public playtest and macOS distribution guidance so testers know where the version gate is recorded.
- Progress:
  - 2026-05-12: Made the just-added Godot version gate visible in the two main release-handoff artifacts without changing the remaining manual blockers.
- Dependencies: [RR-PROD-69]
- Completed: 2026-05-12

### [RR-PROD-69] Add Godot version validation gate
- Outcome: Local validation now checks the configured Godot executable is on the supported Godot 4.6.x stable line before running the Python suite and runtime smoke.
- Validation:
  - [x] Added a failing regression requiring `scripts/check_godot_version.sh`, `scripts/check.sh` integration, fake accepted/blocked Godot version checks, and updated architecture/reliability/quality/macOS debt docs.
  - [x] Added `scripts/check_godot_version.sh` with `GODOT_BIN` support, `RIFT_ROAD_GODOT_VERSION ok`, and `RIFT_ROAD_GODOT_VERSION blocked` markers.
  - [x] Updated `scripts/check.sh` to run `bash scripts/check_godot_version.sh` before `python3 -m pytest tests -v`.
  - [x] `python3 -m pytest tests/test_scripts_and_docs.py::test_godot_version_gate_requires_46_stable -q` passes.
  - [x] `bash scripts/check.sh` passes with 106 tests and Godot runtime smoke.
- Progress:
  - 2026-05-12: Closed TD-001's machine-checkable Godot-version gap without claiming a patch-level engine pin.
- Dependencies: [RR-PROD-68]
- Completed: 2026-05-12

### [RR-PROD-68] Refresh repo guidance for current release gates
- Outcome: Architecture, reliability, product-spec, and quality guidance now point to the current release-candidate, signing preflight, exported-app performance, and public-playtest gate artifacts instead of stale unknowns.
- Validation:
  - [x] Added a failing regression requiring repo guidance docs to reference `scripts/check_release_candidate.sh`, `scripts/sample_exported_app_performance.sh`, `scripts/check_macos_signing_env.sh`, `build/release-gate/latest/completion-audit.md`, and `docs/public_playtest_gate.md`.
  - [x] Updated `ARCHITECTURE.md`, `docs/RELIABILITY.md`, `docs/product-specs/index.md`, and `docs/QUALITY_SCORE.md` to reflect the current mechanical gates while preserving real unresolved evidence gaps.
  - [x] `python3 -m pytest tests/test_scripts_and_docs.py::test_repo_guidance_tracks_current_release_validation_gates -q` passes.
  - [x] `python3 scripts/check_agent_docs.py` passes.
  - [x] `bash scripts/check.sh` passes with 105 tests and Godot runtime smoke.
- Progress:
  - 2026-05-12: Removed stale guidance that implied performance validation and external-session policy were still undiscovered after the release/playtest gates were added.
- Dependencies: [RR-PROD-67]
- Completed: 2026-05-12

### [RR-PROD-67] Emit release completion audit artifact
- Outcome: The release-candidate gate now writes a prompt-to-artifact completion audit that maps the active marketability objective to the logs generated by the gate run before reporting blocked or release-candidate.
- Validation:
  - [x] Added a failing regression requiring `scripts/check_release_candidate.sh` to write `completion-audit.md` with an objective restatement, prompt-to-artifact checklist, named objective requirements, and log-backed evidence rows.
  - [x] Updated `scripts/check_release_candidate.sh` to write `build/release-gate/latest/completion-audit.md` with checked/blocked rows for Stage 1 playability, macOS deployability, launched screenshot/playtest evidence, validation, market-readiness assessment, public playtest/release proof, and player-love/commercial evidence.
  - [x] Updated public playtest, macOS distribution, market audit, and tracker docs to reference the completion-audit artifact.
  - [x] `python3 -m pytest tests/test_scripts_and_docs.py::test_release_candidate_gate_combines_automated_and_manual_blockers -q` passes.
  - [x] `bash scripts/check_release_candidate.sh` writes `build/release-gate/latest/completion-audit.md` and reports `RIFT_ROAD_RELEASE_GATE blocked` with the expected remaining manual/package/player-evidence blockers.
  - [x] `bash scripts/check.sh` passes with 104 tests and Godot runtime smoke.
- Progress:
  - 2026-05-12: Made the release gate produce the completion-audit checklist required before any future public-playtest or release-candidate claim.
- Dependencies: [RR-PROD-14], [RR-PROD-15]
- Completed: 2026-05-12

### [RR-PROD-66] Record manual gate statuses in tester packet
- Outcome: The known-tester packet now records the current focus/audio, playtest, controller, and second-machine evidence gate statuses plus logs, so supervised sessions can see which manual blockers remain without rerunning every checker by hand.
- Validation:
  - [x] Added a failing regression requiring `scripts/prepare_known_tester_packet.sh` to run `scripts/check_playtest_evidence.sh`, `scripts/check_controller_evidence.sh`, and `scripts/check_second_machine_evidence.sh` in allow-failure mode, then write their statuses and logs into the packet manifest.
  - [x] Updated `scripts/prepare_known_tester_packet.sh` to preserve `logs/playtest_evidence.log`, `logs/controller_evidence.log`, and `logs/second_machine_evidence.log` while keeping the packet command usable when those evidence gates are blocked.
  - [x] Updated macOS distribution docs and the handoff note to state that the known-tester packet records manual gate statuses.
  - [x] `python3 -m pytest tests/test_scripts_and_docs.py::test_known_tester_packet_script_collects_internal_build_evidence -q` passes.
  - [x] `bash scripts/check.sh` passes with 104 tests and Godot runtime smoke.
- Progress:
  - 2026-05-12: Made the internal packet a clearer evidence handoff by surfacing each remaining manual gate status directly in `manifest.md`.
- Dependencies: [RR-PROD-14], [RR-PROD-15]
- Completed: 2026-05-12

### [RR-PROD-65] Add manual focus/audio evidence gate
- Outcome: Added an explicit release-candidate blocker for manual audible focus-loss/resume confirmation so automated focus state proof cannot be mistaken for real output-device evidence.
- Validation:
  - [x] Added a failing regression requiring `scripts/check_focus_audio_evidence.sh`, `docs/focus_audio_validation.md`, release-gate integration, known-tester packet references, public gate docs, macOS docs, handoff, and market audit to reference the manual focus/audio gate.
  - [x] Added `scripts/check_focus_audio_evidence.sh` and `docs/focus_audio_validation.md` with required pass checks for focus overlay, audio before focus loss, quiet/suspended focus pause, audio after resume, resume control, and real evidence capture file.
  - [x] Updated `scripts/check_release_candidate.sh` so release-candidate status requires `RIFT_ROAD_FOCUS_AUDIO_EVIDENCE ok`.
  - [x] `python3 -m pytest tests/test_scripts_and_docs.py::test_focus_audio_evidence_gate_blocks_without_manual_audible_confirmation -q` passes.
  - [x] `bash scripts/check.sh` passes with 104 tests and Godot runtime smoke.
- Progress:
  - 2026-05-12: Converted the audible focus-loss gap into a mechanical blocker while preserving the current automated focus/resume smoke.
- Dependencies: [RR-PROD-59]
- Completed: 2026-05-12

### [RR-PROD-64] Add playtest evidence collector
- Outcome: Added a guarded manual collector for external-style playtest sessions so testers can generate non-empty evidence notes plus paste-ready `docs/playtest_log.md` rows after real runs.
- Validation:
  - [x] Added a failing regression requiring `scripts/collect_playtest_evidence.sh`, required playtest fields, collector blocked/ok markers, playtest log docs, public gate, known-tester packet, handoff, and market audit to reference the collector.
  - [x] Added `scripts/collect_playtest_evidence.sh` with `--confirm-external-session`, required timing/replay/confusion/cheap-damage/quote/follow-up fields, and generated note/row files under `docs/playtest-captures/playtests/`.
  - [x] Updated the known-tester packet to bundle the playtest collector and checker scripts.
  - [x] `python3 -m pytest tests/test_scripts_and_docs.py::test_playtest_evidence_collector_scaffolds_external_session_notes -q` passes.
  - [x] `bash scripts/check.sh` passes with 103 tests and Godot runtime smoke.
- Progress:
  - 2026-05-12: Reduced external session logging friction while preserving the real playtest-evidence gate.
- Dependencies: [RR-PROD-14]
- Completed: 2026-05-12

### [RR-PROD-63] Add controller evidence collector
- Outcome: Added a guarded manual collector for exported-app controller and keyboard fallback sessions so testers can generate non-empty evidence notes plus paste-ready `docs/controller_validation.md` snippets after real physical-device runs.
- Validation:
  - [x] Added a failing regression requiring `scripts/collect_controller_evidence.sh`, per-control confirmations, collector blocked/ok markers, controller docs, public gate, known-tester packet, handoff, and market audit to reference the collector.
  - [x] Added `scripts/collect_controller_evidence.sh` with `--session-type controller|keyboard`, explicit controller metadata, explicit per-control confirmation flags, and generated evidence/snippet files under `docs/playtest-captures/controller/`.
  - [x] Updated the known-tester packet to bundle the controller collector and checker scripts.
  - [x] `python3 -m pytest tests/test_scripts_and_docs.py::test_controller_evidence_collector_scaffolds_real_manual_sessions -q` passes.
  - [x] `bash scripts/check.sh` passes with 102 tests and Godot runtime smoke.
- Progress:
  - 2026-05-12: Reduced controller/keyboard evidence collection friction while preserving the real-session gate.
- Dependencies: [RR-PROD-15]
- Completed: 2026-05-12

### [RR-PROD-62] Add macOS release signing script
- Outcome: Added a guarded release-artifact script that signs the exported macOS app with Developer ID, submits it to notarytool, staples and validates the ticket, checks Gatekeeper, writes `build/macos/Rift Road-signed-notarized.zip`, and audits the signed artifact when real Apple signing inputs are available.
- Validation:
  - [x] Added a failing regression requiring `scripts/sign_notarize_macos.sh`, the signing commands, artifact-only package audit mode, redacted env template, public playtest gate, handoff, and market audit to reference the release signing path.
  - [x] Added `scripts/sign_notarize_macos.sh` with a `--help` path and `RIFT_ROAD_RELEASE_SIGNING blocked/ok` markers.
  - [x] Updated `scripts/audit_macos_package.sh` with `RIFT_ROAD_AUDIT_ARTIFACT_ONLY=1` for post-export signed artifact audits.
  - [x] `python3 -m pytest tests/test_scripts_and_docs.py::test_macos_sign_notarize_script_defines_release_artifact_path -q` passes.
  - [x] `bash scripts/check.sh` passes with 101 tests and Godot runtime smoke.
- Progress:
  - 2026-05-12: Converted the missing sign/notarize/staple flow into a repeatable script while keeping release status blocked until real credentials and signed artifact evidence exist.
- Dependencies: [RR-PROD-20]
- Completed: 2026-05-12

### [RR-PROD-61] Bundle second-machine evidence collector
- Outcome: Known testers can run a dedicated second-machine collector on the real Apple Silicon Mac B to generate the host profile, package audit log, install-smoke note, and title/gameplay capture files expected by the second-machine evidence gate.
- Validation:
  - [x] Added a failing regression requiring `scripts/collect_second_machine_evidence.sh`, the second-machine docs, public gate, handoff note, and known-tester packet script to reference the collector.
  - [x] Added `scripts/collect_second_machine_evidence.sh` with a `--help` path, an explicit `RIFT_ROAD_SECOND_MACHINE_LABEL="Apple Silicon Mac B"` guard, package audit reuse, exported-app smoke reuse, host profile generation, install-smoke generation, and blocked/ok collector markers.
  - [x] Updated `scripts/prepare_known_tester_packet.sh` to bundle the collector plus `check_second_machine_evidence.sh`, `audit_macos_package.sh`, and `smoke_exported_macos_app.sh`.
  - [x] `python3 -m pytest tests/test_scripts_and_docs.py::test_second_machine_evidence_gate_blocks_without_clean_machine_proof tests/test_scripts_and_docs.py::test_second_machine_evidence_collector_is_bundled_for_known_testers tests/test_scripts_and_docs.py::test_known_tester_packet_script_collects_internal_build_evidence tests/test_scripts_and_docs.py::test_known_tester_packet_includes_manual_gate_checklists -q` passes.
  - [x] `bash scripts/check.sh` passes with 100 tests and Godot runtime smoke.
- Progress:
  - 2026-05-12: Reduced second-machine handoff friction without turning the gate green; real Apple Silicon Mac B execution, Gatekeeper acceptance, and release-candidate package audit evidence are still missing.
- Dependencies: [RR-PROD-19]
- Completed: 2026-05-12

### [RR-PROD-60] Require real controller evidence files
- Outcome: The controller evidence gate no longer accepts completed-looking physical controller or keyboard fallback rows unless every `Evidence capture` path resolves to a real, non-empty file.
- Validation:
  - [x] Added a failing regression proving two complete controller-family rows plus one complete keyboard fallback row still block when their evidence captures are missing.
  - [x] Updated `scripts/check_controller_evidence.sh` to resolve relative capture paths from the repo root and reject missing or empty evidence files.
  - [x] Updated `docs/controller_validation.md`, macOS notes, handoff, and market-readiness audit to state the real-file evidence requirement.
  - [x] `python3 -m pytest tests/test_scripts_and_docs.py::test_controller_evidence_gate_rejects_missing_evidence_files tests/test_scripts_and_docs.py::test_controller_evidence_gate_accepts_complete_session_metadata -q` passes.
  - [x] `bash scripts/check.sh` passes with 99 tests and Godot runtime smoke.
- Progress:
  - 2026-05-12: Tightened the remaining manual controller/keyboard blocker so future rows must be tied to actual capture artifacts before the release gate can turn green.
- Dependencies: [RR-PROD-53]
- Completed: 2026-05-12

### [RR-PROD-59] Add exported-app focus/resume smoke
- Outcome: The packaged app can now be launched with a focus/resume smoke argument that records JSON plus a pause-overlay viewport capture for Stage 1 focus-pause, audio-manager state, return-focus copy, and resume.
- Validation:
  - [x] Added a failing regression requiring `scripts/smoke_exported_focus_resume.sh`, the app launch hook, release gate, known-tester packet, macOS docs, handoff note, and market audit to reference `RIFT_ROAD_EXPORTED_FOCUS_RESUME ok`.
  - [x] Added `--rift-road-focus-resume-smoke`, output, and capture-dir launch args in `AppRoot`.
  - [x] Added `scripts/smoke_exported_focus_resume.sh` and integrated it into `scripts/check_release_candidate.sh` and `scripts/prepare_known_tester_packet.sh`.
  - [x] `python3 -m pytest tests/test_runtime_smoke.py::test_stage_one_focus_loss_pauses_and_resumes -q` passes.
  - [x] `bash scripts/check.sh` passes with 98 tests and Godot runtime smoke.
  - [x] `bash scripts/package_macos.sh` regenerated `build/macos/Rift Road.zip`.
  - [x] `bash scripts/smoke_exported_focus_resume.sh` reports `RIFT_ROAD_EXPORTED_FOCUS_RESUME ok`.
- Progress:
  - 2026-05-11: Added repeatable launched-zip focus/resume artifact generation. Manual audible focus-loss behavior still needs tester confirmation.
- Dependencies: [RR-PROD-57]
- Completed: 2026-05-11

### [RR-PROD-58] Add controller hot-plug status smoke
- Outcome: The app now listens for Godot controller connection changes, records a concise connected/disconnected status, and keeps that status visible in menu/result control prompts so hot-plug events do not silently disappear.
- Validation:
  - [x] Added a failing runtime regression requiring `controller_hotplug_status` to emit `RIFT_ROAD_CONTROLLER_HOTPLUG connected=true disconnected=true prompt=true events=2`.
  - [x] Wired `Input.joy_connection_changed` in `AppRoot` and added connection-status prompt refresh.
  - [x] Added `controller_hotplug_status` to `src/wildcoil/tools/runtime_test_runner.gd`.
  - [x] `python3 -m pytest tests/test_runtime_smoke.py::test_controller_hotplug_status_updates_ui_and_runtime_state -q` passes.
- Progress:
  - 2026-05-11: Added automated coverage for the controller hot-plug acceptance row. Physical controller-family testing remains blocked until real devices are recorded.
- Dependencies: [RR-PROD-12]
- Completed: 2026-05-11

### [RR-PROD-57] Add audio focus suspend/resume hook
- Outcome: Window focus-loss handling now forwards to the Stage 1 audio manager so the stage pulse is suspended on focus loss and resumed when focus returns.
- Validation:
  - [x] Added a failing runtime regression requiring `stage1_focus_resume` to emit `RIFT_ROAD_FOCUS_RESUME focus_pause=true overlay=true audio=true resume=true`.
  - [x] Added `AudioManager.suspend_for_focus_loss()` and `AudioManager.resume_after_focus_return()` with focus suspend/resume counters for smoke-test proof.
  - [x] Wired `AppRoot` focus-loss/focus-return paths to the current stage audio manager.
  - [x] `python3 -m pytest tests/test_runtime_smoke.py::test_stage_one_focus_loss_pauses_and_resumes -q` passes.
- Progress:
  - 2026-05-11: Automated focus coverage now includes audio-manager suspend/resume state. Manual exported-app audio output still needs human confirmation during tester sessions.
- Dependencies: [RR-PROD-56]
- Completed: 2026-05-11

### [RR-PROD-56] Add focus-loss pause/resume runtime smoke
- Outcome: Stage 1 now auto-pauses on macOS window focus loss with a visible pause overlay, updates the pause copy when focus returns, and resumes cleanly through the existing Esc/Start path.
- Validation:
  - [x] Added a failing runtime regression requiring `stage1_focus_resume` to emit focus-pause, overlay, and resume proof.
  - [x] Updated `AppRoot` focus notifications and pause state handling so stage pause uses a dedicated pause overlay while the title layer stays hidden.
  - [x] Added `stage1_focus_resume` to `src/wildcoil/tools/runtime_test_runner.gd`.
  - [x] `python3 -m pytest tests/test_runtime_smoke.py::test_stage_one_focus_loss_pauses_and_resumes -q` passes.
- Progress:
  - 2026-05-11: Added automated coverage for the macOS focus-loss/resume acceptance row.
- Dependencies: [RR-PROD-12]
- Completed: 2026-05-11

### [RR-PROD-55] Add redacted macOS signing input template
- Outcome: Added a placeholder-only env template for the macOS signing/notarization preflight inputs so release setup can be repeated locally without committing credentials or account values.
- Validation:
  - [x] Added a failing regression requiring `docs/macos_release_inputs.example.env` to exist, include `RIFT_ROAD_APPLE_TEAM_ID`, `RIFT_ROAD_DEVELOPER_ID_APPLICATION`, and `RIFT_ROAD_NOTARY_KEYCHAIN_PROFILE`, and warn not to commit real values.
  - [x] Added `docs/macos_release_inputs.example.env` with placeholder values and local usage comments.
  - [x] Updated security, macOS distribution, and tracker docs to point to the redacted template.
- Progress:
  - 2026-05-11: Made the blocked signing preflight inputs concrete without recording any real signing credentials.
- Dependencies: [RR-PROD-31]
- Completed: 2026-05-11

### [RR-PROD-54] Fingerprint known-tester packet artifacts
- Outcome: The known-tester packet manifest now records the git build commit and SHA-256 of `Rift Road.zip`, tying future manual controller/playtest notes to an exact package artifact.
- Validation:
  - [x] Added a failing regression requiring `scripts/prepare_known_tester_packet.sh` to collect `git -C "$ROOT_DIR" rev-parse --short HEAD`, hash `Rift Road.zip` with `shasum -a 256`, and write `Build commit` plus `Package SHA256` lines into `manifest.md`.
  - [x] Updated `scripts/prepare_known_tester_packet.sh` to compute those values after rebuilding the package and before writing the manifest.
  - [x] Updated public playtest, macOS distribution, market-readiness, and tracker docs with the manifest fingerprint expectation.
- Progress:
  - 2026-05-11: Added artifact fingerprinting to make supervised tester evidence traceable to the exact package under test.
- Dependencies: [RR-PROD-27]
- Completed: 2026-05-11

### [RR-PROD-53] Harden controller evidence metadata gate
- Outcome: The controller evidence gate now rejects marked controller or keyboard fallback sessions when required build, device, connection, evidence-capture, or blocker metadata is missing or still `TBD`, while still accepting complete non-placeholder evidence rows.
- Validation:
  - [x] Added a failing regression proving a fake controller-validation document with two `RIFT_ROAD_CONTROLLER_SESSION ok` rows, one `RIFT_ROAD_KEYBOARD_FALLBACK ok` row, and all controls marked `pass` is still blocked when metadata is placeholder.
  - [x] Added a positive fixture proving two complete controller-family rows plus one complete keyboard fallback row report `RIFT_ROAD_CONTROLLER_EVIDENCE ok`.
  - [x] Updated `scripts/check_controller_evidence.sh` to validate required metadata before counting controller families or keyboard fallback evidence.
  - [x] Updated controller, macOS distribution, market-readiness, and tracker docs with the stricter metadata rule.
- Progress:
  - 2026-05-11: Hardened the manual evidence gate so future physical controller sessions need real build/device/evidence details, not just pass strings.
- Dependencies: [RR-PROD-15]
- Completed: 2026-05-11

### [RR-PROD-52] Include keyboard fallback in release packet gates
- Outcome: The release-candidate gate and known-tester packet now run the exported-app keyboard fallback smoke and preserve its log/evidence alongside the existing launch smoke and performance evidence.
- Validation:
  - [x] Added failing script/doc regressions requiring `scripts/check_release_candidate.sh` and `scripts/prepare_known_tester_packet.sh` to reference `scripts/smoke_exported_keyboard_fallback.sh`, `RIFT_ROAD_EXPORTED_KEYBOARD_FALLBACK ok`, `logs/exported_app_keyboard_fallback.log`, and `evidence/keyboard-fallback-latest/`.
  - [x] Updated `scripts/check_release_candidate.sh` to run the exported-app keyboard fallback smoke and block if its success marker is missing.
  - [x] Updated `scripts/prepare_known_tester_packet.sh` to run the exported-app keyboard fallback smoke, copy `docs/playtest-captures/keyboard-fallback-latest/`, and list the log/evidence in `manifest.md`.
- Progress:
  - 2026-05-11: Wired the keyboard fallback proof into the release and handoff workflows so it travels with the tester packet.
- Dependencies: [RR-PROD-51]
- Completed: 2026-05-11

### [RR-PROD-51] Add exported-app keyboard fallback smoke
- Outcome: Added a packaged-app keyboard fallback smoke command that extracts `build/macos/Rift Road.zip`, launches the `.app`, exercises keyboard title/hero/stage/action/pause input through the exported runtime, and writes JSON plus viewport evidence.
- Validation:
  - [x] Added a failing script/doc regression requiring `scripts/smoke_exported_keyboard_fallback.sh`, the `--rift-road-keyboard-fallback-smoke` app launch argument, JSON/capture artifact names, docs, and `RIFT_ROAD_EXPORTED_KEYBOARD_FALLBACK ok`.
  - [x] Added `KEYBOARD_FALLBACK_SMOKE_ARG` and `_run_exported_keyboard_fallback_smoke` to `src/wildcoil/scripts/app_root.gd`.
  - [x] Added `scripts/smoke_exported_keyboard_fallback.sh` to launch the zipped app and verify `stage1-exported-app-keyboard-fallback.json` plus `stage1-exported-app-keyboard-fallback.png`.
  - [x] `python3 -m pytest tests/test_runtime_smoke.py::test_keyboard_fallback_title_to_stage_and_action_flow tests/test_scripts_and_docs.py::test_exported_app_keyboard_fallback_smoke_records_input_artifacts -q` passes.
  - [x] `bash scripts/check.sh` passes with 93 tests and Godot runtime smoke.
  - [x] `bash scripts/package_macos.sh` regenerated `build/macos/Rift Road.zip`.
  - [x] `bash scripts/smoke_exported_keyboard_fallback.sh` reports `RIFT_ROAD_EXPORTED_KEYBOARD_FALLBACK ok` and writes `docs/playtest-captures/keyboard-fallback-latest/stage1-exported-app-keyboard-fallback.json` plus `stage1-exported-app-keyboard-fallback.png`.
- Progress:
  - 2026-05-11: Added automated launched-export keyboard fallback proof after Computer Use could see the process but could not attach to a Godot app window for manual input.
- Dependencies: [RR-PROD-50]
- Completed: 2026-05-11

### [RR-PROD-50] Add keyboard fallback runtime smoke coverage
- Outcome: Added a repeatable headless keyboard-fallback regression that exercises title, hero select, preview cancel/back, Stage 1 start, movement, attack, jump, special, dash, and pause/resume through the runtime input path.
- Validation:
  - [x] Added a failing regression for `keyboard_fallback_flow` that required the runtime smoke runner to emit `RIFT_ROAD_KEYBOARD_FALLBACK title=true hero_select=true movement=true attack=true jump=true special=true dash=true pause=true cancel=true`.
  - [x] Verified the regression failed before implementation because the runtime runner accepted the mode name but did not emit keyboard-fallback evidence.
  - [x] Added `keyboard_fallback_flow` to `src/wildcoil/tools/runtime_test_runner.gd` with menu key events and in-stage keyboard state checks for movement/actions.
  - [x] `python3 -m pytest tests/test_runtime_smoke.py::test_keyboard_fallback_title_to_stage_and_action_flow -q` passes.
  - [x] `bash scripts/check.sh` passes with 92 tests and Godot runtime smoke.
- Progress:
  - 2026-05-11: Added automated keyboard-fallback coverage to reduce input-regression risk before manual controller and exported-app keyboard sessions.
- Dependencies: [RR-PROD-12]
- Completed: 2026-05-11

### [RR-PROD-49] Add Stage 1 opening story and barks
- Outcome: Stage 1 now starts with short data-driven Raya/Nika story panels and in-stage bark hooks that explain drill marks, Iron Veil cages, and route stakes without blocking player control, with a repeatable launched-app opening-story screenshot.
- Validation:
  - [x] Added a regression that Stage 1 data defines at least three `opening_story` panels plus `stage_barks`, and that `StageManager`/`ArcadeCombatFx` expose story-panel and bark presentation helpers.
  - [x] Added runtime smoke coverage for `stage1_opening_story` proving opening panels and the cage-loading bark surface in the running Stage 1 scene.
  - [x] Added exported-app smoke coverage for `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-opening-story.png`.
  - [x] `python3 -m pytest tests/test_brawler_presentation.py::test_stage_one_has_opening_story_panels_and_barks tests/test_runtime_smoke.py::test_stage_one_opening_story_and_barks_surface_in_runtime tests/test_scripts_and_docs.py::test_exported_app_smoke_script_captures_opening_story_viewport -q` passes.
  - [x] `bash scripts/check.sh` passes with 91 tests and Godot runtime smoke.
  - [x] `bash scripts/package_macos.sh` regenerated `build/macos/Rift Road.zip`.
  - [x] `bash scripts/smoke_exported_macos_app.sh` reports `RIFT_ROAD_EXPORTED_APP_SMOKE ok` with `opening_story_capture=.../stage1-exported-app-smoke-opening-story.png`.
  - [x] Manual visual inspection of `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-opening-story.png` confirms the launched-app story panel is readable and does not cover the player/combat plane; this is opening presentation evidence, not a human playtest claim.
- Progress:
  - 2026-05-11: Added Stage 1 opening story data, barks, runtime smoke, launched-app capture, and market-readiness docs.
- Dependencies: [RR-PROD-48]
- Completed: 2026-05-11

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
  - [x] Current 1280x720 windowed result: `avg_ms=10.126`, `max_ms=22.409`, `budget_ms=33.3`, `max_budget_ms=120.0`.
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
  - [x] Latest local result: `avg_ms=10.126`, `max_ms=22.409`, `budget_ms=33.3`, `max_budget_ms=120.0`, after 8 startup/render warmup frames.
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
  - [x] Latest local result: `avg_ms=16.726`, `max_ms=40.161`, `budget_ms=33.3`, `max_budget_ms=120.0`.
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
