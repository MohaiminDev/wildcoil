# Rift Road: Beasts of the Afterglow — Living Game Spec

Version: 2026-05-11
Status: replacement working draft
Primary target: personal-first commercial-quality game, built first as a polished macOS Stage 1 slice
Engine target: Godot 4.6.x stable
Primary hardware target: M1 iMac, 16GB RAM

## 0. Creative Lock

`Rift Road: Beasts of the Afterglow` is a modern cinematic 2D arcade brawler about animated road heroes crossing a glowing prehistoric future to stop an extraction empire from draining the living crystal network beneath the world.

The game is not a tiny retro clone, not a full 3D action game, and not a live-service project. It is a modern side-scrolling beat-'em-up with large expressive 2D characters, smooth readable motion, strong hit impact, cinematic stage moments, rich parallax backgrounds, and short story beats that make the world feel alive.

The first success condition is not market demand. The first success condition is: the game feels good, looks alive, and is satisfying to play on an M1 iMac.

### Locked Direction

- Genre: story-driven 2D arcade beat-'em-up / belt-scroll brawler.
- Core fantasy: drive into dangerous glowing wildlands, fight extraction crews and mutated beasts, rescue living ecosystems, and open the road forward.
- Visual target: HD 2D animated sprites with arcade/pixel-art influence, layered 2.5D-feeling backgrounds, crisp silhouettes, and disciplined effects.
- Combat target: fast, physical, readable, responsive, and animated; every hit should visibly change the crowd state.
- Story target: short cinematic moments, character banter, environmental storytelling, and boss scenes; no long lore dumps during play.
- Technology target: Godot 4.6.x stable, 2D-first, macOS-first, controller-ready, 60 FPS target.
- Prototype target: one polished Stage 1 slice. RR-PROD-109 temporarily narrows the playable source-run focus to Kian Vale and one strong Iron Veil grunt loop before broad roster or enemy-variety expansion.

### Working-Name Warning

All titles, character names, faction names, and place names are working production names until commercial clearance is done. Before public release, perform a proper trademark, store, and web search. Do not assume any name is safe just because it appears original in the current documents.

## 1. Product Thesis

Build the smallest version of the full dream that proves the game is worth expanding.

The first slice should feel like a complete animated arcade episode:

1. The Sundrifter enters a broken highway at sunset.
2. Kian leads the local demo response when the crew discovers Iron Veil loading frightened creatures into cages.
3. The player fights through a readable, escalating brawler stage.
4. The road collapses into a lower service lane.
5. Brask Noll arrives as a brutal field captain boss.
6. The heroes rescue a tagged young creature and discover the route to Iron Veil's jungle lab.

The slice must make the player think: "I want the next stage."

## 2. Player Experience Goals

### Primary Feeling

The player should feel like they are controlling animated heroes inside a dangerous road-adventure cartoon with real combat weight.

### Desired Moment-to-Moment Feel

- Movement is responsive within the first five seconds.
- First combat starts within 30 seconds.
- Hits feel sharp and physical.
- Enemies visibly react to every meaningful strike.
- Enemy attacks are readable before they become dangerous.
- Story appears through short scenes, barks, visual staging, and boss entrances.
- The screen feels rich but not noisy.
- The player can always understand why they got hit.

### Emotional Texture

- Colorful, not childish.
- Adventurous, not grim.
- Dangerous, not cruel.
- Mythic and strange, not generic sci-fi.
- Characterful, not dialogue-heavy.

### Audience for Now

The first audience is the developer-player. Build for personal joy first:

- satisfying solo play
- good animation and motion
- strong story atmosphere
- visually memorable scenes
- replayable combat encounters
- smooth performance on M1 iMac

Market-facing decisions come later, after the Stage 1 slice is fun.

## 3. Design Pillars

| Pillar | Meaning | Practical Rule | Failure Signal |
| --- | --- | --- | --- |
| Immediate impact | Combat must feel good immediately | Prioritize input response, hitstop, hit reactions, and sound before content breadth | Player says hits feel soft, floaty, or delayed |
| Expressive motion | Characters must feel alive in idle, movement, attack, hurt, and victory | Use large sprites, strong poses, cloth/gear motion, and clear anticipation | Characters feel like sliding puppets |
| Readable chaos | Fights can be busy, but never confusing | Limit enemy overlap, telegraph danger, keep VFX short and directional | Player calls damage cheap |
| Cinematic stage flow | Every stage needs story motion and visual escalation | Add short scenes, camera locks, set pieces, and boss entrances | Stage feels like disconnected arenas |
| Strange ecology | The world must feel original and alive | Creatures, crystals, roads, machines, and settlements must obey shared world logic | Game reads as a dinosaur-brawler clone |
| Ruthless scope | Build only what proves the loop first | Polish Stage 1 before adding more stages | Content expands while the core still feels weak |

