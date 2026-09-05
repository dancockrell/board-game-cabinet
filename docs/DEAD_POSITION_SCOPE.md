# Draw adjudication scope

The cabinet implements current-position claims and claims based on a declared legal next move. A declaration can establish a third occurrence or complete 100 halfmoves without a pawn move or capture. An accepted declaration ends play without appending the proposed move to played history. This follows the distinction between intended and completed moves in [FIDE Laws of Chess, Articles 9.2 and 9.3](https://handbook.fide.com/chapter/e012023).

The session records the declared move separately, validates it against its authoritative position, and checks any expected revision before accepting it. Save loading replays actual moves and revalidates the declaration. A forged or obsolete declaration cannot alter the current game. Undo follows the cabinet's existing policy: remove the last actual ply and clear the claim. This is an application convenience, not a tournament adjudication workflow.

## Conservative material detection

FIDE Article 5.2.2 defines a dead position by whether either player can checkmate through any legal continuation. This is broader than a material count and does not mean that a player can force mate. [Official rule](https://handbook.fide.com/chapter/e012023).

The current rules engine recognizes a conservative subset: bare kings; a single bishop or knight with the kings; and bishop-only material with all bishops on the same square colour. It separately recognizes stalemate, checkmate, and the session's automatic move-count and repetition draws.

It does **not** solve arbitrary dead positions involving blocked pawns or other position-specific constraints. Some dead positions may remain playable. Any future extension needs sound evidence that no legal mating continuation exists; an engine evaluation of zero or failure to find a forced win is not such evidence.

King and two knights versus king must not be classified as universally insufficient. As a constructive example, `7k/5K2/5NN1/8/8/8/8/8 b - - 0 1` is checkmate: the g6 knight checks h8, the white king covers g8 and g7, and the f6 knight covers h7. The rules regression tests cover both an ongoing two-knight position and this mating arrangement.

## Validation boundary

`tests/test_draw_claims.gd` covers intended repetition claims, stale and malformed requests, unchanged position/history, terminal locking, JSON round trips, forged save rejection, undo, and new-game reset. Clock threshold and capture-reset tests use isolated in-memory fixtures because production saves deliberately replay only from the standard initial position; these fixtures do not claim to prove a 99-halfmove persisted game. Full generic dead-position detection remains outside this slice.
