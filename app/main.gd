extends Control
const Session = preload("res://core/session.gd")
const Rules = preload("res://games/chess/chess_rules.gd")
const Board = preload("res://presentation/board_view.gd")
const Opponent = preload("res://ai/local_opponent.gd")
const Tutor = preload("res://ai/tutor_context.gd")
const MoveAudio = preload("res://presentation/move_audio.gd")
const Preferences = preload("res://core/preferences.gd")
const PGN = preload("res://games/chess/pgn.gd")
var save_path: String = "user://cabinet-chess-v1.json"
var preferences_path: String = "user://cabinet-preferences-v1.json"
var session = Session.new()
var board_view
var board_viewport: SubViewport
var selected: int = -1
var practice: bool = true
var flipped: bool = false
var status_label: Label
var detail_label: Label
var history_label: RichTextLabel
var tutor_label: Label
var notice_label: Label
var undo_button: Button
var hint_button: Button
var draw_button: Button
var promotion_dialog: ConfirmationDialog
var new_dialog: ConfirmationDialog
var _promotion_moves: Array = []
var _promotion_revision: int = -1
var _promotion_buttons: Dictionary = {}
var _worker: Thread
var _analysis_busy: bool = false
var _closing: bool = false
var _mode_picker: OptionButton
var _move_audio
var _animate_next: bool = false
var _review_ply: int = -1
var _review_label: Label
var _review_back: Button
var _review_next: Button
var _settings: Dictionary
var _board_surface: SubViewportContainer
var _keyboard_square: int = 12
var _keyboard_active: bool = false
var _board_caption: Label
var _reduced_motion: bool = false
var _draw_dialog: ConfirmationDialog
var _draw_picker: OptionButton
var _draw_moves: Array = []
var _draw_revision: int = -1
var _export_dialog: FileDialog
var _export_text: String = ""

func _ready() -> void:
	_settings = Preferences.read_settings(preferences_path)
	practice = _settings["practice"]
	flipped = _settings["flipped"]
	_reduced_motion = _settings["reduced_motion"]
	_move_audio = MoveAudio.new()
	add_child(_move_audio)
	_move_audio.set_muted(_settings["muted"])
	_build_ui()
	session.changed.connect(_on_changed)
	_refresh()
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="):
			_capture(argument.trim_prefix("--capture="))