## 4. Reference DNA

Use classic arcade brawlers only as structural ancestry: side-scrolling movement, big readable sprites, waves, pickups, boss punctuation, and immediate action.

Do not copy old arcade art, UI, vehicle fantasy, dinosaur staging, character archetypes, enemy layouts, music, sprites, animations, names, boss silhouettes, or stage layouts.

Modernize the formula through:

- smoother animation transitions
- better enemy telegraphs
- clearer hit/hurtbox tuning
- short cinematic scenes
- stronger environmental storytelling
- score and replay goals without grind
- accessibility and input remapping
- performance profiling from the beginning

## 5. Visual Direction

### Final Visual Target

Modern HD 2D animated arcade style:

- large 2D characters
- crisp silhouettes
- expressive rigs and hand-polished key poses
- arcade color discipline
- layered parallax environments
- controlled glow, dust, sparks, and weather
- readable lane-based combat
- no full free-camera 3D
- no tiny low-resolution sprites as final target

### What "HD 2D with Pixel-Art Influence" Means

This does not mean pure 16-bit pixel art. It means:

- the camera and gameplay structure feel like a classic arcade brawler
- character shapes are bold and readable
- animations use strong key poses and snappy timing
- textures can have crisp painted or pixel-influenced edges
- scenes are richer and smoother than old arcade hardware allowed

### Rendering Approach

- Gameplay actors: 2D sprites, cutout rigs, or sprite-part rigs.
- Important impact poses: custom hand-drawn/sprite-swapped frames where needed.
- Backgrounds: 2D layered parallax with 2.5D depth impression.
- Effects: short-lived 2D VFX with clear direction and color meaning.
- Camera: locked side/belt-scroll camera with subtle cinematic framing.

### Production Art Rule

Every final asset must be original. Temporary placeholder assets must be labeled as placeholders. AI-generated concept art may be used only as internal ideation unless license and originality are cleanly documented. Do not ship traced, copied, or style-mimicked assets.

## 6. Animation and Motion Standard

Animation quality is a core feature, not polish.

### Required Motion Qualities

- Idle animations show personality.
- Walk/run cycles show weight and speed.
- Attack startup frames show intent.
- Active frames feel decisive.
- Recovery frames show vulnerability but do not feel sluggish.
- Hurt animations clearly show damage direction.
- Heavy hits need anticipation, impact, and aftermath.
- Cloth, scarf, cape, tools, and small gear should add life without hurting readability.

### Recommended Gameplay Animation Lengths

These are starting points, not final tuning:

| Action | Target Length | Notes |
| --- | --- | --- |
| Idle loop | 0.8-1.4 sec | subtle personality, no noisy motion |
| Walk loop | 0.45-0.65 sec | readable footfalls |
| Run loop | 0.35-0.50 sec | stronger forward energy |
| Dash | 0.18-0.28 sec | fast but controllable |
| Light attack 1 | 0.18-0.25 sec | quick confirmation |
| Light attack 2 | 0.20-0.28 sec | slight escalation |
| Light attack 3 | 0.26-0.36 sec | finisher feel |
| Heavy attack | 0.38-0.55 sec | anticipation required |
| Jump attack | 0.28-0.45 sec | fake verticality, clear landing |
| Special | 0.60-0.95 sec | spectacle with lockout risk |
| Hurt light | 0.22-0.35 sec | fast recovery |
| Knockdown/getup | 0.80-1.20 sec | readable invulnerability window |
| Victory pose | 1.0-2.0 sec | character expression |

### Animation Pipeline

Use a hybrid approach:

1. Early prototype: simple placeholder sprites or shape rigs.
2. First serious slice: large layered 2D character rigs using Godot animation tools.
3. Combat polish: custom impact frames, smears, contact flashes, and enemy reaction poses.
4. Final production: cleaned rigs, atlas organization, and consistent animation naming.

