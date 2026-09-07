extends SceneTree
const Shrine = preload("res://themes/olympus_shrine_clip.tres")
const Rubble = preload("res://themes/olympus_shrine_rubble_clip.tres")
const Actor = preload("res://presentation/pixel_actor.gd")
const Collapse = preload("res://presentation/olympus_collapse_fx.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var stage := Node3D.new()
	root.add_child(stage)
	var building := Actor.new()
	stage.add_child(building)
	building.pixel_size = .0014
	building.reset_playback(Shrine)
	var camera := Camera3D.new()
	stage.add_child(camera)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 4.5
	camera.position = Vector3(0, 4, 6)
	camera.look_at(Vector3(0, .8, 0))
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("3c5049")
	stage.add_child(environment)
	await process_frame
	var fx := Collapse.new()
	stage.add_child(fx)
	fx.begin(building)
	building.reset_playback(Rubble)
	var capture := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="): capture = arg.trim_prefix("--capture=")
	for frame in 45:
		fx.advance_visual(1.0 / 30.0)
		await process_frame
		await RenderingServer.frame_post_draw
		if frame in [5, 11, 21, 38] and not capture.is_empty():
			root.get_texture().get_image().save_png(capture + "-%02d.png" % frame)
	print("Collapse native study completed")
	quit()
