extends SceneTree
const WALK = preload("res://themes/heracles_east_walk.tres")
const REST = preload("res://themes/heracles_east_rest.tres")
const ATTACK = preload("res://themes/heracles_east_attack.tres")
const Actor = preload("res://presentation/pixel_actor.gd")
var checks := 0
var failures := 0
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)
func _initialize() -> void:
	check(WALK.validation_error().is_empty(), "East clip validates")
	check(WALK.regions.size() == 4 and WALK.frame_atlases.size() == 4, "Four individually authored east sources")
	var actor := Actor.new()
	actor.reset_playback(REST)
	actor.set_locomotion(WALK)
	var elapsed := 0.0
	var seen := {}
	for phase in 4:
		actor.show_time(elapsed + .001)
		check(actor.texture.atlas == WALK.frame_atlases[phase], "East source reached in chronological order")
		check(actor.texture.region == Rect2(WALK.regions[phase]), "East source region stays intact")
		seen[actor.texture.atlas.resource_path] = true
		elapsed += WALK.durations[phase]
	check(seen.size() == 4, "No repeated atlas fills the four-source cycle")
	actor.show_time(elapsed + .001)
	check(actor.texture.atlas == WALK.frame_atlases[0], "East cycle loops")
	actor.play_attack(1, ATTACK)
	actor.advance_visual(1.0)
	check(actor.clip == WALK, "East attack returns to continuing walking")
	actor.set_locomotion(null)
	check(actor.clip == REST, "East stop restores facing rest")
	actor.free()
	print("Heracles east walk checks: ", checks, "; failures: ", failures)
	quit(1 if failures else 0)
