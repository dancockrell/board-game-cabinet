extends SceneTree
const Walk = preload("res://themes/medusa_south_walk.tres")
const Rest = preload("res://themes/medusa_south_rest.tres")
func _initialize(): run.call_deferred()
func run():
	if not Walk.validation_error().is_empty(): push_error(Walk.validation_error()); quit(1); return
	var output = ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="): output = arg.trim_prefix("--capture=")
	if not output.is_absolute_path(): quit(2); return
	root.size = Vector2i(1280,800)
	var board = preload("res://presentation/olympus_arena_board.gd").new()
	root.add_child(board)
	board.camera.size = 6.0
	board.camera.position = Vector3(0,10.5,14)
	board.camera.look_at(Vector3(0,.6,3))
	var actor = preload("res://presentation/pixel_actor.gd").new()
	actor.pixel_size = .003
	board.add_child(actor)
	actor.position = Vector3(0,.15,3)
	actor.reset_playback(Rest)
	DirAccess.make_dir_recursive_absolute(output)
	for frame in 90:
		if frame == 12: actor.reset_playback(Walk)
		if frame == 72: actor.reset_playback(Rest)
		if frame >= 12 and frame < 72: actor.show_time((frame-12)/30.0)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(output.path_join("frame-%03d.png" % frame))
	print("Medusa south walk: 90 native frames with rest/walk/rest captured")
	quit(0)
