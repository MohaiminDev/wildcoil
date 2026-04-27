# Rift Road Living Game Spec

Schedule A-aligned working draft. As of 2026-04-27, the active story direction is `Rift Road: Beasts of the Afterglow`; the full story bible lives in [`docs/game-story.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/game-story.md). Earlier Wildcoil planning remains historical context only.

Current implementation path: Godot 4.x macOS prototype for Stage 1, `Sunset Overpass`, with Raya Flint and Nika Sol playable first, grunt/runner/brute enemies, Brask Noll as the boss, original placeholder assets, and validation-first tasks tracked in [`to-do.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/to-do.md).

## 1. Executive Summary

- Active game direction: `Rift Road: Beasts of the Afterglow`, a solo-first 2D arcade beat-'em-up about crossing a glowing prehistoric future to stop Iron Veil Excavation from draining the Afterglow Rift.
- Target audience: players who want modern beat-'em-up immediacy, readable melee combat, and a distinctive pulp-tech wilderness identity without live-service bloat.
- Product thesis: deliver a tight macOS-native first playable where movement, hits, and spectacle sell the game before content breadth does.
- Core design pillars: immediate impact, readable chaos, strange wilderness identity, and ruthless scope discipline.
- macOS priorities: controller reliability, Apple Silicon stability, painless tester packaging, and an engine workflow that does not punish day-to-day iteration.
- Open-source priorities: traceable assets, clean dependency choices, clear docs, and strong separation between original content and temporary placeholders.
- Prototype priorities: first combat within 30 seconds, first wow moment within 3 minutes, one memorable miniboss encounter, and validation evidence for all gate calls.
- Major risks: originality drift, engine/tool friction on macOS, solo-production art cost, and combat readability under enemy stacks.
- Immediate next steps:
  - scaffold the production Godot project under `src/wildcoil`
  - build Stage 1: Sunset Overpass with Raya, Nika, grunt, runner, brute, and Brask Noll
  - package and validate a macOS prototype with original placeholder assets only

## 2. Target Experience

- Player fantasy: become a fast salvage hunter carving through storm-mutated creatures and dormant machine ruins with a crackling melee kit that feels precise, dangerous, and stylish.
- Action rhythm: short traversal beats, fast combat entry, escalating crowd-control decisions, miniboss punctuation, and one visually loud set piece early.
- Tone: pulpy, adventurous, ominous, and slightly mythic rather than grim or comedic.
- Mastery curve: newcomers can survive with clean movement and a simple combo chain; skilled players optimize spacing, launch windows, dodge timing, and crowd-control cooldown use.
- Normal session feel: one runable stage or arena with four encounter beats, a strong midpoint escalation, and a clean replay loop.
- Difficulty feeling: demanding but fair, with readable intent and very little cheap damage.
- Replayability drivers: better route choices, cleaner damage avoidance, faster elite clears, score/rank ambition, and later character experimentation.

## 3. Reference DNA

| Topic | Keep | Modernize | Avoid |
| --- | --- | --- | --- |
| Stage-based action structure | Immediate encounter clarity, memorable lane progression, miniboss punctuation | Better checkpointing, fewer dead stretches, stronger escalation logic | Filler traversal and repeated enemy spam |
| Combat | Crowd control, satisfying melee strings, enemy knockback readability | Cleaner cancels, better recovery tuning, more legible telegraphs, tighter hit feedback | Floaty attacks and long unsafe recovery without tactical value |
| Presentation | Big poses, readable silhouettes, exaggerated spectacle | Stronger VFX discipline, cleaner HUD, layered audio, better camera discipline | Muddy stacks, noisy effects, indistinct silhouettes |
| Co-op energy | Shared screen chaos and complementary kits | Design for later readability and role clarity | Shipping co-op early before solo feel is proven |
| Replay structure | Score chase, stage mastery, route optimization | Better onboarding and stronger first-session readability | Bloated unlock trees and grind loops |

Emotional qualities worth preserving: directness, swagger, forward momentum, and the feeling that every strike changes the crowd state.

## 4. Similar Game Research

