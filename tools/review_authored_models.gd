extends SceneTree
## Review an external GLB without admitting it into the game's asset library.
## godot --path . --script tools/review_authored_models.gd -- --model=C:/raw/model.glb --capture-dir=C:/review

var _mesh_count := 0
var _triangles := 0
var _materials: Dictionary = {}
var _animations: Array[String] = []
var _bounds := AABB()
var _has_bounds := false

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var model_path := ""
	var destination := ""
	var target_height := 2.0
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--model="): model_path = argument.trim_prefix("--model=")
		elif argument.begins_with("--capture-dir="): destination = argument.trim_prefix("--capture-dir=")
		elif argument.begins_with("--height="): target_height = argument.trim_prefix("--height=").to_float()
	if not model_path.is_absolute_path() or not destination.is_absolute_path() or target_height <= 0.0 or not is_finite(target_height):
		_fail("Pass absolute --model= and --capture-dir= paths and a positive --height= (default 2.0).")
		return
	if DisplayServer.get_name() == "headless":
		_fail("Rendered review needs a graphics display; omit --headless.")
		return
	if DirAccess.make_dir_recursive_absolute(destination) != OK:
		_fail("Cannot create review directory: " + destination)
		return
	var document := GLTFDocument.new()
	var state := GLTFState.new()
	var result := document.append_from_file(model_path, state)
	if result != OK:
		_fail("GLB import failed (%s): %s" % [result, model_path])
		return
	var imported := document.generate_scene(state)
	if imported == null:
		_fail("GLB did not generate a scene.")
		return
	root.size = Vector2i(960, 960)
	var world := Node3D.new()
	root.add_child(world)
	var normalized := Node3D.new()
	world.add_child(normalized)
	normalized.add_child(imported)
	_inspect(imported)
	if not _has_bounds or _bounds.size.y <= 0.00001:
		_fail("Imported model has no usable mesh height.")
		return
	var source_bounds := _bounds
	var uniform_scale := target_height / source_bounds.size.y
	normalized.scale = Vector3.ONE * uniform_scale
	normalized.position = -Vector3(source_bounds.get_center().x, source_bounds.position.y, source_bounds.get_center().z) * uniform_scale
	var final_bounds := normalized.transform * source_bounds
	_make_studio(world, maxf(final_bounds.size.x, final_bounds.size.z) + target_height)
	var camera := Camera3D.new()
	world.add_child(camera)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.near = 0.01
	camera.far = target_height * 100.0
	camera.current = true
	var center := Vector3(0.0, target_height * 0.5, 0.0)
	# A diagonal's width fits every view, including wide architecture.
	camera.size = maxf(target_height, Vector2(final_bounds.size.x, final_bounds.size.z).length()) * 1.35
	var views := {"front": Vector3(0, 0.10, 1), "side": Vector3(1, 0.10, 0), "rear": Vector3(0, 0.10, -1), "threequarter": Vector3(1, 0.55, 1)}
	var captures: Array[String] = []
	for view_name in views:
		camera.position = center + (views[view_name] as Vector3).normalized() * camera.size * 3.0
		camera.look_at(center)
		for frame in 16: await process_frame
		await RenderingServer.frame_post_draw
		var capture_path := destination.path_join(view_name + ".png")
		result = root.get_texture().get_image().save_png(capture_path)
		if result != OK:
			_fail("Could not save capture: " + capture_path)
			return
		captures.append(capture_path)
	var report := {
		"source": model_path, "source_sha256": FileAccess.get_sha256(model_path),
		"mesh_instances": _mesh_count, "triangles_instanced": _triangles,
		"unique_materials": _materials.size(), "animation_count": _animations.size(),
		"animations": _animations, "source_bounds": _bounds_json(source_bounds),
		"normalized_bounds": _bounds_json(final_bounds), "uniform_scale": uniform_scale,
		"target_height_m": target_height, "captures": captures,
		"review_notes": "Rest-pose geometry bounds; front is viewed from +Z. No authored materials were overridden. Rendered images are inspection evidence, not asset approval."
	}
	var report_path := destination.path_join("review.json")
	var file := FileAccess.open(report_path, FileAccess.WRITE)
	if file == null:
		_fail("Could not write report: " + report_path)
		return
	file.store_string(JSON.stringify(report, "\t") + "\n")
	file.close()
	print(JSON.stringify(report))
	world.queue_free()
	for frame in 4: await process_frame
	quit(0)

func _inspect(node: Node) -> void:
	if node is AnimationPlayer:
		var player := node as AnimationPlayer
		player.stop()
		player.active = false
		for animation in player.get_animation_list():
			if animation != "RESET": _animations.append(str(node.get_path()) + ":" + animation)
	if node is MeshInstance3D:
		var instance := node as MeshInstance3D
		if instance.mesh != null:
			_mesh_count += 1
			var transformed := instance.global_transform * instance.mesh.get_aabb()
			_bounds = _bounds.merge(transformed) if _has_bounds else transformed
			_has_bounds = true
			for surface in instance.mesh.get_surface_count():
				var arrays := instance.mesh.surface_get_arrays(surface)
				if not arrays.is_empty() and instance.mesh.surface_get_primitive_type(surface) == Mesh.PRIMITIVE_TRIANGLES:
					var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
					var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
					_triangles += int((indices.size() if not indices.is_empty() else vertices.size()) / 3)
				var material := instance.get_active_material(surface)
				if material != null: _materials[material.get_instance_id()] = material.resource_name
	for child in node.get_children(): _inspect(child)

func _make_studio(world: Node3D, span: float) -> void:
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("33383d")
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color("e2e6ed")
	environment.environment.ambient_light_energy = 0.45
	environment.environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world.add_child(environment)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-48, -35, 0)
	key.light_energy = 1.05
	key.shadow_enabled = true
	world.add_child(key)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-30, 145, 0)
	fill.light_energy = 0.35
	world.add_child(fill)
	var floor_mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2.ONE * span * 12.0
	floor_mesh.mesh = plane
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("54595e")
	material.roughness = 0.95
	floor_mesh.material_override = material
	floor_mesh.position.y = -0.005
	world.add_child(floor_mesh)

func _bounds_json(value: AABB) -> Dictionary:
	return {"position": [value.position.x, value.position.y, value.position.z], "size": [value.size.x, value.size.y, value.size.z]}

func _fail(message: String) -> void:
	push_error(message)
	quit(2)
