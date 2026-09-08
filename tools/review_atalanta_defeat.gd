extends SceneTree
const Actor=preload("res://presentation/pixel_actor.gd")
const SOUTH=preload("res://themes/atalanta_south_defeat.tres")
const NORTH=preload("res://themes/atalanta_north_defeat.tres")
const SOUTH_REST=preload("res://themes/atalanta_south_rest.tres")
const NORTH_REST=preload("res://themes/atalanta_north_rest.tres")
func _initialize(): run.call_deferred()
func run():
    var output=""
    for arg in OS.get_cmdline_user_args():
        if arg.begins_with("--capture="): output=arg.trim_prefix("--capture=")
    if not output.is_absolute_path(): quit(2); return
    root.size=Vector2i(1440,900)
    var board=preload("res://presentation/olympus_arena_board.gd").new()
    root.add_child(board)
    board.camera.size=6.0
    board.camera.position=Vector3(0,10.5,14)
    board.camera.look_at(Vector3(0,.6,3))
    var actors=[]
    for i in 4:
        var actor=Actor.new()
        actor.pixel_size=.003
        board.add_child(actor)
        actor.position=Vector3(-2.1+i*1.4,0.0,3)
        actor.reset_playback(SOUTH_REST if i<2 else NORTH_REST)
        actors.append(actor)
    DirAccess.make_dir_recursive_absolute(output)
    for frame in 96:
        var elapsed=maxf(0,(frame-12)/60.0)
        for i in 4:
            var actor=actors[i]
            if i%2==0:
                actor.advance_visual(1.0/60)
            elif frame>=12:
                if frame==12: actor.set_clip(SOUTH if i==1 else NORTH)
                actor.show_time(elapsed)
                var landing=0.0
                actor.position.y=0.0
        await process_frame
        await RenderingServer.frame_post_draw
        root.get_texture().get_image().save_png(output.path_join("frame-%03d.png"%frame))
    print("Atalanta defeat study:96frames, canonical rest beside south/north eight-pose grounded defeat")
    quit(0)