func _build_ui() -> void:
	var skin := Theme.new()
	skin.default_font_size = 17
	skin.set_color("font_color", "Label", Color("e6dfca"))
	skin.set_color("default_color", "RichTextLabel", Color("d9d6c7"))
	for state_name in ["normal", "hover", "pressed", "focus", "disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("273b36") if state_name != "hover" else Color("3a5146")
		style.border_color = Color("ab9463") if state_name == "focus" else Color("41564a")
		style.set_border_width_all(2 if state_name == "focus" else 1)
		style.set_corner_radius_all(6)
		style.content_margin_left = 14
		style.content_margin_right = 14
		style.content_margin_top = 10
		style.content_margin_bottom = 10
		skin.set_stylebox(state_name, "Button", style)
		skin.set_stylebox(state_name, "OptionButton", style)
	theme = skin
	var background := ColorRect.new()
	background.color = Color("101d1a")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for edge in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + edge, 24)
	add_child(margin)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 16)
	margin.add_child(layout)
	var header := HBoxContainer.new()
	layout.add_child(header)
	var brand := _label("THE BOARD GAME CABINET", 15, Color("bfa875"))
	brand.autowrap_mode = TextServer.AUTOWRAP_OFF
	brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(brand)
	var edition := _label("CHESS  /  THE WOODEN SET", 14, Color("aeb7a8"))
	edition.autowrap_mode = TextServer.AUTOWRAP_OFF
	header.add_child(edition)
	var columns := HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 24)
	layout.add_child(columns)
	var board_column := VBoxContainer.new()
	board_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(board_column)
	var container := SubViewportContainer.new()
	_board_surface = container
	container.name = "BoardSurface"
	container.focus_mode = Control.FOCUS_ALL
	container.gui_input.connect(_board_key_input)
	container.focus_entered.connect(func():
		_keyboard_active = true
		_update_keyboard_cursor()
	)
	container.focus_exited.connect(func():
		_keyboard_active = false
		_update_keyboard_cursor()
	)
	container.stretch = true
	container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board_column.add_child(container)
	board_viewport = SubViewport.new()
	board_viewport.size = Vector2i(980, 780)
	board_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	board_viewport.msaa_3d = Viewport.MSAA_4X
	container.add_child(board_viewport)
	board_view = Board.new()
	board_viewport.add_child(board_view)
	board_view.square_clicked.connect(_mouse_square)
	board_view.set_flipped(flipped)
	var instructions := _label("Click a chip, then a marked square.  •  Tab: focus board  •  Arrows + Enter: play", 14, Color("aeb7a8"))
	instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	board_column.add_child(instructions)
	_board_caption = _label("F: turn board  ·  Esc: clear  ·  Mouse wheel: zoom", 14, Color("c8ba96"))
	_board_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	board_column.add_child(_board_caption)
	var side := VBoxContainer.new()
	side.custom_minimum_size.x = 330
	side.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	side.add_theme_constant_override("separation", 10)
	var sidebar_scroll := ScrollContainer.new()
	sidebar_scroll.custom_minimum_size.x = 345
	sidebar_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sidebar_scroll.follow_focus = true
	columns.add_child(sidebar_scroll)
	sidebar_scroll.add_child(side)
	side.add_child(_label("The wooden set", 32))
	side.add_child(_label("Maple & walnut · branded chess chips", 14, Color("aeb7a8")))
	side.add_child(HSeparator.new())
	status_label = _label("White to move", 25)
	side.add_child(status_label)
	detail_label = _label("", 14, Color("bfa875"))
	side.add_child(detail_label)
	_mode_picker = OptionButton.new()
	_mode_picker.add_item("Play the practice opponent")
	_mode_picker.add_item("Two players at this board")
	_mode_picker.select(0 if practice else 1)
	_mode_picker.item_selected.connect(_change_mode)
	side.add_child(_mode_picker)
	var controls := HBoxContainer.new()
	side.add_child(controls)
	undo_button = _button("Undo", _undo)
	controls.add_child(undo_button)
	controls.add_child(_button("Turn board", _flip))
	controls.add_child(_button("New", func(): new_dialog.popup_centered()))
	var storage := HBoxContainer.new()
	side.add_child(storage)
	storage.add_child(_button("Save", _save))
	storage.add_child(_button("Load", _load_save))
	draw_button = _button("Claim draw", _open_draw_claim)
	storage.add_child(draw_button)
	var review_controls := HBoxContainer.new()
	side.add_child(review_controls)
	_review_back = _button("‹", func(): _review(-1))
	_review_back.tooltip_text = "Review previous position"
	review_controls.add_child(_review_back)
	_review_label = _label("Live board", 14, Color("bfa875"))
	_review_label.custom_minimum_size.x = 115
	_review_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	review_controls.add_child(_review_label)
	_review_next = _button("›", func(): _review(1))
	_review_next.tooltip_text = "Review next position"
	review_controls.add_child(_review_next)
	review_controls.add_child(_button("Live", func():
		_review_ply = -1
		_refresh()
	))
	side.add_child(_label("MOVE RECORD", 13, Color("bfa875")))
	history_label = RichTextLabel.new()
	history_label.custom_minimum_size.y = 88
	history_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	history_label.bbcode_enabled = false
	history_label.scroll_following = true
	history_label.selection_enabled = true
	side.add_child(history_label)
	var record_actions := HBoxContainer.new()
	side.add_child(record_actions)
	record_actions.add_child(_button("Copy PGN", func():
		DisplayServer.clipboard_set(PGN.export_game(session))
		notice_label.text = "Game record copied in PGN format."
	))
	record_actions.add_child(_button("Export PGN…", _open_export))
	side.add_child(HSeparator.new())
	side.add_child(_label("AT THE BOARD", 13, Color("bfa875")))
	tutor_label = _label("", 16)
	tutor_label.custom_minimum_size.y = 72
	side.add_child(tutor_label)
	hint_button = _button("Explore a candidate move", _hint)
	side.add_child(hint_button)
	var limits := _label("Practice strength · two-ply search\nPosition facts, not expert coaching.", 13, Color("aeb7a8"))
	side.add_child(limits)
	var sound := CheckButton.new()
	sound.text = "Wooden move sound"
	sound.button_pressed = not _settings["muted"]
	sound.toggled.connect(func(enabled: bool):
		_move_audio.set_muted(not enabled)
		_settings["muted"] = not enabled
		_persist_preferences()
	)
	side.add_child(sound)
	var motion := CheckButton.new()
	motion.text = "Reduced motion"
	motion.button_pressed = _reduced_motion
	motion.toggled.connect(func(enabled: bool):
		_reduced_motion = enabled
		_settings["reduced_motion"] = enabled
		board_view.show_position(_display_state().board)
		_persist_preferences()
	)
	side.add_child(motion)
	notice_label = _label("", 14, Color("e1c48b"))
	notice_label.custom_minimum_size.y = 32
	side.add_child(notice_label)
	promotion_dialog = ConfirmationDialog.new()
	promotion_dialog.title = "Choose your promotion"
	promotion_dialog.dialog_text = "Choose the piece your pawn becomes."
	promotion_dialog.get_ok_button().hide()
	for kind in ["q", "r", "b", "n"]:
		var titles: Dictionary = {"q": "Queen", "r": "Rook", "b": "Bishop", "n": "Knight"}
		var choice: Button = promotion_dialog.add_button(titles[kind], false, kind)
		choice.name = "Promote_" + kind
		_promotion_buttons[kind] = choice
	promotion_dialog.custom_action.connect(_promote)
	add_child(promotion_dialog)
	new_dialog = ConfirmationDialog.new()
	new_dialog.title = "Start a new game?"
	new_dialog.dialog_text = "The current board and move record will be replaced.\nSave first if you want to return to this game."
	new_dialog.confirmed.connect(func(): session.new_game())
	add_child(new_dialog)
	_draw_dialog = ConfirmationDialog.new()
	_draw_dialog.title = "Claim a draw"
	_draw_dialog.dialog_text = "Declare a qualifying move. The game ends as a draw.\nThe declared move is not played on the board."
	_draw_dialog.get_ok_button().text = "Declare and claim"
	_draw_picker = OptionButton.new()
	_draw_dialog.add_child(_draw_picker)
	_draw_dialog.confirmed.connect(_confirm_draw_claim)
	add_child(_draw_dialog)
	_export_dialog = FileDialog.new()
	_export_dialog.title = "Export game record"
	_export_dialog.access = FileDialog.ACCESS_FILESYSTEM
	_export_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	_export_dialog.add_filter("*.pgn", "Portable Game Notation")
	_export_dialog.current_file = "cabinet-game.pgn"
	_export_dialog.file_selected.connect(_write_pgn)
	add_child(_export_dialog)

