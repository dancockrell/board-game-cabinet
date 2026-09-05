extends SceneTree
## Reproducible wooden-set render without application or rules dependencies.
## godot --path . --script presentation/capture_preview.gd -- output.png

func _initialize() -> void:
    call_deferred("_capture")

func _capture() -> void:
    root.size = Vector2i(1100, 960)
    var view := preload("res://presentation/board_view.gd").new()
    root.add_child(view)
    var board: Array = []
    board.resize(64)
    board.fill("")
    var back := "RNBQKBNR"
    for i in range(8):
        board[i] = back[i]
        board[8 + i] = "P"
        board[48 + i] = "p"
        board[56 + i] = back[i].to_lower()
    view.show_position(board)
    view.show_highlights(12, [20, 28])
    for _frame in range(8):
        await process_frame
    await RenderingServer.frame_post_draw
    var args := OS.get_cmdline_user_args()
    var output: String = args[0] if not args.is_empty() else "user://wooden-set-preview.png"
    var result := root.get_texture().get_image().save_png(output)
    print("Wooden preview saved: ", output, " result=", result)
    quit(result)
