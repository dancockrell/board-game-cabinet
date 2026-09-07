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
	var shrine=board._towers.blue.get_node("Architecture/PixelBuilding")
	check(shrine is Sprite3D and shrine.clip.validation_error().is_empty(), "Tower uses valid authored sprite Resource")
	check(board._towers.blue.position==Vector3(0,0.1,6.6), "Building keeps authoritative footprint origin")
	var unit: Node3D = board._tokens[1]
	state.units[0].z = 2.0
	state.units[0].hp = 50.0
	board.show_state(state, 0.1)
	check(board._tokens[1] == unit, "Unit reused for snapshot updates")
	check(is_equal_approx(unit.position.z, 2.0), "Authoritative position rendered")
	check(is_equal_approx(unit.get_node("Health/Fill").scale.x, 0.5), "Health ratio rendered")
	check(unit.get_node("Hit").visible, "Damage impact visible")
	state.units[0].charge_ready = true
	board.show_state(state, 0.05)
	check(unit.get_node("Ability").visible, "Authoritative Minotaur charge remains visible until consumed")
	state.units[0].charge_ready = false
	board.show_state(state, 0.05)
	check(not unit.get_node("Ability").visible, "Consumed charge clears persistent board marker")
	state.towers[0].hp = 0.0
	board.show_state(state, 0.3)
	check(not unit.get_node("Hit").visible, "Damage impact expires")
	check(board._towers.blue.visible and shrine.clip == board.RUBBLE_CLIP and board._towers.blue.scale == Vector3.ONE, "Destroyed temple remains as ruins")
	check(not board._towers.blue.get_node("Health").visible, "Destroyed temple health hidden")
	var rubble_material=shrine.material_override
	board.show_state(state)
	check(rubble_material != null and shrine.material_override==rubble_material, "Repeated destroyed snapshot retains rubble presentation")
	state.towers[0].hp=500.0
	board.show_state(state)
	check(board._towers.blue.scale==Vector3.ONE and board._towers.blue.get_node("Health").visible and shrine.clip==board.SHRINE_CLIP and shrine.material_override==null, "Restored authoritative tower resets sprite scale and health")
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
	board.show_deployment(Vector2(2.7,2),true,false,"minotaur")
	check(board._ghost != null and board._ghost.visible, "Legal deployment shows selected miniature ghost")
	check(board._tokens.is_empty(), "Ghost never becomes an authoritative replica")
	board.show_deployment(Vector2(2.7,-2),false,false,"minotaur")
	check(not board._ghost.visible, "Rejected placement hides miniature ghost")
	board.clear_preview()
	check(not board._ghost.visible and not board._preview.visible, "Clear hides both ghost and placement marker")
	state.events = [{"id":0,"kind":"lightning","x":0.0,"z":0.0,"side":0}]
	board.show_state(state)
	check(not board.combat_fx.effects.is_empty(), "Lightning visual created")
	var lightning_count: int = board.combat_fx.effects.size()
	board.show_state(state)
	check(board.combat_fx.effects.size() == lightning_count, "Repeated snapshot never duplicates event")
	board.show_state(state, 0.6)
	board.show_state(state, 0.6)
	check(board.combat_fx.effects.is_empty(), "Event visual expires")
	state.events.append({"id":1,"kind":"hit","source_id":2,"source_type":"unit","x":1.0,"z":1.0,"side":0,"source_x":0.0,"source_z":0.0})
	state.units = [{"id":2,"kind":"atalanta","side":0,"x":0.4,"z":0.0,"hp":100.0,"max_hp":100.0}]
	state.units.append({"id":3,"kind":"atalanta","side":0,"x":0.0,"z":0.0,"hp":100.0,"max_hp":100.0})
	board.show_state(state)
	var has_tracer := false
	for effect in board.combat_fx.effects:
		if str(effect.motion) == "projectile": has_tracer = true
	check(has_tracer, "Source-aware hit creates tracer")
	check(float(board._tokens[2].get_meta("attack_until", 0.0)) > board._time, "Hit event triggers presentation-only attack follow-through")
	check(not board._tokens[3].has_meta("attack_until"), "Closer neighbour does not steal identified attack")
	state.events.append({"id":2,"kind":"hit","source_id":3,"source_type":"tower","side":0,"x":1.0,"z":1.0})
	state.events.append({"id":3,"kind":"hit","source_id":999,"source_type":"unit","side":0,"x":1.0,"z":1.0})
	board.show_state(state)
	check(not board._tokens[3].has_meta("attack_until"), "Tower and missing sources are never reassigned to a unit")
	board.show_state(state, 0.2)
	board.show_state(state, 0.4)
	check(board.combat_fx.effects.is_empty(), "Tracer and impact expire")
	state.units.append({"id":4,"kind":"hoplites","side":0,"x":2.0,"z":2.0,"hp":100.0,"max_hp":100.0})
	state.events.append({"id":4,"kind":"hit","source_id":4,"source_type":"unit","side":0,"x":2.5,"z":2.0})
	board.show_state(state)
	var attacking=board._tokens[4].get_node("Figure/PixelActor")
	check(attacking.clip==board.THRUST_CLIP, "Exact Hoplite attack event starts thrust clip")
	board.show_state(state,.6)
	check(attacking.clip.looping and attacking.scale==Vector3.ONE, "Live Hoplite returns to rest without replaying old attack")
	state.units[-1].z=1.9
	board.show_state(state,.1)
	check(attacking.clip==board.NORTH_REST, "Upward movement selects rear rest")
	state.events.append({"id":5,"kind":"hit","source_id":4,"source_type":"unit","side":0,"source_x":2.0,"source_z":1.9,"x":2.0,"z":1.0})
	board.show_state(state)
	check(attacking.clip==board.NORTH_ATTACK, "Upward authoritative target selects rear attack")
	board.show_state(state,.6)
	check(attacking.clip==board.NORTH_REST, "Rear attack recovers without turning to camera")
	state.units[-1].hp=80.0
	board.show_state(state,.1)
	check(attacking.clip==board.NORTH_REST, "Rear damage keeps orientation while impact marker handles feedback")
	await process_frame
	print("Olympus board: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
