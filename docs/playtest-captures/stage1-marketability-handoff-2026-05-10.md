# Stage 1 Marketability Handoff - 2026-05-10

## Current Build

- Package: `build/macos/Rift Road.zip`
- Engine: Godot 4.6.1
- Validation: `bash scripts/check.sh` passed with 140 tests and Godot runtime smoke; focus-loss smoke now includes audio-manager suspend/resume state, exported-app focus/resume artifact generation, staged capture replacement coverage, release signing-script coverage, signing-preflight success-marker coverage, release-candidate signing log coverage, known-tester release signing status coverage, signed-artifact packet selection coverage, signed-package second-machine evidence-source coverage, second-machine collector host-architecture coverage, second-machine SHA-shape coverage, focus/audio SHA-shape coverage, controller SHA-shape coverage, playtest SHA-shape coverage, playtest observation-field coverage, playtest milestone-timing coverage, playtest setup/input metadata coverage, playtest cheap-damage repeat coverage, playtest hook/show-moment coverage, local source-run playability scope coverage, local source-run playtest collector coverage, local source-run playtest evidence gate coverage, selected-package manual evidence collector coverage, playtest evidence-capture, package-SHA, and signed-source coverage, controller package-SHA and signed-source coverage, focus/audio package-SHA and signed-source coverage, second-machine package-SHA and signed-source coverage, Godot 4.6.x stable version-gate coverage, controller evidence collector coverage, playtest evidence collector coverage, manual focus/audio gate coverage, focus/audio evidence collector coverage, manual gate status coverage in the known-tester packet, current release-gate guidance coverage, and controller hot-plug status is covered in automation, but audible exported-app focus-loss behavior and physical controller devices still need manual confirmation.
- Export validation: `bash scripts/package_macos.sh` regenerated `build/macos/Rift Road.zip`; `bash scripts/smoke_exported_macos_app.sh` refreshed the launched-app title, hero-select, opening story, Stage 1 gameplay, post-intro combat, pickup clarity, road-collapse, Brask intro, Stage Clear score/rank summary, Game Over/retry, and post-retry gameplay screenshots through staged capture replacement.
- Signing preflight: `bash scripts/check_macos_signing_env.sh` reports `RIFT_ROAD_SIGNING_PREFLIGHT blocked` until real Developer ID/notary configuration exists.
- Release signing path: `bash scripts/sign_notarize_macos.sh` can create `build/macos/Rift Road-signed-notarized.zip` only after real Developer ID, notary profile, and local package inputs exist; it currently reports `RIFT_ROAD_RELEASE_SIGNING blocked` without those inputs.
- Package audit: `bash scripts/audit_macos_package.sh` reports `RIFT_ROAD_PACKAGE_AUDIT internal-only`.
- Second-machine evidence: `bash scripts/check_second_machine_evidence.sh` currently reports `RIFT_ROAD_SECOND_MACHINE_EVIDENCE blocked` because no clean-machine proof files have been recorded. `bash scripts/collect_second_machine_evidence.sh` is available for known testers to generate those files on the actual second Mac, including signed/notarized package-source and 64-character `Package SHA256` metadata for the exact zip; the collector only writes the install-ok marker when the host reports `arm64`.
- Controller evidence: `bash scripts/check_controller_evidence.sh` currently reports `RIFT_ROAD_CONTROLLER_EVIDENCE blocked` because no physical controller-family sessions have been recorded. Marked controller or keyboard fallback rows must include complete metadata, include a 64-character `package_sha256=<sha>` and signed `package_source=...Rift Road-signed-notarized.zip` metadata in `Build`, point `Evidence capture` at a real non-empty file, and confirm special-meter readiness before marking `Special` as passed. `docs/playtest-captures/controller/20260512-keyboard-menu-confirm.md` records a narrower launched-app keyboard menu-confirm fix for text-style `j` from hero preview to Stage 1, but it is not the full manual keyboard fallback row.
- Controller evidence collector: `bash scripts/collect_controller_evidence.sh --help` is available for real exported-app controller or keyboard sessions; it writes manual evidence notes and paste-ready snippets, records selected package path and package SHA metadata by default, requires special-meter-ready confirmation, but does not substitute for actual physical device testing; unsigned fallback snippets remain internal-only and do not satisfy the gate.
- Keyboard fallback smoke: `python3 -m pytest tests/test_runtime_smoke.py::test_keyboard_fallback_title_to_stage_and_action_flow -q` proves the headless runtime covers title, hero select, preview cancel, Stage 1 movement, attack, jump, special, dash, and pause/resume through keyboard input. This is automated regression coverage, not a manual exported-app keyboard session.
- Exported-app smoke: `bash scripts/smoke_exported_macos_app.sh` reports `RIFT_ROAD_EXPORTED_APP_SMOKE ok` when it can launch the zipped app and capture title, hero-select, opening story, Stage 1 gameplay, post-intro combat, pickup clarity, road-collapse, Stage Clear, Game Over/retry, and post-retry gameplay viewports from the running exported app.
- Exported-app keyboard smoke: `bash scripts/smoke_exported_keyboard_fallback.sh` records `docs/playtest-captures/keyboard-fallback-latest/stage1-exported-app-keyboard-fallback.json` and `stage1-exported-app-keyboard-fallback.png` from the launched zipped app. This is automated exported-app proof, not a manual tester row.
- Exported-app focus/resume smoke: `bash scripts/smoke_exported_focus_resume.sh` reports `RIFT_ROAD_EXPORTED_FOCUS_RESUME ok` and records `docs/playtest-captures/focus-resume-latest/stage1-exported-app-focus-resume.json` plus `stage1-exported-app-focus-resume.png` from the launched zipped app. This is automated exported-app proof of focus-handler state, not manual audible output confirmation.
- Smoke evidence integrity: the exported-app smoke, keyboard fallback smoke, and focus/resume smoke scripts use staged capture replacement, so failed launches leave the previous latest capture/JSON evidence intact until a validated replacement exists.
- Focus/audio evidence: `bash scripts/check_focus_audio_evidence.sh` currently reports `RIFT_ROAD_FOCUS_AUDIO_EVIDENCE blocked` because no human has confirmed real audible output before focus loss, quiet/suspended audio while focus-paused, and audible output after resume from the exported macOS app. Marked sessions must include a 64-character `package_sha256=<sha>` and signed package-source metadata in `Build`, plus a real non-empty evidence capture.
- Focus/audio evidence collector: `bash scripts/collect_focus_audio_evidence.sh --help` is available for real exported-app focus/audio sessions; it writes manual evidence notes and paste-ready snippets, records the selected package path and package SHA metadata when available, but does not substitute for actual audible output confirmation; unsigned fallback snippets remain internal-only and do not satisfy the gate.
- Exported-app performance: `bash scripts/sample_exported_app_performance.sh` reports `RIFT_ROAD_EXPORTED_PERF stage1` on local Apple Silicon Mac A (`arm64`, `Apple M1`, `iMac21,2`) with latest local 1280x720 windowed steady-state result `avg_ms=14.560`, `max_ms=35.960`, and writes `docs/playtest-captures/exported-app-performance-latest/stage1-exported-performance.json` after excluding 8 startup/render warmup frames. A local 1920x1080 windowed sample records `avg_ms=3.199`, `max_ms=6.652` under `docs/playtest-captures/exported-app-performance-windowed-1080p-latest/`. A local fullscreen exported-app performance sample records `avg_ms=1.583`, `max_ms=2.793` under `docs/playtest-captures/exported-app-performance-fullscreen-latest/`.
- Release-candidate gate: `bash scripts/check_release_candidate.sh` reports `RIFT_ROAD_RELEASE_GATE blocked` while package and player-evidence gates remain unresolved, and now runs the release signing/notarization path, preserves `logs/release_signing.log`, includes exported-app keyboard fallback and focus/resume smoke as automated gates, and preserves the completion audit on required-command hard failures.
- Known-tester packet: `bash scripts/prepare_known_tester_packet.sh` creates `build/known-tester-packet/latest/` with the selected zip, manifest, build commit, package SHA-256, Godot version-gate marker, release signing status, logs, docs, controller and second-machine checklists, second-machine collector scripts, smoke captures, keyboard fallback evidence, performance JSON, host profile, and manual gate statuses for supervised sessions. It uses `Rift Road-signed-notarized.zip` when release signing succeeds and the artifact exists; otherwise it keeps using the internal `Rift Road.zip`.
- Performance sample: `stage1_performance_sample` reports `RIFT_ROAD_PERF stage1` with latest local result `avg_ms=16.828`, `max_ms=49.411`.
- Public playtest gate: `docs/public_playtest_gate.md` defines the external session protocol, evidence threshold, and no-claim rules.
- Playtest evidence gate: `bash scripts/check_playtest_evidence.sh` currently reports `RIFT_ROAD_PLAYTEST_EVIDENCE blocked` because no external session rows have been recorded. Counted rows must include a 64-character `package_sha256=<sha>` and signed `package_source=...Rift Road-signed-notarized.zip` metadata in `Build`, `machine=primary-mac` or `machine=second-mac` setup metadata, a non-placeholder input method, first-combat and wow-moment times inside the Phase 1 targets, tester hook-description and show-someone-moment cells, non-placeholder timing/replay/confusion/cheap-damage/quote/follow-up cells, no repeated cheap-damage reports, plus an `Evidence capture` path to a real non-empty file.
- Playtest evidence collector: `bash scripts/collect_playtest_evidence.sh --help` is available after real external-style sessions to generate a session note and paste-ready `docs/playtest_log.md` row, records the selected package path and package SHA metadata by default, and does not replace external tester evidence; unsigned fallback rows remain internal-only and do not satisfy the playtest gate.