| Title | Genre | Platform | Visual style | Solo / multiplayer | Strengths | Weaknesses | Lessons worth borrowing | Lessons to avoid | Modern relevance | macOS relevance | Originality risk if over-referenced |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Streets of Rage 4 | Modern brawler | PC + console | Hand-drawn 2D | Solo + co-op | Crisp hit feedback, readable lanes, strong enemy identity | Stage repetition can creep in if encounter variety dips | Strong first-hit satisfaction and controlled spectacle | Direct street-crime framing or silhouette echoes | Very high | Use mainly as feel and readability reference | High for combat pacing and HUD rhythm |
| TMNT: Shredder's Revenge | Arcade revival brawler | PC + console | Bright pixel art | Solo + co-op | Fast onboarding, joyful co-op, low friction readability | Nostalgia does a lot of identity work | Clean pacing, fast combat start, approachable controls | Licensed-team energy and overt homage structure | High | Useful as onboarding benchmark only | High for tone and party energy |
| Fight'N Rage | Indie brawler | PC + console | Pixel art | Solo + co-op | Mechanical depth, route mastery, replay hooks | Presentation feels niche compared with premium peers | Deep combo logic can exist inside compact scope | Overly dense combo systems too early | Medium-high | Useful as mastery benchmark | Medium for combat systems |
| Dragon's Crown Pro | Side-scrolling action RPG brawler | PlayStation | Painterly fantasy 2D | Solo + co-op | Strong spectacle, class contrast, tactile effects | Visual density can overwhelm clarity | Distinct class identity and premium-feeling impact | Overloaded screen clutter and exaggerated anatomy cues | Medium-high | Limited as macOS benchmark | Medium-high for fantasy excess |
| Hades | Isometric action roguelike | macOS + PC + console | Stylized 3D/2D hybrid | Solo | Immediate readability, strong audio layering, clear telegraphs | Not a lane-based brawler structure | Use of VFX discipline, early hook, and repeated-run desire | Importing its roguelike progression wholesale | Very high | Useful as macOS feel benchmark | Medium for readability and audio rhythms |
| Guacamelee! 2 | Metroidvania action-platformer | PC + console | Bold 2D | Solo + co-op | Strong silhouette language, traversal-combat blend, color clarity | Broader exploration focus than desired | Saturated readability and punchy movement | Turning the prototype into a traversal-heavy platformer | Medium | Useful as silhouette/color benchmark | Low-medium |

## 5. Comparison Matrix

| Category | Best reference | Why it stands out | Wildcoil takeaway | Caution |
| --- | --- | --- | --- | --- |
| Melee feel | Streets of Rage 4 | Hits feel weighty without losing pace | Prioritize hitstop, hit reactions, and enemy displacement | Do not borrow urban-crime framing |
| Movement feel | Guacamelee! 2 | Movement reads quickly and keeps momentum | Keep traversal snappy even outside combat | Avoid platforming bloat |
| Stage flow | TMNT: Shredder's Revenge | First-session pacing is immediate and friendly | Put action in front of the player fast | Do not rely on nostalgia or licensed cast appeal |
| Boss punctuation | Hades | Telegraphs and threat escalation stay readable | Make elite/miniboss attacks legible and learnable | Avoid roguelike structure creep |
| Character variety | Dragon's Crown Pro | Classes sell different fantasies strongly | Eventually ship mechanically distinct characters, not skins | Protect readability under spectacle |
| Replayability | Fight'N Rage | Mastery and routing add depth | Build room for score/rank or damage-clean clears later | Do not overload the prototype with advanced systems |
| Visual identity | Hades | Strong color scripting and readable FX | Use a disciplined palette and silhouette-first blocking | Avoid over-stylizing beyond solo production limits |
| Co-op value | TMNT: Shredder's Revenge | Shared-screen play creates easy-to-read joy | Keep architecture local-co-op-ready | Do not implement co-op before solo feel passes |

## 6. Design Pillars

