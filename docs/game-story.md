# Rift Road: Beasts of the Afterglow

## One-Sentence Pitch

`Rift Road: Beasts of the Afterglow` is an original 2D arcade beat-'em-up where four road warriors cross a glowing prehistoric future to stop a mining empire from draining the living crystal heart of the world.

## Core Identity

- Genre: 2D side-scrolling arcade beat-'em-up
- Target platform: macOS desktop
- Visual style: colorful 1990s-inspired arcade action with original prehistoric creatures, road-adventure staging, and crisp pixel-art animation
- Production rule: spiritual successor, not a remake

Do not copy characters, names, sprites, music, maps, UI, bosses, dialogue, logos, ROM code, vehicle branding, or recognizable layouts from any existing game, comic, film, car company, or dinosaur franchise. Every hero, enemy, creature, vehicle, stage, animation, sound, and interface element must be original or clearly marked as original placeholder work.

## Core Idea

Future Earth has been reshaped by the Red Aurora, a solar-magnetic storm that cracked open ancient underground ecosystems below ruined cities and highways. Forests of mineral light, glowing plants, prehistoric creatures, engineered beasts, and strange underground life now spill into the surface world.

Four heroes travel across the broken continent in a rugged solar-powered expedition crawler called the `Sundrifter`. Their route crosses ruined highways, jungle cities, skybridges, biodomes, rail tunnels, volcanic machine towns, and the living crystal depths of the `Afterglow Belt`.

Their mission is to stop `Iron Veil Excavation`, a rogue mining syndicate drilling toward the `Afterglow Rift`, a living luma-crystal network that keeps the revived ecosystems stable. If Iron Veil fractures the rift, unstable energy will flood the world and mutate its creatures beyond recovery.

The tone is adventurous, colorful, dramatic, and fun: a playable Saturday-morning arcade adventure with fast action, heroic banter, expressive animation, big bosses, dangerous dinosaurs, vehicle moments, secret areas, and short cinematic stage transitions.

## Main Theme

The game is about rebuilding a broken world without exploiting it again.

Iron Veil sees prehistoric energy as property. The heroes see the new world as alive, fragile, and shared. Every level should show the conflict between extraction and coexistence through enemy behavior, stage hazards, creature encounters, civilian stakes, and boss consequences.

## World Background

The world is called the `Afterglow Belt`.

Fifty years ago, the Red Aurora split deep caverns under the old cities. Inside were ecosystems preserved by mineral light. Some creatures were prehistoric. Some evolved underground. Some were changed by radiation from glowing crystals called `luma stone`.

Human survivors built settlements around old roads, biodomes, rail tunnels, cliff cities, and solar salvage routes. For a while, people learned to coexist with the creatures and the crystal ecology.

Then Iron Veil Excavation began hunting rare luma stone to power weapons, engines, and private cities. Its drilling destabilizes migration routes, makes dinosaurs aggressive, drains settlements, and causes the Afterglow Rift to pulse with dangerous storms.

The heroes discover Iron Veil is building the `Deep Crown`, a machine designed to drain the entire crystal network and force every settlement to depend on Iron Veil for survival.

## Playable Heroes

Each hero needs a distinct silhouette, color palette, movement style, combat rhythm, personality, and failure profile. The MVP ships with Raya and Nika first; Kian and Tor remain planned full-roster heroes.

### Raya Flint

Raya is the expedition mechanic and driver of the Sundrifter.

- Visual identity: cropped reinforced field jacket, utility belt, mechanic gloves, knee guards, moving scarf, rust-orange, charcoal, and warm cream
- Personality: brave, practical, sarcastic, protective, and distrustful of any machine she has not personally inspected
- Combat role: balanced all-rounder with medium speed, medium damage, and reliable combos
- Signature moves: Spanner Jab, Gearbreaker Kick, Overdrive Slam, Field Repair
- Animation notes: wrench shifts in idle, confident mechanic stride, heavy but responsive attack arcs, spark flashes on special impact, guarded quick recovery when hurt

### Kian Vale

Kian is the wildlife biologist and field medic.

