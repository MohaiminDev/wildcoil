# Focus Audio Validation

Use `docs/focus_audio_validation.md` to record manual audible focus-loss/resume sessions for the exported macOS build. Automated focus/resume smoke verifies handler state, but it is not audible output evidence.

Run the gate after recording a session:

```bash
bash scripts/check_focus_audio_evidence.sh
```

Use `bash scripts/collect_focus_audio_evidence.sh --help` during real exported-app sessions to generate a non-empty evidence note and a paste-ready session snippet. The collector uses the selected signed package when available, including `Rift Road-signed-notarized.zip` inside a known-tester packet, then falls back to `Rift Road.zip`, and writes `commit=<short> package_sha256=<64-character-hex> package_source=<path>` by default. If you override `--build`, keep a 64-character `package_sha256=<sha>` value and signed `package_source=...Rift Road-signed-notarized.zip` in the value. Unsigned fallback snippets are internal-only notes; they do not satisfy this gate. The collector still depends on a human confirming real audible output; do not paste its `ok` snippet unless the session actually happened on the exported app.

The gate passes only after one completed manual exported-app session confirms the focus pause overlay, audible output before focus loss, quiet/suspended audio while focus-paused, audible output after resume, and resume control. The `Build` field must include a 64-character `package_sha256=<sha>` value and signed `package_source=build/macos/Rift Road-signed-notarized.zip` or `package_source=Rift Road-signed-notarized.zip`, and the `Evidence capture` field must point to a real, non-empty note, screenshot, or video file.

## Focus Audio Session Template

Do not add `RIFT_ROAD_FOCUS_AUDIO_SESSION ok` until the exported macOS app has been tested by a human with real audio output.

### Focus Audio Session: `TBD`

- Build: `commit=<short> package_sha256=<64-character-hex> package_source=build/macos/Rift Road-signed-notarized.zip`
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
