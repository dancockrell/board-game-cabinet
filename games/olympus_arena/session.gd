class_name OlympusArenaSession
extends RefCounted

const STEP := 0.1
const MATCH_SECONDS := 180.0
const MAX_UNITS := 64
const RIVER_BANK := 0.8
const BRIDGE_HALF_WIDTH := 0.50
const GROUND_SPACING := 0.58
const ALLY_BODY_RADIUS := {"hoplites":0.41, "atalanta":0.41, "medusa":0.41, "heracles":0.50, "minotaur":0.55, "hydra":0.58}
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
		"minotaur": {"name":"Minotaur", "cost":5, "description":"Targets towers. Build a charge by moving; next hit deals double damage.", "hp":720.0, "damage":86.0, "speed":0.78, "range":0.8, "count":1},
		"medusa": {"name":"Medusa", "cost":4, "description":"Ranged gaze slows enemy movement.", "hp":260.0, "damage":29.0, "speed":0.72, "range":2.35, "count":1},
		"heracles": {"name":"Heracles", "cost":5, "description":"His club hits nearby ground enemies.", "hp":640.0, "damage":64.0, "speed":0.75, "range":0.8, "count":1},
		"hydra": {"name":"Hydra", "cost":6, "description":"Bites ground and air. Heals after 4 seconds without taking damage.", "hp":1080.0, "damage":58.0, "speed":0.52, "range":1.15, "count":1},
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
	if float(_state.energy[side]) + 0.000001 < int(card.cost):
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
	_state.energy[side] = maxf(0.0, float(_state.energy[side]) - int(card.cost))
	_hands[side][slot] = _queues[side].pop_front()
	_queues[side].append(kind)
	if kind == "thunderbolt":
		for unit in _state.units:
			if unit.side != side and _position(unit).distance_to(position) <= 1.55:
				_hurt(unit, 130.0)
		for tower in _state.towers:
			if tower.side != side and _position(tower).distance_to(position) <= 1.55:
				tower.hp -= 65.0
		_event("lightning", position, side)
	else:
		for index in range(int(card.count)):
			var formation_gap := 0.42 if kind == "harpies" else 0.82
			var spread := (index - (int(card.count) - 1) * 0.5) * formation_gap
			var half_formation := (int(card.count) - 1) * 0.5 * formation_gap
			# Shift the whole formation inward at the edge rather than stack clamped bodies.
			var center_x := clampf(position.x, -4.6 + half_formation, 4.6 - half_formation)
			var point := Vector2(center_x + spread, position.y)
			_state.units.append({"id":_next_id, "side":side, "kind":kind, "x":point.x, "z":point.y, "hp":card.hp, "max_hp":card.hp, "range":card.range, "damage":card.damage, "speed":card.speed, "cooldown":0.2, "slow":0.0, "flying":kind == "harpies", "lane":-2.7 if position.x < 0 else 2.7, "crossed":false, "charge_distance":0.0, "charge_ready":false, "recovery_time":0.0, "heal_clock":0.0})
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
			if _state.phase != "playing":
				return
	for unit in _state.units:
		if unit.hp > 0:
			_step_unit(unit)
	_separate_units()
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
	# React only to current visible pieces: no future RNG or player-hand inspection.
	var threats := [0.0, 0.0]
	var air_threat := [false, false]
	var nearest_z := [-1.0, -1.0]
	for unit in _state.units:
		if unit.side != 0 or unit.hp <= 0 or unit.z > -0.4: continue
		var lane := 0 if unit.x < 0 else 1
		threats[lane] += float(unit.hp) * (1.0 + maxf(0.0, -float(unit.z) - 1.0) * 0.3)
		air_threat[lane] = air_threat[lane] or unit.flying
		nearest_z[lane] = minf(nearest_z[lane], unit.z)
	var defending: bool = maxf(threats[0], threats[1]) > 0
	var lane: int = (0 if threats[0] >= threats[1] else 1) if defending else _bot_push_lane()
	var lane_x := -2.7 if lane == 0 else 2.7
	var frontline := false
	for unit in _state.units:
		if unit.side == 1 and (unit.x < 0) == (lane == 0) and unit.kind in ["minotaur", "hydra", "heracles"]:
			frontline = true
	var cards := catalog()
	var chosen := -1
	var best_score := -INF
	var best_unaffordable := -INF
	var point := Vector2(lane_x, clampf(nearest_z[lane] - 1.1, -6.5, -1.2) if defending else -4.1 if frontline else -2.7)
	var spell := _bot_spell_target()
	for slot in range(4):
		var kind: String = _hands[1][slot]
		var score := 0.0
		if kind == "thunderbolt":
			score = float(spell.score) / 35.0 if spell.score >= 180.0 else -100.0
		elif defending:
			score = {"hoplites":6.0, "atalanta":7.0, "minotaur":-10.0, "medusa":9.0, "heracles":8.0, "hydra":7.0, "harpies":6.0}[kind]
			if air_threat[lane]: score += 6.0 if kind in ["atalanta", "medusa", "hydra", "harpies"] else -20.0
		else:
			score = ({"hoplites":7.0, "atalanta":10.0, "minotaur":4.0, "medusa":9.0, "heracles":5.0, "hydra":4.0, "harpies":8.0} if frontline else {"hoplites":4.0, "atalanta":3.0, "minotaur":10.0, "medusa":4.0, "heracles":9.0, "hydra":11.0, "harpies":3.0})[kind]
		if float(_state.energy[1]) + 0.000001 < float(cards[kind].cost):
			if float(cards[kind].cost) - float(_state.energy[1]) <= 2.0:
				best_unaffordable = maxf(best_unaffordable, score)
			continue
		if score > best_score and score > 0:
			best_score = score
			chosen = slot
	# In quiet moments, save briefly for a coherent front line instead of leaking troops.
	if not defending and best_unaffordable > best_score: return
	if chosen < 0: return
	if _hands[1][chosen] == "thunderbolt": point = spell.position
	_deploy(1, chosen, point)

