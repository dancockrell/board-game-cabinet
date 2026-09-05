# Board Game Cabinet handoff

Updated 2026-09-05. Repository: [dancockrell/board-game-cabinet](https://github.com/dancockrell/board-game-cabinet), private.

## Start here: current request

**Build a Clash Royale-style real-time arena battler with our Greek heroes and monsters.** Keep the familiar two-lane, three-tower, four-card-hand, regenerating-elixir loop. The user explicitly asked for direct implementation without more scenario design or extended deliberation. See [Olympus Arena](OLYMPUS_ARENA.md).

The previous Heaven-and-Hell setting, invented commanders, Ninth Gate scenarios, Greek rescue adventure, and simultaneous-turn proposal are superseded. They remain historical source work, not the active product brief. Go, Xiangqi, and checkers were earlier selections but are not part of this implementation pass.

Use original Greek characters and presentation assets. Preserve the existing wooden chess game. Do not build a broader all-games framework or add commercial progression, accounts, or network services to this first local prototype.

## Repository status

| Component | Status and evidence boundary |
| --- | --- |
| Wooden chess | Existing playable game: pure chess rules, wooden 3D board and chips, mouse/keyboard controls, history, undo, save/load, practice opponent, factual tutor context, and PGN export. Preserve its tests. |
| Olympus Arena | Playable source checkpoint `7bff5ce`: Greek unit deployment, real-time automatic battles, local opponent, two lanes, three structures per side, cycling cards, and elixir. Rules: 740 checks; native renderer: 28; native application: 33 with captures. Packaging and full regression evidence are separate. |
| The Ninth Gate | Parked historical prototype with rules, 3D source work, and an older 2D prerelease. Its setting and play loop are not the current direction. |
| Go / Xiangqi / checkers | Previously selected future games; not implemented and not active parallel work. |

The [successful chess checkpoint](https://github.com/dancockrell/board-game-cabinet/actions/runs/33967027800) and [older Ninth Gate CI](https://github.com/dancockrell/board-game-cabinet/actions/runs/33969164766) are historical evidence only. The [Ninth Gate prerelease](https://github.com/dancockrell/board-game-cabinet/releases/tag/ninth-gate-prototype-2026-09-05) is not an Olympus build. For a new download, inspect its release notes and manifest for the packaged source commit. Never treat earlier CI or an older executable as validation of new arena code.

## Current controls and limitations

The main project opens Olympus Arena. Press **BATTLE** to begin; the timer waits for this action. Select a card with a click or **1–4**, then click the blue half to deploy troops, or drag the card onto the board. Thunderbolt targets either half. **Escape** clears selection. **Space** or **Pause / Resume** pauses/resumes. **Restart** requests confirmation before replacing the match; **REMATCH** starts again from the result screen. A chess-table button preserves access to chess.

The fixed eight-card deck has no editor. This is local practice against a basic opponent. There are no accounts, network battles, progression, collection upgrades, arena saves/replay, or collision avoidance. Original procedural Greek models are readable placeholders, not a completed character-art set. Native gameplay/result captures and complete-battle checks passed at `7bff5ce`; full cabinet checks and the Windows export need their own publication record.

## Actual project boundaries

| Location | Responsibility |
| --- | --- |
| `games/olympus_arena/session.gd` | Pure arena authority: unit definitions, resource/hand state, deployments, navigation, combat, objective damage, clock, and outcome |
| `presentation/olympus_arena_board.gd` | Arena, towers, Greek unit visuals, state-driven effects, and picking |
| `app/olympus_arena.gd`, `.tscn` | Arena scene, card controls, HUD, ticking, local opponent, restart, and exit |
| `games/chess/`, `core/session.gd` | Existing chess rules and session; the session is chess-specific, not a generic multi-game implementation |
| `ai/` | Existing chess practice opponent and factual tutor interfaces |
| `presentation/`, `themes/`, `assets/` | Presentation helpers, Resource themes, and original assets |
| `games/ninth_gate/`, `app/ninth_gate*` | Historical battle prototype; retain without treating its rules or fiction as current requirements |
| `tests/`, `tools/`, `.github/workflows/validate.yml` | Native/headless tests and CI integration |
| `docs/` | Design, provenance, verification, and archived decisions |

Rules and authoritative state extend `RefCounted`, not `Node`. Scenes submit actions and render copied snapshots. They cannot fix a rule by relocating a visual piece. The same principle now applies to continuous combat: attack timing, target choice, costs, and death belong to the simulation. A renderer may interpolate motion and play effects but cannot invent a successful deployment or hit.

Keep the arena implementation narrow. A shared material/theme helper is useful; a universal action hierarchy for chess, Go, real-time combat, and every future game is premature.

## Running and checking

Use Godot 4.3 and the Compatibility renderer. From the repository root:

```powershell
godot --path .
./tools/verify.ps1 -Godot "C:/path/to/Godot_v4.3-stable_win64_console.exe"
./tools/verify.ps1 -Godot "C:/path/to/Godot_v4.3-stable_win64_console.exe" -Graphics
```

The local validation script enumerates suites explicitly. Check that new arena suites are included before describing it as complete coverage. CI also enumerates its headless suites explicitly. Native rendering must be checked separately: the headless dummy renderer cannot establish visual quality.

To package Windows, install the matching Godot 4.3 export templates, create `build`, and run:

```powershell
godot --headless --path . --export-release "Windows Desktop" "build/BoardGameCabinet.exe"
```

Launch and play the exported executable as well as the editor project. Record the executable hash, source commit, test results, and known limitations in the release manifest/notes. Do not silently reuse an older archive after source changes.

## What a useful next handoff contains

Supply a clean commit, exact run instructions, tested controls, a complete-match result, native screenshots, and known defects. Report whether deployment boundaries, resource spending, card cycling, target selection, tower destruction, clock expiry, and restart have tests. Identify the practice opponent honestly; a legal local policy is not competitive multiplayer or a strong adaptive opponent.

For the Codex polish pass, preserve stable unit/tower IDs, copied snapshots, clearly defined deployment coordinates, one simulation clock, explicit outcome data, and a restart boundary that discards old visual effects. Keep original model/material sources editable. Note which units are merely visually distinct and which actually have different behavior; never sell lore as an implemented ability.

The next work should make a single arena match enjoyable: readable counters, responsive deployment, good movement spacing, expressive but clear hit feedback, useful audio, reliable card selection, and understandable win/loss feedback. Tune through actual matches before expanding the roster.

## Small parallel continuation slices

Each slice should take roughly ten minutes of focused work and end in its own reviewable commit. Estimates exclude open-ended tuning and asset production. Do not split shared app or simulation ownership across simultaneous agents.

| Wave | Slice and likely files | Dependency | Expected output and explicit check |
| --- | --- | --- | --- |
| 1 | Rule edge cases: `games/olympus_arena/test_*.gd` | Stable rules API | Regression cases for unaffordable/invalid placement and exact card cycling; headless suite passes |
| 1 | Visual identity audit: `docs/OLYMPUS_VISUAL_AUDIT.md` | Native build | Actual gameplay-distance observations for each unit/team; every claim tied to a screenshot |
| 1 | Match observations: `docs/OLYMPUS_PLAYTEST.md` | Complete playable match | Three match records with outcome, duration, unused cards, and novice confusion; no invented balance conclusions |
| 2 | Card usability: `app/olympus_arena.gd` | Wave 1 observations; sole app owner | Clear selected/affordable states and rejection feedback; exercise mouse and keyboard at supported window sizes |
| 2 | Greek silhouette pass: `presentation/olympus_arena_board.gd` | Visual audit; sole renderer owner | Improve two confused unit silhouettes; compare native before/after at game distance |
| 2 | Combat tuning: `games/olympus_arena/session.gd` | Match observations; sole rules owner | One documented counter interaction improved; existing regressions and complete match pass |
| 3 | Integrated acceptance and export: app/tests/tools/release notes | All approved Wave 2 commits | Chess regression suite, arena headless/native checks, exported full match, exact commit/hash manifest |

## Historical material and rights

The [original chess plan](PLAN.md) remains useful architecture history. The [Ninth Gate design](NINTH_GATE_DESIGN.md), [verification](NINTH_GATE_VERIFICATION.md), and [rejected art checkpoint](ART_DIRECTION_STATUS.md) explain older work; their product instructions have been superseded. Do not regenerate or restore the rejected commander art.

Greek mythological subject matter does not grant permission to copy a modern game's character designs, a film's costume designs, a translation, a soundtrack, or commercial artwork. The new implementation uses original assets and its own presentation. The repository remains private; no source licence or change of visibility is implied.
