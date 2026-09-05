extends Node3D
## A snapshot renderer. Only already-observed units may enter this scene.
const PALETTE = preload("res://themes/ninth_gate_3d.tres")
var camera: Camera3D
var _terrain: Node3D
var _pieces: Node3D
var _overlays: Node3D
var _view: Dictionary = {}
var _tokens: Dictionary = {}
var _tweens: Array[Tween] = []
var _materials: Dictionary = {}

func _ready() -> void:
	_setup()
	get_viewport().msaa_3d = Viewport.MSAA_4X

func _setup() -> void:
	if camera != null: return
	camera = Camera3D.new()
	add_child(camera)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 8.4
	camera.position = Vector3(0.5, 10, 13)
	camera.rotation = Vector3(-atan2(10.0, 13.05), atan2(0.5, 13.05), 0)
	camera.current = true
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("192725")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("b3c7bf")
	env.ambient_light_energy = 0.35
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	world.environment = env
	add_child(world)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-52, -28, 0)
	light.light_color = Color("fff0d3")
	light.light_energy = 0.72
	light.shadow_enabled = true
	light.directional_shadow_max_distance = 35
	add_child(light)
	_terrain = Node3D.new()
	_pieces = Node3D.new()
	_overlays = Node3D.new()
	add_child(_terrain)
	add_child(_pieces)
	add_child(_overlays)
	var plinth := _box(self, Vector3(13.1, 0.45, 9.1), Vector3(0, -0.55, 0), PALETTE.wood)
	var wood := ShaderMaterial.new()
	wood.shader = preload("res://presentation/wood.gdshader")
	wood.set_shader_parameter("wood_color", Color("5d4334"))
	wood.set_shader_parameter("grain_strength", 0.3)
	plinth.material_override = wood
	_box(self, Vector3(12.9, 0.07, 8.9), Vector3(0, -0.29, 0), Color("ac8952"))
	_box(self, Vector3(12.6, 0.22, 8.6), Vector3(0, -0.16, 0), Color("46534a"))
	# A carved plinth and corner studs keep the map a tangible tabletop object.
	for x in [-6.28, 6.28]:
		for z in [-4.28, 4.28]: _cylinder(self, 0.07, 0.035, Vector3(x, -0.02, z), PALETTE.heaven_trim)
	for x in 12:
		_label(self, char(65 + x), Vector3(x - 5.5, -0.025, 4.24), 27, Color("c9c2a2"), 0.008)
	for y in 8:
		_label(self, str(y + 1), Vector3(-6.25, -0.025, y - 3.5), 27, Color("c9c2a2"), 0.008)
	_scenery()

func _mat(color: Color, metallic: float = 0.0, glow: bool = false) -> StandardMaterial3D:
	var key := str(color) + str(metallic) + str(glow)
	if _materials.has(key): return _materials[key]
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = 0.72
	result.metallic = metallic
	if glow:
		result.emission_enabled = true
		result.emission = color
		result.emission_energy_multiplier = 0.6
	_materials[key] = result
	return result

func _mesh(parent: Node3D, mesh: Mesh, at: Vector3, color: Color, metallic: float = 0.0) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.material_override = _mat(color, metallic)
	node.position = at
	parent.add_child(node)
	return node

func _box(parent: Node3D, dimensions: Vector3, at: Vector3, color: Color) -> MeshInstance3D:
	var shape := BoxMesh.new()
	shape.size = dimensions
	return _mesh(parent, shape, at, color)

func _cylinder(parent: Node3D, radius: float, height: float, at: Vector3, color: Color, top: float = -1.0) -> MeshInstance3D:
	var shape := CylinderMesh.new()
	shape.top_radius = radius if top < 0 else top
	shape.bottom_radius = radius
	shape.height = height
	shape.radial_segments = 12
	return _mesh(parent, shape, at, color)

func _sphere(parent: Node3D, radius: float, at: Vector3, color: Color) -> MeshInstance3D:
	var shape := SphereMesh.new()
	shape.radius = radius
	shape.height = radius * 2
	shape.radial_segments = 12
	shape.rings = 6
	return _mesh(parent, shape, at, color)

func _bar(parent: Node3D, a: Vector3, b: Vector3, radius: float, color: Color) -> void:
	var node := _cylinder(parent, radius, a.distance_to(b), (a+b)/2.0, color)
	var direction := (b-a).normalized()
	if absf(direction.dot(Vector3.UP)) < 0.999:
		node.quaternion = Quaternion(Vector3.UP, direction)

