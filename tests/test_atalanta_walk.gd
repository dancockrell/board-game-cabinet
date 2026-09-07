extends SceneTree
const WALKS = [preload("res://themes/atalanta_north_walk.tres"), preload("res://themes/atalanta_south_walk.tres")]
const RESTS = [preload("res://themes/atalanta_north_rest.tres"), preload("res://themes/atalanta_south_rest.tres")]
const ATTACKS = [preload("res://themes/atalanta_north_attack.tres"), preload("res://themes/atalanta_south_attack.tres")]
const Actor = preload("res://presentation/pixel_actor.gd")
var failures := 0
var checks := 0

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	for i in 2:
		var walk = WALKS[i]
		check(walk.validation_error().is_empty() and walk.looping, "Valid looping walk")
		var actor := Actor.new()
		actor.reset_playback(RESTS[i])
		actor.set_locomotion(walk)
		var time := 0.0
		for phase in walk.durations.size():
			actor.show_time(time + .001)
			check(actor.texture.region == Rect2(walk.regions[phase]), "Each authored phase reached in order")
			time += walk.durations[phase]
		actor.show_time(time + .001)
		check(actor.texture.region == Rect2(walk.regions[0]), "Walk loops to first phase")
		actor.play_attack(1, ATTACKS[i])
		actor.advance_visual(1.0)
		check(actor.clip == walk, "Shooting recovers into continuing movement")
		actor.set_locomotion(null)
		check(actor.clip == RESTS[i], "Stopping recovers correct rest")
		actor.free()
	print("Atalanta walk checks: ", checks, "; failures: ", failures)
	quit(1 if failures else 0)
