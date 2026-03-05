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
