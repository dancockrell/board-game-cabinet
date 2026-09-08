extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func run() -> void:
	root.size=Vector2i(1440,960)
	var board=preload("res://presentation/olympus_arena_board.gd").new()
	root.add_child(board)
	var stage=board.stage
	check(stage.get_child_count()==2 and stage.backdrop is Sprite3D and stage.sea_fill is Sprite3D,"Scenery and extended sea are authored 2D sprites")
	check(stage.backdrop.texture==stage.BACKDROP,"Scene uses canonical painted background")
	for viewport_size in [Vector2i(1440,960),Vector2i(1100,1000)]:
		root.size=viewport_size
		await process_frame
		for index in 2:
			var pixel: Vector2=stage.BRIDGE_CENTERS[index]
			var half: Vector2=stage.BACKDROP.get_size()*0.5
			var point: Vector3=stage.backdrop.position+board.camera.basis.x*(pixel.x-half.x)*stage.backdrop.pixel_size+board.camera.basis.y*(half.y-pixel.y)*stage.backdrop.pixel_size
			var expected=board.camera.unproject_position(Vector3(-2.7 if index==0 else 2.7,.12,0))
			check(board.camera.unproject_position(point).distance_to(expected)<0.1,"Painted bridge agrees with authoritative lane at both aspect ratios")
	stage.advance_visual(.4)
	check(is_equal_approx(stage._water_time,.4),"2D water clock advances")
	stage.advance_visual(0)
	stage.advance_visual(-1)
	stage.advance_visual(NAN)
	check(is_equal_approx(stage._water_time,.4),"Pause and invalid delta cannot advance scenery")
	check(is_equal_approx(stage._art_material.get_shader_parameter("animation_time"),.4),"Artwork receives the manual clock")
	root.size=Vector2i(1440,960)
	board.show_state(preload("res://games/olympus_arena/session.gd").new().snapshot())
	for frame in 5: await process_frame
	await RenderingServer.frame_post_draw
	var rendered := root.get_texture().get_image()
	for lane in [-2.7,2.7]:
		var screen := board.camera.unproject_position(Vector3(lane,.12,0))
		var color := rendered.get_pixelv(Vector2i(screen))
		check(color.r>color.b and color.r>0.3,"Painted stone bridge remains visible above the sea margin layer")
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="):
			check(root.get_texture().get_image().save_png(arg.trim_prefix("--capture="))==OK,"Native 2D stage capture saved")
	board.queue_free()
	await process_frame
	print("2D stage: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
