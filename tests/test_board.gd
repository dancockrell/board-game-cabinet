extends SceneTree
## Native rendering smoke/interaction regression: run without --headless.
var failures: int = 0
var checks: int = 0

func _initialize() -> void:
    call_deferred("run")

func check(condition: bool, message: String) -> void:
    checks += 1
    if not condition:
        failures += 1
        push_error(message)

func run() -> void:
    var view := preload("res://presentation/board_view.gd").new()
    root.add_child(view)
    await process_frame
    var camera: Camera3D = view.get("_camera")
    for flipped in [false, true]:
        view.set_flipped(flipped)
        for square in range(64):
            var screen := camera.unproject_position(view.to_global(view.square_position(square)))
            check(view.screen_to_square(screen) == square, "Square picking failed %d flipped=%s" % [square, flipped])
    var before: Array = []
    before.resize(64)
    before.fill("")
    before[12] = "P"
    var after := before.duplicate()
    after[12] = ""
    after[28] = "P"
    view.show_position(before)
    view.show_position(after, true)
    var pieces: Node3D = view.get("_pieces")
    var moved: Node3D = pieces.get_node("Square28")
    check(moved.position.is_equal_approx(view.square_position(12)), "Animation must begin at source")
    await create_timer(0.3).timeout
    check(moved.position.is_equal_approx(view.square_position(28)), "Animation must settle at authoritative destination")
    view.show_position(before, true)
    view.show_position(after)
    await create_timer(0.3).timeout
    check(pieces.get_child_count() == 1, "Interrupted animation must not retain stale pieces")
    check(pieces.get_node("Square28").position.is_equal_approx(view.square_position(28)), "Interrupted animation must not move rebuilt state")
    before.fill("")
    before[4] = "K"
    before[7] = "R"
    after = before.duplicate()
    after[4] = ""
    after[7] = ""
    after[6] = "K"
    after[5] = "R"
    var origins: Dictionary = view._movement_origins(before, after)
    check(origins.get(6) == 4 and origins.get(5) == 7, "Castling must map both moving pieces")
    before.fill("")
    before[48] = "P"
    after = before.duplicate()
    after[48] = ""
    after[56] = "N"
    origins = view._movement_origins(before, after)
    check(origins.get(56) == 48, "Promoted chip must animate from pawn source")
    var audio := preload("res://presentation/move_audio.gd").new()
    root.add_child(audio)
    check(audio.stream is AudioStreamWAV and not audio.stream.data.is_empty(), "Wooden sound must synthesize PCM")
    audio.set_muted(true)
    audio.play_move_sound()
    check(not audio.playing, "Muted moves must remain silent")
    print("Board presentation: %d checks, %d failures" % [checks, failures])
    quit(0 if failures == 0 else 1)
