extends SceneTree
const Session = preload("res://games/ninth_gate/session.gd")
var checks: int = 0

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		push_error(message)
		quit(1)
		assert(condition, message)

func piece(id: String, side: String, x: int, y: int, role: String = "spear") -> Dictionary:
	return {"id":id,"side":side,"x":x,"y":y,"role":role,"hp":5,"max_hp":5,"morale":3}

func order(id: String, kind: String, x: int, y: int) -> Dictionary:
	return {"unit_id":id,"type":kind,"x":x,"y":y}

func canonical(state: Dictionary) -> Dictionary:
	var copy: Dictionary = state.duplicate(true)
	copy.erase("revision")
	return copy

func _init() -> void:
	var s = Session.new()
	check(s.snapshot().units.size() == 12, "Twelve initial units")
	var snap: Dictionary = s.snapshot()
	snap.units.clear()
	check(s.snapshot().units.size() == 12, "Snapshot cannot mutate session")
	check(s.view_for("heaven").units.size() == 6, "Initial enemy army hidden")
	check(not s.view_for("heaven").has("rng"), "RNG state hidden")
	var before: Dictionary = s.snapshot()
	check(not s.resolve_round([order("hell0","hold",9,1)]).ok, "Cannot command enemy")
	check(s.snapshot() == before, "Bad command is atomic")
	check(not s.resolve_round([], before.revision - 1).ok, "Stale revision rejected")
	check(s.snapshot() == before, "Stale request is atomic")
	check(not s.resolve_round([order("heaven0","move",5,2)]).ok, "River/teleport rejected")
	var hold: Dictionary = order("heaven0","hold",2,1)
	check(not s.resolve_round([hold,hold]).ok, "Duplicate units rejected")
	check(s.resolve_round([],before.revision).ok, "Empty orders resolve holds")
	check(s.undo(), "Round undo works")
	check(canonical(s.snapshot()) == canonical(before), "Undo restores all state including RNG")
	check(s.snapshot().revision > before.revision, "Undo revision is monotonic")
	# Fixture injection is confined to the rules tests.
	s._state.units = [piece("h","heaven",3,2),piece("i","hell",7,2)]
	check(s.view_for("heaven").units.size() == 1, "Enemy beyond sight hidden")
	s._state.units[1].x = 6
	check(s.view_for("heaven").units.size() == 2, "Enemy at sight boundary visible")
	s._state.units = [piece("a","heaven",3,2),piece("b","heaven",4,3),piece("i","hell",9,7)]
	s._apply([order("a","move",4,2),order("b","move",4,2)])
	check(s._unit(s._state,"a").x == 3 and s._unit(s._state,"b").y == 3,"Conflicting destinations block both")
	s._state.units = [piece("a","heaven",3,2),piece("b","hell",4,2)]
	s._apply([order("a","move",4,2),order("b","move",3,2)])
	check(s._unit(s._state,"a").x == 3 and s._unit(s._state,"b").x == 4,"Opposing swaps blocked")
	s._state.units = [piece("a","heaven",3,2),piece("b","hell",4,2)]
	s._state.units[0].hp = 1
	s._state.units[1].hp = 1
	s._apply([order("a","attack",4,2),order("b","attack",3,2)])
	check(s._state.units.is_empty(), "Fatal attackers still deal simultaneous damage")
	check(s._state.phase == "finished", "Annihilation ends battle")
	s.new_game(42)
	var other = Session.new()
	other.new_game(42)
	for round_index in 12:
		check(s.resolve_round([]).ok and other.resolve_round([]).ok, "Round resolves")
		check(canonical(s.snapshot()) == canonical(other.snapshot()), "Seeded bot and combat deterministic")
	check(s.snapshot().phase == "finished" and s.snapshot().round == 12,"Twelve rounds ends match")
	check(not s.resolve_round([]).ok, "Finished match rejects commands")
	var saved: Dictionary = s.save_data()
	var loaded = Session.new()
	check(loaded.load_data(JSON.parse_string(JSON.stringify(saved))).ok,"Save round-trips through JSON")
	check(canonical(loaded.snapshot()) == canonical(s.snapshot()),"Replay restore identical")
	var loaded_before: Dictionary = loaded.snapshot()
	saved.orders.append([])
	check(not loaded.load_data(saved).ok,"Overlength save rejected")
	check(loaded.snapshot() == loaded_before,"Failed load atomic")
	# Hidden enemy relocation cannot affect bot decisions from identical observations.
	s.new_game()
	var bot_before: Array = s._bot(s.view_for("hell"))
	s._state.units[0].x = 0
	check(s._bot(s.view_for("hell")) == bot_before,"Bot cannot use unseen enemy location")
	s._apply([order("hell0","rally",9,1)])
	check(not str(s.view_for("heaven").log).contains("hell0"),"Hidden enemy rally absent from player reports")
	check(str(s.view_for("hell").log).contains("hell0 rallied"),"Own rally reported")
	check(not s.view_for("heaven").has("reports"),"Opposing reports not exposed")
	s.new_game()
	s._state.units = [piece("a","heaven",4,1),piece("b","hell",9,7)]
	s._apply([order("a","move",5,1)])
	check(s._state.sites[0].owner == "heaven" and s._state.score.heaven == 1,"Crossing captured and scores")
	s._apply([order("a","move",6,1)])
	check(s._state.score.heaven == 2,"Empty owned crossing continues scoring")
	s._state.units = [piece("a","heaven",3,2),piece("b","hell",4,2)]
	s._apply([order("a","attack",4,2),order("b","move",4,3)])
	check(s._unit(s._state,"b").hp == 5,"Attack misses enemy that moved away")
	check(str(s.view_for("heaven").log).contains("no enemy"),"Miss explained to attacker")
	# Real combat consumes identical dice even if the UI submits its orders reversed.
	s.new_game(91)
	other.new_game(91)
	var combat_units: Array = [piece("a","heaven",3,2),piece("b","heaven",3,3),piece("x","hell",4,2),piece("y","hell",4,3)]
	s._state.units = combat_units.duplicate(true)
	other._state.units = combat_units.duplicate(true)
	check(s.resolve_round([order("a","attack",4,2),order("b","attack",4,3)]).ok,"Combat orders valid")
	check(other.resolve_round([order("b","attack",4,3),order("a","attack",4,2)]).ok,"Reversed combat orders valid")
	check(canonical(s.snapshot()) == canonical(other.snapshot()),"Combat deterministic independent of selection order")
	check(s.snapshot().rng != 91,"Combat consumed random state")
	# Play real nonempty orders from the initial position, then persist as JSON.
	s.new_game()
	for index in 12:
		if s.snapshot().phase == "finished": break
		var planned: Array = []
		for unit in s.view_for("heaven").units:
			if unit.side != "heaven" or planned.size() >= 3: continue
			var chosen: Dictionary = {}
			for legal in s.legal_orders(unit.id):
				if legal.type == "rally": chosen = legal
				if legal.type == "move" and legal.x > unit.x: chosen = legal
				if legal.type == "attack":
					chosen = legal
					break
			if not chosen.is_empty(): planned.append(chosen)
		check(s.resolve_round(planned).ok,"Nonempty battle orders resolve")
	var json_save: Dictionary = JSON.parse_string(JSON.stringify(s.save_data()))
	check(loaded.load_data(json_save).ok,"Nonempty full battle JSON replay loads")
	check(canonical(loaded.snapshot()) == canonical(s.snapshot()),"Full battle JSON replay identical")
	loaded_before = loaded.snapshot()
	json_save.orders[0][0].x = 3.5
	check(not loaded.load_data(json_save).ok,"Fractional JSON coordinate rejected")
	check(loaded.snapshot() == loaded_before,"Fractional save load atomic")
	print("Ninth Gate: %d checks passed" % checks)
	quit(0)
