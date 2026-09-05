extends Node3D
## Persistent visual replicas of authoritative arena snapshots.
const PALETTE = preload("res://themes/olympus_arena_theme.tres")
var camera: Camera3D
var _tokens: Dictionary = {}
var _towers: Dictionary = {}
var _materials: Dictionary = {}
var _preview: MeshInstance3D
var _time := 0.0

func _ready() -> void:
	_setup()
	get_viewport().msaa_3d = Viewport.MSAA_4X

func _setup() -> void:
	if camera != null: return
	camera = Camera3D.new()
	add_child(camera)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 20.3
	camera.position = Vector3(0, 20, 13.8)
	camera.look_at(Vector3(0, 0, 0))
	camera.current = true
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("182937")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("c5d9e5")
	env.ambient_light_energy = 0.62
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world.environment = env
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -35, 0)
	sun.light_color = Color("fff0cf")
	sun.light_energy = 1.6
	sun.shadow_enabled = true
	add_child(sun)
	_box(self, Vector3(11.5, 0.65, 18.3), Vector3(0, -0.5, 0), Color("34414a"))
	_box(self, Vector3(11.25, 0.15, 18.05), Vector3(0, -0.18, 0), PALETTE.gold)
	_box(self, Vector3(11, 0.16, 17.8), Vector3(0, -0.06, 0), PALETTE.marble)
	for side in [-1, 1]:
		_box(self, Vector3(10, 0.1, 7.4), Vector3(0, 0.035, side * 4.5), PALETTE.grass)
		for x in [-2.7, 2.7]:
			_box(self, Vector3(1.4, 0.025, 6.7), Vector3(x, 0.10, side * 4.0), Color("a6ab8b"))
		for x in [-4.65, 4.65]:
			for z in range(2, 8, 2):
				_cylinder(self, 0.23, 0.3, Vector3(x, 0.22, side * z), PALETTE.stone)
				_cylinder(self, 0.10, 0.7, Vector3(x, 0.7, side * z), PALETTE.marble)
				_sphere(self, Vector3(0.16, 0.16, 0.16), Vector3(x, 1.1, side * z), PALETTE.gold)
	_box(self, Vector3(10.7, 0.12, 1.55), Vector3(0, 0.01, 0), PALETTE.water)
	for x in range(-5, 6):
		_box(self, Vector3(0.45, 0.012, 0.025), Vector3(x, 0.085, 0.3 * sin(x)), Color("80d6d9"))
	for x in [-2.7, 2.7]:
		_box(self, Vector3(1.8, 0.22, 2.0), Vector3(x, 0.16, 0), PALETTE.marble)
		for z in [-0.7, -0.35, 0.0, 0.35, 0.7]:
			_box(self, Vector3(1.64, 0.02, 0.02), Vector3(x, 0.285, z), PALETTE.stone)
		for edge in [-0.85, 0.85]:
			_box(self, Vector3(0.12, 0.38, 2), Vector3(x + edge, 0.36, 0), PALETTE.stone)
	# Repeated meander blocks form an original, physical border rather than a texture.
	for z in range(-17, 18):
		for x in [-5.27, 5.27]:
			_box(self, Vector3(0.22, 0.025, 0.22), Vector3(x, 0.035, z * 0.48), PALETTE.roof)
			_box(self, Vector3(0.12, 0.03, 0.12), Vector3(x + 0.05, 0.045, z * 0.48 + 0.04), PALETTE.marble)
	_preview = _cylinder(self, 0.6, 0.035, Vector3.ZERO, Color(0.3, 0.8, 1, 0.5))
	_preview.visible = false

