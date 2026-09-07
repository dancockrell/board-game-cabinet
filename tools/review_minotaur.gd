extends SceneTree
const Rest = preload("res://themes/minotaur_south_rest.tres")
const Attack = preload("res://themes/minotaur_south_attack.tres")
const Actor = preload("res://presentation/pixel_actor.gd")
func _initialize() -> void: _run.call_deferred()
func _run() -> void:
	assert(Rest.validation_error().is_empty())
	assert(Attack.validation_error().is_empty())
	root.size = Vector2i(960, 720)
	var stage := Node3D.new()
	root.add_child(stage)
	var camera := Camera3D.new()
	stage.add_child(camera)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 3.8
	camera.position = Vector3(0, 5, 7)
	camera.look_at(Vector3(0, 0.85, 0))
	var actor := Actor.new()
	stage.add_child(actor)
	actor.pixel_size = 0.0034
	actor.reset_playback(Rest)
	var directory := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture-dir="): directory = arg.trim_prefix("--capture-dir=")
	if not directory.is_empty(): DirAccess.make_dir_recursive_absolute(directory)
	for frame in 60:
		if frame == 10: assert(actor.play_attack(1, Attack))
		actor.advance_visual(1.0/30.0)
		await process_frame
		await RenderingServer.frame_post_draw
		if not directory.is_empty(): root.get_texture().get_image().save_png(directory.path_join("frame-%04d.png" % frame))
	assert(actor.clip == Rest)
	print("Minotaur native resource and recovery checks passed")
	quit()
