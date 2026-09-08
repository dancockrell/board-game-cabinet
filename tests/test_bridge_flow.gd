extends SceneTree
const Session=preload("res://games/olympus_arena/session.gd")
func _initialize():
	var failures=0
	for side in 2:
		for lane in [-2.7,2.7]:
			var game=Session.new()
			game.bot_enabled=false
			game._deploy(side,0,Vector2(lane,1.3 if side==0 else -1.3))
			var ids=[]
			for unit in game._state.units: ids.append(unit.id)
			var crossed={}
			var safe=true
			for tick in 120:
				game.tick()
				for unit in game._state.units:
					if absf(unit.z)<Session.RIVER_BANK and absf(absf(unit.x)-2.7)>Session.BRIDGE_HALF_WIDTH+.00001: safe=false
					if ids.has(unit.id) and (unit.z<-.85 if side==0 else unit.z>.85): crossed[unit.id]=true
			if crossed.size()!=3:
				failures+=1
				push_error("Whole formation must cross: side %s lane %s crossed %s/3"%[side,lane,crossed.size()])
			if not safe:
				failures+=1
				push_error("Formation left legal bridge deck")
	print("Bridge flow: four formations, every member crosses, water boundary; failures: ",failures)
	quit(1 if failures else 0)
