extends RefCounted
## Complete miniature Greek sanctuary architecture; no gameplay ownership.
var host: Node3D
const STONE := Color("9c9380")
const TRIM := Color("b5ab96")
const SHADOW := Color("302f28")
const CLAY := Color("946547")
const BRONZE := Color("76613c")
func _init(presenter: Node3D) -> void: host = presenter

func build(node: Node3D, temple: bool, team: Color) -> void:
	var width := 2.2 if temple else 1.35
	var depth := 1.62
	for step in 3:
		_box(node,Vector3(width+.5-step*.15,.105,depth+.5-step*.16),Vector3(0,.06+step*.105,0),STONE.lightened(step*.025))
	# Enclosed cella, with an actual doorway through the front wall.
	var cella := 1.23 if temple else .68
	_box(node,Vector3(cella,.99,.11),Vector3(0,.86,-.31),STONE.darkened(.12))
	for side in [-1,1]:
		_box(node,Vector3(.10,.99,.74),Vector3(side*cella*.5,.86,0),STONE)
		_box(node,Vector3((cella-.37)*.5,.99,.12),Vector3(side*(cella+.37)*.25,.86,.38),STONE)
		_box(node,Vector3(.07,.82,.17),Vector3(side*.215,.79,.405),TRIM)
	_box(node,Vector3(.5,.16,.18),Vector3(0,1.275,.41),TRIM)
	_box(node,Vector3(cella-.12,.88,.018),Vector3(0,.79,-.24),SHADOW)
	_box(node,Vector3(.32,.68,.025),Vector3(0,.715,-.20),Color("544734"))
	for side in [-1,1]:
		_box(node,Vector3(.009,.63,.018),Vector3(side*.075,.72,-.18),BRONZE)
	# Peristyle columns: four on watch shrines, eight on the main sanctuary.
	var xs := [-width*.38,width*.38]
	if temple: xs = [-width*.40,-width*.135,width*.135,width*.40]
	for x in xs:
		for z in [-.62,.62]: _column(node,Vector3(x,.325,z))
	_box(node,Vector3(width+.16,.12,depth),Vector3(0,1.475,0),TRIM)
	_box(node,Vector3(width+.11,.19,depth-.02),Vector3(0,1.625,0),STONE)
	_box(node,Vector3(width+.26,.065,depth+.13),Vector3(0,1.756,0),TRIM)
	# Triglyphs and small dentils read as relief, not coloured stickers.
	for side in [-1,1]:
		var count := 9 if temple else 6
		for i in count:
			var x := (float(i)/(count-1)-.5)*width
			_box(node,Vector3(.074,.125,.027),Vector3(x,1.628,side*(depth*.5+.012)),TRIM.darkened(.09))
			for groove in [-1,1]:
				_box(node,Vector3(.009,.104,.008),Vector3(x+groove*.021,1.628,side*(depth*.5+.029)),STONE.darkened(.19))
		for i in count*2:
			_box(node,Vector3(.038,.033,.06),Vector3((float(i)/(count*2-1)-.5)*(width+.1),1.79,side*.845),TRIM)
	_roof(node,width+.31,1.87,temple)
	# Hung linen standards occupy the porch, keeping the roof silhouette classical.
	for side in [-1,1]:
		var x: float = side*width*.38
		_box(node,Vector3(.032,.34,.032),Vector3(x,1.32,.75),BRONZE)
		_box(node,Vector3(.17,.34,.018),Vector3(x,1.12,.758),team.darkened(.15))
		_box(node,Vector3(.17,.019,.021),Vector3(x,.96,.761),BRONZE)
	if temple:
		_box(node,Vector3(.32,.12,.24),Vector3(0,.41,.72),STONE)
		var bowl = host._cylinder(node,.115,.085,Vector3(0,.51,.72),BRONZE)
		bowl.material_override = host._weathered_material(BRONZE)
		# A restrained votive flame; no giant glowing sphere.
		host._sphere(node,Vector3(.044,.09,.044),Vector3(0,.595,.72),Color("db9e52"))

