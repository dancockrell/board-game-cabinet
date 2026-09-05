extends RefCounted
## Authoritative, presentation-independent simultaneous-orders skirmish.
const WIDTH = 12
const HEIGHT = 8
const LIMIT = 8
const TARGET_SCORE = 12
var _state: Dictionary
var _undo: Array = []
var _revision: int = 0
var _history: Array = []

func _init() -> void:
	new_game()

func new_game(seed_value: int = 1824) -> void:
	_revision += 1
	_undo.clear()
	_history.clear()
	var terrain: Array = []
	for y in HEIGHT:
		for x in WIDTH:
			terrain.append("river" if x == 5 else "plain")
	for y in [1, 3, 6]: terrain[y * WIDTH + 5] = "bridge"
	for p in [Vector2i(3, 1), Vector2i(8, 1), Vector2i(3, 6), Vector2i(8, 6)]: terrain[p.y * WIDTH + p.x] = "wood"
	for p in [Vector2i(4, 3), Vector2i(7, 3), Vector2i(2, 4), Vector2i(9, 4)]: terrain[p.y * WIDTH + p.x] = "hill"
	var units: Array = []
	for side in ["heaven", "hell"]:
		for i in 6:
			var role: String = ["guard", "guard", "spear", "spear", "archer", "herald"][i]
			var names: Array = ["Dawn Wardens", "Gate Sentinels", "Sun Lances", "Oath Blades", "Starbow Choir", "Lightbearer"] if side == "heaven" else ["Ironbound", "Ash Wardens", "Ember Lances", "Rift Blades", "Cinder Bows", "Ashmender"]
			var descriptions: Dictionary = {"guard":"Armored defender: 1 extra cover.","spear":"Vanguard: +1 attack power in close combat.","archer":"Ranged formation: attacks up to 3 tiles away.","herald":"Support: mend an adjacent ally for 2 health."}
			units.append({"display_name":names[i], "description":descriptions[role], "id": side + str(i), "side": side, "role": role, "x": 2 if side == "heaven" else 9, "y": i + 1, "hp": 5, "max_hp": 5, "morale": 3})
	_state = {"revision": _revision, "round": 1, "round_limit": LIMIT, "target_score": TARGET_SCORE, "phase": "orders", "winner": "", "width": WIDTH, "height": HEIGHT, "terrain": terrain, "units": units, "sites": [{"x":5,"y":1,"owner":""},{"x":5,"y":3,"owner":""},{"x":5,"y":6,"owner":""}], "score": {"heaven":0,"hell":0}, "seed": seed_value, "rng": seed_value & 0x7fffffff, "log": ["Give 3 orders. Other units fight automatically. Occupy bridges to score; reach 12 points or lead after 8 rounds."]}
	_state.reports = {"heaven":[],"hell":[]}

func snapshot() -> Dictionary:
	return _state.duplicate(true)

func view_for(side: String) -> Dictionary:
	return _view(_state, side)

func _view(state: Dictionary, side: String) -> Dictionary:
	var result: Dictionary = state.duplicate(true)
	var visible: Array = []
	for unit in state.units:
		if unit.side != side: continue
		for y in HEIGHT:
			for x in WIDTH:
				var reach: int = 4 if state.terrain[unit.y * WIDTH + unit.x] == "hill" else 3
				if absi(x - unit.x) + absi(y - unit.y) <= reach and not visible.has(y * WIDTH + x): visible.append(y * WIDTH + x)
	result.units = []
	for unit in state.units:
		if unit.side == side or visible.has(unit.y * WIDTH + unit.x): result.units.append(unit.duplicate(true))
	result.visible_cells = visible
	# Combat reports and random state are referee information, not reconnaissance.
	result.erase("rng")
	result.erase("seed")
	result.log = state.reports.get(side, []).duplicate(true)
	result.log.append("Round %d. Heaven %d — Hell %d." % [state.round, state.score.heaven, state.score.hell])
	result.erase("reports")
	return result

func legal_orders(unit_id: String, side: String = "heaven") -> Array:
	if _state.phase != "orders": return []
	return _legal(_view(_state, side), unit_id, side)

