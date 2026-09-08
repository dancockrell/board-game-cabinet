extends SceneTree
const NORTH = preload("res://themes/atalanta_east_walk.tres")
const SOUTH = preload("res://themes/atalanta_west_walk.tres")
const NORTH_REST = preload("res://themes/atalanta_east_rest.tres")
const SOUTH_REST = preload("res://themes/atalanta_west_rest.tres")
const Actor = preload("res://presentation/pixel_actor.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var stage := Node3D.new()
	root.add_child(stage)
	var camera := Camera3D.new()
	stage.add_child(camera)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 4.5
	camera.position = Vector3(0, 8, 10)
	camera.look_at(Vector3(0, .75, 0))
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
		actor.position = Vector3(-.9 + i * 1.8, .1, 0)
		actor.reset_playback(NORTH_REST if i == 0 else SOUTH_REST)
		actors.append(actor)
	var capture := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="): capture = arg.trim_prefix("--capture=")
	if not capture.is_empty(): DirAccess.make_dir_recursive_absolute(capture)
	for frame in 90:
		if frame == 10:
			actors[0].set_locomotion(NORTH)
			actors[1].set_locomotion(SOUTH)
		if frame == 75:
			for actor in actors: actor.set_locomotion(null)
		for actor in actors: actor.advance_visual(1.0 / 30.0)
		await process_frame
		await RenderingServer.frame_post_draw
		if not capture.is_empty():
			root.get_texture().get_image().save_png(capture.path_join("frame-%04d.png" % frame))
	print("Atalanta east/west native walking study completed")
	quit()

