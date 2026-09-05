extends "res://ai/engine_adapter.gd"
## Small deterministic two-ply opponent. Intentionally labelled as practice strength.
const Rules = preload("res://games/chess/chess_rules.gd")
const VALUES: Dictionary = {"p": 100, "n": 320, "b": 330, "r": 500, "q": 900, "k": 0}

func analyze(state, revision: int) -> Dictionary:
	var candidates: Array = []
	var perspective: String = state.turn
	for move in Rules.legal_moves(state):
		var child = Rules.apply_move(state, move)
		var replies: Array = Rules.legal_moves(child)
		var score: int = 1000000
		if replies.is_empty():
			score = 100000 if Rules.in_check(child, child.turn) else 0
		else:
			for reply in replies:
				var leaf = Rules.apply_move(child, reply)
				score = mini(score, evaluate(leaf, perspective))
		candidates.append({"move": move.duplicate(), "score_cp": score})
	candidates.sort_custom(func(a, b): return a["score_cp"] > b["score_cp"])
	return {"revision": revision, "move": candidates[0]["move"] if not candidates.is_empty() else {}, "provider": "Local practice opponent", "depth": 2, "perspective": perspective, "candidates": candidates.slice(0, 3)}

static func evaluate(state, perspective: String) -> int:
	var score: int = 0
	for square in range(64):
		var piece: String = state.board[square]
		if piece.is_empty():
			continue
		var side: String = "w" if piece == piece.to_upper() else "b"
		var kind: String = piece.to_lower()
		var file: int = square % 8
		var rank_index: int = square / 8
		var center: int = int(14 - abs(2 * file - 7) - abs(2 * rank_index - 7))
		var value: int = VALUES[kind]
		if kind in ["n", "b"]:
			value += center * 3
		elif kind == "p":
			value += (rank_index if side == "w" else 7 - rank_index) * 7 + center
		score += value if side == perspective else -value
	return score