func _legal(view: Dictionary, unit_id: String, side: String) -> Array:
	var unit: Dictionary = _unit(view, unit_id)
	if unit.is_empty() or unit.side != side: return []
	var orders: Array = [{"unit_id":unit_id,"type":"hold","x":unit.x,"y":unit.y}, {"unit_id":unit_id,"type":"rally","x":unit.x,"y":unit.y}]
	for cell in _reachable(view, unit):
		orders.append({"unit_id":unit_id,"type":"move","x":cell.x,"y":cell.y})
	for target in view.units:
		if target.side == side:
			if unit.role == "herald" and absi(unit.x - target.x) + absi(unit.y - target.y) <= 1 and target.hp < target.max_hp:
				orders.append({"unit_id":unit_id,"type":"heal","x":target.x,"y":target.y})
			continue
		var distance: int = absi(unit.x - target.x) + absi(unit.y - target.y)
		if distance <= (3 if unit.role == "archer" else 1): orders.append({"unit_id":unit_id,"type":"attack","x":target.x,"y":target.y})
	return orders

func _reachable(state: Dictionary, unit: Dictionary) -> Array:
	# Breadth-first reachability allows corners, never jumps a river or blocker.
	var found: Array = []
	var frontier: Array = [Vector2i(unit.x, unit.y)]
	var visited: Array = frontier.duplicate()
	for step in 2:
		var next: Array = []
		for origin in frontier:
			for delta in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var cell: Vector2i = origin + delta
				if cell.x < 0 or cell.x >= WIDTH or cell.y < 0 or cell.y >= HEIGHT or visited.has(cell): continue
				visited.append(cell)
				if state.terrain[cell.y * WIDTH + cell.x] == "river" or not _occupant(state, cell.x, cell.y).is_empty(): continue
				found.append(cell)
				next.append(cell)
		frontier = next
	return found

func _unit(state: Dictionary, id: String) -> Dictionary:
	for unit in state.units:
		if unit.id == id: return unit
	return {}

func _occupant(state: Dictionary, x: int, y: int) -> Dictionary:
	for unit in state.units:
		if unit.x == x and unit.y == y: return unit
	return {}

func _bot(view: Dictionary) -> Array:
	var candidates: Array = []
	for unit in view.units:
		if unit.side != "hell": continue
		for order in _legal(view, unit.id, "hell"):
			var value: int = -100
			if order.type == "heal":
				var patient: Dictionary = _occupant(view, order.x, order.y)
				value = 65 + (patient.max_hp - patient.hp) * 3
			elif order.type == "rally": value = 65 if unit.hp <= 2 else -100
			elif order.type == "move":
				var current: int = 99
				var nearest: int = 99
				for site in view.sites:
					if not _occupant(view, site.x, site.y).is_empty() and site.owner == "hell": continue
					current = mini(current, absi(unit.x - site.x) + absi(unit.y - site.y))
					nearest = mini(nearest, absi(order.x - site.x) + absi(order.y - site.y))
				var on_site: bool = false
				for site in view.sites:
					if unit.x == site.x and unit.y == site.y: on_site = true
				if not on_site and nearest < current: value = 50 + (current - nearest) * 4 + (30 if nearest == 0 else 0)
			# Attacks are automatic: spend scarce commands on positioning/recovery.
			if value > 0: candidates.append({"order":order,"value":value})
	candidates.sort_custom(func(a, b): return a.value > b.value if a.value != b.value else str(a.order) < str(b.order))
	var orders: Array = []
	var commanded: Array = []
	var destinations: Array = []
	for candidate in candidates:
		if orders.size() == 3: break
		var selected: Dictionary = candidate.order
		var cell: Vector2i = Vector2i(selected.x, selected.y)
		if commanded.has(selected.unit_id) or (selected.type == "move" and destinations.has(cell)): continue
		orders.append(selected)
		commanded.append(selected.unit_id)
		if selected.type == "move": destinations.append(cell)
	return orders

func resolve_round(player_orders: Array, expected_revision: int = -1) -> Dictionary:
	if expected_revision != -1 and expected_revision != _revision: return {"ok":false,"error":"The position changed; issue orders again."}
	if _state.phase != "orders": return {"ok":false,"error":"The battle has ended."}
	if player_orders.size() > 3: return {"ok":false,"error":"Issue at most three orders."}
	var seen: Array = []
	for order in player_orders:
		if not order is Dictionary or not order.has_all(["unit_id","type","x","y"]): return {"ok":false,"error":"Malformed order."}
		if not order.unit_id is String or seen.has(order.unit_id) or not legal_orders(order.unit_id, "heaven").has(order): return {"ok":false,"error":"An order is illegal or repeats a unit."}
		seen.append(order.unit_id)
	var orders: Array = player_orders.duplicate(true)
	orders.append_array(_bot(_view(_state, "hell")))
	# A player's click order must not change which combat receives which die.
	orders.sort_custom(func(a, b): return a.unit_id < b.unit_id)
	_undo.append(snapshot())
	_history.append(player_orders.duplicate(true))
	_apply(orders)
	_revision += 1
	_state.revision = _revision
	return {"ok":true,"revision":_revision}