## Proof Captures

- Stage readability: `docs/playtest-captures/stage1-jungle-road-ruins-pass.png`
- Exported app title: `docs/playtest-captures/stage1-exported-app-title-window.png`
- Exported app Stage 1 keyflow: `docs/playtest-captures/stage1-exported-app-gameplay-window.png`
- Exported app manual input state: `docs/playtest-captures/stage1-exported-app-manual-input-window.png`
- Repeatable exported-app smoke title: `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-title.png`
- Repeatable exported-app smoke hero select: `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-hero-select.png`
- Repeatable exported-app smoke opening story: `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-opening-story.png`
- Repeatable exported-app smoke gameplay: `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-gameplay.png`
- Repeatable exported-app smoke post-intro combat: `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-combat.png`
- Repeatable exported-app smoke pickups: `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-pickups.png`
- Repeatable exported-app smoke road collapse: `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-road-collapse.png`
- Repeatable exported-app smoke Brask intro: `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-brask-intro.png`
- Repeatable exported-app smoke Stage Clear: `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-stage-clear.png`
- Repeatable exported-app smoke Game Over/retry: `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-game-over.png`
- Repeatable exported-app smoke post-retry gameplay: `docs/playtest-captures/exported-app-smoke-latest/stage1-exported-app-smoke-retry-gameplay.png`
- Repeatable exported-app keyboard fallback JSON: `docs/playtest-captures/keyboard-fallback-latest/stage1-exported-app-keyboard-fallback.json`
- Repeatable exported-app keyboard fallback capture: `docs/playtest-captures/keyboard-fallback-latest/stage1-exported-app-keyboard-fallback.png`
- Combat impact: `docs/playtest-captures/stage1-combat-impact-proof.png`
- Boss HUD: `docs/playtest-captures/stage1-boss-hud-readability-proof.png`
- Cinematic banner: `docs/playtest-captures/stage1-cinematic-banner-proof.png`

