extends SceneTree
## Native 30 fps gameplay evidence. Example:
## godot --path . --script res://tools/capture_olympus_motion.gd -- --capture-dir=C:/captures/olympus-motion
## Encode without retiming: ffmpeg -framerate 30 -i frame-%04d.png -c:v libx264 -pix_fmt yuv420p gameplay.mp4
const Battle = preload("res://app/olympus_arena.tscn")
const FPS := 30
const WARMUP_FRAMES := 38 * FPS
const CAPTURE_FRAMES := 6 * FPS
var warmup_frames := WARMUP_FRAMES
var pixel_attack_frames := 0
var pixel_walk_frames := 0
var wait_for_thrust := false
var app
var directory := ""
var placements := 0
var last_slot := -1
var lane := 0

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument=="--wait-for-thrust": wait_for_thrust=true
		if argument.begins_with("--warmup-seconds="):
			warmup_frames=clampi(int(argument.trim_prefix("--warmup-seconds=")),0,150)*FPS
		if argument.begins_with("--capture-dir="):
			directory = argument.trim_prefix("--capture-dir=")
	if directory.is_empty():
		push_error("Pass an explicit --capture-dir= absolute output directory.")
		quit(2)
		return
	if not directory.is_absolute_path():
		push_error("Capture directory must be absolute.")
		quit(2)
		return
	var error := DirAccess.make_dir_recursive_absolute(directory)
	if error != OK:
		push_error("Cannot create capture directory: %s" % error_string(error))
		quit(2)
		return
	root.size = Vector2i(1440, 960)
	root.content_scale_size = Vector2i(1440, 960)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	root.gui_disable_input = true
	app = Battle.instantiate()
	root.add_child(app)
	app.set_process(false)
	app.set_process_input(false)
	app.set_process_unhandled_input(false)
	await process_frame
	await process_frame
	app.sound.set_muted(true)
	app._start_or_restart()
	app._countdown_remaining = 0.0
	app.notice = ""
	app.session.new_game(42)
	app._refresh()
	# Every simulation step is rendered during warmup so recent effects expire normally.
	# No snapshot surgery, instant troop spawns, or fabricated combat events are used.
	if wait_for_thrust: warmup_frames=120*FPS
	var found_thrust:=false
	for frame in warmup_frames:
		_advance(frame)
		await process_frame
		await RenderingServer.frame_post_draw
		if wait_for_thrust:
			for token in app.board._tokens.values():
				var sprite=token.get_node_or_null("Figure/PixelActor")
				if sprite != null and sprite.clip in [app.board.THRUST_CLIP,app.board.NORTH_ATTACK,app.board.SOUTH_ATTACK,app.board.WEST_ATTACK]: found_thrust=true
			if found_thrust:
				# End on a complete three-frame simulation interval.
				if frame%3==2:
					warmup_frames=frame+1
					break
	if wait_for_thrust and not found_thrust:
		push_error("No Hoplite thrust observed within 120 seconds of legal play")
		quit(1)
		return
	print("Motion capture warmup complete at %.1f seconds; %d legal player placements." % [app.state.elapsed, placements])
	Engine.max_fps = FPS
	for frame in CAPTURE_FRAMES:
		_advance(warmup_frames + frame)
		await process_frame
		await RenderingServer.frame_post_draw
		for token in app.board._tokens.values():
			var sprite=token.get_node_or_null("Figure/PixelActor")
			if sprite != null and sprite.clip in [app.board.THRUST_CLIP,app.board.NORTH_ATTACK,app.board.SOUTH_ATTACK,app.board.WEST_ATTACK]: pixel_attack_frames+=1
			if sprite != null and sprite.clip == app.board.NORTH_WALK: pixel_walk_frames+=1
		var filename := "frame-%04d.png" % frame
		error = root.get_texture().get_image().save_png(directory.path_join(filename))
		if error != OK:
			push_error("Capture failed: %s" % filename)
			quit(1)
			return
	var expected_elapsed := float(warmup_frames + CAPTURE_FRAMES) / FPS
	if not is_equal_approx(float(app.state.elapsed), expected_elapsed):
		push_error("Capture timeline changed unexpectedly; expected %.1f seconds, got %s" % [expected_elapsed, app.state.elapsed])
		quit(1)
		return
	var metadata := {
		"scene": "res://app/olympus_arena.tscn", "seed": 42,
		"fps": FPS, "frames": CAPTURE_FRAMES, "duration_seconds": 6,
		"pixel_attack_actor_frames":pixel_attack_frames, "warmup_seconds": float(warmup_frames) / FPS, "simulation_tick_seconds": 0.1,
		"pixel_walk_actor_frames":pixel_walk_frames,
		"player_legal_placements": placements,
		"final_elapsed": app.state.elapsed,
		"final_unit_count": app.state.units.size(),
		"capture": "Native rendered frames, sequential gameplay, no retiming"
	}
	var file := FileAccess.open(directory.path_join("capture.json"), FileAccess.WRITE)
	if file == null:
		push_error("Could not write capture metadata.")
		quit(1)
		return
	file.store_string(JSON.stringify(metadata, "\t"))
	file.close()
	print("Motion capture complete: %d frames at %d fps; %.1f seconds authoritative match time." % [CAPTURE_FRAMES, FPS, app.state.elapsed])
	app.queue_free()
	await process_frame
	quit(0)

func _advance(frame: int) -> void:
	# Integer frame scheduling gives exactly one 0.1 s rules tick per three images.
	if frame % 3 == 0:
		if frame % 30 == 0: _deploy_player()
		app.session.tick()
		app._refresh()
	app.board.show_state(app.state, 1.0 / FPS)
	if app.board.ambient_life: app.board.ambient_life.advance(1.0 / FPS, false)

func _deploy_player() -> void:
	var state: Dictionary = app.session.snapshot()
	if state.phase != "playing": return
	for offset in 4:
		var slot := (last_slot + 1 + offset) % 4
		var kind: String = state.hand[slot]
		var position := Vector2(-2.7 if lane % 2 == 0 else 2.7, 1.3)
		if kind == "thunderbolt":
			position = Vector2(position.x, -3.0)
			for unit in state.units:
				if int(unit.side) == 1:
					position = Vector2(float(unit.x), float(unit.z))
					break
		var result: Dictionary = app.session.deploy(slot, position)
		if bool(result.get("ok", false)):
			placements += 1
			last_slot = slot
			lane += 1
			return
