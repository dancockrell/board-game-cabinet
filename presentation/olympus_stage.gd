extends Node3D
## Presentation-only scenery. Never owns combat, placement, or navigation state.
const ROCK = preload("res://themes/olympus_shared_rock.tres")
const WATER = preload("res://presentation/olympus_water.gdshader")
const PIXEL_PAVING = preload("res://themes/olympus_pixel_paving.tres")
const STONE = preload("res://presentation/olympus_limestone.gdshader")
const IVORY = Color("989184")
const SAND = Color("7c715f")
const BRONZE = Color("655432")
const BLUE = Color("456879")
const RED = Color("945c4d")
var _materials: Dictionary = {}
var _box_meshes: Dictionary = {}
var _water_materials: Array[ShaderMaterial] = []
var _water_time := 0.0

func advance_visual(delta: float) -> void:
	_water_time += maxf(delta, 0.0)
	for material in _water_materials:
		material.set_shader_parameter("animation_time", _water_time)

func _ready() -> void:
	name = "OlympusStage"
	_sea()
	_foundation()
	_field()
	_river()
	for x in [-2.7, 2.7]: _bridge(x)
	_borders()
	_gardens()

func _foundation() -> void:
	# Floating, stepped limestone plinth with a dark carved undercut.
	_box(Vector3(11.9, 0.42, 18.7), Vector3(0, -1.12, 0), Color("4b4b43"))
	_box(Vector3(12.3, 0.17, 19.1), Vector3(0, -0.84, 0), SAND)
	_box(Vector3(11.95, 0.42, 18.8), Vector3(0, -0.58, 0), Color("817966"))
	_box(Vector3(12.15, 0.10, 19.0), Vector3(0, -0.32, 0), SAND)
	_box(Vector3(11.8, 0.17, 18.65), Vector3(0, -0.20, 0), IVORY)
	_box(Vector3(11.4, 0.16, 18.25), Vector3(0, -0.075, 0), SAND)
	for side in [-1, 1]:
		for i in range(-8, 9):
			_box(Vector3(0.12, 0.26, 0.07), Vector3(i * 0.64, -0.53, side * 9.42), SAND)
		for i in range(-14, 15):
			_box(Vector3(0.07, 0.26, 0.12), Vector3(side * 5.99, -0.53, i * 0.62), SAND)

func _field() -> void:
	for side in [-1, 1]:
		var field := _box(Vector3(10.25, 0.10, 7.5), Vector3(0, 0.025, side * 4.55), IVORY)
		field.material_override = PIXEL_PAVING
		for x in [-2.7, 2.7]:
			var lane := _box(Vector3(1.65, 0.025, 6.95), Vector3(x, 0.086, side * 4.35), IVORY)
			var lane_mat := PIXEL_PAVING.duplicate()
			lane_mat.set_shader_parameter("tint", Color(0.72, 0.77, 0.70))
			lane.material_override = lane_mat
			for edge in [-0.86, 0.86]:
				_box(Vector3(0.04, 0.026, 6.95), Vector3(x + edge, 0.09, side * 4.35), SAND)
		# Radial mosaics remain subordinate to troop silhouettes.
		_medallion(Vector3(0, 0.09, side * 3.5), 1.03, BLUE if side == 1 else RED)
		_box(Vector3(9.8, 0.02, 0.065), Vector3(0, 0.087, side * 7.95), BRONZE)

func _river() -> void:
	_box(Vector3(11.3, 0.16, 1.64), Vector3(0, -0.035, 0), Color("175362"))
	var water := _box(Vector3(11.4, 0.04, 1.52), Vector3(0, 0.045, 0), Color.WHITE)
	var material := ShaderMaterial.new()
	material.shader = WATER
	material.set_shader_parameter("deep_color", Color("14383d"))
	material.set_shader_parameter("shallow_color", Color("305a59"))
	material.set_shader_parameter("river", true)
	material.set_shader_parameter("caustic_strength", 0.30)
	_water_materials.append(material)
	water.material_override = material
	for side in [-1, 1]:
		_box(Vector3(10.9, 0.15, 0.16), Vector3(0, 0.06, side * 0.88), SAND)
		_box(Vector3(10.9, 0.045, 0.10), Vector3(0, 0.16, side * 0.88), IVORY)
		# Water spills out through the sides of the island.
		var fall := _box(Vector3(0.06, 0.78, 1.45), Vector3(side * 5.72, -0.35, 0), Color.WHITE)
		var fall_material := material.duplicate() as ShaderMaterial
		fall_material.set_shader_parameter("waterfall", true)
		_water_materials.append(fall_material)
		fall.material_override = fall_material

