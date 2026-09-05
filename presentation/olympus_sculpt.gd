extends RefCounted
## Hand-shaped mesh profiles for the first detailed Greek infantry miniature.
## All coordinates are local presentation space; animation moves child joints only.
var f: RefCounted
var bronze := Color("977347")
var dark_bronze := Color("574c37")
var linen := Color("bcaf92")
var skin := Color("a67e60")
var leather := Color("493d30")

func _init(factory: RefCounted) -> void:
	f = factory

func profile(parent: Node3D, rings: Array, color: Color, segments := 20) -> MeshInstance3D:
	# Ring: height, X radius, Z radius, X offset, Z offset.
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_smooth_group(0)
	for row in rings.size()-1:
		for step in segments:
			var corners: Array[Vector3] = []
			for pair in [Vector2i(row,step),Vector2i(row,step+1),Vector2i(row+1,step),Vector2i(row+1,step+1)]:
				var r: Array = rings[pair.x]
				var angle := float(pair.y)*TAU/segments
				corners.append(Vector3(cos(angle)*float(r[1])+float(r[3]),float(r[0]),sin(angle)*float(r[2])+float(r[4])))
			for index in [0,1,2,1,3,2]: surface.add_vertex(corners[index])
	surface.generate_normals()
	return _finish(f.host._mesh(parent,surface.commit(),Vector3.ZERO,color),color)

func tube(parent: Node3D, points: Array[Vector3], radii: Array[float], color: Color, segments := 10) -> MeshInstance3D:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_smooth_group(0)
	var rings: Array = []
	for i in points.size():
		var tangent: Vector3 = (points[mini(i+1,points.size()-1)]-points[maxi(i-1,0)]).normalized()
		var axis := Vector3.FORWARD if absf(tangent.dot(Vector3.FORWARD)) < .9 else Vector3.RIGHT
		var u := tangent.cross(axis).normalized()
		var v := tangent.cross(u).normalized()
		var ring: Array[Vector3] = []
		for j in segments:
			var angle := j*TAU/segments
			ring.append(points[i]+(cos(angle)*u+sin(angle)*v)*radii[i])
		rings.append(ring)
	for i in rings.size()-1:
		for j in segments:
			var next := (j+1)%segments
			for point in [rings[i][j],rings[i+1][j],rings[i][next],rings[i][next],rings[i+1][j],rings[i+1][next]]:
				surface.add_vertex(point)
	surface.generate_normals()
	return _finish(f.host._mesh(parent,surface.commit(),Vector3.ZERO,color),color)

func _finish(mesh: MeshInstance3D, color: Color) -> MeshInstance3D:
	f._finish(mesh,color)
	if color == bronze or color == dark_bronze:
		mesh.material_override.metallic = .60
		mesh.material_override.roughness = .48
	return mesh

