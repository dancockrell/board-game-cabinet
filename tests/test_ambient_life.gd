extends SceneTree
const Ambient = preload("res://presentation/olympus_ambient_life.gd")
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	var life = Ambient.new()
	root.add_child(life)
	await process_frame
	assert(life._cloth.size() == 10)
	assert(life._wakes.size() == 6)
	var before: Vector3 = life._wakes[0].position
	life.advance(0.5)
	assert(life._wakes[0].position != before)
	assert(is_equal_approx(float(life._cloth[0].get_shader_parameter("motion_clock")), 0.5))
	var frozen: Vector3 = life._wakes[0].position
	life.advance(2.0, true)
	assert(life._wakes[0].position == frozen)
	assert(is_equal_approx(float(life._cloth[0].get_shader_parameter("motion_clock")), 0.5))
	life.advance(-1.0)
	assert(life._wakes[0].position == frozen)
	print("Ambient motion: 7 checks passed")
	if DisplayServer.get_name() != "headless":
		var camera := Camera3D.new()
		root.add_child(camera)
		camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		camera.size = 3.5
		camera.position = Vector3(8, 3, 7)
		camera.look_at(Vector3(5.72, 0.8, 2.6))
		var light := DirectionalLight3D.new()
		root.add_child(light)
		light.rotation_degrees = Vector3(-45, -30, 0)
		for phase in [0.0, 0.4]:
			life.advance(phase)
			await process_frame
			await RenderingServer.frame_post_draw
			for arg in OS.get_cmdline_user_args():
				if arg.begins_with("--capture="):
					root.get_texture().get_image().save_png(arg.trim_prefix("--capture=") + "-%s.png" % phase)
	quit()
