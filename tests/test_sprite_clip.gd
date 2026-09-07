extends SceneTree
const GuardClip=preload("res://themes/hoplite_guard_clip.tres")
const Clip=preload("res://presentation/sprite_clip.gd")
var failures:=0
func check(value: bool, label: String) -> void:
	if not value: failures+=1; push_error(label)
func _initialize() -> void:
	check(GuardClip is Clip and GuardClip.validation_error()=="","Shipped guard Resource loads its script, atlas and timing")
	var clip:=Clip.new()
	var img:=Image.create(64,32,false,Image.FORMAT_RGBA8)
	clip.atlas=ImageTexture.create_from_image(img)
	clip.regions=[Rect2i(0,0,32,32),Rect2i(32,0,32,32)]
	clip.durations=PackedFloat32Array([.125,.375])
	check(clip.validation_error()=="","Valid ordered clip")
	check(clip.frame_at(.124)==0 and clip.frame_at(.125)==1,"Exact frame boundary")
	check(clip.frame_at(.5)==0,"Loop boundary returns first")
	clip.looping=false
	check(clip.frame_at(9)==1,"One-shot holds final")
	check(clip.frame_at(-1)==0,"Negative time clamps")
	clip.durations[0]=0
	check(clip.frame_at(0)==-1,"Reject zero duration")
	clip.durations[0]=.125
	clip.regions[1]=Rect2i(50,0,32,32)
	check(not clip.validation_error().is_empty(),"Reject atlas overflow")
	if DisplayServer.get_name() != "headless":
		clip.regions[1]=Rect2i(32,0,32,32)
		clip.pivot=Vector2(16,30)
		var actor:=preload("res://presentation/pixel_actor.gd").new()
		check(actor.set_clip(clip),"Actor accepts valid clip")
		check(actor.offset==Vector2(0,14),"Foot pivot raises image above origin")
		actor.show_time(.125)
		check(actor.texture.region.position==Vector2(32,0),"Actor displays ordered second frame")
		var rest=clip.duplicate()
		rest.looping=true
		check(actor.reset_playback(rest),"Rest clip resets reaction state")
		check(actor.react_to_hit(7,clip),"Fresh authoritative event starts reaction")
		actor.advance_visual(.2)
		check(not actor.react_to_hit(7,clip) and actor.texture.region.position==Vector2(32,0),"Repeated snapshot does not restart reaction")
		actor.advance_visual(1)
		check(actor.clip==rest,"Completed reaction returns to rest")
		check(not actor.react_to_hit(6,clip),"Older events ignored")
		actor.reset_playback(rest)
		check(actor.react_to_hit(0,clip),"Rematch accepts new event numbering")
		actor.free()
	print("Sprite clip: %s checks, %s failures"%[8 if DisplayServer.get_name()=="headless" else 17,failures])
	quit(1 if failures else 0)