| Pillar | What it means | Why it matters | Implementation effect | What goes wrong if ignored | Engagement / market value |
| --- | --- | --- | --- | --- | --- |
| Immediate impact | Combat should feel good on the first exchange | First-playable lives or dies on hand-feel | Prioritize input latency, hitstop, reactions, and audio | Prototype feels generic even with good art | Makes clips and first sessions convincing |
| Readable chaos | Crowd fights should look dangerous without becoming messy | Fairness and replay desire depend on readable failure | Limit simultaneous threat overlap, tune silhouettes, restrain VFX | Testers call deaths cheap and stop trusting the game | Supports retention and co-op readiness |
| Strange wilderness identity | The world should feel like its own lane, not borrowed pulp | Originality is a gate, not a polish step | Design fauna, ruins, props, and factions from one shared logic | The game reads as derivative | Improves screenshots, pitch clarity, and wishlisting appeal |
| Ruthless scope discipline | Only build what the first playable must prove | Solo part-time development cannot absorb feature drift | Freeze prototype scope, cut online, defer co-op, keep stage count tiny | Production collapses under ambition | Raises odds of shipping something strong |

## 7. Original Game Concepts

### Concept A: Wildcoil

- Working title: `Wildcoil`
- One-line pitch: A salvage ranger fights through storm-fed jungles wrapped around dead machine-serpents, using an electrified melee kit to keep mutated pack hunters and ruin wardens under control.
- Setting: Subtropical storm basin where ancient coil-machines once regulated weather and now feed strange ecosystems.
- Tone: adventurous, hazardous, mythic-tech pulp.
- Visual direction: copper ruin ribs, wet stone, bioluminescent spores, bright storm arcs, and clean silhouette-led character blocking.
- Music / sound direction: taiko-sized percussion, metal resonance, synth-static swells, and animal-electric impact layers.
- Gameplay identity: spacing and crowd control through lash arcs, launcher timing, and a cooldown pulse that reorganizes enemy space.
- Character style: agile-balanced explorer with a cable gauntlet and hooked blade.
- Enemy style: predatory fauna, machine-grown scavengers, and relay wardens built from maintenance relics.
- Boss style: oversized apex hybrids and awakened infrastructure guardians.
- Progression style: stage mastery, score/rank goals, unlockable move refinements later.
- Solo / co-op recommendation: solo prototype, local-co-op-ready architecture later.
- macOS suitability: strong because the prototype can read well with restrained effects and a controlled camera.
- Commercial appeal: high if the storm-jungle machine-ruin identity is visually coherent.
- Production complexity: medium.
- Major risks: can slide too close to familiar lost-ruin pulp if the silhouette language gets generic.
- Differentiators: bio-electric wilderness, coil-machine ecology, and a less urban, more primal-tech battlefield.
- Originality safeguards: no treasure-hunter stand-ins, no fedora pulp coding, no directly recognizable ruins or vehicle props.

### Concept B: Saltglass Reclaimers

- Working title: `Saltglass Reclaimers`
- One-line pitch: A breaker crew dives into drowned observatory cliffs where salt-crystal predators and tide-driven machines battle for control of the last stable causeways.
- Setting: storm-lashed coast of glassy tidal ruins and flooded relay towers.
- Tone: eerie, windswept, treasure-scrap adventure.
- Visual direction: pale mineral cliffs, teal surf glow, rust-orange salvage lights, and reflective salt formations.
- Music / sound direction: low brass, surf percussion, glass chimes, and resonant metal impacts.
- Gameplay identity: positional control around narrow platforms and tide pulses.
- Character style: heavier, grounded breaker with anchor-chain tools.
- Enemy style: crustacean mutants, cliff scavengers, and waterlogged sentries.
- Boss style: lighthouse-scale tide engines and armored leviathan juveniles.
- Progression style: route mastery and environmental hazard awareness.
- Solo / co-op recommendation: solo-first.
- macOS suitability: good, but water and transparency can raise visual-cost risk.
- Commercial appeal: medium-high.
- Production complexity: medium-high.
- Major risks: water readability and environmental VFX can overwhelm the prototype.
- Differentiators: salt-glass palette and coastal ruin identity.
- Originality safeguards: avoid pirate framing, avoid obvious Atlantis cues, avoid nautical cliches.

### Concept C: Thornwake Courier

