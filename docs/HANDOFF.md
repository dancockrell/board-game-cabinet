# Board Game Cabinet handoff

Updated 2026-09-07. Repository: [dancockrell/board-game-cabinet](https://github.com/dancockrell/board-game-cabinet), private.

## First authored thrust animation

Hoplites now play a provisional four-frame thrust from exact authoritative hit events. Uneven source layout is handled by per-frame crops/pivots and two neighbour masks. Source pixels are unchanged. Scale returns to normal after recovery; hit and attack event IDs are tracked separately. Native study reviewed through draw/contact/recovery and native legal-match capture confirmed ten actor-frames using the attack clip. The capture began at 6.9 seconds, used two legal deployments, and ended at 12.9 seconds; outputs/Hoplite-Thrust-Live.mp4 and Hoplite-Thrust-Study.mp4. Earlier fixed-time captures contained zero thrust frames and were not accepted as animation evidence.

Validation: 11 headless and 25 native sprite checks, 43 native board checks, 64 native model checks, 55 native app checks passed. Important limitation: only a right-facing thrust exists and currently plays for every Hoplite attack, including upward targets. Directional correctness, idle-to-windup transition, locomotion and rest of roster remain unfinished. This is an intermediate animation hookup, not final art acceptance. Windows checkpoint predates it.

## Attack source identity

Hit events now include source_id, source_type and target_id from the authoritative simulation. Attack feedback targets that exact unit; it no longer chooses the nearest friendly replica. Missing sources and tower attacks cannot animate nearby troops. Native regression includes a closer neighbour and separate tower/missing-source events. 775 arena-rule checks and 41 native board checks pass. New thrust pose sheet is preserved as a candidate only; see HOPLITE_POSE_RESERVE.md for layout and scale defects. Latest Windows checkpoint predates this source change.

## Destroyed building increment

Zero-health towers now switch to matching authored rubble instead of compressing the intact shrine. Repeated dead snapshots retain the current sprite/material; restoring a tower restores the intact clip and removes the chroma material. Authoritative coordinates and scale remain unchanged. Initial checkerboard output was rejected; built-in generation corrected its background to saturated magenta. The source is preserved unchanged, and an opt-in clip shader discards only strongly saturated magenta. Native close-up reviewed in outputs/Pixel-Shrine-Ruins.png; this is static rubble, not animated collapse. Board transition/reset checks, native sprite/app checks and 773 arena rules checks pass.

## Pixel buildings increment

The six combat structures now use an original transparent owl-shrine sprite, replacing runtime procedural architecture. Main temples use a larger scale; both teams retain narrow coloured footprint borders. Clip metadata anchors the lowest step; a presentation-only forward offset places the step at the footprint edge without moving authoritative tower coordinates. Native close review caught and corrected step clipping. Source PNG is preserved unchanged with provenance in assets/olympus_arena/buildings.

Validation: 38 native board checks (including sprite resource, authoritative origin, destruction and reset), 64 native model checks, and 55 native app checks passed. A 180-frame match capture completed before the final step-anchor adjustment; final adjusted close-up is outputs/Pixel-Shrine-Footprint.png. This is static building art: distinct main-temple artwork, mid-damage states and ambient animation remain unfinished. Rubble now replaces the temporary vertical compression, as described above.

## Pixel battlefield increment

Authored limestone paving now replaces procedural field/lane stone through a shared ShaderMaterial Resource. Existing footprints, ground picking and simulation are unchanged. Source and provenance live in assets/olympus_arena/terrain. Native match review exposed excessive brightness; field/lane tints were reduced. Validation: 35 native board checks and 55 native app checks passed; final 180-frame native capture completed at 30 fps with six legal placements, through 44 seconds of authoritative match time. Still inspected at outputs/Olympus-Pixel-Paving-Match.png. This is the first terrain material conversion, not a completed pixel environment; bridges, borders, vegetation, water and other units still need conversion; temples now use the sprite increment above.

## Live pixel integration checkpoint

[Pixel Hoplites now run in matches](PIXEL_LIVE_CHECKPOINT.md), reacting to authoritative health loss. Windows interim build smoke passed. Static locomotion, fixed facing, missing attacks and legacy rest of roster remain visible work; do not confuse this with the goal being complete.

## Active delivery goal

[Make the playable pixel-art Greek arena game](ACTIVE_GAME_GOAL.md) is the user-requested active goal. First event-driven guard clip is implemented and tested in native diagnostic; actual match integration is implemented; locomotion, attack and roster conversion remain.

## Latest pose production

[Hoplite pose reserve](HOPLITE_POSE_RESERVE.md): 18 varied static candidates, six inspected in the native chroma preview. Shared 2D sources and rejected-output findings preserved. No finished animation implied.

## Latest implementation and shared archive

See [pixel implementation checkpoint](PIXEL_IMPLEMENTATION.md): old art/model workshop preserved in shared storage; new sprite clip Resource and camera-facing renderer implemented and tested. Static front/back native preview exists; Hoplites run in matches, while full roster migration remains pending coherent animation.

## Current visual authority

The user selected pixel art and elevated gameplay perspective from two supplied references. [Pixel art direction](PIXEL_ART_DIRECTION.md) is now the visual authority. Realistic miniature repair below is historical; the next visual slice is one directional Greek sprite tested in the arena. References are not runtime assets or instructions to build their western game.

## Current priority: zero-budget shared reuse

See [Olympus reuse checkpoint](OLYMPUS_REUSE.md) and its linked shared strategy. DR Companion and Pirate Island take priority. Reuse existing art; only verified free guided generation is allowed. The generated-model experiment below is historical source evidence, not the current production plan.

## Historical model method

See [Hoplite source reuse trial](HOPLITE_SOURCE_REUSE.md): existing textured source posed and compared in the arena. It is a review candidate; open weapon grip and missing clips prevent live admission. No paid work.

## Model surface pass

Cloth and bronze now reuse four existing CC0 Poly Haven normal/roughness maps from the shared library. See `assets/olympus_arena/materials/miniature-surfaces/provenance.json` for source URLs and hashes. Resource materials use local triplanar mapping so texture follows animated parts without requiring new UVs. Cloth applies to capes and hoplite linen; bronze applies to the existing primary armor palette. Team colors and skin remain unchanged. Native roster inspection shows a subtle surface improvement, not a replacement for authored shapes. No generation or paid work.

## Latest playable polish checkpoint

See [free inlay and hand polish](OLYMPUS_INLAY_CHECKPOINT.md). Current runtime source is `c5d7e5e`: quiet owl floor mosaics, slimmer card framing and readable unaffordable cards. The stage has 651 nodes; 113 stage checks and 55 native app checks pass. A six-second legal-play capture and Windows export launch were verified. These are targeted presentation checks, not a new full-match balance acceptance or complete cabinet regression.

No paid generation was used. One image was generated through Magnific's visibly confirmed Generate Unlimited browser button. Do not use headless generation or generate models. The figures remain below the desired visual standard; reuse strategy remains current authority.

## Previous art direction: replace procedural production method

The user rejected the sanctuary models as clay-like and explicitly requested properly authored assets. The procedural checkpoint below is historical implementation evidence, not an accepted quality baseline. Further primitive-detail roster passes are superseded by the [generated 3D workflow](GENERATED_3D_WORKFLOW.md): reference design, dedicated textured-mesh generation, multi-angle inspection, modeling cleanup, rigging and native admission. Begin with one Hoplite and one temple; do not batch the roster before this method passes review.

## Historical integrated sanctuary checkpoint

The user specifically requested much better buildings and parallel model work. The arena now uses complete Doric architecture in `presentation/olympus_architecture.gd`: enclosed cellae, recessed entrances, three-step bases, four/eight fluted columns with entasis and capitals, solid pediments, carved frieze details, overlapping pan tiles, raised cover tiles and ridge caps. Heights remain around 2.3 arena units so the gameplay camera and troop visibility retain their existing contract. `tools/capture_olympus_architecture.gd` renders a close study using the actual runtime buildings.

Five units now use shaped profile/tube mesh builders: Hoplite and Minotaur in `olympus_sculpt.gd`, Atalanta in `olympus_archer.gd`, and Hydra/Harpies in `olympus_creatures.gd`. Atalanta has a green hunting chiton, natural head proportions, bow, quiver and strapped footwear. Hydra has separated sinuous necks and wedge-shaped reptile heads. Harpies have adult anatomy and closed, overlapping feather meshes. The final visual review found and fixed inward-facing feather normals; `test_olympus_creatures.gd` guards this specific defect. Heracles and Medusa remain the oldest and weakest figure constructions and are the next modeling priorities.

Current checks: 773 arena rules; 35 native board; 90 stage geometry/budget; 63 full-roster model; 16 creature; 45 native app (47 with captures); 25 combat effects; 11 HUD effects; 48 audio. The full local cabinet regression passed, followed by the targeted creature regression after the feather winding correction. Existing chess and Ninth Gate tests remain green. Native building and roster studies are staged asset reviews; the six-second legal-play motion fixture is separate gameplay evidence. All assets are original code-built geometry and existing project artwork, with no newly imported third-party models.

The next parallel art wave should give one owner Medusa, one Heracles, and one tower damage/collapse presentation. Preserve `Figure` and all direct animation pivot names, authoritative replica roots, snapshot-driven health, and existing gameplay coordinates. Each owner should produce a native close study, a gameplay-distance review, meaningful model lifecycle checks, and one scoped commit before coordinator integration. The `work/` folder is ignored by Godot and Git; keep experiments there and only ship admitted runtime assets.

## Start here: current request

**Build a Clash Royale-style real-time arena battler with our Greek heroes and monsters.** Keep the familiar two-lane, three-tower, four-card-hand, regenerating-elixir loop. The user explicitly asked for direct implementation without more scenario design or extended deliberation. See [Olympus Arena](OLYMPUS_ARENA.md).

The previous Heaven-and-Hell setting, invented commanders, Ninth Gate scenarios, Greek rescue adventure, and simultaneous-turn proposal are superseded. They remain historical source work, not the active product brief. Go, Xiangqi, and checkers were earlier selections but are not part of this implementation pass.

Use original Greek characters and presentation assets. Preserve the existing wooden chess game. Do not build a broader all-games framework or add commercial progression, accounts, or network services to this first local prototype.

## Current polish pass (2026-09-05)

The follow-up sanctuary iteration replaces the Hoplite and Minotaur assembly with explicitly shaped mesh profiles in `presentation/olympus_sculpt.gd`. Hoplite now has a Corinthian helmet, anatomical cuirass, fitted greaves, folded linen, curved owl-emblem shield, and arm-attached spear/shield. Minotaur has a longer bull muzzle, swept tapered horns, fur mantle, split hooves, and a forged axe attached to its animated arm. Atalanta wears green, Medusa purple, and Heracles has a defined beard. Team bases now have stone tops with thin colored rims. These are original code-built miniatures, not imported production sculpts or rigged GLBs.

The stage now uses varied rectangular stone courses with hairline joints, 48-piece mosaic borders, asymmetric coastal outcrops and finer water ripples. The play camera is slightly closer. Health bars use stable unlit colors and do not cast rectangular shadows. The complete local regression passed; native board and complete-match app tests were rerun after the final health-bar change. Stage count is 785 nodes, under the existing 1000-node scenery gate. This is a geometry count, not a measured frame-rate guarantee.

The latest request is finer, more realistic art on the board and a better match. The diorama pass is implemented: chamfered masonry, weathered limestone and aged-bronze shaders, worn paving, nonperiodic dark coastal water, irregular plants and rocks, restrained temple colors, filmic lighting, and refined miniature proportions with tapered limbs and folded cloth capes. The [board-art contract](OLYMPUS_BOARD_ART.md) defines the current environment and gameplay-distance review target.

Minotaur now earns a doubled building strike after 2.4 units of its own travel. Its amber base cue persists while charged, and a HUD announcement explains the state. Hydra recovers 20 health after four seconds without damage, then 20 each subsequent second; all incoming damage interrupts recovery. These mechanics, events, and visual cues are driven by authoritative state. See the exact rules for details.

This checkpoint passed the complete `tools/verify.ps1 -Graphics` run: 773 arena rules, 35 arena renderer, 90 stage geometry/budget, 45 native app (47 with captures), 25 combat effects, 11 HUD effects, and 48 audio/music checks, plus the existing chess and Ninth Gate regressions. Native opening, staged miniature review, and sequential gameplay images were inspected. The motion fixture contains 180 native frames at 30 fps, covering match time 38-44 seconds without retiming. The figures remain procedural; the realism target is not complete until authored models pass the same camera review.

`tools/capture_olympus_roster.gd` produces an explicitly staged art lineup. `tools/capture_olympus_motion.gd` produces actual legal-play evidence. Do not substitute the lineup for gameplay evidence.

The user explicitly requested a much more attractive, modern presentation. Implemented: eight illustrated card portraits, a larger coastal 3D arena with carved paving and animated water, boats, gulls, pennants and embers, layered Greek shrines, seven richer procedural figurines, jointed walking/attack/wing/cape/neck animation, visual movement smoothing, placement ghosts, tactile card dragging, unit-specific attack effects, tower debris and smoke, reactive HUD alerts, a cinematic countdown, tactical practice opponent, deterministic crowd separation, and original synthesized combat sounds plus a quiet lyre-and-frame-drum score. Art prompt and provenance are in `assets/olympus_arena/ART-PROVENANCE.md` and `art-manifest.json`.

This is a stronger playable art prototype, not finished commercial character production. The next largest visual gain is authored, rigged low-poly characters matching the card portraits, with distinct attack anticipation, contact and recovery. Current meshes are assembled from primitives. Deterministic soft crowd separation respects banks and bridges, but it is not a full physics or steering system. Do not call this equivalent to a shipped Clash Royale presentation.

The visual authority remains the pure session. Replica roots equal authoritative coordinates; smoothing is confined to the child figure. Preview ghosts stay outside the replica map. Audio consumes deduplicated snapshot events and tower health transitions. No presentation feature changes combat results.

New boundaries: `presentation/olympus_stage.gd` and two shaders own scenery; `presentation/olympus_ambient_life.gd` owns boats, birds, pennants and embers; `presentation/olympus_figurines.gd` owns miniature geometry and joint animation; `presentation/olympus_combat_fx.gd` and `olympus_hud_fx.gd` consume authoritative events; `presentation/olympus_audio.gd` owns synthesized sounds and music. `tools/capture_olympus_motion.gd` records native frames from legal play at a fixed simulation cadence. See [the art production contract](OLYMPUS_ART_PIPELINE.md) before replacing procedural characters. Do not use a staged screenshot as evidence of match balance or performance.

The previous short slices for crowd separation, combat effects, ambient arena life, tactical bot behavior, countdown, music and HUD reactions are complete. The next parallel polish slices are:

| Wave | Owner/files | Output | Dependencies and validation |
| --- | --- | --- | --- |
| 1 | Character artist: `work/art-source/olympus/hoplite/`, then `assets/olympus_arena/models/hoplite/` | Authored hoplite with all required clips and material IDs | Follow `OLYMPUS_ART_PIPELINE.md`; review alone, in a trio, and against both team accents |
| 1 | Technical artist: new `presentation/olympus_model_loader.gd` | GLB loader with clip validation and procedural fallback | Use a deliberately missing fixture first; no renderer edit until fallback tests pass |
| 1 | Performance owner: new profiling scene/report | 8-, 16- and 32-unit native GPU/CPU measurements with effects | Use current game camera and active water/ambient life; record hardware and frame percentiles |
| 1 | UX owner: app tests and a review note | Keyboard, mouse, drag and 1000 x 700 readability audit | Substantiate issues before app edits; verify countdown and invalid-placement recovery |
| 2 | Character artists: separate folders for Atalanta, Minotaur and Medusa | Three approved models, one owner per folder | Starts only after hoplite pipeline admission; shared skeleton changes have one owner |
| 2 | Creature artists: separate folders for Heracles, Hydra and Harpies | Three approved models with creature-specific clips | Hydra must preserve three-head separation; Harpies must remain distinct as a pair |
| 2 | Renderer owner: `olympus_arena_board.gd` | Admit approved models one at a time with procedural fallback | No batch integration; run authoritative-root, event, cleanup and crowd captures after each |
| 3 | Coordinator: app, exports, docs | Mix review, complete-match capture, regression, Windows build and release | Requires 773 rules checks plus all native presentation suites and exported executable smoke test |

## Repository status

| Component | Status and evidence boundary |
| --- | --- |
| Wooden chess | Existing playable game: pure chess rules, wooden 3D board and chips, mouse/keyboard controls, history, undo, save/load, practice opponent, factual tutor context, and PGN export. Preserve its tests. |
| Olympus Arena | Playable prototype with a weathered diorama, refined procedural miniatures, charge/recovery abilities, illustrated roster, coastal life, combat feedback, tactical local opponent and layered audio. Current evidence: 773 rules, 35 native renderer, 90 stage geometry/budget, 45 native app (47 with captures), 25 combat-FX, 11 HUD-FX and 48 audio checks. Full chess and parked Ninth Gate regressions pass. Refresh the export manifest for every new package. |
| The Ninth Gate | Parked historical prototype with rules, 3D source work, and an older 2D prerelease. Its setting and play loop are not the current direction. |
| Go / Xiangqi / checkers | Previously selected future games; not implemented and not active parallel work. |

The [successful chess checkpoint](https://github.com/dancockrell/board-game-cabinet/actions/runs/33967027800) and [older Ninth Gate CI](https://github.com/dancockrell/board-game-cabinet/actions/runs/33969164766) are historical evidence only. The [Ninth Gate prerelease](https://github.com/dancockrell/board-game-cabinet/releases/tag/ninth-gate-prototype-2026-09-05) is not an Olympus build. For a new download, inspect its release notes and manifest for the packaged source commit. Never treat earlier CI or an older executable as validation of new arena code.

## Current controls and limitations

The main project opens Olympus Arena. Press **BATTLE** to begin; the timer waits for this action. Select a card with a click or **1–4**, then click the blue half to deploy troops, or drag the card onto the board. Thunderbolt targets either half. **Escape** clears selection. **Space** or **Pause / Resume** pauses/resumes. **Restart** requests confirmation before replacing the match; **REMATCH** starts again from the result screen. A chess-table button preserves access to chess.

The fixed eight-card deck has no editor. This is local practice against a tactical deterministic opponent that defends pressure, builds supported pushes and chooses useful spell targets while obeying its own hand and elixir. There are no accounts, network battles, progression, collection upgrades, or arena save/replay. Original procedural Greek models include joint and attack animation and sculpted details; they remain an art prototype rather than a completed authored character set. Soft unit separation is implemented; full local avoidance and formation steering are not. Refresh native gameplay/result captures, complete-battle checks and the Windows manifest after each integrated polish pass.

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



## Windows shrine checkpoint

Local package: workspace outputs/Olympus-Pixel-Shrines-Windows.zip, source dbf1b22. Native exported screenshot inspected and 90-frame smoke exited 0. Executable SHA256 78631C55C35F9829876C6ED0F2B3AFF182DA28319BC083B308BFFBDDCFD60027. Includes notices, provenance and build notes. Local artifact only, not a GitHub release; incomplete art and animation requirements remain.
