extends SceneTree
const Arena=preload("res://games/olympus_arena/session.gd")
var checks:=0
var failures:=0
func check(value:bool,message:String):
	checks+=1
	if not value: failures+=1; push_error(message)
func pair(point:Vector2):
	var game=Arena.new()
	game.bot_enabled=false
	game._hands[0][0]="harpies"
	check(game.deploy(0,point).ok,"Harpy fixture legal deployment")
	for tower in game._state.towers: tower.cooldown=1000.0
	return game
func gap(a:Dictionary,b:Dictionary)->float:
	return Vector2(a.x,a.z).distance_to(Vector2(b.x,b.z))
func _init():
	var game=pair(Vector2(2.7,1.3))
	check(gap(game._state.units[0],game._state.units[1])>=1.04,"Fresh pair has readable body separation")
	var edge=pair(Vector2(4.6,.8))
	check(gap(edge._state.units[0],edge._state.units[1])>=1.04,"Edge shifts full airborne formation inward")
	for unit in edge._state.units: check(unit.x<=4.6 and unit.x>=-4.6 and unit.z>=.8,"Legal edge bounds")
	var over_water=pair(Vector2(0,1.3))
	var replay=pair(Vector2(0,1.3))
	var crossed:=false
	for tick in 24:
		over_water.tick()
		replay.tick()
		check(over_water.snapshot()==replay.snapshot(),"Deterministic airborne spacing")
		if over_water._state.units.size()==2:
			var a=over_water._state.units[0]
			var b=over_water._state.units[1]
			check(gap(a,b)>.90,"Pair retains separation during traversal")
			if a.z<0 and absf(absf(a.x)-2.7)>Arena.BRIDGE_HALF_WIDTH: crossed=true
	check(crossed,"Flyers still cross open water without bridge routing")
	var a:Dictionary=game._state.units[0]
	var b:Dictionary=game._state.units[1]
	a.x=0.0; a.z=3.0
	b.x=.5; b.z=3.0; b.side=1
	game._separate_units()
	check(is_equal_approx(gap(a,b),.5),"Opposing flyers are not forced outside melee range")
	a.cooldown=0.0
	var before=float(b.hp)
	game._step_unit(a)
	check(float(b.hp)<before,"Opposing flyer remains attackable at real coordinates")
	b.side=0; a.x=0.0; b.x=0.0
	for tick in 20: game._separate_units()
	check(gap(a,b)>=1.04,"Coincident allies resolve to airborne spacing")
	print("Harpy formation: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
