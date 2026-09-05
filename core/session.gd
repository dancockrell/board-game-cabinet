class_name GameSession
extends RefCounted
## Sole authority for an active chess game. Consumers receive copied snapshots.
const State = preload("res://games/chess/chess_state.gd")
const Rules = preload("res://games/chess/chess_rules.gd")
signal changed(revision: int)
var revision: int = 0
var _state = State.initial()
var _initial_fen: String = _state.to_fen()
var _states: Array = []
var _moves: Array = []
var _san: Array[String] = []
var _keys: Array[String] = []
var _claimed: bool = false
var _claim_move: Dictionary = {}

func _init() -> void:
	_keys.append(_position_key(_state))

func snapshot():
	return _state.copy()

func snapshot_at(ply: int):
	if ply < 0 or ply > _moves.size():
		return null
	return _state.copy() if ply == _moves.size() else _states[ply].copy()

func history() -> Array:
	return _moves.duplicate(true)

func history_san() -> Array[String]:
	return _san.duplicate()

func legal_moves() -> Array:
	if not result().is_empty():
		return []
	return Rules.legal_moves(_state)

func try_move(request: Dictionary, expected_revision: int = -1) -> bool:
	if expected_revision >= 0 and expected_revision != revision:
		return false
	if not _well_formed_move(request):
		return false
	for move in legal_moves():
		if _same_move(request, move):
			_states.append(_state.copy())
			_san.append(Rules.san(_state, move))
			_moves.append(move.duplicate(true))
			_state = Rules.apply_move(_state, move)
			_keys.append(_position_key(_state))
			_touch()
			return true
	return false

func _well_formed_move(request: Dictionary) -> bool:
	for key in ["from", "to"]:
		var value: Variant = request.get(key)
		if not (value is int or value is float):
			return false
		if not is_finite(float(value)) or float(value) != floor(float(value)) or float(value) < 0 or float(value) > 63:
			return false
	if not request.get("promotion", "") is String:
		return false
	return true

func _same_move(a: Dictionary, b: Dictionary) -> bool:
	return int(a["from"]) == b["from"] and int(a["to"]) == b["to"] and a.get("promotion", "") == b.get("promotion", "")

func undo() -> bool:
	if _states.is_empty():
		return false
	_state = _states.pop_back()
	_moves.pop_back()
	_san.pop_back()
	_keys.pop_back()
	_claimed = false
	_claim_move.clear()
	_touch()
	return true

func new_game() -> void:
	_state = State.initial()
	_initial_fen = _state.to_fen()
	_states.clear()
	_moves.clear()
	_san.clear()
	_keys = [_position_key(_state)]
	_claimed = false
	_claim_move.clear()
	_touch()

func result() -> String:
	var terminal: String = Rules.outcome(_state)
	if not terminal.is_empty():
		return terminal
	if _claimed:
		return "Draw claimed"
	if _state.halfmove >= 150:
		return "Draw · seventy-five-move rule"
	if _keys.count(_keys.back()) >= 5:
		return "Draw · fivefold repetition"
	return ""

func draw_claim_available() -> bool:
	return result().is_empty() and (_state.halfmove >= 100 or _keys.count(_keys.back()) >= 3)

func claim_draw() -> bool:
	if not draw_claim_available():
		return false
	_claimed = true
	_claim_move.clear()
	_touch()
	return true

func draw_claim_moves() -> Array:
	var declarations: Array = []
	for move in legal_moves():
		var after = Rules.apply_move(_state, move)
		if after.halfmove >= 100 or _keys.count(_position_key(after)) >= 2:
			declarations.append(move.duplicate(true))
	return declarations

func claim_draw_with_move(request: Dictionary, expected_revision: int = -1) -> bool:
	if (expected_revision >= 0 and expected_revision != revision) or not _well_formed_move(request):
		return false
	for move in draw_claim_moves():
		if _same_move(request, move):
			# Declaring a move ends the game without adding that move to the board/log.
			_claimed = true
			_claim_move = move.duplicate(true)
			_touch()
			return true
	return false

func save_payload() -> Dictionary:
	return {"schema_version": 1, "game_id": "chess", "rules_version": 1, "initial_fen": _initial_fen, "moves": history(), "draw_claimed": _claimed, "declared_claim_move": _claim_move.duplicate(true)}

func load_payload(payload: Variant) -> String:
	# Validate into a separate session. An error cannot partially overwrite a game.
	if not payload is Dictionary:
		return "This save is not a game object."
	if payload.get("schema_version") != 1 or payload.get("game_id") != "chess" or payload.get("rules_version") != 1:
		return "Unsupported save or rules version."
	if payload.get("initial_fen") != State.initial().to_fen():
		return "This version loads games from the standard starting position."
	if not payload.get("moves") is Array or payload["moves"].size() > 2048:
		return "Invalid move history."
	if not payload.get("draw_claimed", false) is bool:
		return "Invalid draw status."
	var declared: Variant = payload.get("declared_claim_move", {})
	if not declared is Dictionary or (not payload.get("draw_claimed", false) and not declared.is_empty()):
		return "Invalid declared draw move."
	var candidate = get_script().new()
	for move in payload["moves"]:
		if not move is Dictionary:
			return "Invalid move record."
		for key in ["from", "to"]:
			var value: Variant = move.get(key)
			if not (value is int or value is float):
				return "Invalid square in save."
			if not is_finite(float(value)) or float(value) != floor(float(value)) or float(value) < 0 or float(value) > 63:
				return "Invalid square in save."
		if not move.get("promotion", "") is String:
			return "Invalid promotion in save."
		if not candidate.try_move(move):
			return "Saved move %d is illegal. The current game was kept." % (candidate._moves.size() + 1)
	if payload.get("draw_claimed", false):
		var accepted: bool = candidate.claim_draw() if declared.is_empty() else candidate.claim_draw_with_move(declared)
		if not accepted:
			return "The saved draw claim is invalid."
	_state = candidate._state
	_initial_fen = candidate._initial_fen
	_states = candidate._states
	_moves = candidate._moves
	_san = candidate._san
	_keys = candidate._keys
	_claimed = candidate._claimed
	_claim_move = candidate._claim_move.duplicate(true)
	_touch()
	return ""

func _touch() -> void:
	revision += 1
	changed.emit(revision)

func _position_key(state) -> String:
	return Rules.position_key(state)
