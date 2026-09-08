extends SceneTree
const Clip=preload("res://presentation/sprite_clip.gd")
const Actor=preload("res://presentation/pixel_actor.gd")
func _initialize(): run.call_deferred()
func run():
	var output=""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--batch-output="): output=arg.trim_prefix("--batch-output=")
	if not output.is_absolute_path(): quit(2); return
	DirAccess.make_dir_recursive_absolute(output)
	root.size=Vector2i(1200,900)
	var world=Node3D.new()
	root.add_child(world)
	var camera=Camera3D.new()
	world.add_child(camera)
	camera.position=Vector3(0,0,20)
	camera.projection=Camera3D.PROJECTION_ORTHOGONAL
	camera.size=10
	var manifest=JSON.parse_string(FileAccess.get_file_as_string("res://art_batches/hydra_batch_01/manifest.json"))
	var actors=[]
	for column in manifest.sheets.size():
		var sheet=manifest.sheets[column]
		var texture=load("res://art_batches/hydra_batch_01/"+sheet.file)
		for row in 4:
			var label=Label.new()
			label.text=sheet.direction+" / "+manifest.actions[row]
			label.position=Vector2(12+column*300,12+row*220)
			label.add_theme_font_size_override("font_size",14)
			root.add_child(label)
			if int(sheet.observed_grid[1])!=8:
				label.text+=" [irregular grid: skipped]"
				continue
			var clip=Clip.new()
			clip.atlas=texture
			clip.magenta_backing=true
			clip.looping=true
			var cell_size=Vector2(texture.get_width()/4.0,texture.get_height()/8.0)
			clip.pivot=Vector2(cell_size.x*.5,cell_size.y*.94)
			for cell in 8:
				var x0=roundi((cell%4)*cell_size.x)
				var y0=roundi((row*2+cell/4)*cell_size.y)
				var x1=roundi((cell%4+1)*cell_size.x)
				var y1=roundi((row*2+cell/4+1)*cell_size.y)
				clip.regions.append(Rect2i(x0,y0,x1-x0,y1-y0))
				clip.frame_pivots.append(Vector2((x1-x0)*.5,(y1-y0)*.94))
				clip.durations.append(.14)
			var actor=Actor.new()
			world.add_child(actor)
			actor.pixel_size=1.8/cell_size.y
			actor.position=Vector3(-4.5+column*3,2.6-row*2.45,0)
			if not actor.set_clip(clip): push_error(clip.validation_error()); quit(1); return
			actors.append(actor)
	for frame in 75:
		for actor in actors: actor.show_time(frame/30.0)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(output.path_join("frame-%03d.png"%frame))
	print("Hydra batch preview: twelve candidate sequences; irregular west grid excluded; no runtime admission")
	quit(0)

