extends SceneTree
const Walk=preload("res://themes/hydra_north_walk.tres")
func _initialize(): run.call_deferred()
func run():
	assert(Walk.validation_error().is_empty())
	assert(Walk.regions.size()==8 and Walk.looping)
	var elapsed=0.0
	var hashes=[]
	for i in 8:
		assert(Walk.frame_at(elapsed+.001)==i)
		var pixels=Walk.atlas.get_image().get_region(Walk.regions[i]).get_data()
		var digest=hash(pixels)
		assert(not hashes.has(digest))
		hashes.append(digest)
		elapsed+=Walk.durations[i]
	assert(Walk.frame_at(elapsed+.001)==0)
	if DisplayServer.get_name()=="headless": print("Hydra north walk: eight distinct cells, ordered timing and loop passed"); quit(0); return
	var actor=preload("res://presentation/pixel_actor.gd").new()
	root.add_child(actor)
	assert(actor.reset_playback(Walk))
	actor.advance_visual(.27)
	var frame=actor._shown
	actor.advance_visual(0.0)
	assert(actor._shown==frame)
	actor.reset_playback(Walk)
	assert(actor._shown==0)
	actor.free()
	print("Hydra north walk: eight distinct cells, ordered timing, loop, pause and reset passed")
	quit(0)