func _column(node: Node3D, pos: Vector3) -> void:
	_box(node,Vector3(.30,.065,.30),pos+Vector3.UP*.035,STONE)
	var rings := [[.065,.115],[.13,.12],[.19,.105],[.40,.11],[.73,.099],[.94,.085],[.99,.087],[1.02,.123],[1.055,.145],[1.09,.145]]
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for row in rings.size()-1:
		for i in 32:
			var points: Array[Vector3] = []
			for pair in [Vector2i(row,i),Vector2i(row,i+1),Vector2i(row+1,i),Vector2i(row+1,i+1)]:
				var angle: float = pair.y*TAU/32.0
				var radius: float = rings[pair.x][1]
				if pair.x in [2,3,4,5,6]: radius *= .95+.05*cos(angle*16.0)
				points.append(pos+Vector3(cos(angle)*radius,rings[pair.x][0],sin(angle)*radius))
			for index in [0,1,2,1,3,2]: surface.add_vertex(points[index])
	surface.generate_normals()
	var column = host._mesh(node,surface.commit(),Vector3.ZERO,TRIM)
	column.material_override = host._weathered_material(TRIM)
	_box(node,Vector3(.32,.06,.32),pos+Vector3.UP*1.12,TRIM)

func _roof(node: Node3D, width: float, depth: float, temple: bool) -> void:
	var eave := 1.81
	var rise := .39
	var half := width*.5
	var angle := atan2(rise,half)
	for side in [-1,1]:
		# Solid triangular tympanum closes the gap beneath both gables.
		var surface := SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		var z: float = side*(depth*.5-.04)
		var points := [Vector3(-half,eave,z),Vector3(half,eave,z),Vector3(0,eave+rise,z)]
		var order := [0,2,1] if side == 1 else [0,1,2]
		for i in order: surface.add_vertex(points[i])
		surface.generate_normals()
		var gable = host._mesh(node,surface.commit(),Vector3.ZERO,STONE.darkened(.12))
		gable.material_override = host._weathered_material(STONE.darkened(.12))
		for slope in [-1,1]:
			var cornice = _box(node,Vector3(sqrt(half*half+rise*rise)+.035,.057,.10),Vector3(slope*half*.5,eave+rise*.5,z+side*.02),TRIM)
			cornice.rotation.z = -slope*angle
		# Carved central shield and two low relief reclining forms.
		var boss = host._cylinder(node,.074,.022,Vector3(0,eave+.145,z+side*.014),TRIM)
		boss.rotation.x = PI/2
		boss.material_override = host._weathered_material(TRIM)
		for s in [-1,1]:
			var relief = host._sphere(node,Vector3(.16,.027,.015),Vector3(s*half*.34,eave+.07,z+side*.018),TRIM.darkened(.05))
			relief.rotation.z = -s*.14
			relief.material_override = host._weathered_material(TRIM)
	for side in [-1,1]:
		var pitch := sqrt(half*half+rise*rise)
		var deck = _box(node,Vector3(pitch,.045,depth),Vector3(side*half*.5,eave+rise*.5+.025,0),CLAY.darkened(.18))
		deck.rotation.z = -side*angle
		var courses := 4 if temple else 3
		for course in courses:
			var fraction := (course+.5)/courses
			for row in 10:
				var tile = _box(node,Vector3(pitch/courses+.026,.027,depth/10.0-.011),Vector3(side*half*fraction,eave+rise*(1.0-fraction)+.059+(courses-course)*.005,(row-4.5)*depth/10.0),CLAY.lightened(float((row+course*3)%5)*.016))
				tile.rotation.z = -side*angle
		# Raised imbrices run down the roof over the pan-tile joints.
		for row in 11:
			var cover = host._cylinder(node,.025,pitch,Vector3(side*half*.5,eave+rise*.5+.083,(row-5)*depth/10.0),CLAY.lightened(.065))
			cover.rotation.z = PI/2.0-side*angle
			cover.material_override = host._weathered_material(CLAY.lightened(.065))
	for row in 11:
		var ridge = host._cylinder(node,.05,depth/11.0+.016,Vector3(0,eave+rise+.062,(row-5)*depth/11.0),CLAY.lightened(.07))
		ridge.rotation.x = PI/2.0
		ridge.material_override = host._weathered_material(CLAY.lightened(.07))

func _box(parent: Node3D, size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
	var box: MeshInstance3D = host._box(parent,size,pos,color)
	box.material_override = host._weathered_material(color)
	return box