## What Works

- The title-to-hero-select-to-Stage-1 path is mechanically validated.
- The Stage 1 opening fight now starts with four enemies and delays heavier/ranged pressure until later waves.
- Stage 1 now opens with data-driven short comic-style story panels and in-stage barks for Raya, Nika, the cages, and the route stakes, captured by launched-app smoke without blocking player control.
- Baseline gamepad support now covers title/hero/start flow, pause, movement, attack, jump, special, dash, and controller-visible prompts.
- Keyboard fallback now has automated runtime smoke coverage for title, hero select, preview cancel/back, Stage 1 movement, attack, jump, special, dash, and pause/resume.
- Keyboard fallback now also has an automated launched-export smoke that writes a JSON checklist and viewport capture from the zipped app.
- Stage 1 has image-backed background and actor art, plus additive ruined signs, cage silhouettes, rubble, luma plants, and readable HUD treatment.
- The title screen now uses a branded Rift Road logo lockup, rift crack, subtitle ribbon, and start plate in the refreshed launched-app smoke capture.
- The Stage 1 intro banner now uses a centered 760px by 58px strap above the combatants, so the launched-game gameplay capture preserves more of the combat lane and background silhouettes while the objective text is visible.
- The Stage 1 intro strap now uses compact stage-card copy, so the refreshed launched-game gameplay capture reads `Free the transport cages` without ellipsizing the full scenario objective.
- The Stage 1 top HUD now uses a smaller player block, portrait frame, score panel, and lighter objective treatment, so the refreshed gameplay capture exposes more sunset/backdrop area while preserving the current health, special, score, luma, objective, combo, portrait, and meter information.
- The Stage 1 objective rail now uses short HUD-specific copy and a one-line top-center treatment, so the refreshed post-intro combat capture keeps the mission readable without covering the sky with a paragraph panel.
- Wave-start notice text now auto-clears after the intro beat, so the refreshed post-intro combat capture no longer carries stale centered `Sunset Overpass / Wave 1` text over the sky.
- The exported-app smoke path now captures a post-intro combat viewport after the Stage 1 intro strap has faded, giving cleaner launched-game fight evidence without claiming a human playtest.
- Pickups now use distinct data-driven health and luma/meter treatments, collection feedback, and a launched-app pickup clarity smoke capture.
- Stage 1 now triggers the updated spec's road-collapse beat after the opening cage-loading fight, briefly sells the luma extraction overload, and resumes combat on the lower service-lane wave.
- Brask now has data-driven intro, phase-change, and escape lines surfaced through the runtime HUD/combat banner path, with the intro captured by exported-app smoke.
- Hero select now uses canted arcade cards, selected-card glow, portrait wells, planned-hero silhouettes, and stat pips in the refreshed launched-app smoke capture.
- Hero select now also uses a canted arcade header/ribbon for `ARCADE CAMPAIGN` / `Choose Hero`, replacing plain floating heading text without overlapping cards or bottom controls in the refreshed launched-app smoke capture.
- Combat now has non-bloody hit bursts, timing rings, speed lines, hit stop, camera punch, combo/damage feedback, and existing input buffering.
- Stage Clear, Game Over restart, and return-to-title paths are covered by a Godot runtime smoke test.
- Stage Clear now hides stale hero-select cards, renders above stage combat FX, wraps long story text inside the viewport, uses a canted arcade result frame, and surfaces rank, score, luma, and health in the refreshed launched-app smoke capture.
- The Game Over/retry presentation now uses the same framed result treatment in the repeatable launched-app smoke capture.
- The exported-app smoke path now restarts Stage 1 after the Game Over presentation and captures post-retry gameplay from the running exported app.
- The macOS zip can be produced locally.
- The package audit now exposes release blockers instead of allowing the local zip to be mistaken for production-ready distribution.
- The release signing script now defines the guarded sign, notarize, staple, Gatekeeper-check, and artifact-audit path for a real Developer ID build, while staying blocked without local Apple credentials.
- The exported-app smoke script can repeatedly extract the zip, launch the app directly into the Stage 1 smoke mode, and capture title, hero-select, opening story, Stage 1 gameplay, post-intro combat, pickup clarity, road-collapse, Stage Clear, Game Over/retry, and post-retry gameplay viewports from the running exported app; staged capture replacement keeps the previous latest smoke evidence intact if a launch fails before new captures validate.
- Stage 1 now has a repeatable headless performance regression sample.
- Stage 1 now has a repeatable launched-app performance sample.
- Stage 1 now has local Apple Silicon Mac A, 1920x1080 windowed, and fullscreen launched-app performance samples.
- There is now a concrete external playtest packet for collecting replay intent, confusion, unfair damage reports, originality concerns, and willingness to pay/share/follow.
- There is now a known-tester packet command that bundles the selected package, validation logs, controller and second-machine checklists, and evidence for supervised sessions.
- There is now a playtest evidence gate command that blocks public-playtest-candidate status until the playtest log has enough external sessions, second-Mac coverage, physical controller-family coverage, and replay intent.
- There is now a playtest evidence collector command that reduces session-log recording friction without turning the evidence gate green by itself.
- There is now a second-machine evidence gate command that blocks release-candidate status until a real second Apple Silicon Mac records host, install, Gatekeeper, and launched-game capture proof.
- There is now a second-machine evidence collector command for known testers to generate the required host profile, package audit log, install smoke note, and title/gameplay captures on the actual second Mac.
- There is now a controller evidence gate command that blocks release-candidate status until two physical controller-family sessions and a manual exported-app keyboard fallback session record detailed control coverage backed by real capture files, package SHA metadata, signed package-source metadata, and special-meter-ready confirmation before the special action is counted.
- There is now a controller evidence collector command that reduces manual session recording friction without turning the evidence gate green by itself.

## Still Placeholder

- Actor sprites and background layers are project-bound placeholder art derived from generated source sheets, not final production sprite sheets.
- Audio is generated procedural placeholder tones/chords, not final composed music or authored SFX.
- The game is not yet proven commercially marketable. There is no external tester evidence that players love it or would buy it.
- The public playtest gate exists, but no outside sessions have been recorded against it.
- The exported-app manual input proof and smoke script confirm launch/keyflow and a survivable opening state, but they are still not substitutes for a recorded human playtest session.
- A successful signed/notarized release artifact has not been produced yet.
- Signing credentials, notarization, Gatekeeper acceptance, stapled ticket validation, physical controller-device testing, manual exported-app keyboard fallback, second Apple Silicon Mac coverage, and external tester distribution policy remain unresolved.

## Next Gate

Before calling the game marketable, run real player sessions against the packaged build and record whether players understand the goal, enjoy the first fight, want another run, and recognize the game as original.
