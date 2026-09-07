extends SceneTree
const Rest = preload("res://themes/hoplite_south_rest.tres")
const Actor = preload("res://presentation/pixel_actor.gd")
const Departure = preload("res://presentation/olympus_unit_departure_fx.gd")
var failures := 0
func check(value: bool, label: String) -> void:
	if not value: failures += 1; push_error(label)
func _initialize() -> void: run.call_deferred()
func run() -> void:
	root.size = Vector2i(1000,700)
	var world := Node3D.new()
	root.add_child(world)
	var camera := Camera3D.new()
	world.add_child(camera)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 5.5
	camera.position = Vector3(0,3,6)
	camera.look_at(Vector3(0,0.8,0))
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("243d3e")
	world.add_child(environment)
	var actor := Actor.new()
	world.add_child(actor)
	actor.pixel_size = 0.004
	check(actor.reset_playback(Rest), "Rest loads")
	var source_transform: Transform3D = actor.global_transform
	var source_material = actor.material_override
	var fx := Departure.new()
	world.add_child(fx)
	check(fx.begin(actor), "Copies current frame")
	check(fx.ghost.texture != actor.texture, "Independent atlas wrapper")
	check(fx.ghost.offset == actor.offset, "Foot pivot retained")
	check(fx.global_transform == source_transform, "Rendered transform retained")
	actor.hide()
	fx.advance_visual(0.0)
	check(fx.elapsed == 0.0, "Pause freezes departure")
	fx.advance_visual(-1.0)
	check(fx.elapsed == 0.0, "Invalid delta ignored")
	var output := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="): output = arg.trim_prefix("--capture=")
	for i in 3:
		if i > 0: fx.advance_visual(0.22)
		for frame in 3: await process_frame
		await RenderingServer.frame_post_draw
		if output != "": root.get_texture().get_image().save_png(output + "-" + str(i) + ".png")
	check(actor.material_override == source_material and actor.global_transform == source_transform, "Source unchanged")
	check(source_material.get_shader_parameter("departure") == null, "Original material unchanged")
	fx.advance_visual(1.0)
	await process_frame
	check(not is_instance_valid(fx), "Bounded departure freed")
	print("Departure checks: 10; failures: ", failures)
	quit(0 if failures == 0 else 1)