- Working title: `Thornwake Courier`
- One-line pitch: A rail-runner courier battles through a living freight line swallowed by thorn forests and broken cargo automatons to keep the only surviving route open.
- Setting: overgrown rail canyons where root systems and abandoned logistics tech have fused together.
- Tone: desperate but kinetic frontier action.
- Visual direction: red freight markers, vine-wrapped steel, pollen fog, and sharp industrial silhouettes.
- Music / sound direction: ticking percussion, tension strings, chain-clack rhythms, and compressed punchy impacts.
- Gameplay identity: strong forward drive, lane pressure, and environmental momentum.
- Character style: balanced duelist with retracting rail-hooks.
- Enemy style: feral cargo workers, seed-spreaders, and route blockers.
- Boss style: runaway locomotion cores and armored route wardens.
- Progression style: stage timer/rank hybrid.
- Solo / co-op recommendation: solo-first, strong local-co-op fantasy later.
- macOS suitability: good.
- Commercial appeal: medium.
- Production complexity: medium.
- Major risks: can drift toward set-piece chase design and stretch scope.
- Differentiators: logistics-machine ecosystem rather than temples or cities.
- Originality safeguards: avoid train-heist tropes and overt western coding.

### Concept D: Emberfen Wardens

- Working title: `Emberfen Wardens`
- One-line pitch: A lone warden pushes through volcanic wetlands where fungal giants feed on heat vents and abandoned refinery shrines keep waking up.
- Setting: sulfur marsh, basalt channels, and buried refining machinery.
- Tone: ominous, heavy, and ritualistic.
- Visual direction: ember reflections in black water, fungal bloom halos, and smoke-cut silhouettes.
- Music / sound direction: low drums, throat-like synth drones, brittle impacts, and wet crackle layers.
- Gameplay identity: heavier tempo, trap awareness, and deliberate crowd-clearing.
- Character style: weighty melee specialist with a furnace mace.
- Enemy style: fungal ambushers, heat-bloated predators, and refinery cult drones.
- Boss style: vent-fed swamp titans and shrine engines.
- Progression style: fewer but more deliberate encounters.
- Solo / co-op recommendation: solo-first.
- macOS suitability: acceptable, but atmosphere-heavy FX may challenge readability.
- Commercial appeal: medium.
- Production complexity: medium-high.
- Major risks: mood may overpower the immediate arcade hook.
- Differentiators: wet-volcanic biomes and ritual-industrial fusion.
- Originality safeguards: avoid soulslike pacing, avoid plague-zombie shorthand.

### Concept E: Skyshard Salvage

- Working title: `Skyshard Salvage`
- One-line pitch: A cliff-runner clears storm bridges between floating shard ruins while scavenger beasts and automated wardens tear the route apart.
- Setting: elevated shard islands and broken lift towers above a permanent storm sea.
- Tone: bright, perilous, and kinetic.
- Visual direction: warm stone, bright cloud breaks, storm blackouts, and long vertical drop silhouettes.
- Music / sound direction: brisk percussion, soaring brass, wind roar, and snapping impact tails.
- Gameplay identity: agile spacing and cliffside spectacle.
- Character style: fastest concept with hook-lance mobility.
- Enemy style: gliding predators, shard crabs, and tower guardians.
- Boss style: lift-heart sentinels and storm collectors.
- Progression style: pace-heavy stage clears.
- Solo / co-op recommendation: solo-first.
- macOS suitability: good.
- Commercial appeal: medium-high.
- Production complexity: high because verticality tempts the game away from a controlled stage brawler.
- Major risks: camera and traversal ambition can displace the core combat loop.
- Differentiators: open-sky spectacle and strong storm framing.
- Originality safeguards: avoid sky-pirate framing and avoid turning the game into a platformer-first project.

### Concept Ranking

| Rank | Concept | Why it ranks here |
| --- | --- | --- |
| 1 | Wildcoil | Best match for the repo identity, the strange-creature plus machine-ruin lane, and a readable first-playable scope |
| 2 | Saltglass Reclaimers | Distinctive and atmospheric, but riskier for water readability and FX discipline |
| 3 | Thornwake Courier | Strong lane clarity and momentum, but easier to overbuild around traversal set pieces |
| 4 | Emberfen Wardens | Mood is strong, but the hook is slower and heavier than the target first session |
| 5 | Skyshard Salvage | Visually attractive, but verticality threatens scope and stage readability |

Recommended winner: `Wildcoil`.

Why it wins now:
- strongest visual and pitch coherence with the repository identity
- easiest path to a compelling first three minutes without overbuilding traversal
- good fit for melee-first crowd control and a spectacle-forward miniboss
- best balance of originality, macOS-friendly readability, and solo production realism

