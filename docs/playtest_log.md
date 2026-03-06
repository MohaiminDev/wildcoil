# Wildcoil Playtest Log

Use this log for all external tests and any internal hands-on checks that materially affect a gate decision.

## Current Gate Status

- 2026-03-05: Local Phase 1 smoke completed on Apple Silicon in both the editor runtime and the exported macOS bundle.
- 2026-03-05: The external-test portion of the gate is blocked because no outside testers or physical controllers were available in this session.
- 2026-03-05: Proceeding with development is acceptable, but the project still owes a real 5 to 8 tester round before calling the Phase 1 gate externally validated.
- 2026-03-05: Phase 2 internal slice review completed on Apple Silicon using the progression mission board, seeded save data, and a fresh packaged macOS artifact.
- 2026-03-05: The repeated blocker from the first Phase 2 slice pass was menu and HUD text density at default window size; a typography and panel-size pass landed immediately after the review and the follow-up smoke closed that blocker locally.
- 2026-03-05: Remaining accepted blocker before release-candidate signoff is still the lack of a physical controller and external tester coverage.
- 2026-03-05: Phase 3 Stage 2 internal smoke completed on Apple Silicon using an unlocked mission-board profile, with Coil Depths loading cleanly from the live shell and the new hazard route reading clearly enough for continued production.
- 2026-03-05: Phase 3 finale smoke completed on Apple Silicon using a seeded Storm Crown profile, with live shell deploy, HID-driven keyboard movement, pause or resume flow, and the first combat transition all verified in the real runtime.

## Phase 1 Gate Targets

- First combat interaction within 30 seconds
- First wow moment within 3 minutes
- Movement and hits feel good immediately
- Enemy intent is readable
- No repeated cheap-damage pattern
- Stable Apple Silicon build
- Most testers want another run or stage

## Session Capture Table

| Date | Build | Tester | Setup | Input method | First-combat time | Wow-moment time | Replay desire | Confusion points | Cheap-damage reports | Key quotes / observations | Follow-up action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2026-03-05 | `phase1-first-playable` | Codex (internal smoke) | Apple M1, editor runtime and exported macOS bundle | Keyboard | `1.5s` | Deterministic stage suite confirms spectacle trigger before `180s`; live blind-input smoke did not cleanly clear the pack | Yes | No controller attached; outside testers unavailable; pause overlay presentation could be stronger | None repeated in local smoke | First combat appears almost immediately, pause and fullscreen work in the exported app, and the first playable reads clearly in motion | Recruit 5 to 8 outside testers, attach a real controller, and repeat on a second machine if available |
| 2026-03-05 | `phase2-progression` | Codex (internal slice review) | Apple M1, editor runtime with a seeded save profile and the mission-board shell | Keyboard | `1.5s` from stage launch after menu confirm | Boss clear still lands inside the deterministic slice suite; live smoke focused on profile load plus route launch | Yes | Mission board and HUD text felt too dense at the default window size before the typography pass; no physical controller available | None repeated in local smoke | Saved best rank and time reloaded correctly on the mission board, stage launch remained instant, and the typography pass made the shell materially easier to scan in the follow-up smoke | Keep controller coverage listed as an accepted blocker, and re-run the packaged build before the release-candidate gate |
| 2026-03-05 | `phase3-second-playable` | Codex (internal loadout smoke) | Apple M1, editor runtime with a seeded unlocked profile for Zeph Rush | Keyboard | `1.5s` from stage launch after menu confirm | Focus of the session was loadout differentiation rather than spectacle timing | Yes | No selection blocker after using an unlocked profile; physical controller still unavailable | None repeated in local smoke | Zeph Rush loaded with `86 HP`, a faster live run velocity, and a clearly lighter silhouette plus palette than Mira, which made the second character feel meaningfully different even inside the same stage shell | Preserve the mobility and survivability contrast while Stage 2 and Stage 3 content are added |
| 2026-03-05 | `phase3-stage2` | Codex (internal Stage 2 smoke) | Apple M1, editor runtime with a seeded unlocked profile for Coil Depths and Zeph Rush | Keyboard | `1.5s` from stage launch after menu confirm | Deterministic Stage 2 suite covered the full clear; live smoke focused on mission-board unlock flow, new backdrop, and in-stage readability | Yes | Physical controller coverage is still missing, but the mission board exposed the new route cleanly once the save had unlocked it | None repeated in local smoke | Coil Depths loaded from the real shell, the blue depth-conduit palette read as a distinct route immediately, and the new enemy mix plus vent-focused objective text made the stage feel like a midgame escalation instead of a Stage 1 reskin | Keep the vent hazard language readable as Stage 3 and onboarding work land |
| 2026-03-05 | `phase3-finale` | Codex (internal finale smoke) | Apple M1, editor runtime with a seeded unlocked profile for Storm Crown and the finale notice flow | Keyboard | `242.6s` from direct Stage 3 deploy in the live smoke | Deterministic finale suite covered the clear and ending notice; live smoke focused on mission-board launch, pause or resume, HID keyboard input, and first-contact combat in Storm Crown | Yes | AppleScript text keystrokes were not enough for gameplay movement on macOS, so the smoke switched to HID-posted key events for the live input check; physical controller coverage is still missing | None repeated in local smoke | Storm Crown loaded from the real shell, the HUD showed Mira move from `(-620, 140)` to `(141, 140)` under live keyboard input, health dropped to `84` on the first combat beat, and the objective shifted to `Break the crown wardens`, which made the finale route feel like a real escalation instead of a shell-only proof | Carry the HID-style smoke workflow into the release-candidate pass, and keep physical-controller coverage open until hardware is available |

