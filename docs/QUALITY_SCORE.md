# Quality Score

Scores are current confidence estimates from repository evidence only. `5/5` means strong automated and documented coverage exists in-repo; `1/5` means mostly undocumented or manually validated.

| Area | Confidence | Evidence | Missing tests | Missing docs | Risk areas | Suggested next action |
|---|---:|---|---|---|---|---|
| Runtime launch | 4/5 | `tests/test_runtime_smoke.py`, `runtime_test_runner.gd`, `scripts/check.sh` | Version-specific Godot check | Supported Godot version policy beyond current Godot 4.6.1 local evidence | Local machine may have different Godot/export setup | Confirm and document supported Godot version |
| Campaign content data | 4/5 | `tests/test_full_campaign.py`, `src/wildcoil/data/*.json` | Schema-level validation beyond asserted fields | Data contract doc beyond architecture summary | JSON shape drift | Add lightweight JSON schema expectations if content grows |
| Game flow | 3/5 | `app_root.gd`, `stage_manager.gd`, tests for campaign progression strings | End-to-end automated victory path | Full demo flow doc is mostly in `to-do.md` | Manual-only confidence for full playthrough | Record deterministic autoplay path before expanding scope |
| Combat feel/readability | 2/5 | Runtime scripts and risk register | Automated feel/readability checks are limited | Tuning rationale and acceptance thresholds | Subjective playtest regressions | Add playtest notes and screenshot evidence per task |
| macOS packaging | 3/5 | `scripts/package_macos.sh`, `scripts/check_release_candidate.sh`, `scripts/check_macos_signing_env.sh`, `export_presets.cfg`, `docs/macos_build_and_distribution.md` | Clean-machine packaging test | Signing/notarization owner/credential process | Export templates and signing setup | Record real Developer ID/notary and second-machine proof before release claims |
| Documentation map | 3/5 | `AGENTS.md`, `ARCHITECTURE.md`, `docs/*` created by this migration | Docs structure check now exists | Some unknowns remain marked TODO | Docs can drift from runtime | Keep `scripts/check_agent_docs.py` in validation |
| Security/config | 2/5 | `docs/SECURITY.md`, empty signing fields, `GODOT_BIN` usage | Secret redaction tests not applicable yet | Credential process unknown | Future signing/notarization secrets | Define credential storage before external release |
| CI/CD | 1/5 | No `.github` directory or workflow file found | All CI checks | CI provider and required gates | Local-only validation can be skipped | Add minimal CI only after repo owner confirms provider |
