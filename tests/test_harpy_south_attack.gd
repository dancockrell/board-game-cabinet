extends SceneTree
const Attack=preload("res://themes/harpies_south_attack.tres")
const Flight=preload("res://themes/harpies_south_flight.tres")
var failures=0
func check(ok:bool,message:String):
	if not ok: failures+=1; push_error(message)
func _initialize(): run.call_deferred()
func run():
	check(Attack.validation_error().is_empty(),"Attack Resource must validate")
	check(Attack.regions.size()==8 and not Attack.looping,"Eight distinct nonlooping phases")
	var elapsed=0.0
	var hashes=[]
	for i in Attack.regions.size():
		check(Attack.frame_at(elapsed+.001)==i,"Chronological phase %d"%i)
		var digest=hash(Attack.atlas.get_image().get_region(Attack.regions[i]).get_data())
		check(not hashes.has(digest),"Independent source crop %d"%i)
		hashes.append(digest)
		elapsed+=Attack.durations[i]
	check(is_equal_approx(elapsed,.39),"Preserve old attack playback duration")
	check(Attack.frame_at(1.0)==7,"Finished action holds recovery pose")
	var actor=preload("res://presentation/pixel_actor.gd").new()
	root.add_child(actor)
	check(actor.reset_playback(Flight),"Flight starts")
	check(actor.play_attack(10,Attack),"New attack accepted")
	actor.advance_visual(.18)
	check(actor._shown==4,"Double claw projection appears at peak")
	var frame=actor._shown
	actor.advance_visual(0.0)
	check(actor._shown==frame,"Paused attack does not advance")
	check(not actor.play_attack(10,Attack),"Repeated event cannot restart action")
	actor.advance_visual(.22)
	check(actor.clip==Flight and actor._shown==0,"Returns to flight using only remaining elapsed time")
	actor.free()
	print("Harpy south attack: eight unique crops, order, timing, peak, pause, dedup and recovery; %d failures"%failures)
	quit(1 if failures else 0)
