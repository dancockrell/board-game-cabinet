extends RefCounted
## Deterministic facts are usable by UI or a future language-model adapter.
## No positional or tactical explanation is invented from the shallow score.
const Rules = preload("res://games/chess/chess_rules.gd")
const Opponent = preload("res://ai/local_opponent.gd")

static func build(state, revision: int, history: Array) -> Dictionary:
	var legal: Array = Rules.legal_moves(state)
	var captures: Array[String] = []
	for move in legal:
		if not state.board[move["to"]].is_empty() or (state.board[move["from"]].to_lower() == "p" and move["to"] == state.en_passant):
			captures.append(Rules.uci(move))
	return {"game_id": "chess", "revision": revision, "fen": state.to_fen(), "side_to_move": state.turn, "in_check": Rules.in_check(state, state.turn), "legal_move_count": legal.size(), "legal_captures_uci": captures, "material_and_activity_cp_white": Opponent.evaluate(state, "w"), "last_move_uci": Rules.uci(history.back()) if not history.is_empty() else "", "limits": "Position facts only. The practice opponent searches two plies; its suggestions are not expert analysis."}

static func describe(context: Dictionary) -> String:
	var side: String = "White" if context["side_to_move"] == "w" else "Black"
	var text: String = "%s has %d legal moves." % [side, context["legal_move_count"]]
	if context["in_check"]:
		text += " Your king is in check; every highlighted move resolves it."
	if not context["legal_captures_uci"].is_empty():
		text += "\nLegal captures: %s. Check what your opponent can recapture." % ", ".join(context["legal_captures_uci"])
	else:
		text += "\nNo captures are available in this position."
	return text