## 8. Character System

- Prototype character count: 1
- MVP character count: 2
- Full release character count: 4
- Character-difference rule: every character must change movement rhythm, crowd-control options, and failure profile, not just damage values.

| Archetype | Movement identity | Combat identity | Strengths | Weaknesses | Complexity | Skill ceiling | Co-op value | Production cost implication |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Balanced striker | Snappy run, clean jump arc, short dodge | Light chain, heavy finisher, launcher, cooldown pulse | Best onboarding, broad matchup coverage | Lower extreme specialization | Low | Medium-high | Baseline anchor | Lowest and ideal for prototype |
| Agile disruptor | Faster dash and air control | Multi-hit strings, fast repositioning, weaker raw damage | Strong routing and rescue play | Fragile and harder to read for new players | Medium | High | High | Moderate |
| Heavy breaker | Shorter dodge, committed steps | Armor breaks, sweeps, crowd knockback | Great crowd control and spectacle | Slower recovery, less forgiving pacing | Medium | Medium | High | Moderate-high |
| Technical trapper | Precise spacing and cancel windows | Setup tools, pulls, and status windows | High depth, great mastery ceiling | More onboarding burden | High | Very high | Medium-high | Highest |

Recommendation:
- Prototype with only the balanced striker.
- Add the agile disruptor for MVP only if the first character proves the loop.
- Delay heavy and technical archetypes until a vertical slice or full release target exists.

## 9. Gameplay Systems

| System | Purpose | Player value | Implementation cost | Production cost | Risk | Essential vs optional | Prototype early? | Readability / engagement effect |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Light attack chain | Core rhythm | Immediate control and expression | Low | Low | Low | Essential | Yes | Defines baseline feel |
| Heavy finisher | Punctuation and crowd break | Strong reward and spacing shift | Low-medium | Low | Low | Essential | Yes | Supports impact and spectacle |
| Launcher or sweep | Vertical or horizontal crowd reset | Creates mastery and combo texture | Medium | Low-medium | Medium | Essential | Yes | Adds wow moments quickly |
| Cooldown crowd-control special | Panic tool and encounter organizer | Helps new players recover space | Medium | Medium | Medium | Essential | Yes | Keeps chaos readable |
| Dodge / evade | Fairness and skill expression | Lets players own failure and recovery | Medium | Low | Medium | Essential | Yes | Core to “no cheap damage” goal |
| Block / parry | Defensive depth | Advanced control | Medium-high | Medium | Medium-high | Optional for prototype | No | Add only if baseline feel is already strong |
| Grabs / throws | Crowd control variety | Classic brawler fantasy | Medium | Medium | Medium | Optional | No | Useful later, not required for first playable |
| Weapon pickups | Variation | Short-term novelty | Medium | Medium | Medium-high | Optional | No | Can clutter readability if rushed |
| Environmental interactions | Stage identity | Creates memorable beats | Medium-high | Medium-high | Medium | Optional | Limited | Use only one safe spectacle moment early |
| Enemy archetypes | Core combat depth | Forces spacing and priority choices | Medium | Medium | Medium | Essential | Yes | The main readability test |
| Elite enemies | Escalation | Threat variety and pacing peak | Medium | Medium | Medium | Essential | Yes | Good miniboss bridge |
| Boss phases | Memorability | Strong climax and learning | Medium-high | High | Medium-high | Optional for first playable beyond miniboss | Limited | Keep simple in Phase 1 |
| Checkpoints | Session fairness | Supports repeat attempts | Low | Low | Low | Essential | Yes | Reduces frustration |
| Score / rank | Replay driver | Encourages mastery | Medium | Low-medium | Low | Optional for first playable | Later | Useful if simple |
| Unlocks | Retention | Gives medium-term goals | Medium-high | Medium | Medium | Optional | Later | Do not bloat prototype |
| Local co-op interactions | Future expansion | Shared-screen synergy | High | Medium-high | High | Deferred | No | Architecture-ready only |

## 10. Stage and Campaign Flow

- Onboarding: start with movement plus one disposable enemy within 20 to 30 seconds.
- Tutorial strategy: embed one mechanic prompt per early encounter; no long text intro.
- First-playable stage length: 8 to 12 minutes on a clean first clear.
- Encounter pacing:
  - Beat 1: movement check and first enemy read
  - Beat 2: mixed archetypes and first crowd-control decision
  - Beat 3: spectacle moment or environmental payoff inside the first three minutes
  - Beat 4: elite/miniboss punctuation
