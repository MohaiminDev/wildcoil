# Product Specs Index

## Inferred Product Behavior
- Product name: `Rift Road: Beasts of the Afterglow`.
- Genre: macOS-first 2D side-scrolling arcade beat-'em-up.
- Current implementation target: Godot 4.x prototype under `src/wildcoil`.
- Current demo path: title screen, hero select, Stage 1, enemy waves, Brask Noll boss, victory screen, and macOS package, as described in `to-do.md`.
- Current playable heroes in runtime data: Raya Flint and Nika Sol, from `src/wildcoil/data/characters.json`.
- Current campaign data contains eight stages, validated by `tests/test_full_campaign.py`.
- Current controls are documented in `docs/game-story.md`: movement through WASD/arrow keys, attack `J`, jump `K`, special `L`, grab/interact `U`, dash/dodge `I`, pause `Esc`.
- Current originality rule: all content must be original or clearly marked as original placeholder work, per `docs/game-story.md` and `docs/asset_provenance_register.md`.

## Source Docs
- `README.md`
- `to-do.md`
- `docs/game-story.md`
- `docs/game_spec.md`
- `docs/asset_provenance_register.md`
- `src/wildcoil/data/*.json`
- `tests/test_full_campaign.py`

## Unknowns
- TODO(source-needed): final release scope.
- TODO(source-needed): supported Godot version.
- TODO(source-needed): save/load behavior requirements.
- TODO(source-needed): controller mapping and supported controller list.
- TODO(source-needed): audio implementation plan.
- TODO(source-needed): external tester distribution policy.
