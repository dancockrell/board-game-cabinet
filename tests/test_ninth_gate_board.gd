extends SceneTree
## Native renderer regression: projection, hidden information and interrupted motion.
## Run without --headless; Compatibility procedural geometry requires a real renderer.
func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1000, 533)
	viewport.own_world_3d = true
	root.add_child(viewport)
	var board = load("res://presentation/ninth_gate_board.gd").new()
	viewport.add_child(board)
	var session = load("res://games/ninth_gate/session.gd").new()
	var view: Dictionary = session.view_for("heaven")
	board.show_view(view)
	await process_frame
	for y in 8:
		for x in 12:
			var screen: Vector2 = board.camera.unproject_position(Vector3(x-5.5, 0.05, y-3.5))
			assert(board.pick_cell(screen, viewport.size) == Vector2i(x,y), "Every cell center must pick its original square")
	assert(board._tokens.size() == view.units.size(), "Render exactly the observed units")
	assert(not board._tokens.has("hell0"), "Unobserved enemy identity must not enter the renderer")
	var moved: Dictionary = view.duplicate(true)
	moved.units[0].x += 1
	board.show_view(moved, true)
	board.show_view(view, false)
	assert(board._tokens["heaven0"].position == Vector3(view.units[0].x-5.5, 0.05, view.units[0].y-3.5), "Interrupted animations must snap back to the new authoritative snapshot")
	print("PASS 99 Ninth Gate renderer assertions")
	quit()
