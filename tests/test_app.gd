extends SceneTree
## Run with native OpenGL, not the headless dummy mesh renderer.
const Main = preload("res://app/main.tscn")
var failures: int = 0
var app

func expect(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		push_error(label)

func _initialize() -> void:
	_run.call_deferred()

func click(square: int) -> void:
	var point: Vector2 = app.board_view._camera.unproject_position(app.board_view.square_position(square))
	var event := InputEventMouseButton.new()
	event.position = point
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	app.board_viewport.push_input(event, true)
	event = event.duplicate()
	event.pressed = false
	app.board_viewport.push_input(event, true)

func play(uci: String) -> void:
	for move in app.session.legal_moves():
		if app.Rules.uci(move) == uci:
			expect(app.session.try_move(move), "Accept fixture move " + uci)
			return
	expect(false, "Fixture missing " + uci)

func _run() -> void:
	app = Main.instantiate()
	app.save_path = "user://test-cabinet-%d.json" % OS.get_process_id()
	app.preferences_path = "user://test-cabinet-prefs-%d.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	await process_frame
	app._change_mode(1)
	await process_frame
	var initial: String = app.session.snapshot().to_fen()
	for flipped in [false, true]:
		app.board_view.set_flipped(flipped)
		for square in range(64):
			var point: Vector2 = app.board_view._camera.unproject_position(app.board_view.square_position(square))
			expect(app.board_view.screen_to_square(point) == square, "Picking all squares in both orientations")
	app.board_view.set_flipped(false)
	click(12)
	await process_frame
	expect(app.selected == 12, "Viewport mouse selects e2 pawn")
	expect(app.board_view._markers.get_child_count() >= 6, "Selected pawn has outline and two legal dots")
	click(28)
	await process_frame
	expect(app.session.snapshot().board[28] == "P" and app.session.snapshot().board[12] == "", "Viewport mouse plays e2e4")
	expect(app.board_view._snapshot == app.session.snapshot().board, "View equals authoritative board after move")
	expect(app.history_label.text.contains("e4"), "SAN record shows e4")
	var live_revision: int = app.session.revision
	app._start_analysis("hint")
	app._review(-1)
	while app._analysis_busy:
		await process_frame
	expect(app.selected == -1, "Pending live hint cannot mark a historical board")
	expect(app.board_view._snapshot == app.session.snapshot_at(0).board, "Review renders earlier snapshot")
	expect(app.session.revision == live_revision and app.session.history().size() == 1, "Review leaves live state unchanged")
	app.request_square(52)
	expect(app.selected == -1, "Review rejects board interaction")
	app._review(1)
	expect(app._review_ply == -1 and app.board_view._snapshot == app.session.snapshot().board, "Review returns to live board")
	app._save()
	expect(app.notice_label.text == "Saved on this device.", "Actual save succeeds")
	app._save()
	expect(app.notice_label.text == "Saved on this device.", "Atomic save replacement succeeds")
	app._undo()
	expect(app.session.snapshot().to_fen() == initial, "UI undo restores start")
	app._load_save()
	expect(app.session.snapshot().board[28] == "P", "UI load restores save")
	var valid: String = app.session.snapshot().to_fen()
	var file := FileAccess.open(app.save_path, FileAccess.WRITE)
	file.store_string("broken JSON")
	file.close()
	app._load_save()
	expect(app.session.snapshot().to_fen() == valid, "Corrupt save does not replace position")
	# Mid-search undo cannot apply an obsolete hint or computer move.
	app._start_analysis("hint")
	app._undo()
	while app._analysis_busy:
		await process_frame
	expect(app.session.snapshot().to_fen() == initial, "Stale analysis leaves undone position intact")
	# En-passant presentation derives removal from the accepted state.
	for uci in ["e2e4", "a7a6", "e4e5", "d7d5", "e5d6"]:
		play(uci)
	expect(app.board_view._snapshot[35] == "" and app.board_view._snapshot[43] == "P", "En passant removes pawn from view")
	app.session.new_game()
	for uci in ["g1f3", "g8f6", "g2g3", "g7g6", "f1g2", "f8g7", "e1g1"]:
		play(uci)
	expect(app.board_view._snapshot[6] == "K" and app.board_view._snapshot[5] == "R" and app.board_view._snapshot[7] == "", "Castling renders both pieces")
	# Reach a legal promotion through ordinary accepted moves, exercise the chooser.
	app.session.new_game()
	for uci in ["a2a4", "h7h5", "a4a5", "h5h4", "a5a6", "h4h3", "a6b7", "h3g2"]:
		play(uci)
	app.request_square(49)
	app.request_square(56)
	expect(app.promotion_dialog.visible, "Promotion shows chooser before commit")
	expect(app.session.snapshot().board[49] == "P", "Pawn remains authoritative until choice")
	app._promote("n")
	expect(app.session.snapshot().board[56] == "N" and app.board_view._snapshot[56] == "N", "Underpromotion reaches state and view")
	app.session.new_game()
	for uci in ["f2f3", "e7e5", "g2g4", "d8h4"]:
		play(uci)
	expect(app.session.result().contains("Checkmate") and app.status_label.text.contains("Black wins"), "Completed game announces checkmate winner")
	app.request_square(12)
	expect(app.selected == -1, "Completed game rejects board input")
	app._undo()
	expect(app.session.result().is_empty() and app.board_view._snapshot == app.session.snapshot().board, "Undo reopens completed game coherently")
	# A real practice response completes and is undoable as a player turn.
	app.session.new_game()
	app._change_mode(0)
	click(12)
	click(28)
	app._hint()
	await process_frame
	while app._analysis_busy:
		await process_frame
	expect(app.session.history().size() == 2 and app.session.snapshot().turn == "w", "Working practice opponent replies legally")
	app._undo()
	expect(app.session.snapshot().to_fen() == initial, "Practice undo takes back both plies")
	app._change_mode(1)
	for uci in ["e2e4", "e7e5", "g1f3", "b8c6"]:
		play(uci)
	click(5)
	await process_frame
	await RenderingServer.frame_post_draw
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--test-capture="):
			var result: Error = root.get_texture().get_image().save_png(argument.trim_prefix("--test-capture="))
			expect(result == OK, "Integration capture saved")
	DirAccess.remove_absolute(app.save_path)
	DirAccess.remove_absolute(app.preferences_path)
	app.queue_free()
	await process_frame
	await process_frame
	print("APP INTEGRATION: ", failures, " failures")
	quit(1 if failures else 0)
