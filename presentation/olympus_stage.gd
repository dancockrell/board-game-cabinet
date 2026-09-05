extends Node3D
## Presentation-only scenery. Never owns combat, placement, or navigation state.
const WATER = preload("res://presentation/olympus_water.gdshader")
const PAVING = preload("res://presentation/olympus_paving.gdshader")
const IVORY = Color("e3d4b4")
const SAND = Color("b9a487")
const BRONZE = Color("c29551")
const BLUE = Color("26799a")
const RED = Color("bd6353")
var _materials: Dictionary = {}

func _ready() -> void:
	name = "OlympusStage"
	_foundation()
	_field()
	_river()
	for x in [-2.7, 2.7]: _bridge(x)
	_borders()
	_gardens()

func _foundation() -> void:
	# Floating, stepped limestone plinth with a dark carved undercut.
	_box(Vector3(11.9, 0.42, 18.7), Vector3(0, -1.12, 0), Color("263c49"))
	_box(Vector3(12.3, 0.17, 19.1), Vector3(0, -0.84, 0), SAND)
	_box(Vector3(11.95, 0.42, 18.8), Vector3(0, -0.58, 0), Color("8d806e"))
	_box(Vector3(12.15, 0.10, 19.0), Vector3(0, -0.32, 0), BRONZE)
	_box(Vector3(11.8, 0.17, 18.65), Vector3(0, -0.20, 0), IVORY)
	_box(Vector3(11.4, 0.16, 18.25), Vector3(0, -0.075, 0), SAND)
	for side in [-1, 1]:
		for i in range(-8, 9):
			_box(Vector3(0.12, 0.26, 0.07), Vector3(i * 0.64, -0.53, side * 9.42), BRONZE)
		for i in range(-14, 15):
			_box(Vector3(0.07, 0.26, 0.12), Vector3(side * 5.99, -0.53, i * 0.62), BRONZE)

func _field() -> void:
	for side in [-1, 1]:
		var field := _box(Vector3(10.25, 0.10, 7.5), Vector3(0, 0.025, side * 4.55), IVORY)
		var paving := ShaderMaterial.new()
		paving.shader = PAVING
		paving.set_shader_parameter("stone_color", Color("9eae99") if side == 1 else Color("b3ac94"))
		field.material_override = paving
		for x in [-2.7, 2.7]:
			var lane := _box(Vector3(1.65, 0.025, 6.95), Vector3(x, 0.086, side * 4.35), IVORY)
			var lane_mat := ShaderMaterial.new()
			lane_mat.shader = PAVING
			lane_mat.set_shader_parameter("stone_color", IVORY)
			lane_mat.set_shader_parameter("block_size", 0.55)
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
	water.material_override = material
	for side in [-1, 1]:
		_box(Vector3(10.9, 0.15, 0.16), Vector3(0, 0.06, side * 0.88), SAND)
		_box(Vector3(10.9, 0.045, 0.10), Vector3(0, 0.16, side * 0.88), IVORY)
		# Water spills out through the sides of the island.
		var fall := _box(Vector3(0.06, 0.78, 1.45), Vector3(side * 5.72, -0.35, 0), Color.WHITE)
		fall.material_override = material

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
			_cylinder(0.29, 0.32, pos + Vector3.UP * 0.13, Color("a77153"))
			_cylinder(0.32, 0.065, pos + Vector3.UP * 0.31, Color("cb9370"))
			_cylinder(0.04, 0.45, pos + Vector3.UP * 0.54, Color("766c49"))
			for layer in 3:
				_sphere(Vector3(0.22 - layer * 0.035, 0.40, 0.22 - layer * 0.035), pos + Vector3.UP * (0.73 + layer * 0.26), Color("496e57").lightened(layer * 0.045))
		for x in [-4.2, 4.2]:
			var pos := Vector3(x, 0.02, side * 8.65)
			_box(Vector3(1.2, 0.23, 0.68), pos + Vector3.UP * 0.10, SAND)
			_box(Vector3(1.12, 0.025, 0.60), pos + Vector3.UP * 0.23, Color("56684b"))
			for i in 5:
				_sphere(Vector3(0.18, 0.13, 0.20), pos + Vector3((i-2)*0.22, 0.31, 0), Color("708566"))

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

func _medallion(pos: Vector3, radius: float, color: Color) -> void:
	_cylinder(radius, 0.018, pos, SAND)
	_cylinder(radius * 0.92, 0.025, pos + Vector3.UP * 0.004, IVORY)
	for i in 12:
		var angle := TAU * i / 12.0
		var chip := _box(Vector3(0.11, 0.016, 0.25), pos + Vector3(cos(angle)*radius*0.73, 0.025, sin(angle)*radius*0.73), color)
		chip.rotation.y = -angle + PI / 2.0
	_cylinder(radius * 0.40, 0.027, pos + Vector3.UP * 0.012, color)
	_cylinder(radius * 0.29, 0.03, pos + Vector3.UP * 0.017, IVORY)

func _material(color: Color) -> StandardMaterial3D:
	if _materials.has(color): return _materials[color]
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.83
	if color == BRONZE:
		material.metallic = 0.55
		material.roughness = 0.32
	_materials[color] = material
	return material

func _box(size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	return _mesh(mesh, pos, color)

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