func _ring(parent: Node3D, at: Vector3, radius: float, color: Color, thickness: float = 0.035) -> void:
	var shape := TorusMesh.new()
	shape.inner_radius = radius - thickness
	shape.outer_radius = radius + thickness
	shape.rings = 32
	shape.ring_segments = 8
	var node := _mesh(parent, shape, at, color)
	node.material_override = _mat(color, 0.15, true)

func _label(parent: Node3D, text: String, at: Vector3, font_size: int, color: Color, pixel_size: float = 0.009) -> void:
	var label := Label3D.new()
	label.text = text
	label.position = at
	label.rotation_degrees.x = -90
	label.font_size = font_size
	label.pixel_size = pixel_size
	label.modulate = color
	label.outline_size = 0
	parent.add_child(label)

func _clear(parent: Node3D) -> void:
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()

func _point(x: int, y: int) -> Vector3:
	return Vector3(x - 5.5, 0.05, y - 3.5)

func show_view(view: Dictionary, animate: bool = false) -> void:
	_setup()
	for tween in _tweens:
		if tween.is_valid(): tween.kill()
	_tweens.clear()
	var previous: Dictionary = {}
	for id in _tokens: previous[id] = _tokens[id].position
	_view = view.duplicate(true)
	_clear(_terrain)
	_clear(_pieces)
	_clear(_overlays)
	_tokens.clear()
	var visible: Array = view.get("visible_cells", [])
	for y in 8:
		for x in 12:
			var index: int = y * 12 + x
			var kind: String = view.terrain[index]
			var at := _point(x, y)
			var observed: bool = visible.has(index)
			var color: Color = PALETTE.grass if (x + y) % 2 == 0 else PALETTE.grass_alternate
			if not observed: color = color.lerp(PALETTE.unseen, 0.67)
			if kind == "river" or kind == "bridge":
				_box(_terrain, Vector3(0.98, 0.07, 0.98), at - Vector3(0, 0.055, 0), PALETTE.river if observed else PALETTE.river.darkened(0.35))
				for ripple in 3:
					_box(_terrain, Vector3(0.34, 0.008, 0.018), at + Vector3(0.13 * sin(y + ripple), -0.012, ripple * 0.24 - 0.25), Color("8ab9ab") if observed else Color("4d7979"))
			else:
				var tile := _box(_terrain, Vector3(0.98, 0.11, 0.98), at - Vector3(0, 0.055, 0), color)
				var grass := ShaderMaterial.new()
				grass.shader = preload("res://assets/ninth_gate/terrain.gdshader")
				grass.set_shader_parameter("surface_color", color)
				tile.material_override = grass
			if kind == "bridge": _bridge(at)
			elif kind == "wood": _trees(at, observed)
			elif kind == "hill":
				for i in 3:
					var rock := _sphere(_terrain, 0.15 + i * 0.025, at + Vector3(0.22 + 0.09 * (i % 2), 0.07, -0.29 + i*0.2), PALETTE.stone if observed else PALETTE.stone.darkened(0.4))
					rock.scale = Vector3(1, 0.55 + i * 0.12, 0.9)
	for site in view.sites:
		var color: Color = PALETTE.heaven_trim if site.owner == "heaven" else (PALETTE.hell_trim if site.owner == "hell" else Color("d7d6b6"))
		var at := _point(site.x, site.y)
		_ring(_terrain, at + Vector3(0, 0.16, 0), 0.38, color, 0.022)
		_cylinder(_terrain, 0.027, 0.6, at + Vector3(-0.47, 0.4, -0.35), color)
		_box(_terrain, Vector3(0.23, 0.15, 0.02), at + Vector3(-0.36, 0.6, -0.35), color)
	for unit in view.units:
		var token := _token(unit)
		_pieces.add_child(token)
		var at := _point(unit.x, unit.y)
		if view.terrain[unit.y * 12 + unit.x] == "bridge": at.y += 0.12
		token.position = at
		_tokens[unit.id] = token
		if animate and previous.has(unit.id) and previous[unit.id].distance_to(at) > 0.01:
			token.position = previous[unit.id]
			var tween := create_tween()
			tween.tween_property(token, "position", at, 0.48).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
			_tweens.append(tween)

