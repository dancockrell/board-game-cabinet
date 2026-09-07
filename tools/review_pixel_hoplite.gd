extends SceneTree
func _initialize() -> void: _run.call_deferred()
func _run() -> void:
	var source:=ProjectSettings.globalize_path("res://docs/art-references/hoplite-directions-candidate.png")
	var output:=""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--source="): source=arg.trim_prefix("--source=")
		if arg.begins_with("--capture="): output=arg.trim_prefix("--capture=")
	if not source.is_absolute_path() or not output.is_absolute_path(): quit(2); return
	var img:=Image.load_from_file(source)
	if img==null: quit(2); return
	var texture:=ImageTexture.create_from_image(img)
	root.size=Vector2i(1440,960)
	var board:=preload("res://presentation/olympus_arena_board.gd").new()
	root.add_child(board)
	board.camera.size=6.0
	board.camera.position=Vector3(0,10.5,14)
	board.camera.look_at(Vector3(0,.6,3))
	for i in 2:
		var clip:=preload("res://presentation/sprite_clip.gd").new()
		clip.atlas=texture
		clip.regions=[Rect2i(0,i*627,627,627)]
		clip.durations=PackedFloat32Array([1.0])
		clip.pivot=Vector2(330,600)
		var actor:=preload("res://presentation/pixel_actor.gd").new()
		actor.pixel_size=.003
		board.add_child(actor)
		actor.position=Vector3(-1.0+i*2,.15,3)
		if not actor.set_clip(clip): quit(2); return
	var title:=Label.new()
	title.text="PIXEL HOPLITE / FRONT AND BACK STUDY / STATIC CANDIDATE"
	title.position=Vector2(30,25)
	title.add_theme_font_size_override("font_size",24)
	root.add_child(title)
	for i in 10: await process_frame
	await RenderingServer.frame_post_draw
	var result:=root.get_texture().get_image().save_png(output)
	quit(0 if result==OK else 2)
