> Historical checkpoint: the former 3D presentation described below was retired on 2026-09-08. It is not an active art specification or evidence for the current build. Rules work remains retained. Follow [the 2D-only art contract](OLYMPUS_BOARD_ART.md) and [current handoff](HANDOFF.md).

# Board Game Cabinet: production plan

## Product goal and accepted direction

Build a modern digital board-game cabinet: a welcoming place to play, learn, and revisit games using tactile, readable sets. Chess is the first complete game. Xiangqi is the next architectural test, not a second game to implement before chess works.

The first set is a correctly constructed wooden board with round wooden chips. Each chip carries a chess symbol that reads as a brand burned into the wood. The simple silhouette is deliberate: premium materials, coherent proportions, readable marks, lighting, contact shadows, camera, and interaction must make the set convincing without sculpted characters. That investment becomes the common foundation for later static sets.

Accepted product decisions:

- Game state and rules are plain `RefCounted` objects, independent of Godot Nodes and scenes.
- The session owns the current position. Presentation submits requests and redraws from accepted session state.
- Board and piece themes are reusable Godot Resources. Switching appearance cannot change a position or a legal move.
- First delivery targets a desktop Godot 4.3 Compatibility renderer. The implemented checkpoint was tested on Windows with an NVIDIA RTX 4070 using OpenGL; broader platform coverage remains to be earned.
- The first computer player can be modest, but its identity and strength must be described honestly. A local heuristic is not Stockfish.
- Tutor facts must come from rules, recorded moves, or an identified engine result. A text interface is not evidence of analysis.

Provisional decisions are a single-board desktop screen, local single-device play, SAN for the displayed move log with UCI coordinate moves for replay, and a fixed oblique camera with a flip control. Online play, accounts, monetization, multiple simultaneous boards, generalized tournament administration, and animated fighters are outside this first implementation.

## Player loop and vertical-slice definition of done

Launch directly into the wooden chess table. Choose local play or the available computer opponent. Select a piece, inspect legal destinations, make a move, read the move log and status, and continue until a result. Undo or load a saved game without losing consistency. Request a factual explanation or candidate move, then return to the same authoritative position. Review the completed game through its recorded moves.

The completed first vertical slice must pass all of these gates. These are acceptance criteria, not a claim that the initial implementation has met them.

| Gate | Required behavior | Evidence |
| --- | --- | --- |
| Rules | Correct ordinary moves, captures, castling, en passant, all four promotions, check, mate, stalemate, and supported draw adjudication | Rule fixtures, established perft counts, and exceptional-position regressions |
| Full game | A player can finish a legal game against the selected computer opponent | Recorded manual full-game walkthrough with result |
| Turn ownership | Opponent work cannot accept input for the wrong side or apply an obsolete result | Undo/load/new-game while an analysis request is pending |
| Wooden set | Eight-by-eight board, light square at White's right, aligned chips, readable brands, no intersections or floating pieces | Actual runtime captures of initial, crowded middlegame, promoted, and flipped positions |
| Interaction | Selection, legal destinations, captures, last move, check, cancel, and promotion choice are distinguishable | Mouse and keyboard walkthrough; grayscale/high-contrast inspection |
| History | Accepted moves, turn, counters, undo, and position are consistent | Sequence replay and undo-to-start assertions |
| Persistence | Versioned saves load transactionally; invalid or unsupported data leaves the running game unchanged | Valid round trip and corrupt/illegal/unsupported-save fixtures |
| Computer | An identified opponent returns a legal move or a recoverable failure, never a stale move | Adapter tests and full-game exercise |
| Tutor | Shows truthful position facts and candidates with provenance and limitations | Rules/analysis fixture matched against displayed explanations |
| Presentation polish | Stable camera framing, tactile move feedback, restrained sound, readable UI, coherent contact shadows | Visual and listening review at normal play size |
| Review | A finished game's move sequence can be inspected without silently changing the active game | Review navigation and return-to-game exercise |
| Packaging | Fresh checkout imports, tests run, app launches, and desktop export opens | Reproducible commands, tested runtime, and export smoke record |

The first coding session has delivered a playable foundation plus several polish features; the current checkpoint is recorded below. Unchecked gates remain work even if the app launches and the first board looks attractive. Keep a dated verification record identifying actual test output, actual screenshot paths, what was inspected, and remaining defects. Do not equate a plan, a passing parser, or a headless render with a polished vertical slice.

## Implemented checkpoint — 2026-09-05

