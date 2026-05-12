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

On the actual second Mac, generate the expected host/install/capture files with:

```bash
RIFT_ROAD_SECOND_MACHINE_LABEL="Apple Silicon Mac B" bash scripts/collect_second_machine_evidence.sh
```

The collector prefers `build/macos/Rift Road-signed-notarized.zip` or the same file inside a known-tester packet when it is present, then falls back to `build/macos/Rift Road.zip` for internal-only handoff evidence. It runs `scripts/audit_macos_package.sh` and `scripts/smoke_exported_macos_app.sh`, writes `package-audit.log` and `exported-app-smoke.log` next to the evidence files, records package SHA-256 metadata for the exact zip, and only records `RIFT_ROAD_SECOND_MACHINE_INSTALL ok` when the package is a release-candidate audit, Gatekeeper accepts it, and launched-app title/gameplay captures are present. `bash scripts/check_second_machine_evidence.sh` only accepts the signed/notarized package source for release evidence.

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
- Package SHA256: `TODO`
```

## Required Install Smoke

`install-smoke.md` must record a release-candidate package audit and Gatekeeper acceptance:

```markdown
# Second-Machine Install Smoke

- Package source: `build/macos/Rift Road-signed-notarized.zip`
- Package SHA256: `TODO`
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
