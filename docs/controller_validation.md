# Controller Validation

Use `docs/controller_validation.md` to record physical controller and keyboard fallback sessions for the exported macOS build. Automated Godot joypad smoke tests are useful regressions, but they are not physical controller evidence.

Run the gate after recording sessions:

```bash
bash scripts/check_controller_evidence.sh
```

The gate passes only after two distinct completed physical controller-family sessions and one completed keyboard fallback session are recorded with every required control marked `pass`.

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

Do not add `RIFT_ROAD_KEYBOARD_FALLBACK ok` until keyboard-only play has completed the same exported-app flow.

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

No physical controller sessions or manual exported-app keyboard fallback session have been recorded yet. `keyboard_fallback_flow` in `src/wildcoil/tools/runtime_test_runner.gd` provides automated keyboard regression coverage, but it is not a substitute for the manual exported-app row required by `bash scripts/check_controller_evidence.sh`. The gate is expected to report `RIFT_ROAD_CONTROLLER_EVIDENCE blocked` until real device sessions and the manual keyboard fallback session exist.
