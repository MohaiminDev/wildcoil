# Core Beliefs

These beliefs are specific to this repository's current state.

- The real runtime is the Godot project under `src/wildcoil`; docs must point back to that project instead of describing imagined systems.
- `AGENTS.md` is a map. Detailed and changing knowledge belongs in versioned docs under `docs/`.
- `to-do.md` is the public task/status source of truth; `.codex/` is for Codex-only continuity.
- Preserve the original `Rift Road: Beasts of the Afterglow` direction and originality safeguards unless a source doc changes.
- Keep behavior changes coupled to tests or explicit validation evidence.
- Keep assets traceable in `docs/asset_provenance_register.md` before they become dependencies.
- Prefer small local scripts over new dependencies when adding enforcement.
- Unknowns should stay visible as `TODO(source-needed): <specific missing fact>` rather than being filled with guesses.
