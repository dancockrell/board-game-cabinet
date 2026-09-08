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
	check(not FileAccess.file_exists("res://assets/olympus_arena/sprites/atalanta-north-attack-eight.png"), "Rejected source removed from all-resources export tree")
	check(not FileAccess.file_exists("res://assets/olympus_arena/sprites/atalanta-north-attack-eight.png.import"), "Rejected import sidecar removed")
	check(ATTACK.validation_error().is_empty(), "Legacy north clip validates")
	check(not ATTACK.looping, "Attack does not loop")
	check(not ATTACK.atlas.resource_path.contains("north-attack-eight"), "Rejected wrong-handed eight sheet cannot ship")
	for source in ATTACK.frame_atlases:
		check(not source.resource_path.contains("north-attack-eight"), "Rejected sheet excluded from per-frame sources")
	var actor := Actor.new()
	actor.reset_playback(REST)
	actor.play_attack(1, ATTACK)
	actor.advance_visual(1.0)
	check(actor.clip == REST, "Legacy attack still recovers to rest")
	actor.free()
	print("Atalanta north attack admission checks: ", checks, "; failures: ", failures)
	quit(1 if failures else 0)