- Visual identity: lightweight expedition armor, seed capsules, small medical satchel, translucent green goggles, moss-green, white, and deep blue
- Personality: curious, calm, witty, compassionate toward animals, and reluctant to harm frightened creatures
- Combat role: technical crowd-control fighter with faster recovery, lower raw damage, and strong nonlethal control tools
- Signature moves: Pulse Staff Combo, Vine Snare, Sonic Whistle, Med Patch
- Animation notes: scanner pulse in idle, alert walking, clean circular staff strikes, organic bio-tech pulse effects, goggles slipping during hurt recovery

### Nika Sol

Nika is a courier, scout, and former skybridge racer.

- Visual identity: sleek athletic outfit, light armor pads, short cape or streamer cloth, high-traction boots, electric violet, black, and silver
- Personality: fearless, funny, impatient, competitive, and always reading danger like a race checkpoint
- Combat role: fastest hero with low health, high mobility, and strong aerial attacks
- Signature moves: Flash Step, Heel Arc, Skyline Drop, Static Burst
- Animation notes: runner's bounce in idle, speed-line cape movement, quick readable attack frames, short electric-violet burst, fast rollback recovery when hurt

### Tor Bram

Tor is an ex-security guard from Iron Veil who changed sides.

- Visual identity: large broad silhouette, reinforced boots, heavy forearm guards, patched industrial armor, steel-gray, dark red, and sandy tan
- Personality: quiet, loyal, guilty, and deliberate with every word
- Combat role: slowest hero, highest health, strongest throws
- Signature moves: Hammer Fist, Shoulder Ram, Titan Throw, Hold the Line
- Animation notes: glove checks in idle, heavy dust-puff steps, big anticipation frames, powerful throws, weak hits barely move him

## Antagonists

### Mara Voss

Mara Voss is the director of Iron Veil Excavation. She is an elegant industrial commander in a black-and-gold hazard coat with a sharp mechanical gauntlet and calm expression. She is cold, persuasive, strategic, and not cartoonishly evil. Mara believes civilization requires control. Her goal is to use the Deep Crown to monopolize luma energy and force every settlement to depend on Iron Veil.

### Dr. Oren Klade

Dr. Oren Klade is a rogue paleotech engineer with glowing lab lenses, a long reinforced coat, and a portable control rig. He is brilliant, unstable, fascinated by hybrid creatures, and obsessed with battlefield experiments. His goal is to create controllable luma-mutated beasts.

### Brask Noll

Brask Noll is Iron Veil's field captain and the Stage 1 boss. He wears heavy armor, a scarred helmet, and carries a hydraulic axe. He is loud, brutal, impatient, and focused on capturing the heroes and recovering stolen rift maps.

## Gameplay Summary

The game uses a 2D side-scrolling brawler camera. Players move left and right, plus slightly up and down on a belt-scroll plane. The initial release is single-player, but architecture should stay local-co-op-ready for up to four players later.

### Core Loop

1. Enter a combat arena.
2. Enemies arrive from both sides, background paths, doors, or vehicles.
3. Defeat waves using positioning, attacks, grabs, specials, and pickups.
4. Gather health, temporary weapons, and luma shards.
5. Continue to the next screen.
6. Finish each stage with a boss, creature set-piece, or cinematic event.

### Controls

- Move: WASD or arrow keys
- Attack: J
- Jump: K
- Special: L
- Grab / interact: U
- Dash / dodge: I
- Pause: Esc

### Combat Requirements

Each hero needs a light attack chain, jump attack, grab, throw, special attack using meter, dodge or defensive action, knockdown and get-up states, pickup weapon use, hurt states, and victory pose.

Combat must use startup, active, and recovery timing. Hitboxes only deal damage during active frames. Knockback direction is based on attacker and defender positions. The player receives brief invulnerability after damage. Heavy hits and boss impacts get short hit pause. Button mashing must not break animation state.

### Weapons and Pickups

Temporary weapons include pipe wrench, shock baton, road flare, crate lid shield, luma spear, scrap hammer, throwable rocks, and fuel canisters that explode when thrown.

Health pickups include glowfruit, canteen, protein tin, field bandage, and medkit. The HUD uses a classic arcade health bar and special meter.

### Dinosaur Behavior

Not all dinosaurs are enemies. Some are frightened, some are territorial, and some attack both heroes and Iron Veil. Kian can calm small creatures. Some stages reward players for avoiding harm to neutral dinosaurs or protecting nestlings.

