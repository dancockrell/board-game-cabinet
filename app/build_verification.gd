extends RefCounted
## Explicit release diagnostic; never enabled by normal launch or player UI.
var failures: Array[String] = []
var placements := 0
var walk_samples := 0
var collapse_samples := 0
var pixel_characters: Array[String] = []
var animated_idle_samples := 0
var flight_samples := 0
var clip_frames := {}
var drawn_defeat_samples := 0
var defeat_frames := {}

func run(app: Control, directory: String) -> void:
	if not directory.is_absolute_path() or DirAccess.make_dir_recursive_absolute(directory) != OK:
		push_error("Build verification requires a writable absolute directory")
		app.get_tree().quit(2)
		return
	app.set_process(false)
	app.set_process_input(false)
	app.set_process_unhandled_input(false)
	app.get_tree().root.gui_disable_input=true
	app.sound.set_muted(true)
	app._start_or_restart()
	app._countdown_remaining=0.0
	app.session.new_game(42)
	app._refresh()
	var ticks := 0
	while app.state.phase == "playing" and ticks < 3000:
		if ticks % 10 == 0:
			# Reserve elixir for an unseen roster card instead of repeatedly
			# spending on cheap cards and depending on the opponent for coverage.
			var slots: Array[int] = []
			for slot in 4:
				if app.state.hand[slot] != "thunderbolt" and not pixel_characters.has(app.state.hand[slot]): slots.append(slot)
			if slots.is_empty(): slots.assign([0,1,2,3])
			else: slots.resize(1)
			for slot in slots:
				var location := Vector2(-2.7 if placements % 2 == 0 else 2.7, 1.3)
				if app.state.hand[slot] == "thunderbolt": location.y=-3.0
				if app.session.deploy(slot, location).get("ok", false):
					placements+=1
					break
		app.session.tick()
		app._refresh()
		app.board.show_state(app.state, .1)
		for token in app.board._tokens.values():
			var sprite=token.get_node_or_null("Figure/PixelActor")
			if sprite != null:
				var kind=str(token.get_meta("kind", ""))
				if not pixel_characters.has(kind): pixel_characters.append(kind)
				var path := str(sprite.clip.resource_path)
				if path.is_empty(): path = "runtime_rest"
				var identity: String = kind + ":" + path
				if not clip_frames.has(identity): clip_frames[identity] = []
				if not clip_frames[identity].has(sprite._shown): clip_frames[identity].append(sprite._shown)
				if sprite._motion_clip != null and sprite.clip == sprite._motion_clip:
					if kind == "harpies": flight_samples+=1
					else: walk_samples+=1
				elif sprite.clip == sprite._rest_clip and sprite.clip.regions.size() > 1:
					animated_idle_samples+=1
		for departure in app.board._departures:
			if departure.drawn_actor != null:
				drawn_defeat_samples+=1
				var path=str(departure.drawn_actor.clip.resource_path)
				if not defeat_frames.has(path): defeat_frames[path]=[]
				if not defeat_frames[path].has(departure.drawn_actor._shown): defeat_frames[path].append(departure.drawn_actor._shown)
		if not app.board._collapses.is_empty():
			collapse_samples+=1
			if collapse_samples in [2,5,9]: await _capture(app,directory.path_join("collapse-%02d.png" % collapse_samples))
		ticks+=1
		await app.get_tree().process_frame
		if ticks in [50,300]: await _capture(app, directory.path_join("battle-%04d.png" % ticks))
	_check(app.state.phase == "finished", "Match reaches terminal state within 300 seconds")
	_check(app.state == app.session.snapshot(), "Displayed result matches authoritative state")
	_check(placements > 0, "Player made legal deployments")
	for kind in ["hoplites","atalanta","medusa","minotaur","heracles","hydra","harpies"]:
		_check(pixel_characters.has(kind), "Match exercises character: " + kind)
	_check(collapse_samples > 0, "Match exercises building collapse")
	_check(drawn_defeat_samples > 0, "Match exercises authored character defeat")
	_check(walk_samples > 0, "Export contains active walking sprites")
	_check(app.battle_overlay.visible and app.start_button.text == "REMATCH", "Result screen offers rematch")
	var expected := "VICTORY!" if app.state.winner == 0 else "DEFEAT" if app.state.winner == 1 else "DRAW"
	_check(app.overlay_title.text == expected, "Result title agrees with winner")
	if float(app.state.time_remaining) < 0.00001:
		_check(app.timer_label.text == "0:00", "Expired match clock displays zero")
	await _capture(app, directory.path_join("result.png"))
	var report := {"seed":42, "ticks":ticks, "simulation_seconds":app.state.elapsed,
		"collapse_samples":collapse_samples,"pixel_characters":pixel_characters,
		"animated_idle_samples":animated_idle_samples,"flight_samples":flight_samples,
		"observed_clip_frames":clip_frames,"drawn_defeat_samples":drawn_defeat_samples,"observed_defeat_frames":defeat_frames,
		"winner":app.state.winner, "legal_deployments":placements, "walking_actor_samples":walk_samples,
		"timing":"Accelerated simulation with one native render opportunity per 0.1-second tick; not real-time video",
		"exported":not OS.has_feature("editor"), "executable":OS.get_executable_path()}
	app._start_or_restart()
	_check(app.state.phase == "playing" and app.state.elapsed == 0 and app.state.units.is_empty(), "Rematch resets match state")
	report["failures"]=failures
	report["passed"]=failures.is_empty()
	var file := FileAccess.open(directory.path_join("verification.json"), FileAccess.WRITE)
	if file == null:
		push_error("Cannot write verification report")
		app.get_tree().quit(2)
		return
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print("Export match verification: %d ticks, %d legal deployments, %d failures" % [ticks,placements,failures.size()])
	app.get_tree().quit(0 if failures.is_empty() else 1)

func _check(condition: bool, description: String) -> void:
	if not condition:
		failures.append(description)
		push_error(description)

func _capture(app: Control, path: String) -> void:
	await app.get_tree().process_frame
	await RenderingServer.frame_post_draw
	_check(app.get_viewport().get_texture().get_image().save_png(path) == OK, "Native screenshot writes " + path.get_file())
