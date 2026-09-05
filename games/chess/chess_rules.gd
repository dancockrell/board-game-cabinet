extends RefCounted
## Stateless chess rules. Call legal_moves before accepting an external move.

const KNIGHT := [Vector2i(1, 2), Vector2i(2, 1), Vector2i(2, -1), Vector2i(1, -2), Vector2i(-1, -2), Vector2i(-2, -1), Vector2i(-2, 1), Vector2i(-1, 2)]
const DIAGONAL := [Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]
const ORTHOGONAL := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]

static func side(piece: String) -> String:
	return "" if piece.is_empty() else ("w" if piece == piece.to_upper() else "b")

static func opposite(player: String) -> String:
	return "b" if player == "w" else "w"

static func _square(x: int, y: int) -> int:
	return y * 8 + x if x >= 0 and x < 8 and y >= 0 and y < 8 else -1

static func attacked(state, target: int, by: String) -> bool:
	var tx := target % 8
	var ty := target / 8
	var pawn_y := ty - (1 if by == "w" else -1)
	for dx in [-1, 1]:
		var sq := _square(tx + dx, pawn_y)
		if sq >= 0 and state.board[sq] == ("P" if by == "w" else "p"):
			return true
	for offset in KNIGHT:
		var sq := _square(tx + offset.x, ty + offset.y)
		if sq >= 0 and state.board[sq] == ("N" if by == "w" else "n"):
			return true
	for offset in DIAGONAL + ORTHOGONAL:
		var distance := 1
		while true:
			var sq := _square(tx + offset.x * distance, ty + offset.y * distance)
			if sq < 0:
				break
			var piece: String = state.board[sq]
			if not piece.is_empty():
				if side(piece) == by:
					var kind := piece.to_lower()
					if kind == "q" or (kind == "k" and distance == 1) or (kind == "b" and offset.x != 0 and offset.y != 0) or (kind == "r" and (offset.x == 0 or offset.y == 0)):
						return true
				break
			distance += 1
	return false

static func in_check(state, player: String) -> bool:
	var king: int = state.board.find("K" if player == "w" else "k")
	return king < 0 or attacked(state, king, opposite(player))

static func _add(moves: Array[Dictionary], start: int, target: int, promotes: bool = false) -> void:
	if promotes:
		for kind in ["q", "r", "b", "n"]:
			moves.append({"from": start, "to": target, "promotion": kind})
	else:
		moves.append({"from": start, "to": target, "promotion": ""})

static func legal_moves(state) -> Array[Dictionary]:
	var candidates: Array[Dictionary] = []
	for start in range(64):
		var piece: String = state.board[start]
		if side(piece) != state.turn:
			continue
		var kind := piece.to_lower()
		var x := start % 8
		var y := start / 8
		if kind == "p":
			var step := 1 if state.turn == "w" else -1
			var target := _square(x, y + step)
			var promotes := y + step == 0 or y + step == 7
			if target >= 0 and state.board[target] == "":
				_add(candidates, start, target, promotes)
				var double_target := _square(x, y + 2 * step)
				if y == (1 if state.turn == "w" else 6) and state.board[double_target] == "":
					_add(candidates, start, double_target)
			for dx in [-1, 1]:
				target = _square(x + dx, y + step)
				if target < 0:
					continue
				var victim: String = state.board[target]
				if (side(victim) == opposite(state.turn) and victim.to_lower() != "k") or (target == state.en_passant and victim == "" and state.board[target - step * 8] == ("p" if state.turn == "w" else "P")):
					_add(candidates, start, target, promotes)
		else:
			var directions: Array = KNIGHT if kind == "n" else (DIAGONAL if kind == "b" else (ORTHOGONAL if kind == "r" else DIAGONAL + ORTHOGONAL))
			for offset in directions:
				var distance := 1
				while true:
					var target := _square(x + offset.x * distance, y + offset.y * distance)
					if target < 0:
						break
					var victim: String = state.board[target]
					if side(victim) == state.turn or victim.to_lower() == "k":
						break
					_add(candidates, start, target)
					if victim != "" or kind in ["n", "k"]:
						break
					distance += 1
			if kind == "k":
				_castles(state, start, candidates)
	var result: Array[Dictionary] = []
	for move in candidates:
		if not in_check(apply_move(state, move), state.turn):
			result.append(move)
	return result

static func _castles(state, start: int, moves: Array[Dictionary]) -> void:
	var base := 0 if state.turn == "w" else 56
	if start != base + 4 or in_check(state, state.turn):
		return
	for kingside in [true, false]:
		var right := ("K" if kingside else "Q") if state.turn == "w" else ("k" if kingside else "q")
		var rook := base + (7 if kingside else 0)
		if right not in state.castling or state.board[rook] != ("R" if state.turn == "w" else "r"):
			continue
		var clear := true
		for file in ([5, 6] if kingside else [1, 2, 3]):
			if state.board[base + file] != "":
				clear = false
		var transit := base + (5 if kingside else 3)
		var destination := base + (6 if kingside else 2)
		if clear and not attacked(state, transit, opposite(state.turn)) and not attacked(state, destination, opposite(state.turn)):
			_add(moves, start, destination)

static func apply_move(state, move: Dictionary):
	var next = state.copy()
	var start: int = move["from"]
	var target: int = move["to"]
	var piece: String = state.board[start]
	var capture: bool = state.board[target] != ""
	if piece.to_lower() == "p" and target == state.en_passant and target % 8 != start % 8 and not capture:
		next.board[target + (-8 if state.turn == "w" else 8)] = ""
		capture = true
	next.board[start] = ""
	next.board[target] = piece
	if move.get("promotion", "") != "":
		next.board[target] = move.promotion.to_upper() if state.turn == "w" else move.promotion.to_lower()
	if piece.to_lower() == "k":
		for right in ("KQ" if state.turn == "w" else "kq"):
			next.castling = next.castling.replace(right, "")
		if absi(target - start) == 2:
			var rook_start := start + 3 if target > start else start - 4
			var rook_target := start + 1 if target > start else start - 1
			next.board[rook_target] = next.board[rook_start]
			next.board[rook_start] = ""
	for entry in [[0, "Q"], [7, "K"], [56, "q"], [63, "k"]]:
		if start == entry[0] or target == entry[0]:
			next.castling = next.castling.replace(entry[1], "")
	next.en_passant = (start + target) / 2 if piece.to_lower() == "p" and absi(target - start) == 16 else -1
	next.halfmove = 0 if piece.to_lower() == "p" or capture else state.halfmove + 1
	next.fullmove = state.fullmove + (1 if state.turn == "b" else 0)
	next.turn = opposite(state.turn)
	return next

static func outcome(state) -> String:
	if legal_moves(state).is_empty():
		return ("Checkmate — " + ("Black" if state.turn == "w" else "White") + " wins") if in_check(state, state.turn) else "Draw — stalemate"
	var minors: Array = []
	for square in range(64):
		var kind: String = state.board[square].to_lower()
		if kind in ["p", "r", "q"]:
			return ""
		if kind in ["b", "n"]:
			minors.append([kind, (square % 8 + square / 8) % 2])
	if minors.size() <= 1:
		return "Draw — insufficient material"
	var bishops_only := true
	for minor in minors:
		if minor[0] != "b" or minor[1] != minors[0][1]:
			bishops_only = false
	return "Draw — insufficient material" if bishops_only else ""

static func uci(move: Dictionary) -> String:
	var start: int = move["from"]
	var target: int = move["to"]
	return "abcdefgh"[start % 8] + str(start / 8 + 1) + "abcdefgh"[target % 8] + str(target / 8 + 1) + move.get("promotion", "")
