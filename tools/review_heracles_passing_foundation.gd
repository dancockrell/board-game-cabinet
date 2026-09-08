extends SceneTree
## External candidate preview; no board mapping or runtime admission.
const REST = preload("res://themes/heracles_east_rest.tres")
const Clip = preload("res://presentation/sprite_clip.gd")
const Actor = preload("res://presentation/pixel_actor.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var source := ""
	var capture := ""
	var cycle := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--cycle="): cycle = arg.trim_prefix("--cycle=")
		if arg.begins_with("--source="): source = arg.trim_prefix("--source=")
		if arg.begins_with("--capture="): capture = arg.trim_prefix("--capture=")
	if not cycle.is_empty(): source = cycle.path_join("heracles-east-study-1.png")
	var candidate_image := Image.load_from_file(source)
	if candidate_image == null:
		push_error("Provide --source=<original candidate PNG>")
		quit(1)
		return
	var candidate := Clip.new()
	candidate.atlas = ImageTexture.create_from_image(candidate_image)
	candidate.regions = [Rect2i(Vector2i.ZERO, candidate_image.get_size())]
	candidate.frame_pivots = [Vector2(645, 1050)]
	candidate.durations = PackedFloat32Array([1.0])
	candidate.draw_scale = .659
	candidate.magenta_backing = true
	if not cycle.is_empty():
		candidate.regions.clear()
		candidate.frame_pivots = [Vector2(645, 1105), Vector2(645, 1087), Vector2(645, 1095), Vector2(645, 1050)]
		candidate.frame_draw_scales = PackedFloat32Array([.622, .635, .629, .659])
		candidate.durations = PackedFloat32Array([.18, .18, .18, .18])
		for index in [3, 2, 4, 1]:
			var cel := Image.load_from_file(cycle.path_join("heracles-east-study-%d.png" % index))
			candidate.frame_atlases.append(ImageTexture.create_from_image(cel))
			candidate.regions.append(Rect2i(Vector2i.ZERO, cel.get_size()))
	if not candidate.validation_error().is_empty():
		push_error(candidate.validation_error())
		quit(1)
		return
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
		actor.position = Vector3(-.85 + i * 1.7, .1, 0)
		actor.reset_playback(REST if i == 0 else candidate)
		actors.append(actor)
	var title := Label.new()
	title.text = "HERACLES â€” REST (LEFT) / SINGLE PASSING STUDY (RIGHT)\nNot a completed walk cycle"
	title.position = Vector2(24, 24)
	root.add_child(title)
	if not cycle.is_empty():
		title.text = "HERACLES - REST (LEFT) / FOUR DRAWN PHASE STUDY (RIGHT)"
		if not capture.is_empty(): DirAccess.make_dir_recursive_absolute(capture)
		for frame in 90:
			actors[1].show_time(frame / 30.0)
			await process_frame
			await RenderingServer.frame_post_draw
			if not capture.is_empty(): root.get_texture().get_image().save_png(capture.path_join("frame-%04d.png" % frame))
		quit()
		return
	for frame in 8: await process_frame
	await RenderingServer.frame_post_draw
	if not capture.is_empty(): root.get_texture().get_image().save_png(capture)
	print("Heracles isolated passing study rendered; no locomotion admission")
	quit()
