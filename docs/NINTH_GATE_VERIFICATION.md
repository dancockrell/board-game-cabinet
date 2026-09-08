> Historical checkpoint: the former 3D presentation described below was retired on 2026-09-08. It is not an active art specification or evidence for the current build. Rules work remains retained. Follow [the 2D-only art contract](OLYMPUS_BOARD_ART.md) and [current handoff](HANDOFF.md).

# Ninth Gate prototype verification — 2026-09-05

This is an original, bounded 2D war-table prototype, not a finished or balanced Kriegsspiel. The religious canon and battle story remain provisional. The current map is a contest over three crossings; a fortress siege, named scriptural commanders, flying units, and faction-specific armies are not implemented.

## Reproduce

Use Godot 4.3 stable, Compatibility renderer. Open the existing chess table and choose **The Ninth Gate**, or run `godot --path . res://app/ninth_gate.tscn`.

```
godot --headless --path . --script res://games/ninth_gate/test_ninth_gate.gd
godot --headless --path . --script res://tests/test_ninth_gate_app.gd
godot --path . --script res://tests/test_ninth_gate_app.gd -- --qa-folder=/absolute/output/folder --end-capture=/absolute/output/folder/ninth-gate-result.png
```

`tools/verify.ps1` includes both new suites alongside the existing chess suites. GitHub CI runs both new suites headlessly. Native Windows checks use NVIDIA RTX 4070/OpenGL; headless checks do not establish rendered quality.

## Evidence

- The entire existing chess verification command passed after adding navigation to the new scene: five headless suites plus board, app, and controls native suites. Its independent oracle still compares 960 positions and 23,179 moves; board presentation has 136 checks.
- Rules through `d6d2dd2`: **78 checks passed**, exercising atomic order rejection, stale revisions, copied observations, hidden-enemy independence, movement conflicts, simultaneous fatal attacks, die allocation independent of order-selection sequence, objective scoring, terminal states, undo, and replay loading.
- UI: **46 checks passed** headlessly, exercising observed-state-only counters, legal drafts without state mutation, three-order budgeting and replacements, round commitment, undo, stale plans, focused keyboard interaction, and a complete twelve-round battle.
- Native planning/contact/result screenshots were captured and inspected. The sample scripted battle finished at round twelve, Heaven 26 / Hell 4. This establishes a working result path, **not balance or opponent strength**.
- Full-battle testing exposed and fixed a save replay defect after actual JSON serialization. The loader now validates and normalizes integral numeric coordinates. The passing regression replays the complete saved battle into a fresh session and compares final position, score, reports, and random state, excluding only the session revision.

The final release manifest identifies the exact packaged source and executable/archive hashes. Older chess-only exports are separate artifacts and do not contain this game.

## Remaining acceptance work

Sustained human playtesting, alternative seeds/scenarios, side-swapped balance evaluation, strong opponent planning, minimum-size crowded-combat review, screen-reader support, and a complete manual click-through remain open. Native automated play is not a human playtest. The map currently uses custom 2D drawing and a Resource palette; a physically polished 3D wooden map table, audio, and state-driven movement animation remain future work. There is no fog occlusion behind terrain, remembered contact system, courier delay, routing, artillery, or unique herald power.

The Save control stores accepted rounds, not uncommitted draft orders. The battle uses a separate save slot from chess. Returning to chess recreates that scene; save a battle before leaving if it should persist.