Do not rely only on skeletal interpolation. Pure cutout animation can feel puppet-like. The game needs authored combat poses and impact frames.

## 7. Technology Direction

### Engine

Use Godot 4.6.x stable for production. Do not base the production branch on beta engine releases unless a specific bug or feature makes it necessary and the risk is documented.

### Why Godot Fits

- Strong 2D workflow.
- Open-source-friendly posture.
- Good macOS export path for a controlled desktop game.
- Efficient iteration for solo development.
- Built-in animation, input, resource, UI, and profiling systems.
- Practical for a 2D-first brawler targeting an M1 iMac.

### Technical Non-Goals

Do not build these during Stage 1:

- online multiplayer
- procedural stage generation
- large unlock trees
- RPG inventory systems
- full 3D camera control
- complex physics destruction
- excessive particles or dynamic lights
- four-player co-op implementation
- eight stages before the combat loop is proven

## 8. Platform and Performance Targets

### Primary Target Machine

- Machine: M1 iMac
- RAM: 16GB
- OS: current supported macOS version on that hardware
- Target display: 1280x720 gameplay window, scalable to 1920x1080
- Target framerate: stable 60 FPS

### Performance Budgets for Stage 1

| Area | Budget |
| --- | --- |
| Active enemies | 4-6 normal enemies during early slice; 8 max after profiling |
| Boss + adds | boss + 2-3 grunts max unless profiling proves more is safe |
| Parallax layers | 5-7 meaningful layers |
| Long-lived particles | minimal; ambient only |
| Combat VFX duration | usually under 0.35 sec |
| Heavy screen shake | rare, under 0.20 sec |
| Dynamic lighting | limited and tested early |
| Texture handling | use atlases where practical; avoid many oversized transparent images |

### Required Debug Overlay

The prototype must include a toggleable debug overlay showing:

- FPS
- frame time if available
- enemy count
- active hitbox count
- active particle/effect count if tracked
- player state
- current arena/wave
- controller/keyboard input status

## 9. Core Gameplay Loop

1. Player enters a stage segment.
2. Camera frames the playable lane.
3. Short story/staging beat sets context.
4. Enemies enter from readable positions.
5. Player uses movement, attacks, dodge, jump, and special to control the crowd.
6. Pickups and hazards add small tactical decisions.
7. Stage advances after the wave or objective clears.
8. Mid-stage set piece changes the scene.
9. Boss arrives with a readable intro.
10. Stage ends with a short consequence scene and route unlock.

### First 30 Seconds Target

The first playable stage must reach combat quickly:

- 0-8 sec: Sundrifter drive-in or stage title card.
- 8-18 sec: brief dialogue/staging.
- 18-30 sec: player gains control and first enemy engages.

No long intro before the player touches the game.

## 10. Controls

Default keyboard mapping:

- Move: WASD or arrow keys
- Attack: J
- Jump: K
- Special: L
- Interact / grab: U
- Dash / dodge: I
- Pause: Esc

Controller mapping target:

- Move: left stick / D-pad
- Attack: face button 1
- Jump: face button 2
- Special: face button 3
- Dash / dodge: face button 4 or shoulder
- Interact / grab: shoulder
- Pause: menu button

All controls must be routed through Godot InputMap actions. Do not hard-code keys inside gameplay scripts.

## 11. Movement System

### Belt-Scroll Plane

The player moves on a 2D floor plane:

- X axis: left/right stage progression.
- Y axis: near/far lane movement.
- Visual Z: fake jump height only.

Jumping does not turn the game into a platformer. The player remains logically grounded on the belt-scroll plane while the visual body lifts for attacks and avoidance.

### Movement Requirements

- Movement starts immediately after input.
- Direction change feels snappy but not weightless.
- Dash has clear start, travel, and recovery.
- Player should not slide after releasing movement unless intentionally designed.
- Z-order sorting follows Y-position so lower-screen characters render in front.

## 12. Combat System

### Combat Philosophy

Combat should be easy to understand, hard to perfect.

The player should not need a deep combo manual to enjoy the game. Depth should come from spacing, timing, enemy priority, dodge discipline, crowd control, and character differences.

### Required Player Actions for Stage 1

Each first-slice hero needs:

- idle
- walk/run
- dash/dodge
- jump
- light attack chain
- heavy or finisher attack
- jump attack
- special attack
- hurt
- knockdown/getup
- pickup/use simple item
- victory pose

