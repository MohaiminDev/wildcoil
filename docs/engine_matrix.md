# Wildcoil Engine Matrix

This document is the Phase 0 engine decision workspace. It locks the evaluation method now so later scoring reflects evidence rather than shifting criteria.

## Decision Rule

Run the same micro-spike in Godot, Unity, and Unreal:

- movement controller
- one combo string
- one enemy
- controller input
- macOS export
- packaging friction notes

Then score each engine with these fixed weights:

| Criterion | Weight | What counts as evidence |
| --- | --- | --- |
| Gameplay iteration | 25 | Time-to-change, time-to-test, edit/run friction, debugging clarity |
| macOS tooling / export | 20 | Export success, packaging friction, docs clarity, codesign/notarize path clarity |
| Responsiveness / input workflow | 15 | Controller setup quality, input rebinding workflow, hot-plug behavior, latency feel |
| Art / animation workflow | 15 | Placeholder asset import, animation state iteration, VFX integration comfort |
| Open-source posture | 15 | License cleanliness, dependency risk, future contributor and repo openness practicality |
| Performance headroom | 10 | Frame stability on Apple Silicon at 1080p in the spike |

Scoring scale:
- `1`: actively painful or risky
- `3`: workable with caveats
- `5`: strong fit for this project

## Official Source Snapshot

Current official sources reviewed on 2026-03-05:

