# Security

## Secret Handling
- No committed secret values were found during this migration.
- `src/wildcoil/export_presets.cfg` contains empty signing fields for `codesign/identity` and `codesign/apple_team_id`.
- `scripts/check_macos_signing_env.sh` checks only non-secret signing readiness inputs and never requires raw certificate material or notary passwords.
- `docs/macos_release_inputs.example.env` is a placeholder-only local setup template. Do not commit real copied values; `.env` is ignored by git.

## Environment Variables
| Variable | Evidence | Purpose |
|---|---|---|
| `GODOT_BIN` | `README.md`, `scripts/*.sh`, `tests/conftest.py` | Override the Godot executable used by local scripts and tests |
| `RIFT_ROAD_APPLE_TEAM_ID` | `scripts/check_macos_signing_env.sh` | Non-secret Apple team identifier expected by the macOS release preflight |
| `RIFT_ROAD_DEVELOPER_ID_APPLICATION` | `scripts/check_macos_signing_env.sh` | Name of the Developer ID Application identity expected in the local keychain |
| `RIFT_ROAD_NOTARY_KEYCHAIN_PROFILE` | `scripts/check_macos_signing_env.sh` | Name of a pre-stored `xcrun notarytool` keychain profile; do not commit notary passwords |

Use `docs/macos_release_inputs.example.env` as the redacted template for local release input setup. Keep real values outside version control.

## Data And PII
- The repo contains game content JSON, docs, tests, scenes, scripts, and local build guidance.
- No PII-specific handling path was found.
- TODO(source-needed): any future telemetry, crash reporting, save data, or player data policy.

## Databricks
- No Databricks evidence was found: no `databricks.yml`, notebooks, `dbutils`, Unity Catalog references, DBFS/Volumes/ADLS paths, Streamlit-on-Databricks notes, Databricks Jobs, or MLflow-on-Databricks references.
- If Databricks code is added later, use Databricks secret scopes, Unity Catalog-aware paths, `pathlib` where Python paths are needed, and job/app-safe configuration patterns.

## Agents Must Never Log
- Signing identities, Apple Team IDs, certificate material, notarization credentials, tokens, passwords, API keys, personal data, or private endpoint values.
- Local filesystem secrets or shell environment dumps.
- Raw future save files, crash reports, or telemetry payloads if they can contain user data.

## Known Gaps
- Release signing is blocked until `scripts/check_macos_signing_env.sh` reports `RIFT_ROAD_SIGNING_PREFLIGHT ready`.
- TODO(source-needed): release signing credential storage process.
- TODO(source-needed): notarization credential process beyond the non-secret keychain profile name.
- TODO(source-needed): third-party service credentials, if any are introduced.
- TODO(source-needed): save-data privacy and retention rules, if save/load is added.
