extends SceneTree
## Exercise every roster model in both factions; isolated combat tests only cover
## a few card kinds and would miss dynamic mesh-builder argument errors.
var checks := 0
var failures := 0
func _initialize() -> void: _run.call_deferred()
func check(ok: bool, text: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(text)
func _run() -> void:
	var board := preload("res://presentation/olympus_arena_board.gd").new()
	root.add_child(board)
	for frame in 6: await process_frame
	await RenderingServer.frame_post_draw
	var state := {"elapsed":1.0,"units":[],"towers":[],"events":[]}
	var kinds := ["hoplites","atalanta","minotaur","medusa","heracles","hydra","harpies"]
	for side in 2:
		for i in kinds.size():
			state.units.append({"id":side*10+i,"kind":kinds[i],"side":side,"x":-3.0+(i%4)*2.0,"z":(2.0+(i/4)*2.0)*(1.0 if side==0 else -1.0),"hp":100.0,"max_hp":100.0,"flying":kinds[i]=="harpies"})
	var before := state.duplicate(true)
	board.show_state(state,.016)
	check(state==before,"All model builders preserve their input snapshot")
	check(board._tokens.size()==14,"Every card model builds for both factions")
	for id in board._tokens:
		var token: Node3D=board._tokens[id]
		var figure: Node3D=token.get_node("Figure")
		var pending: Array[Node]=[figure]
		var meshes := 0
		var valid := true
		while not pending.is_empty():
			var node: Node=pending.pop_back()
			if node is MeshInstance3D:
				meshes += 1
				valid = valid and node.mesh != null and node.global_transform.is_finite() and absf(node.global_basis.determinant()) > .0000001
			for child in node.get_children(): pending.append(child)
		if token.get_meta("kind")=="hoplites":
			var sprite=figure.get_node_or_null("PixelActor")
			check(sprite!=null and sprite.texture!=null and sprite.clip.validation_error()=="","Hoplite uses valid pixel clip")
		else:
			check(meshes>10 and valid,"Complete finite geometry for "+str(token.get_meta("kind"))+" side "+str(token.get_meta("side")))
		if token.get_meta("kind") == "minotaur":
			check(figure.get_node("ArmR").get_child_count()>4,"Weapon geometry belongs to animated arm")
		for indicator in token.get_node("Health").get_children():
			check(indicator.cast_shadow==GeometryInstance3D.SHADOW_CASTING_SETTING_OFF,"World-space health indicators do not cast shadows")
	for unit in state.units:
		unit.z += .06
		state.events.append({"id":unit.id,"kind":"hit","source_kind":unit.kind,"side":unit.side,"source_x":unit.x,"source_z":unit.z,"x":unit.x,"z":unit.z-.4})
	state.elapsed=1.1
	board.show_state(state,.1)
	for token in board._tokens.values():
		check(token.get_node("Figure").transform.is_finite(),"Walk and attack pose stays finite")
	var hoplite=board._tokens[0]
	state.units[0].hp=75.0
	board.show_state(state,.05)
	var sprite=hoplite.get_node("Figure/PixelActor")
	check(hoplite.get_meta("damage_serial")==1 and sprite.clip==board.SOUTH_REST and hoplite.get_node("Hit").visible,"Authoritative damage preserves south view with impact feedback")
	board.show_state(state,.05)
	check(hoplite.get_meta("damage_serial")==1,"Repeated health snapshot does not replay hit")
	check(hoplite.position==Vector3(state.units[0].x,.12,state.units[0].z),"Sprite presentation preserves authoritative position")
	state.units=[]
	state.events=[]
	state.elapsed=0.0
	board.show_state(state,.1)
	check(board._tokens.is_empty(),"Rematch discards all roster replicas")
	await process_frame
	board.queue_free()
	for frame in 4: await process_frame
	print("Olympus models: %s checks, %s failures" % [checks,failures])
	quit(1 if failures else 0)
