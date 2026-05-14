# Kian Combat Vertical Slice Handoff

## Purpose

The next coding goal is not broad visual polish. The owner played the local game and found that the fight does not yet feel alive: the player action set feels thin, enemies appear too static, opponents do not pressure or respond convincingly, and the first fight reads as a staged prototype instead of a real arcade brawler.

The next agent should build a small combat reference slice:

**Make Kian Vale, the first-slot male lead, feel good in one real fight against one Iron Veil mining-company grunt.**

Do not ask the owner to re-decide the direction below. Treat these decisions as locked for this next goal.

## Locked Product Decisions

- Lead hero: Kian Vale.
- Roster order: Kian, Tor, Raya, Nika.
- Gender mix: first two heroes male, third and fourth heroes female.
- Immediate playable focus: Kian only for the reference combat loop. Tor can stay visible as the second male roster slot and may remain preview-only until Kian feels good.
- Story lead: Kian replaces Raya as the Stage 1 local-demo lead.
- Kian combat identity: heavy road adventurer using a reinforced wrench or rugged road tool.
- Kian should not feel like a martial artist. Avoid kick-combo, ninja, karate, kung-fu, or acrobatic-fighter language.
- First reference enemy: Iron Veil mining-company grunt with salvaged gear. Use the existing `iron_veil_grunt` data/profile as the base unless a narrow rename is needed.
- Enemy variety is not the next goal. Build one excellent grunt loop first, then later derive variants.
- Visual identity is part of this goal. The lead hero, first enemy, hero-select card, and title/logo treatment should not feel like text-only placeholders.
- Keep the Rift Road identity, repair-versus-extraction theme, Iron Veil antagonist, Sunset Overpass Stage 1, and original content rules.

## Current Repo Starting Point

- Runtime project: `src/wildcoil`.
- Main runtime map: `ARCHITECTURE.md`.
- Current tracker: `to-do.md`.
- Current story bible: `docs/game-story.md`.
- Current living game spec: `docs/game_spec.md`.
- Product spec index: `docs/product-specs/index.md`.
- Current hero data: `src/wildcoil/data/characters.json`.
- Current enemy data: `src/wildcoil/data/enemies.json`.
- Current Stage 1 data: `src/wildcoil/data/stages.json`.
- Main game flow: `src/wildcoil/scripts/app_root.gd`.
- Player behavior: `src/wildcoil/scripts/player_controller.gd`.
- Enemy behavior: `src/wildcoil/scripts/enemy_actor.gd`.
- Stage orchestration: `src/wildcoil/scripts/stage_manager.gd`.
- Wave spawning: `src/wildcoil/scripts/wave_spawner.gd`.
- Headless runtime tests: `src/wildcoil/tools/runtime_test_runner.gd` and `tests/test_runtime_smoke.py`.

Important contradiction to resolve intentionally: current docs and data still describe Raya/Nika as the first playable demo heroes, and Kian as a support/control hero. RR-PROD-109 intentionally changes that direction for the local demo.

## Desired Player Experience

From a fresh source run, the player should see a real game identity first, then choose or default into Kian as the lead. Kian should read visually as a male road adventurer carrying a heavy reinforced wrench/road tool. His motion should feel practical, weighty, and improvised, not martial-arts-based.

The first fight should communicate a simple promise: this is an arcade brawler. The grunt should notice Kian, move toward him, align lanes, hold or adjust distance, telegraph an attack, swing, recover, flinch when hit, get knocked back or staggered, and eventually be defeated. The enemy should not stand in a fixed position waiting to be deleted.

The target is not final art. The target is intentional, demoable, solid placeholder presentation plus a real combat loop.

## Scope

Build this as one focused vertical slice.

1. Roster and story pivot
   - Put Kian first and Tor second in `characters.json`.
   - Make Kian the default/lead local-demo hero.
   - Update hero-select copy and preview state so Kian is the clear playable lead.
   - Update Stage 1 opening story and barks so Kian leads the response to Iron Veil.
   - Preserve the team and world premise, but stop presenting Raya as the Stage 1 local-demo center.

