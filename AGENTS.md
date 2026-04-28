# AGENTS.md

## Repo Purpose
Wildcoil currently hosts `Rift Road: Beasts of the Afterglow`, a macOS-first Godot 4.x 2D arcade beat-'em-up prototype. Runtime code lives in `src/wildcoil`, tests live in `tests`, and contributor-facing docs live in `docs`.

## Fast Path
1. Read `README.md` for the current milestone and local commands.
2. Read `to-do.md` for the active task tracker and validation gate.
3. Read `ARCHITECTURE.md` for the runtime map before changing code.
4. Read `docs/game-story.md` and `docs/product-specs/index.md` before changing product behavior.
5. Read `docs/exec-plans/active/` before starting planned work.

## System of Record
- Architecture: `ARCHITECTURE.md`
- Product specs: `docs/product-specs/index.md`, `docs/game-story.md`, `docs/game_spec.md`
- Execution plans: `docs/exec-plans/`, `docs/PLANS.md`, `.codex/`
- Design guidance: `docs/DESIGN.md`, `docs/design-docs/`
- Frontend/UI guidance: `docs/FRONTEND.md`
- Reliability: `docs/RELIABILITY.md`
- Security/config: `docs/SECURITY.md`
- Quality tracking: `docs/QUALITY_SCORE.md`, `docs/exec-plans/tech-debt-tracker.md`
- References: `docs/references/index.md`
- Generated references: `docs/generated/index.md`

## Commands
- Setup: TODO(source-needed): setup command
- Run game: `bash scripts/run_game.sh`
- Test: `python3 -m pytest tests -v`
- Full validation: `bash scripts/check.sh`
- Docs structure check: `python3 scripts/check_agent_docs.py`
- Package macOS build: `bash scripts/package_macos.sh`
- Lint: TODO(source-needed): lint command

Set `GODOT_BIN=/path/to/godot` when `godot` is not on `PATH`.

## Agent Rules
- Preserve runtime behavior unless explicitly asked to change it.
- Do not invent architecture, deployment details, commands, owners, or SLAs.
- Prefer existing repo patterns and small, reviewable changes.
- Update docs when changing behavior, structure, or workflow.
- Add or update tests for behavior changes.
- Do not log, print, copy, or expose secrets.
- Keep runtime assets and scenes inside `src/wildcoil`.
- Keep public planning/status in `to-do.md` and `docs/`; keep Codex-only continuity in `.codex/`.
- Use `docs/game-story.md` as the story bible for `Rift Road: Beasts of the Afterglow`.
- Run the relevant validation before commit or handoff.
- For Databricks code, if introduced later, prefer `pathlib`, Unity Catalog-aware paths, Databricks secret scopes, and job/app-safe configuration.

## Commit/Push Notes
- Complete one tracker task at a time.
- Run that task's full validation before commit.
- Commit and push immediately once green only when commit/push is requested.
- After any requested commit or push, include the exact commit message and a short description in the final response.
