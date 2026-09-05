# Board Game Cabinet: Claude build / Codex polish handoff

**Latest steering:** the first generated commander art was rejected. Establish army lore before further character art; see [art direction checkpoint](ART_DIRECTION_STATUS.md). Rules v2 and the 3D board are a working source checkpoint, not an approved finished visual style. The existing downloadable release is still the older 2D version.

Updated 2026-09-05. Repository: [dancockrell/board-game-cabinet](https://github.com/dancockrell/board-game-cabinet), private. Start with this document and [The Ninth Gate design](NINTH_GATE_DESIGN.md). The user's latest selection supersedes the earlier broad game catalogue: **chess, Go, Xiangqi, English checkers, and an original Heaven-versus-Hell Kriegsspiel**. Dice and other components are allowed where a chosen board game needs them. This is not an all-games platform.

## Intended collaboration

Claude builds a complete, testable game foundation and hands over clean source, readable placeholder presentation, exact rules, run instructions, and evidence. Codex then improves materials, visual clarity, input, feedback, sound, and presentation consistency. Both stages own correctness. Neither stage can postpone defects by calling them polish.

For the new war game, use the structured Reisswitz 1824 tradition as historical inspiration and implement original rules with a reproducible digital adjudicator. The user has now selected **our original canon** and authorized changing the rules and presentation to make a fun modern 3D game for novices. The tone is adventurous and playful, with glamorous adult commanders and a PG-13 flirtatious rivalry. Aureth, Keeper of the Dawn, faces Veyra, the Cinder Regent, at the Three Bridges of the Ninth Gate. See the [setting and comparison with Milton/Revelation](NINTH_GATE_DESIGN.md#why-original-canon-is-the-best-fit-for-this-game). The working title and quality ambitions do not establish brand clearance or playtested excellence.

## Status and evidence boundary

| Game | Current status | Next useful boundary |
| --- | --- | --- |
| Chess | Existing playable wooden table; validated source checkpoint `6f5ff9273c07da13331d2c647468d2ba33604bd2` | Preserve it; complete manual acceptance and further polish |
| The Ninth Gate | Version 2 rules and a new 3D presentation are the current iteration; the former 2D release is a historical checkpoint | Verify current integration/export, then novice playtesting and balance; see [current verification](NINTH_GATE_VERIFICATION.md) |
| Xiangqi | Selected, not implemented | 9×10 intersection board, river/palaces, complete rules and repetition policy |
| Go | Selected, not implemented | Choose a named rules/scoring/ko policy before coding; 9×9 is a practical first teaching board, not a confirmed product decision |
| English checkers | Selected, not implemented; variant is provisional | 8×8 dark-square play, compulsory capture chains, English promotion and king rules |

The [successful chess CI run](https://github.com/dancockrell/board-game-cabinet/actions/runs/33967027800) covers the older chess checkpoint. The [earlier Ninth Gate CI](https://github.com/dancockrell/board-game-cabinet/actions/runs/33969164766) and [2D prerelease](https://github.com/dancockrell/board-game-cabinet/releases/tag/ninth-gate-prototype-2026-09-05) establish the previous prototype. Neither validates the current rules or 3D changes. Use the current [verification record](NINTH_GATE_VERIFICATION.md) and release manifest for the exact tested and packaged source. A green import alone does not establish playability or visual quality.

The chess foundation includes ordinary and special legal moves, promotions, turn ownership, SAN history, undo, immutable review, transactional single-slot save/load, supported draw claims, PGN export, mouse/keyboard play, Resource-driven wooden presentation, reduced motion, and a local two-ply practice opponent. Tutor support is factual context and modest candidates. It is not a strong chess engine or a conversational tutor. Generic dead positions, PGN import, multiple slots, complete accessibility acceptance, and full manual acceptance remain open.

## Exact next-build brief

Polish and playtest **one Ninth Gate scenario first**, retaining playable chess. Heaven is the player's army; Hell is a practice opponent. The current iteration adds a 3D table, clearer novice-facing orders, faster movement, useful default attacks, a support action, shorter matches, and original commander presentation. Do not build Go, Xiangqi, or checkers simultaneously. Do not claim commander powers, dialogue systems, civilian evacuation, or a fortress siege: those are future mechanics, even when the fiction mentions them.

Keep state and rules independent of Godot Nodes. The scene presents a side-filtered observation and requests actions. It cannot correct the rules by moving a counter locally. The opponent cannot read the full referee state or the player's pending orders. Report current limitations directly. Finish with a clean commit, reproducible commands, a native screenshot, and test output tied to the commit.

## Current rules contract: version 2

`games/ninth_gate/session.gd` is the pure `RefCounted` authority. Consult [exact rules](../games/ninth_gate/RULES.md) and its adjacent tests for formulas and edge cases. Rules commit `886f9ba` and regression commit `550717e` passed 80 headless checks. This is rules evidence; the coordinator must separately verify the integrated UI and export. The [design document](NINTH_GATE_DESIGN.md) distinguishes setting, current mechanics, and future ambitions.

| Area | Version 2 contract |
| --- | --- |
| Map | 12×8 cells; river at zero-based column 5; crossings at rows 1, 3, and 6; woods and hills |
| Armies | Six formations each: two guards, two spears, one archer, one herald; Heaven and Hell use original presentation |
| Planning | Up to three distinct formation orders: move, attack, rally, hold, or a Herald's support action. Unordered units automatically attack the nearest enemy in range after movement, with stable-ID tie breaking |
| Movement | Up to two cardinal steps through free passable cells; river impassable except crossings; start-of-round occupation blocks paths; competing destinations stop contenders |
| Resolution | Both plans commit before movement, recovery/support, and simultaneous damage. Any explicit order suppresses that unit's default attack; moving does not also attack |
| Combat | Archers reach Manhattan distance 3, others 1. Hold braces for extra cover; Wardens on both sides receive armour. Terrain, morale, and seeded dice contribute |
| Recovery | Rally restores one health and morale; Heaven rallies morale faster. Heralds can restore two health to self or an adjacent injured ally; square targeting may miss a moving ally |
| Faction experiment | Heaven recovers morale faster; Hell adds attack power. Balance remains a playtest hypothesis |
| Objectives | Each occupied bridge awards one point per round. Vacated bridges clear ownership and stop scoring |
| End | Army annihilation, first to at least 12 points, or eight resolved rounds. Simultaneous thresholds and ties follow the exact rules; equal deciding scores draw |
| Knowledge | Friendly sight reaches Manhattan distance 3, or 4 from hills; public scores/site ownership; hidden enemies/orders withheld; own dispatches and public captures only |
| API | `snapshot()` for referee/debug use; `view_for(side)` for presentation; `legal_orders(unit_id, side)` for planning; `resolve_round(orders, expected_revision)` for commitments |
| Persistence | `undo()` restores a whole round including random state; `save_data()` / `load_data(data)` replay seed and accepted human plans transactionally. Version 1 saves are rejected explicitly; there is no silent migration |

There is no line-of-sight occlusion, contact memory, order transmission delay, supply, routing, strong AI, two-human secret planning, or finished balance model. Fog radius is a deliberately small rule, not a complete battlefield intelligence simulation. Portraits establish characters; they do not establish playable commander abilities. Consult current verification before presenting integration work as shipped.

## Work in the existing project

| Location | Responsibility and constraint |
| --- | --- |
| `games/chess/` | Pure chess state, rules, and notation; preserve existing contracts |
| `ai/` | Chess opponent adapter, local practice policy, and factual tutor context |
| `core/session.gd` | Authoritative chess session; currently chess-specific, not a generic all-games session |
| `core/game_definition.gd`, `games/chess.tres` | Metadata seams; changing dimensions here does not generalize the renderer |
| `games/ninth_gate/` | New battle rules/session and related game data; no presentation imports |
| `app/` | Chess entry button and `ninth_gate.tscn` / `ninth_gate.gd` battle scene; coordinator-owned integration |
| `themes/war_table_theme.gd`, `themes/ninth_gate.tres` | Existing war-map palette Resource; extend it instead of introducing a duplicate theme system |
| `presentation/`, `themes/`, `assets/` | Presentation helpers, Resource themes, original assets; geometry has no authority over legality |
| `tests/`, `tools/` | Headless rules, native presentation checks, verification automation |
| `docs/` | Design, exact evidence, provenance, and future acceptance work |

Start Godot 4.3 with the Compatibility renderer. From the repository root, with the matching executable on PATH:

```powershell
godot --path .
./tools/verify.ps1 -Godot "C:/path/to/Godot_v4.3-stable_win64_console.exe"
./tools/verify.ps1 -Godot "C:/path/to/Godot_v4.3-stable_win64_console.exe" -Graphics
```

Inspect `tools/verify.ps1` to see which new suites are included; explicitly run new rules suites until integrated there. Headless dummy rendering does not establish visual quality. Existing native verification used Windows, NVIDIA RTX 4070, and OpenGL. To build Windows, install Godot's matching 4.3 export templates, create a `build` directory, then use:

```powershell
godot --headless --path . --export-release "Windows Desktop" "build/BoardGameCabinet.exe"
```

The new rules suite can be run independently with `godot --headless --path . --script games/ninth_gate/test_ninth_gate.gd`.

## Delivery back to Codex

Supply the source commit and branch, exact game variant and rules version, launch instructions, test results, and known defects. Include at least one complete battle record and native images of planning, contact, and the result. Identify any untested save/replay or information-boundary behaviour. Keep the existing chess checks passing; do not claim the older chess CI validates new work.

The polish pass needs stable formation IDs, copied observations, documented orders and events, revision handling, explicit outcome data, reusable theme Resources, original asset sources, and room for keyboard navigation. Those are useful interfaces. A universal hierarchy for every imaginable game is not required. Add Go's placements and passing, Xiangqi's intersection moves, and checkers' multi-capture actions only when implementing their own tested sessions.

Use the [parallel ten-minute waves](NINTH_GATE_DESIGN.md#parallel-follow-up-slices) for bounded follow-up tasks with distinct file ownership, dependencies, and checks. Preserve current rules tests while checking novice clarity: can a new player identify the objective, explain the three-order budget and default attacks, distinguish roles, undo a mistake, and understand the result? Record confusion and match duration instead of assuming shorter rules are fun. The earlier [chess plan](PLAN.md) remains the architecture record; this selected scope supersedes older roadmap ordering.

## Rights and publication

Keep original code, prose, map artwork, marks, sounds, and faction designs. Do not copy a modern Kriegsspiel translation, commercial board, or an existing fantasy franchise's visual identity. Traditional game methods and a modern publisher's written or visual expression are different rights questions; see the [U.S. Copyright Office guidance](https://www.copyright.gov/register/tx-games.html). Historical references are inspiration, not a blanket worldwide licence. The Ninth Gate is a working title requiring naming review before public branding. The repository remains private; no source-code licence or permission to change visibility is implied.