2. Kian combat identity
   - Rework Kian data and move names around a reinforced wrench/road-tool heavy brawler fantasy.
   - Recommended feel:
     - `J`: weighty wrench combo, at least three visible beats.
     - `I`: practical shoulder/check or tool-assisted dash reposition, not a martial dash kick.
     - `K`: small hop or road-step used for positioning or a tool drop, not an acrobatic kick fantasy.
     - `L`: meter special such as a luma-charged wrench slam or road-anchor shock.
   - Add visible timing: windup, active hit, recovery.
   - Add feedback: hit spark, luma flash, screen shake or camera impulse, enemy flinch/knockback, clear damage response.

3. Reference grunt behavior
   - Use `iron_veil_grunt` as the first reference enemy.
   - Implement or tune a clear behavior contract:
     - idle or patrol before engagement
     - aggro when Kian is close or combat starts
     - approach across x and y lanes
     - stop at attack distance instead of overlapping forever
     - back off or sidestep if too close
     - telegraph before attacking
     - damage Kian on a readable hit
     - flinch when hit
     - recover after flinch
     - knockdown or defeat with readable effect
   - If multiple enemies are present, avoid all of them attacking at once. The first reference loop can start with one or two grunts.

4. Solid placeholder presentation
   - Title screen should have a logo/mark treatment that feels like a game title, not only plain text.
   - Hero select should show a visual Kian card: portrait/body silhouette, tool silhouette, palette, role, and status.
   - In-game Kian should have a readable heavy-tool silhouette.
   - The reference grunt should have a readable salvaged-gear/mining-company silhouette.
   - These assets can be procedural Godot drawing, simple original placeholder sprites, or imported original temporary project assets. Do not depend on files outside `src/wildcoil` for runtime.

## Non-Goals

- Do not build all enemy types yet.
- Do not try to make Tor, Raya, and Nika all equally playable in this task.
- Do not build the full campaign.
- Do not change the distribution target, signing, notarization, or second-machine gates.
- Do not claim production-grade visuals or market readiness from automated tests.
- Do not copy a known brawler, gorilla game, dinosaur game, character, UI, move set, logo, or sprite. Use genre lessons only.

## Tests To Add First

Use test-driven development for this change. Add failing tests before implementation.

Recommended focused tests:

- Content test proving roster order is `kian_vale`, `tor_bram`, `raya_flint`, `nika_sol`.
- Content test proving Kian move names and role text are reinforced-wrench/road-tool heavy brawler flavored and do not use martial-arts language.
- Content/runtime test proving Stage 1 opening story names Kian as the lead and no longer uses Raya as the lead line.
- Runtime smoke proving the first/default hero starts Stage 1 as Kian.
- Runtime smoke or unit-style runner proving the reference grunt transitions through approach, telegraph/attack, flinch, recover, and defeated states during a deterministic combat scenario.
- Presentation/content test proving Kian and the grunt have non-text-only visual identity metadata or drawing hooks.

## Validation Before Commit

At minimum, run:

```sh
python3 -m pytest tests -v
python3 scripts/check_agent_docs.py
git diff --check
bash scripts/check_local_playability.sh
bash scripts/smoke_source_run_local_demo.sh
bash scripts/check.sh
```

Then launch and play locally:

```sh
bash scripts/run_game.sh
```

Record a real local playtest note after the run. The combat loop should not be called "good", "fun", "polished", or "done" unless a real launched-game session supports that claim.

## Done Criteria

RR-PROD-109 is done only when all of this is true:

- Kian is first in the roster and is the local-demo lead.
- Stage 1 story and barks support Kian as lead.
- Kian is visually identifiable without reading body text.
- Kian has a heavy reinforced-wrench/road-tool combat feel with multiple readable actions.
- The first Iron Veil grunt behaves like an opponent: approaches, spaces, attacks, reacts, and can be defeated.
- The first fight is playable from `bash scripts/run_game.sh` on the local computer.
- Automated checks pass.
- A real local playtest note records whether the fight now feels more alive, what still feels weak, and what should be fixed next.

## Suggested Next Task After This

After Kian versus the reference grunt feels good, derive enemy variants from that loop in this order:

1. shield/blocking grunt
2. ranged scrap thrower
3. heavy brute
4. fast runner
5. creature or beast encounter

Do not start that expansion until the reference grunt loop is enjoyable enough to copy.
