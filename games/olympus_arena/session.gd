class_name OlympusArenaSession
extends RefCounted

const STEP := 0.1
const MATCH_SECONDS := 180.0
const MAX_UNITS := 64
const DECK := ["hoplites", "atalanta", "minotaur", "medusa", "heracles", "hydra", "harpies", "thunderbolt"]
var bot_enabled := true
var _rng := RandomNumberGenerator.new()
var _state: Dictionary
var _queues: Array
var _hands: Array
var _next_id := 0
var _event_id := 0
var _bot_wait := 1.8

func _init() -> void:
	new_game()

func catalog() -> Dictionary:
	return {
		"hoplites": {"name":"Hoplites", "cost":3, "description":"Three shield soldiers. Strong together.", "hp":145.0, "damage":24.0, "speed":0.8, "range":0.65, "count":3},
		"atalanta": {"name":"Atalanta", "cost":3, "description":"Quick archer. Hits ground and air.", "hp":175.0, "damage":37.0, "speed":1.05, "range":2.65, "count":1},
		"minotaur": {"name":"Minotaur", "cost":5, "description":"Heavy charger. Heads straight for towers.", "hp":720.0, "damage":86.0, "speed":0.78, "range":0.8, "count":1},
		"medusa": {"name":"Medusa", "cost":4, "description":"Ranged gaze slows enemy movement.", "hp":260.0, "damage":29.0, "speed":0.72, "range":2.35, "count":1},
		"heracles": {"name":"Heracles", "cost":5, "description":"His club hits nearby ground enemies.", "hp":640.0, "damage":64.0, "speed":0.75, "range":0.8, "count":1},
		"hydra": {"name":"Hydra", "cost":6, "description":"An enduring beast that can bite flying foes.", "hp":1080.0, "damage":58.0, "speed":0.52, "range":1.15, "count":1},
		"harpies": {"name":"Harpies", "cost":3, "description":"Two flying attackers. Evade ground fighters.", "hp":120.0, "damage":27.0, "speed":1.35, "range":0.8, "count":2},
		"thunderbolt": {"name":"Thunderbolt", "cost":2, "description":"Strike anywhere: 130 unit damage, 65 tower damage.", "count":0}
	}

func new_game(seed_value: int = 42) -> void:
	_rng.seed = seed_value
	_next_id = 0
	_event_id = 0
	_bot_wait = 1.8
	_hands = [DECK.slice(0, 4), DECK.slice(0, 4)]
	_queues = [DECK.slice(4), DECK.slice(4)]
	_state = {"elapsed":0.0, "time_remaining":MATCH_SECONDS, "overtime":false, "crowns":[0, 0], "phase":"playing", "winner":-1, "revision":0, "energy":[5.0, 5.0], "units":[], "towers":[], "events":[]}
	for side in range(2):
		var sign_z := 1.0 if side == 0 else -1.0
		for lane in [-1, 1]:
			_state.towers.append({"id":"%s_%s" % [side, lane], "side":side, "kind":"tower", "x":lane * 2.7, "z":sign_z * 5.0, "hp":1100.0, "max_hp":1100.0, "cooldown":0.0})
		_state.towers.append({"id":"%s_temple" % side, "side":side, "kind":"temple", "x":0.0, "z":sign_z * 7.0, "hp":1800.0, "max_hp":1800.0, "cooldown":0.0})

func snapshot() -> Dictionary:
	var copy := _state.duplicate(true)
	copy["hand"] = _hands[0].duplicate()
	copy["next_card"] = _queues[0][0]
	return copy

func deploy(slot: int, position: Vector2, expected_revision: int = -1) -> Dictionary:
	if expected_revision >= 0 and expected_revision != _state.revision:
		return {"ok":false, "error":"The arena changed. Try again."}
	return _deploy(0, slot, position)

func preview_deploy(slot: int, position: Vector2) -> Dictionary:
	return _validate_deploy(0, slot, position)

