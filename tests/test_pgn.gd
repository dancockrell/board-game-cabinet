extends SceneTree

const Session = preload("res://core/session.gd")
const Rules = preload("res://games/chess/chess_rules.gd")
const PGN = preload("res://games/chess/pgn.gd")
var failures := 0
var checks := 0
var fixtures: Array = []

func expect(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(label)

func play(session, uci: String) -> void:
	for move in session.legal_moves():
		if Rules.uci(move) == uci:
			expect(session.try_move(move), "Accept " + uci)
			return
	expect(false, "Missing move " + uci)

func record(session, label: String, result: String, metadata: Dictionary = {}) -> String:
	var before: String = JSON.stringify(session.save_payload())
	var revision: int = session.revision
	var pgn: String = PGN.export_game(session, metadata)
	expect(pgn == PGN.export_game(session, metadata), label + " deterministic")
	expect(pgn.contains('[Result "%s"]' % result) and pgn.ends_with(result + "\n"), label + " matching result")
	expect(JSON.stringify(session.save_payload()) == before and session.revision == revision, label + " export is read-only")
	for line in pgn.split("\n"):
		if not line.begins_with("["):
			expect(line.length() <= 80, label + " wrapped movetext")
	fixtures.append({"name": label, "pgn": pgn, "fen": session.snapshot().to_fen(), "plies": session.history().size(), "result": result})
	return pgn

func _init() -> void:
	var session = Session.new()
	var pgn := record(session, "empty", "*")
	expect(pgn.count("[") == 7 and pgn.contains('[Date "????.??.??"]'), "Seven deterministic default tags")
	play(session, "e2e4")
	pgn = record(session, "one ply", "*")
	expect(pgn.contains("1. e4 *"), "Odd final ply numbering")
	var metadata := {"White": "A \"quoted\" \\ player\nnext", "Event": "Tab\tEvent", "Result": "1-0", "Injected": "ignored"}
	pgn = record(session, "escaped metadata", "*", metadata)
	expect(pgn.contains('[White "A \\"quoted\\" \\\\ player next"]'), "Quotes, slashes and newline escaped")
	expect(pgn.contains('[Event "Tab Event"]') and not pgn.contains("Injected"), "Only fixed tag names accepted")
	session.new_game()
	for uci in ["f2f3", "e7e5", "g2g4", "d8h4"]:
		play(session, uci)
	pgn = record(session, "black mate", "0-1")
	expect(pgn.contains("2. g4 Qh4# 0-1"), "Mate SAN retained")
	session.new_game()
	for uci in ["e2e4", "e7e5", "f1c4", "b8c6", "d1h5", "g8f6", "h5f7"]:
		play(session, uci)
	record(session, "white mate", "1-0")
	session.new_game()
	for uci in ["e2e4", "e7e5", "g1f3", "b8c6", "f1c4", "g8f6", "e1g1"]:
		play(session, uci)
	pgn = record(session, "castle", "*")
	expect(pgn.contains("4. O-O *"), "Castle SAN retained")
	for promotion in ["q", "r", "b", "n"]:
		session.new_game()
		for uci in ["a2a4", "h7h5", "a4a5", "h5h4", "a5a6", "h4h3", "a6b7", "h3g2", "b7a8" + promotion]:
			play(session, uci)
		pgn = record(session, "promotion " + promotion, "*")
		expect(pgn.contains("bxa8=" + promotion.to_upper()), "Promotion SAN retained")
	session.new_game()
	for _cycle in range(2):
		for uci in ["g1f3", "g8f6", "f3g1", "f6g8"]:
			play(session, uci)
	record(session, "unclaimed repetition", "*")
	expect(session.claim_draw(), "Claim repetition draw")
	record(session, "claimed draw", "1/2-1/2")
	expect(session.undo(), "Undo claimed draw")
	record(session, "undo draw", "*")
	session.new_game()
	for _cycle in range(4):
		for uci in ["g1f3", "g8f6", "f3g1", "f6g8"]:
			play(session, uci)
	record(session, "automatic repetition", "1/2-1/2")
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--fixtures":
		var file := FileAccess.open(args[1], FileAccess.WRITE)
		expect(file != null, "Open oracle fixtures")
		if file != null:
			file.store_string(JSON.stringify(fixtures, "\t"))
	print("PGN: %d checks, %d failures, %d replay fixtures" % [checks, failures, fixtures.size()])
	quit(1 if failures else 0)
