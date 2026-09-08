# Olympus Arena

Olympus Arena is a playable pixel-art Greek arena battler built with Godot 4.3. Deploy a four-card hand from an eight-card deck, defend two lanes and your central temple, and defeat a local computer opponent. The roster is Hoplites, Atalanta, Minotaur, Medusa, Heracles, Hydra, Harpies, and Thunderbolt.

**The active art direction is 2D only.** Characters and buildings use authored sprite sheets with explicit animation timing and pivots. The battlefield uses illustrated flat artwork. Orthographic placement supports the tactical camera; it does not authorize sculpted characters, volumetric scenery, PBR materials, or a 3D-model fallback. The old model builders and wooden-table/war-table presentations have been removed from the project and designated for deletion from their remaining external copies.

Press **BATTLE**, choose a card with a click or **1–4**, then click your half of the arena. Dragging a card also deploys it. Thunderbolt can target either side. **Space** pauses; **Escape** clears selection. The Menu saves Sound and Animate scenery preferences between launches; switching scenery off keeps combat animation active. Destroy the rival central temple to win immediately, or win on towers at the clock. The final minute doubles elixir regeneration; tied matches enter sudden-death overtime.

The current build includes directional attacks, walking or creature idle cycles, animated building collapse and unit departures, damage totals, card portraits matching the actual sprites, and an original synthesized score. Animation coverage and presentation still need polish. This is local play with a fixed deck, not online multiplayer or a progression system.

See the [current handoff](docs/HANDOFF.md), [arena guide](docs/OLYMPUS_ARENA.md), [exact rules](games/olympus_arena/RULES.md), and [2D art contract](docs/OLYMPUS_BOARD_ART.md). The handoff identifies the exact latest verified build and remaining work. Historical releases and screenshots do not describe the current art direction.

## Run

Open `project.godot` in Godot 4.3 and run, or run `godot --path .` from this directory. Windows builds use the Compatibility renderer. Extract the complete release ZIP and launch `Olympus.exe`.

## Verify

```powershell
./tools/verify.ps1 -Godot "C:/path/to/Godot_v4.3-stable_win64_console.exe"
./tools/verify.ps1 -Godot "C:/path/to/Godot_v4.3-stable_win64_console.exe" -Graphics
```

The graphical checks need a working native display. Passing automated checks establishes the covered rules and integration behavior; native gameplay recordings and exported-build checks establish separate evidence. Consult the handoff for current results and any hosted CI gate.

## Architecture and parked games

Rules and state are RefCounted objects. Presentation observes immutable snapshots and submits commands; it never independently changes unit health, positions, legality, or match results. Sprite themes are Resources with explicit atlas regions, frame durations, pivots, and provenance.

Chess legality, session history, save/load, notation, tutor and opponent foundations remain available as source and tests. Ninth Gate rules are retained as a parked experiment. Their old 3D scenes are removed, and neither is exposed as an active game. Future cabinet games must use the same 2D-only art direction. Go, Xiangqi and checkers are not implemented.

See `AGENTS.md` before collaborating. Own independent files, commit small changes, and inspect real native motion before claiming visual quality.

## Global 2D production decision

The 2026-09-08 owner decision applies to every project and shared pack: 2D artwork only. Delete retired 3D assets rather than preserve them for a future return. Reuse the shared 2D art folder across Olympus, Cattle Trail, DR Companion and Pirate Island. Physical removal outside this checkout is pending: automatic approval review rejected deletion with only "blocked by policy". Do not describe an inventory or a catalog exclusion as completed deletion.
