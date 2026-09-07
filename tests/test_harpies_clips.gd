extends SceneTree
const FLIGHT = [preload("res://themes/harpies_south_flight.tres"), preload("res://themes/harpies_north_flight.tres")]
const STRIKE = [preload("res://themes/harpies_south_attack.tres"), preload("res://themes/harpies_north_attack.tres")]
var checks := 0
func _initialize() -> void: _run.call_deferred()
func _check(value: bool, description: String) -> void:
    checks += 1
    if not value:
        push_error(description)
        quit(1)
func _run() -> void:
    for i in 2:
        var flight=FLIGHT[i]
        var strike=STRIKE[i]
        _check(flight.validation_error().is_empty(), "Flight resource invalid")
        _check(strike.validation_error().is_empty(), "Strike resource invalid")
        _check(flight.looping and not strike.looping, "Flight/strike looping contract")
        _check(flight.regions.size()==4, "Four authored wing phases")
        var length: float=0
        for time in flight.durations: length+=time
        _check(flight.frame_at(length+.001)==0, "Flight wraps")
        _check(strike.frame_at(20)==strike.regions.size()-1, "Strike holds final frame")
        if DisplayServer.get_name()!="headless":
            var actor=preload("res://presentation/pixel_actor.gd").new()
            root.add_child(actor)
            _check(actor.reset_playback(flight) and actor.set_locomotion(flight), "Continuous hovering")
            actor.advance_visual(.20)
            _check(actor.clip==flight, "Flight remains active")
            _check(actor.play_attack(1,strike), "Strike interrupts wing loop")
            _check(not actor.play_attack(1,strike), "Duplicate strike ignored")
            actor.advance_visual(2)
            _check(actor.clip==flight, "Strike recovers to active flight")
            actor.queue_free()
    print("Harpies: %d checks passed" % checks)
    quit(0)
