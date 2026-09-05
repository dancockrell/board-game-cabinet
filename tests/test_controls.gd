extends SceneTree
const Main = preload("res://app/main.tscn")
const Prefs = preload("res://core/preferences.gd")
var failures: int = 0
var app
var prefs_path: String

func expect(condition: bool, description: String) -> void:
	if not condition:
		failures += 1
		push_error(description)

func _initialize() -> void:
	_run.call_deferred()

func key(code: Key, viewport: Viewport = root) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	viewport.push_input(event, true)
	event = event.duplicate()
	event.pressed = false
	viewport.push_input(event, true)

func play(uci: String) -> void:
	for move in app.session.legal_moves():
		if app.Rules.uci(move) == uci:
			expect(app.session.try_move(move), "Fixture move " + uci)
			return
	expect(false, "Missing fixture move " + uci)

func capture(label: String) -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--qa-folder="):
			await process_frame
			await RenderingServer.frame_post_draw
			var path: String = argument.trim_prefix("--qa-folder=").path_join(label + ".png")
			expect(root.get_texture().get_image().save_png(path) == OK, "Save QA capture " + label)

func _run() -> void:
	prefs_path = "user://test-controls-%d.json" % OS.get_process_id()
	expect(Prefs.read_settings(prefs_path) == Prefs.DEFAULTS, "Missing preference file uses defaults")
	var file := FileAccess.open(prefs_path, FileAccess.WRITE)
	file.store_string("{broken")
	file.close()
	expect(Prefs.read_settings(prefs_path) == Prefs.DEFAULTS, "Malformed settings fall back safely")
	file = FileAccess.open(prefs_path, FileAccess.WRITE)
	file.store_string('{"version":1,"muted":"yes","flipped":true}')
	file.close()
	expect(Prefs.read_settings(prefs_path)["muted"] == false and Prefs.read_settings(prefs_path)["flipped"], "Invalid types do not corrupt valid preferences")
	expect(Prefs.write_settings(prefs_path, Prefs.DEFAULTS) == OK, "Settings write atomically")
	app = Main.instantiate()
	app.preferences_path = prefs_path
	root.add_child(app)
	await process_frame
	await process_frame
	app._change_mode(1)
	key(KEY_TAB)
	expect(app._board_surface.has_focus(), "Tab focuses board from initial screen")
	key(KEY_SPACE)
	expect(app.selected == 12, "Keyboard Space selects e2")
	key(KEY_UP)
	key(KEY_UP)
	expect(app._keyboard_square == 28, "Arrow keys reach e4")
	expect(app._board_caption.text.contains("legal destination"), "Keyboard caption identifies legal destination")
	key(KEY_ENTER)
	expect(app.session.snapshot().board[28] == "P" and app.session.snapshot().board[12] == "", "Keyboard plays complete e2e4 move")
	expect(app.board_view._cursor.get_child_count() == 8, "Keyboard cursor has visible corner brackets")
	await create_timer(0.3).timeout
	await capture("keyboard-play")
	key(KEY_F)
	key(KEY_UP)
	expect(app.flipped and app._keyboard_square == 20, "Arrow navigation follows flipped screen orientation")
	key(KEY_ESCAPE)
	expect(app.selected == -1, "Escape cancels selection")
	# Tab leaves the board, preserving access to the ordinary sidebar controls.
	key(KEY_TAB)
	expect(not app._board_surface.has_focus(), "Tab can leave board; focus is not trapped")
	# All promotion choices remain keyboard-accessible in a modal viewport.
	app.session.new_game()
	for uci in ["a2a4", "h7h5", "a4a5", "h5h4", "a5a6", "h4h3", "a6b7", "h3g2"]:
		play(uci)
	app._board_surface.grab_focus()
	app._keyboard_square = 49
	key(KEY_ENTER)
	# Flipped view: b7 to a8 is screen-right, screen-down.
	key(KEY_RIGHT)
	key(KEY_DOWN)
	key(KEY_ENTER)
	expect(app.promotion_dialog.visible, "Keyboard destination opens promotion")
	expect(app._promotion_buttons["q"].has_focus(), "Promotion starts with an explicit visible choice focused")
	app._promotion_buttons["n"].grab_focus()
	key(KEY_ENTER, app.promotion_dialog)
	expect(app.session.snapshot().board[56] == "N", "Keyboard confirms knight underpromotion")
	# Declare rather than play the prospective third repetition.
	app.session.new_game()
	for uci in ["g1f3", "g8f6", "f3g1", "f6g8", "g1f3", "g8f6", "f3g1"]:
		play(uci)
	var before: String = app.session.snapshot().to_fen()
	app._open_draw_claim()
	expect(app._draw_dialog.visible and not app.draw_button.disabled, "Prospective claim is available through deliberate dialog")
	await capture("draw-declaration")
	app._draw_dialog.hide()
	expect(app.session.result().is_empty(), "Closing declaration does not claim")
	app._open_draw_claim()
	app._confirm_draw_claim()
	expect(app.session.result() == "Draw claimed" and app.session.snapshot().to_fen() == before, "Declared draw ends game without playing move")
	# Export captures a stable game record even if the session subsequently changes.
	app._open_export()
	var export_text: String = app._export_text
	app._export_dialog.hide()
	app.session.new_game()
	var export_path: String = "user://test-controls-%d.pgn" % OS.get_process_id()
	app._write_pgn(export_path)
	expect(FileAccess.get_file_as_string(export_path) == export_text and export_text.contains("1/2-1/2"), "PGN export writes captured record")
	# Persist all supported preferences, then restart the application node.
	app._settings = {"muted": true, "flipped": true, "reduced_motion": true, "practice": false}
	app._persist_preferences()
	app.queue_free()
	await process_frame
	app = Main.instantiate()
	app.preferences_path = prefs_path
	root.add_child(app)
	await process_frame
	expect(app._move_audio.muted and app.flipped and app._reduced_motion and not app.practice, "Restart applies all persisted preferences")
	app._settings_dialog.popup_centered(Vector2i(400, 230))
	await capture("table-settings")
	app._settings_dialog.hide()
	app._commit_move({"from": 12, "to": 28, "promotion": ""})
	expect(app.board_view._movement_tweens.is_empty(), "Reduced motion snaps to authoritative destination")
	expect(app.board_view._snapshot == app.session.snapshot().board, "Reduced motion preserves authority")
	app.queue_free()
	await process_frame
	DirAccess.remove_absolute(prefs_path)
	DirAccess.remove_absolute(export_path)
	print("CONTROLS AND PREFERENCES: ", failures, " failures")
	quit(1 if failures else 0)
