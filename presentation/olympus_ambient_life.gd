extends Node3D
## Scenic motion only. Call advance(delta, paused) from the presentation clock.
## No automatic _process: capture fixtures and pause controls own the same clock.
var _clock := 0.0
var _boats: Array[Node3D] = []
var _birds: Array[Node3D] = []
var _pennants: Array[Node3D] = []
var _embers: Array[MeshInstance3D] = []
var _materials: Dictionary = {}

func _ready() -> void:
	name = "AmbientLife"
	for side in [-1, 1]:
		_boat(side)
		for z in [-2.6, 2.6]: _pennant(Vector3(side * 5.72, 0.1, z), z > 0)
		for z in [-6.8, -3.7, 3.7, 6.8]:
			for i in 3:
				var ember := _sphere(self, Vector3(side * 5.38, 0.5, z), Vector3(0.017, 0.033, 0.017), Color("ffb64f"))
				ember.set_meta("origin", ember.position)
				ember.set_meta("base_scale", ember.scale)
				ember.set_meta("phase", float(i) / 3.0 + absf(z) * 0.12)
				_embers.append(ember)
	for i in 3: _bird(i)
	advance(0.0)

func advance(delta: float, paused: bool = false) -> void:
	if paused: return
	_clock += maxf(0.0, delta)
	for i in _boats.size():
		var boat := _boats[i]
		var side := -1.0 if i == 0 else 1.0
		boat.position = Vector3(side * (8.6 + sin(_clock * 0.035 + i) * 0.15), -0.96 + sin(_clock * 1.15 + i * 2.0) * 0.035, side * (-3.4 + sin(_clock * 0.045) * 1.6))
		boat.rotation = Vector3(sin(_clock * 0.85 + i) * 0.035, side * 0.17, sin(_clock + i) * 0.045)
	for i in _birds.size():
		var bird := _birds[i]
		var side := -1.0 if i % 2 == 0 else 1.0
		var phase := _clock * 0.18 + i * 2.1
		bird.position = Vector3(side * (7.0 + sin(phase) * 0.65), 1.8 + sin(phase * 0.7) * 0.18, cos(phase) * 5.0)
		bird.rotation.y = atan2(side * cos(phase) * 0.65, -sin(phase) * 5.0)
		bird.rotation.z = sin(phase) * 0.18
		# A short occasional flap interrupts long, calm glides.
		var flap := sin(_clock * 6.0 + i) * 0.28 if fmod(_clock + i * 3.0, 9.0) < 1.25 else 0.04
		bird.get_node("LeftWing").rotation.z = flap
		bird.get_node("RightWing").rotation.z = -flap
	for i in _pennants.size():
		var ribbon := _pennants[i]
		ribbon.rotation.y = sin(_clock * 1.5 + i) * 0.16
		ribbon.rotation.z = sin(_clock * 2.3 + i * 0.8) * 0.045
	for ember in _embers:
		var phase := fmod(_clock * 0.52 + float(ember.get_meta("phase")), 1.0)
		var origin: Vector3 = ember.get_meta("origin")
		ember.position = origin + Vector3(sin(phase * 8.0 + origin.z) * 0.055, phase * 0.37, phase * 0.075)
		ember.scale = Vector3(ember.get_meta("base_scale")) * (1.0 - phase)
		ember.visible = phase < 0.87

func _boat(side: int) -> void:
	var boat := Node3D.new()
	boat.name = "CoastalBoatWest" if side < 0 else "CoastalBoatEast"
	add_child(boat)
	_boats.append(boat)
	var hull := PrismMesh.new()
	hull.size = Vector3(0.42, 0.29, 1.32)
	var hull_node := _mesh(boat, hull, Vector3.ZERO, Color("75533b"))
	hull_node.rotation.x = PI
	_box(boat, Vector3(0.34, 0.055, 1.01), Vector3(0, 0.04, 0), Color("b18c59"))
	_box(boat, Vector3(0.035, 1.22, 0.035), Vector3(0, 0.60, 0), Color("725640"))
	_box(boat, Vector3(0.74, 0.027, 0.025), Vector3(0, 1.08, 0), Color("725640"))
	var sail := _triangle(boat, Vector3(-0.36, 1.06, 0.015), Vector3(0.35, 1.06, 0.015), Vector3(0.24, 0.20, 0.12), Color("d8d0b7"))
	sail.rotation.y = -0.18
	for i in 3:
		var wake := _box(boat, Vector3(0.26 + i * 0.18, 0.008, 0.027), Vector3(0, -0.02, 0.76 + i * 0.19), Color("7ebbb7"))
		wake.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _bird(index: int) -> void:
	var bird := Node3D.new()
	bird.name = "Gull%d" % index
	add_child(bird)
	_birds.append(bird)
	_sphere(bird, Vector3.ZERO, Vector3(0.036, 0.027, 0.09), Color("d9dfd7"))
	var left := _triangle(bird, Vector3.ZERO, Vector3(-0.24, 0.025, -0.035), Vector3(-0.085, 0, 0.08), Color("d9dfd7"))
	left.name = "LeftWing"
	var right := _triangle(bird, Vector3.ZERO, Vector3(0.085, 0, 0.08), Vector3(0.24, 0.025, -0.035), Color("d9dfd7"))
	right.name = "RightWing"
	_sphere(bird, Vector3(0, 0.012, -0.085), Vector3(0.025, 0.025, 0.036), Color("e6e8d7"))

func _pennant(pos: Vector3, blue: bool) -> void:
	_box(self, Vector3(0.07, 1.40, 0.07), pos + Vector3.UP * 0.7, Color("a5824e"))
	_sphere(self, pos + Vector3.UP * 1.43, Vector3(0.065, 0.065, 0.065), Color("caa25b"))
	var holder := Node3D.new()
	add_child(holder)
	holder.position = pos + Vector3.UP * 1.25
	_pennants.append(holder)
	var direction := -1.0 if pos.x < 0 else 1.0
	var color := Color("367fa0") if blue else Color("ae6658")
	_triangle(holder, Vector3.ZERO, Vector3(direction * 0.43, 0, 0), Vector3(direction * 0.31, -0.52, 0.03), color)
	_triangle(holder, Vector3.ZERO, Vector3(direction * 0.31, -0.52, 0.03), Vector3(0, -0.42, 0), color)
	_box(holder, Vector3(0.37, 0.025, 0.015), Vector3(direction * 0.2, -0.07, 0.018), Color("d5b77a"))

func _material(color: Color) -> StandardMaterial3D:
	if _materials.has(color): return _materials[color]
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.83
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	if color == Color("ffb64f"):
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = 1.1
	_materials[color] = material
	return material

func _triangle(parent: Node3D, a: Vector3, b: Vector3, c: Vector3, color: Color) -> MeshInstance3D:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.add_vertex(a)
	surface.add_vertex(b)
	surface.add_vertex(c)
	surface.generate_normals()
	return _mesh(parent, surface.commit(), Vector3.ZERO, color)

func _box(parent: Node3D, size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	return _mesh(parent, mesh, pos, color)

func _sphere(parent: Node3D, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = 1.0
	mesh.height = 2.0
	mesh.radial_segments = 8
	mesh.rings = 4
	var node := _mesh(parent, mesh, pos, color)
	node.scale = size
	return node

func _mesh(parent: Node3D, mesh: Mesh, pos: Vector3, color: Color) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.material_override = _material(color)
	node.position = pos
	parent.add_child(node)
	return node
