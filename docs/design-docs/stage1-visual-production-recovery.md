# Stage 1 Visual Production Recovery Plan

## Why This Exists

The current Godot build is mechanically playable, but it does not visually match the approved north-star concept. It still relies heavily on programmatic shapes, simple panels, and placeholder effects. That is useful for proving flow and combat scaffolding, but it is not production-grade visual output.

This plan corrects the path: make Stage 1 asset-backed first, then judge it by screenshots and manual play, not just automated checks.

## Current Truth

- The title, hero select, Stage 1 waves, Brask Noll boss path, and victory flow can be verified mechanically.
- The runtime has useful combat/UI systems: attack buffering, hit stop, boss telegraph hooks, HUD panels, and placeholder audio hooks.
- The presentation is still prototype-grade and does not match the generated concept image.
- The stale `build/macos/Wildcoil.app` is not the current Rift Road build and must not be used for playtest decisions.
- The current user-facing package is `build/macos/Rift Road.zip`; playtests must extract and launch `Rift Road- Beasts of the Afterglow.app` from that zip.

## Recovery Goal

Create an asset-backed Stage 1 vertical slice that visually moves toward the approved concept:

- painted or sprite-sheet-based Stage 1 background layers;
- image-backed Raya and Nika gameplay sprites;
- image-backed Iron Veil grunt/runner/brute sprites;
- image-backed Brask Noll boss sprite;
- image-backed combat FX overlays;
- title and hero select that share the same visual language;
- screenshots from a real launched app proving the direction.

## Slice 1: One-Screen Art Replacement

Do this before expanding scope.

1. Replace the Stage 1 far/mid/road background with imported image layers.
2. Replace at least Raya and one Iron Veil grunt with image-backed sprites.
3. Keep existing collision, AI, and combat timing.
4. Capture a real in-game screenshot with the player and enemy on the new background.
5. Compare that screenshot against the north-star concept and decide whether to iterate or continue.

Success means the screenshot no longer reads as rectangle/polygon prototype art.

## Asset Requirements

### Stage 1 Background Layers

- `far_sky_ruins`: sunset sky, distant jungle, ruined road silhouettes.
- `mid_overpass`: broken railings, transport cages, ruined signage, jungle growth.
- `road_playfield`: cracked asphalt with readable belt-scroll floor and luma cracks.
- `foreground_atmosphere`: optional dust, leaves, luma glints, and edge framing.

### Character Sprite Requirements

For the first slice, each actor needs only enough frames to prove style:

- idle;
- walk or ready stance;
- one attack pose;
- hurt pose.

Priority order:

1. Raya Flint.
2. Iron Veil Grunt.
3. Brask Noll.
4. Nika Sol.
5. Runner and brute.

### UI Requirements

- Keep the existing HUD behavior.
- Replace flat panels only after the playfield art reads correctly.
- Do not let UI work delay the first gameplay screenshot.

## Implementation Strategy

- Add project assets under `src/wildcoil/assets/stage1/`.
- Add a small asset manifest under `src/wildcoil/data/visual_assets.json`.
- Add a visual asset loader that safely falls back to current programmatic drawing if an asset is missing.
- Introduce image-backed background layers first, because they have the largest immediate visual impact.
- Introduce image-backed character sprites one actor at a time.
- Keep all old programmatic shapes as fallback until the replacement is visibly better.

## Validation

Mechanical validation still matters:

```bash
python3 -m pytest tests -v
bash scripts/check.sh
bash scripts/package_macos.sh
```

But this plan is not complete until there is visual evidence:

- real screenshot from the launched game window;
- screenshot includes Stage 1 background plus at least one playable hero and one enemy;
- screenshot is compared against the north-star concept;
- any mismatch is written down instead of hidden behind green tests.

## Non-Goals

- Do not build all eight stages.
- Do not add new gameplay systems before the first asset-backed screenshot.
- Do not keep polishing programmatic rectangles.
- Do not call the result production-grade until manual play and screenshots support that claim.