func _bot_push_lane() -> int:
	var health := [INF, INF]
	for tower in _state.towers:
		if tower.side == 0 and tower.kind == "tower" and tower.hp > 0:
			health[0 if tower.x < 0 else 1] = tower.hp
	# Follow an existing push when either lane is otherwise equally attractive.
	if health[0] == health[1]:
		for unit in _state.units:
			if unit.side == 1 and unit.hp > 0: return 0 if unit.x < 0 else 1
		return _rng.randi_range(0, 1)
	return 0 if health[0] < health[1] else 1

func _bot_spell_target() -> Dictionary:
	var candidates: Array[Vector2] = []
	for unit in _state.units:
		if unit.side == 0 and unit.hp > 0: candidates.append(_position(unit))
	for tower in _state.towers:
		if tower.side == 0 and tower.hp > 0: candidates.append(_position(tower))
	var best := {"score":0.0, "position":Vector2.ZERO}
	for point in candidates:
		var score := 0.0
		for unit in _state.units:
			if unit.side == 0 and unit.hp > 0 and _position(unit).distance_to(point) <= 1.55:
				score += minf(unit.hp, 130.0) + (25.0 if unit.hp <= 130.0 else 0.0)
		for tower in _state.towers:
			if tower.side == 0 and tower.hp > 0 and _position(tower).distance_to(point) <= 1.55:
				score += 1000.0 if tower.hp <= 65.0 else 20.0
		if score > best.score: best = {"score":score, "position":point}
	return best

func _step_unit(unit: Dictionary) -> void:
	unit.cooldown = maxf(0.0, float(unit.cooldown) - STEP)
	unit.slow = maxf(0.0, float(unit.slow) - STEP)
	if unit.kind == "hydra":
		unit.recovery_time = float(unit.recovery_time) + STEP
		unit.heal_clock = float(unit.heal_clock) + STEP
		if unit.recovery_time >= 4.0 - 0.000001 and unit.hp < unit.max_hp:
			if unit.heal_clock >= 1.0 - 0.000001:
				var healing := minf(20.0, float(unit.max_hp) - float(unit.hp))
				unit.hp += healing
				unit.heal_clock = 0.0
				_event("heal", _position(unit), unit.side, Vector2.INF, {"unit_id":unit.id, "amount":healing, "source_kind":"hydra"})
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
			destination = Vector2(unit.lane, sign_z * (RIVER_BANK + 0.05))
		else:
			destination = Vector2(unit.lane, -sign_z * (RIVER_BANK + 0.05))
	var next := current.move_toward(destination, float(unit.speed) * STEP * (0.45 if unit.slow > 0 else 1.0))
	next = _constrain_position(unit, current, next)
	if unit.kind == "minotaur" and not unit.charge_ready:
		unit.charge_distance = float(unit.charge_distance) + current.distance_to(next)
		if unit.charge_distance >= 2.4:
			unit.charge_ready = true
			_event("charge_ready", next, unit.side, Vector2.INF, {"unit_id":unit.id, "source_kind":"minotaur"})
	unit.x = next.x
	unit.z = next.y