func _validate_deploy(side: int, slot: int, position: Vector2) -> Dictionary:
	if _state.phase != "playing":
		return {"ok":false, "error":"This battle is finished."}
	if slot < 0 or slot >= 4 or not is_finite(position.x) or not is_finite(position.y):
		return {"ok":false, "error":"Choose a card and a valid position."}
	var kind: String = _hands[side][slot]
	var card: Dictionary = catalog()[kind]
	if absf(position.x) > 4.6 or absf(position.y) > 7.8:
		return {"ok":false, "error":"Choose a position inside the arena."}
	if kind != "thunderbolt" and ((side == 0 and position.y < 0.8) or (side == 1 and position.y > -0.8)):
		return {"ok":false, "error":"Deploy troops on your side of the river."}
	if float(_state.energy[side]) < int(card.cost):
		return {"ok":false, "error":"Not enough elixir yet."}
	if _state.units.size() + int(card.count) > MAX_UNITS:
		return {"ok":false, "error":"The arena is full. Wait for space."}
	return {"ok":true, "error":""}

func _deploy(side: int, slot: int, position: Vector2) -> Dictionary:
	var validity := _validate_deploy(side, slot, position)
	if not validity.ok:
		return validity
	var kind: String = _hands[side][slot]
	var card: Dictionary = catalog()[kind]
	_state.energy[side] -= int(card.cost)
	_hands[side][slot] = _queues[side].pop_front()
	_queues[side].append(kind)
	if kind == "thunderbolt":
		for unit in _state.units:
			if unit.side != side and _position(unit).distance_to(position) <= 1.55:
				unit.hp -= 130.0
		for tower in _state.towers:
			if tower.side != side and _position(tower).distance_to(position) <= 1.55:
				tower.hp -= 65.0
		_event("lightning", position, side)
	else:
		for index in range(int(card.count)):
			var spread := (index - (int(card.count) - 1) * 0.5) * 0.42
			var point := Vector2(clampf(position.x + spread, -4.6, 4.6), position.y)
			_state.units.append({"id":_next_id, "side":side, "kind":kind, "x":point.x, "z":point.y, "hp":card.hp, "max_hp":card.hp, "range":card.range, "damage":card.damage, "speed":card.speed, "cooldown":0.2, "slow":0.0, "flying":kind == "harpies", "lane":-2.7 if position.x < 0 else 2.7, "crossed":false})
			_next_id += 1
		_event("summon", position, side)
	_cleanup()
	_state.revision += 1
	return {"ok":true, "error":""}

func tick() -> void:
	if _state.phase != "playing":
		return
	_state.elapsed = float(_state.elapsed) + STEP
	_state.time_remaining = maxf(0.0, (MATCH_SECONDS + 60.0 if _state.overtime else MATCH_SECONDS) - float(_state.elapsed))
	for side in range(2):
		_state.energy[side] = minf(10.0, float(_state.energy[side]) + STEP / 2.8 * (2.0 if _state.elapsed >= 120.0 else 1.0))
	if bot_enabled:
		_bot_wait -= STEP
		if _bot_wait <= 0:
			_bot_turn()
			_bot_wait = 1.5 + _rng.randf() * 1.3
	for unit in _state.units:
		if unit.hp > 0:
			_step_unit(unit)
	for tower in _state.towers:
		if tower.hp > 0:
			_step_tower(tower)
	_cleanup()
	if _state.phase == "playing" and _state.time_remaining <= 0.0001:
		if not _state.overtime and _state.crowns[0] == _state.crowns[1]:
			_state.overtime = true
			_state.time_remaining = 60.0
		else:
			_finish_on_score()
	_state.revision += 1

func _bot_turn() -> void:
	var start := _rng.randi_range(0, 3)
	for offset in range(4):
		var slot := (start + offset) % 4
		var kind: String = _hands[1][slot]
		var point := Vector2(-2.7 if _rng.randf() < 0.5 else 2.7, -2.2 - _rng.randf() * 2.0)
		if kind == "thunderbolt":
			point = Vector2(2.7, 5.0)
			for unit in _state.units:
				if unit.side == 0:
					point = _position(unit)
					break
		if _deploy(1, slot, point).ok:
			return

