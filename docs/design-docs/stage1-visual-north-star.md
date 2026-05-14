# Stage 1 Visual North Star

## Goal State

`Rift Road: Beasts of the Afterglow` should keep its current Godot runtime, story bible, heroes, enemies, and Stage 1 structure, then raise presentation toward a production-grade modern retro-action vertical slice.

The target is not a different game. It is the current `Sunset Overpass` prototype upgraded into a playable, cinematic, original arcade brawler: colorful prehistoric-future road adventure, stronger danger, premium combat feedback, readable human silhouettes, and clean modern arcade UI.

## Reference Images

Primary UI/combat/presentation reference: [`stage1-visual-north-star.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/design-docs/assets/stage1-visual-north-star.png)

Stage 1 environment reference: [`stage1-background-north-star.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/design-docs/assets/stage1-background-north-star.png)

Current approved male hero references: [`kian-vale-male-concept.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/design-docs/assets/kian-vale-male-concept.png) and [`tor-bram-male-concept.png`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/design-docs/assets/tor-bram-male-concept.png)

Use these as mood, composition, polish, and quality direction only. Do not copy generated details literally into runtime, and do not treat generated names, logos, character details, weapons, costumes, UI text, or story beats as canon unless they are also supported by `docs/game-story.md`.

The current running game is not visually at this level yet. Any claim of visual match must be backed by a launched-game screenshot placed beside these references during review.

## What Stays

- Game title: `Rift Road: Beasts of the Afterglow`.
- Engine: Godot 4.x under `src/wildcoil`.
- Immediate production target: Stage 1 vertical slice.
- Stage 1: `Sunset Overpass`, a cracked highway over jungle ruins at sunset.
- Heroes: Kian Vale and Tor Bram should read clearly as the first two male roster slots, with Raya Flint and Nika Sol preserving the current female roster direction.
- Faction: Iron Veil Excavation.
- Boss: Brask Noll.
- Theme: coexistence versus extraction.
- Originality rule: no copied characters, sprites, layouts, logos, vehicles, UI, music, or recognizable designs from existing games or brands.

## Visual Direction

- Modern stylized arcade realism, not photorealism.
- Pixel-art-inspired readability with stronger hand-drawn silhouettes.
- Warm sunset sky, jungle greens, charcoal road shapes, violet/green luma accents, and industrial hazard details.
- Layered depth: distant ruins, jungle silhouettes, broken railings, cracked overpass slabs, service lane shadows, road debris, luma cracks, dust, sparks, and foreground atmosphere.
- Human characters should read as people at gameplay distance through head, torso, arms, legs, stance, pose, and weapon shape.
- Enemies should feel physical and threatening, but still readable and original.
- Combat effects should emphasize timing: hit stop, sparks, dust, knockback, attack arcs, camera punch, boss telegraphs.

## UI Direction

- Premium arcade expedition interface.
- Keep HUD clean and readable at 1280x720.
- Use player name, health, special meter, score/luma, objective, combo, and boss bar without crowding the combat plane.
- Menus should feel fast, polished, and controller-ready later.
- Cinematic banners should be short and functional: stage start, wave start, boss entrance, stage clear.
- The title screen and hero select must stop reading as placeholder panels and simple shapes before this visual goal can be considered met.

## Runtime Acceptance Criteria

- A player can start from title, choose or default into Kian for the current source-run slice, play Stage 1, fight Brask Noll, and reach victory.
- Stage 1 visibly communicates a ruined jungle overpass at sunset.
- Kian, Tor in preview, Raya, Nika, human enemies, creatures, and Brask are readable as distinct silhouettes at 1280x720.
- Combat hits have visible impact feedback and brief weight without hiding the actors.
- Boss attacks telegraph before damage and Brask has clear phase escalation.
- HUD text and bars remain readable and do not overlap key combat action.
- Title, hero select, HUD, pause/victory, and boss UI visually belong to the same polished arcade interface family as the references.
- A real launched-game screenshot must show the current build compared against the generated north-star images.
- `bash scripts/check.sh` passes before handoff.
- `bash scripts/package_macos.sh` can create the macOS build before release handoff.

## Non-Goals

- Do not restart in browser.
- Do not rebuild the engine architecture.
- Do not make a full 5-stage or 8-stage game before Stage 1 is strong.
- Do not add online multiplayer.
- Do not chase realistic 3D or AAA asset density.
- Do not replace Rift Road with generic cyberpunk, generic post-apocalypse, or copied arcade nostalgia.
