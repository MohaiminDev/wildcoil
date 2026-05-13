# Product Specs Index

## Inferred Product Behavior
- Product name: `Rift Road: Beasts of the Afterglow`.
- Genre: macOS-first modern cinematic 2D arcade beat-'em-up / belt-scroll brawler.
- Current implementation target: Godot 4.6.x stable prototype under `src/wildcoil`, with M1 iMac as the primary performance target.
- Current spec target: one polished Stage 1 episode with Raya and Nika, opening story panels and barks, three enemy types, Brask Noll, a road-collapse set piece, simple pickups, HUD, pause, debug overlay, score/rank summary, short ending scene, and macOS package.
- Current demo path: title screen, hero select, Stage 1 opening story, enemy waves, simple health/luma pickups, Brask Noll boss story beats, Stage Clear score/rank summary, restart or return-to-title, and macOS package, as described in `to-do.md`.
- Current playable demo heroes: Raya Flint and Nika Sol. Kian Vale and Tor Bram remain visible in hero select as planned preview cards, but they do not start Stage 1.
- Current campaign data contains eight stages, validated by `tests/test_full_campaign.py`, but `docs/game_spec.md` says production must not depend on building all eight early; Stage 1 quality comes first.
- Current keyboard controls are documented in `docs/game-story.md`: movement through WASD/arrow keys, attack `J`, jump `K`, special `L`, grab/interact `U`, dash/dodge `I`, pause `Esc`.
- Current automated keyboard fallback coverage: `keyboard_fallback_flow` in `src/wildcoil/tools/runtime_test_runner.gd` checks title, hero select, preview cancel/back, Stage 1 start, movement, attack, jump, special, dash, and pause/resume.
- Current automated exported-app keyboard fallback coverage: `bash scripts/smoke_exported_keyboard_fallback.sh` launches the zipped app and records JSON plus viewport evidence for the same keyboard path.
- Current automated exported-app focus/resume coverage: `bash scripts/smoke_exported_focus_resume.sh` launches the zipped app and records JSON plus viewport evidence for Stage 1 focus-pause, overlay, audio-manager state, return-focus copy, and resume.
- Current automated focus-loss coverage: `stage1_focus_resume` in `src/wildcoil/tools/runtime_test_runner.gd` checks Stage 1 auto-pause on focus loss, visible pause overlay, audio-manager suspend/resume state, return-focus copy, and Esc resume.
- Current baseline gamepad mapping: left stick/D-pad move, `X` attack, `A` jump/confirm, `Y` or left bumper special, `B` or right bumper dash/cancel, shoulder/D-pad hero selection, `Start` pause/confirm.
- Current automated controller hot-plug coverage: `controller_hotplug_status` in `src/wildcoil/tools/runtime_test_runner.gd` checks the Godot connection-change handler, connected/disconnected runtime state, and menu prompt status persistence.
- Current originality rule: all content must be original or clearly marked as original placeholder work, per `docs/game-story.md` and `docs/asset_provenance_register.md`.
- Current public-claim rule: the first success condition is that Stage 1 feels good, looks alive, and is satisfying to play on the target Mac; market-facing claims come only after playtest evidence.
- Current external-session protocol: `docs/public_playtest_gate.md` defines the public-playtest evidence threshold, while the current package remains internal-only until signing, notarization, Gatekeeper, second-machine, controller, focus/audio, and playtest evidence gates pass.

## Source Docs
- `README.md`
- `to-do.md`
- `docs/game-story.md`
- `docs/game_spec.md`
- `docs/asset_provenance_register.md`
- `src/wildcoil/data/*.json`
- `tests/test_full_campaign.py`

## Unknowns
- TODO(source-needed): final release scope after Stage 1 playtest evidence.
- TODO(source-needed): save/load behavior requirements.
- TODO(source-needed): physically tested supported controller list.
- TODO(source-needed): audio implementation plan.
- TODO(source-needed): final external tester distribution approval after signing/notarization and evidence gates pass.
