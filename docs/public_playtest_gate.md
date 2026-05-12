# Rift Road Public Playtest Gate

Use this packet before asking anyone outside the project to judge whether `Rift Road: Beasts of the Afterglow` is marketable. The goal is evidence, not reassurance.

## Current Build Under Test

- Package: `build/macos/Rift Road.zip`; signed/notarized release artifact path: `build/macos/Rift Road-signed-notarized.zip`
- Current package status: `RIFT_ROAD_PACKAGE_AUDIT internal-only`
- Smoke command: `bash scripts/smoke_exported_macos_app.sh`
- Validation command: `bash scripts/check.sh`
- Godot version gate command: `bash scripts/check_godot_version.sh`
- Package audit command: `bash scripts/audit_macos_package.sh`
- Release signing/notarization command: `bash scripts/sign_notarize_macos.sh`
- Release completion audit artifact: `build/release-gate/latest/completion-audit.md`
- Exported-app focus/resume smoke command: `bash scripts/smoke_exported_focus_resume.sh`
- Known-tester packet command: `bash scripts/prepare_known_tester_packet.sh`
- Controller validation checklist: `docs/controller_validation.md`
- Second-machine validation checklist: `docs/second_machine_validation.md`
- Second-machine evidence collector: `scripts/collect_second_machine_evidence.sh`
- Focus/audio evidence gate command: `bash scripts/check_focus_audio_evidence.sh`
- Controller evidence collector: `scripts/collect_controller_evidence.sh`
- Playtest evidence collector: `scripts/collect_playtest_evidence.sh`
- Playtest evidence gate command: `bash scripts/check_playtest_evidence.sh`
- Second-machine evidence gate command: `bash scripts/check_second_machine_evidence.sh`
- Controller evidence gate command: `bash scripts/check_controller_evidence.sh`
- Headless performance sample command: `godot --path src/wildcoil --headless --script "$PWD/src/wildcoil/tools/runtime_test_runner.gd" -- stage1_performance_sample`
- Exported-app performance sample command: `bash scripts/sample_exported_app_performance.sh`
- Optional local windowed 1080p performance sample command: `RIFT_ROAD_PERF_WINDOW_SIZE=1920x1080 RIFT_ROAD_PERF_WINDOW_MODE=windowed bash scripts/sample_exported_app_performance.sh build/macos/Rift\ Road.zip docs/playtest-captures/exported-app-performance-windowed-1080p-latest`
- Optional local fullscreen exported-app performance sample command: `RIFT_ROAD_PERF_WINDOW_SIZE=1920x1080 RIFT_ROAD_PERF_WINDOW_MODE=fullscreen bash scripts/sample_exported_app_performance.sh build/macos/Rift\ Road.zip docs/playtest-captures/exported-app-performance-fullscreen-latest`

Do not distribute this as a public build until the macOS signing, notarization, Gatekeeper, stapled-ticket, and second-machine install gates are resolved. Until then, treat it as a supervised internal or known-tester build.

## Preflight Checklist

Run and record these before every external-style session:

