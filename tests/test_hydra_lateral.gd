extends SceneTree
const Clips = [preload("res://themes/hydra_east_idle.tres"),preload("res://themes/hydra_west_idle.tres"),preload("res://themes/hydra_east_attack.tres"),preload("res://themes/hydra_west_attack.tres")]

const Walks = [preload("res://themes/hydra_east_walk.tres"),preload("res://themes/hydra_west_walk.tres")]

func _initialize() -> void: run.call_deferred()

func run() -> void:
	for clip in Walks:
		if not clip.validation_error().is_empty() or not clip.looping or clip.regions.size()!=4: quit(1); return
		for i in 4:
			if clip.frame_at(i*.2+.03)!=i: quit(1); return
	for i in Clips.size():
		var clip=Clips[i]
		if not clip.validation_error().is_empty(): push_error(clip.validation_error()); quit(1); return
		if clip.frame_at(0)!=0 or clip.frame_at(clip.durations[0]+.001)!=1: quit(1); return
		if clip.looping != (i<2): quit(1); return
		if not clip.looping and clip.frame_at(100)!=3: quit(1); return
	if DisplayServer.get_name() != "headless":
		var board=preload("res://presentation/olympus_arena_board.gd").new()
		root.add_child(board)
		var state={"units":[{"id":1,"kind":"hydra","side":0,"x":0.0,"z":2.0,"hp":100.0,"max_hp":100.0}],"towers":[],"elapsed":1.0,"events":[]}
		board.show_state(state,0.0)
		var actor=board._tokens[1].get_node("Figure/PixelActor")
		for direction in [1.0,-1.0]:
			var seen=[]
			for step in 10:
				state.units[0].x+=direction*.1
				state.elapsed+=.1
				board.show_state(state,.1)
				if actor.clip != Walks[0 if direction>0 else 1]: push_error("Hydra lateral movement did not select walk"); quit(1); return
				if not seen.has(actor._shown): seen.append(actor._shown)
			if seen.size()!=4: push_error("Hydra lateral walk did not exercise every frame"); quit(1); return
		state.elapsed+=.1
		board.show_state(state,.1)
		if actor.clip!=board.HYDRA_IDLE.west: push_error("Stopped Hydra did not return to idle"); quit(1); return
		board.free()
	print("Hydra sprite resources valid; native mode verifies both lateral directions, all walk frames and idle recovery")
	quit(0)

