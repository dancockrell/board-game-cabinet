extends SceneTree
## Native close-up wind review. Does not simulate a game.
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	root.size = Vector2i(900,700)
	var board = preload("res://presentation/olympus_arena_board.gd").new()
	root.add_child(board)
	var stage = board.get_node("OlympusStage")
	board.camera.size = 3.8
	board.camera.position = Vector3(5.7,8.0,17.8)
	board.camera.look_at(Vector3(5.7,0.7,7.8))
	var output := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="): output=arg.trim_prefix("--output=")
	if output.is_empty(): quit(1); return
	DirAccess.make_dir_recursive_absolute(output)
	for i in 90:
		stage.advance_visual(1.0/30.0)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(output.path_join("frame-%04d.png" % i))
	print("Native garden breeze study: 90 frames")
	board.free()
	quit()
