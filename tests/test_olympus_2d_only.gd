extends SceneTree
## Native gate on the actual active scene, including legally spawned combat FX.
## Node3D placement is allowed; visible artwork must be sprites or planar drawings.
var failures: Array[String] = []
var kinds: Array[String] = []
var inspected := {}
var effect_samples := 0
var placements := 0
var sprite_samples := 0

func _initialize() -> void: run.call_deferred()

func check(ok: bool, message: String) -> void:
	if not ok and not failures.has(message):
		failures.append(message)
		push_error(message)

func planar(vertices: PackedVector3Array) -> bool:
	if vertices.size() < 4: return true
	var origin := vertices[0]
	var normal := Vector3.ZERO
	for i in range(1, vertices.size() - 1):
		normal = (vertices[i] - origin).cross(vertices[i + 1] - origin)
		if normal.length_squared() > 0.00000001: break
	if normal.length_squared() <= 0.00000001: return true
	normal = normal.normalized()
	for point in vertices:
		if absf((point - origin).dot(normal)) > 0.00001: return false
	return true

func inspect_art(node: Node) -> void:
	var script = node.get_script()
	if script != null:
		var path := str(script.resource_path)
		check(not ("model_builder" in path or "figure_factory" in path or "miniature" in path), "No legacy model factory attached: " + path)
	if node is MeshInstance3D and node.mesh != null:
		var mesh: Mesh = node.mesh
		if not inspected.has(mesh.get_instance_id()):
			inspected[mesh.get_instance_id()] = true
			check(mesh is QuadMesh or mesh is PlaneMesh or mesh is ArrayMesh, "Only planar mesh types allowed: " + str(node.get_path()) + " " + mesh.get_class())
			if mesh is ArrayMesh:
				var vertices := PackedVector3Array()
				for surface in mesh.get_surface_count():
					vertices.append_array(mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX])
				check(planar(vertices), "Flat drawing has no volumetric vertices across surfaces: " + str(node.get_path()))
	if node is Sprite3D:
		sprite_samples += 1
		check(node.texture != null, "Sprite artwork has a texture: " + str(node.get_path()))
	for child in node.get_children(): inspect_art(child)

func visual_signature(node: Node, result: Array) -> void:
	if node is Node3D: result.append([node.get_instance_id(), node.transform, node.visible])
	if node is Sprite3D and node.texture is AtlasTexture:
		result.append([node.texture.region, node.offset])
	for child in node.get_children(): visual_signature(child, result)

func run() -> void:
	root.size = Vector2i(1200, 850)
	var configured := str(ProjectSettings.get_setting("application/run/main_scene"))
	check(configured == "res://app/olympus_arena.tscn", "Active project launches Olympus")
	var app = load(configured).instantiate()
	root.add_child(app)
	await process_frame
	app.set_process(false)
	app.set_process_input(false)
	app.set_process_unhandled_input(false)
	app.sound.set_muted(true)
	app._start_or_restart()
	app._countdown_remaining = 0.0
	app.session.new_game(42)
	app._refresh()
	inspect_art(app)
	var stage_sprites := 0
	for child in app.board.stage.get_children():
		if child is Sprite3D and child.texture != null: stage_sprites += 1
	check(stage_sprites > 0, "Battlefield uses a painted sprite backdrop")
	var paused_checked := false
	var capture := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--art-capture="): capture = arg.trim_prefix("--art-capture=")
	for tick in 1800:
		if app.state.phase != "playing": break
		if tick % 10 == 0:
			for slot in 4:
				var position := Vector2(-2.7 if placements % 2 == 0 else 2.7, 1.3)
				if app.state.hand[slot] == "thunderbolt": position.y = -3.0
				if app.session.deploy(slot, position).get("ok", false):
					placements += 1
					break
		app.session.tick()
		app._refresh()
		app.board.show_state(app.state, .1)
		for token in app.board._tokens.values():
			var kind := str(token.get_meta("kind", ""))
			if not kinds.has(kind): kinds.append(kind)
			var actor = token.get_node_or_null("Figure/PixelActor")
			check(actor is Sprite3D and actor.texture != null, "Legal roster member uses authored sprite: " + kind)
		if not app.board.combat_fx.effects.is_empty():
			effect_samples += 1
			inspect_art(app)
			if not paused_checked and tick > 50:
				app.board.show_state(app.state, 0.0)
				var before: Array = []
				visual_signature(app.board, before)
				var state_before: Dictionary = app.session.snapshot().duplicate(true)
				var clock_before: float = app.board._time
				app.board.show_state(app.state, 0.0)
				var after: Array = []
				visual_signature(app.board, after)
				check(before == after and clock_before == app.board._time, "Zero-delta presentation freezes sprites, effects and clock")
				check(state_before == app.session.snapshot(), "Presentation leaves authoritative snapshot unchanged")
				paused_checked = true
		await process_frame
		if tick == 400 and capture != "":
			await RenderingServer.frame_post_draw
			check(root.get_texture().get_image().save_png(capture) == OK, "Native art screenshot saved")
	check(kinds.size() == 7, "All seven characters legally encountered")
	check(effect_samples > 0 and placements > 0 and sprite_samples > 0, "Native legal match exercised sprite combat effects")
	check(paused_checked, "Pause check exercised during live effects")
	check(app.state == app.session.snapshot(), "Displayed state stays authoritative")
	print("Olympus 2D-only gate: %d characters, %d legal placements, %d effect samples, %d unique mesh drawings, %d failures" % [kinds.size(), placements, effect_samples, inspected.size(), failures.size()])
	app.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)

