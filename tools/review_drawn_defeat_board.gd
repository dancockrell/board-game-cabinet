extends SceneTree
func _initialize(): run.call_deferred()
func run():
	var output=""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="): output=arg.trim_prefix("--capture=")
	if not output.is_absolute_path(): quit(2); return
	DirAccess.make_dir_recursive_absolute(output)
	var board=preload("res://presentation/olympus_arena_board.gd").new()
	root.add_child(board)
	var state={"units":[{"id":1,"kind":"medusa","side":0,"x":-1.0,"z":2.0,"hp":100.0,"max_hp":100.0},{"id":2,"kind":"medusa","side":1,"x":1.0,"z":2.0,"hp":100.0,"max_hp":100.0}],"towers":[],"events":[],"elapsed":1.0}
	board.show_state(state,0.0)
	board._face_pixel_unit(board._tokens[1],Vector2.UP)
	board._face_pixel_unit(board._tokens[2],Vector2.DOWN)
	board.camera.size=6
	board.camera.position=Vector3(0,10.5,14)
	board.camera.look_at(Vector3(0,.5,2))
	for frame in 60:
		if frame==12:
			state.units=[]
			state.elapsed=1.1
		board.show_state(state,1.0/30.0)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(output.path_join("frame-%03d.png"%frame))
	print("Two facing-specific drawn removals captured; cosmetic actors only")
	quit(0)
