extends RefCounted
## Original display-miniature creatures. Curved anatomy and closed feather meshes.
var f: RefCounted
var sculpt: RefCounted
var bone := Color("b5ad91")
var hide := Color("52634e")
var shadow := Color("293c30")

func _init(factory: RefCounted) -> void:
	f=factory
	sculpt=preload("res://presentation/olympus_sculpt.gd").new(factory)

func tube(parent: Node3D, points: Array, radii: Array, color: Color, segments := 10) -> void:
	var vertices: Array[Vector3] = []
	var widths: Array[float] = []
	vertices.assign(points)
	widths.assign(radii)
	sculpt.tube(parent,vertices,widths,color,segments)

func hydra(p: Node3D, team: Color) -> void:
	# A low reptilian trunk, muscular haunches and a long curved tapering tail.
	sculpt.profile(p,[[.13,0,0,0,-.08],[.17,.25,.38,0,-.08],[.29,.36,.43,0,-.045],[.43,.29,.33,0,0],[.49,.15,.20,0,.04],[.51,0,0,0,.04]],hide,22)
	tube(p,[Vector3(0,.28,-.35),Vector3(.04,.22,-.55),Vector3(.18,.15,-.73),Vector3(.30,.11,-.91),Vector3(.27,.10,-1.10),Vector3(.14,.10,-1.23)],[.145,.12,.08,.047,.023,.001],hide,12)
	for s in [-1,1]:
		for z in [-.25,.19]:
			tube(p,[Vector3(s*.23,.31,z),Vector3(s*.40,.24,z-.05),Vector3(s*.48,.12,z+.035),Vector3(s*.44,.085,z+.17)],[.105,.085,.050,.025],hide,12)
			for j in 3:
				var toe:=Vector3(s*.44+(j-1)*.037,.085,z+.17)
				tube(p,[toe,toe+Vector3((j-1)*.018,-.025,.085),toe+Vector3((j-1)*.025,-.038,.13)],[.020,.011,.001],bone,7)
	for i in [-1,0,1]:
		var neck: Node3D=f.joint(p,"Neck%d"%i,Vector3(i*.15,.39,.16))
		var points: Array[Vector3]=[]
		var radii: Array[float]=[]
		for j in 13:
			var t:=j/12.0
			points.append(Vector3(i*(sin(t*PI*.70)*.22),t*(.75-abs(i)*.055),sin(t*TAU)*.085+t*.10))
			radii.append(lerpf(.10,.045,t))
		tube(neck,points,radii,hide.lightened(.035),14)
		# Segmented ventral plates follow each sinuous neck.
		for j in range(2,12):
			var point: Vector3=points[j]
			_feather(neck,point+Vector3(-.035,0,.059),point+Vector3(.035,.018,.059),.026,Color("899178"),.008)
		var tip: Vector3=points.back()
		var skull: Node3D=f.joint(neck,"Skull",tip)
		skull.rotation.x=PI/2
		# Flattened wedge skull and projecting muzzle; no spherical plush face.
		sculpt.profile(skull,[[-.065,0,0,0,0],[-.05,.073,.064,0,0],[.025,.104,.066,0,0],[.12,.086,.048,0,.010],[.25,.066,.033,0,.016],[.27,0,0,0,.016]],Color("6d7b5e"),16)
		sculpt.profile(skull,[[.025,.076,.024,0,.059],[.11,.071,.020,0,.060],[.23,.058,.016,0,.054],[.255,0,0,0,.052]],hide.darkened(.15),14)
		for s in [-1,1]:
			f.ball(skull,Vector3(s*.082,.063,-.044),Vector3(.018,.025,.010),shadow)
			f.ball(skull,Vector3(s*.083,.070,-.052),Vector3(.006,.012,.005),Color("bfa765"))
			tube(skull,[Vector3(s*.037,-.04,-.04),Vector3(s*.08,-.12,-.065),Vector3(s*.11,-.18,-.12)],[.027,.018,.001],bone,8)
			for tooth in 3:
				var z:=.085+tooth*.045
				tube(skull,[Vector3(s*.064,z,.027),Vector3(s*.060,z+.01,.055)],[.008,.001],bone,6)
			for j in (7 if i == 0 else 0):
				var a:=j*PI/6
				_feather(p,Vector3(s*.10,.46,-.25+j*.069),Vector3(s*.24,.35,-.25+j*.069),.043,hide.lightened(.07+(j%2)*.035),.009)
	for j in 8:
		var z:=-.40+j*.084
		tube(p,[Vector3(0,.43,z),Vector3(0,.55,z-.04),Vector3(0,.58,z-.075)],[.028,.018,.001],bone.darkened(.18),7)
	# Small painted harness marking keeps faction readable without recoloring anatomy.
	tube(p,[Vector3(-.22,.40,-.10),Vector3(0,.49,-.10),Vector3(.22,.40,-.10)],[.016,.017,.016],team.darkened(.15),8)

