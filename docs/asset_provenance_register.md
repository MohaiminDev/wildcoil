# Wildcoil Asset Provenance Register

Track every non-trivial imported asset, tool dependency, plugin, font, audio pack, and code import here. If the source is unknown, the asset is not approved.

## Current State

As of 2026-03-05, no third-party art, audio, font, plugin, or engine-specific package has been approved for committed use in the public project docs. Record new items here before they become habitual dependencies.

## Register

| ID | Type | Description | Source / URL | Creator / Vendor | License | Phase used | Placeholder or permanent | Replacement needed for future open source? | Verified by | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ORIG-001 | Documentation | Project planning docs and prose in this repository | Local repository authorship | Project author | Repository license applies | Phase 0 | Permanent | No | TBD | Applies only to original written documentation |
| TMP-001 | Art | Graybox shapes, primitive materials, and temporary silhouettes authored in-engine | Self-authored at creation time | Project author | Original work | Phase 0-1 | Placeholder | No, unless external textures are added later | TBD | Safe default for early spikes |
| HOLD-001 | External asset intake placeholder | Any future third-party asset under consideration | Record before use | TBD | TBD | Any | Hold | Assume yes until verified otherwise | TBD | Do not commit unclear-source assets |

## Intake Rules

- Record the asset before or at the same time it enters the repo.
- Mark whether it is a placeholder or a permanent dependency.
- If future open-source release is uncertain, treat replacement as required until proven otherwise.
- Keep code dependencies that affect build or packaging visible here or in a linked dependency appendix later.
# Rift Road Prototype Addendum

As of 2026-04-27, the playable prototype uses only programmatically drawn placeholder rectangles, circles, bars, and labels from local Godot scripts. No external art, audio, sprites, fonts, logos, ROMs, traced assets, or third-party asset packs were added for the Rift Road scaffold.

| Asset / system | Source | License / provenance | Notes |
| --- | --- | --- | --- |
| Raya, Nika, Iron Veil enemies, Brask, pickups, road, crystals, HUD placeholders | Programmatic drawing in `src/wildcoil/scripts/*.gd` | Original placeholder work created in-repo | Replace with original sprite sheets and sounds later |
| Generated procedural audio tones | Generated in `audio_manager.gd` with local `AudioStreamWAV` tone/chord synthesis | Original placeholder code | No external sound files included yet; replace with final original SFX/music later |

## Stage 1 Visual Production Addendum

