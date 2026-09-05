extends SceneTree
var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func run() -> void:
	var fx := preload("res://presentation/olympus_combat_fx.gd").new()
	root.add_child(fx)
	await process_frame
	var tower := {"id":"left","x":2.7,"z":5.0,"side":0,"hp":100.0,"max_hp":100.0}
	var state := {"elapsed":1.0,"units":[{"kind":"medusa","side":0,"x":1.0,"z":2.0}],"towers":[tower],"events":[{"id":0,"kind":"hit","x":1.0,"z":.5,"side":0,"source_x":1.0,"source_z":2.0}]}
	var untouched := state.duplicate(true)
	fx.consume_state(state,.016)
	check(state == untouched,"FX never modifies input state")
	check(fx._attacker(state.events[0]) == "medusa","Attacker kind inferred from friendly source position")
	var explicit: Dictionary = state.events[0].duplicate()
	explicit.source_kind="atalanta"
	check(fx._attacker(explicit) == "atalanta","Authoritative source kind takes precedence over inference")
	check(not fx.effects.is_empty(),"Medusa creates visible gaze and impact")
	var count: int = fx.effects.size()
	fx.consume_state(state,0.0)
	check(fx.effects.size() == count,"Repeated snapshot does not replay effects")
	fx.animate(2.0)
	check(fx.effects.is_empty(),"Gaze effects expire")
	state.towers[0].hp=0.0
	fx.consume_state(state,0.0)
	check(fx.effects.size() >= 15,"Tower destruction produces debris and smoke")
	count=fx.effects.size()
	fx.consume_state(state,0.0)
	check(fx.effects.size() == count,"Destroyed tower does not explode repeatedly")
	fx.animate(2.0)
	check(fx.effects.is_empty(),"Tower effects expire")
	for kind in ["hoplites","atalanta","heracles","hydra","minotaur","harpies","medusa"]:
		state.units[0].kind=kind
		state.events[0].id+=1
		fx.consume_state(state,0.0)
		check(not fx.effects.is_empty(),"Unit effect renders: "+kind)
	state.events[0].id += 1
	state.events[0].source_kind = "temple"
	fx.consume_state(state, 0.0)
	check(fx.effects.any(func(effect): return str(effect.get("impact", "")) == "giant"), "Temple launches a distinct heavy projectile")
	fx.animate(2.0)
	fx.animate(2.0)
	check(fx.effects.is_empty(),"Projectile completion impacts also expire")
	for ability in ["charge_ready", "charge_hit", "heal"]:
		state.events[0] = {"id":int(state.events[0].id)+1,"kind":ability,"x":1.0,"z":.5,"side":0,"source_kind":"minotaur" if ability.begins_with("charge") else "hydra"}
		fx.consume_state(state,0.0)
		check(not fx.effects.is_empty(),"Ability feedback renders: "+ability)
		fx.animate(2.0)
	check(fx.effects.is_empty(),"Ability feedback expires cleanly")
	for i in 100:
		fx.show_event({"kind":"lightning","x":0,"z":0,"side":0})
	check(fx.effects.size() <= fx.MAX_EFFECTS,"Heavy bursts respect hard effect cap")
	state.elapsed=0.0
	state.events=[]
	fx.consume_state(state,0.0)
	check(fx.effects.is_empty(),"New match clears previous effects")
	check(fx._last_id == -1,"New match resets event cursor")
	fx.queue_free()
	await process_frame
	print("Olympus combat FX: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
