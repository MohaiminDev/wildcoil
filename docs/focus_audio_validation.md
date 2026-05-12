# Focus Audio Validation

Use `docs/focus_audio_validation.md` to record manual audible focus-loss/resume sessions for the exported macOS build. Automated focus/resume smoke verifies handler state, but it is not audible output evidence.

Run the gate after recording a session:

```bash
bash scripts/check_focus_audio_evidence.sh
```

The gate passes only after one completed manual exported-app session confirms the focus pause overlay, audible output before focus loss, quiet/suspended audio while focus-paused, audible output after resume, and resume control. The `Evidence capture` field must point to a real, non-empty note, screenshot, or video file.

## Focus Audio Session Template

Do not add `RIFT_ROAD_FOCUS_AUDIO_SESSION ok` until the exported macOS app has been tested by a human with real audio output.

### Focus Audio Session: `TBD`

- Build: `TBD`
- Output device: `TBD`
- Evidence capture: `TBD`
- Focus pause overlay: `TBD`
- Audio before focus loss: `TBD`
- Audio quiet during focus pause: `TBD`
- Audio after resume: `TBD`
- Resume control: `TBD`
- Blockers: `TBD`

## Current Status

No manual audible focus-loss/resume session has been recorded yet. `bash scripts/smoke_exported_focus_resume.sh` records automated state proof, but `bash scripts/check_focus_audio_evidence.sh` is expected to report `RIFT_ROAD_FOCUS_AUDIO_EVIDENCE blocked` until real audible output has been confirmed from the exported macOS app.
