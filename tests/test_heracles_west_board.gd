extends SceneTree
const Walk=preload("res://themes/heracles_west_walk.tres")
func _initialize(): run.call_deferred()
func run():
	var board=preload("res://presentation/olympus_arena_board.gd").new()
	root.add_child(board)
	var state={"units":[{"id":1,"kind":"heracles","side":0,"x":0.0,"z":2.0,"hp":100.0,"max_hp":100.0}],"towers":[],"elapsed":1.0,"events":[]}
	board.show_state(state,0.0)
	var actor=board._tokens[1].get_node("Figure/PixelActor")
	var seen=[]
	for step in 24:
		state.units[0].x-=.04
		state.elapsed+=.05
		board.show_state(state,.05)
		if actor.clip!=Walk or not is_equal_approx(board._tokens[1].position.x,state.units[0].x): push_error("West motion diverged from state or clip"); quit(1); return
		if not seen.has(actor._shown): seen.append(actor._shown)
		if actor.texture.atlas!=Walk.frame_atlases[actor._shown]: push_error("Pose used wrong source sheet"); quit(1); return
	if seen.size()!=4: push_error("West gait did not play all four source poses"); quit(1); return
	state.elapsed+=.05
	board.show_state(state,.05)
	if actor.clip!=board.HERACLES_REST.west: push_error("Stopped Heracles failed to recover west rest"); quit(1); return
	board.free()
	print("Heracles west board: four source poses, authoritative movement and stopped recovery passed")
	quit(0)