Grab/throw is desirable for the full game but may wait until core combat feels strong.

### Attack Timing Model

Every attack has:

- startup frames
- active frames
- recovery frames
- cancel rules
- hitbox definition
- damage value
- knockback value
- hitstop value
- meter effect
- sound cue
- VFX cue

Hitboxes only deal damage during active frames. Animation state must not be breakable through button mashing.

### Hit Feedback Targets

| Hit Type | Hitstop | Reaction | Notes |
| --- | --- | --- | --- |
| Light hit | 2-3 frames | small flinch | should feel crisp |
| Combo finisher | 4-5 frames | knockback or stagger | should move crowd state |
| Heavy hit | 5-7 frames | strong knockback or launch | needs impact sound |
| Special hit | 6-8 frames | crowd-control effect | must not blind the screen |
| Boss heavy impact | 6-10 frames | camera shake + sound cue | use sparingly |

### Damage and Invulnerability

- Player receives brief invulnerability after damage.
- Knockdown includes getup invulnerability.
- Boss and elite enemies should not stunlock the player unfairly.
- Multi-hit effects must have clear hit intervals.

### Dodge

Dash/dodge is a fairness tool, not just movement flair.

Required properties:

- short startup
- short invulnerability or avoidance window
- clear recovery
- cannot be spammed without consequence
- readable animation and sound

### Special Meter

Special attacks use meter. Meter comes from fighting well, not waiting passively.

Possible meter gain sources:

- landing attacks
- avoiding damage
- defeating enemies
- rescuing creatures or breaking cages
- stage pickups

Specials should help organize chaos. They should not erase all challenge.

## 13. Character System

### Prototype / First Slice Characters

The first serious local source-run combat reference slice now starts with Kian because RR-PROD-109 prioritizes one heavy road-tool brawler loop before roster breadth:

- Kian: grounded, male, heavy reinforced-wrench brawler with practical road-tool pressure.
- Tor, Raya, and Nika: visible roster previews until Kian's reference loop feels strong enough to copy.

Do not expand enemy variants or equalize the whole roster until Kian versus the reference Iron Veil grunt feels convincing.

### Raya Flint

Role: balanced mechanic striker.

Feel target: reliable, physical, practical, warm, and strong.

Strengths:

- easiest onboarding
- strong basic combo
- good stagger and knockback
- safer recovery than Nika
- useful for learning the game

Weaknesses:

- less mobility
- fewer aerial options
- lower burst speed

Initial move kit:

- Spanner Jab: quick first hit.
- Bolt-Crank Swing: second hit with wider arc.
- Gearbreaker Kick: third-hit finisher with knockback.
- Overdrive Slam: special meter attack that creates a short shockwave.
- Field Patch: future support move; not required in first slice unless healing is well balanced.

Motion notes:

- wrench shifts in idle
- jacket/scarf has secondary motion
- grounded footwork
- heavy attacks show body torque
- recovery is guarded and practical

### Nika Sol

Role: agile disruptor.

Feel target: fast, stylish, risky, kinetic, and expressive.

Strengths:

- highest movement speed
- strong dash repositioning
- good jump attack
- fast recovery
- good at reaching runners/hurlers

Weaknesses:

- lower health
- weaker raw knockback
- easier to overextend

Initial move kit:

- Flash Step: fast dash with short avoidance timing.
- Heel Arc: quick light chain with sweeping third hit.
- Skyline Drop: jump attack that hits downward and forward.
- Static Burst: special meter attack that briefly stuns or pushes nearby enemies.

Motion notes:

- runner's bounce in idle
- cape/streamer cloth shows speed
- attacks use fast readable silhouettes
- electric-violet effects are short and sharp
- hurt recovery rolls back quickly

### Planned Full Roster

- Kian Vale: wildlife biologist / field medic; technical control and creature calming.
- Tor Bram: ex-Iron Veil guard; heavy throws, defense, and guilt-driven story arc.

Full roster rule: every hero must change movement rhythm, crowd-control options, and failure profile. Do not create skins with different numbers.

## 14. Enemy System

### Enemy Design Rules

Every enemy needs:

- readable silhouette
- clear movement speed
- clear attack range
- attack startup cue
- one primary threat
- one readable weakness
- hurt and knockdown states
- behavior that supports crowd composition

