# Olympus Arena: playable rules

An original Greek roster in a familiar real-time, two-lane card deployment arena. This is a local single-player prototype against a deterministic practice bot. It has no accounts, multiplayer, collection economy, paid upgrades, or licensed commercial assets.

## Win the match

Each player has two defensive towers and a main temple. Destroying a side tower earns one crown. Destroying the temple immediately wins and earns three crowns. At three minutes, the player with more crowns wins. Equal crowns start one minute of sudden-death overtime: the next tower destroyed wins. If overtime expires without a new destroyed tower, surviving building count, then total remaining building health decides the winner; exact equality is a draw.

## Deploy and watch the battle

- Start with five elixir. Maximum ten. One elixir regenerates every 2.8 seconds, doubling after two minutes and throughout overtime.
- Eight cards form a fixed deck. Four are in hand. Playing a card replaces that slot with the next queued card and sends the played card to the back of the queue.
- Troops deploy only on their owner's half, at least 0.8 arena units from the river. Thunderbolt can target either half.
- Troops automatically advance and attack. Ground units cross at one of the two bridges. Flying units cross directly.
- Units attack nearby enemies before buildings, except the Minotaur, which seeks buildings. Units cannot attack outside their range. Towers defend themselves automatically against ground and air.
- The practice opponent uses the same cards, costs, regeneration, placement restrictions, and unit limit. Its choices use a seeded random generator. It has full battlefield information, as does the player.

| Card | Cost | Role |
|---|---:|---|
| Hoplites | 3 | Three ground soldiers, each 145 health. |
| Atalanta | 3 | One mobile archer; attacks ground and air at range. |
| Minotaur | 5 | A tough building-seeking melee attacker. |
| Medusa | 4 | Ranged damage and a temporary movement slow; can target air. |
| Heracles | 5 | Tough ground fighter whose club also damages nearby ground enemies. |
| Hydra | 6 | Slow, extremely durable melee beast able to target air. |
| Harpies | 3 | Two fast flying attackers, immune to ordinary ground-only melee attacks. |
| Thunderbolt | 2 | Radius 1.55, 130 damage to enemy troops, 65 to enemy buildings. |

All names, costs, balance values and special effects above describe this implementation. They are not a claim of mythological accuracy or a reproduction of another game's unit balance.

## Integration contract

`session.gd` extends `RefCounted` and never imports scenes or Nodes. `new_game(seed_value = 42)` resets the simulation; `tick()` advances exactly 0.1 seconds. The interface accumulates real frame time and calls fixed ticks only while playing. Pausing means withholding ticks.

`snapshot()` deep-copies all public state: revision, elapsed, time_remaining, overtime, crowns, energy, hand, next_card, units, towers, recent events, phase, and winner. Player is side 0, starting south at positive z. Opponent is side 1. Winner is -1 while playing, 0/1 for a winner, or 2 for a draw. `catalog()` returns independent card data. `deploy(slot, Vector2(x, z), expected_revision = -1)` validates and applies one action atomically; `preview_deploy(slot, position)` performs the identical player validation without mutation. Both return `{ok, error}`. Rejected actions do not spend energy, rotate cards, emit events, or change revision.

Private mutable state belongs solely to the session. Rendering must never directly edit it. Tests may construct explicit private fixtures to prove unusual end conditions. Match replay/save, command logs, multiplayer synchronization, collision avoidance, polished animation and sophisticated bot strategy are future work. The combat loop uses deterministic iteration order, so damage within one fixed step is resolved in unit order rather than simultaneously.

## Verification

Run `Godot_v4.3-stable_win64_console.exe --headless --path . --script games/olympus_arena/test_arena.gd`. The suite checks atomic illegal actions, snapshot isolation, read-only previews, costs and regeneration, deck rotation, bridge crossing, tower combat, air immunity, Medusa slow, spell radius and tower damage, normal and overtime wins, temple destruction, fixed-seed bot determinism, and finished-state immutability. A full arena UI still requires native rendering and input checks owned by the integration task.