func show_state(state: Dictionary, delta: float = 0.0) -> void:
	_setup()
	_time += delta
	var alive := {}
	for unit in state.get("units", []):
		var id = unit["id"]
		alive[id] = true
		if not _tokens.has(id):
			_tokens[id] = _make_unit(str(unit.get("kind", "hoplites")), int(unit["side"]))
		var node: Node3D = _tokens[id]
		var target := Vector3(float(unit["x"]), 0.12, float(unit["z"]))
		var previous: Vector3 = node.position
		node.position = target
		if previous.distance_to(target) > 0.004:
			node.get_node("Figure").rotation.y = atan2(target.x - previous.x, target.z - previous.z)
			node.get_node("Figure").position.y = abs(sin(_time * 9 + int(id))) * 0.045
		_health(node, float(unit["hp"]) / maxf(1.0, float(unit.get("max_hp", unit["hp"]))))
	for id in _tokens.keys():
		if not alive.has(id):
			_tokens[id].queue_free()
			_tokens.erase(id)
	for tower in state.get("towers", []):
		var id = tower["id"]
		if not _towers.has(id): _towers[id] = _make_tower(tower)
		var node: Node3D = _towers[id]
		node.visible = float(tower["hp"]) > 0
		_health(node, float(tower["hp"]) / maxf(1.0, float(tower.get("max_hp", tower["hp"]))))

func pick_ground(screen: Vector2, _viewport_size: Vector2 = Vector2.ZERO) -> Vector2:
	_setup()
	var hit = Plane(Vector3.UP, 0.12).intersects_ray(camera.project_ray_origin(screen), camera.project_ray_normal(screen))
	if hit == null or abs(hit.x) > 5.0 or abs(hit.z) > 8.0: return Vector2.INF
	return Vector2(hit.x, hit.z)

func show_deployment(position: Vector2, valid: bool, spell: bool = false) -> void:
	_setup()
	_preview.visible = position.is_finite()
	if not _preview.visible: return
	_preview.position = Vector3(position.x, 0.32, position.y)
	_preview.scale = Vector3(2.3 if spell else 1.0, 1, 2.3 if spell else 1.0)
	_preview.material_override = _material(Color(0.2, 0.8, 1, 0.55) if valid else Color(1, 0.2, 0.15, 0.5))

func clear_preview() -> void:
	if _preview: _preview.visible = false

func _make_tower(data: Dictionary) -> Node3D:
	var node := Node3D.new()
	add_child(node)
	node.position = Vector3(float(data["x"]), 0.1, float(data["z"]))
	var team: Color = PALETTE.player if int(data["side"]) == 0 else PALETTE.enemy
	var temple: bool = str(data.get("kind", "tower")) == "temple"
	var width := 2.2 if temple else 1.35
	_box(node, Vector3(width + 0.3, 0.18, 1.8), Vector3(0, 0.1, 0), PALETTE.stone)
	_box(node, Vector3(width, 0.15, 1.55), Vector3(0, 0.27, 0), PALETTE.marble)
	if temple:
		_box(node, Vector3(1.35, 1.1, 0.85), Vector3(0, 0.9, 0.1), PALETTE.marble)
		_box(node, Vector3(0.55, 0.8, 0.04), Vector3(0, 0.75, 0.55), team)
	for x in [-width * 0.38, width * 0.38]:
		for z in [-0.53, 0.53]:
			_cylinder(node, 0.19, 0.14, Vector3(x, 0.4, z), PALETTE.stone)
			_cylinder(node, 0.13, 0.94, Vector3(x, 0.93, z), PALETTE.marble)
			_box(node, Vector3(0.35, 0.14, 0.35), Vector3(x, 1.46, z), PALETTE.stone)
	_box(node, Vector3(width + 0.15, 0.22, 1.55), Vector3(0, 1.66, 0), team)
	for sign_x in [-1, 1]:
		var roof := _box(node, Vector3(width * 0.59, 0.12, 1.68), Vector3(sign_x * width * 0.24, 1.92, 0), PALETTE.roof)
		roof.rotation.z = sign_x * -0.35
	_sphere(node, Vector3(0.15, 0.15, 0.15), Vector3(0, 2.18, 0), PALETTE.gold)
	_add_health(node, 2.5, 1.4, team)
	return node

