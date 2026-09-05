extends RefCounted
## Original painted tabletop miniatures. Only presentation; no combat decisions live here.
var host: Node3D
var gold := Color("ad8950")
var bronze := Color("806747")
var ivory := Color("d8ceb9")
var leather := Color("4e4438")
var skin := Color("bb9679")
var _paint: Dictionary = {}

func _init(renderer: Node3D) -> void:
	host = renderer

func ball(p: Node3D, at: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	return _finish(host._sphere(p, size, at, color), color)

func box(p: Node3D, at: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	return _finish(host._box(p, size, at, color), color)

func rod(p: Node3D, a: Vector3, b: Vector3, radius: float, color: Color) -> MeshInstance3D:
	return _finish(host._limb(p, a, b, radius, color), color)

func tapered_limb(p: Node3D, a: Vector3, b: Vector3, upper: float, lower: float) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = lower
	mesh.bottom_radius = upper
	mesh.height = a.distance_to(b)
	mesh.radial_segments = 12
	var limb := _finish(host._mesh(p, mesh, (a+b)*.5, skin), skin)
	limb.quaternion = Quaternion(Vector3.UP, (b-a).normalized())
	return limb

func _finish(mesh: MeshInstance3D, color: Color) -> MeshInstance3D:
	if not _paint.has(color):
		var material := StandardMaterial3D.new()
		material.albedo_color = color
		material.roughness = .84
		if color == gold or color == bronze:
			material.metallic = .54
			material.roughness = .47
		_paint[color] = material
	mesh.material_override = _paint[color]
	return mesh

func joint(p: Node3D, label: String, at: Vector3) -> Node3D:
	var node := Node3D.new()
	node.name = label
	node.position = at
	p.add_child(node)
	return node

func cone(p: Node3D, at: Vector3, bottom: float, top: float, height: float, color: Color) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.bottom_radius = bottom
	mesh.top_radius = top
	mesh.height = height
	mesh.radial_segments = 10
	return _finish(host._mesh(p, mesh, at, color), color)

func face(p: Node3D, at: Vector3, color: Color = Color("bb9679"), bull := false) -> void:
	ball(p, at, Vector3(.20,.22,.18) if not bull else Vector3(.27,.26,.21), color)
	for s in [-1,1]:
		box(p, at + Vector3(s * .075,.025,.168), Vector3(.05,.014,.018), leather)
		box(p, at + Vector3(s * .078,.055,.173), Vector3(.075,.018,.022), color.darkened(.30)).rotation.z = s * -.10
	rod(p, at + Vector3(0,.035,.16), at + Vector3(0,-.04,.19), .022, color)
	box(p, at + Vector3(0,-.105,.157), Vector3(.065,.009,.018), color.darkened(.32))

func cape(p: Node3D, team: Color, width := .30, length := .54) -> void:
	var cloth := joint(p, "Cape", Vector3(0,.92,-.10))
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for row in 7:
		for column in 8:
			var corners: Array[Vector3] = []
			for offset in [Vector2(0,0),Vector2(1,0),Vector2(0,1),Vector2(1,1)]:
				var u: float = (column+offset.x)/8.0
				var v: float = (row+offset.y)/7.0
				corners.append(Vector3((u-.5)*width*1.8*(.70+v*.30),-v*length,-.035-v*.13+sin(u*PI*8)*.020*(.3+v)))
			for i in [0,2,1,1,2,3]: surface.add_vertex(corners[i])
	surface.generate_normals()
	var mesh := _finish(host._mesh(cloth,surface.commit(),Vector3.ZERO,team),team)
	var material := mesh.material_override.duplicate() as StandardMaterial3D
	material.cull_mode=BaseMaterial3D.CULL_DISABLED
	mesh.material_override=material
	for i in 8:
		var a:=i/8.0
		var b:=(i+1)/8.0
		rod(cloth,Vector3((a-.5)*width*1.8,-length,-.165+sin(a*PI*8)*.026),Vector3((b-.5)*width*1.8,-length,-.165+sin(b*PI*8)*.026),.009,ivory.darkened(.18))
func humanoid(p: Node3D, team: Color, muscular := false, legs := true, cloth := Color("d8ceb9")) -> void:
	if legs:
		for s in [-1,1]:
			var leg := joint(p, "LegL" if s < 0 else "LegR", Vector3(s*.12,.49,0))
			tapered_limb(leg, Vector3.ZERO, Vector3(s*.008,-.15,.005), .072 if muscular else .053, .051 if muscular else .039)
			tapered_limb(leg, Vector3(s*.008,-.15,.005), Vector3(s*.015,-.30,.015), .054 if muscular else .042, .037 if muscular else .029)
			ball(leg, Vector3(s*.008,-.15,.005), Vector3(.053,.043,.045), skin)
			box(leg, Vector3(s*.015,-.33,.065), Vector3(.13,.072,.21), leather)
			box(leg, Vector3(s*.015,-.23,.064), Vector3(.087,.14,.025), bronze)
	ball(p, Vector3(0,.72,0), Vector3(.27 if muscular else .205,.27,.14), skin if muscular else cloth)
	cone(p, Vector3(0,.49,0), .27,.20,.22, leather if muscular else cloth)
	box(p, Vector3(0,.59,.15), Vector3(.36,.045,.025), leather)
	box(p, Vector3(0,.59,.17), Vector3(.06,.055,.02), bronze)
	for i in 12:
		var a := i*TAU/12
		var strip := box(p,Vector3(sin(a)*.235,.48,cos(a)*.185),Vector3(.07,.18,.018),leather if muscular else cloth.darkened((i%3)*.025))
		strip.rotation.y = a
	var sash := box(p, Vector3(.03,.78,.15), Vector3(.058,.27,.02),team.darkened(.18))
	sash.rotation.z = -.3
	for s in [-1,1]:
		var arm := joint(p, "ArmL" if s < 0 else "ArmR", Vector3(s*.24,.85,0))
		ball(arm, Vector3(0,-.022,0), Vector3(.076,.079,.069) if muscular else Vector3(.053,.069,.049), skin if muscular else cloth)
		tapered_limb(arm, Vector3.ZERO, Vector3(s*.055,-.14,.025), .075 if muscular else .047, .050 if muscular else .034)
		tapered_limb(arm, Vector3(s*.055,-.14,.025), Vector3(s*.075,-.28,.11), .061 if muscular else .04, .038 if muscular else .027)
		ball(arm, Vector3(s*.075,-.28,.11), Vector3(.049,.065,.041), skin)

func build(p: Node3D, kind: String, team: Color) -> void:
	p.set_meta("kind", kind)
	team = team.lerp(Color("6e6b60"), .42).darkened(.12)
	if kind == "hoplites":
		preload("res://presentation/olympus_sculpt.gd").new(self).hoplite(p,team)
		return
	if kind == "minotaur":
		preload("res://presentation/olympus_sculpt.gd").new(self).minotaur(p,team)
		return
	if kind == "hydra":
		hydra(p, team)
		_refine(p,kind)
		return
	if kind == "medusa":
		for i in 22:
			var a := i*.40
			var r := .36 * (1.0-i/34.0)
			ball(p, Vector3(cos(a)*r,.15+i*.016,sin(a)*r), Vector3(.14,.11,.14), Color("68785b").darkened(i*.007))
		humanoid(p, team, false, false,Color("66556c"))
		face(p, Vector3(0,1.10,0), Color("a6c494"))
		for i in 9:
			var a := i*TAU/9
			var tip := Vector3(cos(a)*.30,1.34+sin(i*1.7)*.09,sin(a)*.22)
			rod(p, Vector3(0,1.18,0), tip, .06, Color("475b44"))
			ball(p, tip+Vector3(0,.02,.035), Vector3(.07,.065,.10), Color("74815c"))
			ball(p, tip+Vector3(.032,.035,.12), Vector3(.018,.02,.018), Color("ffde73"))
		cone(p, Vector3(0,1.38,0), .075,0,.24,gold)
		rod(p, Vector3(.34,.35,.15), Vector3(.40,1.28,.15), .03, gold)
		ball(p, Vector3(.40,1.31,.15), Vector3(.09,.11,.08), Color("a9b18b"))
		_refine(p,kind)
		return
	var giant := kind in ["minotaur","heracles"]
	humanoid(p, team, giant,true,Color("536951") if kind == "atalanta" else ivory)
	if kind == "minotaur":
		ball(p, Vector3(0,.77,-.04), Vector3(.31,.29,.19), Color("6f594b"))
		face(p, Vector3(0,1.17,0), Color("805147"), true)
		ball(p, Vector3(0,1.06,.23), Vector3(.21,.13,.14), Color("b9896c"))
		for s in [-1,1]:
			ball(p, Vector3(s*.08,1.07,.355), Vector3(.035,.024,.013), leather)
			rod(p, Vector3(s*.20,1.33,0), Vector3(s*.40,1.44,-.03), .07, ivory)
			rod(p, Vector3(s*.40,1.44,-.03), Vector3(s*.39,1.63,.015), .035, ivory)
			ball(p, Vector3(s*.33,.93,0), Vector3(.17,.15,.18), team)
			cone(p, Vector3(s*.33,1.09,0), .07,0,.19,gold)
		rod(p, Vector3(.36,.23,.16), Vector3(.48,1.37,.16), .048, leather)
		for s in [-1,1]:
			var blade := ball(p, Vector3(.48+s*.18,1.23,.16), Vector3(.19,.24,.05), Color("9a9b87"))
			blade.rotation.z = s*.35
		box(p, Vector3(0,.50,.19), Vector3(.35,.13,.05), team)
	elif kind == "heracles":
		face(p, Vector3(0,1.10,.035))
		ball(p, Vector3(0,1.14,-.09), Vector3(.28,.27,.21), Color("8b744c"))
		face(p, Vector3(0,1.10,.095))
		var sculpt := preload("res://presentation/olympus_sculpt.gd").new(self)
		sculpt.profile(p,[[.90,0,0,0,.19],[.97,.11,.07,0,.20],[1.045,.16,.08,0,.18],[1.08,.16,.055,0,.17]],Color("614632"),16)
		for s in [-1,1]:
			ball(p, Vector3(s*.22,1.30,-.02), Vector3(.085,.09,.06), gold)
			ball(p, Vector3(s*.22,.88,-.06), Vector3(.14,.13,.19), Color("8b744c"))
		ball(p, Vector3(0,1.37,.10), Vector3(.18,.09,.17), gold)
		box(p, Vector3(0,1.37,.25), Vector3(.06,.04,.04), leather)
		cape(p, Color("bc8d45"), .39,.65)
		rod(p, Vector3(.36,.47,.15), Vector3(.50,1.40,.12), .08, leather)
		ball(p, Vector3(.48,1.19,.12), Vector3(.17,.33,.16), Color("795136"))
		for i in 3:
			box(p, Vector3(.48,1.03+i*.14,.12), Vector3(.31,.06,.29), bronze)
	elif kind == "atalanta":
		face(p, Vector3(0,1.10,0))
		ball(p, Vector3(0,1.23,-.03), Vector3(.21,.13,.2), Color("72513b"))
		var pony := joint(p,"Ponytail",Vector3(0,1.20,-.18))
		ball(pony,Vector3(0,-.16,-.06),Vector3(.11,.25,.10),Color("72513b"))
		box(p,Vector3(0,1.21,.174),Vector3(.32,.04,.04),gold)
		cape(p,team.darkened(.2),.22,.4)
		rod(p,Vector3(-.18,.54,-.17),Vector3(-.18,1.04,-.20),.085,leather)
		for i in 3:
			rod(p,Vector3(-.23+i*.05,.83,-.20),Vector3(-.23+i*.05,1.28,-.20),.012,ivory)
		for i in 8:
			var a := i*PI/8
			var b := (i+1)*PI/8
			rod(p,Vector3(.34+sin(a)*.23,.23+a*.34,.23),Vector3(.34+sin(b)*.23,.23+b*.34,.23),.028,gold)
		rod(p,Vector3(.34,.23,.23),Vector3(.34,1.30,.23),.009,ivory)
	elif kind in ["harpy","harpies"]:
		face(p,Vector3(0,1.1,0))
		ball(p,Vector3(0,1.24,-.04),Vector3(.20,.15,.18),Color("493b69"))
		for s in [-1,1]:
			var wing := joint(p,"WingL" if s < 0 else "WingR",Vector3(s*.19,.93,-.08))
			rod(wing,Vector3.ZERO,Vector3(s*.43,.22,-.04),.065,team)
			for i in 6:
				var feather := ball(wing,Vector3(s*(.23+i*.095),.12-i*.075,-.09),Vector3(.09,.31-i*.014,.045),ivory if i%2 else Color("d7c6a7"))
				feather.rotation.z = -s*(.65+i*.11)
			for i in 3:
				rod(p,Vector3(s*.13,.11,.10),Vector3(s*.13+(i-1)*.05,.04,.24),.022,gold)
	else:
		face(p,Vector3(0,1.10,0))
		ball(p,Vector3(0,1.21,-.035),Vector3(.22,.18,.21),gold)
		box(p,Vector3(0,1.14,.19),Vector3(.04,.22,.04),gold)
		for s in [-1,1]:
			box(p,Vector3(s*.16,1.06,.14),Vector3(.08,.20,.05),gold).rotation.z=s*.20
		for i in 6:
			ball(p,Vector3(0,1.38+sin(i*PI/6)*.07,-.17+i*.065),Vector3(.055,.10,.06),team)
		cape(p,team,.33,.61)
		var shield := host._cylinder(p,.31,.065,Vector3(-.30,.64,.22),gold) as MeshInstance3D
		shield.rotation.x=PI/2
		ball(p,Vector3(-.30,.64,.263),Vector3(.26,.26,.05),team)
		ball(p,Vector3(-.30,.64,.316),Vector3(.10,.10,.035),gold)
		for i in 8:
			var a := i*TAU/8
			ball(p,Vector3(-.30+cos(a)*.27,.64+sin(a)*.27,.27),Vector3(.022,.022,.02),ivory)
		rod(p,Vector3(.34,.12,.12),Vector3(.34,1.60,.12),.025,leather)
		cone(p,Vector3(.34,1.69,.12),.065,0,.26,Color("d4e4df"))
	_refine(p,kind)

func hydra(p: Node3D, team: Color) -> void:
	var green := Color("52644e")
	ball(p,Vector3(0,.35,0),Vector3(.43,.30,.51),green)
	for s in [-1,1]:
		for z in [-.23,.23]:
			rod(p,Vector3(s*.26,.30,z),Vector3(s*.46,.09,z+.10),.10,green)
			for j in 3:
				rod(p,Vector3(s*.46,.09,z+.10),Vector3(s*.46+(j-1)*.045,.05,z+.25),.023,ivory)
	for j in 5:
		ball(p,Vector3(sin(j*.5)*.17,.26-j*.025,-.40-j*.13),Vector3(.17-j*.025,.12-j*.018,.15),green)
	for i in [-1,0,1]:
		var head := joint(p,"Neck%d" % i,Vector3(i*.19,.46,.14))
		rod(head,Vector3.ZERO,Vector3(i*.11,.39,.04),.10,green)
		rod(head,Vector3(i*.11,.39,.04),Vector3(i*.12,.64,.22),.085,Color("657456"))
		ball(head,Vector3(i*.12,.69,.31),Vector3(.15,.14,.24),Color("798566"))
		box(head,Vector3(i*.12,.64,.51),Vector3(.19,.025,.08),leather)
		for s in [-1,1]:
			ball(head,Vector3(i*.12+s*.10,.75,.42),Vector3(.034,.036,.025),Color("ffe084"))
			cone(head,Vector3(i*.12+s*.09,.88,.22),.035,0,.16,gold)
			cone(head,Vector3(i*.12+s*.065,.60,.51),.02,0,.08,ivory).rotation.x=PI
	box(p,Vector3(0,.61,-.10),Vector3(.40,.07,.30),team)
	for j in 4:
		cone(p,Vector3(0,.66,-.30+j*.14),.075,0,.18,gold)

func _height(y: float) -> float:
	if y < .10: return y
	if y < .55: return .10 + (y-.10)*1.48
	if y < .90: return .766 + (y-.55)
	return 1.116 + (y-.90)*.70

func _refine(figure: Node3D, kind: String) -> void:
	# Reproportion the assembled sculpt and its pivots together. Joint names remain
	# direct children, so the independent walking/attack animator retains its API.
	# Preserve each world transform before changing parents to avoid compounded scale.
	var root_transform := figure.global_transform
	var inverse := root_transform.affine_inverse()
	var records: Array = []
	var pending: Array[Node] = [figure]
	while not pending.is_empty():
		var parent: Node = pending.pop_front()
		for child in parent.get_children():
			if child is Node3D:
				records.append({"node":child,"transform":inverse*child.global_transform})
				pending.append(child)
	for record in records:
		var node: Node3D = record.node
		var original: Transform3D = record.transform
		var height := original.origin.y
		var shaped := original
		if kind == "hydra":
			# Longer necks and narrower heads read as a reptile instead of a plush toy.
			shaped.origin = Vector3(original.origin.x*.90,original.origin.y*1.08,original.origin.z)
			if node is MeshInstance3D:
				shaped.basis = original.basis.scaled(Vector3(.78,.88,.86) if height > 1.0 else Vector3(.9,1.08,1.0))
		else:
			var lateral := .72 if height >= .94 else .86
			shaped.origin = Vector3(original.origin.x*lateral,_height(height),original.origin.z*lateral)
			if node is MeshInstance3D:
				var vertical := .70 if height >= .9 else (1.48 if height > .10 and height < .55 else 1.0)
				shaped.basis = original.basis.scaled(Vector3(lateral,vertical,lateral))
		node.global_transform = root_transform*shaped

func animate(figure: Node3D, phase: float, moving: bool, flying: bool, hit: float, attack := 0.0) -> void:
	var stride := sin(phase*9.0)*(.35 if moving else .035)
	for pair in [["LegL",1.0],["LegR",-1.0],["ArmL",-0.6],["ArmR",0.6]]:
		var limb := figure.get_node_or_null(str(pair[0])) as Node3D
		if limb:
			limb.rotation.x = stride*float(pair[1]) - hit*.8
			if str(pair[0]) == "ArmR": limb.rotation.x -= attack * 1.15
	for s in [-1,1]:
		var wing := figure.get_node_or_null("WingL" if s < 0 else "WingR") as Node3D
		if wing: wing.rotation.z = s*sin(phase*8)*.38
	for i in [-1,0,1]:
		var neck := figure.get_node_or_null("Neck%d" % i) as Node3D
		if neck:
			neck.rotation.z = sin(phase*2+i)*.10
			neck.rotation.x = -attack * (0.35 + abs(i) * 0.08)
	var cloth := figure.get_node_or_null("Cape") as Node3D
	if cloth: cloth.rotation.x = sin(phase*5)*.08 + (.15 if moving else 0.0)
	figure.position.y = (.23 + sin(phase*4)*.07) if flying else abs(stride)*.11
	figure.rotation.x = -hit*.18 - attack*.10
	figure.rotation.z = attack * (-.12 if int(figure.get_meta("kind", "").hash()) % 2 else .12)
