extends SceneTree
const WALKS = [preload("res://themes/heracles_north_walk.tres"),preload("res://themes/heracles_south_walk.tres")]
const RESTS = [preload("res://themes/heracles_north_rest.tres"),preload("res://themes/heracles_south_rest.tres")]
const ATTACKS = [preload("res://themes/heracles_north_attack.tres"),preload("res://themes/heracles_south_attack.tres")]
const Actor = preload("res://presentation/pixel_actor.gd")
var checks := 0
var failures := 0
func check(ok: bool, message: String) -> void:
    checks += 1
    if not ok: failures += 1; push_error(message)
func _initialize() -> void:
    for i in 2:
        var walk = WALKS[i]
        check(walk.validation_error().is_empty(), "Walk resource valid")
        check(walk.looping and walk.regions.size() == 4, "Four phase loop")
        check(walk.frame_at(.17)==1 and walk.frame_at(.65)==0, "Loop timing progresses and wraps")
        var actor=Actor.new()
        actor.reset_playback(RESTS[i])
        check(actor.set_locomotion(walk), "Walking starts")
        actor.advance_visual(.17)
        check(actor.clip == walk, "Walking persists")
        actor.play_attack(10,ATTACKS[i])
        check(actor.clip == ATTACKS[i], "Attack interrupts walk")
        actor.advance_visual(1.0)
        check(actor.clip == walk, "Walking resumes after attack")
        actor.set_locomotion(null)
        check(actor.clip == RESTS[i], "Stopping restores direction rest")
        actor.free()
    print("Heracles walk checks: ", checks, "; failures: ", failures)
    quit(1 if failures else 0)
