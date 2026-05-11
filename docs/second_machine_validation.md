# Second-Machine Validation

Use this file when moving `Rift Road: Beasts of the Afterglow` from local internal packaging toward public-playtest or release-candidate distribution. This is a clean-machine evidence gate, not a substitute for signing, notarization, or human playtest notes.

## Evidence Directory

Record the latest proof under:

- `docs/playtest-captures/second-machine-latest/host-profile.md`
- `docs/playtest-captures/second-machine-latest/install-smoke.md`
- `docs/playtest-captures/second-machine-latest/stage1-second-machine-title.png`
- `docs/playtest-captures/second-machine-latest/stage1-second-machine-gameplay.png`

Then run:

```bash
bash scripts/check_second_machine_evidence.sh
```

## Required Host Profile

`host-profile.md` must identify the second machine, not the local development Mac:

```markdown
# Second-Machine Host Profile

- Machine label: `Apple Silicon Mac B`
- Architecture: `arm64`
- CPU: `TODO`
- Model: `TODO`
- Memory: `TODO`
- macOS: `TODO`
- Build: `TODO`
```

## Required Install Smoke

`install-smoke.md` must record a release-candidate package audit and Gatekeeper acceptance:

```markdown
# Second-Machine Install Smoke

- Package source: `build/macos/Rift Road.zip`
- Package status: `RIFT_ROAD_PACKAGE_AUDIT release-candidate`
- Gatekeeper result: `accepted`
- Install method: `TODO`
- Launch path: `TODO`
- Input checked: `keyboard`
- Notes: `TODO`

RIFT_ROAD_SECOND_MACHINE_INSTALL ok
```

## Current Status

No second-machine evidence has been recorded yet. `bash scripts/check_second_machine_evidence.sh` is expected to report `RIFT_ROAD_SECOND_MACHINE_EVIDENCE blocked` until the files above come from a real second Apple Silicon Mac.
