extends SceneTree
const SouthIdle = preload("res://themes/hydra_east_idle.tres")
const EastWalk = preload("res://themes/hydra_east_walk.tres")
const WestWalk = preload("res://themes/hydra_west_walk.tres")
const NorthIdle = preload("res://themes/hydra_west_idle.tres")
const SouthAttack = preload("res://themes/hydra_east_attack.tres")
const NorthAttack = preload("res://themes/hydra_west_attack.tres")

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	var output := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="): output=arg.trim_prefix("--capture=")
	if not output.is_absolute_path(): quit(2); return
	for clip in [SouthIdle,NorthIdle,SouthAttack,NorthAttack]:
		if not clip.validation_error().is_empty(): push_error(clip.validation_error()); quit(2); return
	if "--validate-only" in OS.get_cmdline_user_args():
		print("Hydra: four clips valid, east/west idle and attack")
		quit(0); return
	root.size=Vector2i(1440,960)
	var board=preload("res://presentation/olympus_arena_board.gd").new()
	root.add_child(board)
	board.camera.size=6.0
	board.camera.position=Vector3(0,10.5,14)
	board.camera.look_at(Vector3(0,.6,3))
	var actors: Array = []
	for i in 2:
		var actor=preload("res://presentation/pixel_actor.gd").new()
		actor.pixel_size=.005
		board.add_child(actor)
		actor.position=Vector3(-1.2+i*2.4,.15,3)
		actor.reset_playback((EastWalk if i==0 else WestWalk) if "--walk" in OS.get_cmdline_user_args() else (SouthIdle if i==0 else NorthIdle))
		actors.append(actor)
	var title:=Label.new()
	title.text="HYDRA / EAST AND WEST / BREATHING AND BITE STUDY"
	if "--walk" in OS.get_cmdline_user_args(): title.text="HYDRA / EAST AND WEST / WALK AND BITE STUDY"
	title.position=Vector2(30,25)
	title.add_theme_font_size_override("font_size",24)
	root.add_child(title)
	var folder:=output.get_basename()+"-frames"
	DirAccess.make_dir_recursive_absolute(folder)
	for frame in 90:
		for i in 2:
			var actor=actors[i]
			if "--damage" in OS.get_cmdline_user_args(): actor.set_damage_flash(clampf(1.0-float(frame-45)/7.0,0.0,1.0) if frame>=45 else 0.0)
			if frame==45: actor.play_attack(1,SouthAttack if i==0 else NorthAttack)
			if frame<45: actor.show_time(frame/30.0)
			else: actor.advance_visual(1.0/30.0)
		await process_frame
		await RenderingServer.frame_post_draw
		var img:=root.get_texture().get_image()
		if img.save_png(folder.path_join("frame-%04d.png" % frame))!=OK: quit(2); return
		if frame==58: img.save_png(output)
	print("Hydra native review: 90 frames, four resources")
	quit(0)