Do not add enemies by reskinning the same behavior too often.

### Stage 1 Enemy Types

#### Iron Veil Grunt

Purpose: basic pressure and combo target.

- Walks toward player.
- Uses simple melee attack.
- Teaches spacing and hit reactions.
- Low health.
- Clear flinch.

#### Iron Veil Runner

Purpose: movement pressure.

- Circles or dashes in from lane angles.
- Low health, higher speed.
- Forces player to reposition.
- Can interrupt careless offense.
- Must have readable wind-up before lunging.

#### Iron Veil Brute

Purpose: heavy telegraph training.

- Slow movement.
- Higher health.
- Big wind-up swing or shove.
- Can be punished after missing.
- Should never attack instantly from offscreen.

### Later Enemy Families

- Handlers: control creature behavior or cages.
- Hurlers: throw rocks, tools, or luma charges.
- Shield guards: teach side/back positioning.
- Drone techs: deploy small machines.
- Creature threats: territorial, scared, or mutated; not automatically evil.
- Elite crews: combine human tactics with luma equipment.

## 15. Boss Design

### Boss Philosophy

Bosses are combat lessons plus story moments.

Each boss needs:

- entrance animation
- short dialogue/staging
- 3-5 readable moves
- distinct sound cues
- stun/weakness condition
- phase change around 50% health
- arena hazard or context mechanic
- defeat animation
- story consequence

### Stage 1 Boss: Brask Noll

Role: Iron Veil field captain.

Weapon: hydraulic axe.

Personality: loud, impatient, brutal, and convinced that control is strength.

Core moves:

1. Wide Axe Swing
   - horizontal range
   - obvious shoulder wind-up
   - punishable recovery

2. Ground Shock Slam
   - vertical axe plant
   - lane shockwave
   - jump/dodge lesson

3. Straight-Line Charge
   - warning snort/engine hiss
   - charges across one lane
   - can crash into a wall/cage barrier and become stunned

4. Grunt Call
   - summons limited backup
   - never floods the arena beyond readability

5. Phase Rage
   - at 50% health, breaks part of the arena and gains faster recovery

Stun rule:

- If Brask charges into a reinforced barrier, cage frame, or road wreck, he enters a short stun state.
- The stun teaches arena awareness without becoming a gimmick.

Defeat consequence:

- Brask does not die in Stage 1.
- He escapes on an Iron Veil lift platform or transport hook.
- He leaves behind a tagged young creature and a route beacon pointing to the jungle lab.

## 16. Creature and Coexistence System

Not all creatures are enemies.

Creature categories:

- Neutral: scared, territorial, or passing through.
- Threatened: trapped by Iron Veil and may panic.
- Hostile: mutated or actively attacking.
- Ally-adjacent: can disrupt Iron Veil if protected or freed.

Stage 1 should include only a simple version:

- caged creature movement in background
- optional cage interaction or environmental rescue
- no complex creature AI until combat is stable

Future coexistence mechanics:

- Kian can calm small creatures.
- Some stages reward avoiding harm to neutral creatures.
- Iron Veil handlers can provoke animals.
- Protecting nests or herds can change score/rank or stage events.

This system must never slow the game into a simulation. It should add emotional stakes and tactical variety.

## 17. Pickups and Weapons

### Prototype Pickups

Use simple, readable pickups first:

- glowfruit: small health
- medkit: large health
- luma shard: score/meter
- scrap wrench or pipe: temporary weapon
- road flare: throwable stun/ignite effect

### Pickup Rules

- Pickups must be visually distinct at combat distance.
- No inventory screen.
- Temporary weapons should be fast to understand.
- Explosive items must have clear danger telegraphs.
- Pickups should not clutter the arena.

## 18. Stage 1: Sunset Overpass

### Stage Identity

A cracked elevated highway above jungle ruins at sunset. Iron Veil has blocked the road, caged young afterglow beasts, and started extracting luma from exposed crystal veins beneath the asphalt.

### Visual Elements

- orange and gold sky
- broken overpass rails
- vine-wrapped concrete
- distant ruined city silhouettes
- glowing plants through road cracks
- luma crystal veins beneath asphalt
- Iron Veil cage transports
- Sundrifter in the background
- distant creature silhouettes moving through the jungle

### Stage Length

