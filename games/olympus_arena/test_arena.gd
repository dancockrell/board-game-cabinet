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
	_crowd_checks()
	_bot_checks()
	_ability_checks()
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
	_check(hit.source_id==hero.id and hit.source_type=="unit" and hit.target_id==tower.id, "Unit attack preserves exact source and target IDs")
	_check(hit.source_kind == "heracles" and hit.target_kind == "tower" and is_equal_approx(hit.damage, hero.damage), "Unit hit identifies attacker, target type, and applied damage")
	tower.cooldown = 0.0
	game._step_tower(tower)
	var tower_hit: Dictionary = game.snapshot().events.back()
	_check(tower_hit.source_id==tower.id and tower_hit.source_type=="tower" and tower_hit.target_id==hero.id, "Tower attack preserves exact source and target IDs")
	_check(tower_hit.source_kind == "tower" and tower_hit.target_kind == "heracles" and tower_hit.damage == 32.0, "Tower hit identifies source and target types with actual damage")

func _check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(label)

func _crowd_checks() -> void:
	var game = Arena.new()
	game.bot_enabled = false
	game.deploy(0, Vector2(4.6, 4.0))
	for iteration in range(20): game._separate_units()
	var group: Array = game.snapshot().units
	var spaced := true
	for first in range(group.size()):
		for second in range(first + 1, group.size()):
			if Vector2(group[first].x, group[first].z).distance_to(Vector2(group[second].x, group[second].z)) < 0.5:
				spaced = false
	_check(spaced, "Boundary-clamped deployment separates into individual authoritative troops")
	for unit in group:
		_check(absf(unit.x) <= 4.6 and absf(unit.z) <= 7.8, "Crowd separation stays within arena")
	# A crowd pressed toward the bank cannot enter water away from a bridge.
	for index in range(game._state.units.size()):
		game._state.units[index].x = 0.0
		game._state.units[index].z = 0.8 + index * 0.05
	for iteration in range(20): game._separate_units()
	var bank_safe := true
	for unit in game.snapshot().units:
		if unit.z < 0.8: bank_safe = false
	_check(bank_safe, "Crowd pressure cannot push ground troops through the river bank")
	# Bridge traffic may spread across its deck but never off its side.
	for index in range(game._state.units.size()):
		game._state.units[index].x = 3.19
		game._state.units[index].z = 0.0
		game._state.units[index].side = index % 2
	for iteration in range(20): game._separate_units()
	var bridge_safe := true
	for unit in game.snapshot().units:
		if absf(unit.z) < 0.8 and absf(unit.x - 2.7) > 0.50001: bridge_safe = false
	_check(bridge_safe, "Opposing bridge crowds remain on bridge deck")
	_check(Vector2(game._state.units[0].x, game._state.units[0].z).distance_to(Vector2(game._state.units[1].x, game._state.units[1].z)) > 0.3, "Opposing coincident units acquire deterministic separation")
	var a = Arena.new()
	var b = Arena.new()
	var all_safe := true
	for frame in range(500):
		if frame % 90 == 0:
			for arena in [a, b]:
				arena.deploy(0, Vector2(0.0, 0.8))
		a.tick()
		b.tick()
		for unit in a.snapshot().units:
			if not unit.flying and absf(unit.z) < 0.79999 and absf(absf(unit.x) - 2.7) > 0.50001:
				all_safe = false
	_check(all_safe, "Live crowded routes never cut water away from bridges")
	_check(a.snapshot() == b.snapshot(), "Repeated player deployments and crowd simulation remain exactly deterministic")

