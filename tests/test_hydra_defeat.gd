extends SceneTree
const South=preload("res://themes/hydra_south_defeat.tres")
const North=preload("res://themes/hydra_north_defeat.tres")
var checks:=0
var failures:=0
func check(value:bool,message:String):
	checks+=1
	if not value: failures+=1; push_error(message)
func _initialize(): run.call_deferred()
func run():
	for clip in [South,North]:
		check(clip.validation_error().is_empty(),"Defeat resource validates")
		check(clip.regions.size()==8 and not clip.looping,"Eight chronological nonlooping frames")
		check(clip.magenta_backing and clip.frame_pivots.size()==8,"Keyed original source with authored pivots")
		var elapsed:=0.0
		var hashes: Array=[]
		for i in 8:
			check(clip.frame_at(elapsed+.001)==i,"Chronological frame %d" % i)
			var digest=hash(clip.atlas.get_image().get_region(clip.regions[i]).get_data())
			check(not hashes.has(digest),"Distinct source data %d" % i)
			hashes.append(digest)
			elapsed+=clip.durations[i]
		check(is_equal_approx(elapsed,.78),"Departure duration .78 seconds")
		check(clip.frame_at(100.0)==7,"Completed defeat holds fallen body")
		if DisplayServer.get_name()!="headless":
			var actor=preload("res://presentation/pixel_actor.gd").new()
			root.add_child(actor)
			actor.pixel_size=.003
			actor.position=Vector3(2,.15,3)
			check(actor.reset_playback(clip),"Actor accepts defeat")
			elapsed=0.0
			for i in 8:
				actor.show_time(elapsed+.001)
				check(actor._shown==i and actor.texture.region==Rect2(clip.regions[i]),"Actor shows exact defeat region")
				check(actor.position==Vector3(2,.15,3),"Defeat never moves authoritative root")
				elapsed+=clip.durations[i]
			actor.show_time(100.0)
			check(actor._shown==7,"Actor holds final body")
			actor.free()
	print("Hydra defeat clips: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)