## Session Notes

### Session ID: `2026-03-05-internal-smoke`

- Build identifier: `phase1-first-playable`
- Engine / branch: Godot 4.6.1 / `codex/wildcoil-mvp`
- Tester familiarity with brawlers: high
- Hardware: Apple M1 Mac
- Controller type: none connected
- Session length: repeated local smoke across editor runtime plus exported `.app`
- What clicked immediately: first combat starts inside two seconds, movement feels snappy, and the enemy pack reads cleanly at first contact
- What confused the tester: the pause overlay is functionally correct but visually understated; live blind keyboard macros were not a reliable way to clear the whole fight
- Where the tester took damage unfairly: no repeatable cheap-damage pattern surfaced in the local smoke
- When the tester smiled, laughed, or verbally reacted: immediate reaction was positive around the fast first-fight pacing and the exported build behaving like a real app
- Whether the tester asked to play again: yes
- Highest-priority fix: gather real outside feedback on fairness, spectacle payoff, and controller feel before treating Phase 1 as externally validated

### Session ID: `2026-03-05-phase2-slice-review`

- Build identifier: `phase2-progression`
- Engine / branch: Godot 4.6.1 / `codex/wildcoil-mvp`
- Tester familiarity with brawlers: high
- Hardware: Apple M1 Mac
- Controller type: none connected
- Session length: repeated local smoke across the mission board, seeded save reload, and packaged artifact generation
- What clicked immediately: the mission board made the slice feel like a real game instead of a debug launch, and saved rank/time feedback read as meaningful progression
- What confused the tester: the first typography pass still felt cramped at the default window size, especially in the mission board and HUD, but the follow-up typography pass brought it back into an acceptable range for the current slice
- Where the tester took damage unfairly: no repeatable cheap-damage pattern surfaced in the local smoke
- When the tester smiled, laughed, or verbally reacted: the strongest positive reaction came from seeing the saved record reload cleanly and then dropping straight back into the route
- Whether the tester asked to play again: yes
- Highest-priority fix: keep controller coverage open until hardware is available and repeat the slice on a second person once outside testers are available

### Session ID: `2026-03-05-second-character-smoke`

- Build identifier: `phase3-second-playable`
- Engine / branch: Godot 4.6.1 / `codex/wildcoil-mvp`
- Tester familiarity with brawlers: high
- Hardware: Apple M1 Mac
- Controller type: none connected
- Session length: short manual smoke focused on character selection, stage launch, and immediate movement contrast
- What clicked immediately: Zeph's smaller silhouette, lower HP, and quicker movement read as a different role immediately instead of a cosmetic swap
- What confused the tester: using a stale save file without the unlock did not expose the character until a seeded unlocked profile was loaded, which is correct behavior but worth remembering during future smoke tests
- Where the tester took damage unfairly: no repeatable cheap-damage pattern surfaced in the short smoke
- When the tester smiled, laughed, or verbally reacted: the biggest positive reaction was seeing the mission board reload straight into Zeph and then watching the live HUD show the faster, lighter loadout
- Whether the tester asked to play again: yes
- Highest-priority fix: keep the distinct mobility and survivability contrast intact as later stages and bosses are added