| Asset / system | Source | License / provenance | Notes |
| --- | --- | --- | --- |
| `docs/design-docs/assets/stage1-visual-north-star.png` | AI-generated concept reference created during Codex planning | Project-bound concept reference; not runtime art | Mood and quality target only. Do not copy generated details literally unless supported by `docs/game-story.md`. |
| `docs/design-docs/assets/stage1-background-north-star.png` | AI-generated concept reference created during Codex planning | Project-bound concept reference; not runtime art | Environment quality target only. Runtime background art should be derived intentionally and reviewed in-game before acceptance. |
| `docs/design-docs/assets/stage1-generated-hero-boss-sheet.png` | Saved copy of this session's generated hero/boss source sheet | Project-bound placeholder runtime art source | Preserved as the approved source image for the current Raya, Nika, Iron Veil grunt, and Brask cutouts. |
| `docs/design-docs/assets/stage1-generated-enemy-sheet.png` | Saved copy of this session's generated Stage 1 enemy source sheet | Project-bound placeholder runtime art source | Preserved as the approved source image for the current runner, brute, scrap hurler, raptorling, and hornbeak cutouts. |
| `docs/design-docs/assets/stage1-generated-background-painting.png` | Saved copy of this session's generated Stage 1 background painting | Project-bound placeholder runtime art source | Preserved as the approved source image for the current Stage 1 background layer crops. |
| `src/wildcoil/assets/stage1/` runtime asset slots | Local repository structure | Original project structure | Runtime assets must be copied here before use and recorded in this register. |
| `src/wildcoil/data/visual_assets.json` | Local repository authorship | Original project data | Manifest for Stage 1 image-backed backgrounds and actor sprites. |
| `src/wildcoil/assets/stage1/backgrounds/*.png` | Runtime crops and overlays derived from `src/wildcoil/assets/stage1/source/generated_stage1_background.png` | Project-bound placeholder runtime art | Covers far sunset ruins, mid overpass props, cracked road playfield, and foreground atmosphere. Replace or paint over during the final art pass. |
| `src/wildcoil/assets/stage1/actors/raya_flint_*.png` | Transparent runtime cutouts derived from `src/wildcoil/assets/stage1/source/generated_actor_sheet_alpha.png` | Project-bound placeholder runtime art | Image-backed Raya idle, walk, attack, and hurt poses for runtime proof. Replace with final original sprite sheet later. |
| `src/wildcoil/assets/stage1/actors/nika_sol_*.png` | Transparent runtime cutouts derived from `src/wildcoil/assets/stage1/source/generated_actor_sheet_alpha.png` | Project-bound placeholder runtime art | Image-backed Nika idle, walk, attack, and hurt poses for runtime proof. Replace with final original sprite sheet later. |
| `src/wildcoil/assets/stage1/actors/iron_veil_grunt_*.png` | Transparent runtime cutouts derived from `src/wildcoil/assets/stage1/source/generated_actor_sheet_alpha.png` | Project-bound placeholder runtime art | Image-backed Iron Veil grunt idle, walk, attack, and hurt poses for runtime proof. Replace with final original sprite sheet later. |
| `src/wildcoil/assets/stage1/actors/iron_veil_runner_*.png` | Transparent runtime cutouts derived from `src/wildcoil/assets/stage1/source/generated_stage1_enemy_sheet_alpha.png` | Project-bound placeholder runtime art | Image-backed Stage 1 runner idle, walk, attack, and hurt poses for runtime proof. Replace with final original sprite sheet later. |
| `src/wildcoil/assets/stage1/actors/iron_veil_brute_*.png` | Transparent runtime cutouts derived from `src/wildcoil/assets/stage1/source/generated_stage1_enemy_sheet_alpha.png` | Project-bound placeholder runtime art | Image-backed Stage 1 brute idle, walk, attack, and hurt poses for runtime proof. Replace with final original sprite sheet later. |
| `src/wildcoil/assets/stage1/actors/scrap_hurler_*.png` | Transparent runtime cutouts derived from `src/wildcoil/assets/stage1/source/generated_stage1_enemy_sheet_alpha.png` | Project-bound placeholder runtime art | Image-backed Stage 1 scrap hurler idle, walk, attack, and hurt poses for runtime proof. Replace with final original sprite sheet later. |
| `src/wildcoil/assets/stage1/actors/frightened_raptorling_*.png` | Transparent runtime cutouts derived from `src/wildcoil/assets/stage1/source/generated_stage1_enemy_sheet_alpha.png` | Project-bound placeholder runtime art | Image-backed Stage 1 raptorling idle, walk, attack, and hurt poses for runtime proof. Replace with final original sprite sheet later. |
| `src/wildcoil/assets/stage1/actors/hornbeak_dinosaur_*.png` | Transparent runtime cutouts derived from `src/wildcoil/assets/stage1/source/generated_stage1_enemy_sheet_alpha.png` | Project-bound placeholder runtime art | Image-backed Stage 1 hornbeak dinosaur idle, walk, attack, and hurt poses for runtime proof. Replace with final original sprite sheet later. |
| `src/wildcoil/assets/stage1/actors/brask_noll_*.png` | Transparent runtime cutouts derived from `src/wildcoil/assets/stage1/source/generated_actor_sheet_alpha.png` | Project-bound placeholder runtime art | Image-backed Brask idle, attack, and hurt poses for runtime proof. Replace with final original sprite sheet later. |
| `src/wildcoil/assets/stage1/source/generated_actor_sheet*.png` | Generated through the built-in image generation tool for this session, then chroma-keyed locally | Project-bound placeholder runtime art source | Source sheet for the current Stage 1 actor cutouts. Replace with final original sprite sheets later. |
| `src/wildcoil/assets/stage1/source/generated_stage1_enemy_sheet*.png` | Generated through the built-in image generation tool for this session, then chroma-keyed locally | Project-bound placeholder runtime art source | Source sheet for the Stage 1 runner, brute, scrap hurler, raptorling, and hornbeak cutouts. Replace with final original sprite sheets later. |
| `src/wildcoil/assets/stage1/source/generated_stage1_background.png` | Generated through the built-in image generation tool for this session | Project-bound placeholder runtime art source | Source painting for the current Stage 1 background layer crops. Replace or repaint during final art pass. |
