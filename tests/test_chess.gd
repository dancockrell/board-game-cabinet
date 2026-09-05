extends SceneTree

const State = preload("res://games/chess/chess_state.gd")
const Rules = preload("res://games/chess/chess_rules.gd")
var failures := 0

func expect(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		push_error(label)

func perft(state, depth: int) -> int:
	if depth == 0:
		return 1
	var count := 0
	for move in Rules.legal_moves(state):
		count += perft(Rules.apply_move(state, move), depth - 1)
	return count

func moves(state) -> Array[String]:
	var result: Array[String] = []
	for move in Rules.legal_moves(state):
		result.append(Rules.uci(move))
	return result

func play(state, notation: String):
	for move in Rules.legal_moves(state):
		if Rules.uci(move) == notation:
			return Rules.apply_move(state, move)
	expect(false, "Missing legal move " + notation)
	return state

func _init() -> void:
	var initial = State.initial()
	expect(initial.to_fen() == "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1", "Initial FEN round trip")
	for depth in range(1, 4):
		var count := perft(initial, depth)
		expect(count == [20, 400, 8902][depth - 1], "Initial perft %d: %d" % [depth, count])
		print("Initial perft depth ", depth, ": ", count)
	var kiwipete = State.from_fen("r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1")
	expect(perft(kiwipete, 1) == 48, "Kiwipete depth 1")
	expect(perft(kiwipete, 2) == 2039, "Kiwipete depth 2")
	var endgame = State.from_fen("8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 1")
	expect(perft(endgame, 3) == 2812, "Rook ending perft depth 3")
	var copy = initial.copy()
	copy.board[0] = ""
	expect(initial.board[0] == "R", "Copies own their board")
	var after = play(initial, "e2e4")
	expect(after.to_fen() == "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1", "Double push FEN")
	expect(initial.board[12] == "P", "Applying move does not mutate source")
	var castle = State.from_fen("r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1")
	expect("e1g1" in moves(castle) and "e1c1" in moves(castle), "Both castles generated")
	after = play(castle, "e1g1")
	expect(after.board[5] == "R" and after.board[6] == "K" and after.board[7] == "" and after.castling == "kq", "Castle moves rook and removes rights")
	var through_check = State.from_fen("4kr2/8/8/8/8/8/8/4K2R w K - 0 1")
	expect("e1g1" not in moves(through_check), "Cannot castle through attack")
	var ep = State.from_fen("4k3/8/8/3pP3/8/8/8/4K3 w - d6 0 1")
	after = play(ep, "e5d6")
	expect(after.board[35] == "" and after.board[43] == "P", "En passant removes passed pawn")
	var pinned_ep = State.from_fen("k3r3/8/8/3pP3/8/8/8/4K3 w - d6 0 1")
	expect("e5d6" not in moves(pinned_ep), "En passant cannot expose king")
	var promotion = State.from_fen("4k3/P7/8/8/8/8/8/4K3 w - - 0 1")
	for kind in ["q", "r", "b", "n"]:
		expect("a7a8" + kind in moves(promotion), "Promotion choice " + kind)
	expect(play(promotion, "a7a8n").board[56] == "N", "Underpromotion applied")
	var mate = initial
	for notation in ["f2f3", "e7e5", "g2g4", "d8h4"]:
		mate = play(mate, notation)
	expect(Rules.outcome(mate).begins_with("Checkmate"), "Fool's mate")
	expect(Rules.outcome(State.from_fen("7k/5Q2/6K1/8/8/8/8/8 b - - 0 1")).contains("stalemate"), "Stalemate")
	expect(Rules.outcome(State.from_fen("7k/8/6K1/8/8/8/8/8 w - - 0 1")).contains("insufficient"), "Bare kings draw")
	expect(State.from_fen("bad") == null, "Malformed FEN rejected")
	expect(State.from_fen("8/8/8/8/8/8/8/8 w - - 0 1") == null, "Missing kings rejected")
	expect(State.from_fen("4k3/8/8/8/8/8/8/4K3 w KK - 0 1") == null, "Duplicate castling rights rejected")
	print("Chess checks complete; failures: ", failures)
	quit(1 if failures else 0)
