extends RefCounted
## Original sculpted toy figures. Only presentation; no combat decisions live here.
var host: Node3D
var gold := Color("d6a34e")
var bronze := Color("996237")
var ivory := Color("fff0cf")
var leather := Color("513b31")
var skin := Color("dbae87")

func _init(renderer: Node3D) -> void:
	host = renderer

func ball(p: Node3D, at: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	return host._sphere(p, size, at, color)

func box(p: Node3D, at: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	return host._box(p, size, at, color)

func rod(p: Node3D, a: Vector3, b: Vector3, radius: float, color: Color) -> MeshInstance3D:
	return host._limb(p, a, b, radius, color)

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
	return host._mesh(p, mesh, at, color)

func face(p: Node3D, at: Vector3, color: Color = Color("dbae87"), bull := false) -> void:
	ball(p, at, Vector3(.20,.22,.18) if not bull else Vector3(.27,.26,.21), color)
	for s in [-1,1]:
		ball(p, at + Vector3(s * .075,.03,.165), Vector3(.038,.04,.024), ivory)
		ball(p, at + Vector3(s * .075,.025,.188), Vector3(.019,.027,.014), Color("182833"))
		box(p, at + Vector3(s * .078,.083,.177), Vector3(.095,.028,.028), leather).rotation.z = s * -.16
	ball(p, at + Vector3(0,-.032,.19), Vector3(.045,.048,.04), color.darkened(.09))
	box(p, at + Vector3(0,-.11,.157), Vector3(.07,.018,.026), leather)

func cape(p: Node3D, team: Color, width := .30, length := .54) -> void:
	var cloth := joint(p, "Cape", Vector3(0,.92,-.10))
	for i in 5:
		var strip := box(cloth, Vector3((i-2)*width*.34,-length*.50,-.10-abs(i-2)*.01), Vector3(width*.35,length,.055), team.darkened(abs(i-2)*.035))
		strip.rotation.x = -.23
		ball(cloth, Vector3((i-2)*width*.34,-length,-.17), Vector3(width*.19,.045,.045), gold)

func humanoid(p: Node3D, team: Color, muscular := false, legs := true) -> void:
	if legs:
		for s in [-1,1]:
			var leg := joint(p, "LegL" if s < 0 else "LegR", Vector3(s*.12,.49,0))
			rod(leg, Vector3.ZERO, Vector3(s*.015,-.30,.015), .088 if muscular else .07, skin)
			box(leg, Vector3(s*.015,-.33,.07), Vector3(.17,.13,.26), leather)
			box(leg, Vector3(s*.015,-.19,.074), Vector3(.12,.15,.03), gold)
	ball(p, Vector3(0,.72,0), Vector3(.30 if muscular else .235,.30,.17), skin if muscular else team)
	cone(p, Vector3(0,.49,0), .27,.20,.22, leather if muscular else ivory)
	box(p, Vector3(0,.59,.17), Vector3(.42,.07,.045), gold)
	ball(p, Vector3(0,.59,.2), Vector3(.075,.063,.02), gold.lightened(.2))
	for s in [-1,1]:
		var arm := joint(p, "ArmL" if s < 0 else "ArmR", Vector3(s*.24,.85,0))
		ball(arm, Vector3.ZERO, Vector3(.13,.13,.13), skin if muscular else gold)
		rod(arm, Vector3.ZERO, Vector3(s*.075,-.28,.11), .095 if muscular else .065, skin)
		ball(arm, Vector3(s*.075,-.28,.11), Vector3(.08,.085,.08), skin)

func build(p: Node3D, kind: String, team: Color) -> void:
	p.set_meta("kind", kind)
	if kind == "hydra":
		hydra(p, team)
		return
	if kind == "medusa":
		for i in 22:
			var a := i*.40
			var r := .36 * (1.0-i/34.0)
			ball(p, Vector3(cos(a)*r,.15+i*.016,sin(a)*r), Vector3(.14,.11,.14), Color("429985").darkened(i*.007))
		humanoid(p, team, false, false)
		face(p, Vector3(0,1.10,0), Color("a6c494"))
		for i in 9:
			var a := i*TAU/9
			var tip := Vector3(cos(a)*.30,1.34+sin(i*1.7)*.09,sin(a)*.22)
			rod(p, Vector3(0,1.18,0), tip, .06, Color("286e55"))
			ball(p, tip+Vector3(0,.02,.035), Vector3(.07,.065,.10), Color("5ca773"))
			ball(p, tip+Vector3(.032,.035,.12), Vector3(.018,.02,.018), Color("ffde73"))
		cone(p, Vector3(0,1.38,0), .075,0,.24,gold)
		rod(p, Vector3(.34,.35,.15), Vector3(.40,1.28,.15), .03, gold)
		ball(p, Vector3(.40,1.31,.15), Vector3(.09,.11,.08), Color("90f1c5"))
		return
	var giant := kind in ["minotaur","heracles"]
	humanoid(p, team, giant)
	if kind == "minotaur":
		ball(p, Vector3(0,.77,-.04), Vector3(.39,.34,.24), Color("815346"))
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
			var blade := ball(p, Vector3(.48+s*.18,1.23,.16), Vector3(.19,.24,.05), Color("bbd6d3"))
			blade.rotation.z = s*.35
		box(p, Vector3(0,.50,.19), Vector3(.35,.13,.05), team)
	elif kind == "heracles":
		face(p, Vector3(0,1.10,.035))
		ball(p, Vector3(0,1.14,-.09), Vector3(.28,.27,.21), Color("b58238"))
		face(p, Vector3(0,1.10,.095))
		for s in [-1,1]:
			ball(p, Vector3(s*.22,1.30,-.02), Vector3(.085,.09,.06), gold)
			ball(p, Vector3(s*.22,.88,-.06), Vector3(.14,.13,.19), Color("b58238"))
		ball(p, Vector3(0,1.37,.10), Vector3(.18,.09,.17), gold)
		box(p, Vector3(0,1.37,.25), Vector3(.06,.04,.04), leather)
		cape(p, Color("bc8d45"), .39,.65)
		rod(p, Vector3(.36,.47,.15), Vector3(.50,1.40,.12), .08, leather)
		ball(p, Vector3(.48,1.19,.12), Vector3(.17,.33,.16), Color("795136"))
		for i in 3:
			box(p, Vector3(.48,1.03+i*.14,.12), Vector3(.31,.06,.29), bronze)
	elif kind == "atalanta":
		face(p, Vector3(0,1.10,0))
		ball(p, Vector3(0,1.23,-.03), Vector3(.21,.13,.2), Color("934929"))
		var pony := joint(p,"Ponytail",Vector3(0,1.20,-.18))
		ball(pony,Vector3(0,-.16,-.06),Vector3(.11,.25,.10),Color("934929"))
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

func hydra(p: Node3D, team: Color) -> void:
	var green := Color("347565")
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
		rod(head,Vector3(i*.11,.39,.04),Vector3(i*.12,.64,.22),.085,Color("438976"))
		ball(head,Vector3(i*.12,.69,.31),Vector3(.15,.14,.24),Color("62a486"))
		box(head,Vector3(i*.12,.64,.51),Vector3(.19,.025,.08),leather)
		for s in [-1,1]:
			ball(head,Vector3(i*.12+s*.10,.75,.42),Vector3(.034,.036,.025),Color("ffe084"))
			cone(head,Vector3(i*.12+s*.09,.88,.22),.035,0,.16,gold)
			cone(head,Vector3(i*.12+s*.065,.60,.51),.02,0,.08,ivory).rotation.x=PI
	box(p,Vector3(0,.61,-.10),Vector3(.40,.07,.30),team)
	for j in 4:
		cone(p,Vector3(0,.66,-.30+j*.14),.075,0,.18,gold)

func animate(figure: Node3D, phase: float, moving: bool, flying: bool, hit: float) -> void:
	var stride := sin(phase*9.0)*(.35 if moving else .035)
	for pair in [["LegL",1.0],["LegR",-1.0],["ArmL",-0.6],["ArmR",0.6]]:
		var limb := figure.get_node_or_null(str(pair[0])) as Node3D
		if limb: limb.rotation.x = stride*float(pair[1]) - hit*.8
	for s in [-1,1]:
		var wing := figure.get_node_or_null("WingL" if s < 0 else "WingR") as Node3D
		if wing: wing.rotation.z = s*sin(phase*8)*.38
	for i in [-1,0,1]:
		var neck := figure.get_node_or_null("Neck%d" % i) as Node3D
		if neck: neck.rotation.z = sin(phase*2+i)*.10
	var cloth := figure.get_node_or_null("Cape") as Node3D
	if cloth: cloth.rotation.x = sin(phase*5)*.08 + (.15 if moving else 0.0)
	figure.position.y = (.23 + sin(phase*4)*.07) if flying else abs(stride)*.11
	figure.rotation.x = -hit*.18