func _roll() -> int:
	_state.rng = (int(_state.rng) * 1103515245 + 12345) & 0x7fffffff
	return 1 + (int(_state.rng) >> 16) % 6

func _apply(orders: Array) -> void:
	var before: Dictionary = snapshot()
	var log_lines: Array = []
	_state.reports = {"heaven":[],"hell":[]}
	var destinations: Dictionary = {}
	for order in orders:
		if order.type != "move": continue
		var key: int = order.y * WIDTH + order.x
		destinations[key] = int(destinations.get(key, 0)) + 1
	for order in orders:
		var unit: Dictionary = _unit(_state, order.unit_id)
		if order.type == "move":
			if destinations[order.y * WIDTH + order.x] == 1 and _reachable(before, _unit(before, order.unit_id)).has(Vector2i(order.x, order.y)):
				unit.x = order.x
				unit.y = order.y
				_state.reports[unit.side].append("%s advanced to %s%d." % [unit.id, char(65 + unit.x), unit.y + 1])
			else:
				log_lines.append("%s movement blocked." % unit.id)
				_state.reports[unit.side].append("%s movement blocked." % unit.id)
		elif order.type == "rally":
			unit.morale = mini(3, unit.morale + (2 if unit.side == "heaven" else 1))
			unit.hp = mini(unit.max_hp, unit.hp + 1)
			_state.reports[unit.side].append("%s rallied: %d health, %d morale." % [unit.id,unit.hp,unit.morale])
	# Healing selects a square just like focus fire; a departing ally may evade it.
	for order in orders:
		if order.type != "heal": continue
		var healer: Dictionary = _unit(_state, order.unit_id)
		var patient: Dictionary = _occupant(_state, order.x, order.y)
		if not patient.is_empty() and patient.side == healer.side and absi(healer.x - patient.x) + absi(healer.y - patient.y) <= 1:
			patient.hp = mini(patient.max_hp, patient.hp + 2)
			_state.reports[healer.side].append("%s mended %s for up to 2 health." % [healer.id, patient.id])
		else: _state.reports[healer.side].append("%s mend missed: ally moved away." % healer.id)
	var combat_orders: Array = orders.duplicate(true)
	var commanded: Array = []
	var braced: Array = []
	for order in orders:
		commanded.append(order.unit_id)
		if order.type == "hold": braced.append(order.unit_id)
	for unit in _state.units:
		if commanded.has(unit.id): continue
		var targets: Array = []
		for enemy in _view(_state, unit.side).units:
			if enemy.side == unit.side: continue
			var distance: int = absi(unit.x - enemy.x) + absi(unit.y - enemy.y)
			if distance <= (3 if unit.role == "archer" else 1): targets.append({"unit":enemy,"distance":distance})
		targets.sort_custom(func(a,b): return a.distance < b.distance if a.distance != b.distance else a.unit.id < b.unit.id)
		if not targets.is_empty():
			var target: Dictionary = targets[0].unit
			combat_orders.append({"unit_id":unit.id,"type":"attack","x":target.x,"y":target.y})
	combat_orders.sort_custom(func(a,b): return a.unit_id < b.unit_id)
	var damage: Dictionary = {}
	for order in combat_orders:
		if order.type != "attack": continue
		var attacker: Dictionary = _unit(_state, order.unit_id)
		var target: Dictionary = _occupant(_state, order.x, order.y)
		if target.is_empty() or target.side == attacker.side:
			_state.reports[attacker.side].append("%s attack found no enemy at the ordered position." % attacker.id)
			continue
		if absi(attacker.x - target.x) + absi(attacker.y - target.y) > (3 if attacker.role == "archer" else 1):
			_state.reports[attacker.side].append("%s attack fell out of range." % attacker.id)
			continue
		var cover: int = 1 if _state.terrain[target.y * WIDTH + target.x] in ["wood","hill"] else 0
		if target.role == "guard": cover += 1
		if braced.has(target.id): cover += 1
		var attack: int = (2 if attacker.role == "spear" else 1) + (1 if attacker.side == "hell" else 0)
		var loss: int = maxi(0, ( _roll() + attack + (1 if attacker.morale >= 2 else 0) - cover) / 3)
		damage[target.id] = int(damage.get(target.id, 0)) + loss
		log_lines.append("%s attacked %s for %d." % [attacker.id,target.id,loss])
		var report: String = "%s attacked %s for %d." % [attacker.id,target.id,loss]
		_state.reports[attacker.side].append(report)
		_state.reports[target.side].append(report)
	for id in damage:
		var target: Dictionary = _unit(_state, id)
		target.hp -= damage[id]
		if damage[id] > 0: target.morale = maxi(0, target.morale - 1)
		if target.hp <= 0: _state.reports[target.side].append("%s was lost." % target.id)
	_state.units = _state.units.filter(func(unit): return unit.hp > 0)
	for site in _state.sites:
		var occupant: Dictionary = _occupant(_state, site.x, site.y)
		if not occupant.is_empty() and site.owner != occupant.side:
			site.owner = occupant.side
			for side in ["heaven","hell"]:
				_state.reports[side].append("%s captured the crossing at F%d." % [site.owner.capitalize(),site.y + 1])
		if occupant.is_empty(): site.owner = ""
		else: _state.score[site.owner] += 1
	var heaven_count: int = 0
	var hell_count: int = 0
	for unit in _state.units:
		if unit.side == "heaven": heaven_count += 1
		else: hell_count += 1
	if heaven_count == 0 or hell_count == 0 or _state.round >= LIMIT or _state.score.heaven >= TARGET_SCORE or _state.score.hell >= TARGET_SCORE:
		_state.phase = "finished"
		if heaven_count == 0 and hell_count > 0: _state.winner = "hell"
		elif hell_count == 0 and heaven_count > 0: _state.winner = "heaven"
		elif _state.score.heaven == _state.score.hell: _state.winner = "draw"
		else: _state.winner = "heaven" if _state.score.heaven > _state.score.hell else "hell"
	else: _state.round += 1
	_state.log = log_lines