func _label(text: String, font_size: int = 17, color: Color = Color("e6dfca")) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

func _button(text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.pressed.connect(action)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return button

func request_square(square: int) -> void:
	if square < 0 or square > 63 or _review_ply >= 0 or not session.result().is_empty():
		return
	var state = session.snapshot()
	if practice and state.turn == "b":
		return
	var options: Array = []
	for move in session.legal_moves():
		if move["from"] == selected and move["to"] == square:
			options.append(move)
	if options.size() > 1:
		_promotion_moves = options
		_promotion_revision = session.revision
		promotion_dialog.popup_centered()
		_promotion_buttons["q"].grab_focus()
		return
	if options.size() == 1:
		_commit_move(options[0])
		return
	var piece: String = state.board[square]
	var own: bool = not piece.is_empty() and ((piece == piece.to_upper()) == (state.turn == "w"))
	selected = square if own and selected != square else -1
	_refresh_highlights()

func _promote(kind: String) -> void:
	promotion_dialog.hide()
	for move in _promotion_moves:
		if move["promotion"] == kind:
			_commit_move(move, _promotion_revision)
			break
	_promotion_moves.clear()

func _on_changed(_revision: int) -> void:
	selected = -1
	_review_ply = -1
	promotion_dialog.hide()
	_draw_dialog.hide()
	notice_label.text = ""
	_refresh()
	_maybe_opponent.call_deferred()

func _refresh() -> void:
	var state = session.snapshot_at(_review_ply) if _review_ply >= 0 else session.snapshot()
	var terminal: String = session.result()
	status_label.text = terminal if not terminal.is_empty() else ("White to move" if state.turn == "w" else "Black to move")
	detail_label.text = "CHECK — protect your king" if Rules.in_check(state, state.turn) else "Move %d · %s" % [state.fullmove, "practice game" if practice else "two players"]
	if _review_ply >= 0:
		status_label.text = "Review · ply %d" % _review_ply
		detail_label.text = "Live game preserved · use Live to return"
	board_view.show_position(state.board, _animate_next and not _reduced_motion)
	_animate_next = false
	_refresh_highlights()
	var moves: Array = session.history()
	var notation: Array = session.history_san()
	var lines := PackedStringArray()
	for index in range(0, moves.size(), 2):
		lines.append("%2d.   %-9s %s" % [index / 2 + 1, notation[index], notation[index + 1] if index + 1 < notation.size() else "…"])
	history_label.text = "Your move record will appear here.\nStandard chess notation · Nf3" if lines.is_empty() else "\n".join(lines)
	undo_button.disabled = moves.is_empty() or _review_ply >= 0
	var claims_available: bool = session.draw_claim_available() or not session.draw_claim_moves().is_empty()
	draw_button.disabled = not claims_available or _review_ply >= 0 or (practice and state.turn == "b")
	hint_button.disabled = not terminal.is_empty() or _analysis_busy or _review_ply >= 0
	_review_label.text = "Live board" if _review_ply < 0 else "%d / %d plies" % [_review_ply, moves.size()]
	_review_back.disabled = moves.is_empty() or _review_ply == 0
	_review_next.disabled = _review_ply < 0
	tutor_label.text = Tutor.describe(Tutor.build(state, session.revision, moves.slice(0, _review_ply) if _review_ply >= 0 else moves)) if terminal.is_empty() or _review_ply >= 0 else terminal + ". Undo a move or start a new game."

func _refresh_highlights() -> void:
	var targets: Array = []
	for move in session.legal_moves():
		if move["from"] == selected:
			targets.append(move["to"])
	var moves: Array = session.history()
	if _review_ply >= 0:
		moves = moves.slice(0, _review_ply)
	var state = session.snapshot_at(_review_ply) if _review_ply >= 0 else session.snapshot()
	var checked_square: int = -1
	if Rules.in_check(state, state.turn):
		checked_square = state.board.find("K" if state.turn == "w" else "k")
	board_view.show_highlights(selected, targets, moves.back()["from"] if not moves.is_empty() else -1, moves.back()["to"] if not moves.is_empty() else -1, checked_square)
	_update_keyboard_cursor()

func _undo() -> void:
	var was_white: bool = session.snapshot().turn == "w"
	if session.undo() and practice and was_white:
		session.undo()

func _flip() -> void:
	flipped = not flipped
	board_view.set_flipped(flipped)
	_settings["flipped"] = flipped
	_persist_preferences()
	_update_keyboard_cursor()

func _change_mode(index: int) -> void:
	practice = index == 0
	_settings["practice"] = practice
	_mode_picker.select(index)
	# Bump the session revision without changing history to invalidate old analysis.
	session.load_payload(session.save_payload())
	_persist_preferences()

func _save() -> void:
	var temporary: String = save_path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		notice_label.text = "Could not write a save. Your game is still here."
		return
	file.store_string(JSON.stringify(session.save_payload(), "\t"))
	file.flush()
	var write_error: Error = file.get_error()
	file.close()
	if write_error != OK or DirAccess.rename_absolute(temporary, save_path) != OK:
		notice_label.text = "Could not replace the save. Your game is still here."
		return
	notice_label.text = "Saved on this device."

func _load_save() -> void:
	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		notice_label.text = "No saved game yet. Use Save to keep this game."
		return
	if file.get_length() > 1048576:
		notice_label.text = "Save is too large. The current game was kept."
		return
	var parser := JSON.new()
	var parse_error: Error = parser.parse(file.get_as_text())
	file.close()
	if parse_error != OK:
		notice_label.text = "Save could not be read. The current game was kept."
		return
	var error: String = session.load_payload(parser.data)
	notice_label.text = "Saved game restored." if error.is_empty() else error

func _maybe_opponent() -> void:
	if practice and session.snapshot().turn == "b" and session.result().is_empty() and not _analysis_busy:
		_start_analysis("opponent")

func _hint() -> void:
	_start_analysis("hint")

func _start_analysis(purpose: String) -> void:
	if _analysis_busy or not session.result().is_empty():
		return
	_analysis_busy = true
	hint_button.disabled = true
	notice_label.text = "Considering replies…" if purpose == "opponent" else "Exploring candidates…"
	var state = session.snapshot()
	var revision: int = session.revision
	_worker = Thread.new()
	var error: Error = _worker.start(func():
		var response: Dictionary = Opponent.new().analyze(state, revision)
		_analysis_finished.call_deferred(response, purpose)
	)
	if error != OK:
		_analysis_busy = false
		notice_label.text = "The practice opponent could not start. Switch to two players to continue."
		hint_button.disabled = false

func _analysis_finished(response: Dictionary, purpose: String) -> void:
	if _worker != null and _worker.is_started():
		_worker.wait_to_finish()
	_worker = null
	_analysis_busy = false
	if _closing:
		return
	if response["revision"] != session.revision:
		notice_label.text = "Position changed; the old suggestion was discarded."
		_refresh()
		_maybe_opponent.call_deferred()
		return
	if purpose == "hint" and _review_ply >= 0:
		notice_label.text = "Return to Live to explore a candidate for the current game."
		return
	if purpose == "opponent":
		if practice and session.snapshot().turn == "b":
			_commit_move(response["move"], response["revision"])
	else:
		var candidate: Dictionary = response["move"]
		if not candidate.is_empty():
			selected = candidate["from"]
			_refresh_highlights()
			notice_label.text = "Try exploring %s. This shallow suggestion can miss tactics." % Rules.uci(candidate)
	hint_button.disabled = not session.result().is_empty() or _review_ply >= 0

func _commit_move(move: Dictionary, revision: int = -1) -> bool:
	_animate_next = true
	var accepted: bool = session.try_move(move, revision)
	_animate_next = false
	if accepted:
		_move_audio.play_move_sound()
	return accepted

func _review(direction: int) -> void:
	var current_ply: int = session.history().size() if _review_ply < 0 else _review_ply
	var target: int = clampi(current_ply + direction, 0, session.history().size())
	_review_ply = target if target < session.history().size() else -1
	selected = -1
	_refresh()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F:
			_flip()
		elif event.keycode == KEY_ESCAPE:
			selected = -1
			_refresh_highlights()

func _display_state():
	return session.snapshot_at(_review_ply) if _review_ply >= 0 else session.snapshot()

func _mouse_square(square: int) -> void:
	_board_surface.grab_focus()
	_keyboard_active = false
	_keyboard_square = square
	request_square(square)
	_update_keyboard_cursor()

func _board_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed:
		return
	var dx: int = 0
	var dy: int = 0
	match event.keycode:
		KEY_LEFT: dx = -1
		KEY_RIGHT: dx = 1
		KEY_UP: dy = 1
		KEY_DOWN: dy = -1
		KEY_ENTER, KEY_KP_ENTER, KEY_SPACE:
			if not event.echo:
				request_square(_keyboard_square)
		KEY_ESCAPE:
			selected = -1
			_refresh_highlights()
		KEY_F:
			if not event.echo:
				_flip()
		_:
			return
	if flipped:
		dx = -dx
		dy = -dy
	_keyboard_square = clampi(_keyboard_square / 8 + dy, 0, 7) * 8 + clampi(_keyboard_square % 8 + dx, 0, 7)
	_keyboard_active = true
	_update_keyboard_cursor()
	_board_surface.accept_event()

func _update_keyboard_cursor() -> void:
	if not is_instance_valid(board_view) or not is_instance_valid(_board_caption):
		return
	var active: bool = _keyboard_active and _board_surface.has_focus()
	board_view.show_keyboard_cursor(_keyboard_square if active else -1)
	if not active:
		_board_caption.text = "F: turn board  ·  Esc: clear  ·  Mouse wheel: zoom"
		return
	var state = _display_state()
	var piece: String = state.board[_keyboard_square]
	var names: Dictionary = {"p": "pawn", "n": "knight", "b": "bishop", "r": "rook", "q": "queen", "k": "king"}
	var description: String = "empty" if piece.is_empty() else ("White " if piece == piece.to_upper() else "Black ") + names[piece.to_lower()]
	var square_name: String = "abcdefgh"[_keyboard_square % 8] + str(_keyboard_square / 8 + 1)
	var destination: bool = false
	if selected >= 0 and _review_ply < 0:
		for move in session.legal_moves():
			if move["from"] == selected and move["to"] == _keyboard_square:
				destination = true
	_board_caption.text = "%s · %s%s" % [square_name, description, " · legal destination" if destination else (" · selected" if selected == _keyboard_square else "")]

func _persist_preferences() -> void:
	if Preferences.write_settings(preferences_path, _settings) != OK:
		notice_label.text = "Setting changed for this session; it could not be saved."

func _open_draw_claim() -> void:
	if _review_ply >= 0 or (practice and session.snapshot().turn == "b"):
		return
	if session.draw_claim_available():
		session.claim_draw()
		return
	_draw_moves = session.draw_claim_moves()
	if _draw_moves.is_empty():
		return
	_draw_revision = session.revision
	_draw_picker.clear()
	for move in _draw_moves:
		_draw_picker.add_item(Rules.san(session.snapshot(), move) + "  (" + Rules.uci(move) + ")")
	_draw_dialog.popup_centered(Vector2i(500, 180))
	_draw_picker.grab_focus()

func _confirm_draw_claim() -> void:
	if _draw_picker.selected >= 0 and _draw_picker.selected < _draw_moves.size():
		if not session.claim_draw_with_move(_draw_moves[_draw_picker.selected], _draw_revision):
			notice_label.text = "The position changed; the draw declaration was not applied."

func _open_export() -> void:
	# Capture the visible game's live record now; later moves cannot alter this export.
	_export_text = PGN.export_game(session)
	_export_dialog.popup_centered_ratio(0.7)

func _write_pgn(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		notice_label.text = "The game record could not be written. Your game is still here."
		return
	file.store_string(_export_text)
	file.flush()
	var error: Error = file.get_error()
	file.close()
	notice_label.text = "Game record exported." if error == OK else "The game record could not be written."

func _exit_tree() -> void:
	_closing = true
	if _worker != null and _worker.is_started():
		_worker.wait_to_finish()

func _capture(path: String) -> void:
	await get_tree().create_timer(2.0).timeout
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var error: Error = image.save_png(path)
	print("CAPTURE ", path, " result=", error)
	get_tree().quit(error)
