extends RefCounted
## Atalanta: layered hunting chiton, leather equipment and a working bow silhouette.
var f: RefCounted
var sculpt: RefCounted
var skin := Color("b18d6d")
var green := Color("52664a")
var leather := Color("554333")
var hair := Color("70462e")

func _init(factory: RefCounted) -> void:
	f = factory
	sculpt = preload("res://presentation/olympus_sculpt.gd").new(factory)

func build(p: Node3D, team: Color) -> void:
	sculpt.profile(p,[[.54,0,0,0,0],[.54,.22,.15,0,0],[.64,.20,.14,0,0],[.76,.145,.104,0,0],[.85,.15,.109,0,.002],[1.01,.174,.113,0,0],[1.11,.186,.09,0,-.008],[1.16,.065,.06,0,0]],green,24)
	for i in 13:
		var a:=i*TAU/13
		sculpt.tube(p,[Vector3(cos(a)*.148,.76,sin(a)*.107),Vector3(cos(a)*.175,.65,sin(a)*.128),Vector3(cos(a)*.217,.548,sin(a)*.15)],[.006,.008,.010],green.darkened(.10+(i%3)*.025),7)
	# Cross-body leather baldric and a narrow team-colored cloth belt.
	sculpt.tube(p,[Vector3(-.13,1.09,.075),Vector3(-.065,.97,.117),Vector3(.02,.88,.114),Vector3(.113,.77,.067)],[.019,.019,.018,.017],leather,8)
	f.box(p,Vector3(0,.777,.11),Vector3(.278,.036,.025),team)
	f.box(p,Vector3(.03,.776,.13),Vector3(.043,.043,.012),Color("aa8951"))
	for side in [-1,1]:
		var leg:Node3D=f.joint(p,"LegL" if side < 0 else "LegR",Vector3(side*.10,.615,0))
		sculpt.profile(leg,[[-.49,.04,.061,0,.022],[-.43,.036,.035,0,0],[-.34,.050,.043,0,-.008],[-.23,.052,.043,0,.003],[-.16,.044,.043,0,.01],[0,.071,.067,0,0]],skin,16)
		f.ball(leg,Vector3(0,-.513,.06),Vector3(.052,.027,.107),leather)
		for band in 4:
			sculpt.profile(leg,[[-.46+band*.038,.041+band*.002,.04+band*.002,0,0],[-.448+band*.038,.041+band*.002,.04+band*.002,0,0]],leather,12)
		var arm:Node3D=f.joint(p,"ArmL" if side < 0 else "ArmR",Vector3(side*.178,1.09,0))
		var elbow:=Vector3(side*.052,-.12,.084)
		var hand:=Vector3(side*.039,-.20,.22 if side < 0 else .065)
		sculpt.tube(arm,[Vector3.ZERO,elbow,hand],[.051,.039,.028],skin,12)
		f.ball(arm,hand,Vector3(.035,.048,.034),skin)
		sculpt.tube(arm,[elbow.lerp(hand,.30),elbow.lerp(hand,.86)],[.037,.031],leather,12)
		if side < 0: _bow(arm,hand)
	sculpt.profile(p,[[1.11,.049,.050,0,0],[1.23,.05,.053,0,0]],skin,16)
	sculpt.profile(p,[[1.23,0,0,0,.02],[1.253,.059,.063,0,.012],[1.31,.080,.071,0,0],[1.37,.078,.07,0,-.008],[1.414,.061,.052,0,-.012],[1.429,0,0,0,-.012]],skin,20)
	for side in [-1,1]:
		f.box(p,Vector3(side*.033,1.337,.068),Vector3(.035,.009,.009),Color("4b3e32"))
		f.box(p,Vector3(side*.034,1.355,.068),Vector3(.04,.007,.009),hair)
	sculpt.tube(p,[Vector3(0,1.351,.069),Vector3(0,1.317,.084)],[.009,.012],skin,8)
	f.box(p,Vector3(0,1.282,.074),Vector3(.035,.005,.008),Color("885b47"))
	sculpt.profile(p,[[1.34,.082,.068,0,-.020],[1.40,.089,.075,0,-.022],[1.443,.057,.057,0,-.026],[1.456,0,0,0,-.026]],hair,20)
	for side in [-1,1]:
		for strand in 5:
			sculpt.tube(p,[Vector3(side*.014,1.437,-.042+strand*.014),Vector3(side*.075,1.392,-.034+strand*.012),Vector3(side*.074,1.31,-.046+strand*.01)],[.013,.014,.004],hair.lightened((strand%3)*.035),7)
	var pony:Node3D=f.joint(p,"Ponytail",Vector3(0,1.377,-.092))
	sculpt.tube(pony,[Vector3.ZERO,Vector3(.025,-.10,-.045),Vector3(.043,-.24,-.065),Vector3(.018,-.31,-.04)],[.044,.052,.032,.003],hair,12)
	# Small quiver sits behind the shoulder, with individual fletched shafts.
	var quiver:=Node3D.new()
	p.add_child(quiver)
	quiver.position=Vector3(.115,.87,-.142)
	quiver.rotation.z=-.22
	sculpt.profile(quiver,[[0,0,0,0,0],[.015,.060,.047,0,0],[.33,.058,.046,0,0],[.36,.068,.054,0,0]],leather,16)
	for i in 4:
		var x:float=(i-1.5)*.024
		sculpt.tube(quiver,[Vector3(x,.12,0),Vector3(x,.49,0)],[.004,.004],Color("b6a582"),6)
		f.box(quiver,Vector3(x,.45,0),Vector3(.025,.067,.008),Color("b8b19a"))
	f.cape(p,team.darkened(.12),.27,.48)
	p.get_node("Cape").position=Vector3(0,1.10,-.12)

func _bow(arm:Node3D, hand:Vector3) -> void:
	var bow:=Node3D.new()
	arm.add_child(bow)
	bow.name="Bow"
	bow.position=hand
	bow.rotation.z=.13
	sculpt.tube(bow,[Vector3(0,-.50,-.01),Vector3(0,-.39,.07),Vector3(0,-.20,.105),Vector3.ZERO,Vector3(0,.20,.105),Vector3(0,.39,.07),Vector3(0,.50,-.01)],[.005,.012,.018,.021,.018,.012,.005],Color("927044"),10)
	sculpt.tube(bow,[Vector3(0,-.50,-.01),Vector3(0,0,-.14),Vector3(0,.50,-.01)],[.0025,.0025,.0025],Color("c6c1a9"),6)
	sculpt.tube(bow,[Vector3(0,0,-.16),Vector3(0,0,.46)],[.004,.004],Color("c0ad88"),6)
	f.box(bow,Vector3(0,0,-.11),Vector3(.02,.033,.065),Color("c5bda8"))