func _bridge(x: float) -> void:
	_box(Vector3(1.82, 0.12, 2.12), Vector3(x, 0.105, 0), SAND)
	for i in 7:
		_box(Vector3(1.76, 0.045, 0.285), Vector3(x, 0.19, (i - 3) * 0.30), IVORY.lightened(0.015 * (i % 3)))
	for edge in [-1, 1]:
		for z in [-0.92, 0.92]:
			_box(Vector3(0.24, 0.50, 0.24), Vector3(x + edge * 0.97, 0.28, z), SAND)
			_box(Vector3(0.32, 0.08, 0.32), Vector3(x + edge * 0.97, 0.56, z), IVORY)
			_sphere(Vector3(0.075, 0.10, 0.075), Vector3(x + edge * 0.97, 0.65, z), BRONZE)
		_box(Vector3(0.10, 0.11, 1.62), Vector3(x + edge * 0.97, 0.48, 0), IVORY)
		for z in [-0.56, 0.0, 0.56]:
			_cylinder(0.045, 0.25, Vector3(x + edge * 0.97, 0.32, z), BRONZE)
		# A segmented arch gives the underside a real bridge silhouette.
		for i in 9:
			var angle := PI * float(i) / 8.0
			var block := _box(Vector3(0.19, 0.20, 0.30), Vector3(x + edge * 0.88, -0.31 + sin(angle) * 0.34, cos(angle) * 0.76), SAND)
			block.rotation.x = PI / 2.0 - angle

func _borders() -> void:
	for side in [-1, 1]:
		_box(Vector3(0.46, 0.055, 17.9), Vector3(side * 5.40, 0.035, 0), IVORY)
		_box(Vector3(0.04, 0.03, 17.9), Vector3(side * 5.14, 0.07, 0), BRONZE)
		for i in range(-16, 17):
			var z := i * 0.53
			if absf(z) < 1.0: continue
			_box(Vector3(0.23, 0.025, 0.23), Vector3(side * 5.40, 0.072, z), BLUE if z > 0 else RED)
			_box(Vector3(0.12, 0.03, 0.12), Vector3(side * 5.40 + 0.05, 0.078, z + 0.04), IVORY)
		for z in [-8.55, 8.55]:
			_column(Vector3(side * 5.37, 0.08, z))
		for z in [-6.8, -3.7, 3.7, 6.8]:
			_box(Vector3(0.38, 0.23, 0.38), Vector3(side * 5.38, 0.17, z), SAND)
			_cylinder(0.19, 0.13, Vector3(side * 5.38, 0.34, z), BRONZE)
			var flame := _sphere(Vector3(0.08, 0.16, 0.08), Vector3(side * 5.38, 0.47, z), Color("ffc87c"))
			var glow := StandardMaterial3D.new()
			glow.albedo_color = Color("ffd493")
			glow.emission_enabled = true
			glow.emission = Color("ff9d45")
			glow.emission_energy_multiplier = 1.2
			flame.material_override = glow

