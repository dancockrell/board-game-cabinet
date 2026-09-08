extends SceneTree
func _initialize(): run.call_deferred()
func run():
	var output:=""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="): output=arg.trim_prefix("--capture=")
	if not output.is_absolute_path(): quit(2); return
	DirAccess.make_dir_recursive_absolute(output)
	var board=preload("res://presentation/olympus_arena_board.gd").new()
	root.add_child(board)
	var state={"units":[{"id":1,"kind":"heracles","side":0,"x":-1.0,"z":2.0,"hp":640.0,"max_hp":640.0}],"towers":[],"events":[],"elapsed":1.0}
	board.show_state(state,0.0)
	board.camera.size=5.0
	board.camera.position=Vector3(0,10.5,14)
	board.camera.look_at(Vector3(0,.8,2))
	for frame in 100:
		if frame%3==0:
			state.elapsed+=.1
			if frame>=12 and frame<78: state.units[0].x+=.075
		board.show_state(state,1.0/30.0)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(output.path_join("frame-%03d.png"%frame))
	print("Heracles board study: authoritative east movement, four drawn poses, stopped recovery")
	quit(0)
