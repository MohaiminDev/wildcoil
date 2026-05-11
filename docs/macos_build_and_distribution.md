# Wildcoil macOS Build and Distribution Notes

This document defines the minimum tester-build path for the prototype and the validation checklist that keeps macOS a first-class target.

## Build Goal

Ship a tester-ready Apple Silicon build for the Phase 1 first playable with:

- controller support
- keyboard fallback
- repeatable packaging steps
- clear signing / notarization checklist
- explicit manual acceptance checks

## Official Sources Reviewed On 2026-03-05

- [Godot macOS export](https://docs.godotengine.org/en/latest/tutorials/export/exporting_for_macos.html)
- [Godot controller support](https://docs.godotengine.org/en/stable/tutorials/inputs/controllers_gamepads_joysticks.html)
- [Unity 6 macOS requirements](https://docs.unity3d.com/6000.0/Documentation/Manual/macos-requirements-and-compatibility.html)
- [Unity macOS signing/notarization](https://docs.unity3d.com/2022.3/Documentation/Manual/macos-building-notarization.html)
- [Unreal macOS requirements](https://dev.epicgames.com/documentation/en-us/unreal-engine/macos-development-requirements-for-unreal-engine)
- [Apple Developer ID / notarization](https://developer.apple.com/support/developer-id/)

## Apple Baseline

Before external distribution, expect to need:

- a Developer ID certificate
- a signed app bundle
- a notarization submission
- a stapled notarization ticket or equivalent deliverable
- a quick Gatekeeper sanity check on a second machine

Unsigned or unnotarized prototype builds may still be useful internally, but they do not satisfy the longer-term platform path.

## Engine-Specific Planning Notes

### Godot

- Official docs describe macOS exports to `.app`, ZIP, DMG, and PKG formats.
- The export flow includes macOS-specific signing and notarization fields.
- The controller documentation states that current controller support is SDL 3-based, which is a good early sign for device coverage.
- If Godot wins, re-check the exact stable-version export docs before locking the build instructions.

### Unity

- Unity documents macOS compatibility for current editor/runtime versions and points to Xcode requirements for relevant build workflows.
- Unity also maintains a specific macOS signing/notarization guide, which lowers process ambiguity.
- If Unity wins, document the precise editor version, Xcode version, and export player settings used for the first stable tester build.

### Unreal

- Epic's current macOS requirements guidance emphasizes recent Apple Silicon, macOS, and Xcode baselines and notes that some rendering features vary by hardware generation.
- If Unreal wins, treat build size, feature toggles, and Apple Silicon frame stability as immediate risks rather than later polish concerns.

## Phase 1 Acceptance Matrix

Run these checks before calling the prototype tester-ready:

| Area | Check | Pass condition |
| --- | --- | --- |
| Hardware | Apple Silicon Mac A | Build launches and runs the test slice without critical issues |
| Hardware | Apple Silicon Mac B | Same as above on a second machine |
| Input | Controller family 1 | Full session works without blocking issues |
| Input | Controller family 2 | Full session works without blocking issues |
| Input | Keyboard-only fallback | Entire session remains playable |
| Windowing | Windowed mode | HUD, focus, and input remain stable |
| Windowing | Fullscreen mode | HUD, focus, and input remain stable |
| OS behavior | Focus-loss / resume | Game recovers cleanly |
| OS behavior | Audio-device change | Audio resumes correctly |
| Performance | 1080p frame target | Roughly 60 FPS target on target hardware |
| Packaging | Tester package flow | Another person can follow the steps |

## Packaging Workflow Template

Complete and refine this after the winning engine spike:

1. Export the macOS build from the chosen engine.
2. Verify local launch on the development machine.
3. Package the app in the chosen distribution wrapper for testers.
4. If distributing externally, sign the bundle with the current Developer ID setup.
5. Submit for notarization when appropriate.
6. Verify the notarized build on a second machine.
7. Record any warnings, exceptions, or extra setup steps here.

## Build Notes Log

### Entry Template

- Date:
- Engine:
- Engine version:
- Xcode version:
- Export target:
- Packaging format:
- Signing status:
- Notarization status:
- Controller devices tested:
- Keyboard fallback tested:
- Issues found:
- Follow-up action:
# Rift Road Prototype Addendum

As of 2026-04-27, the Rift Road prototype uses Godot 4.x under `src/wildcoil`.

## Local Commands

- Run checks: `bash scripts/check.sh`
- Run game: `bash scripts/run_game.sh`
- Package macOS build: `bash scripts/package_macos.sh`
- Check signing/notarization preflight: `bash scripts/check_macos_signing_env.sh`
- Audit macOS package status: `bash scripts/audit_macos_package.sh`
- Smoke launched exported app: `bash scripts/smoke_exported_macos_app.sh`
- Smoke launched exported app keyboard fallback: `bash scripts/smoke_exported_keyboard_fallback.sh`
- Sample launched-app performance: `bash scripts/sample_exported_app_performance.sh`
- Prepare known-tester packet: `bash scripts/prepare_known_tester_packet.sh`
- Check playtest evidence threshold: `bash scripts/check_playtest_evidence.sh`
- Check second-machine evidence threshold: `bash scripts/check_second_machine_evidence.sh`
- Check physical controller evidence threshold: `bash scripts/check_controller_evidence.sh`
- Check release-candidate gate: `bash scripts/check_release_candidate.sh`

`GODOT_BIN` can point to a custom Godot executable when `godot` is not on `PATH`.

## Current Packaging State

The repository includes `src/wildcoil/export_presets.cfg` with a macOS export preset named `macOS`. Local export still depends on Godot macOS export templates being installed on the machine.

On 2026-04-27, `bash scripts/package_macos.sh` succeeded locally with Godot 4.6.1 and created:

- `build/macos/Rift Road.zip`

The exported archive contains `Rift Road- Beasts of the Afterglow.app`.

On 2026-05-10, `bash scripts/audit_macos_package.sh` was added to inspect the exported zip, app bundle metadata, `codesign`, Gatekeeper assessment through `spctl`, and notarization ticket status through `stapler`.

The expected current result is `RIFT_ROAD_PACKAGE_AUDIT internal-only`: the build can be inspected and launched locally, but the export preset still has an empty Developer ID identity, an empty Apple Team ID, and notarization disabled. That means this package is not release-candidate or external-distribution ready until signing, notarization, and second-machine install checks are resolved.

Also on 2026-05-10, `bash scripts/check_macos_signing_env.sh` was added to check non-secret signing prerequisites before external release work: `RIFT_ROAD_APPLE_TEAM_ID`, `RIFT_ROAD_DEVELOPER_ID_APPLICATION`, `RIFT_ROAD_NOTARY_KEYCHAIN_PROFILE`, `security find-identity`, `xcrun notarytool`, and the Godot export-preset signing/notarization fields. The expected current result is `RIFT_ROAD_SIGNING_PREFLIGHT blocked` until real Developer ID and notary configuration exists.

Also on 2026-05-10, `bash scripts/smoke_exported_macos_app.sh` was added as a repeatable local proof that the exported zip can be extracted and launched through LaunchServices with `open -n`. It passes `--rift-road-smoke-capture-dir=...` so the running exported app writes title, hero-select, opening story, Stage 1 gameplay, post-intro combat, pickup clarity, road-collapse, Brask intro, Stage Clear, Game Over/retry, and post-retry gameplay viewport captures even when macOS opens the window in a Space that `screencapture` cannot access. The expected success marker is `RIFT_ROAD_EXPORTED_APP_SMOKE ok`. This is launched-app evidence only; it does not replace human playtest, second-machine install, signing, notarization, or Gatekeeper acceptance.

Also on 2026-05-11, `bash scripts/smoke_exported_keyboard_fallback.sh` was added to extract the exported zip, launch the `.app` through LaunchServices with `--rift-road-keyboard-fallback-smoke`, and record `docs/playtest-captures/keyboard-fallback-latest/stage1-exported-app-keyboard-fallback.json` plus `stage1-exported-app-keyboard-fallback.png`. The expected success marker is `RIFT_ROAD_EXPORTED_KEYBOARD_FALLBACK ok`. This proves automated exported-app keyboard fallback behavior; it does not replace the manual keyboard fallback row or physical controller-family sessions required by `docs/controller_validation.md`.

Also on 2026-05-10, `bash scripts/sample_exported_app_performance.sh` was added to launch the packaged app with `--rift-road-render-perf-sample`, wait for a JSON timing artifact, and report `RIFT_ROAD_EXPORTED_PERF stage1` when the rendered app stays inside the current frame budget. The sampler resolves package/output paths to absolute paths before launching the `.app`, excludes explicit startup/render warmup frames from the steady-state gameplay budget, and accepts `RIFT_ROAD_PERF_WINDOW_SIZE` / `RIFT_ROAD_PERF_WINDOW_MODE` for local window-size and display-mode evidence. Local Apple Silicon Mac A, windowed, and fullscreen samples now exist, but second-machine validation still needs separate proof.

Also on 2026-05-10, `bash scripts/check_release_candidate.sh` was added to combine the automated release gates: repository validation, signing preflight, package rebuild, package audit, exported-app smoke capture, exported-app keyboard fallback smoke, exported-app performance, and Stage 1 headless performance sample. It intentionally reports `RIFT_ROAD_RELEASE_GATE blocked` while the signing preflight is blocked, the package audit is not `RIFT_ROAD_PACKAGE_AUDIT release-candidate`, or the market-readiness audit still marks public playtest/player-love proof as not achieved.

Also on 2026-05-10, `bash scripts/prepare_known_tester_packet.sh` was added to create `build/known-tester-packet/latest/` with the rebuilt `Rift Road.zip`, validation logs, package audit, exported-app smoke captures, exported-app keyboard fallback evidence, exported-app performance JSON, host profile, and the current playtest protocol/docs. The packet is still labeled `internal-only` while signing/notarization and package audit gates are blocked; it exists to make supervised known-tester sessions repeatable, not to approve public distribution.

Also on 2026-05-10, `bash scripts/check_playtest_evidence.sh` was added to read `docs/playtest_log.md` and block public-playtest-candidate status until the log records at least five external sessions, at least one `machine=second-mac` setup, at least two physical `controller-family=<family>` inputs, and majority replay intent. The release-candidate gate now treats this as a blocker while the log has no external rows.

Also on 2026-05-10, `bash scripts/check_second_machine_evidence.sh` and `docs/second_machine_validation.md` were added to block release-candidate claims until a real second Apple Silicon Mac records host profile, install smoke, Gatekeeper acceptance, and title/gameplay captures under `docs/playtest-captures/second-machine-latest/`. The expected current result is `RIFT_ROAD_SECOND_MACHINE_EVIDENCE blocked`.

Also on 2026-05-10, `bash scripts/check_controller_evidence.sh` and `docs/controller_validation.md` were added to block release-candidate claims until two real physical controller-family sessions plus keyboard fallback record title, hero select, Stage 1 movement, attack, jump, special, dash, pause, and cancel/back as `pass`. On 2026-05-11, the gate was hardened to reject marked sessions with missing or `TBD` build, device, connection, evidence-capture, or blocker metadata, so placeholder rows cannot satisfy the controller evidence gate. The expected current result is `RIFT_ROAD_CONTROLLER_EVIDENCE blocked`.

Also on 2026-05-10, baseline gamepad input support was added for menu flow, pause, movement, attack, jump, special, dash, and hero selection. The current automated proof uses simulated `InputEventJoypadButton` events in Godot, not a physical controller. Before calling a tester package ready, run at least two physical controller-family sessions and record the devices in this document.