func _gardens() -> void:
	for side in [-1, 1]:
		for z in [-7.8, -5.3, 5.3, 7.8]:
			var pos := Vector3(side * 5.70, 0.05, z)
			_cylinder(0.29, 0.32, pos + Vector3.UP * 0.13, Color("895d47"))
			_cylinder(0.32, 0.065, pos + Vector3.UP * 0.31, Color("ac8062"))
			_cylinder(0.04, 0.45, pos + Vector3.UP * 0.54, Color("766c49"))
			for layer in 5:
				var width := 0.21 - layer * 0.028
				var crown := _sphere(Vector3(width, 0.30, width * 0.91), pos + Vector3(sin(layer*2.0)*0.035, 0.61+layer*0.20,cos(layer)*0.035), Color("47553e").lightened(layer * 0.015))
				crown.rotation.y = layer * 1.1
				for twig in 3:
					var angle := twig*TAU/3.0 + layer*1.3
					_sphere(Vector3(width*.57,.15,width*.46), crown.position + Vector3(cos(angle)*width*.6,.02,sin(angle)*width*.6), Color("596448").darkened(layer*.02))
		for x in [-4.2, 4.2]:
			var pos := Vector3(x, 0.02, side * 8.65)
			_box(Vector3(1.2, 0.23, 0.68), pos + Vector3.UP * 0.10, SAND)
			_box(Vector3(1.12, 0.025, 0.60), pos + Vector3.UP * 0.23, Color("56684b"))
			for i in 5:
				var shrub := _sphere(Vector3(0.17 + (i%2)*0.04, 0.12 + (i%3)*0.025, 0.18), pos + Vector3((i-2)*0.22, 0.30 + sin(i*2.1)*0.025, sin(i)*0.06), Color("72785a").darkened((i%3)*0.04))
				shrub.rotation = Vector3(.1*i,i*.91,.08*i)

func _column(pos: Vector3) -> void:
	_box(Vector3(0.65, 0.15, 0.65), pos, SAND)
	_cylinder(0.23, 0.11, pos + Vector3.UP * 0.11, IVORY)
	_cylinder(0.16, 1.02, pos + Vector3.UP * 0.65, IVORY)
	for i in 8:
		var angle := TAU * i / 8.0
		_cylinder(0.025, 0.89, pos + Vector3(cos(angle)*0.154, 0.65, sin(angle)*0.154), SAND.lightened(0.12))
	_cylinder(0.23, 0.12, pos + Vector3.UP * 1.21, IVORY)
	_box(Vector3(0.48, 0.10, 0.48), pos + Vector3.UP * 1.31, IVORY)
	_sphere(Vector3(0.14, 0.18, 0.14), pos + Vector3.UP * 1.48, BRONZE)

func _medallion(pos: Vector3, radius: float, _color: Color) -> void:
	var medallion := MeshInstance3D.new()
	medallion.name = "OwlInlayPlayer" if pos.z > 0 else "OwlInlayRival"
	var plane := PlaneMesh.new()
	plane.size = Vector2.ONE * radius * 2.0
	medallion.mesh = plane
	medallion.material_override = preload("res://themes/olympus_owl_inlay.tres")
	medallion.position = pos + Vector3.UP * 0.03
	medallion.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(medallion)

func _material(color: Color) -> ShaderMaterial:
	if _materials.has(color): return _materials[color]
	var material := ShaderMaterial.new()
	material.shader = STONE
	material.set_shader_parameter("base_color", color)
	material.set_shader_parameter("surface_roughness", 0.89)
	material.set_shader_parameter("wear_strength", 0.19)
	if color == BRONZE:
		material.set_shader_parameter("metalness", 0.68)
		material.set_shader_parameter("surface_roughness", 0.53)
		material.set_shader_parameter("wear_strength", 0.3)
	_materials[color] = material
	return material

