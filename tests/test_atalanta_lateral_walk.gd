extends SceneTree
const WALKS = [preload("res://themes/atalanta_east_walk.tres"), preload("res://themes/atalanta_west_walk.tres")]
const RESTS = [preload("res://themes/atalanta_east_rest.tres"), preload("res://themes/atalanta_west_rest.tres")]
const ATTACKS = [preload("res://themes/atalanta_east_attack.tres"), preload("res://themes/atalanta_west_attack.tres")]
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
		if i == 0: check(walk.frame_atlases.size() == 8, "East has eight authored source frames")
		for phase in walk.durations.size():
			actor.show_time(time + .001)
			check(actor.texture.region == Rect2(walk.regions[phase]), "Each authored phase reached in order")
			var expected_source = walk.atlas if walk.frame_atlases.is_empty() else walk.frame_atlases[phase]
			check(actor.texture.atlas == expected_source, "Each phase selects its own authored image")
			time += walk.durations[phase]
		actor.show_time(time + .001)
		check(actor.texture.region == Rect2(walk.regions[0]), "Walk loops to first phase")
		actor.play_attack(1, ATTACKS[i])
		actor.advance_visual(1.0)
		check(actor.clip == walk, "Shooting recovers into continuing movement")
		actor.set_locomotion(null)
		check(actor.clip == RESTS[i], "Stopping recovers correct rest")
		actor.free()
	print("Atalanta lateral walk checks: ", checks, "; failures: ", failures)
	quit(1 if failures else 0)