- Environmental variety: one biome slice is enough for Phase 1; use lighting and staging changes instead of adding more locations.
- Checkpoint timing: one mid-stage checkpoint before the elite/miniboss.
- MVP stage count: 3
- Full game stage count: 5 to 7 if the project ever reaches that scale
- Stage identity strategy: each stage should own one ecology idea, one hazard language, and one memorable visual silhouette.
- Sample progression:
  - Stage 1: storm basin edge and first relay ruins
  - Stage 2: deeper coil-growth with denser predator packs
  - Stage 3: buried core approach and large-scale guardian fight
- Scope control rule: add encounter permutations before adding whole new stage systems.

## 11. Success / Failure / Retention

- Success should feel like clean crowd control, intentional spacing, and visible improvement between runs.
- Failure should usually be traceable to missed telegraphs, greedy offense, or poor positioning, not hidden hits.
- Punishment severity: moderate. Use health loss and checkpoint reset, not long stage restarts.
- Accessibility stance: readable HUD, remapping-friendly input plan, restrained shake, and minimal color dependence.
- Casual vs skilled balance: easy to understand, hard to optimize.
- Replay value: cleaner clears, score/rank ambitions, faster elite kills, and eventually character contrast.
- What not to use: grind progression, massive unlock trees, artificial daily hooks, or randomness that obscures fairness.

## 12. Visual Direction

- Recommended target: controlled 2.5D action with a locked side view and stylized 3D or hybrid assets built around large silhouettes, readable materials, and disciplined effects.
- Why this direction:
  - preserves modern lighting and camera staging without demanding free-camera complexity
  - supports premium-feeling screenshots better than flat placeholders once the slice matures
  - keeps the combat lane readable on desktop and couch distances
- Character rendering priority: silhouette first, secondary accent color second, tiny detail last.
- Hit effects: brief, high-contrast, and directional; avoid foggy screen wash.
- HUD / UI style: utilitarian field-tech overlays with storm-gauge accents, large health readability, and low clutter.
- Premium feel vs cost: invest in strong poses, contact flashes, and environment lighting before detailed props.
- macOS performance note: keep transparency, dynamic lights, and long-screen particle effects tightly budgeted.

## 13. Sound and Music Direction

- Soundtrack identity: primal percussion meeting failing-machine resonance.
- Stage music mood: tense, propulsive, and storm-charged.
- Boss / elite treatment: larger low-end hits, warning motifs, and short pre-impact rises.
- Combat SFX: sharp contact transient, short body weight, then electric or metallic tail.
- Weapon sounds: hooked blade slices and cable snaps should sound mechanical, not fantasy-magical.
- UI sounds: crisp, confident, and brief.
- Environmental audio: wind, relay hum, rain, wildlife chatter, and distant structural groans.
- Voice approach: optional and minimal in prototype; rely on barks if anything.
- Audio work that must happen early: hit confirmation, enemy telegraph cues, and UI confirm/cancel sounds because they change feel immediately.

## 14. Solo vs Multiplayer

| Mode | User value | Engineering cost | Balancing cost | Testing cost | macOS implications | Prototype fit | MVP fit | Readability risk | Recommendation |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Solo only | Highest focus and cleanest feel tuning | Low | Low | Low | Lowest | Excellent | Strong | Low | Default for prototype |
| Solo + local co-op | Adds social appeal and memorable chaos | Medium-high | Medium-high | High | Controller validation burden increases | Poor for first playable timing | Good later if readability holds | Medium-high | Architecture-ready only until Phase 1 passes |
| Solo + online co-op | Marketable on paper | Very high | High | Very high | Netcode and support burden rise sharply | Bad | Risky | High | Defer entirely |
| Multiplayer-first | Strong social pitch | Very high | Very high | Very high | Highest | Bad | Bad | Highest | Reject |

Recommendation: ship the first playable as solo-only, keep data structures and input plumbing local-co-op-ready, and refuse online until there is evidence it materially changes demand.

## 15. macOS Considerations