func _bridge(at: Vector3) -> void:
	_box(_terrain, Vector3(1.02, 0.14, 0.71), at + Vector3(0, 0.035, 0), PALETTE.stone)
	for x in [-0.39, 0.39]:
		for z in [-0.36, 0.36]:
			_box(_terrain, Vector3(0.18, 0.28, 0.14), at + Vector3(x, 0.09, z), PALETTE.stone.darkened(0.13))
	for z in [-0.36, 0.36]: _box(_terrain, Vector3(0.95, 0.1, 0.08), at + Vector3(0, 0.19, z), PALETTE.stone.lightened(0.1))
	for x in [-0.32, 0, 0.32]: _box(_terrain, Vector3(0.014, 0.012, 0.65), at + Vector3(x, 0.112, 0), PALETTE.stone.darkened(0.2))

func _trees(at: Vector3, observed: bool) -> void:
	for i in 3:
		var offset := Vector3(-0.3 + i * 0.28, 0, -0.31)
		_cylinder(_terrain, 0.035, 0.3, at + offset + Vector3(0, 0.15, 0), Color("695746"))
		for layer in 2:
			_cylinder(_terrain, 0.16 - layer * 0.025, 0.28, at + offset + Vector3(0, 0.35 + layer * 0.16, 0), Color("395e50") if observed else Color("314c45"), 0)

func _token(unit: Dictionary) -> Node3D:
	var node := Node3D.new()
	node.name = str(unit.id)
	var heaven: bool = unit.side == "heaven"
	var body: Color = PALETTE.heaven if heaven else PALETTE.hell
	var trim: Color = PALETTE.heaven_trim if heaven else PALETTE.hell_trim
	_cylinder(node, 0.30, 0.075, Vector3(0, 0.04, 0), trim)
	_cylinder(node, 0.27, 0.05, Vector3(0, 0.095, 0), body.darkened(0.18))
	# Low-poly ceremonial miniatures: robe, shoulders, helmet and role silhouette.
	_cylinder(node, 0.15, 0.31, Vector3(0, 0.29, 0), body, 0.085)
	_sphere(node, 0.095, Vector3(0, 0.53, 0), body)
	_box(node, Vector3(0.29, 0.095, 0.12), Vector3(0, 0.405, 0), trim)
	_box(node, Vector3(0.1, 0.035, 0.035), Vector3(0, 0.54, 0.086), Color("364653") if heaven else trim)
	if heaven:
		_ring(node, Vector3(0, 0.7, 0), 0.105, trim, 0.015)
	else:
		for sign_value in [-1, 1]:
			var horn := _cylinder(node, 0.038, 0.18, Vector3(sign_value * 0.082, 0.645, 0), trim, 0)
			horn.rotation.z = -sign_value * 0.37
	match str(unit.role):
		"guard":
			var shield := _cylinder(node, 0.145, 0.045, Vector3(-0.16, 0.33, 0.11), trim)
			shield.rotation.x = PI / 2
			_box(node, Vector3(0.025, 0.19, 0.013), Vector3(-0.16, 0.33, 0.137), body)
			_bar(node, Vector3(0.18, 0.18, 0), Vector3(0.18, 0.57, 0), 0.026, trim)
		"spear":
			_bar(node, Vector3(0.2, 0.12, 0), Vector3(0.2, 0.84, 0), 0.018, trim)
			_cylinder(node, 0.06, 0.19, Vector3(0.2, 0.89, 0), body, 0)
		"archer":
			for i in 8:
				var a: float = -1.3 + i * 2.6 / 8
				var b: float = -1.3 + (i+1) * 2.6 / 8
				_bar(node, Vector3(0.15 + cos(a)*0.15, 0.39 + sin(a)*0.23, 0.035), Vector3(0.15 + cos(b)*0.15, 0.39 + sin(b)*0.23, 0.035), 0.018, trim)
			_bar(node, Vector3(0.19, 0.17, 0.035), Vector3(0.19, 0.61, 0.035), 0.006, body)
		"herald":
			for sign_value in [-1, 1]:
				for feather in 3:
					var wing := _box(node, Vector3(0.075, 0.36 - feather * 0.035, 0.035), Vector3(sign_value * (0.16 + feather*0.06), 0.46 + feather*0.045, -0.06), body if heaven else trim)
					wing.rotation.z = -sign_value * (0.3 + feather*0.14)
	# Health is visible on the front edge at ordinary play distance.
	for i in int(unit.max_hp):
		var active: bool = i < int(unit.hp)
		_box(node, Vector3(0.064, 0.028, 0.06), Vector3((i - (unit.max_hp-1)/2.0)*0.075, 0.13, 0.26), trim if active else Color("39423e"))
	var identity := Label3D.new()
	identity.text = ("H" if heaven else "D") + str(int(str(unit.id).trim_prefix(str(unit.side))) + 1)
	identity.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	identity.position = Vector3(0, 0.24, 0.38)
	identity.font_size = 28
	identity.pixel_size = 0.0055
	identity.modulate = Color("fff2cd") if heaven else Color("ffd2c1")
	identity.outline_modulate = Color("28312f")
	identity.outline_size = 7
	node.add_child(identity)
	return node

