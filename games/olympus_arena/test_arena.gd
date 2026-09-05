extends SceneTree

const Arena = preload("res://games/olympus_arena/session.gd")
var checks := 0
var failures := 0

func _init() -> void:
	var game = Arena.new()
	game.bot_enabled = false
	_check(game.snapshot().hand.size() == 4, "four-card hand")
	_check(game.catalog().size() == 8, "eight cards")
	var initial: Dictionary = game.snapshot()
	_check(not game.deploy(0, Vector2(0, -2)).ok, "enemy half blocked")
	_check(not game.deploy(-1, Vector2(0, 2)).ok, "bad slot blocked")
	_check(not game.deploy(0, Vector2(NAN, 2)).ok, "NaN blocked")
	_check(not game.deploy(0, Vector2(0, 2), 99).ok, "stale revision blocked")
	_check(game.snapshot() == initial, "invalid actions fully atomic")
	_check(game.preview_deploy(0, Vector2(0, 2)).ok, "valid preview")
	_check(not game.preview_deploy(0, Vector2(0, -2)).ok, "invalid preview")
	_check(game.snapshot() == initial, "preview never mutates")
	var external: Dictionary = game.snapshot()
	external.energy[0] = 999
	external.towers[0].hp = 0
	_check(game.snapshot() == initial, "snapshot isolated")
	_check(game.deploy(0, Vector2(-2.7, 2)).ok, "troop deployment")
	_check(game.snapshot().units.size() == 3, "hoplite trio")
	_check(is_equal_approx(game.snapshot().energy[0], 2.0), "paid exact cost")
	_check(game.snapshot().hand[0] == "heracles", "queue rotates")
	_check(not game.deploy(0, Vector2(0, 2)).ok, "unaffordable rejected")
	for frame in range(28):
		game.tick()
	_check(is_equal_approx(game.snapshot().energy[0], 3.0), "normal regeneration 2.8 seconds")
	for frame in range(300):
		game.tick()
	_check(game.snapshot().energy[0] <= 10.0, "regeneration caps at ten")
	game.new_game()
	game.bot_enabled = false
	game.deploy(2, Vector2(0, 1.1))
	var crossed := false
	for frame in range(230):
		game.tick()
		for unit in game.snapshot().units:
			if absf(unit.z) < 0.15:
				_check(absf(absf(unit.x) - 2.7) < 0.15, "ground unit crosses on bridge")
			if unit.z < 0:
				crossed = true
	_check(crossed, "unit crosses river")
	var damaged := false
	for tower in game.snapshot().towers:
		if tower.side == 1 and tower.hp < tower.max_hp:
			damaged = true
	_check(damaged, "attacker damages enemy tower")
	game.new_game()
	game.bot_enabled = false
	for frame in range(1800):
		game.tick()
	_check(game.snapshot().overtime and game.snapshot().phase == "playing", "tie enters overtime")
	for frame in range(600):
		game.tick()
	_check(game.snapshot().phase == "finished" and game.snapshot().winner == 2, "untouched match draws after overtime")
	var ended: Dictionary = game.snapshot()
	game.tick()
	_check(game.snapshot() == ended, "finished battle frozen")
	_check(not game.deploy(0, Vector2(0, 2)).ok, "deployment after finish rejected")
	var a = Arena.new()
	var b = Arena.new()
	for frame in range(700):
		a.tick()
		b.tick()
		_check(a.snapshot().energy[1] >= 0 and a.snapshot().energy[1] <= 10, "bot obeys energy budget")
	_check(a.snapshot() == b.snapshot(), "seeded bot deterministic")
	_combat_checks()
	print("Olympus arena: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)

func _combat_checks() -> void:
	var game = Arena.new()
	game.bot_enabled = false
	game._state.energy = [10.0, 10.0]
	game._hands[0][0] = "medusa"
	game._hands[1][0] = "hoplites"
	game.deploy(0, Vector2(2.7, 0.8))
	game._deploy(1, 0, Vector2(2.7, -0.8))
	for frame in range(3):
		game.tick()
	var slowed := false
	for unit in game.snapshot().units:
		if unit.side == 1 and unit.slow > 0:
			slowed = true
	_check(slowed, "Medusa slows enemies within gaze range")
	game.new_game()
	game._state.energy = [10.0, 10.0]
	game._hands[0][0] = "heracles"
	game._hands[1][0] = "harpies"
	game.deploy(0, Vector2(2.7, 0.8))
	game._deploy(1, 0, Vector2(2.7, -0.8))
	for frame in range(20):
		game.tick()
	var untouched_air := true
	for unit in game.snapshot().units:
		if unit.side == 1 and unit.hp != unit.max_hp:
			untouched_air = false
	_check(untouched_air, "Heracles cannot hit flying harpies")
	game.new_game()
	game._state.energy = [10.0, 10.0]
	game._hands[0][0] = "thunderbolt"
	var tower_hp: float = game.snapshot().towers[3].hp
	game.deploy(0, Vector2(-2.7, -5.0))
	_check(is_equal_approx(game.snapshot().towers[3].hp, tower_hp - 65.0), "spell reaches enemy tower and applies tower damage")
	_check(is_equal_approx(game.snapshot().towers[4].hp, 1100.0), "spell radius excludes far tower")
	game._state.towers[3].hp = 0
	game._cleanup()
	_check(game.snapshot().crowns == [1, 0], "side tower awards one crown")
	game._state.elapsed = 179.9
	game.tick()
	_check(game.snapshot().phase == "finished" and game.snapshot().winner == 0, "crown leader wins at regulation")
	game.new_game()
	game._state.elapsed = 179.9
	game.tick()
	game._state.towers[0].hp = 0
	game.tick()
	_check(game.snapshot().winner == 1, "overtime next tower wins")
	game.new_game()
	game._state.towers[5].hp = 0
	game._cleanup()
	_check(game.snapshot().winner == 0 and game.snapshot().crowns[0] == 3, "temple destruction immediately awards three crowns and victory")
	game.new_game()
	game._state.energy[0] = 0.0
	game._state.elapsed = 120.0
	for frame in range(14):
		game.tick()
	_check(is_equal_approx(game.snapshot().energy[0], 1.0), "final minute doubles regeneration")
	game.new_game()
	game._state.energy = [10.0, 10.0]
	game._hands[0][0] = "heracles"
	game.deploy(0, Vector2(2.7, 2))
	game._deploy(1, 0, Vector2(2.7, -5))
	var hero: Dictionary = game._state.units[0]
	var tower: Dictionary = game._state.towers[4]
	hero.x = tower.x
	hero.z = tower.z + 0.5
	var enemy: Dictionary = game._state.units[1]
	var enemy_before: float = enemy.hp
	game._attack(hero, tower)
	_check(enemy.hp < enemy_before, "Heracles hitting a string-ID tower also splashes nearby integer-ID units")
	var hit: Dictionary = game.snapshot().events.back()
	_check(hit.has("source_x") and hit.has("source_z") and is_equal_approx(hit.source_x, hero.x) and is_equal_approx(hit.source_z, hero.z), "Hit event records authoritative projectile origin")

func _check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(label)