- [ ] `bash scripts/check.sh` passes.
- [ ] `bash scripts/check_godot_version.sh` reports `RIFT_ROAD_GODOT_VERSION ok` for the configured Godot 4.6.x stable executable.
- [ ] `bash scripts/package_macos.sh` regenerates `build/macos/Rift Road.zip`.
- [ ] If checking release-candidate status, `bash scripts/check_release_candidate.sh` writes `build/release-gate/latest/completion-audit.md` with a prompt-to-artifact checklist, `logs/release_signing.log` in the production-deployable build row, and Godot engine version-gate row for the active marketability objective.
- [ ] For any external-distribution candidate, `bash scripts/sign_notarize_macos.sh` produces `build/macos/Rift Road-signed-notarized.zip` and reports `RIFT_ROAD_RELEASE_SIGNING ok`; if it reports `RIFT_ROAD_RELEASE_SIGNING blocked`, keep the session internal-only.
- [ ] `bash scripts/prepare_known_tester_packet.sh` creates `build/known-tester-packet/latest/manifest.md` with the build commit, selected package SHA-256, release signing status/log, manual evidence gate statuses/logs, and the signed/notarized artifact when available.
- [ ] `bash scripts/audit_macos_package.sh` result is recorded, including any `internal-only` warnings.
- [ ] `bash scripts/smoke_exported_macos_app.sh` captures title, hero-select, Stage 1 gameplay, post-intro combat, Stage Clear, Game Over/retry, and post-retry gameplay viewports from the launched exported app.
- [ ] The latest `stage1_performance_sample` result is recorded.
- [ ] The latest exported-app performance result is recorded; run the windowed 1080p and fullscreen samples when the target session needs display-mode evidence.
- [ ] The tester knows whether they are playing a signed/notarized build or an internal-only build.
- [ ] Use `bash scripts/collect_focus_audio_evidence.sh --help` during manual focus/audio sessions to generate evidence notes before updating `docs/focus_audio_validation.md`; inside a signed known-tester packet, the collector records the selected signed artifact by default.
- [ ] `bash scripts/check_focus_audio_evidence.sh` reports `RIFT_ROAD_FOCUS_AUDIO_EVIDENCE ok` after a human confirms audible output before focus loss, quiet/suspended audio while focus-paused, and audible output after resume.
- [ ] `bash scripts/check_second_machine_evidence.sh` reports `RIFT_ROAD_SECOND_MACHINE_EVIDENCE ok` before any public-playtest or release-candidate distribution claim.
- [ ] Use `bash scripts/collect_controller_evidence.sh --help` during manual controller/keyboard sessions to generate evidence notes before updating `docs/controller_validation.md`; inside a signed known-tester packet, the collector records the selected signed artifact by default.
- [ ] `bash scripts/check_controller_evidence.sh` reports `RIFT_ROAD_CONTROLLER_EVIDENCE ok` after two physical controller-family sessions plus keyboard fallback.
- [ ] Use `bash scripts/collect_playtest_evidence.sh --help` after each external-style session to generate a session note and paste-ready log row; inside a signed known-tester packet, the collector records the selected signed artifact by default.
- [ ] After adding session rows to `docs/playtest_log.md`, every row has a real non-empty `Evidence capture` file and `bash scripts/check_playtest_evidence.sh` reports `RIFT_ROAD_PLAYTEST_EVIDENCE public-playtest-candidate` before making any public-playtest-candidate claim.

## Session Flow

Each session must cover the same minimum path:

1. Launch the exported app from the package named in the known-tester packet manifest; the local default is `build/macos/Rift Road.zip`, and a successful release signing run uses `build/macos/Rift Road-signed-notarized.zip`.
2. Start at the title screen.
3. Play title -> hero select -> Stage 1.
4. Reach at least one clear/fail/retry loop.
5. Try keyboard fallback; try a physical controller if one is available.
6. Record whether the tester wants another attempt without being prompted.

Do not coach the tester through basic controls unless they are blocked for more than 30 seconds. Confusion is evidence.

## Evidence Threshold

Minimum signal before calling the build a public playtest candidate:

- 5 to 8 external sessions recorded in `docs/playtest_log.md`.
- At least one session on a second Mac.
- `bash scripts/check_second_machine_evidence.sh` passes with proof from `docs/playtest-captures/second-machine-latest/`.
- At least two physical controller-family sessions.
- `bash scripts/check_controller_evidence.sh` passes with detailed control coverage in `docs/controller_validation.md`.
- No repeated launch, focus, input, or cheap-damage blocker across sessions.
- Most testers show replay intent or ask for another run.
- Testers can describe the hook without naming a different game first.
- At least half of testers say the game has a moment they would show someone else.
- `bash scripts/check_playtest_evidence.sh` must pass against the current `docs/playtest_log.md`; this is a minimum verifier, not a substitute for reading the notes.

Commercial or player-love claims require stronger evidence:

- Direct quotes that explain what players liked.
- Notes on willingness to pay, wishlist, follow, or share.
- Repeated positive reaction to the same hook, fight beat, character, or visual moment.
- Repeated criticism converted into tracked fixes or explicit scope decisions.

## Interview Prompts

Ask after the run, not during combat:

- What did you think the goal was?
- When did the game first feel good?
- What hit felt unfair or unclear?
- Which character, enemy, or screen detail do you remember?
- Did anything feel too familiar or derivative?
- Would you play another run right now?
- Would you wishlist, follow, share, or pay for this after more polish?
- What one change would most improve the next build?

## Decision Rules

Do not claim marketable from internal testing, automated tests, screenshots, or one enthusiastic player.

Use these labels:

- `Internal vertical slice`: local build launches and core flow works, but external evidence is missing.
- `Private playtest candidate`: signing/distribution risk is understood and known testers can follow the package instructions.
- `Public playtest candidate`: package distribution is resolved, repeated blockers are absent, and 5 to 8 external sessions show replay intent.
- `Release candidate`: public-playtest blockers are fixed, performance/input/package gates are clean, and player evidence supports the build quality.
- `Marketable claim`: only after player evidence and market-facing material show real interest, such as wishlist/follow/share/pay intent.

Do not claim marketable, production-ready, or player-loved unless the evidence threshold above is met and the market-readiness audit is updated with the proof.