- First clear: 12-15 minutes.
- Skilled replay: 8-10 minutes.
- Prototype blockout: 6-8 minutes acceptable if the core feels good.

### Encounter Flow

#### Beat 0: Opening Drive-In

- Sundrifter rolls onto the overpass.
- The camera shows Iron Veil cages.
- Short dialogue establishes urgency.
- Player gains control quickly.

#### Beat 1: First Roadblock

- 2-3 grunts.
- Teaches basic attack and movement.
- No advanced threat stacking.

#### Beat 2: Cage Loading Zone

- Grunts + runner.
- Player sees creatures in cages.
- First pickup appears.
- Optional cage interaction can be introduced later.

#### Beat 3: Road Collapse Set Piece

- Iron Veil drill or luma surge destabilizes the overpass.
- Camera shakes briefly.
- Road breaks.
- Fight shifts to lower service lane.
- This is the first wow moment and must happen within the first 3 minutes in the polished slice.

#### Beat 4: Service Lane Escalation

- Runner + brute mix.
- Player learns dodge timing and target priority.
- Background Sundrifter keeps moving or gets blocked.

#### Beat 5: Brask Noll Boss Arena

- Brask enters with axe slam.
- Short dialogue.
- Boss fight teaches reading heavy telegraphs and using arena stun.

#### Beat 6: Ending Scene

- Brask escapes.
- Heroes rescue tagged creature.
- Beacon points to Glassleaf Jungle lab.
- Stage clear screen.

## 19. Stage and Campaign Scope

### Stage 1 Slice

Must exist first. No argument.

### MVP Target

MVP means a complete small game loop, not the full dream:

- 1 current playable demo hero: Kian Vale
- 1 polished stage: Sunset Overpass
- 1 boss: Brask Noll
- title screen
- character select
- pause menu
- game over
- ending scene
- score/rank summary
- macOS package

### Vertical Slice Target

After MVP passes playtesting:

- Stage 1 polished to near-final quality
- 2 heroes with stronger animation
- 4-5 enemy types
- improved boss fight
- cinematic intro/outro
- original music and SFX pass
- settings/remap support
- controller validation

### Full Game Target

Full game remains possible, but only after the slice proves the pipeline.

Recommended full scope:

- 4 heroes
- 5-6 core stages
- 6-8 bosses/major encounters
- replay rank system
- local co-op only if solo readability survives
- optional challenge arenas

Eight stages may remain a story ambition, but production must not depend on building all eight early.

## 20. Later Stage Concepts

These are story/planning targets, not immediate tasks.

| Stage | Name | Core Idea | Main Threat |
| --- | --- | --- | --- |
| 1 | Sunset Overpass | highway blockade and creature cages | Brask Noll |
| 2 | Glassleaf Jungle | luminous research district and creature experiments | Dr. Klade / Glassback |
| 3 | Ember Rest Market | survivor town infiltrated by Iron Veil | Sable Rin |
| 4 | Mineral Rail | moving cargo route over crystal canyons | Rail Maw |
| 5 | Ashforge Town | volcanic factory settlement tied to Tor's past | Vorrak |
| 6 | Storm Plain Chase | Sundrifter chase against mobile lab | Klade's crawler |
| 7 | The Underroot | quiet underground living crystal ecology | Echo Queen |
| 8 | Deep Crown Citadel | final drilling fortress | Mara Voss / Deep Crown core |

If production reality demands a smaller commercial release, compress stages 4-7 into fewer chapters rather than lowering quality everywhere.

## 21. UI and HUD

### HUD Requirements

- Player portrait
- player name
- health bar
- special meter
- score/luma shard count
- boss health bar when active
- minimal prompt system
- optional creature rescue indicator

### Style

Industrial expedition interface with warm road colors and luma glow.

Avoid copying any existing arcade UI layout. Use original shapes, icon language, and motion.

### Readability Rules

- Health must be readable at a glance.
- Boss attacks should not be hidden behind HUD elements.
- Prompts should be short.
- UI animation should be clean and brief.

## 22. Dialogue and Cinematic System

### Narrative Delivery Rule

Use short scenes, not long interruptions.

Allowed formats:

- comic-panel intro/outro
- in-stage dialogue barks
- boss intro dialogue
- short mid-stage reaction lines
- radio-style Sundrifter callouts
- animated title cards

Avoid:

