extends SceneTree
## Staged all-character render, not gameplay evidence.
const Board = preload("res://presentation/olympus_arena_board.gd")
func _initialize() -> void: _run.call_deferred()
func _run() -> void:
	var directory := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture-dir="): directory=arg.trim_prefix("--capture-dir=")
	if not directory.is_absolute_path() or DirAccess.make_dir_recursive_absolute(directory)!=OK: quit(2); return
	root.size=Vector2i(1440,960)
	var board=Board.new()
	root.add_child(board)
	board.camera.size=12
	board.camera.position=Vector3(0,15,18)
	board.camera.look_at(Vector3(0,.7,0))
	var kinds=["hoplites","atalanta","medusa","minotaur","heracles","hydra","harpies"]
	var state={"units":[],"towers":[],"events":[],"elapsed":1.0}
	for side in 2:
		for i in kinds.size():
			state.units.append({"id":side*10+i,"kind":kinds[i],"side":side,"x":-6.3+i*2.1,"z":3.0 if side==0 else -3.0,"hp":100.0,"max_hp":100.0,"flying":kinds[i]=="harpies"})
	board.show_state(state)
	var label:=Label.new()
	label.text="ROSTER ANIMATION STUDY / STAGED POSES / NOT GAMEPLAY"
	label.position=Vector2(20,20)
	root.add_child(label)
	for frame in 90:
		if frame==15:
			for unit in state.units:
				state.events.append({"id":unit.id,"kind":"hit","source_id":unit.id,"source_type":"unit","side":unit.side,"source_x":unit.x,"source_z":unit.z,"x":unit.x,"z":unit.z-2.0 if unit.side==0 else unit.z+2.0})
		board.show_state(state,1.0/30.0)
		await process_frame
		await RenderingServer.frame_post_draw
		if root.get_texture().get_image().save_png(directory.path_join("frame-%04d.png"%frame))!=OK: quit(2); return
	print("Roster study: 90 native frames")
	quit()
