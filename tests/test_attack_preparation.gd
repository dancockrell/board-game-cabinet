extends SceneTree
const Session=preload("res://games/olympus_arena/session.gd")
const Board=preload("res://presentation/olympus_arena_board.gd")
const Strike=preload("res://themes/hoplite_thrust_clip.tres")
var failures:=0
var checks:=0
func check(ok:bool,label:String):
	checks+=1
	if not ok: failures+=1; push_error(label)
func fixture():
	var game=Session.new()
	game.deploy(0,Vector2(0,2))
	var unit=game._state.units[0]
	unit.x=0.0
	unit.cooldown=.5
	var tower=game._state.towers[3]
	tower.x=.5
	tower.z=2.0
	game._state.units=[unit]
	game._state.towers=[tower]
	game._state.events=[]
	return game
func _initialize(): run.call_deferred()
func run():
	var invalid=Strike.duplicate()
	invalid.strike_time=-.1
	check(not invalid.validation_error().is_empty(),"Negative strike time rejected")
	invalid.strike_time=99.0
	check(not invalid.validation_error().is_empty(),"Strike beyond action rejected")
	invalid.strike_time=.2
	invalid.looping=true
	check(not invalid.validation_error().is_empty(),"Looping locomotion cannot declare a strike")
	var game=fixture()
	var board=Board.new()
	root.add_child(board)
	board.show_state(game.snapshot(),0.0)
	var unit=game._state.units[0]
	var tower=game._state.towers[0]
	var actor=board._tokens[unit.id].get_node("Figure/PixelActor")
	var hp=float(tower.hp)
	var hit=false
	var seen:={}
	for tick in 8:
		game._state.elapsed+=.1
		game._step_unit(unit)
		var snapshot=game.snapshot()
		var before=snapshot.duplicate(true)
		board.show_state(snapshot,0.0)
		check(snapshot==before,"Presentation leaves authoritative intent/state untouched")
		if tower.hp<hp:
			hit=true
			check(not actor.awaiting_strike and actor.clip==Strike,"Authoritative hit commits prepared action")
			check(is_equal_approx(actor._reaction_elapsed,Strike.strike_time) and actor._shown==9,"Hit selects exact authored contact frame despite float32 duration sums")
			check(is_equal_approx(hp-tower.hp,unit.damage),"Preparation neither delays nor multiplies rules damage")
			break
		check(actor.awaiting_strike,"In-range target prepares before hit")
		check(tower.hp==hp,"Anticipation never applies damage")
		for frame in 6:
			seen[actor._shown]=true
			var elapsed=actor._reaction_elapsed
			board.show_state(snapshot,0.0)
			check(actor._reaction_elapsed==elapsed,"Pause retains exact anticipation phase")
			board.show_state(snapshot,1.0/60.0)
	check(hit and seen.size()>=6,"Real cooldown produces multiple preparation drawings then a hit")
	var snapshot=game.snapshot()
	board.show_state(snapshot,.01)
	check(actor._reaction_elapsed>Strike.strike_time,"Repeated hit snapshot does not restart release")
	board.show_state(snapshot,.6)
	check(actor._reaction_elapsed<0 and not actor.awaiting_strike,"Committed attack returns to rest")
	board.free()
	game=fixture()
	board=Board.new()
	root.add_child(board)
	unit=game._state.units[0]
	game._step_unit(unit)
	board.show_state(game.snapshot(),0.0)
	actor=board._tokens[unit.id].get_node("Figure/PixelActor")
	check(actor.awaiting_strike,"Second fixture prepares")
	board.show_state(game.snapshot(),2.0)
	check(actor.awaiting_strike and actor._reaction_elapsed<Strike.strike_time,"Slow or stale snapshot cannot invent a strike")
	game._state.towers[0].x=-4.0
	game._step_unit(unit)
	check(not unit.has("attack_target"),"Rules clear intent when target leaves range")
	board.show_state(game.snapshot(),.01)
	check(not actor.awaiting_strike,"Lost target cancels preparation into locomotion")
	check(actor.clip==Board.WEST_WALK,"Lost target immediately turns locomotion toward authoritative movement")
	board.free()
	# The longer bow draw must still release on the rules hit, not at clip start.
	game=fixture()
	unit=game._state.units[0]
	unit.kind="atalanta"
	tower=game._state.towers[0]
	tower.x=0.0
	tower.z=1.5
	board=Board.new()
	root.add_child(board)
	board.show_state(game.snapshot(),0.0)
	actor=board._tokens[unit.id].get_node("Figure/PixelActor")
	var bow=Board.ATALANTA_ATTACK.north
	hp=float(tower.hp)
	hit=false
	seen.clear()
	for tick in 8:
		game._state.elapsed+=.1
		game._step_unit(unit)
		snapshot=game.snapshot()
		board.show_state(snapshot,0.0)
		if tower.hp<hp:
			hit=true
			check(actor.clip==bow and not actor.awaiting_strike,"North bow commits on actual hit")
			check(is_equal_approx(actor._reaction_elapsed,bow.strike_time),"Extended bow sequence releases at its authored marker")
			check(actor._shown==bow.frame_at(bow.strike_time),"Hit displays release drawing rather than raising pose")
			check(is_equal_approx(hp-tower.hp,unit.damage),"Longer bow drawing does not change damage")
			break
		for frame in 6:
			if actor.awaiting_strike: seen[actor._shown]=true
			board.show_state(snapshot,1.0/60.0)
	check(hit and seen.size()>=2,"North bow shows distinct anticipation poses before release")
	board.free()
	print("Attack preparation: %s checks, %s failures"%[checks,failures])
	quit(1 if failures else 0)

