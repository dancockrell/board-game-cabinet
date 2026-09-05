extends SceneTree
const Session = preload("res://games/ninth_gate/session.gd")
var checks: int = 0
var failures: int = 0

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		push_error(message)
		failures += 1

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
	for round_index in Session.LIMIT:
		if s.snapshot().phase == "finished": break
		check(s.resolve_round([]).ok and other.resolve_round([]).ok, "Round resolves")
		check(canonical(s.snapshot()) == canonical(other.snapshot()), "Seeded bot and combat deterministic")
	check(s.snapshot().phase == "finished" and s.snapshot().round <= 8,"Match ends by eight rounds")
	check(not s.resolve_round([]).ok, "Finished match rejects commands")
	var saved: Dictionary = s.save_data()
	var loaded = Session.new()
	check(loaded.load_data(JSON.parse_string(JSON.stringify(saved))).ok,"Save round-trips through JSON")
	check(canonical(loaded.snapshot()) == canonical(s.snapshot()),"Replay restore identical")
	var loaded_before: Dictionary = loaded.snapshot()
	while saved.orders.size() <= Session.LIMIT: saved.orders.append([])
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
	check(s._state.score.heaven == 1 and s._state.sites[0].owner == "","Empty crossing stops scoring and clears ownership")
	s._state.units = [piece("a","heaven",3,2),piece("b","hell",4,2)]
	s._apply([order("a","attack",4,2),order("b","move",4,3)])
	check(s._unit(s._state,"b").hp == 5,"Attack misses enemy that moved away")
	check(str(s.view_for("heaven").log).contains("no enemy"),"Miss explained to attacker")
	# Real combat consumes identical dice even if the UI submits its orders reversed.
	s.new_game(91)
	other.new_game(91)
	var combat_units: Array = [piece("a","heaven",3,2),piece("b","heaven",3,3),piece("x","hell",4,2),piece("y","hell",4,3)]
	combat_units[2].hp = 2
	combat_units[3].hp = 2
	s._state.units = combat_units.duplicate(true)
	other._state.units = combat_units.duplicate(true)
	s._state.sites = [{"x":4,"y":2,"owner":"hell"},{"x":4,"y":3,"owner":"hell"}]
	other._state.sites = s._state.sites.duplicate(true)
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
	# Rules-v2 movement, support, automatic combat, and scoring contracts.
	s.new_game()
	check(s.snapshot().round_limit == 8 and s.snapshot().target_score == 12,"Victory targets exposed to presentation")
	check(s.snapshot().units[0].display_name == "Dawn Wardens","Named formations available to UI")
	check(s.legal_orders("heaven0").has(order("heaven0","move",4,1)),"Two-step advance is legal")
	s._state.units = [piece("a","heaven",4,2),piece("b","hell",9,7)]
	check(not s.legal_orders("a").has(order("a","move",6,2)),"Cannot jump river in two steps")
	s._state.units = [piece("a","heaven",2,2),piece("block","heaven",3,2),piece("b","hell",9,7)]
	check(not s.legal_orders("a").has(order("a","move",4,2)),"Cannot jump occupied intermediate square")
	s._state.units = [piece("a","heaven",2,2,"archer"),piece("b","hell",4,3)]
	check(s.legal_orders("a").has(order("a","attack",4,3)),"Archer attacks at range three")
	s._apply([])
	check(s._unit(s._state,"b").hp < 5,"Uncommanded archer automatically attacks")
	s.new_game()
	s._state.units = [piece("a","heaven",2,2,"herald"),piece("ally","heaven",3,2),piece("b","hell",9,7)]
	s._state.units[1].hp = 1
	check(s.legal_orders("a").has(order("a","heal",3,2)),"Herald can mend injured adjacent ally")
	s._apply([order("a","heal",3,2)])
	check(s._unit(s._state,"ally").hp == 3,"Mend restores two health")
	s._state.units[0].hp = 2
	check(s.legal_orders("a").has(order("a","heal",2,2)),"Herald can mend itself")
	s.new_game()
	s._state.units = [piece("a","heaven",3,2),piece("b","hell",4,2)]
	s._apply([order("a","hold",3,2),order("b","hold",4,2)])
	check(s._unit(s._state,"a").hp == 5 and s._unit(s._state,"b").hp == 5,"Explicit brace suppresses automatic attack")
	s.new_game()
	s._state.units = [piece("a","heaven",5,1),piece("b","hell",9,7)]
	s._state.score.heaven = 11
	s._apply([])
	check(s._state.phase == "finished" and s._state.winner == "heaven","Twelve bridge points wins before round limit")
	s.new_game()
	var obsolete: Dictionary = s.save_data()
	obsolete.rules = 1
	before = s.snapshot()
	check(not s.load_data(obsolete).ok and s.snapshot() == before,"Old rules saves explicitly rejected atomically")
	var reserved: Array = []
	for bot_order in s._bot(s.view_for("hell")):
		if bot_order.type != "move": continue
		var cell: Vector2i = Vector2i(bot_order.x,bot_order.y)
		check(not reserved.has(cell),"Bot avoids duplicate move destinations")
		reserved.append(cell)
	# Exact damage modifiers are measured from matching dice, not lucky outcomes.
	var ordinary_damage: int = 0
	var protected_damage: int = 0
	for seed_value in 20:
		s.new_game(seed_value)
		other.new_game(seed_value)
		s._state.units = [piece("a","heaven",2,2),piece("b","hell",3,2)]
		other._state.units = [piece("a","heaven",2,2),piece("b","hell",3,2,"guard")]
		s._apply([order("a","attack",3,2),order("b","rally",3,2)])
		other._apply([order("a","attack",3,2),order("b","hold",3,2)])
		ordinary_damage += 5 - s._unit(s._state,"b").hp
		protected_damage += 5 - other._unit(other._state,"b").hp
	check(protected_damage < ordinary_damage,"Guard armor plus brace reduces damage over identical dice")
	s.new_game()
	s._state.units = [piece("a","heaven",4,1),piece("b","hell",5,1)]
	# Legal resolver cannot see hidden blockers in general; referee still rechecks paths.
	s._apply([order("a","move",6,1),order("b","hold",5,1)])
	check(s._unit(s._state,"a").x == 4,"Authoritative movement cannot jump a blocker at the intermediate bridge")
	s.new_game()
	s._state.units = [piece("a","heaven",5,1),piece("b","hell",5,6)]
	s._state.score = {"heaven":11,"hell":11}
	s._apply([])
	check(s._state.phase == "finished" and s._state.winner == "draw","Simultaneous target-score tie is a draw")
	s.new_game()
	s._state.units = [piece("a","heaven",0,0),piece("b","hell",11,7)]
	for round_index in Session.LIMIT: s._apply([])
	check(s._state.round == 8 and s._state.phase == "finished","Eight rounds ends even an uneventful battle")
	s.new_game()
	s._state.units = [piece("a","heaven",3,2),piece("b","hell",4,2)]
	before = s.snapshot()
	var forecast: String = s.preview_order(order("a","attack",4,2))
	check(forecast.contains("1-3 damage"),"Strike preview uses actual die bounds and possible Brace cover")
	check(s.snapshot() == before,"Preview consumes no random state and changes no authority")
	check(s.preview_order(order("a","attack",9,7)).contains("legal target"),"Preview rejects unobserved or illegal targets")
	print("Ninth Gate: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)
