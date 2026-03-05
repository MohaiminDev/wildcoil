# Wildcoil Risk Register

This is the living risk register for the project. Update it whenever a decision, spike, or playtest changes the actual risk picture.

## Active Risks

| ID | Category | Risk | Why it matters | Likelihood | Impact | Early warning signs | Mitigation | Owner | Resolution method | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| R-01 | Design | Combat feels technically correct but not satisfying | Phase 1 fails if hits and movement are soft | Medium | High | Testers stop after one run, vague “feels off” comments | Prioritize feel before content breadth; review hitstop, recovery, enemy reactions early | Solo developer | Prototype experiment + playtest | Open |
| R-02 | Originality | World, enemies, or pacing drift too close to familiar genre references | Violates the contract and weakens market clarity | Medium | High | Testers name another game first when describing Wildcoil | Maintain inspiration log, review silhouettes and faction logic before prototype lock | Solo developer | Concept review + scope change | Open |
| R-03 | Scope | Solo part-time schedule cannot absorb feature creep | Timeline collapses before first playable ships | High | High | “Just one more system” thinking, stage count inflation | Freeze prototype scope and defer co-op/online/progression extras | Solo developer | Scope reduction | Open |
| R-04 | Engine / tool | Chosen engine creates disproportionate macOS or workflow pain | Lost weeks and weak prototype quality | Medium | High | Export blockers, long iteration loop, brittle input setup | Run identical spikes and score them before committing | Solo developer | Engine comparison | Open |
| R-05 | Animation production | Target presentation needs too much bespoke animation polish too early | Prototype stalls waiting on art quality | Medium | Medium-high | Graybox combat reads poorly without expensive polish | Use strong poses and reactions first; defer complex flourishes | Solo developer | Mockup + prototype experiment | Open |
| R-06 | Performance | Effects, lighting, or scene complexity hurt Apple Silicon frame stability | Fails the macOS gate and damages feel | Medium | High | Frame drops during early spectacle moments | Budget VFX early, capture frame-time notes in every spike | Solo developer | Benchmark + optimization pass | Open |
| R-07 | Packaging | Packaging, codesign, or notarization blocks external testing | Playtests slip and macOS-first promise weakens | Medium | High | “Works locally only” build situation | Dry-run export path early and keep notes current | Solo developer | Packaging experiment | Open |
| R-08 | Input | Controller behavior is unreliable on macOS | Core platform-fit requirement fails | Medium | High | Hot-plug issues, bad prompts, deadzone complaints | Test at least two controllers plus keyboard early | Solo developer | Input testing | Open |
| R-09 | Readability | Enemy stacks and effects create cheap damage | Players lose trust and stop replaying | Medium | High | Repeated “I couldn't tell what hit me” comments | Limit overlap, simplify silhouettes, restrain VFX and camera shake | Solo developer | Playtest + design iteration | Open |
| R-10 | Open-source transition | Placeholder assets or plugins become long-term traps | Future repo release becomes legally or structurally messy | Medium | Medium-high | Unclear provenance, marketplace dependence, undocumented imports | Track every dependency and placeholder from day one | Solo developer | Process change + provenance review | Open |
| R-11 | Testing blind spots | Self-testing misses clarity, fairness, or pacing failures | Bad decisions survive too long | High | High | Feedback surprises after external playtests | Schedule 5 to 8 outside sessions for Phase 1 | Solo developer | Player testing | Open |
| R-12 | Market clarity | The hook feels too familiar or too vague to pitch quickly | Harder to earn attention even if the combat is decent | Medium | Medium-high | One-sentence pitch needs too much explanation | Keep concept, art, and audio language tightly aligned | Solo developer | Concept refinement | Open |

## Inspiration Risk Log

Use this table to keep reference influence visible and safe.

| Reference | Useful lesson | At-risk element if copied too closely | Safety boundary | Status |
| --- | --- | --- | --- | --- |
| Streets of Rage 4 | Weighty impact and readable enemy reactions | Urban-crime framing, silhouette rhythm, HUD pacing | Keep the wilderness-tech ecology and unique faction logic front and center | Watching |
| TMNT: Shredder's Revenge | Fast onboarding and joyful pacing | Team-comedy tone, nostalgia-driven structure, celebratory co-op framing | Stay solo-first and avoid homage-style character energy | Watching |
| Fight'N Rage | Mastery and combo depth | Dense combo complexity too early | Use only as a late-stage mastery benchmark | Watching |
| Dragon's Crown Pro | Premium spectacle and class contrast | Screen clutter and exaggerated fantasy shorthand | Keep silhouettes cleaner and setting more primal-tech than fantasy | Watching |
| Hades | Telegraph clarity and audio discipline | Run structure, UI cadence, or over-familiar FX rhythms | Borrow only clarity discipline, not roguelike progression or underworld aesthetics | Watching |

## Review Cadence

- Review after every engine spike.
- Review after every external playtest round.
- Review before any phase gate.
