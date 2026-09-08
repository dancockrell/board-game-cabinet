extends SceneTree
const Walk=preload("res://themes/harpies_north_flight.tres")
func _initialize(): run.call_deferred()
func run():
	assert(Walk.validation_error().is_empty())
	assert(Walk.regions.size()==8 and Walk.looping)
	var elapsed=0.0
	var hashes=[]
	for i in 8:
		assert(Walk.frame_at(elapsed+.001)==i)
		var pixels=Walk.atlas.get_image().get_region(Walk.regions[i]).get_data()
		var digest=hash(pixels)
		assert(not hashes.has(digest))
		hashes.append(digest)
		elapsed+=Walk.durations[i]
	assert(Walk.frame_at(elapsed+.001)==0)
	if DisplayServer.get_name()=="headless": print("Harpy north flight: eight distinct cells, ordered timing and loop passed"); quit(0); return
	var actor=preload("res://presentation/pixel_actor.gd").new()
	root.add_child(actor)
	assert(actor.reset_playback(Walk))
	actor.advance_visual(.27)
	var frame=actor._shown
	actor.advance_visual(0.0)
	assert(actor._shown==frame)
	actor.reset_playback(Walk)
	assert(actor._shown==0)
	actor.free()
	var board=preload("res://presentation/olympus_arena_board.gd").new()
	root.add_child(board)
	var state={"units":[{"id":1,"kind":"harpies","flying":true,"side":0,"x":0.0,"z":2.0,"hp":100.0,"max_hp":100.0}],"towers":[],"elapsed":1.0,"events":[]}
	board.show_state(state,0.0)
	var moving=board._tokens[1].get_node("Figure/PixelActor")
	var seen=[]
	for step in 24:
		state.units[0].z-=.04
		state.elapsed+=.05
		board.show_state(state,.05)
		assert(moving.clip==Walk)
		if not seen.has(moving._shown): seen.append(moving._shown)
		assert(is_equal_approx(board._tokens[1].position.z,state.units[0].z))
	assert(seen.size()==8)
	state.elapsed+=.05
	board.show_state(state,.05)
	assert(moving.clip==board.HARPIES_FLIGHT.north)
	board.free()
	print("Harpy north flight: eight distinct cells, ordered timing, loop, pause and reset passed")
	quit(0)

