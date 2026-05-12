# Controller Validation

Use `docs/controller_validation.md` to record physical controller and keyboard fallback sessions for the exported macOS build. Automated Godot joypad smoke tests are useful regressions, but they are not physical controller evidence.

Run the gate after recording sessions:

```bash
bash scripts/check_controller_evidence.sh
```

Use `bash scripts/collect_controller_evidence.sh --help` during real exported-app sessions to generate a non-empty evidence note and a paste-ready session snippet. The collector uses the selected signed package when available, including `Rift Road-signed-notarized.zip` inside a known-tester packet, then falls back to `Rift Road.zip`. The collector still depends on manual, physical testing; do not use its `ok` marker unless the tester actually completed the flow on the exported app.

The gate passes only after two distinct completed physical controller-family sessions and one completed keyboard fallback session are recorded with every required control marked `pass`.

For any section marked `RIFT_ROAD_CONTROLLER_SESSION ok` or `RIFT_ROAD_KEYBOARD_FALLBACK ok`, do not leave metadata fields as `TBD`. The `Evidence capture` field must point to a real, non-empty file, preferably under `docs/playtest-captures/controller/`. The gate rejects placeholder or missing build, evidence, blocker, and controller device metadata so a session cannot pass on control-check strings alone.

## Controller Session Template

Copy this section once per physical controller family. Do not add `RIFT_ROAD_CONTROLLER_SESSION ok` until the exported macOS app has been tested with the device.

### Controller Session: `TBD`

- Build: `TBD`
- Controller family: `TBD`
- Device name: `TBD`
- Connection: `TBD`
- Evidence capture: `TBD`
- Title: `TBD`
- Hero select: `TBD`
- Stage 1 movement: `TBD`
- Attack: `TBD`
- Jump: `TBD`
- Special: `TBD`
- Dash: `TBD`
- Pause: `TBD`
- Cancel/back: `TBD`
- Blockers: `TBD`

## Keyboard Fallback Template

Do not add `RIFT_ROAD_KEYBOARD_FALLBACK ok` until keyboard-only play has completed the same exported-app flow. The completed row must include a non-placeholder build identifier, evidence capture path, and blocker note.

### Keyboard Fallback Session

- Build: `TBD`
- Evidence capture: `TBD`
- Title: `TBD`
- Hero select: `TBD`
- Stage 1 movement: `TBD`
- Attack: `TBD`
- Jump: `TBD`
- Special: `TBD`
- Dash: `TBD`
- Pause: `TBD`
- Cancel/back: `TBD`
- Blockers: `TBD`

## Current Status

No physical controller sessions or manual exported-app keyboard fallback session have been recorded yet. `keyboard_fallback_flow` in `src/wildcoil/tools/runtime_test_runner.gd` provides automated keyboard regression coverage, and `bash scripts/smoke_exported_keyboard_fallback.sh` provides automated launched-export keyboard coverage, but neither is a substitute for the manual exported-app row required by `bash scripts/check_controller_evidence.sh`. The gate is expected to report `RIFT_ROAD_CONTROLLER_EVIDENCE blocked` until real device sessions and the manual keyboard fallback session exist, and it will keep blocking any marked session that still contains placeholder metadata.
