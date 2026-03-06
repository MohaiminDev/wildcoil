# Wildcoil macOS Build and Distribution Notes

This document defines the minimum tester-build path for the prototype and the validation checklist that keeps macOS a first-class target.

## Build Goal

Ship a tester-ready Apple Silicon build for the current progression-enabled vertical slice with:

- controller support
- keyboard fallback
- persistent save/profile support
- stage-select mission board shell
- repeatable packaging steps
- repeatable checksum output
- mirrored local and hosted validation steps
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

## Acceptance Matrix

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

Current Phase 2 packaging workflow:

1. Run `./scripts/check.sh` from the repo root and stop if any test fails.
2. Run `./scripts/package_macos.sh`.
3. Verify the bundle exists at `build/macos/Wildcoil.app`.
4. Verify the ZIP exists at `build/macos/Wildcoil-<build_label>-macos.zip`.
5. Verify the checksum file exists at `build/macos/Wildcoil-<build_label>-macos.zip.sha256`.
6. Launch the exported binary directly with `build/macos/Wildcoil.app/Contents/MacOS/Wildcoil`.
7. Smoke-check keyboard input, pause, fullscreen, and mission-board save data in the exported app.
8. If you need a deterministic local profile for smoke tests, launch with `WILDCOIL_SAVE_PATH=/absolute/path/to/profile.json build/macos/Wildcoil.app/Contents/MacOS/Wildcoil`.
9. Run `godot --path src/wildcoil --script res://tools/runtime_test_runner.gd -- --suite performance_sample` for the 1080p-equivalent local frame-rate sample.
10. If distributing externally, sign the bundle with the active Developer ID setup and notarize it.
11. On unsigned internal builds, tell testers to use Finder's `Open` flow or remove quarantine manually.

## Validation Automation

- Local gate: `./scripts/check.sh`
- Local packaging: `./scripts/package_macos.sh`
- Packaging guardrail: `scripts/package_macos.sh` reruns `./scripts/check.sh` unless `SKIP_CHECK=1` is set intentionally for a local iteration-only pass
- Hosted CI mirror: [`.github/workflows/macos-check.yml`](/Users/himu/Desktop/career/personal_projects/wildcoil/.github/workflows/macos-check.yml)
- CI scope: installs Godot on a macOS runner, installs `pytest`, and executes the same local validation gate used before task commits
- Export hygiene: the macOS export preset excludes local experimental `storm_warden_boss` scene/script files so untracked scratch assets do not leak into tester builds

## Build Notes Log

### Entry Template

- Date:
- Build label:
- Engine:
- Engine version:
- Xcode version:
- Export target:
- Packaging format:
- Checksum path:
- Signing status:
- Notarization status:
- Controller devices tested:
- Keyboard fallback tested:
- Save persistence tested:
- Validation gate:
- Issues found:
- Follow-up action:

### 2026-03-05 - Phase 1 First Playable

- Date: 2026-03-05
- Build label: `phase1-first-playable`
- Engine: Godot
- Engine version: 4.6.1.stable.official.14d19694e
- Xcode version: full Xcode not installed on this machine; unsigned export path used
- Export target: `build/macos/Wildcoil.app`
- Packaging format: `.app` bundle plus `build/macos/Wildcoil-phase1-first-playable-macos.zip`
- Artifact size: `.app` is `176M`; ZIP is `58M`
- ZIP SHA-256: `24de506ffa92db57469db7037be0be7a85c0cbab5a5af0c52707c629fc0c4837`
- Checksum path: manual terminal output only; no `.sha256` sidecar yet
- Binary architecture: universal Mach-O (`x86_64` and `arm64`)
- Signing status: ad hoc / linker-signed only; `spctl --assess -vv build/macos/Wildcoil.app` reports `source=no usable signature`
- Notarization status: not attempted; no Developer ID identity configured on this machine
- Controller devices tested: none attached during this pass; HUD reported `Connected pads: 0 [none]`
- Keyboard fallback tested: yes; exported app launched, moved into combat, paused with `Esc`, and toggled borderless fullscreen with `F`
- Save persistence tested: no; this build predates the progression shell
- Validation gate: local runtime and exported app smoke only
- Issues found: native AppKit fullscreen transitions were unstable under active screen capture, so the build now uses an in-game borderless fullscreen toggle instead of calling the macOS fullscreen transition directly
- Follow-up action: smoke-test a real controller, focus-loss/resume, and audio-device changes before external tester distribution

