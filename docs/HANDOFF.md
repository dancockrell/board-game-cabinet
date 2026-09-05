# Board Game Cabinet: Claude build / Codex polish handoff

Updated 2026-09-05. Repository: [dancockrell/board-game-cabinet](https://github.com/dancockrell/board-game-cabinet), private. Start with this document and [The Ninth Gate design](NINTH_GATE_DESIGN.md). The user's latest selection supersedes the earlier broad game catalogue: **chess, Go, Xiangqi, English checkers, and an original Heaven-versus-Hell Kriegsspiel**. Dice and other components are allowed where a chosen board game needs them. This is not an all-games platform.

## Intended collaboration

Claude builds a complete, testable game foundation and hands over clean source, readable placeholder presentation, exact rules, run instructions, and evidence. Codex then improves materials, visual clarity, input, feedback, sound, and presentation consistency. Both stages own correctness. Neither stage can postpone defects by calling them polish.

For the new war game, use the structured Reisswitz 1824 tradition as historical inspiration and implement original rules with a reproducible digital adjudicator. Do not attempt to reproduce a subjective human umpire through unsupported AI promises. The working title is **The Ninth Gate**; its goal is an excellent modern Kriegsspiel, with quality established by playtesting rather than by the title or this brief. Original mythology and the provisional siege/crossing scenario await the user's setting choice; do not cement Milton, Revelation, or another canon without that decision.

## Status and evidence boundary

| Game | Current status | Next useful boundary |
| --- | --- | --- |
| Chess | Existing playable wooden table; validated source checkpoint `6f5ff9273c07da13331d2c647468d2ba33604bd2` | Preserve it; complete manual acceptance and further polish |
| The Ninth Gate | Rules through `d6d2dd2`: 78 headless checks; UI: 46 checks including complete battle and JSON replay; native planning/contact/result captures | Human playtesting, balance, and visual polish; see [current verification](NINTH_GATE_VERIFICATION.md) |
| Xiangqi | Selected, not implemented | 9×10 intersection board, river/palaces, complete rules and repetition policy |
| Go | Selected, not implemented | Choose a named rules/scoring/ko policy before coding; 9×9 is a practical first teaching board, not a confirmed product decision |
| English checkers | Selected, not implemented; variant is provisional | 8×8 dark-square play, compulsory capture chains, English promotion and king rules |

The [successful chess CI run](https://github.com/dancockrell/board-game-cabinet/actions/runs/33967027800) covers the older chess checkpoint, not subsequent Ninth Gate changes. Existing Windows exports likewise predate the new game unless their manifest explicitly identifies a newer source revision. Use the repository's current [verification record](VERIFICATION.md) for later evidence. A new file or a green import alone does not prove a playable, polished battle.

The chess foundation includes ordinary and special legal moves, promotions, turn ownership, SAN history, undo, immutable review, transactional single-slot save/load, supported draw claims, PGN export, mouse/keyboard play, Resource-driven wooden presentation, reduced motion, and a local two-ply practice opponent. Tutor support is factual context and modest candidates. It is not a strong chess engine or a conversational tutor. Generic dead positions, PGN import, multiple slots, complete accessibility acceptance, and full manual acceptance remain open.

## Exact next-build brief

Polish and playtest **one Ninth Gate scenario first**, retaining playable chess. The new source already makes Heaven the player's army and Hell the practice opponent, with order planning, commitment, resolution, undo, save/load, and restart. Its first scene is a simple 2D map with a Resource palette, not a polished 3D wooden war table. Automated native interaction and a complete twelve-round battle are checked; human playtesting and balance remain open. Do not build Go, Xiangqi, or checkers simultaneously with this integration.

Keep state and rules independent of Godot Nodes. The scene presents a side-filtered observation and requests actions. It cannot correct the rules by moving a counter locally. The opponent cannot read the full referee state or the player's pending orders. Report current limitations directly. Finish with a clean commit, reproducible commands, a native screenshot, and test output tied to the commit.

## Prototype contract under implementation

This is the initial rules agent's concrete contract, not a declaration that every item has passed native interaction acceptance. `games/ninth_gate/session.gd` is the pure `RefCounted` authority; consult the [exact prototype rules](../games/ninth_gate/RULES.md) and its adjacent test script for precise formulas. The [design document](NINTH_GATE_DESIGN.md) distinguishes later command and reconnaissance ambitions.

| Area | Initial contract |
| --- | --- |
| Map | 12×8 cells; river at zero-based column 5; crossings at rows 1, 3, and 6; woods and hills |
| Armies | Six formations each: two guards, two spears, one archer, one herald; Heaven and Hell use original presentation |
| Planning | Up to three distinct formation orders each round: move, attack, rally, or hold; omissions hold |
| Movement | One cardinal cell; river impassable except crossings; cells occupied at the start block moves; competing destinations stop all contenders |
| Resolution | Both plans commit before movement, then rally, then attacks; attack damage applied simultaneously |
| Combat | Archers reach Manhattan distance 2, others 1; terrain, morale, faction modifiers, and seeded chance contribute; exact formula remains in executable rules |
| Faction experiment | Heaven favours guard protection and rallying; Hell has increased attack. This is an unbalanced hypothesis awaiting tests and human games |
| Objectives | Three crossing sites retain ownership when vacated and award one point per owned site each round |
| End | Army annihilation or twelve rounds; simultaneous annihilation and round-limit results use objective scores, equal scores draw |
| Knowledge | Friendly sight reaches Manhattan distance 3, or 4 from hills; public scores/site ownership; hidden enemies/orders withheld; own dispatches and public captures only |
| API | `snapshot()` for referee/debug use; `view_for(side)` for presentation; `legal_orders(unit_id, side)` for planning; `resolve_round(orders, expected_revision)` for commitments |
| Persistence | `undo()` restores a whole round including random state; `save_data()` / `load_data(data)` replay seed and accepted human plans transactionally, including undo after load |

There is no claim yet of line-of-sight occlusion, contact memory, order transmission delay, supply, retreat behaviour, distinct abilities for every role, strong AI, two-human secret planning, or a finished balance model. Fog radius is a deliberately small first rule, not a complete battlefield intelligence simulation. Consult the final integration notes before presenting any prototype feature as shipped.

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

Use the [parallel ten-minute waves](NINTH_GATE_DESIGN.md#parallel-follow-up-slices) for bounded follow-up tasks with distinct file ownership, explicit dependencies, and checks. The earlier [chess plan](PLAN.md) remains the record of chess architecture and its acceptance gates; the selected scope here takes precedence over older roadmap ordering.

## Rights and publication

Keep original code, prose, map artwork, marks, sounds, and faction designs. Do not copy a modern Kriegsspiel translation, commercial board, or an existing fantasy franchise's visual identity. Traditional game methods and a modern publisher's written or visual expression are different rights questions; see the [U.S. Copyright Office guidance](https://www.copyright.gov/register/tx-games.html). Historical references are inspiration, not a blanket worldwide licence. The Ninth Gate is a working title requiring naming review before public branding. The repository remains private; no source-code licence or permission to change visibility is implied.
