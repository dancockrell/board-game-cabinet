extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("_run")
func check(ok: bool, text: String) -> void:
	if not ok:
		failures += 1
		push_error(text)
func _run() -> void:
	root.size = Vector2i(1100,1000)
	var board = preload("res://presentation/olympus_arena_board.gd").new()
	root.add_child(board)
	var stage = board.get_node("OlympusStage")
	check(stage.get_child_count() < 1000, "Scenery stays below 1000 mesh instances")
	var coastal = get_nodes_in_group("olympus_coastal_rocks")
	check(coastal.size() == 18, "Only 18 coastal outcrops use the shared rock material")
	for rock in coastal:
		check(rock.material_override == stage.ROCK, "Outcrop uses canonical reusable material")
	check(stage.ROCK.normal_enabled and stage.ROCK.normal_texture != null, "Rock normal map is present")
	check(stage.ROCK.roughness_texture_channel == BaseMaterial3D.TEXTURE_CHANNEL_GREEN, "ARM roughness uses green")
	check(stage.ROCK.metallic_texture_channel == BaseMaterial3D.TEXTURE_CHANNEL_BLUE, "ARM metallic uses blue")
	check(stage.ROCK.ao_texture_channel == BaseMaterial3D.TEXTURE_CHANNEL_RED, "ARM AO uses red")
	var mesh: ArrayMesh = stage._beveled_box(Vector3(2,1,3))
	var arrays := mesh.surface_get_arrays(0)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	check(vertices.size() == 132, "Beveled block has 44 bounded triangles")
	for i in range(0,vertices.size(),3):
		var cross_ := (vertices[i+1]-vertices[i]).cross(vertices[i+2]-vertices[i])
		check(cross_.dot(normals[i]) < 0, "Clockwise face winding matches outward normal")
		check(normals[i].dot(vertices[i]) > 0, "Every chamfer normal points outward")
	var session = preload("res://games/olympus_arena/session.gd").new()
	session.new_game(42)
	board.show_state(session.snapshot())
	for i in 5: await process_frame
	await RenderingServer.frame_post_draw
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="):
			check(root.get_texture().get_image().save_png(arg.trim_prefix("--capture=")) == OK, "Native diorama capture saved")
	print("Olympus stage: 113 geometry/material/budget checks, %s failures; %s stage nodes" % [failures,stage.get_child_count()])
	board.free()
	await process_frame
	quit(1 if failures else 0)
