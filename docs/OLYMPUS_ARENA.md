# Olympus Arena

## Product decision

The current request is a direct Greek-mythology arena battler in the style of Clash Royale. Build the familiar loop: two lanes, defended towers, a regenerating deployment resource, an eight-card deck with a four-card hand, and troops that walk and fight automatically during a short real-time match. The player makes deployment and timing decisions. This replaces the Ninth Gate scenario direction; it is not an adventure, a turn-based Kriegsspiel, or a collection of scripted rescue missions.

Use original Greek-themed 2D sprite artwork, interface, names, code, and audio. No 3D models or procedural miniature fallback. Follow the current 2D-only board-art contract. Clash Royale is the mechanical reference, not a source of copied characters, branding, artwork, sound, or proprietary assets. Olympus Arena is a working title.

## What the player should understand

Protect your temple. Spend elixir to deploy a unit on your half of the arena. Troops cross a bridge and attack automatically. Take down the enemy's main temple to win, or lead on destroyed towers when the timer expires. Watch both lanes, save enough elixir to answer a dangerous push, and deploy a useful counter rather than every affordable card.

A card must show the unit's name and elixir cost before selection. The selected card needs a clear highlight. Deployment feedback must identify invalid terrain or insufficient elixir. Health bars, distinct team colors, attack effects, resource regeneration, and the clock explain the battle without a rules manual. All numbers and legal deployment boundaries come from the authoritative session.

## Scope of the first playable version

- One fixed 3D arena with two bridges and two opposing teams.
- Three defended structures on each side: two lane towers and a central temple.
- An eight-card Greek roster and four-card cycling hand.
- A resource-limited local opponent using the same deployment rules.
- Automatic movement, target selection, attacks, damage, and victory resolution.
- Restart and return to the existing chess table.

Network multiplayer, accounts, matchmaking, collectible upgrades, progression, purchases, a deck-building collection screen, and a full commercial game's balance are outside this first build. Greek heroes and monsters supply the unit identities; no campaign fiction is necessary to explain a match.

## Playing the current build

The main project now opens Olympus Arena. Press **BATTLE** to start; the match clock waits until then. Click a card or press **1–4**, then click the blue half of the arena to deploy. Alternatively, drag a card onto the arena. Thunderbolt can target either half. Troops walk and fight automatically.

Press **Escape** to clear card selection. Press **Space** or click **Pause / Resume** to pause or resume. **Restart** asks before replacing the current match; confirm, then press BATTLE to begin again. The result screen offers **REMATCH**. The chess-table button returns to the existing wooden chess game. The Sound switch controls the synthesized arena audio.

The deck is fixed in this prototype; there is no deck editor. Card descriptions and elixir costs describe the actual implemented units. The models are stylized procedural placeholders with original silhouettes, not finished character art.

## Implemented rules checkpoint

The pure session is implemented. Its standalone suite reports 773 passing checks, including deterministic crowd separation, tactical practice-opponent behavior, Minotaur charge, and Hydra recovery. The exact formulas live in [the rules contract](../games/olympus_arena/RULES.md), which takes precedence over this summary.

| Card | Elixir | Implemented distinction |
| --- | --- | --- |
| Hoplites | 3 | Deploys three ground soldiers |
| Atalanta | 3 | Fast ranged attacker; can hit flying targets |
| Minotaur | 5 | High-health building attacker; earns a doubled first strike after travelling 2.4 arena units |
| Medusa | 4 | Ranged attacks slow enemy movement |
| Heracles | 5 | Club attacks damage nearby ground enemies |
| Hydra | 6 | Very high health; can reach flying enemies and heals after four seconds without damage |
| Harpies | 3 | Two flying attackers that cross the river directly |
| Thunderbolt | 2 | Area spell deployable anywhere inside the arena; deals 130 damage to enemy units and 65 to enemy structures |

Both sides start with five elixir and regenerate one every 2.8 seconds, capped at ten. Regeneration doubles after two minutes. The main match lasts three minutes. Equal crowns at that point trigger up to one minute of sudden-death overtime. At the final limit, surviving structures and then remaining total tower health break the tie; a remaining tie draws. Destroying a side tower earns one crown. Destroying the main temple wins immediately with three crowns.

Troops deploy on their owner's half of the board; destroying an enemy side tower does not currently extend deployment territory. Ground units cross at bridges. Flying units cross directly. Ordinary melee fighters cannot hit air units; the Hydra is an explicit exception. Buildings attack automatically. Ground crowds use deterministic soft separation while respecting banks and bridges; flyers use a separate lighter spacing layer. This is formation readability rather than rigid-body physics. There is no unit upgrade or collection level. Arena save/replay is not implemented. Damage within a fixed step follows deterministic unit order rather than simultaneous resolution.

The simulation advances in fixed 0.1-second steps. `snapshot()` returns a deep copy, including the player hand and next card. `catalog()` exposes costs and descriptions. `preview_deploy(slot, position)` validates without mutation; `deploy(slot, position, expected_revision)` submits a deployment; `new_game(seed)` resets the match. The practice opponent is enabled by `bot_enabled` and obeys the same hand, cost, and placement validation. It defends threatened lanes, reserves elixir for useful front lines, adds ranged support, attacks a weaker opposing lane, and aims Thunderbolt at clusters or a finishable tower. It sees only the current battlefield and its own hand. It is still a deterministic local policy rather than competitive multiplayer.