### 2026-03-05 - Phase 2 Progression Mission Board

- Date: 2026-03-05
- Build label: `phase2-progression`
- Engine: Godot
- Engine version: 4.6.1.stable.official.14d19694e
- Xcode version: full Xcode not installed on this machine; unsigned export path used
- Export target: `build/macos/Wildcoil.app`
- Packaging format: `.app` bundle plus `build/macos/Wildcoil-phase2-progression-macos.zip`
- Artifact size: `.app` is `176M`; ZIP is `59M`
- ZIP SHA-256: `3f8555a91f4e1d31870bec0163e1370c8de79e6875ecb9cec4fc492870c66874`
- Checksum path: `build/macos/Wildcoil-phase2-progression-macos.zip.sha256`
- Binary architecture: universal Mach-O (`x86_64` and `arm64`)
- Signing status: ad hoc / linker-signed only; `spctl --assess -vv build/macos/Wildcoil.app` reports `source=no usable signature`
- Notarization status: not attempted in this phase
- Controller devices tested: none attached during this pass
- Keyboard fallback tested: yes; live smoke entered the mission board and stage runtime successfully
- Save persistence tested: yes; the exported app saved borderless fullscreen to an isolated profile and relaunched back into that saved view state
- Validation gate: `./scripts/check.sh`, `./scripts/package_macos.sh`, and live local smoke using a saved profile override
- Issues found: focus-loss/resume, audio-device change, and controller-device coverage still need dedicated release-candidate validation; the export preset excludes the local `storm_warden_boss` experiments so untracked test files do not leak into packaged artifacts
- Follow-up action: repeat the smoke pass against the packaged app with a physical controller attached, then cover focus-loss/resume and audio-device changes during the release-candidate gate

### 2026-03-05 - Phase 3 Release Candidate

- Date: 2026-03-05
- Build label: `phase3-finale`
- Engine: Godot
- Engine version: 4.6.1.stable.official.14d19694e
- Xcode version: full Xcode not installed on this machine; unsigned export path used
- Export target: `build/macos/Wildcoil.app`
- Packaging format: `.app` bundle plus `build/macos/Wildcoil-phase3-finale-macos.zip`
- Artifact size: `.app` is `176M`; ZIP is `58M`
- ZIP SHA-256: `9ac87a38a56238b459cffda985c8fbecd4f6817da90c82342d750120853c2e64`
- Checksum path: `build/macos/Wildcoil-phase3-finale-macos.zip.sha256`
- Binary architecture: universal Mach-O (`x86_64` and `arm64`)
- Signing status: ad hoc / linker-signed only; `spctl --assess -vv build/macos/Wildcoil.app` reports `source=no usable signature`
- Notarization status: not attempted in this phase; no Developer ID identity configured on this machine
- Controller devices tested: no physical controller attached during the release-candidate pass; synthetic controller coverage still passes in the runtime suite
- Keyboard fallback tested: yes; packaged app launched, deployed into Stage 1, survived focus-loss auto-pause, and resumed cleanly
- Save persistence tested: yes; packaged app launched against an isolated profile override without regression
- Focus-loss / resume tested: yes; switching to Finder and back returned the app to an auto-paused overlay
- Audio-device change tested: yes; output switched from `iMac Speakers` to `ATR2100x-USB Microphone` and back while the packaged app stayed responsive
- Performance sample: `godot --path src/wildcoil --script res://tools/runtime_test_runner.gd -- --suite performance_sample` reported `60.13 FPS` average with a `59 FPS` 5th-percentile floor at `960x540` points on a `2.0` scale display, which is a 1080p-equivalent sample on this Retina panel
- Validation gate: `./scripts/check.sh`, `./scripts/package_macos.sh`, packaged-app live smoke, `SwitchAudioSource` output swap, and the performance sample suite
- Issues found: physical controller hardware is still unavailable on this machine, and the app remains unsigned and unnotarized
- Follow-up action: publish the internal tester release with keyboard-first install notes, then use the release itself to gather physical-controller and outside-tester feedback
