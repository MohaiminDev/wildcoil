# Agent-First Repo Migration Plan

## Current Repo Structure Summary
- `README.md` describes the current `Rift Road: Beasts of the Afterglow` milestone and local commands.
- `AGENTS.md` existed before this migration as a long contributor instruction file with stale claims that no `src/` or `tests/` tree was committed.
- `src/wildcoil` contains the production Godot project, including `project.godot`, scenes, scripts, data JSON, export presets, and a headless runtime test runner.
- `tests` contains Python `pytest` tests that inspect repo files and drive Godot headlessly.
- `scripts` contains shell wrappers for running the game, running checks, and packaging a macOS build.
- `docs` already contained game, risk, playtest, asset provenance, macOS build, engine, and implementation-plan docs.
- `.codex` contains tracked Codex-only plan continuity files.
- No `.github`, package manager manifest, Makefile, Databricks bundle, notebooks, Streamlit app, or service/API entry point was found.

## Repository Classification
| Area | Finding |
|---|---|
| Primary languages | GDScript, Python tests, Bash scripts, Markdown |
| Frameworks | Godot 4.x, pytest |
| Package manager | None found; no `pyproject.toml`, `requirements.txt`, `setup.py`, `setup.cfg`, `tox.ini`, `noxfile.py`, `Makefile`, or `package.json` was found |
| Test runner | `python3 -m pytest tests -v`; Godot headless smoke through `scripts/check.sh` |
| Lint/type checks | None found; TODO(source-needed): lint/type-check command if one is required |
| CI/CD | None found; no `.github` directory or workflow file was found |
| Deployment style | Local Godot macOS export through `scripts/package_macos.sh` and `src/wildcoil/export_presets.cfg` |
| Entry points | `scripts/run_game.sh`, `src/wildcoil/project.godot`, `src/wildcoil/scenes/app_root.tscn`, `scripts/check.sh`, `scripts/package_macos.sh` |
| Repo type | Godot game prototype with Python runtime/content tests |
| Databricks/Azure/ML/data pipeline evidence | None found |

## Current Agent-Readiness Score
**medium**

- Positive: runtime code, tests, scripts, and product docs are already in repo-local files.
- Positive: `to-do.md` provides a visible active tracker and validation gate.
- Positive: Python tests and Godot smoke checks make some repo behavior mechanically visible.
- Gap: pre-migration `AGENTS.md` mixed durable rules with stale setup guidance.
- Gap: architecture, reliability, security, quality, and plan indexes were not normalized.
- Gap: no CI or lint/type-check workflow was discoverable.

## Differentiation Table
| Current technique | Harness-engineering target | Gap | Migration action |
|---|---|---|---|
| Long `AGENTS.md` with stale repo-structure claims | Short `AGENTS.md` as table of contents | Agents can spend context on outdated instructions | Rewrite `AGENTS.md` as a concise map to structured docs |
| README and `to-do.md` carry most current workflow/status guidance | Docs directory is the versioned system of record | Product, architecture, quality, and reliability guidance are not indexed by concern | Add `ARCHITECTURE.md` and normalized docs indexes |
| Existing docs cover game direction, risks, assets, macOS notes, and an implementation plan | Deeper guidance is structured and discoverable | Docs exist but are not grouped into the harness-engineering layout | Add `docs/design-docs`, `docs/exec-plans`, `docs/generated`, `docs/product-specs`, and `docs/references` indexes |
| Tests validate runtime smoke and content | Rules enforced mechanically where safe | No check keeps `AGENTS.md` short or required docs present | Add `scripts/check_agent_docs.py` and call it from `scripts/check.sh` |
| Deployment notes are in macOS docs and package script | Deployment/config knowledge is discoverable | Signing/notarization details remain unknown | Keep known macOS packaging notes and mark unknowns as `TODO(source-needed)` |
| No Databricks evidence | Databricks docs only when evidence exists | Azure/Databricks docs would be invented | Do not create Databricks-specific docs in this change |

## Current Guidance-Risk Assessment
| Risk | Assessment | Evidence |
|---|---|---|
| README-only guidance | Medium | README has current commands and working docs, but detailed guidance also exists in `docs` and `to-do.md` |
| Long AGENTS.md guidance | High before this migration | Pre-migration `AGENTS.md` was a large instruction file and claimed no `src/` or `tests` tree existed |
| Scattered comments | TODO(source-needed): whether scattered code comments are relied on as guidance | No systematic comment audit was performed beyond targeted runtime files |
| Tribal knowledge | Medium | Signing/notarization, exact Godot version, CI expectations, and final release process are not fully specified |
| Notebook-only context | Low | No `notebooks` directory or notebook files were found |
| External docs | Low-medium | Godot/Apple references are linked from existing docs, but core project state is repo-local |
| Implicit deployment knowledge | Medium | `scripts/package_macos.sh` exists, but export templates, signing, notarization, and clean-machine setup are not fully specified |

## Smallest Safe Migration Path
### Steps taken in this change
- Inspect current files, scripts, docs, tests, and runtime entry points before editing.
- Replace `AGENTS.md` with a short table-of-contents style map.
- Add `ARCHITECTURE.md` with repo-grounded runtime structure.
- Add normalized docs directories and concise index/guidance files.
- Add reliability, security, product, frontend/UI, design, planning, quality, reference, generated-reference, and tech-debt docs.
- Add `scripts/check_agent_docs.py` to enforce required docs and `AGENTS.md` length.
- Integrate the docs check into `scripts/check.sh`.

### Follow-up steps not done in this change
- Do not refactor GDScript runtime logic.
- Do not introduce package managers, heavy dependencies, or CI without owner confirmation.
- Do not create Databricks/Azure-specific docs without repo evidence.
- Do not invent signing, notarization, telemetry, deployment, or ownership details.
- Do not add autoplay/screenshot validation until a deterministic workflow exists.