The application source checkpoint `35220cb` was pushed to GitHub, and its [CI verification run passed](https://github.com/dancockrell/board-game-cabinet/actions/runs/33965654203). Subsequent documentation commits do not expand that code-validation claim. The full local `tools/verify.ps1 -Godot <exe> -Graphics` command passed on Godot 4.3, Windows, NVIDIA RTX 4070 OpenGL. The Windows x86-64 export with embedded PCK was built, launched, and captured. See [VERIFICATION.md](VERIFICATION.md) for the coordinator's detailed evidence and limitations.

| Area | Delivered and checked | Remaining acceptance work |
| --- | --- | --- |
| Chess foundation | Plain state/rules; ordinary and special moves; check, mate, stalemate; perft/regressions; python-chess 1.11.2 oracle covering 960 positions and 23,179 legal moves | Generic dead-position adjudication beyond supported material cases; broader long-game coverage |
| Session | Validated requests, revisions, snapshots, SAN history, undo, transactional replay save/load, current-position and intended-move draw claims, persisted declaration metadata and automatic draw policy | Multiple save slots; expanded save migration policy |
| Board | Wooden 3D board/chips, branded shader appearance with restrained height-normal detail, Resource themes, logical picking, flip and move/check markers; 136 board checks passed | Recessed brand geometry is not implemented; further premium material and accessibility review |
| Input and review | Mouse and keyboard play in either orientation, modal keyboard promotion, immutable `snapshot_at()` review and Live return | Complete accessibility acceptance, including screen-reader review |
| Practice and help | Local two-ply computer, revision-bound results, factual position context, candidate suggestions | Stockfish/UCI integration, expert explanations, conversational tutoring |
| Feedback | Lift/slide/settle movement, muteable wooden taps, reduced motion and persisted sound/orientation/mode preferences | Complete listening/accessibility review; zoom remains transient |
| Test and release | Five headless and three native suites; rules, session, draw claims, PGN, board, app and controls; earlier checkpoint CI and Windows export smoke | Exhaustive chess proof is not claimed; full manual acceptance ledger and broader device/platform coverage |
| Cabinet roadmap | Game definition/topology seam and reusable static-piece theme system | PGN import, Xiangqi, additional admitted themes, animated character sets |

The implemented breadth exceeds a bare board prototype. It still does not close every acceptance gate above: teacher-quality explanations, generic dead-position policy, full accessibility acceptance, and the complete polish review remain explicit work.

## Continuation checkpoint — 2026-09-05

The continuation adds keyboard board play, modal promotion, persisted table preferences, PGN copy/export and intended-next-move draw declarations. The declarations are validated without playing the move and are retained in save metadata. The brand shader adds subtle height-normal detail; carved symbol geometry and final visual approval remain open.

The complete local eight-suite command passed for the continuation implementation, followed by native reruns of the keyboard/dialog and hint/opponent timing regressions. Normal/minimum window captures and the custom dialogs were inspected. The Windows build was rebuilt, launched, captured and exited successfully. Expanded headless CI passed at `0ef94e0`; exact evidence and remaining acceptance limits are recorded in `docs/VERIFICATION.md`.

| Completed handoff | Actual files and check |
| --- | --- |
| N1-01, N2-01 | `core/session.gd`, `tests/test_draw_claims.gd`, `app/main.gd`: current/intended claims, no played declaration move, save/load replay and invalid-claim atomicity |
| N1-03 | `presentation/brand.gdshader`: restrained height-normal shading; initial native inspection completed, final user visual admission remains |
| N2-02 | `app/main.gd`, `presentation/board_view.gd`, `tests/test_controls.gd`: arrows follow visible orientation; Enter/Space move; Escape clears; modal promotion supports keyboard |
| N2-04 | `games/chess/pgn.gd`, `tests/test_pgn.gd`, `app/main.gd`: copy/full-game file export; 176 default-run checks and 14 independently replayed fixtures |
| N3-01 | `core/preferences.gd`, `app/main.gd`, `tests/test_controls.gd`: persisted mute/orientation/reduced-motion/practice settings, corrupt-file fallback and runtime controls; zoom not persisted |

The next useful implementation lane is a real UCI adapter with timeout/cancellation recovery and verified engine identity. In parallel, finish a sustained manual game, human audio listening, focus/contrast/screen-reader review and user approval of the wood/brand appearance. Keep those acceptance checks distinct from the passing automated suites.

## Architecture and authority

Dependencies flow from the application to the session, game rules, and adapters. Presentation reads session snapshots and authored themes. Rules never import presentation, UI, audio, scene nodes, or process management.

```text
app/main.gd (input, UI, controller, opponent scheduling)
    -> core/session.gd (accepted state, revision, history, undo)
        -> games/chess/chess_state.gd
        -> games/chess/chess_rules.gd
    -> ai/ (computer and tutor boundaries)
    -> presentation/board_view.gd -> themes/ (Resource assets)
```

A board click identifies a logical square. The controller asks the session to play a complete move. The session checks legality against its current state, applies it through the rules, records history, increments its revision, and emits `changed`. UI and scene rebuild their derived view from the resulting state. Neither a piece mesh's transform nor a highlighted destination constitutes a move.

During animation the authoritative state is already settled. Animation may interpolate old-to-new transforms, but cancellation, undo, load, or theme change snaps/rebuilds to the newest state. Captures are reconstructed from state, including the off-destination removal in en passant. Castling moves both displayed pieces from the resulting board. No second piece-position dictionary becomes a competing source of truth.

## Folder and module structure

Paths below distinguish current contracts from planned modules. Empty abstraction folders are unnecessary until the corresponding slice starts.

| Path | Ownership and purpose |
| --- | --- |
| `project.godot`, `app/main.tscn` | Project boot, window, renderer, root scene; integration owner |
| `app/main.gd` | Initial screen, input flow, status/history controls, scheduling; integration owner |
| `core/preferences.gd` | Versioned local mute, orientation, reduced-motion and opponent preferences; separate from game state |
| `core/session.gd` | Single authority for position, legal requests, snapshots, revisions, undo, saves |
| `games/chess/chess_state.gd` | Plain position value and FEN parsing/serialization |
| `games/chess/chess_rules.gd` | Move generation, attack detection, immutable application, results, UCI |
| `games/chess/chess_rules.gd` notation helpers | Implemented SAN formatter and UCI codec |
| `games/chess/pgn.gd` | Pure standard-start PGN export; full accepted history and authoritative result |
| `ai/` | Computer and tutor services; process/protocol work stays outside rules |
| `presentation/board_view.gd` | Procedural board/chips, logical picking, position rendering, markers, flip |
| `presentation/board_view.gd`, `presentation/move_audio.gd` | Implemented lift/slide/settle transitions and muteable wooden sound response |
| `themes/` | BoardTheme/PieceTheme Resource definitions and authored set assets |
| `tests/` | Headless rule/session/adapter fixtures and integration checks |
| `docs/` | This plan, verification evidence, design decisions, future art admission records |
| `assets/` future authored content | Admitted textures, symbols, sounds, and licenses; no uncurated generation dumps |

## State and rules contracts

The initial chess implementation intentionally has a concrete, small API:

| Contract | Shape and meaning |
| --- | --- |
| `ChessState` | `RefCounted`; 64 board strings, empty `""`, uppercase White, lowercase Black; a1 = 0, h8 = 63 |
| State fields | `turn` is `"w"`/`"b"`; castling rights string; en-passant square integer or sentinel; halfmove and fullmove counters |
| State construction | `initial()`, `from_fen()`, `to_fen()`, `copy()`; copies must not share a mutable board array |
| Move | Dictionary with integer `from`, integer `to`, and `promotion` `""` or `"q"`, `"r"`, `"b"`, `"n"` |
| `ChessRules` | Static `legal_moves`, `apply_move`, `in_check`, `outcome`, and UCI representation |
| Session | Current position, accepted move history and position snapshots; `changed` signal and monotonic revision |

Generated moves are candidates until legality filtering proves the mover's king remains safe. Attack detection is distinct from legal-move generation: pawns attack empty diagonals, kings attack adjacent squares, and castling must test attacked transit squares. Low-level move application may assume a generated move; every external request must go through the validating session boundary.

The initial `core/game_definition.gd` Resource identifies a game and describes its board dimensions and cell/intersection placement. Its eventual definition can also select starting-state construction and rules, describe piece roles, and declare notation/save formats. An eventual game-neutral controller needs only legal actions, action submission, side-to-act, outcome, and presentation descriptors. Introduce that interface when a second game's actual needs can challenge it. Do not make chess's 64-square array, kings, castling, promotions, FEN, or alternating two-side assumptions universal base-class requirements.

## Chess implementation plan

1. Establish copy-safe positions and FEN fixtures. Validate board dimensions, piece alphabet, kings, side, castling fields, counters, and en-passant representation at the external boundary. Distinguish structural validity from a claim that a position is reachable in a legal game.
2. Generate pawn, knight, bishop, rook, queen, and king moves; separate attack maps from moves; filter self-check.
3. Implement castling rights updates for king/rook moves and rook captures, attacked-transit restrictions, en passant including discovered check, and four promotion choices including captures.
4. Resolve mate and stalemate from legal moves plus check. Add repetition accounting and move-count adjudication at the history-aware layer.
5. Prove core behavior using perft and focused fixtures before treating the UI as correctness evidence.
6. Bind the session to the board and controls; exercise undo and replay through every special move.

Draw policy must remain explicit. Threefold repetition and the fifty-move rule are claims; fivefold repetition and seventy-five moves are automatic under standard chess rules, subject to mate precedence. A first interface may expose only implemented draw categories, but it must not label an unimplemented claim as an automatic draw. Dead-position detection is broader than a few insufficient-material patterns; document any supported subset and never use an overbroad heuristic to terminate a winnable game. Repetition identity includes side, castling rights, and relevant en-passant availability, not just piece placement.

## Xiangqi fit

Xiangqi demonstrates why visual cells and logical locations must be distinct. Its pieces occupy a nine-by-ten intersection lattice. The board has a river and palaces; generals, advisors, elephants, horses, cannons, and soldiers obey game-specific constraints. Cannon screens, horse legs, elephant eyes, palace limits, river effects, and facing generals belong to Xiangqi rules, never a chess flag collection.

When Xiangqi begins, create `games/xiangqi/xiangqi_state.gd` and `xiangqi_rules.gd`, then extract only the common session/controller contract proved by both games. Supply topology metadata for intersections, board bounds, labels, hit targets, and camera framing. Reuse chip geometry, branding/material layers, move feedback, selection semantics, and the adapter lifecycle. Provide game-specific position and notation codecs. Investigate and document the selected Xiangqi repetition/perpetual-check ruleset before claiming complete adjudication.

## Engine and tutor adapters

The implemented computer adapter accepts a copied state and produces a proposed legal move using a local two-ply search. The interface labels its practice strength; it is not Stockfish or a UCI connection. A stronger engine belongs in a replaceable adapter; do not pull process handles or UCI parsing into `ChessRules`.

Every asynchronous request carries game ID, request ID, position identity, and session revision. Undo, load, new game, mode changes, and another accepted move invalidate old work. On completion, compare the captured revision, current side, and game identity, then validate the proposed move against current legal moves. A failed, cancelled, timed-out, or illegal response produces a recoverable status and no state change. Stop/cancel is useful, but revision rejection remains necessary even when cancellation exists.

A future UCI adapter handles process startup, `uci`/`uciok`, `isready`/`readyok`, position synchronization, bounded search, `stop`, `bestmove`, timeouts, and shutdown. Parse principal variations and scores with their source position; distinguish mate scores from centipawns. Keep evaluation perspective explicit. Verify engine redistribution license, binary provenance, and platform availability before bundling.

The first tutor view can truthfully state side to move, whether a king is in check, legal-move count, material balance, and a heuristic candidate with its selection reason. Richer analysis records should include source (rules/local heuristic/identified engine), position identity, revision, candidate actions, score perspective, and optional principal variation. Explain “bad move” only when a defensible before/after comparison or tactical line supports it. A missing engine result is unavailable analysis, not an invitation to invent a mistake label. Natural-language services are optional consumers of verified facts, never rule authorities.

## Presentation and theme system

`BoardTheme` and `PieceTheme` are Godot Resources containing tunable dimensions, materials, colors, grain controls, symbol treatment, rim treatment, and marker styling. Resource authoring changes appearance; the same chess state and moves must survive a theme swap unchanged. Keep logical square coordinates separate from local-space layout and camera orientation.

The baseline board has 64 correctly alternating tiles, a restrained wooden frame, subtle edge treatment, consistent tile heights, and plausible thickness. White's home-right square is light in either camera orientation. Chips sit within their squares, have enough top surface for recognizable brands, and distinguish teams by both body value and symbol contrast. Grain scale should belong to a physical object rather than repeat conspicuously at each screen pixel.

A dark flat symbol is an acceptable early readability scaffold, but is not proof of a finished brand. Final marks need an impression of shallow indentation, darkened fibers, and restrained roughness around their edges without blurring the symbol at the normal camera distance. Review the chosen representation under the actual lights. The six roles must be identifiable without relying on height, elaborate shapes, or recoloring alone.

Render selection, legal quiet moves, legal captures, the last move, and check as separate treatments. Preserve symbol visibility and use shape/outline as well as color. Selection cancels cleanly on empty or nonactionable clicks. Promotion pauses for a deliberate queen/rook/bishop/knight choice. UI buttons should state their effect, show opponent work, and make undo/load failure recoverable.

Motion direction is restrained lift, slide, settle. Board flip updates visual mapping and picking together. Audio can add a soft wooden placement and capture cue, with volume/mute controls; no sound is required for understanding state. Keyboard navigation, focus visibility, scalable text, and reduced motion are required polish work, not inherent properties of a 3D board.

Required visual anchors are real runtime captures of the starting board, crowded middlegame, a selected piece with legal/capture marks, checked king, promotion choice, and flipped table. Record what each capture validates. A screenshot approves only its visible state; animation and sound require their own runtime review.

## Save/load, history, and notation

The session records accepted moves alongside position snapshots for immediate undo. Serialization should use a versioned envelope: schema version, game ID, starting position in that game's codec, accepted move sequence, optional expected final position, and presentation preferences separately. Save engine configuration by name/settings, never a live process or transient pending request.

Load into temporary state. Validate schema/version/game, parse the starting position, replay every move legally, and compare any final-position assertion. Only after every check succeeds replace the session, rebuild snapshots/repetition accounting, advance revision, and emit one change. A failed load preserves the previous session. Write through a temporary file and replace the destination only after successful serialization where the platform permits. Handle unreadable files and future versions with plain recovery messages.

UCI strings such as `e2e4` and `e7e8q` provide the unambiguous replay format. The implemented `ChessRules.san()` formats the displayed move history with legal context for disambiguation, captures, castling, promotion, check, and mate; `GameSession.history_san()` returns the accepted notation. Review uses copied `snapshot_at()` positions and cannot mutate the active game. The pure `games/chess/pgn.gd` helper now exports standard-start games with seven roster tags, escaped metadata, wrapped SAN and an authoritative result. Copy/export always uses the full live game even while reviewing an earlier position. PGN import and arbitrary starting-position export remain future work; see [PGN.md](PGN.md). Intended-move draw declarations are save metadata, not an extra played move.

## Testing and release evidence

Run headless Godot tests independent of scene startup. Known initial-position perft totals are 20, 400, 8,902, and 197,281 at depths one through four. Use the lower depths for a fast loop and the deeper check as a release gate; include a castling-rich established fixture to avoid merely proving starting pawn moves. Test pinned pieces, king adjacency, illegal castling out of/through check, missing rooks, captured rook rights, en-passant discovered check, underpromotion, mate/stalemate, counters, and copy isolation.

Session tests cover rejected moves causing no mutation, history count and FEN agreement, undo across castling/en passant/promotion, game-over behavior, legal replay, bad-save transactionality, and stale computer results after undo/load/new game. Adapter tests inject fixed legal, illegal, delayed, and failed responses. Test tutor outputs against fixture facts and provenance.

Headless import detects parse/resource issues. Actual graphics startup detects material, picking, font, camera, and rendering issues. Visually inspect captures at the gameplay window size and exercise both orientations. A desktop export smoke is separate from editor launch. Record what was run and the exact runtime version; missing checks remain pending.

## Coordination: parallel ten-minute slices

Each row is an approximately ten-minute unit of focused implementation or investigation, not a promise that an uncertain integration is finished in ten minutes. Stop a slice at its stated output/check, commit only owned files, and hand back evidence plus unresolved issues. If the check fails, carry a focused follow-up slice rather than silently enlarging scope. Do not push or stage another agent's edits.

One integration owner controls `project.godot`, `app/main.gd`, `app/main.tscn`, and `core/session.gd`. Within each wave, assign a file to only one agent. Shared-contract changes must be announced before they land. Adjacent edits to one source file run serially in its ownership lane even when another lane is still working. Test authors may work concurrently in distinct test files using the frozen contract. Integrate each wave, import, run relevant tests, and commit the integration before starting consumers of changed interfaces.

### Delivery map and next handoffs

The original slice IDs below remain useful ownership contracts. Several implementations were consolidated into existing modules instead of creating every predicted helper/test file. Use actual files in this delivery map when continuing the work.

| Original slices | Current disposition | Actual implementation / evidence |
| --- | --- | --- |
| W0-01–05, W1-01–05, W2-01–05 | Delivered foundation scope | Project, state/rules, themes, session, local opponent and tutor; state/rules fixtures consolidated in `tests/test_chess.gd` |
| W3-01–05 | Delivered integration scope | Picking and interaction; special-move tests in `test_chess`; persistence fixtures in `test_session`; runtime flows in `test_app` |
| W4-01, W4-05 | Delivered | `core/session.gd`, `app/main.gd`; valid/corrupt save and computer integration checks |
| W4-02 | Implemented shader/material pass; ongoing visual admission | `presentation/wood.gdshader`, `presentation/brand.gdshader`, themes and captured runtime board; no recessed brand mesh |
| W4-03, W4-04 | Covered through consolidated suites | Session/application opponent guards plus rule/perft/oracle suites; check dedicated future UCI timeout/cancellation fixtures when that adapter exists |
| W5-01, W5-03 | Implemented | Promotion UI and `board_view.gd` lift/slide/settle; underpromotion and state synchronization application coverage |
| W5-02, W5-05 | Implemented supported policy | Repetition identity, current-position and intended-next-move claims, automatic draws, declaration save validation; generic dead-position work remains |
| W5-04, W6-03 | Keyboard/reduced-motion implementation delivered; accessibility admission open | Native keyboard navigation and promotion in both orientations; preferences and focus fixtures; full accessibility and screen-reader review remain |
| W6-01 | Implemented in existing rule/session modules | `ChessRules.san()`, `GameSession.history_san()` and immutable review; no separate `san.gd` required |
| W6-02 | Implemented feedback; review remains | Procedural wooden sound in `presentation/move_audio.gd`, mute toggle; dedicated listening acceptance still needs a record |
| W6-04 | Evidence recorded; full acceptance still open | Coordinator-owned `docs/VERIFICATION.md`; actual graphics/application captures and automated checks, without assuming every manual gate is closed |
| W6-05 | Delivered tested Windows checkpoint | `tools/verify.ps1`, GitHub CI, `export_presets.cfg`, built/launched/captured Windows executable |

The following handoffs record the next-wave contracts after the initial build. The continuation delivered N1-01, N1-03, N2-01, N2-02, N2-04 and N3-01 within the scope recorded below; the table preserves their original ownership and checks. N1-02, N1-04, N2-03 and N3-02 remain open. Keyboard implementation has practical native-test evidence but does not close the broader accessibility review. Keep all edits to session or application integration serialized under the coordinator.

| ID / wave | Owner and likely files | Dependencies | Expected output | Explicit validation |
| --- | --- | --- | --- | --- |
| N1-01 | Rules/test lane: `tests/test_intended_draw_claim.gd` | Current session contract | Fixtures for announcing a move that creates the third repetition or reaches 100 halfmoves; rejected claims preserve state | Fixtures fail for the known missing feature and distinguish current-position claims |
| N1-02 | Accessibility lane: `docs/ACCESSIBILITY_REVIEW.md` | Running exported app | Keyboard/focus/contrast/scale review with reproducible issues | Each finding identifies an exact interaction and checkable expected result |
| N1-03 | Presentation lane: isolated brand shader/material prototype | Current wooden theme | One restrained brand refinement with paired normal-distance captures | Six roles remain readable for both teams; captures explicitly distinguish shading from geometry |
| N1-04 | Adapter lane: new UCI protocol fixture/parser files in `ai/` and `tests/` | Existing adapter result contract | Bounded parser for readiness/bestmove/error transcript, no engine-bundling decision needed | Recorded valid/malformed/late transcripts yield explicit recoverable outcomes |
| N2-01 | Integration lane: `core/session.gd`, `app/main.gd` | N1-01 | Intended-next-move claim API and deliberate UI flow | N1-01 fixtures pass; claim transaction never silently plays a move |
| N2-02 | Integration lane, after N2-01: `app/main.gd`, `presentation/board_view.gd` | N1-02 | Keyboard square focus and select/submit/cancel flow | Complete legal move and promotion by keyboard in both orientations |
| N2-03 | Test/research lane: `docs/DEAD_POSITION_SCOPE.md`, dedicated fixtures | Existing material outcome logic | Precise supported and unsupported dead-position cases with counterexamples | No proposed heuristic incorrectly terminates a fixture with a possible mating sequence |
| N2-04 | Review/notation lane: new PGN codec and test files | Existing SAN and replay APIs | Small strict PGN export of a recorded game; bounded scope stated | Independent parser accepts exported headers, SAN sequence and result, recreating final FEN |
| N3-01 | Integration lane: preferences helper, `app/main.gd` | N2-02 merged | Versioned mute/orientation/reduced-motion preferences | Restart preserves valid preferences; corrupt preference file leaves defaults usable |
| N3-02 | QA lane: coordinator's acceptance evidence | Integrated next wave | Full manual game and listening/recovery checklist | Every observed failure becomes a bounded repair slice; no full-slice claim with unchecked gates |

### Wave 0: contracts and independent scaffolding

| ID | Owner / likely files | Dependencies | Expected output | Explicit validation |
| --- | --- | --- | --- | --- |
| W0-01 | Integration: `project.godot`, `app/main.tscn`, `AGENTS.md` | None | Bootable project, ownership rules, renderer target | Headless project import succeeds |
| W0-02 | Design: `docs/PLAN.md` | Product brief | This plan and acceptance ledger | Every requested topic and slice column present |
| W0-03 | Rules: `games/chess/chess_state.gd` | Frozen state contract | Initial position, deep copy, FEN codec | Round-trip start FEN; mutation of copy leaves original unchanged |
| W0-04 | Presentation: theme Resource scripts and baseline assets in `themes/` | Frozen presentation contract | BoardTheme and PieceTheme with documented defaults | Resources load in headless Godot |
| W0-05 | Tests: `tests/test_chess_state.gd` | State contract; runtime waits for W0-03 | Codec/copy/counter fixtures | Fixtures pass against actual state module |

### Wave 1: legal board and physical table

| ID | Owner / likely files | Dependencies | Expected output | Explicit validation |
| --- | --- | --- | --- | --- |
| W1-01 | Rules lane: `games/chess/chess_rules.gd` | W0-03 | Ordinary move generation and attack maps | Per-piece fixtures and initial legal count 20 |
| W1-02 | Presentation lane: `presentation/board_view.gd` | W0-04 | Board geometry, layout transform, camera-compatible bounds | Runtime capture shows 64 tiles and light h1 |
| W1-03 | Test lane: `tests/test_chess_rules.gd` | W0-03 and rules contract | Perft runner and check/pin fixtures | Reports explicit expected/actual counts; no scene dependency |
| W1-04 | Adapter lane: `ai/local_opponent.gd` | Frozen rules contract | Deterministic practice candidate from legal moves | Fixture move is in legal set; no-move returns empty |
| W1-05 | Integration lane: `core/session.gd` | W0-03 and rules contract | Session boundary, copied snapshots, revision/change signal | Illegal request preserves revision/state; legal request increments once |

### Wave 2: special rules, chips, and factual help

| ID | Owner / likely files | Dependencies | Expected output | Explicit validation |
| --- | --- | --- | --- | --- |
| W2-01 | Rules lane: `games/chess/chess_rules.gd` | W1-01 | Castling, en passant, promotions, check filtering | Special-move fixtures and initial perft depths 1–3 pass |
| W2-02 | Presentation lane: `presentation/board_view.gd` | W1-02 | Chips, six top brands, side treatment, `show_position` | Start capture has 32 readable, correctly placed chips |
| W2-03 | Tutor lane: `ai/tutor_context.gd` | W1-01 | Position facts and identified heuristic candidate | Check/turn/material fixtures match displayed data |
| W2-04 | Test lane: `tests/test_session.gd` | W1-05 | Session legality/history/revision assertions | Tests exercise success and rejected no-mutation paths |
| W2-05 | Integration lane: `core/session.gd` | W1-05 | Undo through snapshots and move log | Play/undo restores exact original FEN and empty log |

### Wave 3: playable integration

| ID | Owner / likely files | Dependencies | Expected output | Explicit validation |
| --- | --- | --- | --- | --- |
| W3-01 | Presentation lane: `presentation/board_view.gd` | W2-02 | Picking, square signal, legal/check/last-move markers, flip | Click known corners before/after flip; marks match requested squares |
| W3-02 | Integration lane: `app/main.gd` | W2-01, W2-05, W3-01 contract | Selection, legal move submission, status, history and undo controls | Mouse walkthrough includes capture and undo with matching FEN |
| W3-03 | Rules lane: `games/chess/chess_rules.gd` | W2-01 | Mate/stalemate and explicit supported outcome categories | Mate and stalemate fixtures produce different results |
| W3-04 | Test lane: `tests/test_special_moves.gd` | W2-01 | Castling transit, en-passant pin, underpromotion, rook-right regressions | All special fixtures pass; move generator never captures a king |
| W3-05 | Persistence lane: `tests/test_save_load.gd` | Frozen save envelope | Valid replay, corrupt and future-version fixtures | Tests assert previous state survives every rejected load |

### Wave 4: opponent and persistence integration

| ID | Owner / likely files | Dependencies | Expected output | Explicit validation |
| --- | --- | --- | --- | --- |
| W4-01 | Integration lane: `core/session.gd` | W2-05, W3-05 | Versioned transactional save/replay load | Save fixtures pass including illegal middle move |
| W4-02 | Presentation lane: `themes/` and distinct shader file | W2-02 | Grain scale, restrained brand/material refinement | Compare actual board captures at normal play distance |
| W4-03 | Adapter lane: `tests/test_opponent.gd` | W1-04 | Legal/empty/failed/delayed adapter fixture support | Stale request fixture is reproducible, not timing-dependent |
| W4-04 | Rules lane: `tests/test_perft.gd` | W3-03 | Deeper initial and established castling-rich perft checks | Exact expected totals pass; failures include divide output |
| W4-05 | Integration lane, after W4-01: `app/main.gd` | W4-01, W1-04, W2-03 | Save/load buttons, computer mode, tutor facts, request revision guard | Undo/new-game during pending opponent work changes no later position |

### Wave 5: close correctness and usability gaps

| ID | Owner / likely files | Dependencies | Expected output | Explicit validation |
| --- | --- | --- | --- | --- |
| W5-01 | Integration lane: `app/main.gd` | W4-05 | Explicit four-choice promotion UI | All four pieces promote through actual input flow |
| W5-02 | Rules lane: new `games/chess/repetition.gd` and its test | Stable state/rules | Correct repetition identity and policy helpers | Side/rights/legal-en-passant identity fixtures |
| W5-03 | Presentation lane: `presentation/move_feedback.gd` | W3-01 | Cancel-safe lift/slide/settle helper | Undo mid-animation ends on session state |
| W5-04 | Accessibility lane: `docs/ACCESSIBILITY_REVIEW.md` | W4-05 | Actual keyboard/contrast/focus/scale findings | Each issue has reproduction and visible acceptance check |
| W5-05 | Integration lane, after W5-01: `app/main.gd`, `core/session.gd` | W5-02 | Draw claims/automatic policy and clear UI | Claim availability differs from automatic adjudication |

### Wave 6: polish and release evidence

| ID | Owner / likely files | Dependencies | Expected output | Explicit validation |
| --- | --- | --- | --- | --- |
| W6-01 | Notation lane: `games/chess/san.gd`, `tests/test_san.gd` | Stable accepted move API | SAN formatter | Disambiguation, castle, capture, promotion, mate fixtures |
| W6-02 | Presentation lane: `presentation/audio_feedback.gd` and licensed sounds | W5-03 | Placement/capture feedback with mute support | Listening review plus muted game remains understandable |
| W6-03 | Integration lane: `app/main.gd` | W5-04 | Keyboard focus/navigation and reduced-motion controls | Keyboard-only move/undo/flip/promotion walkthrough |
| W6-04 | QA lane: `docs/VERIFICATION.md`, capture evidence | Integrated Wave 5 | Visual state captures and manual complete game | Each acceptance gate marked passed/failed/pending with evidence |
| W6-05 | Release lane: export preset and CI files; integration owner approves shared config | W6-04 | Repeatable import/test/export smoke procedure | Fresh checkout and exported executable launch successfully |

These waves deliberately contain serial rows within the integration lane. With four concurrent workers, the coordinator handles integration while rules, presentation, and tests/adapters advance independently. Reassign idle workers to a new owned test or documentation file; never have two workers repair the same script concurrently. A ten-minute timer bounds the handoff, not quality: report incomplete work honestly and carry it into a named next slice.

## Roadmap and milestone exits

**M0 — trustworthy foundation.** Bootable board, legal chess core, headless fixtures, session authority, clickable pieces, turn status, move history, undo, modest practice opponent, and factual tutor scaffold. Exit requires passing relevant tests and an inspected runtime view; this does not yet imply all first-slice acceptance gates.

**M1 — polished wooden vertical slice.** Close the definition-of-done table, including complete-game play, draw policy, deliberate promotion, save/recovery, accessible controls, sound/motion, review, and export. Iterate on branded marks and physical materials at gameplay distance. Admit the wooden set as the visual baseline only after review.

**M2 — static theme family.** Add one sharply different material set, such as ceramic or stone, using the same theme/data boundary. Run identical state/picking fixtures across both themes and compare readability, contact, symbol contrast, and feedback. Then author lacquer, brass, and other coherent sets. Store provenance and licenses with each admitted asset family; do not let theme packs override rules.

**M3 — cabinet and Xiangqi.** Add a restrained game chooser and persist each game's resume slot. Implement Xiangqi's actual topology and rules, then extract the minimum shared game interface supported by both games. Keep per-game notation, positions, adjudication, tutorial facts, and opponent adapters honest.

**M4 — stronger coaching and review.** Extend the existing SAN history and immutable review with a real engine, process cancellation, bounded analysis, evaluations with provenance, PGN import and richer export, and specific tactical explanations. Measure responsiveness and failure recovery. Do not gate ordinary local play on a network tutor.

**M5 — animated character sets.** Character models occupy the same logical piece roles and positions. A presentation event stream drives idle, selected, move, capture, defeat, and promotion sequences while the session remains authoritative. Each asset declares scale, footprint, attachment points, role/team identity, animation map, fallback static pose, and provenance. Long capture choreography must be skippable; interruption reconstructs the latest state. Establish framing, silhouettes, readability, and performance with one character pair before commissioning a full Battle-Chess-style set.

## Risks and next decisions

The largest early correctness risks are exceptional chess moves, draw-policy shortcuts, shallow copies, and accepting stale opponent responses. The largest presentation risks are unreadable top brands at the oblique camera angle, repetitive wood, insufficient side contrast, and UI markers hiding the simple pieces. Test and inspect these directly.

The next product decisions become concrete after the first runtime review: final camera range, brand representation, board/chip proportions, keyboard interaction, review layout, and whether a bundled engine is worth its distribution cost. Tune those against the playable wooden table. Do not delay the state/rules foundation while waiting for art choices.

