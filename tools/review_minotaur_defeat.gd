extends SceneTree
const Defeat=preload("res://themes/minotaur_north_defeat.tres")
const Rest=preload("res://themes/minotaur_north_rest.tres")
func _initialize(): run.call_deferred()
func run():
	var output:=""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="): output=arg.trim_prefix("--capture=")
	if not output.is_absolute_path(): quit(2); return
	root.size=Vector2i(960,640)
	var board=preload("res://presentation/olympus_arena_board.gd").new()
	root.add_child(board)
	board.camera.size=7.0
	board.camera.position=Vector3(0,10.5,14)
	board.camera.look_at(Vector3(0,.65,3))
	var actors:Array=[]
	for i in 2:
		var actor=preload("res://presentation/pixel_actor.gd").new()
		actor.pixel_size=.003
		board.add_child(actor)
		actor.position=Vector3(-1.2+i*2.4,.15,3)
		actor.reset_playback(Rest)
		actors.append(actor)
	DirAccess.make_dir_recursive_absolute(output)
	for frame in 90:
		if frame==12: actors[1].reset_playback(Defeat)
		if frame>=12: actors[1].show_time((frame-12)/60.0)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(output.path_join("frame-%03d.png"%frame))
	print("Minotaur north defeat study: canonical rest / eight-pose defeat, 90 native frames")
	quit(0)
