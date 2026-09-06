extends "res://tools/review_authored_models.gd"
## Reuses the preserved source without admitting it to the live roster.
func _run() -> void:
	var source := ""
	var output := ""
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--model="): source = argument.trim_prefix("--model=")
		if argument.begins_with("--capture="): output = argument.trim_prefix("--capture=")
	if not source.is_absolute_path() or not output.is_absolute_path():
		quit(2)
		return
	root.size = Vector2i(1440,960)
	var board := preload("res://presentation/olympus_arena_board.gd").new()
	root.add_child(board)
	board.camera.size = 14.0 if "--game-scale" in OS.get_cmdline_user_args() else 5.0
	board.camera.position = Vector3(0,10.5,14)
	board.camera.look_at(Vector3(0,.7,3))
	board.show_state({"units":[{"id":1,"kind":"hoplites","side":0,"x":-1.0,"z":3.0,"hp":100.0,"max_hp":100.0}],"towers":[],"events":[],"elapsed":1.0},.016)
	board._tokens[1].get_node("Figure").rotation.y=0
	board._tokens[1].get_node("Health").hide()
	var document := GLTFDocument.new()
	var state := GLTFState.new()
	if document.append_from_file(source,state) != OK:
		quit(2)
		return
	var imported := document.generate_scene(state)
	var wrapper := Node3D.new()
	board.add_child(wrapper)
	wrapper.add_child(imported)
	_pose_ready(imported)
	_inspect(imported)
	var factor := 1.65 / _bounds.size.y
	imported.position = -Vector3(_bounds.get_center().x,_bounds.position.y,_bounds.get_center().z)
	wrapper.scale=Vector3.ONE*factor
	wrapper.rotation.y=-PI/2
	wrapper.position=Vector3(1,.15,3)
	var label := Label.new()
	label.text="CURRENT FIGURE                         REUSED TEXTURED SOURCE / POSE TRIAL"
	label.position=Vector2(150,48)
	label.add_theme_font_size_override("font_size",24)
	root.add_child(label)
	for i in 20: await process_frame
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png(output)
	quit(0 if error == OK else 1)
