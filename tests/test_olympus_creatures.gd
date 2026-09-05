extends SceneTree
var checks:=0
var failures:=0
func _initialize() -> void:
	call_deferred("run")
func check(value: bool, message: String) -> void:
	checks+=1
	if not value:
		failures+=1
		push_error(message)
func run() -> void:
	var board:=preload("res://presentation/olympus_arena_board.gd").new()
	root.add_child(board)
	await process_frame
	var state:={"units":[{"id":1,"kind":"hydra","side":0,"x":-1.0,"z":2.0,"hp":100,"max_hp":100},{"id":2,"kind":"harpies","side":0,"x":1.0,"z":2.0,"hp":100,"max_hp":100,"flying":true}],"towers":[],"events":[],"elapsed":1.0}
	board.show_state(state,.016)
	var hydra:Node3D=board._tokens[1].get_node("Figure")
	var harpy:Node3D=board._tokens[2].get_node("Figure")
	for index in [-1,0,1]:
		check(hydra.has_node("Neck%d/Skull"%index),"Separate animated neck and skull %d"%index)
	for label in ["WingL","WingR","ArmL","ArmR","LegL","LegR","Head"]:
		check(harpy.has_node(label),"Adult harpy animation pivot "+label)
	var meshes:=0
	var finite:=true
	var pending:Array[Node]=[hydra,harpy]
	while not pending.is_empty():
		var node:Node=pending.pop_back()
		if node is MeshInstance3D:
			meshes+=1
			finite=finite and node.transform.origin.is_finite() and node.transform.basis.determinant()!=0
		for child in node.get_children(): pending.append(child)
	check(finite,"Creature meshes have finite nonsingular transforms")
	check(meshes<220,"Combined creature geometry stays within display-miniature budget")
	var animation:=preload("res://presentation/olympus_figurines.gd").new(board)
	var sculpt:=preload("res://presentation/olympus_creatures.gd").new(animation)
	var feather_test:=Node3D.new()
	board.add_child(feather_test)
	sculpt._feather(feather_test,Vector3.ZERO,Vector3.RIGHT,.12,Color.WHITE,.03)
	var feather:MeshInstance3D=feather_test.get_child(0)
	var arrays:=feather.mesh.surface_get_arrays(0)
	var vertices:PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
	var normals:PackedVector3Array=arrays[Mesh.ARRAY_NORMAL]
	var outward:=true
	for i in range(0,vertices.size(),3):
		var center:Vector3=(vertices[i]+vertices[i+1]+vertices[i+2])/3.0
		outward=outward and normals[i].dot(center-Vector3(.40,0,0))>0
	check(outward,"Closed feather faces point outward instead of showing the hollow reverse side")
	animation.animate(hydra,2.0,true,false,.2,.7)
	animation.animate(harpy,2.0,true,true,.2,.7)
	check(hydra.get_node("Neck0").rotation.x<0,"Hydra attack animates necks")
	check(absf(harpy.get_node("WingL").rotation.z)>0,"Harpy wings animate")
	check(board._tokens[1].position==Vector3(-1,.12,2),"Creature animation preserves authoritative root position")
	await process_frame
	await RenderingServer.frame_post_draw
	board.queue_free()
	await process_frame
	print("Olympus creatures: %d checks, %d failures; %d meshes"%[checks,failures,meshes])
	quit(1 if failures else 0)