## Art Direction

The visual target is original hand-drawn pixel art or high-resolution 2D painted sprites with pixel-art influence. The game should evoke 1990s arcade energy through animation density, parallax, dramatic color, and readable silhouettes while remaining fully original.

- Internal canvas: 384 x 216
- Window target: 1280 x 720, scalable to 1920 x 1080
- Scaling rule: preserve crisp edges if using pixel art
- Readability rule: sprites must stay readable at combat distance

Color moods include warm ruined highways at sunset, neon green crystal caves, blue jungle nights, red volcanic factories, gold storm skies, and purple luma energy effects.

Backgrounds use layered parallax: sky and ruins in the far layer, trees and machines in the mid layer, grass and broken road pieces near the action, and foreground overlays such as leaves, sparks, rain, ash, or dust.

## Animation Requirements

Every playable hero eventually needs idle, walk, run, three light attacks, heavy attack, jump start, jump loop, jump attack, land, dash, grab, throw, special attack, pickup item, use weapon, hurt light, hurt heavy, knockdown, getup, victory pose, and low-health idle.

Recommended frame ranges: idle 6-10, walk 8, run 8, attacks 5-9, jump 3-6, special 10-16, hurt 3-5, knockdown/getup 8-12.

Heavy hits need anticipation. Impacts use 1-3 frames of hit pause. Screen shake is reserved for heavy attacks and boss hits. Landings and heavy footsteps use dust puffs. Metal impacts use sparks. Crystal-powered attacks use luma glow.

## Stage Roadmap

The full game has eight stages, but the MVP implements Stage 1 and one boss first.

### Stage 1: Sunset Overpass

A cracked elevated highway above jungle ruins at sunset. The heroes drive the Sundrifter toward Ember Rest and find Iron Veil raiders blocking the road while loading captured dinosaurs into armored transport cages.

- Visuals: orange sky, broken signs, vines, distant dinosaur silhouettes, abandoned buses, glowing plants through asphalt cracks
- MVP enemies: Iron Veil grunt, runner, brute
- Later additions: net runner, scrap hurler, frightened raptorling
- Mid-stage event: the road collapses and the fight shifts to a lower service lane while the Sundrifter rolls in the background
- Boss: Brask Noll with wide axe swing, ground shock slam, grunt calls, straight-line charge, and wall-stun condition
- Ending: Brask escapes by helicopter platform. The heroes rescue a young dinosaur tagged with an Iron Veil beacon pointing toward the jungle lab

### Later Stages

- Stage 2, Glassleaf Jungle: a luminous rainforest research district with the Glassback as a controlled creature boss.
- Stage 3, Ember Rest Market: a survivor town infiltrated by Iron Veil, ending with Sable Rin.
- Stage 4, Mineral Rail: a moving cargo train over crystal canyons, ending with the Rail Maw.
- Stage 5, Ashforge Town: a volcanic factory settlement tied to Tor's past, ending with Vorrak.
- Stage 6, Storm Plain Chase: a Sundrifter vehicle/combat hybrid against Dr. Klade's mobile lab.
- Stage 7, The Underroot: a quiet-versus-loud underground ecosystem ending with the Echo Queen.
- Stage 8, Deep Crown Citadel: Iron Veil's final drilling fortress, ending with Mara Voss and the Deep Crown core.

## Enemy Types

Human enemies include grunt, runner, shield guard, brute, hurler, handler, drone tech, and elite.

Creature enemies include raptorling, hornbeak, ashscale, cliff glider, crystal leech, and echo raptor.

Neutral creatures include long-neck herd, glowtail, mossback, and nestlings.

## Boss Design Rules

Each boss must have a readable entrance animation, 3-5 core moves, a clear weakness or stun condition, a phase change at 50% health, a strong sound cue before dangerous attacks, a unique arena hazard, a short defeat animation, and a story consequence after defeat.

Boss behavior should be learnable, not random. Every boss should teach the player something about the world, villains, or coexistence theme.

## UI and HUD

- Top-left: player portrait, name, health bar, special meter
- Top-center: stage name during opening
- Top-right: score and luma shards
- Boss health: bottom or top-center with boss name
- Title screen: Rift Road logo with animated highway/jungle background
- Character select: four heroes with stats and short personality line
- Pause menu: resume, controls, restart stage, quit
- Game over: hero silhouettes and "the road can still be won"