func hoplite(p: Node3D, team: Color) -> void:
	# Tunic has a flared hem, a pulled waist and shallow folds.
	profile(p,[[.56,0,0,0,0],[.56,.24,.16,0,0],[.65,.22,.145,0,0],[.78,.17,.12,0,0],[.90,.18,.12,0,0],[.91,0,0,0,0]],linen,24)
	for i in 14:
		var a := i*TAU/14
		tube(p,[Vector3(cos(a)*.178,.78,sin(a)*.122),Vector3(cos(a)*.232,.575,sin(a)*.161)],[.008,.013],linen.darkened(.12),6)
	# Anatomical bronze cuirass narrows at the waist, swells at the chest,
	# and turns into a small neck opening instead of a sphere torso.
	profile(p,[[.77,0,0,0,0],[.77,.172,.126,0,0],[.83,.166,.13,0,.005],[.94,.202,.145,0,.005],[1.07,.233,.132,0,-.005],[1.14,.205,.102,0,-.015],[1.18,.084,.077,0,0]],bronze,24)
	for side in [-1,1]:
		tube(p,[Vector3(side*.02,1.03,.145),Vector3(side*.105,1.02,.144),Vector3(side*.188,1.07,.09)],[.007,.009,.006],dark_bronze,8)
		tube(p,[Vector3(side*.15,.84,.071),Vector3(side*.12,.91,.12),Vector3(side*.07,.94,.137)],[.006,.007,.004],dark_bronze,6)
	f.box(p,Vector3(0,.795,.131),Vector3(.31,.035,.021),leather)
	f.box(p,Vector3(0,.795,.146),Vector3(.053,.048,.019),bronze.lightened(.12))
	profile(p,[[1.12,.064,.066,0,0],[1.24,.062,.065,0,0]],skin)
	for side in [-1,1]:
		var leg: Node3D = f.joint(p,"LegL" if side < 0 else "LegR",Vector3(side*.112,.64,0))
		profile(leg,[[-.51,0,0,0,.04],[-.49,.052,.074,0,.04],[-.43,.047,.044,0,.005],[-.33,.061,.051,0,0],[-.22,.064,.054,0,.006],[-.15,.061,.053,0,.007],[0,.085,.077,0,0]],skin,16)
		profile(leg,[[-.46,.048,.047,0,.008],[-.35,.060,.054,0,.002],[-.22,.060,.057,0,.008],[-.18,.055,.051,0,.008]],bronze,16)
		tube(leg,[Vector3(0,-.445,.054),Vector3(0,-.34,.06),Vector3(0,-.20,.062)],[.004,.006,.004],bronze.lightened(.16),6)
		f.ball(leg,Vector3(0,-.525,.053),Vector3(.061,.032,.113),leather)
		for strap in 3: f.box(leg,Vector3(0,-.503,.01+strap*.045),Vector3(.112,.015,.017),bronze.darkened(.18))
		var arm: Node3D = f.joint(p,"ArmL" if side < 0 else "ArmR",Vector3(side*.225,1.095,0))
		tube(arm,[Vector3.ZERO,Vector3(side*.035,-.13,.015),Vector3(side*.025,-.23,.07),Vector3(side*.01,-.29,.115)],[.072,.061,.046,.036],skin,12)
		f.ball(arm,Vector3(side*.01,-.29,.115),Vector3(.043,.055,.040),skin)
		tube(arm,[Vector3(side*.025,-.22,.064),Vector3(side*.012,-.27,.101)],[.049,.041],leather,12)
		if side < 0: shield(arm,team)
		else:
			tube(arm,[Vector3(.01,-.88,.115),Vector3(.01,.56,.115)],[.014,.012],leather,8)
			profile(arm,[[.54,0,0,.01,.115],[.58,.035,.011,.01,.115],[.68,.019,.008,.01,.115],[.79,0,0,.01,.115]],Color("a7aaa0"),8)
	# Small face sits within an enclosing Corinthian helmet.
	profile(p,[[1.22,0,0,0,.028],[1.25,.071,.072,0,.022],[1.30,.086,.079,0,.02],[1.37,.088,.078,0,.012],[1.43,.073,.065,0,0],[1.46,0,0,0,0]],skin)
	profile(p,[[1.33,.104,.094,0,-.015],[1.42,.109,.098,0,-.015],[1.49,.088,.078,0,-.02],[1.53,.04,.046,0,-.022],[1.54,0,0,0,-.022]],bronze,24)
	for side in [-1,1]:
		var cheek := profile(p,[[1.22,.018,.019,side*.078,.066],[1.27,.025,.023,side*.087,.069],[1.34,.034,.026,side*.089,.054],[1.38,.029,.033,side*.087,.04]],bronze,12)
		cheek.rotation.z=side*-.035
		f.box(p,Vector3(side*.041,1.35,.099),Vector3(.047,.019,.012),Color("292b25"))
		f.box(p,Vector3(side*.042,1.371,.101),Vector3(.065,.009,.012),bronze.lightened(.13))
	profile(p,[[1.255,.017,.014,0,.113],[1.32,.012,.019,0,.109],[1.394,.014,.016,0,.094]],bronze,8)
	# Horsehair crest follows the helmet from brow to nape.
	for i in 15:
		var a := float(i)*PI/14
		var z := cos(a)*.115-.02
		var y := 1.48+sin(a)*.064
		tube(p,[Vector3(0,y,z),Vector3(0,y+.105+sin(a)*.035,z*1.13)],[.025,.022],team.darkened(.13+(i%3)*.04),8)
	f.cape(p,team,.35,.65)
	p.get_node("Cape").position=Vector3(0,1.13,-.10)

func shield(arm: Node3D, team: Color) -> void:
	var root := Node3D.new()
	arm.add_child(root)
	root.position=Vector3(-.035,-.24,.14)
	root.rotation.x=-PI/2
	profile(root,[[-.075,0,0,0,0],[-.07,.12,.12,0,0],[-.045,.26,.26,0,0],[0,.315,.315,0,0],[.026,.313,.313,0,0],[.034,.289,.289,0,0],[.005,.245,.245,0,0],[-.015,0,0,0,0]],bronze,32)
	profile(root,[[-.076,0,0,0,0],[-.071,.13,.13,0,0],[-.047,.249,.249,0,0],[-.017,.288,.288,0,0]],team.darkened(.22),32)
	# Embossed owl: curved body, small ears, eye disks and a central beak.
	for side in [-1,1]:
		f.ball(root,Vector3(side*.065,-.086,.066),Vector3(.062,.014,.060),bronze.lightened(.15))
		f.ball(root,Vector3(side*.065,-.103,.066),Vector3(.026,.008,.027),dark_bronze)
		tube(root,[Vector3(side*.115,-.070,.104),Vector3(side*.089,-.083,.146),Vector3(side*.035,-.089,.105)],[.009,.005,.008],bronze.lightened(.12),8)
		tube(root,[Vector3(side*.102,-.075,.018),Vector3(side*.126,-.069,-.063),Vector3(side*.053,-.078,-.133),Vector3(0,-.083,-.10)],[.009,.011,.009,.005],bronze.lightened(.12),8)
	f.ball(root,Vector3(0,-.104,.015),Vector3(.022,.011,.046),bronze.lightened(.2))

