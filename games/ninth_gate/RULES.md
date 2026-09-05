# The Ninth Gate — rules, version 2

An original Heaven-versus-Hell tactical board game inspired by the command and uncertainty of historical Kriegsspiel. This is a bounded playable experiment, not a historical rules implementation or a claim of competitive balance. The rules below describe the shipped prototype exactly; larger design documents may describe future work.

## Board and victory

The board has 12 files and 8 ranks. Coordinates in the API start at zero. The river occupies file 5; it is impassable except at bridge ranks 1, 3, and 6. Those three bridges are the objectives. Woods and hills provide cover. Hills also increase observation range.

Each army begins with six units: two guards, two spears, one archer, and one herald. Each has five health and three morale. Heaven starts on file 2, Hell on file 9, ranks 1 through 6.

At the end of every round, a unit standing on an objective captures it for its army. Ownership clears when the unit leaves. Each occupied objective scores one point per round. Reaching 12 points ends the battle after simultaneous scoring; higher score wins if both reach the target together. Eliminating the opposing army wins immediately. If both armies disappear simultaneously, compare objective scores. Otherwise the game ends after resolving round 8; higher objective score wins, and equal scores draw. There is no additional health tiebreaker.

## Command and observation

The human commands Heaven. Hell uses a small deterministic practice opponent. Each army issues at most three orders, each to a different living unit. Unordered units attack the nearest visible enemy in range after movement, or stay put if none is available. Ties use unit identifier. Explicit commands replace this automatic attack, including Move, Hold, Rally, and Mend. Orders are committed before either army moves; the bot never reads the human's submitted orders.

Friendly units are always visible. Enemy units are visible within Manhattan distance three of any friendly unit, or distance four of a friendly unit standing on a hill. Terrain does not block line of sight in this prototype. Objective ownership and both scores are public. There are no remembered enemy contacts. The player view omits the random state, opposing dispatches, and referee combat log. It includes the final observed board, public score and captures, and reports about its own movement, rally, attacks, incoming damage, and casualties. A failed attack reports that the targeted square had no enemy; a blocked move does not identify an unseen blocker.

The bot receives the same filtered view for its side. It spends commands on recovery and advancing toward unoccupied or hostile objectives, reserving distinct destinations. It stays on occupied bridges and relies on automatic attacks instead of spending all commands on fire. It is intentionally a modest opponent, not a military planning engine.

## Orders

* **Hold / Brace:** stay in place, gain one cover this round, and do not attack.
* **Move:** move up to two steps north, south, east, or west, with a turn permitted between steps. Every step must be passable and unoccupied in the observed planning position. River squares are illegal. Hidden occupants can cause a legal attempted move to fail during resolution; there must still be a clear path in the authoritative pre-round position.
* **Attack:** target the planning position of a visible enemy within Manhattan range one, or range three for archers. There is no intervening-square line-of-fire rule. The attack targets the square, not a tracking unit identifier.
* **Rally:** recover one health up to five. Recover one morale, or two for Heaven, up to three. 

* **Mend:** heralds can restore two health to an injured friendly unit within one step, including themselves. The order targets a square; if that ally moves away it may miss. Healing cannot exceed maximum health.

Both factions have two guards, two spears, one archer and one herald, with unique formation names exposed through `display_name` and role help through `description`. Guards have one additional cover, spears have one additional attack power, archers have range three, and heralds mend.

## Simultaneous resolution

1. Validate every human order against the same current observed position. Any malformed, duplicate, excessive, stale, or illegal request rejects the entire round without changing state or consuming randomness.
2. Generate the bot orders from its observed planning position. Sort all orders by unit identifier, so selecting orders in another UI sequence cannot manipulate die allocation.
3. Resolve movement simultaneously. A destination or necessary intermediate cell occupied at the start of the round blocks that path even if its occupant moves away. If two or more units try to enter the same square, all stay put. Swaps, follow-the-leader moves, and automatic collision combat are absent.
4. Resolve rally and mend orders.
5. Choose automatic attacks for units without commands using the resulting observed position, and sort all attacks by unit identifier.
6. Resolve attacks against occupants of the targeted squares after movement. An empty square, friendly occupant, or target now out of range causes the attack to miss without a die roll. All valid attack damage is accumulated and applied together; a unit fatally struck this round still deals its attack.
7. Remove units at zero health, capture and score objectives, then check the end condition.

An attack rolls a deterministic seeded six-sided die. Attack bonus is two for spears and one for every other role. Hell adds one. An attacker with morale at least two adds one. Cover is one for woods or hills, plus one for any guard and one for an explicit Brace order. Damage is `max(0, floor((die + attack bonus + morale bonus - cover) / 3))`. Taking any positive total damage loses one morale, regardless of the number of attackers. Zero morale is permitted; there is no routing rule yet.

Heaven has quicker morale recovery; Hell hits harder. Both sides have armored guards. These asymmetries have not yet undergone balance playtesting.

## Authority, persistence, and integration

`session.gd` extends `RefCounted`, imports no scenes, and owns every rule and state mutation. `snapshot()` and `view_for(side)` return deep copies. UI code must render `view_for("heaven")`, never the full referee snapshot. A board interaction submits one of the dictionaries returned by `legal_orders(unit_id, side)`.

`resolve_round(orders, expected_revision)` returns `{ok, revision}` on success or `{ok:false, error}` on failure. All normal UI submissions should include the current revision. Undo restores the entire preceding round including random state, while advancing the revision so old requests remain invalid. New games and loads also advance the revision.

Saves use schema 1, game ID `ninth_gate`, rules version 2, initial seed, and the human order history. Loading validates and replays into a separate candidate session before replacing the live session. Undo remains available after load. The stored referee state is not trusted. Version-1 saves are explicitly rejected with a message to start a new battle.

## Validation and limits

The snapshot includes `round_limit:8` and `target_score:12`; views retain these public fields.

Run `godot --headless --path . --script games/ninth_gate/test_ninth_gate.gd` from the project root. Tests cover copied snapshots, observation, illegal and stale request atomicity, collisions and swaps, simultaneous fatal attacks, deterministic replay, round limit, transactional saves, and bot independence from unseen enemies.

Not implemented: multiplayer, order delays, courier simulation, retreat/routing, remembered contacts, artillery, flying movement, morale auras, hex maps, line-of-sight occlusion, reaction fire, scenario editing, sophisticated AI, replay controls, balance certification, or claims that this is the best Kriegsspiel. The goal is a sound small prototype from which those design decisions can be tested.