func _step_unit(unit: Dictionary) -> void:
	unit.cooldown = maxf(0.0, float(unit.cooldown) - STEP)
	unit.slow = maxf(0.0, float(unit.slow) - STEP)
	var target: Dictionary = {}
	var best := 3.1
	if unit.kind != "minotaur":
		for enemy in _state.units:
			if enemy.side == unit.side or enemy.hp <= 0 or (enemy.flying and unit.kind not in ["atalanta", "medusa", "hydra", "harpies"]):
				continue
			var distance := _position(unit).distance_to(_position(enemy))
			if distance < best:
				best = distance
				target = enemy
	if target.is_empty():
		best = 100.0
		for tower in _state.towers:
			if tower.side != unit.side and tower.hp > 0:
				var distance := _position(unit).distance_to(_position(tower))
				if distance < best:
					best = distance
					target = tower
	if target.is_empty():
		return
	var distance := _position(unit).distance_to(_position(target))
	if distance <= float(unit.range):
		if unit.cooldown <= 0:
			_attack(unit, target)
			unit.cooldown = 1.0 if unit.kind != "minotaur" else 1.35
		return
	var destination := _position(target)
	var current := _position(unit)
	# Every ground crossing uses a bridge, even when chasing an enemy.
	if not unit.flying and current.y * destination.y < 0:
		var sign_z := 1.0 if current.y > 0 else -1.0
		if absf(current.x - float(unit.lane)) > 0.12 and absf(current.y) > 0.22:
			destination = Vector2(unit.lane, sign_z * 0.35)
		else:
			destination = Vector2(unit.lane, -sign_z * 0.35)
	var next := current.move_toward(destination, float(unit.speed) * STEP * (0.45 if unit.slow > 0 else 1.0))
	unit.x = next.x
	unit.z = next.y

func _attack(unit: Dictionary, target: Dictionary) -> void:
	target.hp -= float(unit.damage)
	if unit.kind == "medusa" and target.has("slow"):
		target.slow = 1.6
	if unit.kind == "heracles":
		for enemy in _state.units:
			if enemy.id != target.get("id") and enemy.side != unit.side and not enemy.flying and _position(enemy).distance_to(_position(target)) < 1.0:
				enemy.hp -= float(unit.damage) * 0.65
	_event("hit", _position(target), unit.side)

func _step_tower(tower: Dictionary) -> void:
	tower.cooldown = maxf(0.0, float(tower.cooldown) - STEP)
	if tower.cooldown > 0:
		return
	var closest: Dictionary = {}
	var best := 3.25
	for unit in _state.units:
		if unit.side != tower.side and unit.hp > 0:
			var distance := _position(tower).distance_to(_position(unit))
			if distance < best:
				best = distance
				closest = unit
	if not closest.is_empty():
		closest.hp -= 32.0 if tower.kind == "tower" else 42.0
		tower.cooldown = 0.9
		_event("hit", _position(closest), tower.side)

func _cleanup() -> void:
	_state.units = _state.units.filter(func(unit: Dictionary) -> bool: return unit.hp > 0)
	var dead_temples: Array = []
	_state.crowns = [0, 0]
	for tower in _state.towers:
		if tower.hp <= 0:
			tower.hp = 0.0
			if tower.kind == "temple":
				dead_temples.append(tower.side)
			else:
				_state.crowns[1 - int(tower.side)] += 1
	if not dead_temples.is_empty():
		_state.phase = "finished"
		_state.winner = 2 if dead_temples.size() == 2 else 1 - int(dead_temples[0])
		for side in dead_temples:
			_state.crowns[1 - int(side)] = 3
	elif _state.overtime and _state.crowns[0] != _state.crowns[1]:
		_state.phase = "finished"
		_state.winner = 0 if _state.crowns[0] > _state.crowns[1] else 1

func _finish_on_score() -> void:
	var alive := [0, 0]
	var health := [0.0, 0.0]
	for tower in _state.towers:
		if tower.hp > 0:
			alive[tower.side] += 1
		health[tower.side] += tower.hp
	_state.phase = "finished"
	if alive[0] != alive[1]:
		_state.winner = 0 if alive[0] > alive[1] else 1
	elif not is_equal_approx(health[0], health[1]):
		_state.winner = 0 if health[0] > health[1] else 1
	else:
		_state.winner = 2

func _position(thing: Dictionary) -> Vector2:
	return Vector2(thing.x, thing.z)

func _event(kind: String, point: Vector2, side: int) -> void:
	_state.events.append({"kind":kind, "x":point.x, "z":point.y, "side":side, "time":_state.elapsed, "id":_event_id})
	_event_id += 1
	while _state.events.size() > 32:
		_state.events.pop_front()