func minotaur(p: Node3D, team: Color) -> void:
	f.humanoid(p,team,true)
	var fur := Color("594737")
	var pending: Array[Node] = [p]
	while not pending.is_empty():
		var node: Node = pending.pop_back()
		if node is MeshInstance3D and node.material_override is StandardMaterial3D:
			if node.material_override.albedo_color == f.skin: f._finish(node,fur)
		for child in node.get_children(): pending.append(child)
	profile(p,[[.53,.21,.16,0,0],[.70,.24,.18,0,-.005],[.86,.34,.21,0,-.025],[.98,.32,.20,0,-.04],[1.10,.15,.13,0,-.045]],fur)
	# Forward-set bull skull and long muzzle; horns curve away from the face.
	profile(p,[[.99,.115,.13,0,.015],[1.10,.175,.16,0,.025],[1.23,.195,.17,0,.025],[1.33,.17,.14,0,.005],[1.40,.12,.09,0,-.015],[1.42,0,0,0,0]],fur.darkened(.12))
	var muzzle := Node3D.new()
	p.add_child(muzzle)
	muzzle.position=Vector3(0,1.10,.12)
	muzzle.rotation.x=PI/2
	profile(muzzle,[[0,.13,.10,0,0],[.12,.14,.087,0,0],[.25,.145,.080,0,0],[.28,.125,.066,0,0],[.29,0,0,0,0]],Color("78624b"),16)
	for side in [-1,1]:
		f.ball(p,Vector3(side*.070,1.15,.409),Vector3(.024,.014,.008),Color("251f1b"))
		f.box(p,Vector3(side*.134,1.267,.151),Vector3(.049,.013,.016),Color("be9b56"))
		tube(p,[Vector3(side*.089,1.296,.145),Vector3(side*.145,1.290,.145),Vector3(side*.179,1.267,.102)],[.018,.022,.019],fur.darkened(.28))
		tube(p,[Vector3(side*.148,1.355,-.005),Vector3(side*.265,1.37,-.028),Vector3(side*.367,1.445,-.022),Vector3(side*.407,1.55,.03),Vector3(side*.389,1.61,.075)],[.080,.068,.046,.026,.002],Color("b8ad8c"),12)
		var leg: Node3D = p.get_node("LegL" if side < 0 else "LegR")
		f.box(leg,Vector3(side*.015,-.326,.072),Vector3(.147,.097,.225),Color("2d2b24"))
		f.box(leg,Vector3(side*.015,-.328,.188),Vector3(.012,.07,.01),fur)
	# Fur mantle uses tapered locks instead of spherical shoulder pads.
	for i in 18:
		var a:=i*TAU/18
		var start:=Vector3(cos(a)*.27,.965,sin(a)*.14-.045)
		tube(p,[start,start+Vector3(cos(a)*.046,-.09,sin(a)*.05),start+Vector3(cos(a)*.065,-.16,sin(a)*.065)],[.035,.029,.001],fur.darkened((i%3)*.07),7)
	var axe_arm: Node3D = p.get_node("ArmR")
	tube(axe_arm,[Vector3(.074,-.56,.11),Vector3(.074,.47,.11)],[.026,.026],leather,10)
	# Broad forged blade with a clearly defined cutting edge.
	var blade:=SurfaceTool.new()
	blade.begin(Mesh.PRIMITIVE_TRIANGLES)
	var polygon: Array[Vector2] = [Vector2(-.04,.24),Vector2(.20,.37),Vector2(.35,.40),Vector2(.40,.22),Vector2(.34,.03),Vector2(.21,.05),Vector2(-.04,.17)]
	for side in [-1,1]:
		for i in range(1,polygon.size()-1):
			var ids := [0,i,i+1] if side < 0 else [0,i+1,i]
			for j in ids: blade.add_vertex(Vector3(polygon[j].x+.074,polygon[j].y,.11+side*.035))
	for i in polygon.size():
		var a: Vector2=polygon[i]
		var b: Vector2=polygon[(i+1)%polygon.size()]
		for point in [Vector3(a.x,a.y,-.035),Vector3(b.x,b.y,-.035),Vector3(a.x,a.y,.035),Vector3(b.x,b.y,-.035),Vector3(b.x,b.y,.035),Vector3(a.x,a.y,.035)]:
			blade.add_vertex(point+Vector3(.074,0,.11))
	blade.generate_normals()
	f._finish(f.host._mesh(axe_arm,blade.commit(),Vector3.ZERO,Color("737873")),Color("737873"))
	for side in [-1,1]:
		tube(p,[Vector3(side*.12,.79,.17),Vector3(side*.20,.63,.155)],[.024,.020],team,8)
	f._refine(p,"minotaur")
