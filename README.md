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
- Runtime code lives in `src/`.
- Automated checks live in `tests/`.
- The production Godot project root is `src/wildcoil`.

## Current Engine Path

- Approved production engine: Godot 4.6.1
- Current backlog shape: 3 stages, 2 playable characters, 6 enemy archetypes, 3 boss encounters, persistent save/progression, controller-first input with keyboard fallback, and a tester-ready Apple Silicon macOS build
- Scope rule: stay solo-first for MVP; local co-op remains architecture-friendly but out of scope, and online play remains deferred

## Current Build And Check Commands

Install requirements:

- Godot 4.6.1 editor build with macOS export templates available on the machine
- Python 3.11 or newer with `pytest` available as `python3 -m pytest`

Run the production project:

- `scripts/run_game.sh`

Run the local validation gate:

- `scripts/check.sh`

Export the current macOS app:

- `scripts/export_macos.sh`

Direct equivalents if you want to run the pieces manually:

- `godot --headless --path src/wildcoil --import`
- `python3 -m pytest tests`
- `godot --path src/wildcoil`
- `godot --headless --path src/wildcoil --export-release "macOS" build/macos/Wildcoil.app`

## Current Milestone

Phase 1: production scaffold and first playable development on the locked Godot path.