func _box(size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
	# Shared lightly chamfered masonry: real edge highlights instead of sharp toy cubes.
	if not _box_meshes.has(size): _box_meshes[size] = _beveled_box(size)
	return _mesh(_box_meshes[size], pos, color)

func _beveled_box(size: Vector3) -> ArrayMesh:
	var half := size * 0.5
	var bevel := minf(0.035, minf(size.x, minf(size.y, size.z)) * 0.18)
	var inset := half - Vector3.ONE * bevel
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for axis in 3:
		var u := (axis + 1) % 3
		var v := (axis + 2) % 3
		for sign_ in [-1, 1]:
			var points: Array[Vector3] = []
			for pair in [Vector2(-1,-1),Vector2(1,-1),Vector2(1,1),Vector2(-1,1)]:
				var point := Vector3.ZERO
				point[axis] = half[axis] * sign_
				point[u] = inset[u] * pair.x
				point[v] = inset[v] * pair.y
				points.append(point)
			_face(surface, points)
		# Four bevel strips parallel to this axis.
		for su in [-1,1]:
			for sv in [-1,1]:
				var points: Array[Vector3] = []
				for pair in [Vector2(-1,0),Vector2(1,0),Vector2(1,1),Vector2(-1,1)]:
					var point := Vector3.ZERO
					point[axis] = inset[axis] * pair.x
					point[u] = (half[u] if pair.y == 0 else inset[u]) * su
					point[v] = (inset[v] if pair.y == 0 else half[v]) * sv
					points.append(point)
				_face(surface, points)
	for x in [-1,1]:
		for y in [-1,1]:
			for z in [-1,1]:
				var signs := Vector3(x,y,z)
				var points: Array[Vector3] = []
				for axis in 3:
					var point := inset
					point[axis] = half[axis]
					points.append(point * signs)
				_face(surface, points)
	return surface.commit()

func _face(surface: SurfaceTool, points: Array[Vector3]) -> void:
	var normal := (points[1]-points[0]).cross(points[2]-points[0]).normalized()
	var center := Vector3.ZERO
	for point in points: center += point
	if normal.dot(center) < 0:
		points.reverse()
		normal = -normal
	# Godot front faces use clockwise vertex winding.
	for i in range(1, points.size()-1):
		for index in [0,i+1,i]:
			surface.set_normal(normal)
			surface.add_vertex(points[index])

func _cylinder(radius: float, height: float, pos: Vector3, color: Color) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 20
	return _mesh(mesh, pos, color)

func _sphere(size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = 1.0
	mesh.height = 2.0
	mesh.radial_segments = 12
	mesh.rings = 6
	var node := _mesh(mesh, pos, color)
	node.scale = size
	return node

func _mesh(mesh: Mesh, pos: Vector3, color: Color) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.material_override = _material(color)
	node.position = pos
	add_child(node)
	return node

func _sea() -> void:
	var sea := _box(Vector3(65,0.1,65),Vector3(0,-1.75,0),Color("18566a"))
	var material := ShaderMaterial.new()
	material.shader = WATER
	material.set_shader_parameter("caustic_strength",0.13)
	material.set_shader_parameter("deep_color",Color("071a24"))
	material.set_shader_parameter("shallow_color",Color("14363b"))
	_water_materials.append(material)
	sea.material_override = material
	# Uneven outcrops, not a necklace of identically spaced stones.
	var clusters := [Vector3(-7.15,-1.45,-6.4),Vector3(-7.35,-1.48,5.8),Vector3(7.35,-1.46,-2.6),Vector3(7.0,-1.46,8.4)]
	var rng := RandomNumberGenerator.new()
	rng.seed = 84027
	for group in clusters.size():
		for i in (5 if group % 2 == 0 else 4):
			var rock := MeshInstance3D.new()
			var shape := SphereMesh.new()
			shape.radial_segments = 7
			shape.rings = 4
			rock.mesh = shape
			var size_ := 1.0 if i == 0 else rng.randf_range(0.28,0.69)
			rock.scale = Vector3(1.75,0.93,2.1) * size_
			rock.rotation = Vector3(rng.randf_range(-.3,.3),rng.randf_range(0,TAU),rng.randf_range(-.2,.2))
			var offset := Vector3.ZERO if i == 0 else Vector3(rng.randf_range(-.45,.65),rng.randf_range(-.08,.02),rng.randf_range(-1.2,1.25))
			rock.position = clusters[group] + offset
			rng.randf_range(0.0,0.12) # Preserve the seeded layout sequence.
			rock.material_override = ROCK
			rock.add_to_group("olympus_coastal_rocks")
			add_child(rock)