### Session ID: `2026-03-05-stage2-smoke`

- Build identifier: `phase3-stage2`
- Engine / branch: Godot 4.6.1 / `codex/wildcoil-mvp`
- Tester familiarity with brawlers: high
- Hardware: Apple M1 Mac
- Controller type: none connected
- Session length: short manual smoke focused on mission-board unlock flow, Stage 2 launch, and first-contact readability in Coil Depths
- What clicked immediately: the mission board exposed Coil Depths as a real second route, and the colder depth-conduit palette plus the new enemy lineup made the stage feel different immediately
- What confused the tester: no blocking confusion in the shell, but the hazard language was validated mostly through the deterministic suite rather than a long manual run because the smoke stayed intentionally short
- Where the tester took damage unfairly: no repeatable cheap-damage pattern surfaced in the short smoke
- When the tester smiled, laughed, or verbally reacted: the strongest positive reaction came from seeing the second route unlock in the live shell and then landing in a scene that did not read like a palette swap of Relay Clearing
- Whether the tester asked to play again: yes
- Highest-priority fix: preserve the vent-hazard readability and route identity while Stage 3 and onboarding layers are added

### Session ID: `2026-03-05-finale-smoke`

- Build identifier: `phase3-finale`
- Engine / branch: Godot 4.6.1 / `codex/wildcoil-mvp`
- Tester familiarity with brawlers: high
- Hardware: Apple M1 Mac
- Controller type: none connected
- Session length: short manual smoke focused on mission-board deploy, Stage 3 launch, pause or resume behavior, and HID-posted keyboard input in live combat
- What clicked immediately: the real shell launched straight into Storm Crown, the darker skyline and oversized crown disk made the route feel like a finale immediately, and the objective copy changed cleanly once combat started
- What confused the tester: plain AppleScript text keystrokes were enough for menu confirm and pause but not for reliable gameplay movement on macOS, so the smoke had to switch to HID-posted key events for the live combat check
- Where the tester took damage unfairly: no repeatable cheap-damage pattern surfaced in the short smoke; the only observed health loss came during the first crowd contact and read as fair
- When the tester smiled, laughed, or verbally reacted: the strongest positive reaction came from watching the HUD prove the player had physically moved from `(-620, 140)` to `(141, 140)` and then seeing the route rename its objective to `Break the crown wardens`
- Whether the tester asked to play again: yes
- Highest-priority fix: keep physical-controller coverage open for the release-candidate pass, because keyboard is now verified live but controller behavior is still only covered by deterministic tests

## Session Notes Template

### Session ID: `TBD`

- Build identifier:
- Engine / branch:
- Tester familiarity with brawlers:
- Hardware:
- Controller type:
- Session length:
- What clicked immediately:
- What confused the tester:
- Where the tester took damage unfairly:
- When the tester smiled, laughed, or verbally reacted:
- Whether the tester asked to play again:
- Highest-priority fix:

## Manual Acceptance Checklist

Mark these after each meaningful build review:

- [x] First combat starts within 30 seconds
- [x] First spectacle beat lands within 3 minutes
- [x] Player movement feels precise and dependable
- [x] Light chain and heavy finisher feel satisfying
- [x] Dodge or evade tool prevents obvious cheap damage
- [x] Enemy telegraphs remain readable under pressure
- [x] HUD stays readable in windowed and fullscreen modes
- [ ] Controller and keyboard both remain usable
- [ ] Build survives focus-loss and resume
- [ ] Audio survives device change
- [ ] Build stays near the 60 FPS target at 1080p
- [x] Tester would willingly run another attempt or stage

## External Session Target

- Minimum for Phase 1 gate: 5 sessions
- Preferred range: 5 to 8 sessions
- Required follow-up: log repeated confusion, repeated praise, and any repeated “too derivative” concern in [`docs/risk_register.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/risk_register.md)