func _make_unit(kind: String, side: int) -> Node3D:
	var node := Node3D.new()
	add_child(node)
	var team: Color = PALETTE.player if side == 0 else PALETTE.enemy
	_cylinder(node, 0.37, 0.1, Vector3(0, 0.035, 0), team)
	var figure := Node3D.new()
	figure.name = "Figure"
	node.add_child(figure)
	figure.rotation.y = PI if side == 0 else 0
	var skin := Color("cf9f75")
	var bronze := Color("b68b43")
	var size := 1.2 if kind in ["heracles", "minotaur", "hydra"] else 0.9
	figure.scale = Vector3.ONE * size
	if kind == "hydra":
		_sphere(figure, Vector3(0.38, 0.3, 0.48), Vector3(0, 0.37, 0), Color("497c63"))
		for i in [-1, 0, 1]:
			_limb(figure, Vector3(i * 0.14, 0.4, 0), Vector3(i * 0.25, 0.9, 0.25), 0.09, Color("497c63"))
			_sphere(figure, Vector3(0.13, 0.12, 0.22), Vector3(i * 0.25, 0.98, 0.32), Color("6eaa73"))
			_sphere(figure, Vector3(0.025, 0.03, 0.025), Vector3(i * 0.25 - 0.08, 1.03, 0.46), Color("ffd769"))
	else:
		var body_color: Color = Color("71604c") if kind == "minotaur" else team
		_sphere(figure, Vector3(0.22, 0.3, 0.15), Vector3(0, 0.55, 0), body_color)
		for x in [-0.11, 0.11]:
			_limb(figure, Vector3(x, 0.4, 0), Vector3(x, 0.1, 0.04), 0.07, skin)
			_box(figure, Vector3(0.12, 0.1, 0.21), Vector3(x, 0.1, 0.08), Color("594c42"))
		_sphere(figure, Vector3(0.16, 0.18, 0.15), Vector3(0, 0.97, 0), skin)
		_limb(figure, Vector3(-0.18, 0.72, 0), Vector3(-0.3, 0.5, 0.12), 0.065, skin)
		_limb(figure, Vector3(0.18, 0.72, 0), Vector3(0.3, 0.55, 0.18), 0.065, skin)
		match kind:
			"hoplites", "hoplite":
				_sphere(figure, Vector3(0.18, 0.13, 0.16), Vector3(0, 1.06, 0), bronze)
				_box(figure, Vector3(0.045, 0.14, 0.22), Vector3(0, 1.19, 0), team)
				var shield := _cylinder(figure, 0.25, 0.055, Vector3(-0.25, 0.56, 0.16), bronze)
				shield.rotation.x = PI / 2
				_sphere(figure, Vector3(0.08, 0.08, 0.035), Vector3(-0.25, 0.56, 0.21), team)
				_limb(figure, Vector3(0.28, 0.13, 0.12), Vector3(0.28, 1.48, 0.12), 0.025, Color("6d503b"))
				_sphere(figure, Vector3(0.05, 0.13, 0.035), Vector3(0.28, 1.5, 0.12), PALETTE.marble)
			"atalanta":
				_sphere(figure, Vector3(0.17, 0.11, 0.18), Vector3(0, 1.08, -0.03), Color("763f2c"))
				for j in 5:
					_limb(figure, Vector3(0.3 + sin(j * PI / 5) * 0.15, 0.3 + j * 0.14, 0.17), Vector3(0.3 + sin((j + 1) * PI / 5) * 0.15, 0.3 + (j + 1) * 0.14, 0.17), 0.025, bronze)
				_limb(figure, Vector3(0.3, 0.3, 0.17), Vector3(0.3, 1, 0.17), 0.01, PALETTE.marble)
			"heracles":
				_sphere(figure, Vector3(0.25, 0.22, 0.21), Vector3(0, 1.0, -0.07), Color("aa7732"))
				_sphere(figure, Vector3(0.13, 0.14, 0.08), Vector3(0, 0.96, 0.13), skin)
				_limb(figure, Vector3(0.28, 0.5, 0.1), Vector3(0.4, 1.3, 0.1), 0.11, Color("755135"))
			"minotaur":
				_sphere(figure, Vector3(0.23, 0.21, 0.2), Vector3(0, 1, 0), Color("775341"))
				_sphere(figure, Vector3(0.16, 0.11, 0.15), Vector3(0, 0.92, 0.18), Color("ab8262"))
				for x in [-1, 1]:
					_limb(figure, Vector3(x * 0.17, 1.09, 0), Vector3(x * 0.34, 1.23, 0), 0.045, PALETTE.marble)
					_limb(figure, Vector3(x * 0.34, 1.23, 0), Vector3(x * 0.32, 1.38, 0), 0.024, PALETTE.marble)
			"medusa":
				for j in 7:
					var angle := j * TAU / 7
					_limb(figure, Vector3(0, 1.0, 0), Vector3(cos(angle) * 0.26, 1.17 + sin(angle) * 0.12, sin(angle) * 0.15), 0.045, Color("49835c"))
			"harpies", "harpy":
				for x in [-1, 1]:
					for j in 4:
						_limb(figure, Vector3(x * 0.18, 0.72, 0), Vector3(x * (0.48 + j * 0.055), 1.1 - j * 0.15, -0.12), 0.045, Color("ded2b3"))
	_add_health(node, 1.95 if size > 1 else 1.65, 0.78, team)
	return node

