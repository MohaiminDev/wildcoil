# Rift Road: Beasts of the Afterglow

Rift Road: Beasts of the Afterglow is an original macOS-first 2D side-scrolling arcade beat-'em-up about four road adventurers crossing a glowing prehistoric future to stop a mining empire from draining the living crystal heart of the world.

The project is now story-first around the Rift Road concept while keeping the repository name and existing planning history. The current goal is to build a Godot 4.6.x stable macOS prototype for Stage 1: Sunset Overpass, with two playable heroes, three enemy types, Brask Noll as the first boss, original placeholder assets, and a validation-first task flow.

## Current Working Docs

- [`to-do.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/to-do.md): single source of truth for milestone status, tasks, validation, and risks
- [`ARCHITECTURE.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/ARCHITECTURE.md): current runtime map, entry points, and known gaps
- [`docs/PLANS.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/PLANS.md): index of public and Codex-only planning sources
- [`docs/game-story.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/game-story.md): Rift Road story bible, world, heroes, stages, MVP scope, and originality checklist
- [`docs/superpowers/plans/2026-04-27-rift-road-mvp.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/superpowers/plans/2026-04-27-rift-road-mvp.md): implementation plan for the Stage 1 playable prototype
- [`docs/game_spec.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/game_spec.md): Schedule A-aligned living game spec
- [`docs/engine_matrix.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/engine_matrix.md): Phase 0 engine evaluation workflow and weighted scorecard
- [`docs/risk_register.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/risk_register.md): living risk and inspiration log
- [`docs/playtest_log.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest_log.md): playtest capture template and gate checklist
- [`docs/asset_provenance_register.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/asset_provenance_register.md): asset and dependency provenance tracker
- [`docs/macos_build_and_distribution.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/macos_build_and_distribution.md): tester build, packaging, and notarization planning notes

## Repo Shape

- Keep living planning artifacts in `docs/`.
- Place runtime code in `src/wildcoil`.
- Place automated checks in `tests/`.
- Keep implementation tasks small, validated, committed, and pushed one tracker task at a time when requested.

## Current Milestone

Rift Road Phase 1: build the Stage 1 macOS playable prototype in Godot.

## Run and Test

- Run checks: `bash scripts/check.sh`
- Check source-run local playability: `bash scripts/check_local_playability.sh`
- Capture source-run local demo proof: `bash scripts/smoke_source_run_local_demo.sh` reports `RIFT_ROAD_SOURCE_RUN_DEMO_SMOKE ok`
- Check local source-run playtest evidence: `bash scripts/check_local_playtest_evidence.sh`
- Collect local source-run playtest evidence: `bash scripts/collect_local_playtest_evidence.sh`
- Run agent docs check: `python3 scripts/check_agent_docs.py`
- Check Godot version: `bash scripts/check_godot_version.sh`
- Run the game: `bash scripts/run_game.sh`
- Run tests only: `python3 -m pytest tests -v`
- Package macOS build: `bash scripts/package_macos.sh`

Set `GODOT_BIN=/path/to/godot` if `godot` is not on `PATH`.
