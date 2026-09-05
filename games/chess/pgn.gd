extends RefCounted
## Deterministic PGN export for the standard-start games accepted by GameSession.
## Presentation and external engine annotations are deliberately excluded.
const Rules = preload("res://games/chess/chess_rules.gd")

static func export_game(session, metadata: Dictionary = {}) -> String:
	var result_token := _result_token(session)
	var defaults := {"Event": "Board Game Cabinet", "Site": "Local", "Date": "????.??.??", "Round": "?", "White": "White", "Black": "Black"}
	var lines := PackedStringArray()
	for tag in defaults:
		lines.append('[%s "%s"]' % [tag, _escape(str(metadata.get(tag, defaults[tag])))])
	lines.append('[Result "%s"]' % result_token)
	lines.append("")
	var tokens := PackedStringArray()
	var moves: Array[String] = session.history_san()
	for ply in range(moves.size()):
		if ply % 2 == 0:
			tokens.append("%d." % (ply / 2 + 1))
		tokens.append(moves[ply])
	tokens.append(result_token)
	var line := ""
	for token in tokens:
		if not line.is_empty() and line.length() + token.length() + 1 > 80:
			lines.append(line)
			line = ""
		line += ("" if line.is_empty() else " ") + token
	lines.append(line)
	return "\n".join(lines) + "\n"

static func _result_token(session) -> String:
	var state = session.snapshot()
	# Derive the winner from rules and side to move, never translated UI text.
	if Rules.legal_moves(state).is_empty() and Rules.in_check(state, state.turn):
		return "0-1" if state.turn == "w" else "1-0"
	return "*" if session.result().is_empty() else "1/2-1/2"

static func _escape(value: String) -> String:
	var printable := ""
	for index in range(value.length()):
		var code := value.unicode_at(index)
		printable += " " if code < 32 or code == 127 else value[index]
	return printable.replace("\\", "\\\\").replace('"', '\\"')