The UI style should feel like an industrial expedition interface with warm colors and luma glow. Do not copy any existing arcade UI layout.

## Music and Sound Direction

The soundtrack must be original: energetic synth-rock, tribal percussion, funky bass, dramatic boss themes, and atmospheric crystal cave ambience.

Sound effects should use chunky punch impacts, bass thuds for heavy hits, soft crystalline luma shimmers, original layered dinosaur calls, and clean mechanical UI clicks.

## Cutscene Tone

Cutscenes use short comic-panel sequences between stages. Dialogue stays brief and playable.

Opening narration:

> after the red aurora, the old world cracked open. from beneath the cities came forests of light, rivers under stone, and beasts history had forgotten. some people called it a miracle. others called it a mine.

Stage 1 opening:

> raya: "roadblock ahead."
>
> nika: "i vote we go through it."
>
> kian: "those cages are moving. they have animals inside."
>
> tor: "iron veil. this is worse than a roadblock."

Final scene:

The Sundrifter drives across a dawn-lit road while dinosaurs move peacefully in the distance.

> raya says the engine sounds terrible.
>
> kian says the world is healing.
>
> nika says healing can go faster.
>
> tor smiles and says, "road's open."

## MVP Scope

Build a playable macOS prototype first. Do not build all eight stages immediately.

- Engine: Godot 4.x preferred
- Platform: macOS desktop app
- Resolution: 1280 x 720 windowed, scalable
- Art: original placeholder sprites, rough pixel art, or simple colored shapes
- Stage: Stage 1 only
- Playable heroes: Raya and Nika
- Enemy types: grunt, runner, brute
- Boss: Brask Noll
- Systems: health bars, special meter, pickups, pause menu, game over, keyboard controls, parallax background, hitboxes, hurtboxes, knockback, damage invulnerability, hit pause, debug overlay

### MVP Success Criteria

- Player can choose Raya or Nika.
- Player can move on a belt-scroll plane.
- Player can attack, jump, dash, use special, take damage, and defeat enemies.
- Enemies spawn in waves and attack the player.
- Brask Noll spawns at the end of Stage 1 and can be defeated.
- Stage ends with a short text cutscene.
- Game runs smoothly on macOS.
- All assets are original placeholders or newly created.

## Implementation Architecture

Use a clean Godot scene/component structure:

- `PlayerController`
- `CharacterStats`
- `CombatBox`, `Hitbox`, and `Hurtbox`
- `DamageEvent`
- `EnemyAI`
- `WaveSpawner`
- `StageManager`
- `PickupManager`
- `BossController`
- `CameraController`
- `HUDController`
- `AudioManager`
- `SaveSettings`

Character, enemy, and stage data should be data-driven through JSON, TOML, or Godot resources. Player and enemy behavior should use simple state machines.

Physics should not become platformer-first. Jumps use fake verticality for attacks while the player remains on the belt-scroll floor. Z-order sorting should follow Y-position so lower characters render in front.

The camera follows the player with smoothing, locks during combat arenas, and uses subtle shake only for heavy impacts and boss slams.

## Development Order

1. Create the project and 1280 x 720 window.
2. Add player movement on the belt-scroll plane.
3. Add one placeholder player with idle, walk, and attack states.
4. Add hitbox and hurtbox combat.
5. Add one enemy type.
6. Add health and damage.
7. Add wave spawning.
8. Add camera lock per arena.
9. Add pickups.
10. Add the second hero.
11. Add Brask Noll.
12. Add the Stage 1 background and parallax.
13. Add title screen and character select.
14. Add placeholder sound.
15. Add final Stage 1 cutscene.
16. Package the macOS build.

## Originality Checklist

Before any release, confirm:

- no existing game title, character name, company name, or brand is used
- no copied sprites, animations, backgrounds, music, sound effects, fonts, logos, or UI layouts are included
- no ROMs, emulators, ripped assets, or traced art are included
- vehicles are original and not based on recognizable real-world branded cars
- dinosaurs are broad original paleontology-inspired designs, not copied from a specific film, game, comic, or toy line
- story, dialogue, bosses, stages, and level layouts are original
- every third-party asset has clear commercial-use license evidence in the provenance register