func harpies(p: Node3D, team: Color) -> void:
	var skin:=Color("aa9279")
	var linen:=Color("b6ad98")
	var plumage:=Color("817966")
	# Fitted classical chiton: shoulder mantle, narrower waist and draped split skirt.
	sculpt.profile(p,[[.52,0,0,0,0],[.53,.19,.125,0,0],[.66,.17,.11,0,0],[.80,.13,.095,0,0],[.92,.17,.12,0,0],[1.05,.18,.10,0,-.015],[1.12,.10,.075,0,-.02],[1.13,0,0,0,-.02]],linen,22)
	for i in 12:
		var a:=i*TAU/12
		tube(p,[Vector3(cos(a)*.131,.79,sin(a)*.097),Vector3(cos(a)*.182,.54,sin(a)*.124)],[.006,.009],linen.darkened(.15),6)
	sculpt.profile(p,[[.78,.137,.100,0,0],[.81,.141,.103,0,0]],team.darkened(.17),20)
	sculpt.profile(p,[[1.08,.055,.057,0,0],[1.22,.05,.05,0,0]],skin,16)
	var head:=f.joint(p,"Head",Vector3(0,1.28,0)) as Node3D
	head.scale=Vector3.ONE*.58
	f.face(head,Vector3.ZERO,skin)
	sculpt.profile(p,[[1.30,.108,.095,0,-.024],[1.39,.097,.091,0,-.024],[1.43,.045,.05,0,-.015],[1.44,0,0,0,-.015]],Color("4d4d44"),20)
	for j in 5:
		_feather(p,Vector3((j-2)*.035,1.37,-.06),Vector3((j-2)*.025,1.12,-.12),.024,Color("55574c"),.01)
	for s in [-1,1]:
		var leg:=f.joint(p,"LegL" if s<0 else "LegR",Vector3(s*.095,.57,0)) as Node3D
		sculpt.profile(leg,[[-.40,.025,.028,0,.036],[-.30,.031,.029,0,.012],[-.20,.041,.038,0,.023],[-.12,.052,.043,0,0],[0,.067,.06,0,0]],skin,14)
		for j in 3:
			tube(leg,[Vector3((j-1)*.018,-.40,.036),Vector3((j-1)*.047,-.43,.12),Vector3((j-1)*.057,-.45,.15)],[.014,.010,.001],Color("756b53"),7)
		var arm:=f.joint(p,"ArmL" if s<0 else "ArmR",Vector3(s*.18,1.04,0)) as Node3D
		tube(arm,[Vector3.ZERO,Vector3(s*.05,-.15,.04),Vector3(s*.03,-.28,.10)],[.050,.037,.025],skin,12)
		f.ball(arm,Vector3(s*.03,-.29,.10),Vector3(.029,.045,.027),skin)
		var wing:=f.joint(p,"WingL" if s<0 else "WingR",Vector3(s*.13,1.06,-.07)) as Node3D
		tube(wing,[Vector3.ZERO,Vector3(s*.22,.17,-.045),Vector3(s*.42,.25,-.04),Vector3(s*.56,.22,-.035)],[.069,.055,.035,.004],plumage,12)
		# Swept pointed primaries form one strong silhouette; secondary coverts overlap.
		for j in 10:
			var t:=j/9.0
			var start:=Vector3(s*(.15+t*.39),.12+t*.08,-.025)
			var end:=Vector3(s*(.34+t*.48),-.28+t*.29,.07)
			_feather(wing,start,end,.067-t*.014,plumage.lightened(.18+(j%3)*.035),.015)
		for j in 8:
			var t:=j/7.0
			_feather(wing,Vector3(s*(.08+t*.37),.09+t*.15,.006),Vector3(s*(.24+t*.34),-.055+t*.15,-.015),.048,plumage.lightened(.25-(j%2)*.045),.012)
		f.ball(p,Vector3(s*.095,1.075,.073),Vector3(.019,.021,.012),f.bronze)

func _feather(p: Node3D, start: Vector3, end: Vector3, width: float, color: Color, thickness: float) -> void:
	# Closed ridged diamond/leaf cross section; sharpened tips avoid capsule feathers.
	var axis: Vector3=(end-start).normalized()
	var across:=axis.cross(Vector3.FORWARD).normalized()
	if across.length_squared()<.01: across=Vector3.RIGHT
	var normal:=axis.cross(across).normalized()
	var middle: Vector3=start.lerp(end,.35)
	var points: Array[Vector3]=[start,middle+across*width,end,middle-across*width,middle+normal*thickness,middle-normal*thickness]
	var mesh:=SurfaceTool.new()
	mesh.begin(Mesh.PRIMITIVE_TRIANGLES)
	for triangle in [[0,1,4],[1,2,4],[2,3,4],[3,0,4],[1,0,5],[2,1,5],[3,2,5],[0,3,5]]:
		for i in triangle: mesh.add_vertex(points[i])
	mesh.generate_normals()
	f._finish(f.host._mesh(p,mesh.commit(),Vector3.ZERO,color),color)
