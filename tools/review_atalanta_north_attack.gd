extends SceneTree
const ATTACK = preload("res://themes/atalanta_north_attack.tres")
const REST = preload("res://themes/atalanta_north_rest.tres")
func _initialize(): run.call_deferred()
func run():
	root.size = Vector2i(960,800)
	var stage := Node3D.new()
	root.add_child(stage)
	var camera := Camera3D.new()
	stage.add_child(camera)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 3.2
	camera.position = Vector3(0,8,10)
	camera.look_at(Vector3(0,.85,0))
	var world := WorldEnvironment.new()
	world.environment = Environment.new()
	world.environment.background_mode = Environment.BG_COLOR
	world.environment.background_color = Color("34463d")
	stage.add_child(world)
	var actor = preload("res://presentation/pixel_actor.gd").new()
	stage.add_child(actor)
	actor.pixel_size = .0027
	actor.reset_playback(REST)
	var output := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="): output = arg.trim_prefix("--capture=")
	if not output.is_absolute_path(): quit(2); return
	DirAccess.make_dir_recursive_absolute(output)
	for frame in 90:
		if frame == 12 or frame == 48: actor.play_attack(frame, ATTACK)
		actor.advance_visual(1.0/30.0)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(output.path_join("frame-%04d.png" % frame))
	print("Atalanta north attack: 90 native frames captured")
	quit(0)

