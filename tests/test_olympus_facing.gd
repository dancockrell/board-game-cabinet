extends SceneTree
var checks := 0
var failures := 0

func _initialize() -> void:
	run.call_deferred()

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func run() -> void:
	var board := preload("res://presentation/olympus_arena_board.gd").new()
	root.add_child(board)
	await process_frame
	var state := {"elapsed":1.0,"events":[],"towers":[],"units":[{"id":1,"kind":"hoplites","side":0,"x":0.0,"z":3.0,"hp":100.0,"max_hp":100.0},{"id":2,"kind":"minotaur","side":0,"x":2.0,"z":3.0,"hp":100.0,"max_hp":100.0}]}
	board.show_state(state)
	var soldier = board._tokens[1]
	board._face_pixel_unit(soldier,Vector2.UP)
	for direction in [Vector2(0.99,-1),Vector2(1.01,-1),Vector2(0.99,-1),Vector2(1.01,-1)]:
		board._face_pixel_unit(soldier,direction)
		check(soldier.get_meta("pixel_facing")=="north", "Small diagonal steering retains north")
	board._face_pixel_unit(soldier,Vector2.RIGHT)
	check(soldier.get_meta("pixel_facing")=="east", "A clear turn changes facing immediately")
	board._face_pixel_unit(soldier,Vector2(1,-1.01),true)
	check(soldier.get_meta("pixel_facing")=="north", "Authoritative attack bypasses steering overlap")
	board._mark_attack_events([{"id":1,"kind":"hit","source_type":"unit","source_id":1,"source_x":0.0,"source_z":3.0,"x":-1.0,"z":3.0}])
	var sprite = soldier.get_node("Figure/PixelActor")
	check(sprite.clip==board.WEST_ATTACK, "Exact attack selects its own direction")
	board._face_pixel_unit(soldier,Vector2.RIGHT)
	check(soldier.get_meta("pixel_facing")=="west" and sprite.clip==board.WEST_ATTACK, "Crowd motion cannot turn an active attack")
	sprite.advance_visual(1.0)
	board._face_pixel_unit(soldier,Vector2.RIGHT)
	check(soldier.get_meta("pixel_facing")=="east", "Steering resumes after attack recovery")
	var beast = board._tokens[2]
	board._face_pixel_unit(beast,Vector2.UP)
	for direction in [Vector2(1,0.001),Vector2(1,-0.001),Vector2(-1,0),Vector2(-1,0.05)]:
		board._face_pixel_unit(beast,direction)
		check(beast.get_meta("pixel_facing")=="north", "Lateral correction retains two-view creature direction")
	board._face_pixel_unit(beast,Vector2.DOWN,true)
	check(beast.get_meta("pixel_facing")=="south", "Two-view creature faces a clear opposing target")
	board.queue_free()
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	print("Facing checks: %d; failures: %d" % [checks,failures])
	quit(1 if failures else 0)
