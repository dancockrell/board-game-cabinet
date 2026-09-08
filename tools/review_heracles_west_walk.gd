extends SceneTree
const REST = preload("res://themes/heracles_west_rest.tres")
const WALK = preload("res://themes/heracles_west_walk.tres")
const Actor = preload("res://presentation/pixel_actor.gd")
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var capture := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="): capture = arg.trim_prefix("--capture=")
	var stage := Node3D.new()
	root.add_child(stage)
	var camera := Camera3D.new()
	stage.add_child(camera)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 4.5
	camera.position = Vector3(0,8,10)
	camera.look_at(Vector3(0,.75,0))
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("34463d")
	stage.add_child(environment)
	var actors: Array = []
	for i in 2:
		var actor := Actor.new()
		stage.add_child(actor)
		actor.pixel_size = .0027
		actor.position = Vector3(-.85+i*1.7,.1,0)
		actor.reset_playback(REST if i == 0 else WALK)
		actors.append(actor)
	var title := Label.new()
	title.text = "HERACLES WEST - REST (LEFT) / SEVEN DRAWN WALK POSES (RIGHT)"
	title.position = Vector2(24,24)
	root.add_child(title)
	if not capture.is_empty(): DirAccess.make_dir_recursive_absolute(capture)
	for frame in 90:
		actors[1].show_time(frame/30.0)
		await process_frame
		await RenderingServer.frame_post_draw
		if not capture.is_empty(): root.get_texture().get_image().save_png(capture.path_join("frame-%04d.png" % frame))
	quit()