func _bot_checks() -> void:
	var game = Arena.new()
	game.bot_enabled = false
	game._hands[0][0] = "harpies"
	game.deploy(0, Vector2(-2.7, 2.0))
	for unit in game._state.units: unit.z = -4.0
	game._state.energy[1] = 4.0
	game._bot_turn()
	var defender: Dictionary = game.snapshot().units.back()
	_check(defender.side == 1 and defender.x < 0 and defender.kind == "medusa", "Bot counters an approaching flying push in its threatened lane")
	_check(is_equal_approx(game.snapshot().energy[1], 0.0), "Defensive counter pays normal card cost")
	game.new_game()
	game._state.energy[1] = 0.0
	var before: Dictionary = game.snapshot()
	game._bot_turn()
	_check(game.snapshot() == before, "Unaffordable bot hand cannot deploy or mutate visible state")
	game._state.energy[1] = 3.0
	before = game.snapshot()
	game._bot_turn()
	_check(game.snapshot() == before, "Quiet bot reserves elixir for an affordable-soon front line")
	game.new_game()
	game._hands[1] = ["thunderbolt", "hydra", "heracles", "minotaur"]
	game._state.energy[1] = 2.0
	game.deploy(0, Vector2(-2.7, 2.0))
	var target: Dictionary = game._bot_spell_target()
	_check(target.position.x < 0 and target.score >= 390.0, "Bot values a clustered troop spell over healthy towers")
	game._bot_turn()
	var hurt := true
	for unit in game.snapshot().units:
		if unit.side == 0 and not is_equal_approx(unit.hp, 15.0): hurt = false
	_check(hurt and game.snapshot().hand.size() == 4, "Bot spell damages the selected cluster using ordinary deployment")
	_check(is_equal_approx(game.snapshot().energy[1], 0.0), "Tactical spell respects elixir affordability")
	game.new_game()
	game._state.towers[1].hp = 60.0
	game._hands[1] = ["thunderbolt", "hydra", "heracles", "minotaur"]
	game._state.energy[1] = 2.0
	game._bot_turn()
	_check(game.snapshot().crowns[1] == 1, "Bot recognizes a spell-finishable opposing tower")
	game.new_game()
	game._state.towers[0].hp = 400.0
	game._bot_turn()
	var attacker: Dictionary = game.snapshot().units.back()
	_check(attacker.kind == "minotaur" and attacker.x < 0, "Bot opens a coherent building push against weaker enemy lane")
	game._state.energy[1] = 4.0
	game._bot_turn()
	var support: Dictionary = game.snapshot().units.back()
	_check(support.kind == "atalanta" and support.x < 0 and support.z < attacker.z, "Bot supports an existing front line with an archer behind it")

func _ability_checks() -> void:
	var game = Arena.new()
	game.bot_enabled = false
	game.deploy(2, Vector2(-2.7, 4.0))
	var bull: Dictionary = game._state.units[0]
	for frame in range(32): game.tick()
	_check(bull.charge_ready, "Minotaur builds charge from actual travel")
	var ready_event := false
	for event in game.snapshot().events:
		if event.kind == "charge_ready" and event.unit_id == bull.id: ready_event = true
	_check(ready_event, "Charge readiness has an explicit presentation event")
	var tower: Dictionary = game._state.towers[3]
	var hp_before: float = tower.hp
	game._attack(bull, tower)
	_check(is_equal_approx(hp_before - tower.hp, 172.0), "Charged Minotaur strike deals exactly double base damage")
	_check(not bull.charge_ready and bull.charge_distance == 0.0, "Charged strike consumes movement charge")
	var event: Dictionary = game.snapshot().events.back()
	_check(event.kind == "hit" and event.charged and event.damage == 172.0, "Standard hit event reports charged damage truthfully")
	hp_before = tower.hp
	game._attack(bull, tower)
	_check(is_equal_approx(hp_before - tower.hp, 86.0), "Standing Minotaur follow-up uses ordinary damage")
	game.new_game()
	game._state.energy[0] = 10.0
	game._hands[0][0] = "hydra"
	game.deploy(0, Vector2(0, 7.0))
	var hydra: Dictionary = game._state.units[0]
	game._hurt(hydra, 100.0)
	for frame in range(39): game.tick()
	_check(hydra.hp == 980.0, "Hydra cannot recover before four seconds unharmed")
	game.tick()
	_check(hydra.hp == 1000.0, "Hydra restores twenty health at four seconds")
	var heal_event: Dictionary = game.snapshot().events.back()
	_check(heal_event.kind == "heal" and heal_event.unit_id == hydra.id and heal_event.amount == 20.0, "Recovery emits exact unit and healing amount")
	for frame in range(10): game.tick()
	_check(hydra.hp == 1020.0, "Unharmed Hydra continues recovery once per second")
	game._hands[1][0] = "thunderbolt"
	game._state.energy[1] = 10.0
	game._deploy(1, 0, Vector2(hydra.x, hydra.z))
	_check(hydra.recovery_time == 0.0 and hydra.heal_clock == 0.0, "Thunderbolt interrupts Hydra recovery")
	hp_before = hydra.hp
	for frame in range(39): game.tick()
	_check(hydra.hp == hp_before, "Damaged Hydra waits a full new recovery interval")
	hydra.hp = hydra.max_hp - 3.0
	game.tick()
	_check(hydra.hp == hydra.max_hp, "Recovery cannot exceed maximum health")
