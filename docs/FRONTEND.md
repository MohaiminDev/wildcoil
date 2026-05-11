# Frontend And UI

This repository does not contain a web frontend. User-facing presentation currently lives in the Godot project.

## Runtime UI Evidence
- `src/wildcoil/scripts/app_root.gd` builds title, hero select, capability preview, pause, game-over, completion overlays, and exported-app smoke capture UI.
- `src/wildcoil/scripts/hud_controller.gd` handles player and boss HUD updates.
- `src/wildcoil/scripts/debug_overlay.gd` provides debug visibility.
- `docs/game-story.md` defines the intended HUD style and controls.
- `to-do.md` tracks the active UI and Stage 1 presentation tasks.
- Title and flow prompts in `src/wildcoil/scripts/app_root.gd` now show both keyboard and baseline gamepad controls.

## UI Guidance
- Preserve arcade readability at 1280x720 unless a source doc changes the target.
- Do not copy existing arcade HUD layouts, logos, sprites, or UI arrangements.
- Keep objective, health, boss, score, and debug text from overlapping core combat where practical.
- Validate presentation changes with the relevant pytest/Godot checks and screenshot/playtest evidence when available.

## Unknowns
- TODO(source-needed): final HUD layout.
- TODO(source-needed): font and sprite asset pipeline.
- TODO(source-needed): final controller prompt artwork and physically tested controller list.
