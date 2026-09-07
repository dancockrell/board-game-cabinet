extends SceneTree
const RESTS = [preload("res://themes/heracles_east_rest.tres"), preload("res://themes/heracles_west_rest.tres"), preload("res://themes/heracles_north_rest.tres"), preload("res://themes/heracles_south_rest.tres")]
const ATTACKS = [preload("res://themes/heracles_east_attack.tres"), preload("res://themes/heracles_west_attack.tres"), preload("res://themes/heracles_north_attack.tres"), preload("res://themes/heracles_south_attack.tres")]
const Actor = preload("res://presentation/pixel_actor.gd")
var checks := 0
var failures := 0

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	for i in 4:
		check(RESTS[i].validation_error().is_empty(), "Valid directional rest")
		check(ATTACKS[i].validation_error().is_empty(), "Valid directional attack")
		check(RESTS[i].looping and not ATTACKS[i].looping, "Only rest loops")
		check(ATTACKS[i].regions.size() == 3 and ATTACKS[i].regions[0] != ATTACKS[i].regions[1], "Distinct wind-up and strike frames")
		check(ATTACKS[i].frame_at(.14) == 1, "Strike follows wind-up")
		var actor := Actor.new()
		actor.reset_playback(RESTS[i])
		check(actor.play_attack(10, ATTACKS[i]), "Directional attack starts")
		actor.advance_visual(.08)
		check(not actor.play_attack(10, ATTACKS[i]), "Repeated authoritative event does not restart")
		actor.advance_visual(2.0)
		check(actor.clip == RESTS[i], "Attack recovers to matching direction")
		actor.free()
	print("Heracles clip checks: ", checks, "; failures: ", failures)
	quit(1 if failures else 0)


