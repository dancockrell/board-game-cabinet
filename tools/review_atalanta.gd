extends SceneTree
const RESTS = [preload("res://themes/atalanta_east_rest.tres"), preload("res://themes/atalanta_west_rest.tres"), preload("res://themes/atalanta_north_rest.tres"), preload("res://themes/atalanta_south_rest.tres")]
const ATTACKS = [preload("res://themes/atalanta_east_attack.tres"), preload("res://themes/atalanta_west_attack.tres"), preload("res://themes/atalanta_north_attack.tres"), preload("res://themes/atalanta_south_attack.tres")]
const Actor = preload("res://presentation/pixel_actor.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var stage := Node3D.new()
	root.add_child(stage)
	var camera := Camera3D.new()
	stage.add_child(camera)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 10.0
	camera.position = Vector3(0, 8, 10)
	camera.look_at(Vector3(0, .7, 0))
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("34463d")
	stage.add_child(environment)
	var actors: Array = []
	for row in 2:
		for facing in 4:
			var actor := Actor.new()
			stage.add_child(actor)
			actor.pixel_size = .0027
			actor.position = Vector3(-3.3 + facing * 2.2, .1, -1.4 + row * 3.2)
			actor.reset_playback(RESTS[facing])
			if row == 1: actors.append(actor)
	var capture := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="): capture = arg.trim_prefix("--capture=")
	for frame in 50:
		if frame == 10:
			for i in 4: actors[i].play_attack(1, ATTACKS[i])
		for actor in actors: actor.advance_visual(1.0 / 30.0)
		await process_frame
		await RenderingServer.frame_post_draw
		if frame in [5, 11, 16, 23, 40] and not capture.is_empty():
			root.get_texture().get_image().save_png(capture + "-%02d.png" % frame)
	print("Atalanta native four-direction review completed")
	quit()