func _add_health(node: Node3D, height: float, width: float, color: Color) -> void:
	var holder := Node3D.new()
	holder.name = "Health"
	node.add_child(holder)
	holder.position.y = height
	holder.rotation = camera.rotation
	_box(holder, Vector3(width + 0.045, 0.12, 0.03), Vector3.ZERO, Color("142d3a"))
	var fill := _box(holder, Vector3(width, 0.075, 0.04), Vector3(0, 0, 0.025), color)
	fill.name = "Fill"
	fill.set_meta("width", width)

func _health(node: Node3D, fraction: float) -> void:
	var fill: MeshInstance3D = node.get_node("Health/Fill")
	fraction = clampf(fraction, 0.0, 1.0)
	fill.scale.x = maxf(0.001, fraction)
	fill.position.x = (fraction - 1.0) * float(fill.get_meta("width")) / 2

func _material(color: Color) -> StandardMaterial3D:
	if _materials.has(color): return _materials[color]
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.78
	if color.a < 1:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_materials[color] = mat
	return mat

func _mesh(parent: Node3D, mesh: Mesh, at: Vector3, color: Color) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.position = at
	instance.material_override = _material(color)
	parent.add_child(instance)
	return instance

func _box(parent: Node3D, size: Vector3, at: Vector3, color: Color) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	return _mesh(parent, mesh, at, color)

func _cylinder(parent: Node3D, radius: float, height: float, at: Vector3, color: Color) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 16
	return _mesh(parent, mesh, at, color)

func _sphere(parent: Node3D, scale_value: Vector3, at: Vector3, color: Color) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = 1
	mesh.height = 2
	mesh.radial_segments = 12
	mesh.rings = 6
	var node := _mesh(parent, mesh, at, color)
	node.scale = scale_value
	return node

func _limb(parent: Node3D, from: Vector3, to: Vector3, radius: float, color: Color) -> MeshInstance3D:
	var mesh := _cylinder(parent, radius, from.distance_to(to), (from + to) / 2, color)
	var direction := (to - from).normalized()
	if abs(direction.dot(Vector3.UP)) < 0.999:
		mesh.quaternion = Quaternion(Vector3.UP, direction)
	return mesh
