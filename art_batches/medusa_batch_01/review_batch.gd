extends SceneTree
## Candidate-only full-batch motion review. Does not load or alter gameplay.
func _initialize(): run.call_deferred()
func run():
	var output := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="): output=arg.trim_prefix("--capture=")
	if not output.is_absolute_path(): quit(2); return
	DirAccess.make_dir_recursive_absolute(output)
	root.size=Vector2i(960,760)
	var manifest: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://art_batches/medusa_batch_01/manifest.json"))
	var background=ColorRect.new()
	background.color=Color("#263a38")
	background.size=Vector2(960,760)
	root.add_child(background)
	var entries: Array=[]
	for column in manifest.sheets.size():
		var sheet: Dictionary=manifest.sheets[column]
		var source=Image.load_from_file("res://art_batches/medusa_batch_01/"+sheet.file)
		var texture=ImageTexture.create_from_image(source)
		for row in sheet.rows.size():
			var label=Label.new()
			label.text=sheet.direction.to_upper()+" / "+sheet.rows[row].action+" / CANDIDATE"
			label.position=Vector2(column*240+6,row*190+3)
			label.add_theme_font_size_override("font_size",12)
			root.add_child(label)
			var sprite=Sprite2D.new()
			sprite.centered=false
			sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
			sprite.position=Vector2(column*240+34,row*190+23)
			sprite.scale=Vector2(.70,.70)
			var material=ShaderMaterial.new()
			material.shader=load("res://presentation/sprite_chroma_preview.gdshader")
			sprite.material=material
			var atlas=AtlasTexture.new()
			atlas.atlas=texture
			sprite.texture=atlas
			root.add_child(sprite)
			entries.append({"sprite":sprite,"atlas":atlas,"row":sheet.rows[row]})
	for frame in 96:
		var phase=(frame/4)%8
		for entry in entries:
			var values: Array=entry.row.regions[phase]
			entry.atlas.region=Rect2(values[0],values[1],values[2],values[3])
			entry.sprite.offset=Vector2((222-values[2])/2.0,0)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(output.path_join("frame-%03d.png" % frame))
	print("Medusa batch candidate preview: 16 rows, 128 occupied source cells, 96 native frames. Not runtime admission.")
	quit(0)