func show_orders(orders: Array, selected_id: String, legal_orders: Array, cursor: Vector2i = Vector2i(-1, -1)) -> void:
	_setup()
	_clear(_overlays)
	if _view.is_empty(): return
	for order in legal_orders:
		if order.type not in ["move", "attack", "heal"]: continue
		var color: Color = PALETTE.move if order.type == "move" else (PALETTE.attack if order.type == "attack" else PALETTE.heal)
		_ring(_overlays, _point(order.x, order.y) + Vector3(0, 0.2, 0), 0.41, color, 0.024)
	if _tokens.has(selected_id):
		var unit: Dictionary = {}
		for candidate in _view.units:
			if candidate.id == selected_id: unit = candidate
		if not unit.is_empty(): _ring(_overlays, _point(unit.x, unit.y) + Vector3(0, 0.24, 0), 0.34, PALETTE.heaven_trim, 0.04)
	for order in orders:
		var unit: Dictionary = {}
		for candidate in _view.units:
			if candidate.id == order.unit_id: unit = candidate
		if unit.is_empty(): continue
		var a := _point(unit.x, unit.y) + Vector3(0, 0.26, 0)
		var b := _point(order.x, order.y) + Vector3(0, 0.26, 0)
		var color: Color = PALETTE.attack if order.type == "attack" else PALETTE.move
		if a.distance_to(b) > 0.1:
			_bar(_overlays, a, b, 0.025, color)
			var direction := (b-a).normalized()
			var sideways := Vector3(-direction.z, 0, direction.x)
			_bar(_overlays, b, b-direction*0.2+sideways*0.13, 0.025, color)
			_bar(_overlays, b, b-direction*0.2-sideways*0.13, 0.025, color)
		else: _ring(_overlays, a, 0.4, PALETTE.heal, 0.035)
	if cursor.x >= 0 and cursor.x < 12 and cursor.y >= 0 and cursor.y < 8:
		_ring(_overlays, _point(cursor.x, cursor.y) + Vector3(0, 0.28, 0), 0.46, Color("f4f1d3"), 0.013)

func pick_cell(screen_position: Vector2, viewport_size: Vector2) -> Vector2i:
	_setup()
	if screen_position.x < 0 or screen_position.y < 0 or screen_position.x >= viewport_size.x or screen_position.y >= viewport_size.y: return Vector2i(-1, -1)
	var hit = Plane(Vector3.UP, 0.05).intersects_ray(camera.project_ray_origin(screen_position), camera.project_ray_normal(screen_position))
	if hit == null: return Vector2i(-1, -1)
	var result := Vector2i(floori(hit.x + 6.0), floori(hit.z + 4.0))
	return result if result.x >= 0 and result.x < 12 and result.y >= 0 and result.y < 8 else Vector2i(-1, -1)

func _scenery() -> void:
	# Faction monuments stay beyond the playable grid; silhouettes frame the battle.
	for side in [-1, 1]:
		var at := Vector3(side * 5.1, -0.03, -4.17)
		var body: Color = PALETTE.heaven if side == -1 else PALETTE.hell
		var trim: Color = PALETTE.heaven_trim if side == -1 else PALETTE.hell_trim
		_box(self, Vector3(1.05, 0.1, 0.55), at, body.darkened(0.15))
		for offset in [-0.35, 0.35]:
			_cylinder(self, 0.13, 0.75, at + Vector3(offset, 0.42, 0), body)
			_cylinder(self, 0.17, 0.28, at + Vector3(offset, 0.94, 0), trim, 0)
		_box(self, Vector3(0.8, 0.14, 0.19), at + Vector3(0, 0.69, 0), body)
		if side == -1: _ring(self, at + Vector3(0, 1.11, 0), 0.17, trim, 0.03)
		else:
			for offset in [-0.15, 0.15]: _cylinder(self, 0.06, 0.38, at + Vector3(offset, 0.95, 0), trim, 0)
