extends SceneTree
## Review an external GLB without admitting it into the game's asset library.
## godot --path . --script tools/review_authored_models.gd -- --model=C:/raw/model.glb --capture-dir=C:/review

var _ready_pose := false
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
		if argument == "--ready-pose": _ready_pose = true
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
	# Override the cabinet's 3:2 canvas stretch and minimum window dimensions.
	root.min_size = Vector2i.ZERO
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.content_scale_size = Vector2i(960, 960)
	root.size = Vector2i(960, 960)
	var world := Node3D.new()
	root.add_child(world)
	var normalized := Node3D.new()
	world.add_child(normalized)
	normalized.add_child(imported)
	if _ready_pose: _pose_ready(imported)
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
		"unique_materials": _materials.size(), "ready_pose_trial": _ready_pose, "animation_count": _animations.size(),
		"animations": _animations, "source_bounds": _bounds_json(source_bounds),
		"normalized_bounds": _bounds_json(final_bounds), "uniform_scale": uniform_scale,
		"target_height_m": target_height, "captures": captures,
		"review_notes": "Evaluated initial skeleton-pose geometry bounds; front is viewed from +Z. No authored materials were overridden. Rendered images are inspection evidence, not asset approval."
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
			var transformed := _evaluated_bounds(instance)
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

func _evaluated_bounds(instance: MeshInstance3D) -> AABB:
	var skeleton := instance.get_node_or_null(instance.skeleton) as Skeleton3D
	if skeleton == null or instance.skin == null:
		return instance.global_transform * instance.mesh.get_aabb()
	# Imported mesh AABBs can describe bind geometry far below its posed skeleton.
	# Evaluate the same joint palette used by skinning before framing or flooring.
	skeleton.force_update_all_bone_transforms()
	var palette: Array[Transform3D] = []
	for joint in instance.skin.get_bind_count():
		var bone := instance.skin.get_bind_bone(joint)
		var bone_name := instance.skin.get_bind_name(joint)
		if not bone_name.is_empty(): bone = skeleton.find_bone(bone_name)
		if bone < 0 or bone >= skeleton.get_bone_count():
			push_error("Invalid skin bind: " + str(joint))
			return instance.global_transform * instance.mesh.get_aabb()
		palette.append(skeleton.global_transform * skeleton.get_bone_global_pose(bone) * instance.skin.get_bind_pose(joint))
	var result := AABB()
	var initialized := false
	for surface in instance.mesh.get_surface_count():
		var arrays := instance.mesh.surface_get_arrays(surface)
		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES] if arrays[Mesh.ARRAY_BONES] != null else PackedInt32Array()
		var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS] if arrays[Mesh.ARRAY_WEIGHTS] != null else PackedFloat32Array()
		var influence_count := int(weights.size() / maxi(1, vertices.size()))
		for vertex_index in vertices.size():
			var point := Vector3.ZERO
			var total := 0.0
			for influence in influence_count:
				var offset := vertex_index * influence_count + influence
				var joint := bones[offset]
				if weights[offset] > 0.0 and joint >= 0 and joint < palette.size():
					point += (palette[joint] * vertices[vertex_index]) * weights[offset]
					total += weights[offset]
			if total <= 0.0: point = instance.global_transform * vertices[vertex_index]
			else: point /= total
			result = result.expand(point) if initialized else AABB(point, Vector3.ZERO)
			initialized = true
	return result if initialized else instance.global_transform * instance.mesh.get_aabb()

func _make_studio(world: Node3D, span: float) -> void:
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("33383d")
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color("e2e6ed")
	environment.environment.ambient_light_energy = 0.18
	environment.environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.environment.tonemap_exposure = 0.8
	world.add_child(environment)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-48, -35, 0)
	key.light_energy = 0.55
	key.shadow_enabled = true
	world.add_child(key)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-30, 145, 0)
	fill.light_energy = 0.12
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

func _pose_ready(node: Node) -> void:
	if node is Skeleton3D:
		var skeleton := node as Skeleton3D
		skeleton.force_update_all_bone_transforms()
		for i in skeleton.get_bone_count():
			var label := str(skeleton.get_bone_name(i))
			if label.ends_with("0_Right_Limb_0") or label.ends_with("0_Left_Limb_0"):
				var current := skeleton.get_bone_global_pose(i)
				var sign_value := 1.0 if current.origin.z > 0.0 else -1.0
				var desired := current
				desired.basis = Basis(Vector3.RIGHT, sign_value * deg_to_rad(62.0)) * current.basis
				var parent := skeleton.get_bone_parent(i)
				var local := skeleton.get_bone_global_pose(parent).affine_inverse() * desired if parent >= 0 else desired
				skeleton.set_bone_pose_rotation(i, local.basis.get_rotation_quaternion())
				skeleton.force_update_all_bone_transforms()
		for i in skeleton.get_bone_count():
			var label := str(skeleton.get_bone_name(i))
			if label.ends_with("0_Right_Limb_1") or label.ends_with("0_Left_Limb_1"):
				var current := skeleton.get_bone_global_pose(i)
				var desired := current
				desired.basis = Basis(Vector3.BACK, deg_to_rad(48.0)) * current.basis
				var parent := skeleton.get_bone_parent(i)
				var local := skeleton.get_bone_global_pose(parent).affine_inverse() * desired
				skeleton.set_bone_pose_rotation(i,local.basis.get_rotation_quaternion())
				skeleton.force_update_all_bone_transforms()
		# Generated finger chains use local Y along the phalanx; curl around X.
		for i in skeleton.get_bone_count():
			var label := str(skeleton.get_bone_name(i))
			if label in ["bone_23", "bone_24", "bone_28", "bone_29", "bone_30"]:
				var rest_rotation := skeleton.get_bone_pose_rotation(i)
				skeleton.set_bone_pose_rotation(i,rest_rotation * Quaternion(Vector3.RIGHT,deg_to_rad(48.0)))
		skeleton.force_update_all_bone_transforms()
	for child in node.get_children(): _pose_ready(child)
