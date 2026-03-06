# Wildcoil Asset Provenance Register

Track every non-trivial imported asset, tool dependency, plugin, font, audio pack, and code import here. If the source is unknown, the asset is not approved.

## Current State

As of 2026-03-05, the production scaffold uses self-authored placeholder visuals and audio plus the Godot 4.6.1 engine toolchain and a Python `pytest` harness for headless validation. The release-candidate pass also used the Homebrew `switchaudio-osx` CLI for repeatable audio-device smoke checks. No third-party art, audio pack, font, gameplay plugin, or code library is approved for committed runtime use. Record new items here before they become habitual dependencies.

## Register

| ID | Type | Description | Source / URL | Creator / Vendor | License | Phase used | Placeholder or permanent | Replacement needed for future open source? | Verified by | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ORIG-001 | Documentation | Project planning docs and prose in this repository | Local repository authorship | Project author | Repository license applies | Phase 0 | Permanent | No | TBD | Applies only to original written documentation |
| TMP-001 | Art | Graybox shapes, primitive materials, and temporary silhouettes authored in-engine | Self-authored at creation time | Project author | Original work | Phase 0-1 | Placeholder | No, unless external textures are added later | TBD | Safe default for early spikes |
| TOOL-001 | Engine toolchain | Godot 4.6.1 editor plus official macOS export templates used for the production scaffold | https://godotengine.org/ and official export templates bundle | Godot contributors | MIT | Phase 0-Release | Tool dependency | No | TBD | Engine choice approved in Phase 0; keep version changes visible, and keep the export preset filters aligned with committed content only |
| ORIG-002 | Art / UI | Placeholder stage shapes, icon, HUD text, and graybox scene dressing in `src/wildcoil` | Local repository authorship | Project author | Original work | Phase 1 | Placeholder | No, unless replaced later by external assets | TBD | Covers the production scaffold visuals and icon added with P1-01 |
| ORIG-003 | Audio / UI | Placeholder synth loops, spectacle stinger, mission-board text UI, and save-profile JSON schema in `src/wildcoil` | Local repository authorship | Project author | Original work | Phase 2 | Placeholder | No, unless replaced later by external assets or middleware | TBD | Added with the progression mission board and vertical-slice audio pass |
| TOOL-002 | Test harness | Python 3.9+ standard library plus `pytest` used to drive the real Godot project headlessly from `tests/` | https://docs.python.org/3/ and https://docs.pytest.org/ | Python Software Foundation / pytest contributors | PSF / MIT | Phase 1-Release | Tool dependency | No | TBD | Runtime suites in `res://tools/runtime_test_runner.gd` are exercised through this harness |
| TOOL-003 | CI automation | GitHub Actions workflow using `actions/checkout`, `actions/setup-python`, and Homebrew-installed Godot on macOS runners | https://github.com/actions/checkout, https://github.com/actions/setup-python, https://formulae.brew.sh/cask/godot | GitHub / Homebrew / Godot contributors | MIT-compatible per upstream projects | Phase 2-Release | Tool dependency | No | TBD | Mirrors the local `./scripts/check.sh` gate on hosted macOS CI |
| TOOL-004 | Packaging utilities | macOS `ditto` and `shasum` used by `scripts/package_macos.sh` to create the tester ZIP and checksum sidecar | Bundled with macOS command-line tools | Apple | Apple platform tooling | Phase 2-Release | Tool dependency | No | TBD | Required for the documented package-and-checksum flow |
| TOOL-005 | Audio smoke tooling | Homebrew `switchaudio-osx` CLI used to swap output devices during the release-candidate macOS smoke pass | https://formulae.brew.sh/formula/switchaudio-osx | Devin Bayer and contributors / Homebrew | MIT | Phase 3 | Tool dependency | No | TBD | Used only for local release-candidate validation; not required at runtime |
| HOLD-001 | External asset intake placeholder | Any future third-party asset under consideration | Record before use | TBD | TBD | Any | Hold | Assume yes until verified otherwise | TBD | Do not commit unclear-source assets |

## Intake Rules

- Record the asset before or at the same time it enters the repo.
- Mark whether it is a placeholder or a permanent dependency.
- If future open-source release is uncertain, treat replacement as required until proven otherwise.
- Keep code dependencies that affect build or packaging visible here or in a linked dependency appendix later.
- Reconcile this register whenever build automation adds a new hosted dependency or action.
