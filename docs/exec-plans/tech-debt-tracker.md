# Technical Debt Tracker

Track small, verifiable debt items that affect agent readability, runtime confidence, or release hygiene.

| ID | Debt | Evidence | Status | Small next action |
|---|---|---|---|---|
| TD-001 | Supported Godot version was not pinned in a machine-checkable way. | `scripts/check_godot_version.sh` now requires Godot 4.6.x stable and is called by `scripts/check.sh`. | Addressed | Decide later whether to pin a specific Godot 4.6.x patch release. |
| TD-002 | No CI workflow is present. | `find .github` returned no directory during migration inspection. | Open | Add CI only after provider and desired gates are confirmed. |
| TD-003 | No lint/type-check command is discoverable. | No `pyproject.toml`, `ruff`, `mypy`, Godot lint config, Makefile, tox, or nox file was found. | Open | Decide whether a lightweight lint command is worth adding after runtime docs migration. |
| TD-004 | Packaging depends on local Godot export templates. | `scripts/package_macos.sh`; `docs/macos_build_and_distribution.md` notes export templates are required. | Open | Document exact template installation path once confirmed. |
| TD-005 | Full demo flow has limited automated coverage. | `to-do.md` requires title, hero select, Stage 1, boss, victory, package; tests cover structure and smoke checks, not a full victory path. | Open | Add deterministic autoplay validation when the flow is stable enough. |
| TD-006 | Agent guidance was previously concentrated in `AGENTS.md`. | Pre-migration `AGENTS.md` contained stale statements that no `src/` or `tests/` tree existed. | Addressed in this change | Keep `AGENTS.md` short and validate line count with `scripts/check_agent_docs.py`. |
