extends SceneTree
## Four authored facings, staged attack/recovery; no fabricated gameplay events.
const REST = {
    "south": preload("res://themes/medusa_south_rest.tres"),
    "north": preload("res://themes/medusa_north_rest.tres"),
    "east": preload("res://themes/medusa_east_rest.tres"),
    "west": preload("res://themes/medusa_west_rest.tres")
}
const ATTACK = {
    "south": preload("res://themes/medusa_south_attack.tres"),
    "north": preload("res://themes/medusa_north_attack.tres"),
    "east": preload("res://themes/medusa_east_attack.tres"),
    "west": preload("res://themes/medusa_west_attack.tres")
}
func _initialize() -> void: _run.call_deferred()
func _run() -> void:
    var output := ""
    for arg in OS.get_cmdline_user_args():
        if arg.begins_with("--capture-dir="): output=arg.trim_prefix("--capture-dir=")
    if not output.is_absolute_path(): quit(2); return
    DirAccess.make_dir_recursive_absolute(output)
    root.size=Vector2i(1440,960)
    var board=preload("res://presentation/olympus_arena_board.gd").new()
    root.add_child(board)
    board.camera.size=9.0
    board.camera.position=Vector3(0,10.5,14)
    board.camera.look_at(Vector3(0,.6,3))
    var actors=[]
    for facing in REST:
        if not REST[facing].validation_error().is_empty() or not ATTACK[facing].validation_error().is_empty():
            push_error("Invalid Medusa clip "+facing)
            quit(1); return
        var actor=preload("res://presentation/pixel_actor.gd").new()
        actor.pixel_size=.0027
        board.add_child(actor)
        actor.position=Vector3(-3.0+actors.size()*2.0,.15,3)
        if not actor.reset_playback(REST[facing]): quit(1); return
        actors.append(actor)
    var title=Label.new()
    title.text="MEDUSA / SOUTH, NORTH, EAST, WEST / STAGED GAZE AND RECOVERY"
    title.position=Vector2(30,25)
    root.add_child(title)
    Engine.max_fps=30
    for frame in 90:
        for i in actors.size():
            if frame in [15,55]: actors[i].play_attack(frame,ATTACK[REST.keys()[i]])
            actors[i].advance_visual(1.0/30.0)
        for tick in 2: await process_frame
        await RenderingServer.frame_post_draw
        if root.get_texture().get_image().save_png(output.path_join("frame-%04d.png"%frame))!=OK: quit(2); return
    for i in actors.size():
        if actors[i].clip!=REST[REST.keys()[i]]:
            push_error("Medusa failed to recover "+REST.keys()[i]); quit(1); return
    print("Medusa: 8 resource validations, 4 attack/recovery checks, 90 native frames; passed")
    quit(0)