- Treat Apple Silicon as the primary target.
- Defer Intel support unless later evidence shows it matters enough to justify testing cost.
- Validate controller behavior early with at least two controller families plus keyboard fallback.
- Test windowed/fullscreen transitions, focus-loss recovery, audio-device changes, and app resume behavior before inviting testers.
- Prefer technology that exports a normal macOS `.app` cleanly and fits a future signed/notarized distribution path.
- Keep packaging notes in one place and update them during every external build attempt.
- Required Phase 1 acceptance:
  - 60 FPS target at 1080p on target Apple Silicon hardware
  - stable controller hot-plug and input recovery
  - readable UI in both windowed and fullscreen play
  - repeatable tester package steps

## 16. Technology and Engine Recommendation

Rift Road now proceeds with Godot 4.x for the first playable. Earlier multi-engine spike planning remains useful historical context, but it is no longer a blocker for Stage 1 implementation.

- gameplay iteration: 25
- macOS tooling/export: 20
- responsiveness/input workflow: 15
- art-animation workflow: 15
- open-source posture: 15
- performance headroom: 10

Provisional read before spikes:

| Engine | Provisional fit | Why | Risk to watch |
| --- | --- | --- | --- |
| Godot | Strong default | Best open-source posture, likely low packaging overhead, and favorable tie-break candidate | Animation and tooling may still lose if the spike feels slower than expected |
| Unity | Strong challenger | Mature animation/content workflow and broad production familiarity | Proprietary engine posture and packaging friction must not erase its workflow benefits |
| Unreal | Conditional option | Visual upside and tooling depth are real | Iteration, build size, and macOS overhead may be too costly for the target scope |

Recommendation today:
- best engine for prototype: Godot 4.x
- best engine for long-term development: Godot 4.x unless Stage 1 evidence exposes a severe workflow blocker
- best engine for macOS practicality: Godot 4.x, validated through the Stage 1 packaging task
- best engine for future open-source posture: Godot 4.x

Override rule:
- choose Unity only if it clearly wins gameplay iteration or art-animation throughput
- use Unreal only if the desired visual target truly cannot be met elsewhere without unacceptable compromise

## 17. Prototype Plan

- First playable contents:
  - 1 balanced melee character
  - run, jump, dodge, light chain, heavy finisher, launcher or sweep
  - 1 cooldown-based crowd-control special
  - 3 enemy types
  - 1 elite/miniboss
  - 4 encounter beats
  - 1 spectacle moment inside the first 3 minutes
  - placeholder HUD, placeholder audio, and capture footage
- What to test first:
  - movement response
  - first-hit satisfaction
  - dodge clarity
  - enemy telegraph readability
  - crowd-control special usefulness
- What can remain placeholder:
  - final lore text
  - polished effects
  - voice
  - progression layer
  - co-op support
- Success criteria:
  - combat begins within 30 seconds
  - testers understand the loop without explanation
  - most testers want another run
  - build is stable on Apple Silicon
- Failure signals:
  - players describe hits as soft or floaty
  - repeated cheap-damage complaints
  - first three minutes lack a memorable moment
  - export/package friction consumes too much time
- Commit milestones:
  - movement and basic input
  - first attack chain and dodge
  - one enemy archetype
  - full arena / stage blockout
  - elite/miniboss
  - packaging and playtest pass
- Evidence required before moving forward:
  - short capture footage
  - playtest notes
  - performance measurements
  - updated risk register

## 18. MVP Scope

- Characters: 2
- Enemy types: 6 to 8
- Bosses: 2
- Stages: 3
- Must-have systems: polished core melee kit, strong enemy variety, clear onboarding, stable save/progression stub, replay hooks, macOS distribution workflow
- Cuttable systems: extra camera modes, multiple specials per character, advanced metaprogression, environmental destruction breadth
- Postponed systems: online play, branching story, large unlock trees, procedural content
- Open-source preparation needs: provenance hygiene, dependency review, contributor-safe layout, restricted-asset replacement plan
- Enough to test market interest means: one clear hook, one clear visual identity, and a stable external build that makes players ask for more
- Too big means: more than three stages, more than two prototype-quality characters, or any attempt to add online before the loop is proven

## 19. Workflow and Task Management

