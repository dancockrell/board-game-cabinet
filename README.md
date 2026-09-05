# Board Game Cabinet

A playable Godot desktop chess table with a wooden board, round wooden chips, and burned-symbol shading. The app separates authoritative chess state from 3D presentation and uses reusable theme Resources so the simple static set can become a foundation for more sets and, later, other games.

The current build includes legal chess moves and special moves, turn handling, legal/capture/check/last-move indicators, four-choice promotion, SAN move history, undo, immutable position review, transactional save/load, a two-ply local practice opponent, and factual tutor context with candidate moves. Chips lift, slide, and settle; wooden taps can be muted. The board can be turned without changing logical positions or picking correctness.

The [production plan](docs/PLAN.md) contains the architecture, full acceptance gates, 35 original parallel slices, their delivery status, and practical next slices. [Verification notes](docs/VERIFICATION.md) separate automated coverage, inspected graphics, exported-app checks, and remaining product limitations.

## Run and controls

Tested on **Godot 4.3**, Windows, using the Compatibility/OpenGL renderer with an NVIDIA RTX 4070. Open `project.godot` in that Godot version and run the project, or run this from the repository root with Godot on your PATH:

```powershell
godot --path .
```

- Click a piece, then one of its legal destinations. Promotion opens a queen/rook/bishop/knight choice.
- Use the opponent selector for local play or the practice computer.
- **Undo**, **New**, **Save**, **Load**, and **Claim draw** operate on the authoritative session. The draw button is enabled when a supported current-position claim is available.
- **Turn board**, or **F**, changes viewing orientation. **Escape** clears selection.
- **‹** and **›** inspect recorded positions; **Live** returns to the current game. Review does not mutate the active position.
- **Explore a candidate move** requests a practice-level suggestion. **Wooden move sound** toggles move audio.

Save/Load uses one local save slot at `user://cabinet-chess-v1.json`. An invalid save leaves the active game intact. Presentation preferences are not persisted yet.

## Verify

From the repository root in PowerShell:

```powershell
./tools/verify.ps1 -Godot "C:/path/to/Godot_v4.3-stable_win64_console.exe"
./tools/verify.ps1 -Godot "C:/path/to/Godot_v4.3-stable_win64_console.exe" -Graphics
```

The first command imports the project and runs `test_chess`, `test_chess_oracle`, and `test_session` headlessly. `-Graphics` also runs `test_board` and `test_app` in the Compatibility renderer and needs a usable graphics session. The complete command passed on the tested Windows system.

The oracle fixture was generated with python-chess 1.11.2 and compares **960 positions and 23,179 legal moves**. The board suite passed **136 checks**. Application integration coverage includes mouse moves, the computer response, save and corrupt-load recovery, undo, castling, en passant, underpromotion, and position review. These checks establish specific behavior; they do not prove every chess position, universal dead-position adjudication, or complete product accessibility.

GitHub CI passed for the implemented checkpoint `35220cb`: [verification run](https://github.com/dancockrell/board-game-cabinet/actions/runs/33965654203). Check the latest repository run before assuming that result applies to later changes.

## Export for Windows

Install Godot 4.3's matching export templates through the editor's export-template manager. The checked-in **Windows Desktop** preset produces an x86-64 executable with its PCK embedded. From the repository root:

```powershell
New-Item -ItemType Directory -Force build | Out-Null
godot --headless --path . --export-release "Windows Desktop" "build/BoardGameCabinet.exe"
./build/BoardGameCabinet.exe
```

Replace `godot` with your quoted executable path and PowerShell's `&` invocation operator if it is not on PATH. The Windows export was built, opened, and captured on the tested machine. This preset is not code-signed; broader platform exports are not verified.

## Current boundaries

The computer is a local two-ply practice opponent, not Stockfish or a UCI engine connection. Tutor output provides position facts and heuristic candidates; expert tactical explanations and conversational coaching are pending. SAN is implemented, while PGN import/export is not.

Draw claims currently inspect the existing position. Claims based on announcing an intended next move are pending, as is generic dead-position detection beyond the supported material cases. Xiangqi remains an architectural target. Full keyboard board operation, persistent preferences, multiple save slots, and a complete accessibility review remain open. The branded effect is shader shading on the chip top, not physically recessed silhouette geometry.

## Design boundaries

- Rules and state are `RefCounted` objects. Core legality never depends on a Node.
- The session accepts moves, records history, and owns the position. The board renders that state and submits requests.
- Board/piece themes are Godot Resources. Appearance changes must preserve the position and legal moves.
- Chess is concrete first. Xiangqi will introduce intersection topology and its own rules without forcing chess assumptions into a universal base class.
- Computer and tutor adapters return identified, position-bound results. Obsolete responses are rejected and proposed moves revalidated.

See `AGENTS.md` before collaborating. Work in independently owned slices, stage only your files, and keep commits small. Inspect the actual running board when assessing visual changes.
