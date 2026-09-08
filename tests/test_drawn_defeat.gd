extends SceneTree
const Board=preload("res://presentation/olympus_arena_board.gd")
var failures=0
func check(value,label):
	if not value: failures+=1; push_error(label)
func _initialize(): run.call_deferred()
func run():
	for kind in Board.DRAWN_DEFEATS:
		for direction in ["north","south"]:
			var board=Board.new()
			root.add_child(board)
			var state={"units":[{"id":7,"kind":kind,"side":0,"x":0.0,"z":2.0,"hp":100.0,"max_hp":100.0}],"towers":[],"events":[],"elapsed":1.0}
			board.show_state(state,0.0)
			board._face_pixel_unit(board._tokens[7],Vector2.UP if direction=="north" else Vector2.DOWN)
			var source=board._tokens[7].get_node("Figure/PixelActor")
			var location=source.global_position
			var ground = location - source.get_parent_node_3d().global_basis * Vector3(0, source.position.y, 0)
			state.units=[]
			state.elapsed=1.1
			var snapshot=state.duplicate(true)
			board.show_state(state,0.0)
			check(not board._tokens.has(7),"Removed unit immediately leaves board authority")
			check(board._departures.size()==1,"Exactly one departure created")
			var departure=board._departures[0]
			check(departure.drawn_actor!=null,"Character uses drawn defeat")
			var actor=departure.drawn_actor
			check(actor.clip==Board.DRAWN_DEFEATS[kind][direction],"Facing chooses matching defeat drawings")
			check(departure.global_position.is_equal_approx(location),"Defeat starts at original foot anchor")
			check(actor.scale.is_equal_approx(Vector3.ONE*actor.clip.draw_scale),"Defeat draw scale not multiplied by prior pose")
			var seen={}
			for frame in 45:
				seen[actor._shown]=true
				var elapsed=departure.elapsed
				board.show_state(state,0.0)
				check(departure.elapsed==elapsed,"Paused defeat holds time")
				board.show_state(state,1.0/60.0)
			check(departure.global_position.is_equal_approx(ground if kind=="harpies" else location),"Defeat settles at ground contact")
			check(seen.size()==8,"All eight authored defeat drawings play")
			check(state==snapshot and board._tokens.is_empty(),"Visual defeat cannot resurrect or mutate state")
			board.show_state(state,.1)
			check(board._departures.is_empty(),"Defeat lifetime remains bounded")
			board.free()
	print("Drawn defeat board integration: four characters, two facings, eight frames each, pause, placement, removal and lifetime; failures: ",failures)
	quit(1 if failures else 0)
