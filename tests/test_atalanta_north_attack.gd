extends SceneTree
const ATTACK = preload("res://themes/atalanta_north_attack.tres")
const REST = preload("res://themes/atalanta_north_rest.tres")
const Actor = preload("res://presentation/pixel_actor.gd")
var failures := 0
var checks := 0
func check(ok: bool, label: String):
	checks += 1
	if not ok: failures += 1; push_error(label)
func _initialize():
	check(ATTACK.validation_error().is_empty(), "North attack validates")
	check(ATTACK.regions.size() == 8 and not ATTACK.looping, "Eight ordered nonlooping poses")
	var actor := Actor.new()
	actor.reset_playback(REST)
	actor.play_attack(1, ATTACK)
	var elapsed := 0.0
	var unique := {}
	for phase in 8:
		actor.show_time(elapsed + .001)
		check(actor.texture.region == Rect2(ATTACK.regions[phase]), "Actual texture visits phase %d" % phase)
		unique[hash(ATTACK.atlas.get_image().get_region(ATTACK.regions[phase]).get_data())] = true
		elapsed += ATTACK.durations[phase]
	check(unique.size() == 8, "Eight different source drawings")
	check(elapsed < 1.0, "Recovery completes before next attack cooldown")
	check(ATTACK.frame_at(elapsed + 5) == 7, "Nonlooping clip holds final pose")
	actor.advance_visual(1.0)
	check(actor.clip == REST, "Attack recovers to facing rest")
	actor.free()
	print("Atalanta north attack checks: ", checks, "; failures: ", failures)
	quit(1 if failures else 0)