func _separate_units() -> void:
	# Two deterministic soft passes preserve crowd flow without teleporting fighters.
	# Allies reserve readable body space; opponents remain within melee reach.
	# Soft constraints allow bottlenecks to compress without blocking legal deployment.
	for iteration in range(2):
		var pushes: Array[Vector2] = []
		pushes.resize(_state.units.size())
		pushes.fill(Vector2.ZERO)
		for first in range(_state.units.size()):
			var a: Dictionary = _state.units[first]
			if a.hp <= 0: continue
			for second in range(first + 1, _state.units.size()):
				var b: Dictionary = _state.units[second]
				if b.hp <= 0 or a.flying != b.flying: continue
				var gap := 0.32 if a.flying else GROUND_SPACING
				if not a.flying and a.side == b.side:
					gap = float(ALLY_BODY_RADIUS.get(a.kind, 0.41)) + float(ALLY_BODY_RADIUS.get(b.kind, 0.41))
				var difference := _position(a) - _position(b)
				var distance := difference.length()
				if distance >= gap: continue
				var direction: Vector2
				if distance > 0.00001:
					direction = difference / distance
				else:
					# Identity-derived tie breaking never consumes the opponent RNG.
					var angle := float((int(a.id) * 13 + int(b.id) * 7) % 16) * TAU / 16.0
					direction = Vector2(cos(angle), sin(angle))
				var push := direction * (gap - distance) * 0.5
				pushes[first] += push
				pushes[second] -= push
		for index in range(_state.units.size()):
			var unit: Dictionary = _state.units[index]
			if unit.hp <= 0: continue
			var current := _position(unit)
			var next := _constrain_position(unit, current, current + pushes[index].limit_length(0.04))
			unit.x = next.x
			unit.z = next.y

func _constrain_position(unit: Dictionary, current: Vector2, desired: Vector2) -> Vector2:
	var point := Vector2(clampf(desired.x, -4.6, 4.6), clampf(desired.y, -7.8, 7.8))
	if unit.flying: return point
	var bridge_x := -2.7 if current.x < 0 else 2.7
	if absf(current.y) < RIVER_BANK:
		# A unit already on a bridge cannot be pushed sideways into the river.
		point.x = clampf(point.x, bridge_x - BRIDGE_HALF_WIDTH, bridge_x + BRIDGE_HALF_WIDTH)
	elif absf(point.y) < RIVER_BANK and absf(absf(point.x) - 2.7) > BRIDGE_HALF_WIDTH:
		point.y = RIVER_BANK if current.y >= 0 else -RIVER_BANK
	return point

func _attack(unit: Dictionary, target: Dictionary) -> void:
	var charged: bool = unit.kind == "minotaur" and unit.get("charge_ready", false)
	var damage := float(unit.damage) * (2.0 if charged else 1.0)
	_hurt(target, damage)
	if charged:
		unit.charge_ready = false
		unit.charge_distance = 0.0
		_event("charge_hit", _position(target), unit.side, _position(unit), {"unit_id":unit.id, "source_kind":unit.kind, "target_kind":target.kind, "damage":damage})
	if unit.kind == "medusa" and target.has("slow"):
		target.slow = 1.6
	if unit.kind == "heracles":
		for enemy in _state.units:
			if str(enemy.id) != str(target.get("id")) and enemy.side != unit.side and not enemy.flying and _position(enemy).distance_to(_position(target)) < 1.0:
				_hurt(enemy, float(unit.damage) * 0.65)
	_event("hit", _position(target), unit.side, _position(unit), {"source_id":unit.id, "source_type":"unit", "target_id":target.id, "source_kind":unit.kind, "target_kind":target.kind, "damage":damage, "charged":charged})

func _hurt(target: Dictionary, damage: float) -> void:
	target.hp -= damage
	if target.kind == "hydra":
		target.recovery_time = 0.0
		target.heal_clock = 0.0

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
		var damage := 32.0 if tower.kind == "tower" else 42.0
		_hurt(closest, damage)
		tower.cooldown = 0.9
		_event("hit", _position(closest), tower.side, _position(tower), {"source_id":tower.id, "source_type":"tower", "target_id":closest.id, "source_kind":tower.kind, "target_kind":closest.kind, "damage":damage})

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

func _event(kind: String, point: Vector2, side: int, source: Vector2 = Vector2.INF, details: Dictionary = {}) -> void:
	var event := {"kind":kind, "x":point.x, "z":point.y, "side":side, "time":_state.elapsed, "id":_event_id}
	event.merge(details)
	if source.is_finite():
		event["source_x"] = source.x
		event["source_z"] = source.y
	_state.events.append(event)
	_event_id += 1
	while _state.events.size() > 32:
		_state.events.pop_front()
