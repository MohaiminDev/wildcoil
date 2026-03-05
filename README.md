# Wildcoil

Wildcoil is a macOS-first solo action game project. The concept direction is locked on `Wildcoil`, and the initial production engine path is now locked to Godot 4.6.1 after the Phase 0 spike review on 2026-03-05, following the rules in [`arcade_heritage_game_master_contract.txt`](/Users/himu/Desktop/career/personal_projects/wildcoil/arcade_heritage_game_master_contract.txt).

## Current Working Docs

- [`to-do.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/to-do.md): single source of truth for milestone status, tasks, validation, and risks
- [`docs/game_spec.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/game_spec.md): Schedule A-aligned living game spec
- [`docs/engine_matrix.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/engine_matrix.md): Phase 0 engine evaluation workflow and weighted scorecard
- [`docs/risk_register.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/risk_register.md): living risk and inspiration log
- [`docs/playtest_log.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest_log.md): playtest capture template and gate checklist
- [`docs/asset_provenance_register.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/asset_provenance_register.md): asset and dependency provenance tracker
- [`docs/macos_build_and_distribution.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/macos_build_and_distribution.md): tester build, packaging, and notarization planning notes

## Repo Shape

- Keep living planning artifacts in `docs/`.
- When implementation starts, place runtime code in `src/` and automated checks in `tests/`.

## Current Engine Path

- Approved production engine: Godot 4.6.1
- Current backlog shape: 3 stages, 2 playable characters, 6 enemy archetypes, 3 boss encounters, persistent save/progression, controller-first input with keyboard fallback, and a tester-ready Apple Silicon macOS build
- Scope rule: stay solo-first for MVP; local co-op remains architecture-friendly but out of scope, and online play remains deferred

## Current Build And Check Commands

Use these commands as the current engine-level validation loop until the production scaffold replaces the spike path:

- `godot --headless --path spikes/godot_wildcoil_spike --import`
- `godot --path spikes/godot_wildcoil_spike --benchmark --quit-after-benchmark`
- `godot --headless --path spikes/godot_wildcoil_spike --export-release "macOS" ../godot_artifacts/WildcoilGodotSpike.app`
- `spikes/godot_artifacts/WildcoilGodotSpike.app/Contents/MacOS/Wildcoil\\ Godot\\ Spike --benchmark --quit-after-benchmark`

When `src/`, `tests/`, and the production Godot project land in Phase 1, update this section in the same commit so later tasks keep one repeatable import, test, and export gate.

## Current Milestone

Phase 1: production scaffold and first playable development on the locked Godot path.
