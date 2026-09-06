extends "res://tools/compare_hoplite_source.gd"
## Motion-only derivative of the preserved source. Never runs in the live roster.
func _run() -> void:
	var source := ""
	var output := ""
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--model="): source = argument.trim_prefix("--model=")
		if argument.begins_with("--capture-dir="): output = argument.trim_prefix("--capture-dir=")
	if not source.is_absolute_path() or not output.is_absolute_path():
		quit(2)
		return
	DirAccess.make_dir_recursive_absolute(output)
	root.size=Vector2i(960,960)
	root.content_scale_size=Vector2i(960,960)
	var world := Node3D.new()
	root.add_child(world)
	var doc := GLTFDocument.new()
	var state := GLTFState.new()
	if doc.append_from_file(source,state) != OK:
		quit(2)
		return
	var model := doc.generate_scene(state)
	var wrapper := Node3D.new()
	world.add_child(wrapper)
	wrapper.add_child(model)
	_pose_ready(model)
	_inspect(model)
	var scale_value := 2.0/_bounds.size.y
	model.position=-Vector3(_bounds.get_center().x,_bounds.position.y,_bounds.get_center().z)
	wrapper.scale=Vector3.ONE*scale_value
	_make_studio(world,2.0)
	var camera := Camera3D.new()
	world.add_child(camera)
	camera.projection=Camera3D.PROJECTION_ORTHOGONAL
	camera.size=3.3
	camera.position=Vector3(5,2.6,3)
	camera.look_at(Vector3(0,1,0))
	var skeleton := model.find_children("*","Skeleton3D",true,false)[0] as Skeleton3D
	var poses: Array[Quaternion]=[]
	for i in skeleton.get_bone_count(): poses.append(skeleton.get_bone_pose_rotation(i))
	var label := Label.new()
	label.position=Vector2(24,24)
	root.add_child(label)
	for frame in 120:
		var time := frame/30.0
		for i in skeleton.get_bone_count(): skeleton.set_bone_pose_rotation(i,poses[i])
		var walking := time < 2.0
		label.text="RIG TEST / WALK" if walking else "RIG TEST / ATTACK - NOT GAMEPLAY"
		if walking:
			var cycle := time*TAU
			_rotate_global(skeleton,"1_Right_Limb_0",Vector3.BACK,sin(cycle)*.30)
			_rotate_global(skeleton,"1_Left_Limb_0",Vector3.BACK,-sin(cycle)*.30)
			_rotate_global(skeleton,"1_Right_Limb_1",Vector3.BACK,-maxf(0,sin(cycle))*.40)
			_rotate_global(skeleton,"1_Left_Limb_1",Vector3.BACK,-maxf(0,-sin(cycle))*.40)
		else:
			var stroke := sin((time-2)*PI)*sin((time-2)*PI)
			_rotate_global(skeleton,"0_Left_Limb_0",Vector3.BACK,stroke*.65)
			_rotate_global(skeleton,"0_Left_Limb_1",Vector3.BACK,-stroke*.5)
		skeleton.force_update_all_bone_transforms()
		for tick in 2: await process_frame
		await RenderingServer.frame_post_draw
		if root.get_texture().get_image().save_png(output.path_join("frame-%04d.png"%frame)) != OK:
			quit(2)
			return
	print("Motion trial: 120 frames, 30 fps. Review only, not gameplay.")
	quit()

func _rotate_global(skeleton: Skeleton3D, suffix: String, axis: Vector3, angle: float) -> void:
	for i in skeleton.get_bone_count():
		if str(skeleton.get_bone_name(i)).ends_with(suffix):
			var current := skeleton.get_bone_global_pose(i)
			current.basis=Basis(axis,angle)*current.basis
			var parent := skeleton.get_bone_parent(i)
			var local := skeleton.get_bone_global_pose(parent).affine_inverse()*current if parent>=0 else current
			skeleton.set_bone_pose_rotation(i,local.basis.get_rotation_quaternion())
			skeleton.force_update_all_bone_transforms()
