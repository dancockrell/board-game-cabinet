extends SceneTree

var checks := 0
var failures := 0

func _initialize() -> void:
	_run.call_deferred()

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _run() -> void:
	var fx := preload("res://presentation/olympus_hud_fx.gd").new()
	fx.size = Vector2(900, 698)
	root.add_child(fx)
	await process_frame
	var state := {"elapsed":1.0,"phase":"playing","overtime":false,"towers":[{"id":"red_left","kind":"tower","hp":100.0}]}
	var untouched := state.duplicate(true)
	fx.consume_state(state)
	expect(state == untouched, "HUD observer never changes authoritative state")
	state.towers[0].hp = 0.0
	fx.consume_state(state)
	expect(fx._banner == "TOWER FALLEN" and fx._flash_age == 0.0, "Tower loss creates one readable alert")
	fx.deployed(Vector2(450, 500))
	expect(fx._sparks.size() == 14, "Deployment creates a bounded celebration")
	for i in 20: fx.deployed(Vector2(450, 500))
	expect(fx._sparks.size() <= 84, "Repeated deployment stays under the particle cap")
	fx.advance(0.6)
	expect(fx._sparks.is_empty(), "Deployment sparks expire")
	state.elapsed = 120.0
	fx.consume_state(state)
	expect(fx._banner == "DOUBLE ELIXIR", "Double elixir announces once")
	state.overtime = true
	fx.consume_state(state)
	expect(fx._banner == "SUDDEN DEATH", "Overtime announces once")
	fx.show_countdown("3")
	expect(fx._banner == "3" and is_equal_approx(fx._banner_duration, 0.92), "Countdown uses short cinematic banner")
	fx.reset()
	expect(fx._sparks.is_empty() and fx._last_towers.is_empty() and not fx._double_announced, "Rematch clears transient HUD state")
	fx.queue_free()
	await process_frame
	print("Olympus HUD FX: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
