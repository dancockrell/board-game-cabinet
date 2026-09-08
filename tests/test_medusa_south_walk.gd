extends SceneTree
const Walk = preload("res://themes/medusa_south_walk.tres")
var checks = 0
var failures = 0
func check(value: bool, message: String):
	checks += 1
	if not value:
		failures += 1
		push_error(message)
func _initialize(): run.call_deferred()
func run():
	check(Walk.validation_error().is_empty(), "Clip resource validation")
	check(Walk.regions.size() == 7 and Walk.looping, "Seven admitted gait cells and looping")
	var elapsed = 0.0
	var hashes = []
	for i in Walk.regions.size():
		check(Walk.frame_at(elapsed + .001) == i, "Sequential timing %d" % i)
		var digest = hash(Walk.frame_atlases[i].get_image().get_region(Walk.regions[i]).get_data())
		check(not hashes.has(digest), "Distinct source pixels %d" % i)
		hashes.append(digest)
		elapsed += Walk.durations[i]
	check(Walk.frame_at(elapsed + .001) == 0, "Complete gait wraps")
	if DisplayServer.get_name() != "headless":
		var board = preload("res://presentation/olympus_arena_board.gd").new()
		root.add_child(board)
		var state = {"units":[{"id":1,"kind":"medusa","side":0,"x":0.0,"z":2.0,"hp":100.0,"max_hp":100.0}],"towers":[],"elapsed":1.0,"events":[]}
		board.show_state(state,0.0)
		var actor = board._tokens[1].get_node("Figure/PixelActor")
		var seen = []
		for step in 24:
			state.units[0].z += .04
			state.elapsed += .05
			board.show_state(state,.05)
			check(actor.clip == Walk, "Moving south chooses south gait")
			check(is_equal_approx(board._tokens[1].position.z,state.units[0].z), "Visual root follows authoritative position")
			check(actor.texture.region == Rect2(Walk.regions[actor._shown]), "Actual texture selects admitted region")
			if not seen.has(actor._shown): seen.append(actor._shown)
		check(seen.size() == 7, "Board played all seven gait poses")
		var prior = actor._shown
		actor.advance_visual(0.0)
		check(actor._shown == prior, "Paused animation does not advance")
		state.elapsed += .05
		board.show_state(state,.05)
		check(actor.clip == board.MEDUSA_REST.south, "Stopped Medusa returns south rest")
		board.free()
	print("Medusa south walk: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
