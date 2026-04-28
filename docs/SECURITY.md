# Security

## Secret Handling
- No committed secret values were found during this migration.
- `src/wildcoil/export_presets.cfg` contains empty signing fields for `codesign/identity` and `codesign/apple_team_id`.
- `GODOT_BIN` is the only environment variable discovered in repo scripts and tests; it points to a local Godot executable path and is not a secret by itself.

## Environment Variables
| Variable | Evidence | Purpose |
|---|---|---|
| `GODOT_BIN` | `README.md`, `scripts/*.sh`, `tests/conftest.py` | Override the Godot executable used by local scripts and tests |

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
- TODO(source-needed): release signing credential storage process.
- TODO(source-needed): notarization credential process.
- TODO(source-needed): third-party service credentials, if any are introduced.
- TODO(source-needed): save-data privacy and retention rules, if save/load is added.
