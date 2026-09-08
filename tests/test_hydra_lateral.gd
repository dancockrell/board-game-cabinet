extends SceneTree
const Clips = [preload("res://themes/hydra_east_idle.tres"),preload("res://themes/hydra_west_idle.tres"),preload("res://themes/hydra_east_attack.tres"),preload("res://themes/hydra_west_attack.tres")]

const Walks = [preload("res://themes/hydra_east_walk.tres"),preload("res://themes/hydra_west_walk.tres")]

func _initialize() -> void:
	for clip in Walks:
		if not clip.validation_error().is_empty() or not clip.looping or clip.regions.size()!=4: quit(1); return
		for i in 4:
			if clip.frame_at(i*.2+.03)!=i: quit(1); return
	for i in Clips.size():
		var clip=Clips[i]
		if not clip.validation_error().is_empty(): push_error(clip.validation_error()); quit(1); return
		if clip.frame_at(0)!=0 or clip.frame_at(clip.durations[0]+.001)!=1: quit(1); return
		if clip.looping != (i<2): quit(1); return
		if not clip.looping and clip.frame_at(100)!=3: quit(1); return
	print("Hydra sprite resources: four clips valid; ordered timing and attack hold verified")
	quit(0)

