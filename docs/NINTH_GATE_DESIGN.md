# The Ninth Gate: a modern Kriegsspiel

Design authority, 2026-09-05. The user has now chosen **our original canon** and authorized new rules, a modern 3D presentation, and glamorous adult characters with a playful PG-13 tone. Prioritize an enjoyable, novice-readable board game. “Best Kriegsspiel” is an ambition to test with players, not an established claim. The Ninth Gate remains a working title pending naming review.

## The cabinet's selected scope

The cabinet contains actual board games. Chess already has a tested playable foundation. The selected additions are **Go, Xiangqi (Chinese chess), English draughts/checkers, and The Ninth Gate**. Go appeared twice in the conversation and is one game. English checkers is the provisional interpretation of “checkers”; do not mix international, Russian, or English capture rules. Dice and counters are components, not a mandate to build every kind of game. Additional catalogue candidates are outside this scope.

## Historical choice and design purpose

Use **Reisswitz's structured 1824 Prussian Kriegsspiel tradition** as the starting inspiration: a terrain map, military formations, concealed intentions, and an adjudicator. A digital adjudicator can make outcomes reproducible and understandable. Verdy du Vernois' later free-umpire approach is valuable inspiration for command uncertainty, but making subjective umpire judgment the foundation would undermine a small, independently testable solo game. The [Kriegsspiel bibliography](https://kriegsspielorg.wordpress.com/kriegsspiel-bibliography/) identifies both original systems and their later editions.

This is an original modern board war game, not a faithful implementation of the 1824 manual. The player makes consequential command decisions with incomplete information, commits orders, and watches both armies act. Success should depend on position, reconnaissance, timing, and limited command attention. It should be possible to understand a defeat without seeing the opponent's private information.

Design targets: understand the objective in one minute, learn the opening scenario in five, finish a battle in roughly 15–25 minutes, and make a typical planning round take about a minute. These are playtest targets, not measured properties. Avoid long tables, arbitrary surprise exceptions, repeated confirmation dialogs, and a simulation layer that contributes no decision.

## The battle: Heaven and Hell

The chosen scenario is **the Three Bridges of the Ninth Gate**, an original battle before a celestial fortress. A river of dusk separates wandering souls from sanctuary. Heaven wants to keep the route open; Hell wants the crossings and the allegiance of those travelling them. The bridge contest is implemented. Evacuation, fortress siege, dialogue, and commander powers are narrative or future features until their own rules exist.

**Marshal Aureth, Keeper of the Dawn**, is Heaven's adult champion: radiant, daring, protective, and far less solemn than the title suggests. **Veyra, the Cinder Regent**, is Hell's adult commander: glamorous, theatrical, and delighted by a worthy opponent. They enjoy each other's company far more than either army approves. Their rivalry should produce bold gambits, teasing challenges, and memorable reversals. Use flirtation and confidence, not explicit sexual content, humiliation, or moral lectures. Both retain agency and motives beyond attraction.

Their eventual abilities should express protection versus audacious pressure, with visible costs and counters. Portraits and brief barks can establish personality now; neither implies implemented dialogue trees, romance systems, or commander units. Example Aureth bark: “Try to keep up, Regent.” Veyra: “Darling, I was waiting for you.” Never let flavour interrupt planning or repeat every click.

Use legible role symbols and plain role labels even when formations have evocative individual names: **Warden** (`guard`), **Lancer** (`spear`), **Archer**, and **Herald**. Each army has two Wardens, two Lancers, one Archer, and one Herald. The current version's exact mechanics belong in [RULES.md](../games/ninth_gate/RULES.md); do not preserve the earlier prototype's values in UI copy.

### Why original canon is the best fit for this game

In Milton's *Paradise Lost*, Book VI, Michael and Gabriel lead the loyal host, Abdiel confronts Satan, and Moloch fights among the rebels. The Son decisively ends the war on the third day. It offers spectacular characters, but a balanced branching game would deliberately depart from the poem. [Primary text](https://milton.host.dartmouth.edu/reading_room/pl/book_6/text.shtml)

Revelation 12 describes Michael and his angels fighting the dragon and its angels. Revelation 19 instead describes the rider called Faithful and True and heavenly armies confronting the beast, earthly kings, and their armies. These are separate episodes, not one supplied tactical scenario. [Chapter 12](https://www.biblegateway.com/passage/?search=Revelation+12&version=KJV), [chapter 19](https://www.biblegateway.com/passage/?search=Revelation+19&version=KJV)

Our own canon lets both sides have vulnerabilities, charismatic leaders, surprises, and meaningful victories. That is a game-design judgment, not a judgment on those religious or literary works. Original mythic fiction also gives us freedom to make the tone adventurous and cheeky without presenting invented scenes as scripture.

## Player contract

1. Inspect your own army, visible enemy contacts, terrain, objectives, and the current round.
2. Spend a limited command allowance on explicit orders; inspect their reachable destinations and consequences before committing. Unordered units have a documented default.
3. Commit the entire plan. The opponent chooses without receiving your private orders.
4. The authoritative rules resolve both plans under a documented order of operations. Presentation displays that result; animations cannot change it.
5. Read a concise report identifying movement, contact, combat, and scoring that your side was entitled to observe. Repeat until a declared result.

Simultaneous planning must not mean implementation-order advantage. Define collisions, opposing moves, vacated destinations, simultaneous casualties, objective ties, and the final-round tiebreak explicitly in the executable rules. Show rejected orders before commitment where knowledge permits. If unseen opposition blocks a legal-looking order, explain the newly observed contact after resolution rather than silently ignoring input.

## Information, opponents, and tutoring

The full referee state and a side's observation are different objects. Opponent adapters consume only the observation available to that side; they cannot receive hidden unit positions, enemy orders, future random values, or the full referee state. The initial opponent may be a modest legal heuristic, labelled as practice strength. Deeper search is separate work.

Fog is a rule, not a dark shader. The view must omit unseen enemies from interaction, tooltips, accessibility labels, and side-facing reports. A hidden enemy must not change an opponent's selected plan when all observable information is otherwise identical. Spectator/debug views must be explicitly separate. Observation tests must cover both sides and both initial and post-resolution positions.

Later reconnaissance can add uncertain last-seen contacts and report age, but the first release must not suggest such memory exists until implemented. Command distance, order delay, retreat, supply, and commander powers remain later experiments; they are not implied by the word Kriegsspiel. Basic morale already exists.

Tutor explanations use the player's observation and identified rules facts. Explain what a player could reasonably know: an exposed approach, a threatened objective, or an order competing for command capacity. Never reveal a hidden formation to justify a suggestion. Post-battle omniscient review is a separately labelled mode and remains future work until built.

## Rules and scene architecture

Keep the new game's state, rules, observation filtering, and opponent policy under `games/ninth_gate/`, independent of Nodes. Its own controller owns state and submits complete plans. Do not force simultaneous orders into chess's `try_move(from, to)` contract or broaden `core/session.gd` while implementing the first scenario.

The scene consumes copied snapshots or filtered observations and requests legal actions. A revision identifies every committed round, reset, undo, and load. Delayed opponent results and animations must be discarded when their source revision is obsolete. Stable formation IDs connect rules events to counters. Rebuilding the complete scene from an authoritative snapshot must always be safe.

Use Resources for presentation colours, dimensions, materials, marks, and terrain appearance. The existing chess renderer is specifically 8×8 and cannot be made into this map merely by changing its metadata Resource. Extract shared presentation helpers only after both scenes demonstrate the same need. Do not make combat or visibility depend on mesh positions, physics collisions, or lighting.

## Replay, randomness, and saves

The long-term record is a versioned scenario ID, rules version, initial state, accepted plans, random seed/state when applicable, and ordered outcomes. The same record must reproduce the same battle. The current prototype uses a seeded six-sided combat roll and a versioned seed-plus-human-order-history save; replay regenerates the deterministic opponent and all outcomes. It has no separate replay viewer yet.

The current rules own their seeded generator and restore its state through undo and transactional replay loading. Rendering, audio, and opponent thinking cannot consume the combat generator. Preserve this property while adding features, and separate practice undo from any eventual competitive mode. Do not use chess FEN or PGN as a container for this game.

Save loading must validate into a separate candidate state and replace the live session only after success. Unsupported versions, illegal plans, duplicate formation IDs, and invalid coordinates must leave the current battle intact. A first prototype without replay or save must say so plainly rather than offer a nonfunctional control.

## First prototype and acceptance boundary

The current work upgrades one compact scenario to a **3D fantasy war table** with clearer planning, faster useful movement, and more distinctive role actions. The former 2D release's 78 rules checks and 46 interface checks are historical evidence, not proof of this new rules/rendering revision. Exact implemented rules belong in [RULES.md](../games/ninth_gate/RULES.md); fresh native and rules evidence belongs in [verification](NINTH_GATE_VERIFICATION.md). Human novice acceptance and balance playtesting remain open until actually performed.

| Gate | Required evidence before claiming completion |
| --- | --- |
| Rules | Fixtures for legal/rejected orders, movement conflicts, combat, scoring, and terminal states |
| Knowledge | Same observation produces the same deterministic opponent plan despite changed hidden referee data; no private enemy orders in view payloads |
| Authority | Rendering a new snapshot, restarting, and undoing cannot retain stale pieces or orders; rejected requests leave state unchanged |
| Determinism | Repeat identical initial state and plans and compare resulting states and event order |
| Playability | Complete a native-rendered game; independently check its final result and report |
| Presentation | Inspect the actual map at normal and minimum window size, including selection, fog, crowded combat, and final result |
| Balance | Record faction, seed/scenario, outcome, rounds, and major decisions for human games; bot win rates alone are insufficient |

## Polish direction and roadmap

The map should feel like a premium fantasy board: framed dark wood, a luminous river, raised bridges and terrain, a pale celestial bank, warm infernal accents, and sculptural static counters. Use a comfortable oblique camera with every playable cell visible. Distinct silhouettes and marks matter more than tiny decorative detail. Geography must remain readable beneath order arrows, health information, and selection marks. Original adult commander portraits frame the rivalry without covering the battlefield.

Codex's polish pass should improve input feedback, cancellation, order preview, contact reports, camera framing, typography, material response, contact shadows, motion, and quiet wooden sounds. Offer reduced motion and mute. Keep combat non-graphic; counters can topple, fade, or move to a casualty tray. Sound and animation should explain commitment, obstruction, impact, and a result.

After the baseline is readable and fun: add one alternate scenario, distinct commander powers with costs and counters, and both playable sides. Then experiment with faction formations, evacuation objectives, stronger opponents, and alternate physical sets. Animated Heaven/Hell characters are a later theme with the same formation IDs and legal state. Long battle animations must be skippable and cannot postpone the acceptance of authoritative results.

## Parallel follow-up slices

Each slice is about ten minutes of bounded work, not a promise to finish a complete subsystem in ten minutes. Stop with a coherent commit and evidence. One owner per file in each wave; the coordinator owns project configuration, integration, publication, and the current application scene. File names below are proposed unless they already exist.

| Wave / slice | Owned files | Depends on | Output and explicit check |
| --- | --- | --- | --- |
| 1A: resolution edge fixtures | `tests/test_ninth_gate_conflicts.gd` | Current rules API | Collisions, mutual destruction, and objective tie cases; headless suite passes |
| 1B: knowledge fixtures | `tests/test_ninth_gate_information.gd` | Observation API | Hidden-state equivalence and event-redaction cases; compare both sides' payloads |
| 1C: playtest form | `docs/NINTH_GATE_PLAYTEST.md` | Prototype rules | One-page structured battle record; another person can report a reproducible result |
| 1D: mark exploration | `assets/ninth_gate/candidates/` | Six-or-fewer role inventory | Original candidate SVG marks; inspect at real counter size and record provenance |
| 2A: record regressions | `tests/test_ninth_gate_record.gd` | Existing seed/history save + 1A | Extend schema rejection, long-history, and random replay fixtures; round trip reproduces final state |
| 2B: theme extension | `themes/war_table_theme.gd`, `themes/ninth_gate.tres` | Existing palette + 1D admitted marks | Add required mark/size/material seams; Resource imports without rules dependencies |
| 2C: opponent diagnostics | `tests/test_ninth_gate_opponent.gd`, `tools/ninth_gate_matches.gd` | 1B | Legal-plan self-play log; all runs terminate or hit an explicit capped diagnostic |
| 3A: integration | Coordinator-owned Ninth Gate scene/controller | 2A, 2B | Extend theme presentation and add read-only replay navigation; invalid load leaves current battle intact |
| 3B: visual acceptance | `docs/NINTH_GATE_VISUAL_REVIEW.md`, `docs/images/ninth_gate/` | 3A | Native initial/contact/endgame captures; verify readable information and no hidden enemies |
| 3C: second-game boundary | `docs/SELECTED_GAME_CONTRACTS.md` | Current cabinet integration | Go, Xiangqi, English-checkers variant/topology/save requirements; no claim that metadata makes them playable |
| 4A: balance adjustment | One named scenario data file + its tests | Recorded human playtests | Change one parameter at a time; document reason and replay regressions |
| 4B: release acceptance | `docs/VERIFICATION.md` and release notes, coordinator | Earlier waves | Full relevant suites, fresh export smoke, exact commit/assets and unpassed gates recorded |

## Ownership and rights

Write original code, explanatory prose, map art, sounds, faction identities, and symbols. Historical inspiration does not authorize copying modern translations, modern miniature designs, or another franchise's angels and demons. The [U.S. Copyright Office's game guidance](https://www.copyright.gov/register/tx-games.html) distinguishes methods of play from protected literary and pictorial expression. It does not clear a product name or establish worldwide rights. “The Ninth Gate” is a working title pending a separate naming review; no public brand clearance or project source-code licence is implied by a private GitHub repository.
