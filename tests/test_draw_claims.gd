extends SceneTree

const Session = preload("res://core/session.gd")
const Rules = preload("res://games/chess/chess_rules.gd")
const State = preload("res://games/chess/chess_state.gd")
var failures := 0

func expect(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		push_error(label)

func move_named(session, uci: String) -> Dictionary:
	for move in session.legal_moves():
		if Rules.uci(move) == uci:
			return move

	return {}

func claim_setup():
	var session = Session.new()
	for uci in ["g1f3", "g8f6", "f3g1", "f6g8", "g1f3", "g8f6", "f3g1"]:
		expect(session.try_move(move_named(session, uci)), "Fixture accepts " + uci)
	return session

func reject_claim(session, move: Dictionary, revision: int, label: String) -> void:
	var before: Dictionary = session.save_payload()
	var before_revision: int = session.revision
	expect(not session.claim_draw_with_move(move, revision), label + " rejected")
	expect(session.save_payload() == before and session.revision == before_revision, label + " is atomic")

func reject_load(session, payload: Dictionary, label: String) -> void:
	var before: Dictionary = session.save_payload()
	var before_revision: int = session.revision
	expect(not session.load_payload(payload).is_empty(), label + " rejected")
	expect(session.save_payload() == before and session.revision == before_revision, label + " preserves loaded game")

func _init() -> void:
	var session = claim_setup()
	var claim_move: Dictionary = move_named(session, "f6g8")
	var before_fen: String = session.snapshot().to_fen()
	var before_history: Array = session.history()
	var before_revision: int = session.revision
	expect(not session.draw_claim_available(), "Current position occurs only twice")
	var choices: Array = session.draw_claim_moves()
	expect(choices.size() == 1 and Rules.uci(choices[0]) == "f6g8", "Only declared return creates third occurrence")
	expect(session.snapshot().to_fen() == before_fen and session.revision == before_revision, "Claim discovery does not play or revise state")
	choices[0]["to"] = 0
	expect(Rules.uci(session.draw_claim_moves()[0]) == "f6g8", "Claim choices are independent copies")
	reject_claim(session, claim_move, before_revision - 1, "Stale declaration")
	reject_claim(session, move_named(session, "e7e5"), before_revision, "Legal move without a claim")
	for invalid in [{}, {"from": 45.5, "to": 62}, {"from": 45, "to": 62.5}, {"from": "45", "to": 62}, {"from": 45, "to": 63}, {"from": -1, "to": 62}, {"from": INF, "to": 62}, {"from": NAN, "to": 62}, {"from": 45, "to": 62, "promotion": 2}, {"from": 45, "to": 62, "promotion": "q"}]:
		reject_claim(session, invalid, before_revision, "Malformed or illegal declaration " + str(invalid))
	expect(session.claim_draw_with_move(claim_move, before_revision), "Valid intended repetition claim accepted")
	expect(session.revision == before_revision + 1, "Accepted claim advances revision once")
	expect(session.snapshot().to_fen() == before_fen and session.history() == before_history, "Declaration leaves position and played history unchanged")
	expect(not session.result().is_empty() and session.legal_moves().is_empty() and session.draw_claim_moves().is_empty(), "Claim locks game and hides further claims")
	reject_claim(session, claim_move, session.revision, "Repeated claim")
	var payload: Dictionary = session.save_payload()
	expect(payload.draw_claimed and payload.declared_claim_move == claim_move, "Save distinguishes declared and played moves")
	var loaded = Session.new()
	expect(loaded.load_payload(JSON.parse_string(JSON.stringify(payload))).is_empty(), "JSON round trip revalidates declared claim")
	expect(loaded.snapshot().to_fen() == before_fen and loaded.history() == before_history and loaded.result() == session.result(), "Loaded claim restores exact game")
	for declared in [null, [], {"from": 45.5, "to": 62}, {"from": 52, "to": 36}, {}]:
		var bad := payload.duplicate(true)
		bad.declared_claim_move = declared
		reject_load(loaded, bad, "Invalid saved declaration " + str(declared))
	var unclaimed := payload.duplicate(true)
	unclaimed.draw_claimed = false
	reject_load(loaded, unclaimed, "Declaration without claimed status")
	expect(loaded.undo() and loaded.result().is_empty() and loaded.history().size() == 6, "Undo retracts last actual ply and resumes play")
	expect(loaded.save_payload().declared_claim_move.is_empty() and not loaded.save_payload().draw_claimed, "Undo clears declaration metadata")
	session.new_game()
	expect(session.save_payload().declared_claim_move.is_empty() and session.draw_claim_moves().is_empty(), "New game clears declaration")
	# Clock-boundary unit fixture: keep a legal starting board; advance only the
	# halfmove clock directly. This is intentionally not a replay/save fixture.
	var clock_session = Session.new()
	clock_session._state.halfmove = 99
	expect(not clock_session.draw_claim_available(), "99 halfmoves is below current claim threshold")
	var quiet: Dictionary = move_named(clock_session, "g1f3")
	expect(quiet in clock_session.draw_claim_moves(), "Quiet move reaching 100 halfmoves is claimable")
	reject_claim(clock_session, move_named(clock_session, "e2e4"), clock_session.revision, "Pawn move resets clock")
	expect(clock_session.claim_draw_with_move(quiet) and clock_session.snapshot().halfmove == 99, "Fifty-move declaration ends game before moving")
	var capture_session = Session.new()
	capture_session._state = State.from_fen("4k3/8/8/8/8/8/r7/R3K3 w - - 99 1")
	reject_claim(capture_session, move_named(capture_session, "a1a2"), capture_session.revision, "Capture resets clock")
	# Two knights cannot force mate against a bare king, but mate is possible.
	expect(Rules.outcome(State.from_fen("7k/8/8/8/8/8/NN6/K7 w - - 0 1")).is_empty(), "Two knights are not blanket insufficient material")
	expect(Rules.outcome(State.from_fen("7k/5K2/5NN1/8/8/8/8/8 b - - 0 1")).begins_with("Checkmate"), "Constructive two-knight mating position remains checkmate")
	print("Declared draw claim checks complete; failures: ", failures)
	quit(1 if failures else 0)
