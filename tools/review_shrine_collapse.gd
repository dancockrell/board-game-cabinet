extends SceneTree
func _initialize(): run.call_deferred()
func run():
	var output := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="): output=arg.trim_prefix("--capture=")
	if not output.is_absolute_path(): quit(2); return
	DirAccess.make_dir_recursive_absolute(output)
	root.size=Vector2i(1280,800)
	var board=preload("res://presentation/olympus_arena_board.gd").new()
	root.add_child(board)
	var state={"units":[],"towers":[{"id":"study_small","side":0,"kind":"tower","x":-1.6,"z":2.0,"hp":100.0,"max_hp":100.0},{"id":"study_large","side":1,"kind":"temple","x":1.6,"z":2.0,"hp":100.0,"max_hp":100.0}],"elapsed":1.0,"events":[]}
	board.show_state(state,0.0)
	board.camera.size=6.5
	board.camera.position=Vector3(0,10.5,14)
	board.camera.look_at(Vector3(0,.8,2))
	for frame in 110:
		if frame==12:
			for tower in state.towers: tower.hp=0.0
		state.elapsed+=1.0/60.0
		board.show_state(state,1.0/60.0)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(output.path_join("frame-%03d.png"%frame))
	print("Shrine collapse: 110 native60fps frames, both building sizes and settled rubble")
	quit(0)