- [Godot macOS export](https://docs.godotengine.org/en/latest/tutorials/export/exporting_for_macos.html)
- [Godot controller support](https://docs.godotengine.org/en/stable/tutorials/inputs/controllers_gamepads_joysticks.html)
- [Godot license FAQ](https://docs.godotengine.org/en/stable/about/faq.html)
- [Unity 6 macOS requirements](https://docs.unity3d.com/6000.0/Documentation/Manual/macos-requirements-and-compatibility.html)
- [Unity macOS signing/notarization](https://docs.unity3d.com/2022.3/Documentation/Manual/macos-building-notarization.html)
- [Unreal macOS requirements](https://dev.epicgames.com/documentation/en-us/unreal-engine/macos-development-requirements-for-unreal-engine)
- [Apple Developer ID / notarization](https://developer.apple.com/support/developer-id/)

Source caveat:
- The Godot export page above is on the `latest` docs track and should be rechecked against the specific stable engine version if Godot wins.

## Machine Audit on 2026-03-05

Current machine state verified in the local shell:

| Item | Local state | Evidence | Impact on the spikes |
| --- | --- | --- | --- |
| Godot | Installed and launchable via Homebrew cask | `godot` resolves to `/opt/homebrew/bin/godot`; version `4.6.1.stable.official.14d19694e`; app at `/Applications/Godot.app` | Ready for the Godot spike |
| Unity Hub | Installed and Gatekeeper-valid | App at `/Applications/Unity Hub.app`; headless CLI is available; install path defaults to `/Applications/Unity/Hub/Editor` | Hub is ready, but no editor is installed yet |
| Unity Editor | Not installed | `Unity Hub -- --headless editors --installed --json` returned `[]`; `/Applications/Unity/Hub/Editor` has no editor content yet | Unity spike is blocked until an editor is installed, which may require additional download time and interactive sign-in or licensing |
| Epic Games Launcher | Installed and Gatekeeper-valid | App at `/Applications/Epic Games Launcher.app` | Launcher is present, but it is not the Unreal Editor |
| Unreal Editor | Not installed | No `UnrealEditor.app` found under `/Applications` | Unreal spike is blocked until the editor is downloaded through Epic's tooling, which is likely to require interactive sign-in |
| Xcode | Full app missing | `/Applications/Xcode.app` is absent; `xcodebuild -version` fails because `xcode-select` points at `/Library/Developer/CommandLineTools` | Full Xcode-dependent export workflows are blocked right now |
| Packaging tools | Present in Command Line Tools | `xcrun notarytool` is available; `codesign`, `pkgbuild`, `productbuild`, and `spctl` resolve locally | Signing and packaging experiments are partly available even before full Xcode is installed |

Machine-level conclusion:
- Godot is the only engine that is immediately ready for a real local spike.
- Unity is partially prepared because the Hub and headless CLI are installed, but the editor itself is still missing.
- Unreal is only prepared at the launcher level, and the actual editor is still unavailable.
- Full Xcode is still missing, so any workflow that depends on `xcodebuild` remains blocked until the app is installed and selected.

## Pre-Spike Evidence Notes

These notes are not final scores. They only seed the experiment with what the official docs already imply.

| Engine | Pre-spike notes from official sources | Early implication for Wildcoil |
| --- | --- | --- |
| Godot | The macOS export docs describe direct export packaging to `.app`, ZIP, DMG, and PKG targets with codesign and notarization-related settings. The controller docs note SDL 3-backed support for modern controllers, and the FAQ confirms Godot is MIT-licensed and free/open source. | Strong early signal for macOS practicality and open-source posture. Real test still needed for animation workflow, input feel, and export friction. |
| Unity | Unity 6 macOS requirements document current editor/runtime compatibility and points to Apple Silicon support plus Xcode requirements for some build paths. Unity's notarization guide documents a supported signing/notarization process rather than leaving it to guesswork. | Likely safe on tooling maturity, but must prove that the day-to-day prototype loop beats the extra packaging and proprietary-engine complexity. |
| Unreal | Epic's macOS requirements guidance currently emphasizes Apple Silicon, current macOS/Xcode baselines, and feature limitations that vary by hardware generation. | Visual ceiling may be attractive, but the spike must prove that editor weight, build friction, and frame stability fit a solo part-time prototype. |

## Weighted Scorecard

Fill this table only after each spike has equivalent evidence.

| Criterion | Weight | Godot score | Unity score | Unreal score | Evidence note |
| --- | --- | --- | --- | --- | --- |
| Gameplay iteration | 25 | TBD | TBD | TBD | Measure minutes from idea to playable change |
| macOS tooling / export | 20 | TBD | TBD | TBD | Include export blockers and packaging notes |
| Responsiveness / input workflow | 15 | TBD | TBD | TBD | Include controller reliability and feel notes |
| Art / animation workflow | 15 | TBD | TBD | TBD | Judge placeholder import and animation iteration comfort |
| Open-source posture | 15 | TBD | TBD | TBD | Note engine license and dependency cleanliness implications |
| Performance headroom | 10 | TBD | TBD | TBD | Capture FPS and frame-time stability at 1080p |
| Weighted total | 100 | TBD | TBD | TBD | Calculate only after all rows are filled |

## Spike Checklist

Use the same checklist for every engine:

1. Create one movement controller with run, jump, and dodge.
2. Implement one light combo string plus heavy finisher.
3. Implement one enemy archetype with readable telegraph and reaction.
4. Connect one controller and verify keyboard fallback.
5. Export a macOS build.
6. Record packaging friction notes.
7. Capture FPS/frame-time notes on Apple Silicon.
8. Write what felt easy, slow, unclear, or brittle.

## Evidence Log Template

### Godot

- Spike status: ready to start
- Export result: TBD
- Controller result: TBD
- Performance result: TBD
- Workflow notes: Godot 4.6.1 is installed locally and launchable from `/opt/homebrew/bin/godot`.
- Packaging notes: CLT packaging tools exist locally; full Xcode is still missing for `xcodebuild`-dependent workflows.
- Score summary: TBD

### Unity

- Spike status: blocked on editor install
- Export result: TBD
- Controller result: TBD
- Performance result: TBD
- Workflow notes: Unity Hub 3.16.3 is installed locally and exposes the headless CLI, but no editor is installed yet.
- Packaging notes: Expect additional install time plus possible sign-in or licensing steps before the spike can begin.
- Score summary: TBD

### Unreal

- Spike status: blocked on editor install
- Export result: TBD
- Controller result: TBD
- Performance result: TBD
- Workflow notes: Epic Games Launcher 19.2.0 is installed locally, but no Unreal Editor bundle is present.
- Packaging notes: Expect interactive Epic login and a large editor download before the spike can begin.
- Score summary: TBD

## Tie-Break Rule

- If the top two engines are close, choose Godot for the prototype.
- Override that tie-break only if Unity clearly wins gameplay iteration or art-animation throughput.
- Use Unreal only if the visual target truly cannot be met elsewhere without unacceptable compromise.

## Decision Status

- Current status: no engine approved yet
- Current best provisional path: Godot by tie-break preference only
- Required before approval: completed spikes, completed weighted totals, updated risk review, and a written go/no-go note in [`docs/game_spec.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/game_spec.md)
