extends SceneTree
const NorthWalk = preload("res://themes/hoplite_north_walk.tres")
const WestRest = preload("res://themes/hoplite_west_rest.tres")
const WestClip = preload("res://themes/hoplite_west_attack.tres")
const SouthRest = preload("res://themes/hoplite_south_rest.tres")
const SouthClip = preload("res://themes/hoplite_south_attack.tres")
const NorthRest = preload("res://themes/hoplite_north_rest.tres")
const NorthClip = preload("res://themes/hoplite_north_attack.tres")
const ThrustClip = preload("res://themes/hoplite_thrust_clip.tres")
const GuardClip = preload("res://themes/hoplite_guard_clip.tres")
func _initialize() -> void: _run.call_deferred()
func _run() -> void:
	var source:=ProjectSettings.globalize_path("res://docs/art-references/hoplite-directions-candidate.png")
	var output:=""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--source="): source=arg.trim_prefix("--source=")
		if arg.begins_with("--capture="): output=arg.trim_prefix("--capture=")
	if not source.is_absolute_path() or not output.is_absolute_path(): quit(2); return
	if "--guard-motion" in OS.get_cmdline_user_args():
		await _review_guard(output)
		return
	var img:=Image.load_from_file(source)
	if img==null: quit(2); return
	var texture:=ImageTexture.create_from_image(img)
	if "--pose-sheet" in OS.get_cmdline_user_args():
		await _review_poses(texture,output)
		return
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

func _review_poses(texture: Texture2D, output: String) -> void:
	root.size=Vector2i(1440,960)
	var background:=ColorRect.new()
	background.color=Color("233f3b")
	background.size=Vector2(1440,960)
	root.add_child(background)
	var names:=["SCAN", "EQUIPMENT ADJUST", "PIVOT", "EXHAUSTED", "KNEEL / RISE", "RALLY"]
	# Broad sheet layout is irregular: use reviewed, nonoverlapping crop regions.
	var regions:=[Rect2(0,0,512,480),Rect2(512,0,512,480),Rect2(1024,0,512,480),Rect2(0,480,512,544),Rect2(512,480,512,544),Rect2(1024,480,512,544)]
	for i in 6:
		var atlas:=AtlasTexture.new()
		atlas.atlas=texture
		atlas.region=regions[i]
		var view:=TextureRect.new()
		view.texture=atlas
		view.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		view.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
		view.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		view.position=Vector2(80+(i%3)*440,85+(i/3)*425)
		view.size=Vector2(330,330)
		var material:=ShaderMaterial.new()
		material.shader=preload("res://presentation/sprite_chroma_preview.gdshader")
		view.material=material
		root.add_child(view)
		var label:=Label.new()
		label.text=names[i]+" / CANDIDATE"
		label.position=view.position+Vector2(25,338)
		root.add_child(label)
	var title:=Label.new()
	title.text="HOPLITE POSE RESERVE / STATIC POSES / CHROMA EDGE REVIEW"
	title.position=Vector2(35,25)
	title.add_theme_font_size_override("font_size",24)
	root.add_child(title)
	for i in 8: await process_frame
	await RenderingServer.frame_post_draw
	var error:=root.get_texture().get_image().save_png(output)
	quit(0 if error==OK else 2)

func _review_guard(output: String) -> void:
	root.size=Vector2i(1440,960)
	var board:=preload("res://presentation/olympus_arena_board.gd").new()
	root.add_child(board)
	board.camera.size=6.0
	board.camera.position=Vector3(0,10.5,14)
	board.camera.look_at(Vector3(0,.6,3))
	var guard=GuardClip
	var action=ThrustClip if "--thrust-motion" in OS.get_cmdline_user_args() else guard
	if "--north-motion" in OS.get_cmdline_user_args(): action=NorthClip
	if "--south-motion" in OS.get_cmdline_user_args(): action=SouthClip
	if "--west-motion" in OS.get_cmdline_user_args(): action=WestClip
	var rest=preload("res://presentation/sprite_clip.gd").new()
	rest.atlas=guard.atlas
	rest.pivot=guard.pivot
	rest.regions.assign([guard.regions[0]])
	rest.durations=PackedFloat32Array([1.0])
	rest.looping=true
	var actor:=preload("res://presentation/pixel_actor.gd").new()
	board.add_child(actor)
	actor.pixel_size=.003
	actor.position=Vector3(0,.15,3)
	actor.reset_playback(WestRest if action==WestClip else (SouthRest if action==SouthClip else (NorthRest if action==NorthClip else rest)))
	var walking := "--north-walk" in OS.get_cmdline_user_args()
	if walking:
		actor.reset_playback(NorthRest)
		if not actor.set_locomotion(NorthWalk):
			push_error("Walking clip rejected: " + NorthWalk.validation_error())
			quit(2)
			return
	var title:=Label.new()
	title.text="HOPLITE / ACTION TIMING STUDY / NOT GAMEPLAY"
	title.position=Vector2(30,25)
	root.add_child(title)
	var folder:=output.get_basename()+"-frames"
	DirAccess.make_dir_recursive_absolute(folder)
	for frame in 90:
		if frame==15 and not walking: actor.play_attack(1,action) if action!=guard else actor.react_to_hit(1,action)
		if frame==25 and not walking: actor.play_attack(1,action) if action!=guard else actor.react_to_hit(1,action) # repeated snapshot must not restart
		actor.advance_visual(1.0/30.0)
		for tick in 2: await process_frame
		await RenderingServer.frame_post_draw
		var img:=root.get_texture().get_image()
		if img.save_png(folder.path_join("frame-%04d.png"%frame))!=OK: quit(2); return
		if frame==24: img.save_png(output)
	print("Guard trial: 90 frames, repeated event did not restart playback")
	quit()
