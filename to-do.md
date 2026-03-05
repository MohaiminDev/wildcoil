# Wildcoil Task Tracker

## Project Goal
Build an original macOS-first arcade-heritage action game that proves satisfying combat feel, clear readability, distinct identity, practical macOS delivery, and future open-source readiness before any larger MVP expansion.

## Product Thesis
Wildcoil should deliver a solo-first, controller-first, stage-based combat prototype with immediate melee satisfaction, strong spectacle in the first three minutes, readable enemy intent, and a strange wilderness-plus-machine-ruin identity that feels original rather than referential.

## Current Milestone
Phase 0 - Discovery and Direction Lock

## Success Gate for Current Milestone
- One concept direction is approved.
- One first-playable prototype plan is approved.
- One initial engine path is approved after the same macOS micro-spike in Godot, Unity, and Unreal.
- The risk register and milestone backlog are prioritized and actionable.
- Approval includes written validation evidence in the docs set, not just verbal agreement.

## Backlog

### [P1-01] Build the combat sandbox first playable
- Purpose: Turn the locked concept and engine choice into a tester-ready solo combat prototype.
- Expected outcome: One playable character, one short stage, three enemy archetypes, one elite/miniboss, placeholder UI/audio, and a macOS build path.
- Validation: Core-feel gate checklist, controller and keyboard checks, Apple Silicon smoke run, and playtest evidence in [`docs/playtest_log.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest_log.md).
- Dependencies: Phase 0 gate pass.

### [P1-02] Package a tester-ready macOS build
- Purpose: Make external testing practical early instead of leaving platform risk until late.
- Expected outcome: Repeatable packaging steps, controller checks, keyboard fallback, and a notarization checklist.
- Validation: Manual acceptance matrix in [`docs/macos_build_and_distribution.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/macos_build_and_distribution.md).
- Dependencies: Engine choice, first playable build.

### [P2-01] Define vertical slice promotion criteria
- Purpose: Prevent MVP scope creep before the first playable proves itself.
- Expected outcome: A Phase 2 promotion checklist tied to feel, readability, art feasibility, and production cost.
- Validation: Updated spec, tracker, and risk register after Phase 1 results.
- Dependencies: Phase 1 gate pass.

## Pending

### [P0-02] Run the Godot micro-spike
- Purpose: Measure prototype speed, controller reliability, macOS export friction, and frame stability in a real slice.
- Expected outcome: Same spike features as the other engines with notes captured in [`docs/engine_matrix.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/engine_matrix.md).
- Validation: Playable local spike, export artifact, and evidence notes for build friction and performance.
- Dependencies: Spike checklist from the engine matrix.

### [P0-03] Run the Unity micro-spike
- Purpose: Compare Unity against the same prototype and packaging workload rather than reputation alone.
- Expected outcome: Equivalent movement, combo, enemy, controller input, and macOS export evidence.
- Validation: Same as [P0-02].
- Dependencies: Spike checklist from the engine matrix.

### [P0-04] Run the Unreal micro-spike
- Purpose: Confirm whether Unreal's visual upside is worth the iteration and macOS cost for this scope.
- Expected outcome: Equivalent spike plus notes on editor friction, packaging, and Apple Silicon performance.
- Validation: Same as [P0-02].
- Dependencies: Spike checklist from the engine matrix.

### [P0-05] Score engines and lock the initial engine path
- Purpose: Convert evidence into a documented choice instead of leaving engine selection open-ended.
- Expected outcome: Weighted scorecard, written recommendation, and rejected-option notes.
- Validation: Completed score rows in [`docs/engine_matrix.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/engine_matrix.md) and a matching decision update in [`docs/game_spec.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/game_spec.md).
- Dependencies: [P0-02], [P0-03], [P0-04].

### [P0-06] Lock the milestone backlog for Phase 1
- Purpose: Enter implementation with a small, reviewable, validation-first backlog.
- Expected outcome: Ordered Phase 1 tasks, acceptance criteria, and a clear salvage-pass rule if the gate fails.
- Validation: Tracker update plus a risk register review.
- Dependencies: [P0-01], [VAL-01], [P0-05].

## In Progress
- None currently. Start the engine spikes next; do not begin `src/` implementation work before the Phase 0 gate passes.

## Blocked
- None currently recorded.

## Validation Needed

### [VAL-01] Approve the recommended concept direction
- Purpose: Confirm that the recommended winner is original, attractive, and small enough for a solo part-time prototype.
- Expected outcome: Go/no-go call on the recommended concept in [`docs/game_spec.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/game_spec.md).
- Validation: Review against originality safeguards, production complexity, and first-playable clarity.
- Dependencies: Initial spec draft.

### [VAL-02] Convert pre-spike engine notes into measured scores
- Purpose: Replace provisional engine assumptions with evidence from real macOS work.
- Expected outcome: Final scores for gameplay iteration, macOS tooling/export, responsiveness/input workflow, art-animation workflow, open-source posture, and performance headroom.
- Validation: Scorecard completion with export and packaging notes.
- Dependencies: [P0-02], [P0-03], [P0-04].

## Done

### [P0-01] Draft the Schedule A-aligned living spec
- Purpose: Turn the contract and development roadmap into one working design and planning brief.
- Expected outcome: [`docs/game_spec.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/game_spec.md) exists with all Schedule A section headings, ranked concepts, and a recommended winner.
- Validation: Section-by-section cross-check against Schedule A on 2026-03-05.
- Dependencies: Contract review and development plan inputs.

### [DOC-01] Create the contract-aligned task tracker
- Purpose: Establish one public source of truth for tasks, validation, and milestone status.
- Expected outcome: `to-do.md` exists with the contract-required sections.
- Validation: Cross-checked against Sections 19-21 and 30 of the contract on 2026-03-05.
- Dependencies: Contract review.

### [DOC-02] Create the initial planning docs set
- Purpose: Put the living spec, engine matrix, risk register, playtest log, asset provenance register, and macOS build note under `docs/`.
- Expected outcome: The Phase 0 public planning scaffold is in place and internally consistent.
- Validation: File set review and link check on 2026-03-05.
- Dependencies: Contract review and development plan inputs.

### [DOC-03] Update contributor entry points
- Purpose: Make the repo self-explanatory for future sessions and contributors.
- Expected outcome: `README.md` points to the active docs and `AGENTS.md` records durable planning conventions.
- Validation: Manual review of repo entry points on 2026-03-05.
- Dependencies: [DOC-01], [DOC-02].

## Technical Debt
- The Schedule A spec is intentionally concise; expand the similar-game research with source-backed store/review notes during Phase 0.
- The engine matrix currently contains pre-spike evidence and process notes, not final weighted scores.
- The macOS build note describes the required path, but real signing and notarization friction cannot be trusted until the chosen engine is tested with an export artifact.

## Risks / Assumptions
- Assumption: solo developer, part-time pace, and about 12 weeks to reach the first playable after kickoff.
- Assumption: solo-first, controller-first, local-co-op-ready architecture remains the safest prototype strategy.
- Risk: concept originality can drift too close to genre references if silhouettes, factions, or stage beats are not reviewed early.
- Risk: engine choice can look fine in theory but create painful macOS packaging or controller problems in practice.
- Risk: feel and readability may fail even if the scope stays small.

## Later / Nice-to-Have
- Detailed market-comparison appendix with store-page screenshot and trailer notes.
- Accessibility options matrix once the control scheme is more concrete.
- Repo setup instructions once a real engine/toolchain is selected.
