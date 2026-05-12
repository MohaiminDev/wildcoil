# Stage 1 Performance Budget

This file records the current performance gate for the Rift Road Stage 1 vertical slice.

## Current Automated Sample

- Command from repo root: `godot --path src/wildcoil --headless --script "$PWD/src/wildcoil/tools/runtime_test_runner.gd" -- stage1_performance_sample`
- Test wrapper: `python3 -m pytest tests/test_runtime_smoke.py::test_stage_one_performance_sample_stays_within_budget -v`
- Runtime marker: `RIFT_ROAD_PERF stage1`
- Sample length: 240 physics/process frame pairs.
- Current automated budget: average frame sample at or below `PERFORMANCE_FRAME_BUDGET_MS` and no spike above `PERFORMANCE_MAX_FRAME_MS`.
- Latest local result on 2026-05-12: `avg_ms=16.687`, `max_ms=25.636`, `budget_ms=33.3`, `max_budget_ms=120.0`.

## Exported App Render Sample

- Command from repo root after packaging: `bash scripts/sample_exported_app_performance.sh`
- Output artifact: `docs/playtest-captures/exported-app-performance-latest/stage1-exported-performance.json`
- Host profile artifact: `docs/playtest-captures/performance-host-latest/host-profile.md`
- Runtime marker: `RIFT_ROAD_EXPORTED_PERF stage1`
- Purpose: capture frame timing from the real launched macOS `.app`, not only the headless Godot runner.
- Sampling discards the first startup/render warmup frames after Stage 1 autoplay begins so the strict spike budget measures steady-state gameplay frame pacing, not one-time app launch and scene setup.
- Current host: local Apple Silicon Mac A, `arm64`, `Apple M1`, `iMac21,2`, `16 GB`, macOS `26.5`; this is not second-machine proof.
- Latest local exported-app result on 2026-05-12: `avg_ms=13.882`, `max_ms=35.522`, `budget_ms=33.3`, `max_budget_ms=120.0`, `window_size=1280x720`, `window_mode=windowed`, with 8 warmup frames excluded.
- Optional local windowed 1080p sample: `RIFT_ROAD_PERF_WINDOW_SIZE=1920x1080 RIFT_ROAD_PERF_WINDOW_MODE=windowed bash scripts/sample_exported_app_performance.sh build/macos/Rift\ Road.zip docs/playtest-captures/exported-app-performance-windowed-1080p-latest`
- Latest local windowed 1080p result on 2026-05-10: `avg_ms=3.199`, `max_ms=6.652`, `budget_ms=33.3`, `max_budget_ms=120.0`, `window_size=1920x1080`, `window_mode=windowed`, with 8 warmup frames excluded.
- Optional local fullscreen sample: `RIFT_ROAD_PERF_WINDOW_SIZE=1920x1080 RIFT_ROAD_PERF_WINDOW_MODE=fullscreen bash scripts/sample_exported_app_performance.sh build/macos/Rift\ Road.zip docs/playtest-captures/exported-app-performance-fullscreen-latest`
- Latest local fullscreen result on 2026-05-10: `avg_ms=1.583`, `max_ms=2.793`, `budget_ms=33.3`, `max_budget_ms=120.0`, `window_size=1920x1080`, `window_mode=fullscreen`, with 8 warmup frames excluded.

## Interpretation

This is a regression guard, not a final shipped performance profile. It proves the current Stage 1 autoplay slice can run repeatedly in the Godot headless runtime without large timing regressions, script errors, or player death during the sample.

Before any public playtest or release-candidate claim, this must include a second-machine Apple Silicon capture or an explicit signed known-tester exception. The market-facing target remains roughly 60 FPS at the intended play resolution, with HUD readability intact during combat effects.

## Current Gaps

- The exported-app render sample is local Apple Silicon Mac A evidence; target-hardware breadth still needs expansion.
- Local 1280x720 windowed, 1920x1080 windowed, and 1920x1080 fullscreen samples are recorded.
- No second-machine performance sample is recorded yet.
- No physical controller session is paired with the performance sample yet.
