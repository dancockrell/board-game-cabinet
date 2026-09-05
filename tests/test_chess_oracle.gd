extends SceneTree
## Independent seeded differential fixture: legal moves, SAN, check, transition FEN.
const State = preload("res://games/chess/chess_state.gd")
const Rules = preload("res://games/chess/chess_rules.gd")

func _init() -> void:
	var fixture: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/chess_oracle.json"))
	var failures := 0
	var checked_moves := 0
	for record in fixture.positions:
		var state = State.from_fen(record.fen)
		var actual := {}
		for move in Rules.legal_moves(state):
			var uci := Rules.uci(move)
			actual[uci] = Rules.san(state, move)
			checked_moves += 1
			if uci == record.selected and Rules.apply_move(state, move).to_fen() != record.after:
				push_error("Transition differs: " + record.fen + " " + uci)
				failures += 1
		if actual != record.moves:
			push_error("Legal moves/SAN differ: " + record.fen + " expected=" + str(record.moves) + " actual=" + str(actual))
			failures += 1
		if Rules.in_check(state, state.turn) != record.check:
			push_error("Check status differs: " + record.fen)
			failures += 1
	print("Oracle ", fixture.oracle, ": ", fixture.positions.size(), " positions, ", checked_moves, " moves; failures: ", failures)
	quit(1 if failures else 0)
