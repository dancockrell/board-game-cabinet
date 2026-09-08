extends SceneTree
const Actor=preload("res://presentation/pixel_actor.gd")
const CLIPS=[preload("res://themes/atalanta_south_defeat.tres"),preload("res://themes/atalanta_north_defeat.tres")]
var checks:=0
var failures:=0
func check(ok:bool,message:String):
    checks+=1
    if not ok: failures+=1; push_error(message)
func _initialize(): run.call_deferred()
func run():
    for clip in CLIPS:
        check(clip.validation_error().is_empty(),"Defeat Resource validates")
        check(clip.regions.size()==8 and not clip.looping,"Eight nonlooping defeat drawings")
        var elapsed:=0.0
        var hashes=[]
        var actor=Actor.new()
        root.add_child(actor)
        actor.pixel_size=.003
        check(actor.set_clip(clip),"Native actor accepts defeat")
        for i in 8:
            check(clip.frame_at(elapsed+.001)==i,"Chronological pose %d"%i)
            var digest=hash(clip.atlas.get_image().get_region(clip.regions[i]).get_data())
            check(not hashes.has(digest),"Separate source drawing %d"%i)
            hashes.append(digest)
            actor.show_time(elapsed+.001)
            check(actor._shown==i,"Actor shows authored pose %d"%i)
            check(clip.frame_pivots[i].y>0 and clip.frame_pivots[i].y<=clip.regions[i].size.y,"Measured body ground anchor stays within crop")
            actor.show_time(elapsed+.001)
            check(actor._shown==i,"Paused sampling is stable")
            elapsed+=clip.durations[i]
        check(is_equal_approx(elapsed,.78),"Fits existing .78 second departure lifetime")
        check(clip.frame_at(99)==7,"Final collapsed body holds")
        check(is_equal_approx(clip.draw_scale,2.5),"Native rest-comparison scale retained")
        actor.free()
    print("Atalanta defeat Resources: %d checks, %d failures"%[checks,failures])
    quit(1 if failures else 0)

