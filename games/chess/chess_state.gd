extends RefCounted
## Value state. Square zero is a1; uppercase pieces are White.

var board: Array = []
var turn: String = "w"
var castling: String = "KQkq"
var en_passant: int = -1
var halfmove: int = 0
var fullmove: int = 1

static func initial():
	return from_fen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")

static func from_fen(fen: String):
	var parts := fen.strip_edges().split(" ", false)
	if parts.size() != 6 or parts[1] not in ["w", "b"]:
		return null
	var rows := parts[0].split("/")
	if rows.size() != 8:
		return null
	var state = load("res://games/chess/chess_state.gd").new()
	state.board.resize(64)
	state.board.fill("")
	var kings := {"K": 0, "k": 0}
	for row in range(8):
		var file := 0
		for symbol in rows[row]:
			if symbol in "12345678":
				file += int(symbol)
			elif symbol in "prnbqkPRNBQK" and file < 8:
				state.board[(7 - row) * 8 + file] = symbol
				file += 1
				if kings.has(symbol):
					kings[symbol] += 1
			else:
				return null
		if file != 8:
			return null
	if kings.K != 1 or kings.k != 1:
		return null
	state.turn = parts[1]
	state.castling = "" if parts[2] == "-" else parts[2]
	var seen := ""
	for right in state.castling:
		if right not in "KQkq" or right in seen:
			return null
		seen += right
	if parts[3] != "-":
		if parts[3].length() != 2 or parts[3][0] not in "abcdefgh" or parts[3][1] not in "36":
			return null
		state.en_passant = "abcdefgh".find(parts[3][0]) + (int(parts[3][1]) - 1) * 8
		if (state.turn == "w" and parts[3][1] != "6") or (state.turn == "b" and parts[3][1] != "3"):
			return null
	if not parts[4].is_valid_int() or not parts[5].is_valid_int():
		return null
	state.halfmove = int(parts[4])
	state.fullmove = int(parts[5])
	if state.halfmove < 0 or state.fullmove < 1:
		return null
	return state

func to_fen() -> String:
	var rows: Array[String] = []
	for rank_index in range(7, -1, -1):
		var row := ""
		var blanks := 0
		for file in range(8):
			var piece: String = board[rank_index * 8 + file]
			if piece.is_empty():
				blanks += 1
			else:
				if blanks:
					row += str(blanks)
					blanks = 0
				row += piece
		if blanks:
			row += str(blanks)
		rows.append(row)
	var ep := "-" if en_passant < 0 else "abcdefgh"[en_passant % 8] + str(en_passant / 8 + 1)
	return "/".join(rows) + " " + turn + " " + ("-" if castling.is_empty() else castling) + " " + ep + " " + str(halfmove) + " " + str(fullmove)

func copy():
	var result = get_script().new()
	result.board = board.duplicate()
	result.turn = turn
	result.castling = castling
	result.en_passant = en_passant
	result.halfmove = halfmove
	result.fullmove = fullmove
	return result
