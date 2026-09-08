extends SceneTree
const Session=preload("res://games/olympus_arena/session.gd")
func _initialize(): run.call_deferred()
func run():
	var output:=""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="): output=arg.trim_prefix("--capture=")
	if not output.is_absolute_path(): quit(2); return
	DirAccess.make_dir_recursive_absolute(output)
	root.size=Vector2i(1280,800)
	var game=Session.new()
	game.deploy(0,Vector2(0,2))
	var source=game._state.units[0]
	source.x=-.6
	source.cooldown=.5
	var target=source.duplicate(true)
	target.id=100
	target.side=1
	target.kind="heracles"
	target.x=0.0
	target.hp=640.0
	target.max_hp=640.0
	game._state.units=[source,target]
	game._state.towers=[]
	game._state.events=[]
	var board=preload("res://presentation/olympus_arena_board.gd").new()
	root.add_child(board)
	board.show_state(game.snapshot(),0.0)
	board.camera.size=4.0
	board.camera.position=Vector3(0,10.5,14)
	board.camera.look_at(Vector3(0,.8,2))
	var log:=[]
	for frame in 180:
		if frame%6==0:
			game._state.elapsed+=.1
			game._step_unit(source)
			board.show_state(game.snapshot(),0.0)
			var actor=board._tokens[source.id].get_node("Figure/PixelActor")
			log.append({"frame":frame,"hp":target.hp,"cooldown":source.cooldown,"preparing":actor.awaiting_strike,"action_time":actor._reaction_elapsed,"pose":actor._shown})
		board.show_state(game.snapshot(),1.0/60.0)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(output.path_join("frame-%03d.png"%frame))
	var file=FileAccess.open(output.path_join("timing.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify(log,"\t"))
	print("Rules-driven preparation review: 180 native60fps frames and strike timing evidence")
	quit(0)