- long cutscenes before gameplay
- exposition paragraphs during action
- lore menus required to understand the stakes
- frequent unskippable dialogue

### Cinematic Implementation

Create a `CinematicDirector` or `DialogueDirector` that can:

- lock player input briefly
- show speaker name and line
- trigger camera pan or shake
- trigger stage event
- release control quickly
- skip text safely

## 23. Audio Direction

### Music Identity

Energetic synth-rock, primal percussion, dirty bass, metallic rhythm, and luma-crystal shimmer.

### Stage 1 Music

- sunset road groove
- percussion-forward but not too busy
- tension rises near the collapse
- heavier boss layer for Brask

### Combat SFX

Every major action needs sound feedback:

- light punch/slash transient
- heavy body impact
- metal wrench contact
- electric/luma tail
- dodge whoosh
- enemy telegraph cue
- boss wind-up cue
- pickup cue
- UI confirm/cancel

Audio is part of combat feel. Do not postpone hit sounds too late.

## 24. Replayability

Replay should come from mastery, not grind.

Stage clear rating can consider:

- clear time
- damage taken
- max combo or style chain
- enemies defeated
- creatures protected/rescued
- pickups used
- boss stun opportunities used

Do not add artificial daily missions, gacha systems, massive unlock trees, or grind-based power gates.

Potential future unlocks:

- challenge ranks
- alternate colors
- animation gallery
- training room
- move refinements
- stage modifiers

## 25. Architecture

### Recommended Project Structure

The repository can keep its existing name, but the game namespace should be clear.

Suggested structure:

```text
src/rift_road/
  project.godot
  scenes/
    boot/
    menus/
    gameplay/
    stages/
    characters/
    enemies/
    bosses/
    pickups/
    ui/
    cinematics/
  scripts/
    core/
    combat/
    actors/
    ai/
    stage/
    ui/
    audio/
    save/
    debug/
  data/
    characters/
    attacks/
    enemies/
    waves/
    stages/
    dialogue/
  art/
    placeholders/
    characters/
    enemies/
    backgrounds/
    vfx/
    ui/
  audio/
    music/
    sfx/
  docs/
```

### Core Components

- `GameBoot`
- `InputRouter`
- `PlayerController`
- `CharacterMotor`
- `CharacterStateMachine`
- `CharacterStats`
- `AttackData`
- `CombatBox`
- `Hitbox`
- `Hurtbox`
- `DamageEvent`
- `CombatResolver`
- `EnemyAI`
- `BossController`
- `WaveSpawner`
- `StageManager`
- `ArenaLock`
- `PickupManager`
- `CameraController`
- `HUDController`
- `DialogueDirector`
- `CinematicDirector`
- `AudioManager`
- `SaveSettings`
- `DebugOverlay`

### Data-Driven Rule

Use Godot resources or structured data for:

- character stats
- attack definitions
- enemy stats
- wave definitions
- pickup definitions
- dialogue lines
- stage event triggers

Do not hard-code tuning numbers in scattered scripts.

## 26. State Machines

Use simple, explicit state machines for players, enemies, and bosses.

Player states:

- idle
- move
- dash
- jump
- attack
- special
- hurt
- knockdown
- getup
- interact
- victory

Enemy states:

- spawn
- idle
- approach
- reposition
- telegraph
- attack
- hurt
- knockdown
- defeated

Boss states:

- intro
- idle/think
- choose attack
- telegraph
- attack
- recover
- stunned
- phase transition
- defeated

Every transition should be intentional and testable.

## 27. Camera

Camera should make combat readable and scenes dramatic without stealing control.

Rules:

- Smooth follow during traversal.
- Lock during combat arenas.
- Keep player and active threats visible.
- Do not over-zoom during dense combat.
- Use subtle shake for heavy hits only.
- Use short camera pans for stage reveals.
- Never hide incoming enemy attacks offscreen without warning.

## 28. Accessibility and Comfort

Required from early development:

- remappable controls later in MVP/vertical slice
- keyboard and controller support
- readable HUD
- colorblind-safe critical information
- reduced screen shake option
- volume controls
- pause and restart stage
- no reliance on tiny text

## 29. Build and Packaging

### macOS First

The build must eventually export as a normal macOS app package. External distribution will require attention to signing and notarization. For early private testing, document every workaround and tester instruction.

### Build Checklist

