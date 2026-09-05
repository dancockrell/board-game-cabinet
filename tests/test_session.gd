extends SceneTree

const Session = preload("res://core/session.gd")
const Rules = preload("res://games/chess/chess_rules.gd")
const Opponent = preload("res://ai/local_opponent.gd")
const Tutor = preload("res://ai/tutor_context.gd")
const Adapter = preload("res://ai/engine_adapter.gd")
const State = preload("res://games/chess/chess_state.gd")
var failures := 0

func expect(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		push_error(label)

func play(session, notation: String) -> void:
	for move in session.legal_moves():
		if Rules.uci(move) == notation:
			expect(session.try_move(move, session.revision), "Accept " + notation)
			return
	expect(false, "Missing move " + notation)

func cycle(session) -> void:
	for notation in ["g1f3", "g8f6", "f3g1", "f6g8"]:
		play(session, notation)

func round_trip(session):
	var loaded = Session.new()
	var serialized := JSON.stringify(session.save_payload())
	expect(loaded.load_payload(JSON.parse_string(serialized)).is_empty(), "JSON save loads")
	expect(loaded.snapshot().to_fen() == session.snapshot().to_fen(), "Save replay recreates complete state")
	expect(loaded.history() == session.history(), "Save replay retains moves")
	expect(loaded.history_san() == session.history_san(), "Save replay retains standard notation")
	expect(loaded.result() == session.result(), "Save replay retains result")
	return loaded

func reject_atomically(session, payload: Variant, label: String) -> void:
	var before: String = session.snapshot().to_fen()
	var history: Array = session.history()
	var revision: int = session.revision
	expect(not session.load_payload(payload).is_empty(), label + " rejected")
	expect(session.snapshot().to_fen() == before and session.history() == history and session.revision == revision, label + " leaves game intact")

func _init() -> void:
	var session = Session.new()
	var start: String = session.snapshot().to_fen()
	var snapshot = session.snapshot()
	snapshot.board[4] = ""
	expect(session.snapshot().board[4] == "K", "Snapshot cannot mutate session")
	expect(not session.undo() and session.revision == 0, "Empty undo is inert")
	expect(not session.try_move({"from": 12, "to": 36}), "Illegal move rejected")
	expect(session.revision == 0, "Illegal move leaves revision unchanged")
	for request in [{"from": 12.5, "to": 28.5}, {"from": "12", "to": 28}, {"from": INF, "to": 28}, {"from": NAN, "to": 28}, {"from": -1, "to": 28}, {"from": 12, "to": 64}, {"from": 12, "to": 28, "promotion": 0}]:
		expect(not session.try_move(request) and session.revision == 0, "Malformed direct request rejected without mutation " + str(request))
	play(session, "e2e4")
	expect(session.history_san() == ["e4"], "History exposes standard algebraic notation")
	var notation_copy: Array[String] = session.history_san()
	notation_copy[0] = "bad"
	expect(session.history_san() == ["e4"], "Notation history is independent")
	var first: String = session.snapshot().to_fen()
	var history: Array = session.history()
	history[0]["to"] = 63
	history.append({})
	expect(session.history().size() == 1 and session.history()[0]["to"] == 28, "History copy is deeply independent")
	expect(not session.try_move({"from": 52, "to": 36}, 0), "Stale engine revision rejected")
	expect(session.revision == 1 and session.snapshot().to_fen() == first, "Stale rejection is inert")
	play(session, "e7e5")
	expect(session.undo() and session.snapshot().to_fen() == first, "Undo restores en passant, clocks, turn and board")
	expect(session.undo() and session.snapshot().to_fen() == start, "Undo restores full initial state")
	for notation in ["e2e4", "e7e5", "g1f3", "b8c6", "f1c4", "g8f6"]:
		play(session, notation)
	var pre_castle: String = session.snapshot().to_fen()
	play(session, "e1g1")
	var loaded = round_trip(session)
	expect(loaded.undo() and loaded.snapshot().to_fen() == pre_castle, "Loaded undo restores castle rights and rook")
	expect(session.undo() and session.snapshot().to_fen() == pre_castle, "Live undo restores castle rights and rook")
	var valid: Dictionary = session.save_payload()
	reject_atomically(session, null, "Null save")
	reject_atomically(session, [], "Array save")
	for patch in [{"schema_version": 2}, {"rules_version": 9}, {"game_id": "xiangqi"}, {"moves": "bad"}, {"draw_claimed": "true"}, {"draw_claimed": true}]:
		var bad := valid.duplicate(true)
		bad.merge(patch, true)
		reject_atomically(session, bad, "Invalid metadata " + str(patch))
	for record in [null, {}, {"from": "12", "to": 28}, {"from": 12.5, "to": 28}, {"from": -1, "to": 28}, {"from": 64, "to": 28}, {"from": 12, "to": 28, "promotion": 1}, {"from": 12, "to": 36}, {"from": INF, "to": 28}]:
		var bad := valid.duplicate(true)
		bad["moves"].append(record)
		reject_atomically(session, bad, "Invalid move " + str(record))
	var repetition = Session.new()
	expect(not repetition.claim_draw(), "Initial draw cannot be claimed")
	cycle(repetition)
	expect(not repetition.draw_claim_available(), "Second occurrence is not claimable")
	cycle(repetition)
	expect(repetition.draw_claim_available() and repetition.result().is_empty(), "Third occurrence offers claim without ending game")
	var before_claim: String = repetition.snapshot().to_fen()
	var claim_revision: int = repetition.revision
	expect(repetition.claim_draw() and repetition.revision == claim_revision + 1, "Draw claim advances revision")
	expect(not repetition.result().is_empty() and repetition.legal_moves().is_empty(), "Claim ends play")
	loaded = round_trip(repetition)
	expect(loaded.undo() and loaded.result().is_empty(), "Undo from loaded claim resumes game")
	expect(repetition.undo() and repetition.result().is_empty() and repetition.snapshot().to_fen() != before_claim, "Undo claim retracts latest ply and clears result")
	play(repetition, "f6g8")
	cycle(repetition)
	expect(repetition.result().is_empty(), "Fourth repetition remains playable")
	cycle(repetition)
	expect(repetition.result().contains("fivefold") and repetition.legal_moves().is_empty(), "Fifth repetition automatically ends game")
	round_trip(repetition)
	expect(repetition.undo() and repetition.result().is_empty(), "Undo automatic draw resumes game")
	session.new_game()
	expect(session.history().is_empty() and session.snapshot().to_fen() == start, "New game resets board and history")
	var engine = Opponent.new()
	for position in ["initial", "after e4"]:
		if position == "after e4":
			play(session, "e2e4")
		var fen: String = session.snapshot().to_fen()
		var revision: int = session.revision
		var begin := Time.get_ticks_usec()
		var analysis: Dictionary = engine.analyze(session.snapshot(), revision)
		var elapsed_ms := (Time.get_ticks_usec() - begin) / 1000.0
		expect(analysis.revision == revision, "Engine response retains revision")
		expect(analysis.move in session.legal_moves(), "Engine recommends legal move " + position)
		expect(session.snapshot().to_fen() == fen and session.revision == revision, "Analysis cannot mutate session")
		print("Local opponent ", position, ": ", snappedf(elapsed_ms, 0.1), " ms, ", Rules.uci(analysis.move))
	var mating = State.from_fen("7k/8/5KQ1/8/8/8/8/8 w - - 0 1")
	var mate_analysis: Dictionary = engine.analyze(mating, 78)
	expect(mate_analysis.revision == 78 and Rules.outcome(Rules.apply_move(mating, mate_analysis.move)).begins_with("Checkmate"), "Practice opponent finds mate in one")
	var empty_analysis: Dictionary = Adapter.new().analyze(mating, 79)
	expect(empty_analysis.revision == 79 and empty_analysis.move.is_empty(), "Unavailable adapter returns no invented move")
	var checkmated = Rules.apply_move(mating, mate_analysis.move)
	expect(engine.analyze(checkmated, 80).move.is_empty(), "Opponent returns no move in terminal position")
	var context: Dictionary = Tutor.build(State.initial(), 90, [])
	expect(context.revision == 90 and context.legal_move_count == 20 and not context.in_check and context.legal_captures_uci.is_empty(), "Tutor initial position facts")
	var ep = State.from_fen("4k3/8/8/3pP3/8/8/8/4K3 w - d6 0 1")
	var ep_fen: String = ep.to_fen()
	var prior: Array = [{"from": 51, "to": 35, "promotion": ""}]
	context = Tutor.build(ep, 91, prior)
	expect(context.revision == 91 and context.fen == ep_fen and context.last_move_uci == "d7d5" and "e5d6" in context.legal_captures_uci, "Tutor includes en passant capture and source position")
	expect(ep.to_fen() == ep_fen and prior[0]["from"] == 51, "Tutor does not mutate source state or history")
	var pinned_ep = State.from_fen("k3r3/8/8/3pP3/8/8/8/4K3 w - d6 0 1")
	context = Tutor.build(pinned_ep, 92, [])
	expect("e5d6" not in context.legal_captures_uci, "Tutor excludes king-exposing captures")
	context = Tutor.build(checkmated, 93, [])
	expect(context.in_check and context.legal_move_count == 0, "Tutor checkmate facts")
	print("Session checks complete; failures: ", failures)
	quit(1 if failures else 0)