## Source ownership and architecture

| File | Responsibility |
| --- | --- |
| `games/olympus_arena/session.gd` | Pure `RefCounted` authority: roster, resource, hands, deployments, movement, combat, clocks, result, snapshots |
| `presentation/olympus_arena_board.gd` | 3D arena and original procedural unit presentation; renders copied state and maps pointer positions to arena coordinates |
| `app/olympus_arena.gd` and `.tscn` | Real-time input, HUD, local opponent scheduling, scene lifecycle |
| `docs/OLYMPUS_ARENA.md` | Current product contract and practical continuation guidance |
| `docs/HANDOFF.md` | Cross-project status and delivery boundary |

The presentation never declares a hit, spends elixir, moves an authoritative unit, or awards a crown. It submits deployment requests and shows the resulting session snapshots. Cosmetic effects may interpolate between snapshots but must reconcile immediately with the authority after restart or scene exit.

## Acceptance checklist

1. A new player can identify their temple, the enemy temple, their elixir, and four usable cards without opening a manual.
2. A valid deployment spends exactly the card's cost and cycles that card once; an invalid deployment changes neither resource nor hand.
3. Troops use bridges and resolve movement/combat under one authoritative simulation.
4. Towers visibly take damage, destroyed towers stop attacking, and victory stops further gameplay.
5. Both player and practice opponent obey resource and placement limits.
6. A full match reaches a result; restarting clears troops, clocks, resource, hand state, and effects.
7. Native screenshots show legible team identities, card costs, health, and the result at the supported window sizes.
8. Existing chess rules and interaction checks remain intact.

## Continuation priorities

First play several complete matches and record what was confusing or ineffective. Tune deployment responsiveness, battle speed, unit spacing, hit feedback, and counters before adding more systems. Balance numbers remain hypotheses until matches demonstrate that players have useful choices and both lanes matter.

Improve the original Greek silhouettes in small groups: shields and spears for infantry, a lion skin and club for Heracles, a bow for Atalanta, bull horns for the Minotaur, and several readable heads for the Hydra. Keep unit identity legible from the actual game camera. Character portraits and elaborate lore do not substitute for readable pieces.

The next useful tests target reproducible combat interactions, legal placement at boundaries, the final seconds of a match, simultaneous objective destruction, opponent affordability, and restart isolation. Do not spend the first polish pass building accounts, a shop, or a generic framework for unrelated games.

## Verification checkpoint

The current arena rules suite has **773 passing checks**. The renderer has 35 native checks, with another 90 stage geometry/budget checks; the full application has 45, or 47 when it writes both captures; the combat-effects director has 25; the HUD-effects director has 11; and synthesized audio/music has 48. Coverage includes charge and recovery, card dragging, countdown, legal deployment, invalid-action atomicity, pause/resume, restart/rematch, outcomes, deterministic crowd spacing, tactical bot fixtures, event deduplication, effect caps, audio cleanup, and a complete battle. The full chess and parked Ninth Gate regressions also pass. These are automated acceptance checks, not a claim of competitive balance or extensive novice playtesting.

Native gameplay and result captures are produced and visually inspected. Gameplay is readable with original 3D procedural models; the character models are still a foundation for an authored art pass. Save/replay, network play, progression, deck editing, and finished character meshes remain absent.

Full cabinet regression validation and Windows packaging are separate integration/publication steps. Verify the release notes and build manifest for the actual packaged source and completed checks; the older Ninth Gate release does not contain Olympus Arena.

## Presentation polish checkpoint

The latest pass moves the board toward a finely made Mediterranean diorama: weathered limestone, chamfered masonry, worn mortar and paving, deeper water with irregular ripples, aged metal, muted terracotta, irregular cypress, and restrained filmic lighting. Refined procedural miniatures use smaller heads, tapered limbs, layered linen, folded capes, and differentiated matte/metal surfaces. The [board-art contract](OLYMPUS_BOARD_ART.md) governs future changes at the real game camera. Minotaur charge and Hydra recovery have event effects plus persistent state cues.

The coastal arena now has sculpted foundations, paved lanes, faction mosaics, fluted columns, planted borders, animated water, distant boats, gulls, pennants, embers, and detailed shrine roofs. Seven miniature designs animate limbs, attack follow-through, capes, wings and Hydra necks. Eight original illustrated portraits appear in the hand, inspection panel and next-card preview. Cards lift and follow the pointer when dragged; a translucent miniature previews legal deployment. Unit-specific weapon trails, Medusa gaze, Hydra and giant impacts, harpy feathers, damage numbers, dust, tower debris, low-health smoke, summon rings and branched thunder accompany authoritative events. The camera reacts gently to major destruction. Countdown, match-phase, tower-loss and deployment HUD effects remain capped and state-driven.

The current authored-art reference is the portrait atlas. Procedural figures are a better animated blockout, not the final matching 3D characters. The exact model, texture, rig, animation, provenance, fallback and admission requirements are in [the art production contract](OLYMPUS_ART_PIPELINE.md). Authored character meshes remain the largest visual opportunity. Multiplayer and progression remain outside this pass.