- runs from exported app
- windowed mode works
- fullscreen mode works
- audio plays after focus loss
- controller hot-plug works
- keyboard fallback works
- pause menu works
- restart stage works
- no missing placeholder assets
- debug overlay toggle works
- FPS remains stable in heavy scene

## 30. Testing and Validation Gates

### Gate 1: Movement Feel

Pass if:

- movement starts quickly
- dash feels controllable
- player can reposition intentionally
- no unwanted sliding

### Gate 2: First-Hit Feel

Pass if:

- attack connects visibly
- hitstop feels satisfying
- enemy reaction is clear
- sound confirms impact

### Gate 3: Enemy Fairness

Pass if:

- players can see attacks coming
- damage feels earned
- no hidden/offscreen cheap hits
- brute and boss attacks have readable wind-up

### Gate 4: Stage Flow

Pass if:

- action starts within 30 seconds
- first wow moment happens within 3 minutes
- stage escalation is clear
- boss arrival feels memorable

### Gate 5: macOS Stability

Pass if:

- exported build runs on target M1 iMac
- 60 FPS target is met in normal play
- controller and keyboard work
- window/fullscreen transitions behave correctly

## 31. Development Order

### Phase 0: Creative and Technical Lock

- Replace spec and story docs.
- Lock art direction.
- Lock Stage 1 scope.
- Lock Godot version.
- Create risk register.
- Create asset provenance register.

### Phase 1: Combat Sandbox

- Godot project setup.
- Movement on belt-scroll plane.
- Placeholder Raya.
- Basic attack state.
- Hitbox/hurtbox/damage event.
- One enemy grunt.
- Hitstop and hurt reactions.
- Debug overlay.

### Phase 2: Stage 1 Blockout

- Sunset Overpass graybox.
- Arena locks.
- Wave spawner.
- Basic parallax.
- HUD.
- First pickup.
- Basic audio placeholders.

### Phase 3: Character and Enemy Contrast

- Add Nika.
- Add runner.
- Add brute.
- Tune Raya/Nika differences.
- Add simple character select.

### Phase 4: Cinematic Slice

- Opening drive-in.
- Mid-stage road collapse.
- Boss intro.
- Ending text/comic panel.

### Phase 5: Brask Boss

- Brask state machine.
- Core attacks.
- Phase change.
- Stun condition.
- Defeat/escape.

### Phase 6: Packaging and Playtest

- macOS export.
- controller tests.
- performance capture.
- 5-8 playtest sessions.
- update docs from evidence.

## 32. Cut Rules

Cut immediately if quality suffers:

- extra stages before Stage 1 works
- Kian/Tor before Raya/Nika work
- online multiplayer
- complex creature AI
- procedural systems
- detailed save progression
- large inventory
- excessive weapons
- cinematic length that delays control
- screen-filling VFX that hide attacks

## 33. Originality and Legal Safety

Before any public release:

- run name/trademark clearance
- confirm no copied characters
- confirm no copied sprites or animations
- confirm no copied vehicles
- confirm no copied dinosaur/franchise designs
- confirm no copied music/SFX/fonts/UI
- confirm no ROM/emulator/ripped assets
- document all third-party licenses
- mark all placeholders clearly
- replace any asset with uncertain provenance

Originality strategy:

- emphasize luma ecology, Afterglow Rift, coexistence, and road survival
- avoid recognizable car-brand fantasy
- avoid direct old-arcade stage structures
- use original creature names and silhouettes
- give Iron Veil specific extraction logic rather than generic villainy

## 34. Current Priority Recommendation

Build the Stage 1 slice with this exact priority order:

1. Raya movement and first-hit feel.
2. Grunt combat loop.
3. Hitstop, knockback, and audio feedback.
4. Sunset Overpass blockout.
5. Wave spawning and arena locks.
6. Nika movement contrast.
7. Runner and brute.
8. Road collapse set piece.
9. Brask boss.
10. Title, character select, HUD, pause, ending scene.
11. macOS export and playtest.

The game becomes great through feel first, then scene craft, then content. Do not reverse that order.

## 35. Final Spec Statement

`Rift Road: Beasts of the Afterglow` should become a modern cinematic 2D arcade brawler: smooth, readable, physical, colorful, story-driven, and original. Its first milestone is not a large game. Its first milestone is a polished Stage 1 episode that feels alive on an M1 iMac and makes the developer want to replay it.
