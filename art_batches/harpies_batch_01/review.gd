extends SceneTree
var sheets: Array[Texture2D] = []
var actors: Array[Sprite2D] = []
var count := 0
var output := ""
var regions: Dictionary = {}
const NAMES = ["south_a","north_a","south_b","north_b"]
func _initialize() -> void:
    root.size = Vector2i(1440,1000)
    regions = JSON.parse_string(FileAccess.get_file_as_string("res://art_batches/harpies_batch_01/regions.json"))
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
        var source := Image.load_from_file("res://art_batches/harpies_batch_01/"+NAMES[d]+".png")
        assert(source != null and source.get_size() == Vector2i(887,1774))
        sheets.append(ImageTexture.create_from_image(source))
        for action in 4:
            var actor := Sprite2D.new()
            actor.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
            actor.texture = sheets[d]
            actor.region_enabled = true
            actor.position = Vector2(180+d*360,137+action*240)
            var material := ShaderMaterial.new()
            material.shader = shader
            actor.material = material
            root.add_child(actor)
            actors.append(actor)
            var label := Label.new()
            var actions: Array = ["flight","dive attack","hurt","defeat"] if d<2 else ["hover","takeoff","landing","victory"]
            label.text = NAMES[d].to_upper()+" / "+actions[action]+" — CANDIDATE"
            label.position = Vector2(30+d*360,10+action*240)
            root.add_child(label)
func _process(_delta: float) -> bool:
    var frame := (count/8)%8
    for d in 4:
        for action in 4:
            var region: Array = regions[NAMES[d]][action*8+frame].region
            var rect := Rect2(region[0],region[1],region[2],region[3])
            actors[d*4+action].region_rect = rect
            var cell_row: int = action*2+frame/4
            var cell_col: int = frame%4
            actors[d*4+action].offset = rect.get_center()-Vector2((cell_col+0.5)*887/4,(cell_row+0.5)*1774/8)
    if not output.is_empty() and count%8==0: capture.call_deferred(count)
    count += 1
    if count >= 128:
        print("Harpies batch native preview: 128 candidate regions, sixteen actions, no runtime admission")
        quit()
    return false
func capture(index: int) -> void:
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(output.path_join("frame-%04d.png"%index))
