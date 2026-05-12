# Reliability

## Current Validation
- `scripts/check.sh` runs `python3 -m pytest tests -v`.
- `scripts/check.sh` then runs Godot headlessly with `src/wildcoil/tools/runtime_test_runner.gd -- smoke`.
- `tests/test_runtime_smoke.py` verifies the Godot project can launch headlessly and emits `RIFT_ROAD_RUNTIME_OK`.
- `runtime_test_runner.gd` validates required runtime paths and JSON top-level keys.
- `scripts/check_release_candidate.sh` combines repository validation, packaging, audit, launched-app smoke, performance, and manual evidence gates before reporting `RIFT_ROAD_RELEASE_GATE`.
- `scripts/sample_exported_app_performance.sh` launches the packaged app and records frame-time JSON from the exported `.app`.

## Logging Pattern
- No structured logging framework was found.
- Runtime smoke validation uses `print` and `printerr` in `src/wildcoil/tools/runtime_test_runner.gd`.
- Gameplay debugging is exposed in-game through `src/wildcoil/scripts/debug_overlay.gd`.

## Error Handling
- Shell scripts use `set -euo pipefail`.
- Python tests use subprocess return codes and captured output for Godot validation.
- Runtime JSON validation checks top-level dictionaries and expected keys in the smoke runner.

## Retry Behavior
- No retry helper, backoff loop, or transient-failure retry pattern was found.

## Known Failure Modes
- `godot` missing from `PATH` unless `GODOT_BIN` is set.
- Godot macOS export templates missing when running `scripts/package_macos.sh`.
- Runtime file or JSON key missing under `src/wildcoil`.
- Script errors during headless Godot launch.
- Human-facing feel/readability regressions that are not fully captured by current automated tests.

## Observability Hooks
- `debug_overlay.gd` provides in-game debug visibility.
- The headless runner prints pass/fail sentinel text for tests.
- `build/release-gate/latest/completion-audit.md` records a prompt-to-artifact checklist for release-gate runs.
- Exported-app and headless frame-time capture exist through `scripts/sample_exported_app_performance.sh` and `stage1_performance_sample`.
- TODO(source-needed): persistent crash dumps, player-session telemetry, or long-term metrics workflow.

## Next Safe Improvements
- Add a documented Godot version check once the supported version policy is confirmed.
- Expand screenshot or replay validation only where an existing deterministic workflow is available.
- Keep `scripts/check.sh` as the single local validation entry point.
