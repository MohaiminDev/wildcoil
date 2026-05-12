# Architecture

## Current Shape
- Runtime project: Godot 4.6.1-era project at `src/wildcoil`, with `src/wildcoil/project.godot` setting `res://scenes/app_root.tscn` as the main scene.
- Runtime language: GDScript files under `src/wildcoil/scripts` and `src/wildcoil/tools`.
- Test harness: Python `pytest` tests under `tests`, with `tests/conftest.py` driving Godot through `GODOT_BIN` or `godot`.
- Local workflow scripts: `scripts/run_game.sh`, `scripts/check.sh`, `scripts/check_godot_version.sh`, `scripts/package_macos.sh`, `scripts/check_release_candidate.sh`, `scripts/sample_exported_app_performance.sh`, and `scripts/check_macos_signing_env.sh`.
- Product docs: `README.md`, `to-do.md`, `docs/game-story.md`, `docs/game_spec.md`, and related planning docs.

## Main Components
| Component | Evidence | Responsibility |
|---|---|---|
| App root | `src/wildcoil/scripts/app_root.gd`, `src/wildcoil/scenes/app_root.tscn` | Title screen, hero select, campaign stage order, pause/game-over/completion flow |
| Stage manager | `src/wildcoil/scripts/stage_manager.gd` | Stage setup, player/enemy/boss orchestration, combat resolution, HUD/debug updates |
| Player controller | `src/wildcoil/scripts/player_controller.gd` | Player movement, attacks, damage, meter, score, drawing |
| Enemy actors | `src/wildcoil/scripts/enemy_actor.gd`, `src/wildcoil/scripts/wave_spawner.gd` | Enemy profile loading, movement behavior, attacks, wave spawning |
| Boss actors | `src/wildcoil/scripts/boss_brask_noll.gd`, `src/wildcoil/scenes/boss_brask_noll.tscn` | Stage boss behavior for Brask Noll |
| Data definitions | `src/wildcoil/data/*.json` | Heroes, enemies, bosses, stages, waves, cutscene text |
| Runtime checks | `src/wildcoil/tools/runtime_test_runner.gd`, `tests/test_runtime_smoke.py` | Headless smoke validation and required-file/JSON validation |

## Data Flow
1. Godot opens `src/wildcoil/project.godot`.
2. The main scene loads `app_root.gd`.
3. `app_root.gd` reads `res://data/stages.json` for final ending text and starts a selected campaign stage.
4. `StageManager` loads character, boss, and stage data from JSON files.
5. `WaveSpawner` loads enemy profiles from `data/enemies.json` and instantiates enemy scenes.
6. Player, enemies, and boss communicate through Godot signals and direct method calls.
7. HUD, combat effects, debug overlay, and pickups are attached by `StageManager`.

## Module Boundaries
- Runtime gameplay code is under `src/wildcoil/scripts`.
- Runtime scenes are under `src/wildcoil/scenes`.
- Runtime data is under `src/wildcoil/data`.
- Headless Godot runtime validation code is under `src/wildcoil/tools`.
- Python tests live outside the Godot project in `tests`.
- Local developer and packaging scripts live in `scripts`.
- Contributor-facing documentation lives in `docs`; Codex-only continuity lives in `.codex`.

## Entry Points
- Game entry: `bash scripts/run_game.sh`
- Godot main scene: `src/wildcoil/scenes/app_root.tscn`
- Full local validation: `bash scripts/check.sh`
- Python tests: `python3 -m pytest tests -v`
- Godot smoke runner: `src/wildcoil/tools/runtime_test_runner.gd`
- Godot version gate: `bash scripts/check_godot_version.sh`
- macOS packaging: `bash scripts/package_macos.sh`
- Release-candidate gate: `bash scripts/check_release_candidate.sh`
- Exported-app performance sample: `bash scripts/sample_exported_app_performance.sh`
- Signing/notarization preflight: `bash scripts/check_macos_signing_env.sh`

## Dependency Direction
- Godot scenes and scripts depend on JSON data in `src/wildcoil/data`.
- Python tests inspect repo files and invoke Godot headlessly.
- Shell scripts wrap Python tests, Godot runtime checks, Godot macOS export, release-candidate gating, signing/notarization preflight, and launched-app performance/screenshot evidence.
- No package manager, application framework outside Godot, or CI workflow file was found during inspection.

## Known Gaps
- Supported engine line is mechanically checked as Godot 4.6.x stable by `scripts/check_godot_version.sh`; TODO(source-needed): final patch-level pin or upgrade policy beyond the 4.6.x stable line.
- TODO(source-needed): release signing and notarization owner/credential process beyond the current non-secret preflight and guarded signing script.
- TODO(source-needed): lint/type-check command for GDScript or Python.
- TODO(source-needed): CI provider and required checks.
