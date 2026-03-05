# Repository Guidelines

## Project Structure & Module Organization
This repository is currently documentation-first. [`README.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/README.md) is the entry point, [`arcade_heritage_game_master_contract.txt`](/Users/himu/Desktop/career/personal_projects/wildcoil/arcade_heritage_game_master_contract.txt) defines the game vision and production constraints, and [`LICENSE`](/Users/himu/Desktop/career/personal_projects/wildcoil/LICENSE) covers reuse terms. No `src/` or `tests/` tree is committed yet. When implementation begins, place runtime code in `src/`, automated tests in `tests/`, and longer design notes in `docs/` instead of adding more root-level files.

## Build, Test, and Development Commands
No build pipeline or runnable prototype is checked in yet, so keep setup lightweight and document new tooling in the same PR that introduces it. Useful current commands:

- `rg --files` to inspect the tracked layout quickly.
- `python -m pytest` once a `tests/` suite exists.
- `ruff check .` and `ruff format .` if Python source is added.

If you introduce a different stack, add its install, run, and test commands to `README.md` immediately.

## Coding Style & Naming Conventions
The existing `.gitignore` is Python-oriented, so default to Python conventions unless the project formally adopts another language. Use 4-space indentation, descriptive module names such as `combat_loop.py`, `stage_flow.py`, or `enemy_spawn_rules.py`, PascalCase for classes, and UPPER_SNAKE_CASE for constants. Keep modules focused, prefer pure functions for deterministic gameplay logic, and separate implementation files from design or production notes.

## Testing Guidelines
No test framework is committed yet. New code should arrive with `pytest`-style tests in `tests/` named `test_<feature>.py`. Prioritize deterministic coverage for combat rules, stage progression, save/load behavior, and content validation. New gameplay systems should not merge without at least one regression test.

## Commit & Pull Request Guidelines
The visible history currently starts with `Initial commit`, so use short, imperative commit subjects going forward, for example `docs: add combat prototype checklist` or `feat: scaffold stage loader`. When a contributor asks for a commit message plus description, return it in a fenced `txt` block so it is easy to copy, using this exact template:

```txt
Commit Message

Desc
- <dash bullet item 1>
- <dash bullet item 2>
```

Use `-` for bullets, not dots. Keep pull requests focused and include a summary, motivation, linked issue or task, and screenshots or short clips for gameplay, UI, or asset changes. Call out third-party asset provenance and licensing in the PR description.

## Agent-Specific Instructions
Treat this file as a living contributor memory. Update `AGENTS.md` whenever you learn a stable user preference, working convention, or durable solution to a repeated issue so future sessions do not repeat the same back-and-forth. Record only concise, reusable guidance that is relevant to contributors in this repository.
