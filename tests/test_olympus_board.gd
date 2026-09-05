extends SceneTree
## Native graphics validation; run without --headless.
var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func run() -> void:
	var board := preload("res://presentation/olympus_arena_board.gd").new()
	root.add_child(board)
	await process_frame
	for x in [-4.5, 0.0, 4.5]:
		for z in [-7.5, 0.0, 7.5]:
			var screen := board.camera.unproject_position(Vector3(x, 0.12, z))
			check(board.pick_ground(screen).distance_to(Vector2(x, z)) < 0.001, "Projected ground pick roundtrip")
	check(not board.pick_ground(board.camera.unproject_position(Vector3(7, 0.12, 0))).is_finite(), "Outside board rejected")
	var state := {"units":[{"id":1,"kind":"minotaur","side":0,"x":2.7,"z":3.0,"hp":100.0,"max_hp":100.0}], "towers":[{"id":"blue","kind":"temple","side":0,"x":0.0,"z":6.6,"hp":500.0,"max_hp":500.0}], "elapsed":0.0,"events":[]}
	board.show_state(state)
	check(board._tokens.size() == 1, "Unit spawned")
	var unit: Node3D = board._tokens[1]
	state.units[0].z = 2.0
	state.units[0].hp = 50.0
	board.show_state(state, 0.1)
	check(board._tokens[1] == unit, "Unit reused for snapshot updates")
	check(is_equal_approx(unit.position.z, 2.0), "Authoritative position rendered")
	check(is_equal_approx(unit.get_node("Health/Fill").scale.x, 0.5), "Health ratio rendered")
	check(unit.get_node("Hit").visible, "Damage impact visible")
	state.towers[0].hp = 0.0
	board.show_state(state, 0.3)
	check(not unit.get_node("Hit").visible, "Damage impact expires")
	check(board._towers.blue.visible and board._towers.blue.scale.y < 0.2, "Destroyed temple remains as ruins")
	check(not board._towers.blue.get_node("Health").visible, "Destroyed temple health hidden")
	state.units.clear()
	board.show_state(state)
	check(board._tokens.is_empty(), "Missing units removed")
	board.show_deployment(Vector2(2.7, 2), true)
	check(board._preview.visible, "Deployment preview shown")
	board.show_deployment(Vector2.INF, false)
	check(not board._preview.visible, "Invalid pick hides preview")
	board.show_deployment(Vector2.ZERO, true, true)
	check(board._preview.scale.x > 2, "Spell preview shows larger area")
	board.clear_preview()
	check(not board._preview.visible, "Preview explicitly cleared")
	state.events = [{"id":0,"kind":"lightning","x":0.0,"z":0.0,"side":0}]
	board.show_state(state)
	check(board._effects.size() == 1, "Lightning visual created")
	board.show_state(state)
	check(board._effects.size() == 1, "Repeated snapshot never duplicates event")
	board.show_state(state, 0.6)
	check(board._effects.is_empty(), "Event visual expires")
	state.events.append({"id":1,"kind":"hit","x":1.0,"z":1.0,"side":0,"source_x":0.0,"source_z":0.0})
	board.show_state(state)
	check(board._effects[0].has("destination"), "Source-aware hit creates tracer")
	board.show_state(state, 0.2)
	check(board._effects.is_empty(), "Tracer expires")
	await process_frame
	print("Olympus board: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
