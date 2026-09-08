extends SceneTree
## Exercises event-driven attacks through the real board, including snapshot reuse.
const Board = preload("res://presentation/olympus_arena_board.gd")
var checks := 0
var failures := 0
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)
func _initialize(): run.call_deferred()
func run():
	if DisplayServer.get_name() == "headless":
		push_error("Attack sequence integration requires native rendering")
		quit(1)
		return
	var board = Board.new()
	root.add_child(board)
	var sequence := 0
	for entry in [{"kind":"atalanta","facing":"north","axis":Vector2.UP}, {"kind":"atalanta","facing":"south","axis":Vector2.DOWN}, {"kind":"harpies","facing":"south","axis":Vector2.DOWN}]:
		sequence += 1
		var state = {"units":[{"id":sequence,"kind":entry.kind,"side":0,"x":0.0,"z":2.0,"hp":100.0,"max_hp":100.0}],"towers":[],"elapsed":float(sequence*10),"events":[]}
		board.show_state(state, 0.0)
		var token = board._tokens[sequence]
		var actor = token.get_node("Figure/PixelActor")
		var event = {"id":sequence*2,"kind":"hit","source_id":sequence,"source_type":"unit","source_kind":entry.kind,"source_x":0.0,"source_z":2.0,"x":entry.axis.x,"z":2.0+entry.axis.y,"side":0,"damage":1.0}
		state.events = [event]
		board.show_state(state, 0.0)
		var action = Board.ATALANTA_ATTACK[entry.facing] if entry.kind == "atalanta" else Board.HARPIES_ATTACK[entry.facing]
		check(actor.clip == action and actor._shown == 0, "%s begins first attack pose" % entry)
		var snapshot = state.duplicate(true)
		var seen := {}
		var total := 0.0
		for duration in action.durations: total += duration
		check(total < 1.0, "Full attack can recover before next authoritative strike")
		for frame in ceili(total*60.0)+2:
			if actor.clip == action:
				seen[actor._shown] = true
				var source = action.atlas if action.frame_atlases.is_empty() else action.frame_atlases[actor._shown]
				check(actor.texture.atlas == source, "Board displays actual authored source")
			var before = actor._reaction_elapsed
			board.show_state(state, 0.0)
			check(actor._reaction_elapsed == before, "Paused repeated hit snapshot neither restarts nor advances attack")
			board.show_state(state, 1.0/60.0)
		check(seen.size() == action.regions.size(), "Every attack pose reached through board playback")
		check(actor.clip != action and actor._reaction_elapsed < 0, "Full sequence recovers after repeated event snapshots")
		check(state == snapshot and token.position == Vector3(0,.12,2), "Animation does not mutate snapshot or authoritative position")
		state.events = [event.duplicate(true)]
		state.events[0].id = sequence*2+1
		board.show_state(state, 0.0)
		check(actor.clip == action and actor._shown == 0, "A genuinely new strike starts a new sequence")
	board.free()
	print("Arena expanded attack integration: %s checks, %s failures" % [checks,failures])
	quit(1 if failures else 0)