func undo() -> bool:
	if _undo.is_empty(): return false
	_state = _undo.pop_back()
	_history.pop_back()
	_revision += 1
	_state.revision = _revision
	return true

func save_data() -> Dictionary:
	return {"schema":1,"game":"ninth_gate","rules":2,"seed":_state.seed,"orders":_history.duplicate(true)}

func load_data(data: Dictionary) -> Dictionary:
	if data.get("schema") != 1 or data.get("game") != "ninth_gate" or data.get("rules") != 2:
		return {"ok":false,"error":"This save uses older or unsupported rules. Start a new rules-v2 battle."}
	if not data.get("orders") is Array or data.orders.size() > LIMIT or not (data.get("seed") is int or data.get("seed") is float):
		return {"ok":false,"error":"Malformed Ninth Gate save."}
	if float(data.seed) != float(int(data.seed)) or absf(float(data.seed)) > 2147483647:
		return {"ok":false,"error":"Invalid seed."}
	var candidate = get_script().new()
	candidate.new_game(int(data.seed))
	for round_orders in data.orders:
		if not round_orders is Array: return {"ok":false,"error":"Malformed saved orders."}
		# Godot JSON decodes every number as float, but dictionary equality is
		# type-sensitive. Normalize only validated integral board coordinates.
		var normalized: Array = []
		for order in round_orders:
			if not order is Dictionary: return {"ok":false,"error":"Malformed saved order."}
			var copy: Dictionary = order.duplicate(true)
			for axis in ["x","y"]:
				var value = copy.get(axis)
				if not (value is int or value is float): return {"ok":false,"error":"Invalid saved coordinate."}
				if not is_finite(float(value)) or float(value) < 0 or float(value) >= (WIDTH if axis == "x" else HEIGHT):
					return {"ok":false,"error":"Invalid saved coordinate."}
				if float(value) != float(int(value)): return {"ok":false,"error":"Fractional saved coordinate."}
				copy[axis] = int(value)
			normalized.append(copy)
		var result: Dictionary = candidate.resolve_round(normalized)
		if not result.ok: return {"ok":false,"error":"Invalid saved order sequence."}
	_state = candidate.snapshot()
	_undo = candidate._undo.duplicate(true)
	_history = candidate._history.duplicate(true)
	_revision += 1
	_state.revision = _revision
	return {"ok":true,"revision":_revision}
