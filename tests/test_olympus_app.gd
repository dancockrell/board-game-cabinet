extends SceneTree
## Native rendered integration; never reads or writes a player's save files.
const Battle = preload("res://app/olympus_arena.tscn")
var app
var checks := 0
var failures := 0

func _initialize() -> void:
	_run.call_deferred()

func expect(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(description)

func _run() -> void:
	root.size = Vector2i(1440, 960)
	app = Battle.instantiate()
	root.add_child(app)
	app.set_process(false)
	await process_frame
	await process_frame
	app.sound.set_muted(true)
	expect(app.board is Node3D and app.board.camera is Camera3D, "Native 3D board and camera")
	expect(not app.started and app.battle_overlay.visible, "Battle waits for explicit start")
	var initial: Dictionary = app.session.snapshot()
	app._process(0.2)
	expect(app.session.snapshot() == initial, "Opening screen never runs simulation")
	expect(app.cards.size() == 4, "Four visible hand cards")
	expect(app.surface.size.x == 1440 and app.surface.size.y >= 720, "Battlefield occupies the full screen width")
	for card in app.cards:
		expect(not app.surface.get_rect().intersects(card.button.get_rect()), "Hand stays outside deployment surface")
	var menu = app.get_node("MatchMenu").get_popup()
	menu.id_pressed.emit(1)
	expect(app.muted and not menu.is_item_checked(1), "Menu sound toggle mutes and updates check")
	menu.id_pressed.emit(1)
	expect(not app.muted and menu.is_item_checked(1), "Menu sound toggle restores sound")
	app.sound.set_muted(true)
	for slot in range(4):
		expect(app.cards[slot].name.text == app.catalog[initial.hand[slot]].name, "Card label agrees with authoritative hand")
		expect(app.cards[slot].icon.texture != null, "Card has an original portrait")
	for kind in app.catalog.keys():
		var art: AtlasTexture = app._texture(kind)
		expect(art != null and Rect2(Vector2.ZERO,art.atlas.get_size()).encloses(art.region), "Every card portrait has a valid atlas region")
	expect(app.get_node("NextArt").texture != null, "Next-card preview contains artwork")
	app._start_or_restart()
	expect(app.started and not app.paused and not app.battle_overlay.visible, "Start enters the battle")
	expect(app._countdown_remaining > 3.0, "Battle opens with a readable countdown")
	var countdown_state: Dictionary = app.session.snapshot()
	app._process(1.0)
	expect(app.session.snapshot() == countdown_state, "Countdown keeps the authoritative clock frozen")
	app._process(2.1)
	expect(app._countdown_remaining == 0.0, "Countdown completes before deployment")
	expect(app.notice.contains("Pick a card"), "Countdown hands control back with a useful instruction")
	app._select_card(0)
	expect(app.selected_slot == 0 and not app.selection_label.text.is_empty(), "Selecting card shows compact deployment guidance")
	var blue: Vector2 = app.board.camera.unproject_position(Vector3(-2.7, 0, 4))
	app._deploy_at(blue)
	expect(app.state.units.size() == 3, "Projected blue-half click deploys three hoplites")
	expect(is_equal_approx(app.state.energy[0], 2.0), "UI deployment spends exact card cost")
	expect(app.state.hand[0] == "heracles" and app.selected_slot == -1, "Successful deployment rotates hand and clears selection")
	expect(app.state == app.session.snapshot(), "Displayed state matches authoritative deployment")
	var waiting_card: Dictionary = app.cards[1]
	expect(waiting_card.icon.modulate != Color.WHITE and waiting_card.button.modulate == Color.WHITE, "Insufficient elixir dims portrait without dimming cost or text")
	expect(waiting_card.cost.text == str(app.catalog[app.state.hand[1]].cost), "Unaffordable card preserves its exact visible cost")
	app._select_card(1)
	expect(app.cards[1].button.get_theme_stylebox("normal").border_width_left == 3 and app.cards[1].button.get_theme_stylebox("hover").border_width_left == 3, "Selection outline remains visible while hovered")
	var before_invalid: Dictionary = app.session.snapshot()
	app._deploy_at(app.board.camera.unproject_position(Vector3(2.7, 0, -4)))
	expect(app.session.snapshot() == before_invalid, "Enemy-half click is atomic and rejected")
	expect(app.notice.contains("your side"), "Illegal placement explains the correction")
	app._toggle_pause()
	var before_pause: Dictionary = app.session.snapshot()
	var visual_time_before_pause: float = app.board._time
	app._process(0.2)
	expect(app.board._time == visual_time_before_pause, "Pause freezes board animation time as well as simulation")
	expect(app.session.snapshot() == before_pause and app.pause_button.text == "Resume", "Pause holds authoritative time and updates control")
	app._toggle_pause()
	app._process(0.2)
	expect(app.state.elapsed > before_pause.elapsed and app.pause_button.text == "Pause", "Resume advances fixed-step simulation")
	# Exercise the drag gesture's actual press/release handlers and board projection.
	for tick in range(28): app.session.tick()
	app._refresh()
	var drag := InputEventMouseButton.new()
	drag.button_index = MOUSE_BUTTON_LEFT
	drag.pressed = true
	app._card_input(drag, 1)
	expect(app.drag_proxy.visible, "Dragging lifts a translucent card portrait")
	var before_drag: Dictionary = app.session.snapshot()
	drag = InputEventMouseButton.new()
	drag.button_index = MOUSE_BUTTON_LEFT
	drag.pressed = false
	drag.position = app.surface.global_position + blue
	app._input(drag)
	expect(not app._dragging and not app.drag_proxy.visible and app.selected_slot == -1, "Card drag release clears gesture state")
	expect(app.session.snapshot().hand[1] != before_drag.hand[1], "Card drag places the chosen card and rotates its slot")
	for tick in range(140): app.session.tick()
	app._refresh()
	await _capture("olympus-arena-playing.png")
	# Play an actual complete simulation from this opening, without inventing a winner.
	var ticks := 0
	while app.session.snapshot().phase == "playing" and ticks < 2401:
		app.session.tick()
		ticks += 1
		if ticks % 100 == 0: app._refresh()
	app._refresh()
	expect(app.state.phase == "finished", "Actual complete battle reaches its result")
	expect(app.state == app.session.snapshot(), "Final presentation matches authoritative match")
	expect(app.battle_overlay.visible and app.start_button.text == "REMATCH", "Completed battle offers rematch")
	var expected_title := "VICTORY!" if app.state.winner == 0 else "DEFEAT" if app.state.winner == 1 else "DRAW"
	expect(app.overlay_title.text == expected_title, "Result title matches actual winner")
	await _capture("olympus-arena-result.png")
	app._start_or_restart()
	expect(app.state.elapsed == 0 and app.state.phase == "playing" and app.state.units.is_empty(), "Rematch clears old battle state")
	# Explicit presentation fixtures cover result branches, separate from the actual match above.
	for winner in [0, 2]:
		app.session._state.phase = "finished"
		app.session._state.winner = winner
		app._refresh()
		expect(app.overlay_title.text == ("VICTORY!" if winner == 0 else "DRAW"), "Result fixture renders requested winner branch")
		app._start_or_restart()
	print("Olympus native app: %d checks, %d failures" % [checks, failures])
	app.queue_free()
	await process_frame
	quit(1 if failures else 0)

func _capture(filename: String) -> void:
	var directory := ""
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-dir="):
			directory = argument.trim_prefix("--capture-dir=")
	if directory.is_empty(): return
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var result := root.get_texture().get_image().save_png(directory.path_join(filename))
	expect(result == OK, "Native screenshot writes " + filename)
