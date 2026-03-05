# Initial Implementation Plan

This file is the immutable baseline snapshot of the first approved implementation plan for Wildcoil. Do not rewrite this file during normal execution. If direction changes materially, keep this record and create a later replacement plan linked from `plan-status.md` and `decision-log.md`.

## Plan Title
Wildcoil Initial Implementation Plan

## Plan ID
`wildcoil-2026-03-05-initial-v1`

## Created Date
2026-03-05

## Source Inputs
- `/Users/himu/Desktop/career/personal_projects/wildcoil/arcade_heritage_game_master_contract.txt`
- `/Users/himu/Desktop/career/personal_projects/wildcoil/AGENTS.md`
- Repository state on 2026-03-05 with documentation-only root files
- Approved development roadmap prepared from the contract and repo guidance

## Planning Assumptions
- Team shape: solo developer as the default operating model
- Pace: part-time development, with about 12 weeks to reach a first playable if execution begins cleanly
- Platform priority: macOS is the primary target from day one
- Engine stance: engine selection remains a Phase 0 gate, not a pre-locked implementation choice
- Multiplayer stance: solo-first architecture with local co-op readiness, but no co-op implementation before the core-feel gate passes
- Commercial stance: prove fun, identity, and feasibility before expanding market-facing scope

## Chosen Defaults
- Stage-based action game with strong replay value
- Side-view or controlled 2.5D presentation
- Melee-first combat with selective ranged or tool-based variety
- Solo-first mode focus
- Local co-op ready architecture, online deferred
- Stylized, readable, premium-feeling, scope-aware art direction
- Light, efficient, environment-led narrative delivery
- Readability over effect spam
- Open-source-safe structure without weakening production quality

## Phase Roadmap
### Phase 0 - Discovery and Direction Lock
- Produce a Schedule A-aligned spec with target audience, product thesis, design pillars, concept options, engine comparison, risk register, and initial milestone backlog.
- Generate 3 to 5 original concept directions, rank them, and select one recommendation.
- Run the same micro-spike in Godot, Unity, and Unreal: movement controller, one combo string, one enemy, controller input, macOS export, and packaging friction notes.
- Score engine candidates with fixed weights: gameplay iteration 25, macOS tooling/export 20, responsiveness/input workflow 15, art-animation workflow 15, open-source posture 15, performance headroom 10.
- Exit only when one concept direction, one prototype plan, one initial engine path, and one risk-prioritized milestone plan are approved.

### Phase 1 - Core Feel Prototype
- Build a solo-first combat prototype with 1 playable character, 1 short stage, 3 enemy archetypes, 1 elite or miniboss, placeholder UI, and placeholder audio.
- Lock the first 3 minutes around fast combat entry, one early spectacle moment, readable encounter escalation, and dependable input feel.
- Ship tester-ready macOS builds with controller validation, keyboard fallback, and documented packaging steps.
- Hold scope unless the core-feel gate passes.

### Phase 2 - Vertical Slice
- Convert the winning prototype into a representative slice with near-target visuals, stronger sound identity, a representative boss, a progression stub, and save/load behavior if needed.
- Revisit local co-op only after confirming readability, performance, and production feasibility.

### Phase 3 - MVP Production
- Target the smallest market-testable MVP: 3 stages, 2 playable characters, 6 to 8 enemy types, 2 bosses, onboarding, replay hooks, stable save/progression, and a clean macOS distribution path.
- Continue prioritizing core feel, clarity, and production realism over feature breadth.

### Phase 4 - Release Readiness and Open-Source Preparation
- Complete asset provenance review, dependency and license review, clean-machine setup validation, packaging and notarization validation, performance pass, crash and error logging review, contributor guidance, and restricted-asset replacement planning.

## Gate Criteria
### Phase 0 Gate
- One original concept direction is approved
- One prototype plan is approved
- One engine path is approved
- The risk register and milestone plan are prioritized and actionable

### Phase 1 Gate
- Movement and attacks feel satisfying immediately
- Combat remains readable under stress
- Failures feel understandable rather than cheap
- macOS builds are stable on Apple Silicon
- Testers express replay desire

### Phase 2 Gate
- The slice proves not only mechanics, but production viability
- Art, audio, and UI direction scale to the intended MVP
- The chosen engine and workflow still help iteration instead of slowing it

### Phase 3 Gate
- The MVP is strong enough to test real player and market interest
- Onboarding, progression, and replay hooks are stable enough for external evaluation
- The repository and documentation remain contributor-safe

### Phase 4 Gate
- Assets and dependencies are traceable
- Packaging and distribution steps are repeatable
- Documentation is complete enough for outside contributors and later open-source work

## Risks At Planning Time
- Originality risk: concept or enemy design may drift too close to well-known genre references
- Engine/tool risk: an engine may look attractive but slow macOS iteration or packaging in practice
- Scope risk: solo development may overreach beyond a realistic first playable and MVP
- Feel risk: early prototypes may look acceptable but fail the hand-feel test
- Readability risk: enemy stacks, VFX, or camera behavior may reduce fairness under chaos
- Animation/audio production risk: feel may lag if hit confirmation, transitions, and sound design are treated too late
- macOS packaging risk: controller behavior, fullscreen/focus handling, or notarization may block external testing
- Open-source transition risk: placeholder assets, plugins, or licenses may become long-term traps if not tracked from the start

## Superseded By
None. This is the active baseline plan as of 2026-03-05.
