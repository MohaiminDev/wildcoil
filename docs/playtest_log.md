# Wildcoil Playtest Log

Use this log for all Phase 1 external tests and any earlier hands-on checks that materially affect a gate decision.

## Current Gate Status

- 2026-03-05: Local Phase 1 smoke completed on Apple Silicon in both the editor runtime and the exported macOS bundle.
- 2026-03-05: The external-test portion of the gate is blocked because no outside testers or physical controllers were available in this session.
- 2026-03-05: Proceeding with development is acceptable, but the project still owes a real 5 to 8 tester round before calling the Phase 1 gate externally validated.

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
