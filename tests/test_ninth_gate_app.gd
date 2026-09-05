extends SceneTree
## Presentation/session integration. Never touches the player's saved battle.
const Battle = preload("res://app/ninth_gate.tscn")
var failures := 0
var checks := 0
var app

func expect(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(description)

func _initialize() -> void:
	_run.call_deferred()

func _key(code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	root.push_input(event, true)
	event = event.duplicate()
	event.pressed = false
	root.push_input(event, true)

func _without_revision(state: Dictionary) -> Dictionary:
	var copy := state.duplicate(true)
	copy.erase("revision")
	return copy

func _run() -> void:
	root.size = Vector2i(1440, 960)
	app = Battle.instantiate()
	root.add_child(app)
	await process_frame
	await process_frame
	var initial: Dictionary = app.session.snapshot()
	expect(app.observed.round == 1 and app.observed.phase == "orders", "Initial planning round")
	expect(app.round_label.text.contains("ROUND 1 / 12"), "Round label reflects session")
	expect(app.observed == app.session.view_for("heaven"), "Presentation consumes the filtered player view")
	expect(initial.units.size() == 12 and app.observed.units.size() == 6, "Unseen enemy counters do not reach presentation")
	for unit in app.observed.units:
		expect(unit.side == "heaven", "Initial visible counter belongs to Heaven")
	for private_key in ["rng", "seed", "reports"]:
		expect(not app.observed.has(private_key), "Referee information stays out of view: " + private_key)
	app._select_cell(Vector2i(2, 1))
	expect(app.selected == "heaven0", "Friendly cell selects its unit")
	app._select_cell(Vector2i(3, 1))
	expect(app.orders.size() == 1 and app.orders[0].type == "move", "Destination drafts a legal move")
	expect(app.session.snapshot() == initial, "Drafting never moves authoritative counters")
	app._commit()
	expect(app.session.snapshot().round == 2, "Commit advances one simultaneous round")
	expect(app.orders.is_empty() and app.selected.is_empty(), "Successful commit clears transient planning state")
	expect(app.observed == app.session.view_for("heaven"), "Commit refreshes the observed view")
	app._undo()
	expect(_without_revision(app.session.snapshot()) == _without_revision(initial), "Undo restores complete position and random state")
	expect(app.observed.revision > initial.revision, "Undo advances revision to invalidate stale orders")
	# Replacement orders count once; a fourth distinct unit cannot be drafted.
	for y in range(1, 5):
		app._select_cell(Vector2i(2, y))
		app._select_cell(Vector2i(3, y))
	expect(app.orders.size() == 3, "UI enforces the three-unit command budget")
	app._select_cell(Vector2i(2, 1))
	app._select_cell(Vector2i(1, 1))
	expect(app.orders.size() == 3 and app.orders[-1].x == 1, "Replacing one unit order preserves command budget")
	expect(_without_revision(app.session.snapshot()) == _without_revision(initial), "Several drafts still leave authority unchanged")
	# A stale draft must be rejected without overwriting the newer session.
	expect(app.session.resolve_round([]).ok, "Prepare an external round change")
	var newer: Dictionary = app.session.snapshot()
	app._commit()
	expect(app.session.snapshot() == newer, "Stale UI submission cannot advance or overwrite the session")
	expect(app.notice.contains("changed"), "Stale submission gives actionable feedback")
	app._new_battle()
	app.grab_focus()
	app.cursor = Vector2i(1, 1)
	_key(KEY_RIGHT)
	_key(KEY_ENTER)
	expect(app.cursor == Vector2i(2, 1) and app.selected == "heaven0", "Focused board accepts arrow and Enter selection")
	_key(KEY_RIGHT)
	_key(KEY_SPACE)
	expect(app.orders.size() == 1, "Keyboard Space drafts a destination")
	_key(KEY_ESCAPE)
	expect(app.selected.is_empty(), "Escape clears keyboard selection")
	app._new_battle()
	# Three rounds of advance provide an optional actual gameplay capture.
	for round_index in 3:
		for unit_id in ["heaven0", "heaven2", "heaven5"]:
			for order in app.session.legal_orders(unit_id, "heaven"):
				if order.type == "move":
					var unit: Dictionary = app.session._unit(app.session.snapshot(), unit_id)
					if order.x == unit.x + 1:
						app._draft(order)
						break
		app._commit()
	expect(app.observed.round == 4, "Three playable rounds reach round four")
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--qa-folder="):
			await process_frame
			await RenderingServer.frame_post_draw
			var path := argument.trim_prefix("--qa-folder=").path_join("ninth-gate-playing.png")
			expect(root.get_texture().get_image().save_png(path) == OK, "Gameplay screenshot saved")
	# Complete the battle through the UI with legal orders from player knowledge.
	for remaining in 12:
		if app.observed.phase == "finished":
			break
		var attack_orders: Array = []
		var rally_orders: Array = []
		for unit in app.observed.units:
			if unit.side != "heaven":
				continue
			var chosen: Dictionary = {}
			for order in app.session.legal_orders(unit.id, "heaven"):
				if order.type == "rally":
					chosen = order
				if order.type == "attack":
					chosen = order
					break
			if chosen.get("type") == "attack":
				attack_orders.append(chosen)
			elif not chosen.is_empty():
				rally_orders.append(chosen)
		attack_orders.append_array(rally_orders)
		for order in attack_orders.slice(0, 3):
			app._draft(order)
		var previous_revision: int = app.observed.revision
		app._commit()
		expect(app.observed.revision > previous_revision, "Full battle commit advances revision")
	var final_state: Dictionary = app.session.snapshot()
	expect(final_state.phase == "finished" and final_state.round <= 12, "Battle reaches a bounded terminal result")
	expect(final_state.winner in ["heaven", "hell", "draw"], "Terminal winner is defined")
	expect(app.details.text.contains("BATTLE ENDED") and app.details.text.contains(str(final_state.winner).to_upper()), "Result panel matches authoritative winner")
	expect(app.observed == app.session.view_for("heaven"), "Terminal presentation remains a filtered session view")
	var restored = app.Session.new()
	var serialized = JSON.parse_string(JSON.stringify(app.session.save_data()))
	var load_result: Dictionary = restored.load_data(serialized)
	expect(load_result.ok, "Completed battle loads after an actual JSON round trip: " + str(load_result))
	expect(_without_revision(restored.snapshot()) == _without_revision(final_state), "Reloaded final position, score, reports and random state match")
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--end-capture="):
			await process_frame
			await RenderingServer.frame_post_draw
			expect(root.get_texture().get_image().save_png(argument.trim_prefix("--end-capture=")) == OK, "Result screenshot saved")
	app.queue_free()
	await process_frame
	print("Ninth Gate app: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
