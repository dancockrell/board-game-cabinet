extends SceneTree

var sheets: Array[Texture2D] = []
var actors: Array[Sprite2D] = []
var elapsed := 0.0
var count := 0
var output := ""
var regions: Dictionary = {}
var bounds := [[0,232,466,693,887],[0,224,458,680,887],[0,241,489,711,887],[0,222,446,669,887]]

func _initialize() -> void:
	regions = JSON.parse_string(FileAccess.get_file_as_string("res://art_batches/atalanta_batch_01/regions.json"))
	root.size = Vector2i(1440,1000)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="): output = arg.trim_prefix("--capture=")
	if not output.is_empty(): DirAccess.make_dir_recursive_absolute(output)
	var background := ColorRect.new()
	background.color = Color("25352d")
	background.size = Vector2(1440,1000)
	root.add_child(background)
	var shader := Shader.new()
	shader.code = "shader_type canvas_item; void fragment(){ vec4 c=texture(TEXTURE,UV); float key=step(0.65,c.r)*step(0.65,c.b)*(1.0-step(0.35,c.g)); COLOR=vec4(c.rgb,c.a*(1.0-key)); }"
	for d in 4:
		var direction: String = ["south","north","east","west"][d]
		var source := Image.load_from_file("res://art_batches/atalanta_batch_01/"+direction+".png")
		assert(source != null and source.get_size() == Vector2i(1774,887))
		sheets.append(ImageTexture.create_from_image(source))
		for row in 4:
			var actor := Sprite2D.new()
			actor.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			actor.texture = sheets[d]
			actor.region_enabled = true
			actor.position = Vector2(180+d*360,137+row*240)
			var material := ShaderMaterial.new()
			material.shader = shader
			actor.material = material
			root.add_child(actor)
			actors.append(actor)
			var label := Label.new()
			label.text = direction.to_upper()+" / "+["walk","bow attack","hurt","defeat"][row]+" — CANDIDATE"
			label.position = Vector2(30+d*360,10+row*240)
			root.add_child(label)

func _process(delta: float) -> bool:
	elapsed += delta
	var frame := int(elapsed/0.12)%8
	for d in 4:
		for row in 4:
			var left := int(round(frame*1774.0/8))
			var right := int(round((frame+1)*1774.0/8))
			var direction: String = ["south","north","east","west"][d]
			var region: Array = regions[direction][row*8+frame].region
			var rect := Rect2(region[0],region[1],region[2],region[3])
			actors[d*4+row].region_rect = rect
			actors[d*4+row].offset = rect.get_center()-Vector2((left+right)/2.0,(bounds[d][row]+bounds[d][row+1])/2.0)
	count += 1
	if not output.is_empty() and count%30==0: capture.call_deferred()
	if count >= 240:
		print("Atalanta batch preview: four original sheets, sixteen candidate rows; no runtime admission")
		quit()
	return false

func capture() -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(output.path_join("frame-%04d.png"%count))
