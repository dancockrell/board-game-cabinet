extends SceneTree
## Staged art comparison only: raw candidate GLB replaces central-temple visuals.
## This script does not admit assets or change the shipped scene or game state.
var _bounds := AABB()
var _has_bounds := false

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	var model_path := ""
	var capture_path := ""
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--model="): model_path = argument.trim_prefix("--model=")
		if argument.begins_with("--output="): capture_path = argument.trim_prefix("--output=")
	if not model_path.is_absolute_path() or not capture_path.is_absolute_path():
		push_error("Pass absolute --model= GLB and --output= PNG paths.")
		quit(2)
		return
	root.min_size = Vector2i.ZERO
	root.size = Vector2i(1440, 960)
	root.content_scale_size = Vector2i(1440, 960)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	root.gui_disable_input = true
	var app = preload("res://app/olympus_arena.tscn").instantiate()
	root.add_child(app)
	app.set_process(false)
	app.set_process_input(false)
	app.set_process_unhandled_input(false)
	app.sound.set_muted(true)
	app._show_overlay(false)
	for tower in app.state.towers:
		if tower.kind != "temple": continue
		var document := GLTFDocument.new()
		var state := GLTFState.new()
		if document.append_from_file(model_path, state) != OK:
			push_error("Cannot load candidate temple GLB.")
			quit(2)
			return
		var imported := document.generate_scene(state)
		if imported == null:
			quit(2)
			return
		var tower_root: Node3D = app.board._towers[tower.id]
		for child in tower_root.get_children():
			if child is Node3D and child.name != "Health": child.hide()
		var normalized := Node3D.new()
		normalized.name = "StagedGeneratedTemple"
		var facing := Node3D.new()
		# Candidate doorway faces +X. Turn each doorway toward the river.
		facing.rotation.y = PI * 0.5 if int(tower.side) == 0 else -PI * 0.5
		normalized.add_child(facing)
		facing.add_child(imported)
		_bounds = AABB()
		_has_bounds = false
		_gather_bounds(facing, Transform3D.IDENTITY)
		if not _has_bounds:
			quit(2)
			return
		var factor := 2.5 / maxf(_bounds.size.x, _bounds.size.z)
		normalized.scale = Vector3.ONE * factor
		normalized.position = -Vector3(_bounds.get_center().x, _bounds.position.y, _bounds.get_center().z) * factor
		tower_root.add_child(normalized)
		# The authoritative root remains at (tower.x, 0.1, tower.z).
		assert(tower_root.position.is_equal_approx(Vector3(float(tower.x), 0.1, float(tower.z))))
	var banner := Label.new()
	banner.text = "STAGED ASSET TRIAL  •  GENERATED CENTRAL TEMPLES  •  NOT SHIPPED"
	banner.position = Vector2(300, 78)
	banner.add_theme_font_size_override("font_size", 15)
	banner.add_theme_color_override("font_color", Color("ffe7a2"))
	root.add_child(banner)
	for frame in 24: await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(capture_path.get_base_dir())
	var result := root.get_texture().get_image().save_png(capture_path)
	print("Staged temple trial: " + capture_path)
	app.queue_free()
	for frame in 4: await process_frame
	quit(0 if result == OK else 1)

func _gather_bounds(node: Node, parent_transform: Transform3D) -> void:
	var current := parent_transform
	if node is Node3D: current = parent_transform * (node as Node3D).transform
	if node is MeshInstance3D and (node as MeshInstance3D).mesh != null:
		var bounds := current * (node as MeshInstance3D).mesh.get_aabb()
		_bounds = _bounds.merge(bounds) if _has_bounds else bounds
		_has_bounds = true
	for child in node.get_children(): _gather_bounds(child, current)
