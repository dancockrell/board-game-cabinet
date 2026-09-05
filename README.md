# Board Game Cabinet

A Godot desktop board-game cabinet, beginning with chess on a wooden board and round wooden chips carrying branded chess symbols. The first implementation establishes legal state, simple tactile presentation, interaction, and the seams for future themes and games.

The full product contract, architecture, acceptance gates, and parallel implementation waves are in [docs/PLAN.md](docs/PLAN.md). The plan distinguishes the foundation milestone from a polished, complete vertical slice; a feature described there is not necessarily implemented yet.

## Run

Open `project.godot` in Godot 4.x with the Compatibility renderer and run the project. The exact tested Godot version and completed checks should be recorded in the repository verification notes. An initial command-line import can be run with:

```text
godot --headless --path . --editor --quit
```

Run the checked-in test scripts with the Godot executable and `--headless --path . --script res://tests/<test-script>.gd`; use actual filenames in `tests/`. Tests should exercise the rules independently of scene startup. Graphics, input, sound, and exported builds need separate runtime checks.

## Design boundaries

- Rules and state are `RefCounted` objects. Core legality never depends on a Node.
- The session accepts moves, records history, and owns the position. The board renders that state and submits requests.
- Board/piece themes are Godot Resources. Appearance changes must preserve the position and legal moves.
- Chess is concrete first. Xiangqi will introduce intersection topology and its own rules without forcing chess assumptions into a universal base class.
- Computer and tutor adapters return identified, position-bound results. Obsolete responses must be discarded and every proposed move revalidated.

See `AGENTS.md` before collaborating. Work in the plan's independently owned slices, stage only your files, and keep commits small. Passing headless checks is not evidence of visual polish; inspect the actual running board before making that claim.
