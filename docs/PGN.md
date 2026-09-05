# Chess PGN export

`games/chess/pgn.gd` provides `export_game(session, metadata = {}) -> String` as a pure, deterministic helper. It exports the current authoritative session and its complete played move history, including after undo. A separately displayed review position does not truncate the export.

The output has the seven standard roster tags, SAN movetext wrapped at 80 columns, and a matching final result token. Checkmate winners come from the rules and side to move. Other terminal session outcomes, including claimed and automatic draws, export as `1/2-1/2`. An available but unclaimed draw exports as `*`.

Defaults use a local event/site, generic White and Black names, unknown date and round. Optional metadata may replace Event, Site, Date, Round, White and Black; callers should supply a PGN date such as `2026.09.05` when known. Quotes and backslashes are escaped, control characters become spaces, and unknown tag names are ignored. The caller cannot override the authoritative result. No current date, account name, computer hostname or other personal data is collected.

This first version exports the standard starting position games supported by session save/load. It does not import PGN, export variations or tutor commentary, or support arbitrary starting FEN positions. Adding custom starts requires explicit SetUp/FEN tags and side/fullmove-aware numbering before expanding the session contract.

Run `tests/test_pgn.gd` with Godot headless. It covers both checkmate winners, ongoing games, castling, all promotions, claimed and automatic repetition, undo, escaping, line lengths, deterministic output and session immutability. Passing `-- --fixtures work/pgn-fixtures.json` also emits replay fixtures for an independent PGN parser to verify legal replay, move counts, results and final FEN.
