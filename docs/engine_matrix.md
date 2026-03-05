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
| Unity Hub | Installed and Gatekeeper-valid | App at `/Applications/Unity Hub.app`; headless CLI is available; install path defaults to `/Applications/Unity/Hub/Editor` | Hub is ready and can manage editor installs |
| Unity Editor | Installed with macOS playback support on disk | Editor at `/Applications/Unity/Hub/Editor/6000.3.10f1/Unity.app`; `MacStandaloneSupport` exists under `Unity.app/Contents/PlaybackEngines/` | Binary prerequisites are present, but project work is blocked by missing Unity license activation |
| Epic Games Launcher | Installed and Gatekeeper-valid | App at `/Applications/Epic Games Launcher.app` | Launcher is present, but it is not the Unreal Editor |
| Unreal Editor | Not installed | No `UnrealEditor.app` found under `/Applications` | Unreal spike is blocked until the editor is downloaded through Epic's tooling, which is likely to require interactive sign-in |
| Xcode | Full app missing | `/Applications/Xcode.app` is absent; `xcodebuild -version` fails because `xcode-select` points at `/Library/Developer/CommandLineTools` | Full Xcode-dependent export workflows are blocked right now |
| Packaging tools | Present in Command Line Tools | `xcrun notarytool` is available; `codesign`, `pkgbuild`, `productbuild`, and `spctl` resolve locally | Signing and packaging experiments are partly available even before full Xcode is installed |

Machine-level conclusion:
- Godot is the only engine that is immediately ready for a real local spike.
- Unity is installed far enough to launch the editor and verify that macOS playback support files exist, but project work is blocked by editor licensing.
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

Scoring note:
- Godot scores below are based on the completed local spike.
- Unity and Unreal scores are intentionally conservative where blocked setup prevented equivalent hands-on evidence on this machine.

| Criterion | Weight | Godot score | Unity score | Unreal score | Evidence note |
| --- | --- | --- | --- | --- | --- |
| Gameplay iteration | 25 | 5 | 1 | 1 | Godot reached a playable spike quickly; Unity was blocked by licensing before project creation; Unreal was blocked before editor install. |
| macOS tooling / export | 20 | 4 | 1 | 1 | Godot exported an unsigned `.app` locally without full Xcode; Unity export was not reachable; Unreal export was not reachable. |
| Responsiveness / input workflow | 15 | 4 | 1 | 1 | Godot keyboard fallback and controller mappings were implemented in the spike; blocked engines never reached equivalent input testing. |
| Art / animation workflow | 15 | 4 | 1 | 1 | Godot placeholder scene and animation iteration were workable in the live spike; blocked engines could not be evaluated fairly on this machine. |
| Open-source posture | 15 | 5 | 2 | 1 | Godot's MIT license and repo openness are strong fits; Unity and Unreal remain proprietary and more account-gated. |
| Performance headroom | 10 | 4 | 1 | 1 | Godot held near 60 FPS in the exported Apple Silicon app and much higher in headless autoplay; blocked engines produced no comparable local benchmark. |
| Weighted total | 100 | 88 | 23 | 20 | Weighted totals use `weight * score / 5`, rounded to whole numbers. |

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

## Evidence Log

### Godot

- Spike status: completed locally on 2026-03-05
- Export result: success. Unsigned macOS app exported to `spikes/godot_artifacts/WildcoilGodotSpike.app` at roughly 176 MB.
- Controller result: keyboard fallback works in local runs; controller mappings were wired to left stick plus A/B/X/Y, but no physical controller was attached during this shell session for a live hardware check.
- Performance result: `144.88` average FPS / `144.00` low FPS in the final headless autoplay benchmark; `60.00` average FPS in the editor-backed Metal autoplay benchmark; `59.83` average FPS / `58.00` low FPS in the final exported macOS app autoplay benchmark on Apple M1.
- Workflow notes: the spike lives at `spikes/godot_wildcoil_spike`; the project was authored from text, imported cleanly after a few script fixes, and validated with both autoplay benchmarks and frame capture.
- Packaging notes: successful export required enabling `rendering/textures/vram_compression/import_etc2_astc=true`, downloading the official `Godot_v4.6.1-stable_export_templates.tpz`, and extracting `templates/macos.zip` to `~/Library/Application Support/Godot/export_templates/4.6.1.stable/`. Full Xcode was not required for an unsigned local export.
- Score summary: strong early signal on iteration speed, open-source posture, and unsigned macOS export practicality.

### Unity

- Spike status: blocked on license activation before project creation
- Export result: not reached. The editor exits before project creation or build steps because no valid Unity Editor license is active on this machine.
- Controller result: not reached because no runnable Unity project was created in this session.
- Performance result: not reached because no runnable Unity project was created in this session.
- Workflow notes: Unity Hub 3.16.3 successfully listed Apple Silicon releases; Unity 6000.3.10f1 installed to `/Applications/Unity/Hub/Editor/6000.3.10f1/Unity.app`; Rosetta 2 was installed; batchmode launch then failed with `No valid Unity Editor license found. Please activate your license.`
- Packaging notes: `MacStandaloneSupport` exists under `Unity.app/Contents/PlaybackEngines/`, so the macOS payload appears present even though the Hub reported a failed module install. The real blocker is licensing, not the editor download.
- Score summary: blocked. The editor cannot be scored fairly for iteration or export until a valid license is activated on this machine.

### Unreal

- Spike status: blocked on editor install and Epic sign-in
- Export result: not reached. No Unreal Editor bundle is installed on this machine, so no project or macOS export could be created.
- Controller result: not reached because no runnable Unreal project was created in this session.
- Performance result: not reached because no runnable Unreal project was created in this session.
- Workflow notes: Epic Games Launcher 19.2.1 launches locally on Apple M1; `~/Library/Application Support/Epic/UnrealEngineLauncher/LauncherInstalled.dat` currently contains an empty `InstallationList`; the launcher log records `Discovered 0 item files` and then routes to `epic-login`, which confirms an interactive Epic account step before editor download.
- Packaging notes: The Unreal spike cannot begin until the editor is downloaded through Epic's distribution flow. That path is both larger and more account-gated than the Godot path on this machine.
- Score summary: blocked. Unreal cannot be scored fairly for iteration, export, or performance until the editor is installed.

## Tie-Break Rule

- If the top two engines are close, choose Godot for the prototype.
- Override that tie-break only if Unity clearly wins gameplay iteration or art-animation throughput.
- Use Unreal only if the visual target truly cannot be met elsewhere without unacceptable compromise.

## Decision Status

- Current status: Godot approved on 2026-03-05 for the production path
- Go decision: proceed with Godot 4.6.1 and begin the Phase 1 production scaffold
- No-go for now: Unity remains blocked by editor licensing on this machine; Unreal remains blocked by editor install plus Epic sign-in
- Backlog status: freeze the MVP backlog to the current Phase 1 through release tasks in [`to-do.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/to-do.md) until playtest evidence or risk review justifies a change
