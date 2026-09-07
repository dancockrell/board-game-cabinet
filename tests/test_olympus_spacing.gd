extends SceneTree

const Arena = preload("res://games/olympus_arena/session.gd")
var checks := 0
var failures := 0

func _init() -> void:
	var game = Arena.new()
	game.bot_enabled = false
	_check(game.deploy(0, Vector2(0, 3)).ok, "formation deployment succeeds")
	_check(_gap(game._state.units[0], game._state.units[1]) >= 0.81, "fresh soldiers have body room")
	var a: Dictionary = game._state.units[0]
	var b: Dictionary = game._state.units[1]
	game._state.units = [a, b]
	a.x = 0.0
	b.x = 0.0
	for step in range(30): game._separate_units()
	_check(_gap(a, b) >= 0.819, "coincident allies separate deterministically")
	a.kind = "hydra"
	b.kind = "minotaur"
	for step in range(30): game._separate_units()
	_check(_gap(a, b) >= 1.129, "large allies reserve larger bodies")
	b.side = 1
	a.x = 0.0
	b.x = 0.0
	a.z = 3.0
	b.z = 3.0
	for step in range(30): game._separate_units()
	_check(_gap(a, b) > 0.579 and _gap(a, b) < 0.65, "enemy separation permits spear melee")
	b.flying = true
	b.x = a.x
	b.z = a.z
	var before: Dictionary = game.snapshot()
	game._separate_units()
	_check(game.snapshot() == before, "ground bodies never push flying actors")
	# A crowded bridge is a soft queue, not a hard collision wall or a water escape.
	var first = _bridge_game()
	var second = _bridge_game()
	var crossed := false
	for step in range(240):
		first.tick()
		second.tick()
		_check(first.snapshot() == second.snapshot(), "bridge simulation repeats exactly at tick %s" % step)
		var view: Dictionary = first.snapshot()
		_check(first.snapshot() == view, "reading a snapshot does not advance spacing")
		for unit in view.units:
			_check(absf(unit.x) <= 4.6 and absf(unit.z) <= 7.8, "body stays within arena")
			_check(absf(unit.z) >= Arena.RIVER_BANK or absf(absf(unit.x) - 2.7) <= Arena.BRIDGE_HALF_WIDTH + 0.00001, "crowd stays on bridge")
			crossed = crossed or unit.z < -1.0
	_check(crossed, "crowded allies make progress across bridge")
	# Legal edge/bank spawn retains every soldier on its deployment side.
	game.new_game()
	_check(game.deploy(0, Vector2(4.6, 0.8)).ok, "edge deployment remains legal")
	_check(_gap(game._state.units[1], game._state.units[2]) >= 0.819, "edge formation shifts inward without stacking soldiers")
	for unit in game.snapshot().units:
		_check(unit.x <= 4.6 and unit.z >= 0.8, "formation never spawns outside deployment zone")
	print("Olympus spacing: %s checks, %s failures" % [checks, failures])
	quit(1 if failures else 0)

func _bridge_game():
	var game = Arena.new()
	game.bot_enabled = false
	game.deploy(0, Vector2(-2.7, 1.0))
	game._state.energy[0] = 10.0
	game.deploy(0, Vector2(-2.7, 1.0))
	for tower in game._state.towers:
		tower.cooldown = 1000.0
	return game

func _gap(a: Dictionary, b: Dictionary) -> float:
	return Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))

func _check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(label)
