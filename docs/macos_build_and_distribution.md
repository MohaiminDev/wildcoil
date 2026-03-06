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

Current Phase 1 first-playable workflow:

1. Run `./scripts/export_macos.sh` from the repo root.
2. Verify the bundle exists at `build/macos/Wildcoil.app`.
3. Package the tester ZIP with `ditto -c -k --sequesterRsrc --keepParent build/macos/Wildcoil.app build/macos/Wildcoil-phase1-first-playable-macos.zip`.
4. Launch the exported binary directly with `build/macos/Wildcoil.app/Contents/MacOS/Wildcoil`.
5. Smoke-check keyboard input, pause, and fullscreen in the exported app.
6. If distributing externally, sign the bundle with the active Developer ID setup and notarize it.
7. On unsigned internal builds, tell testers to use Finder's `Open` flow or remove quarantine manually.

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

### 2026-03-05 - Phase 1 First Playable

- Date: 2026-03-05
- Engine: Godot
- Engine version: 4.6.1.stable.official.14d19694e
- Xcode version: full Xcode not installed on this machine; unsigned export path used
- Export target: `build/macos/Wildcoil.app`
- Packaging format: `.app` bundle plus `build/macos/Wildcoil-phase1-first-playable-macos.zip`
- Artifact size: `.app` is `176M`; ZIP is `58M`
- ZIP SHA-256: `24de506ffa92db57469db7037be0be7a85c0cbab5a5af0c52707c629fc0c4837`
- Binary architecture: universal Mach-O (`x86_64` and `arm64`)
- Signing status: ad hoc / linker-signed only; `spctl --assess -vv build/macos/Wildcoil.app` reports `source=no usable signature`
- Notarization status: not attempted; no Developer ID identity configured on this machine
- Controller devices tested: none attached during this pass; HUD reported `Connected pads: 0 [none]`
- Keyboard fallback tested: yes; exported app launched, moved into combat, paused with `Esc`, and toggled borderless fullscreen with `F`
- Issues found: native AppKit fullscreen transitions were unstable under active screen capture, so the build now uses an in-game borderless fullscreen toggle instead of calling the macOS fullscreen transition directly
- Follow-up action: smoke-test a real controller, focus-loss/resume, and audio-device changes before external tester distribution
