extends SceneTree
var failures := 0
var checks := 0

func _initialize() -> void:
	run.call_deferred()

func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(description)

func run() -> void:
	var board := preload("res://presentation/olympus_arena_board.gd").new()
	root.add_child(board)
	await process_frame
	var state := {"elapsed":1.0, "events":[], "towers":[], "units":[{"id":1,"kind":"hoplites","side":0,"x":2.7,"z":3.0,"hp":100.0,"max_hp":100.0}]}
	board.show_state(state)
	state.units[0].hp = 76.0
	board.show_state(state, 0.1)
	var numbers = board.damage_numbers
	check(numbers.entries.size()==1, "One loss creates one burst")
	var first = numbers.entries[0].label
	check(first.text=="−24", "Burst displays health loss")
	check(first.position.y>board._tokens[1].position.y+board._tokens[1].get_node("Health").position.y, "Damage appears above the health bar")
	state.units[0].hp = 52.0
	board.show_state(state, 0.1)
	check(numbers.entries.size()==1 and first.text=="−48", "Rapid damage merges into one readable total")
	var paused_position: Vector3 = first.position
	var paused_age: float = numbers.entries[0].age
	for frame in range(8):
		board.show_state(state, 0.0)
		await process_frame
	check(first.position==paused_position and numbers.entries[0].age==paused_age, "Real frames cannot advance paused damage labels")
	check(first.text=="−48", "Repeated snapshots do not double count")
	board.show_state(state, 0.2)
	state.units[0].hp = 20.0
	board.show_state(state)
	check(numbers.entries.size()==2, "A later hit starts a new burst")
	check(absf(numbers.entries[0].origin.x-numbers.entries[1].origin.x)>=0.4, "Concurrent nearby bursts occupy distinct slots")
	board.show_state(state, 0.8)
	check(numbers.entries.is_empty(), "All bursts expire on the presentation clock")
	state.units[0].hp = 10.0
	board.show_state(state)
	check(numbers.entries.size()==1, "A fresh loss remains visible")
	state.elapsed = 0.0
	state.units[0].hp = 100.0
	board.show_state(state)
	check(numbers.entries.is_empty(), "Rematch clears old damage without making a new burst")
	for index in range(40): numbers.show_loss(index, Vector3(index, 2, 0), 1)
	check(numbers.entries.size()==numbers.MAX_LABELS, "Burst capacity remains bounded")
	numbers.clear()
	check(numbers.entries.is_empty(), "Explicit cleanup clears bookkeeping")
	board.queue_free()
	await process_frame
	print("Damage number checks: %d; failures: %d" % [checks, failures])
	quit(1 if failures else 0)
