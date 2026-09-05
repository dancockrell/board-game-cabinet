extends SceneTree
## Staged close review of the same structures used in a match.
func _initialize() -> void: _run.call_deferred()
func _run() -> void:
	var destination := ""
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="): destination=argument.trim_prefix("--capture=")
	if not destination.is_absolute_path():
		push_error("Pass an absolute --capture= PNG path.")
		quit(2)
		return
	root.size=Vector2i(1440,960)
	var board:=preload("res://presentation/olympus_arena_board.gd").new()
	root.add_child(board)
	board.camera.size=7.0
	board.camera.position=Vector3(3.0,7.0,13.0)
	board.camera.look_at(Vector3(0,1.0,3.5))
	board.show_state({"units":[],"events":[],"elapsed":1.0,"towers":[
		{"id":"study_temple","kind":"temple","side":0,"x":-1.75,"z":3.5,"hp":1800.0,"max_hp":1800.0},
		{"id":"study_shrine","kind":"tower","side":1,"x":1.75,"z":3.5,"hp":1100.0,"max_hp":1100.0}]})
	for tower in board._towers.values(): tower.get_node("Health").hide()
	var panel:=ColorRect.new()
	panel.color=Color("102b35")
	panel.position=Vector2(20,18)
	panel.size=Vector2(650,54)
	root.add_child(panel)
	var label:=Label.new()
	label.text="OLYMPUS  /  TEMPLE & WATCH SHRINE STUDY"
	label.position=Vector2(35,31)
	label.add_theme_font_size_override("font_size",23)
	label.add_theme_color_override("font_color",Color("e7d6ac"))
	root.add_child(label)
	for i in 12: await process_frame
	await RenderingServer.frame_post_draw
	var result:=root.get_texture().get_image().save_png(destination)
	board.queue_free()
	await process_frame
	quit(0 if result==OK else 1)
