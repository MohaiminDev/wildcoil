# Wildcoil Playtest Log

Use this log for all Phase 1 external tests and any earlier hands-on checks that materially affect a gate decision.

Use [`docs/public_playtest_gate.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/public_playtest_gate.md) as the session protocol before treating feedback as market-readiness evidence.

Run `bash scripts/check_playtest_evidence.sh` after recording external sessions. The current gate only passes when completed session rows show at least 5 sessions, at least one `machine=second-mac` setup, at least two distinct `controller-family=<family>` input entries, and replay intent from most testers.

Use `bash scripts/collect_playtest_evidence.sh --help` after a real external-style session to generate a non-empty evidence note and a paste-ready row for the table below. The collector uses the selected signed package when available, including `Rift Road-signed-notarized.zip` inside a known-tester packet, then falls back to `Rift Road.zip`. It does not append rows automatically; review the note, paste the row, then run the gate.

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
| TBD | TBD | TBD | machine=primary-mac | keyboard; controller-family=<family-if-used> | TBD | TBD | TBD | TBD | TBD | TBD | TBD |

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

- [ ] First combat starts within 30 seconds
- [ ] First spectacle beat lands within 3 minutes
- [ ] Player movement feels precise and dependable
- [ ] Light chain and heavy finisher feel satisfying
- [ ] Dodge or evade tool prevents obvious cheap damage
- [ ] Enemy telegraphs remain readable under pressure
- [ ] HUD stays readable in windowed and fullscreen modes
- [ ] Controller and keyboard both remain usable
- [ ] Build survives focus-loss and resume
- [ ] Audio survives device change
- [ ] Build stays near the 60 FPS target at 1080p
- [ ] Tester would willingly run another attempt or stage

## External Session Target

- Minimum for Phase 1 gate: 5 sessions
- Preferred range: 5 to 8 sessions
- Required follow-up: log repeated confusion, repeated praise, and any repeated “too derivative” concern in [`docs/risk_register.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/risk_register.md)