- Use [`to-do.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/to-do.md) as the single public source of truth.
- Keep tasks small enough for clean review and validation.
- Separate research, implementation, and validation work.
- Require acceptance criteria before major work is marked done.
- Re-open tasks honestly if the evidence says they failed.
- Update tracker and docs in the same pass as the work.

## 20. Testing and Validation Contract

- No major task is done without validation evidence.
- Use automated checks where they make sense and explicit manual checks where they do not.
- For prototype work, the mandatory manual mix includes gameplay feel review, controller tests, UI readability review, performance capture, and packaging checks.
- Record the result of each important validation pass in the tracker and the relevant document.

## 21. Commit / Push / Repo Rules

- Keep commits focused and professional.
- Do not mix spike experiments with production-ready changes unless the repo state remains easy to understand.
- When work is partial or experimental, label it clearly.
- Keep the repo usable whenever practical.
- Do not let documentation drift behind actual decisions.

## 22. Documentation and Open-Source Readiness

- Required living docs during Phase 0 and Phase 1:
  - README
  - game spec
  - engine matrix
  - risk register
  - playtest log
  - asset provenance register
  - macOS build and distribution notes
  - task tracker
- Rules:
  - keep code and assets separable where practical
  - track every third-party dependency and its license
  - mark placeholder assets clearly
  - document anything that could block a future open-source release

## 23. Risks and Research Gaps

| Risk / gap | Why it matters | Best resolution path |
| --- | --- | --- |
| Originality drift | A derivative concept fails the contract and weakens market identity | Concept review plus inspiration risk log |
| Engine fit on macOS | Wrong engine choice can burn weeks | Identical micro-spikes and export tests |
| Combat feel | Core loop can fail even if the content list is correct | Early playtests and frame-by-frame review |
| Art production cost | Strong visuals can exceed solo bandwidth | Scope-aware target art choices and graybox-first prototyping |
| Packaging / notarization path | External testing stalls if macOS distribution is painful | Early export and packaging dry runs |
| Playtest blind spots | Solo development can misread clarity and fairness | 5 to 8 external Phase 1 sessions |

See [`docs/risk_register.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/risk_register.md) for the living version.

## 24. Market Positioning

- Target audience: modern brawler fans, stylish-action players who value readable melee combat, and players drawn to weird ecology plus machine-ruin imagery.
- Trailer / screenshot hook: electrified melee through storm-lit ruins and predator swarms with clean silhouettes.
- Strongest differentiators: wild-environment focus, strange creature roster, primal-tech tone, and disciplined macOS-first delivery.
- Safest strategy: sell a clean solo-first action prototype with visible polish in feel and staging.
- Highest-upside strategy: grow into a co-op-friendly series identity after the first playable proves itself.
- Market expectations to ignore: feature parity with larger live-service or online-first action games.

## 25. Final Recommendation

- Best concept direction: `Rift Road: Beasts of the Afterglow`
- Best engine: Godot 4.x for the Stage 1 macOS prototype
- Best solo / co-op strategy: solo-only first playable, local-co-op-ready architecture, online deferred
- Best visual direction: controlled 2.5D with stylized 3D or hybrid assets and strict silhouette discipline
- Best sound direction: percussion plus failing-machine resonance with sharp, tactile combat layers
- Best prototype scope: Stage 1, Raya and Nika, grunt/runner/brute enemies, Brask Noll, pickups, HUD, pause, debug overlay, and ending cutscene
- Best MVP scope: one polished Stage 1 slice first, then expand only after the prototype passes playtest and packaging gates
- Best workflow approach: validation-first with `to-do.md` as the public control plane
- Best testing discipline: early hands-on macOS tests, explicit gate checklists, and external playtests before promotion
- Biggest risks: engine friction, originality drift, and readability collapse under combat chaos
- Biggest opportunities: a memorable visual lane and a macOS-native prototype that feels better than its content breadth suggests
- Next research steps:
  - run the three engine spikes
  - pressure-test the concept winner against the inspiration log
  - expand similar-game research with market-facing notes
  - draft the Phase 1 combat sandbox backlog in more detail after the engine pick
- Top 5 immediate tasks to add to `to-do.md`:
  - run the Godot micro-spike
  - run the Unity micro-spike
  - run the Unreal micro-spike
  - score engines and lock the path
  - approve the concept direction and Phase 1 backlog
