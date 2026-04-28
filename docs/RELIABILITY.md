# Reliability

## Current Validation
- `scripts/check.sh` runs `python3 -m pytest tests -v`.
- `scripts/check.sh` then runs Godot headlessly with `src/wildcoil/tools/runtime_test_runner.gd -- smoke`.
- `tests/test_runtime_smoke.py` verifies the Godot project can launch headlessly and emits `RIFT_ROAD_RUNTIME_OK`.
- `runtime_test_runner.gd` validates required runtime paths and JSON top-level keys.

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
- TODO(source-needed): persistent logs, crash dumps, metrics, tracing, or frame-time capture workflow.

## Next Safe Improvements
- Add a documented Godot version check once the supported version is confirmed.
- Add screenshot or replay validation only after an existing deterministic workflow is available.
- Keep `scripts/check.sh` as the single local validation entry point.
