extends SceneTree
## Candidate atlas playback only. No runtime admission or simulation changes.
var sprites: Array[Sprite2D] = []
var tick := 0
var output := ""
func _initialize() -> void:
	root.size = Vector2i(1100, 1060)
	root.content_scale_size = Vector2i(1100, 1060)
	RenderingServer.set_default_clear_color(Color("243031"))
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="): output = arg.trim_prefix("--capture=")
	if not output.is_empty(): DirAccess.make_dir_recursive_absolute(output)
	var shader := Shader.new()
	shader.code = "shader_type canvas_item; void fragment(){vec4 c=texture(TEXTURE,UV); if(c.r>0.65 && c.b>0.65 && c.g<0.35){c.a=0.0;} COLOR=c;}"
	for d in 4:
		var direction: String = ["south", "north", "east", "west"][d]
		var path := "res://art_batches/heracles_batch_01/"+direction+".png"
		var texture := ImageTexture.create_from_image(Image.load_from_file(path))
		for row in 4:
			var s := Sprite2D.new()
			s.texture = texture
			s.hframes = 8
			s.vframes = 4
			s.position = Vector2(140+d*270, 145+row*250)
			s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			var mat := ShaderMaterial.new()
			mat.shader = shader
			s.material = mat
			root.add_child(s)
			sprites.append(s)
			var label := Label.new()
			label.text = direction+" / "+["walk", "run", "attack", "defeat"][row]
			label.position = s.position+Vector2(-100,-125)
			root.add_child(label)
	process_frame.connect(_step)
func _step() -> void:
	for i in sprites.size(): sprites[i].frame = (i%4)*8 + (tick/6)%8
	await RenderingServer.frame_post_draw
	if not output.is_empty(): root.get_texture().get_image().save_png(output.path_join("frame-%03d.png"%tick))
	tick += 1
	if tick >= 96:
		print("Heracles batch preview: 16 rows, 128 candidate cells, two playback cycles; not runtime admitted")
		quit()
