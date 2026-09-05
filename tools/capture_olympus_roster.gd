extends SceneTree
## Staged art-review lineup, explicitly separate from gameplay evidence.
func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var destination := ""
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="): destination = argument.trim_prefix("--capture=")
	if not destination.is_absolute_path():
		push_error("Pass --capture= with an absolute PNG path.")
		quit(2)
		return
	root.size = Vector2i(1440,960)
	var board := preload("res://presentation/olympus_arena_board.gd").new()
	root.add_child(board)
	board.camera.size = 9.8
	board.camera.position = Vector3(0,10.5,14)
	board.camera.look_at(Vector3(0,.4,2.7))
	var names := ["hoplites","atalanta","minotaur","medusa","heracles","hydra","harpies"]
	var units: Array = []
	for i in names.size():
		var at := Vector2(-3.3+(i%4)*2.2,1.2) if i < 4 else Vector2(-2.4+(i-4)*2.4,4.3)
		units.append({"id":i,"kind":names[i],"side":0,"x":at.x,"z":at.y,"hp":100.0,"max_hp":100.0,"flying":names[i]=="harpies"})
	board.show_state({"units":units,"towers":[],"events":[],"elapsed":1.0},.016)
	for unit in board._tokens.values():
		unit.get_node("Figure").rotation.y = 0
		unit.get_node("Health").hide()
	var title := Label.new()
	title.text = "OLYMPUS ARENA  /  MINIATURE ART STUDY"
	title.position = Vector2(28,22)
	title.add_theme_font_size_override("font_size",24)
	title.add_theme_color_override("font_color",Color("fff0d2"))
	root.add_child(title)
	for i in 5: await process_frame
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png(destination)
	board.queue_free()
	await process_frame
	quit(0 if error == OK else 1)
