extends Node3D
## Persistent visual replicas of authoritative arena snapshots.
const PALETTE = preload("res://themes/olympus_arena_theme.tres")
var camera: Camera3D
var _tokens: Dictionary = {}
var _towers: Dictionary = {}
var _materials: Dictionary = {}
var _preview: MeshInstance3D
var _time := 0.0
var _last_event := -1
var _last_elapsed := 0.0
var _effects: Array = []
var _figure_factory: RefCounted
var _ghost: Node3D
var _ghost_kind := ""
var ambient_life
var combat_fx

func _ready() -> void:
	_setup()
	get_viewport().msaa_3d = Viewport.MSAA_4X

func _setup() -> void:
	if camera != null: return
	camera = Camera3D.new()
	add_child(camera)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 15.8
	camera.position = Vector3(0, 17, 20)
	camera.look_at(Vector3(0, 0, 0))
	camera.current = true
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("163c4b")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("c5d9e5")
	env.ambient_light_energy = 0.35
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	world.environment = env
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -35, 0)
	sun.light_color = Color("fff0cf")
	sun.light_energy = 0.60
	sun.shadow_enabled = true
	add_child(sun)
	var stage = preload("res://presentation/olympus_stage.gd").new()
	add_child(stage)
	ambient_life = preload("res://presentation/olympus_ambient_life.gd").new()
	add_child(ambient_life)
	combat_fx = preload("res://presentation/olympus_combat_fx.gd").new()
	add_child(combat_fx)
	_preview = _cylinder(self, 0.6, 0.035, Vector3.ZERO, Color(0.3, 0.8, 1, 0.5))
	_preview.visible = false

func show_state(state: Dictionary, delta: float = 0.0) -> void:
	_setup()
	_time += delta
	if float(state.get("elapsed", 0.0)) < _last_elapsed:
		_last_event = -1
		for effect in _effects: effect.node.queue_free()
		_effects.clear()
	_last_elapsed = float(state.get("elapsed", 0.0))
	combat_fx.consume_state(state, delta)
	camera.h_offset = combat_fx.camera_impulse.x
	camera.v_offset = combat_fx.camera_impulse.y
	var alive := {}
	for unit in state.get("units", []):
		var id = unit["id"]
		alive[id] = true
		if not _tokens.has(id):
			_tokens[id] = _make_unit(str(unit.get("kind", "hoplites")), int(unit["side"]))
			_tokens[id].position = Vector3(float(unit["x"]), 0.12, float(unit["z"]))
		var node: Node3D = _tokens[id]
		var target := Vector3(float(unit["x"]), 0.12, float(unit["z"]))
		var previous: Vector3 = node.position
		node.position = target
		var visual_offset: Vector3 = node.get_meta("visual_offset", Vector3.ZERO)
		visual_offset += previous - target
		visual_offset = visual_offset.lerp(Vector3.ZERO, 1.0 - exp(-delta * 28.0))
		node.set_meta("visual_offset", visual_offset)
		node.get_node("Figure").position.x = visual_offset.x
		node.get_node("Figure").position.z = visual_offset.z
		if previous.distance_to(target) > 0.004:
			node.get_node("Figure").rotation.y = atan2(target.x - previous.x, target.z - previous.z)
			node.set_meta("walking_until", _time + .14)
		_health(node, float(unit["hp"]) / maxf(1.0, float(unit.get("max_hp", unit["hp"]))))
		_damage_feedback(node, float(unit["hp"]), delta)
		_figure_factory.animate(node.get_node("Figure"), _time + int(id) * .37, _time < float(node.get_meta("walking_until", 0.0)), bool(unit.get("flying", false)), float(node.get_meta("hit_time", 0.0)))
	for id in _tokens.keys():
		if not alive.has(id):
			_departure(_tokens[id])
			_tokens[id].queue_free()
			_tokens.erase(id)
	for tower in state.get("towers", []):
		var id = tower["id"]
		if not _towers.has(id): _towers[id] = _make_tower(tower)
		var node: Node3D = _towers[id]
		node.scale.y = 1.0 if float(tower["hp"]) > 0 else 0.14
		node.get_node("Health").visible = float(tower["hp"]) > 0
		_health(node, float(tower["hp"]) / maxf(1.0, float(tower.get("max_hp", tower["hp"]))))
		_damage_feedback(node, float(tower["hp"]), delta)

func pick_ground(screen: Vector2, _viewport_size: Vector2 = Vector2.ZERO) -> Vector2:
	_setup()
	var hit = Plane(Vector3.UP, 0.12).intersects_ray(camera.project_ray_origin(screen), camera.project_ray_normal(screen))
	if hit == null or abs(hit.x) > 5.0 or abs(hit.z) > 8.0: return Vector2.INF
	return Vector2(hit.x, hit.z)

func show_deployment(position: Vector2, valid: bool, spell: bool = false, kind: String = "") -> void:
	_setup()
	_preview.visible = position.is_finite()
	if _ghost: _ghost.visible = false
	if not _preview.visible: return
	if not spell and not kind.is_empty():
		if _ghost_kind != kind:
			if _ghost: _ghost.queue_free()
			_ghost = _make_unit(kind, 0)
			_ghost.get_node("Health").hide()
			_ghost.get_node("Hit").hide()
			_ghost_kind = kind
			_tint_ghost(_ghost)
		_ghost.position = Vector3(position.x, .22, position.y)
		_ghost.visible = valid
	_preview.position = Vector3(position.x, 0.32, position.y)
	_preview.scale = Vector3(2.3 if spell else 1.0, 1, 2.3 if spell else 1.0)
	_preview.material_override = _material(Color(0.2, 0.8, 1, 0.55) if valid else Color(1, 0.2, 0.15, 0.5))

func clear_preview() -> void:
	if _preview: _preview.visible = false
	if _ghost: _ghost.visible = false

func _tint_ghost(node: Node) -> void:
	if node is MeshInstance3D:
		var material := StandardMaterial3D.new()
		material.albedo_color = Color(.35,.8,1,.45)
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		node.material_override = material
	for child in node.get_children(): _tint_ghost(child)

func _departure(unit: Node3D) -> void:
	# A short separate cosmetic burst never delays authoritative unit removal.
	var cloud := Node3D.new()
	add_child(cloud)
	cloud.position = unit.position
	for i in 6:
		var a := i * TAU / 6.0
		var puff := _sphere(cloud, Vector3.ONE * .10, Vector3(cos(a)*.12,.32,sin(a)*.12), Color("ead4a2"))
		var motion := create_tween().set_parallel(true)
		motion.tween_property(puff,"position",Vector3(cos(a)*.55,.12,sin(a)*.55),.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		motion.tween_property(puff,"scale",Vector3.ONE*.005,.35)
	var cleanup := create_tween()
	cleanup.tween_interval(.38)
	cleanup.tween_callback(cloud.queue_free)

func _show_event(event: Dictionary) -> void:
	var node := Node3D.new()
	add_child(node)
	node.position = Vector3(float(event.x), 0.25, float(event.z))
	var color: Color = PALETTE.player if int(event.side) == 0 else PALETTE.enemy
	var duration := 0.3
	match str(event.kind):
		"lightning":
			duration = 0.42
			var points := [Vector3(0, 0, 0), Vector3(-0.32, 1.0, 0), Vector3(0.28, 1.25, 0), Vector3(-0.2, 2.25, 0), Vector3(0.32, 3.5, 0)]
			for i in range(points.size() - 1): _limb(node, points[i], points[i+1], 0.045, Color("ffe590"))
			_cylinder(node, 1.05, 0.03, Vector3.ZERO, Color(1, 0.85, 0.35, 0.45))
		"summon":
			for i in 8:
				var angle := i * TAU / 8
				_sphere(node, Vector3(0.065, 0.14, 0.065), Vector3(cos(angle) * 0.5, 0.2, sin(angle) * 0.5), color)
		"hit":
			if event.has("source_x") and event.has("source_z"):
				var destination := node.position + Vector3(0, 0.5, 0)
				node.position = Vector3(float(event.source_x), 0.9, float(event.source_z))
				_sphere(node, Vector3(0.08, 0.08, 0.19), Vector3.ZERO, Color("ffe2a3"))
				_effects.append({"node":node, "age":0.0, "duration":0.16, "origin":node.position, "destination":destination})
				return
			for i in 4:
				var angle := i * PI / 2
				_limb(node, Vector3(0, 0.5, 0), Vector3(cos(angle) * 0.35, 0.7, sin(angle) * 0.35), 0.025, Color("ffe2a3"))
	_effects.append({"node":node, "age":0.0, "duration":duration})

func _make_tower(data: Dictionary) -> Node3D:
	var node := Node3D.new()
	add_child(node)
	node.position = Vector3(float(data["x"]), 0.1, float(data["z"]))
	var team: Color = PALETTE.player if int(data["side"]) == 0 else PALETTE.enemy
	var temple: bool = str(data.get("kind", "tower")) == "temple"
	var width := 2.2 if temple else 1.35
	_box(node, Vector3(width + .52,.08,2.02),Vector3(0,.035,0),Color("ad9270"))
	_box(node, Vector3(width + 0.3, 0.18, 1.8), Vector3(0, 0.1, 0), PALETTE.stone)
	_box(node, Vector3(width, 0.15, 1.55), Vector3(0, 0.27, 0), PALETTE.marble)
	for side in [-1,1]:
		for stair in 3:
			_box(node,Vector3(width*.58,.07,.19),Vector3(0,.05+stair*.07,side*(1.12-stair*.15)),PALETTE.marble)
	if temple:
		_box(node, Vector3(1.35, 1.1, 0.85), Vector3(0, 0.9, 0.1), PALETTE.marble)
		_box(node, Vector3(0.55, 0.8, 0.04), Vector3(0, 0.75, 0.55), team)
	for x in [-width * 0.38, width * 0.38]:
		for z in [-0.53, 0.53]:
			_cylinder(node, 0.19, 0.14, Vector3(x, 0.4, z), PALETTE.stone)
			_cylinder(node, 0.13, 0.94, Vector3(x, 0.93, z), PALETTE.marble)
			for flute in 8:
				var angle := flute*TAU/8.0
				_cylinder(node,.019,.81,Vector3(x+cos(angle)*.128,.94,z+sin(angle)*.128),Color("d6caa8"))
			_cylinder(node,.16,.075,Vector3(x,1.38,z),PALETTE.gold)
			_box(node, Vector3(0.35, 0.14, 0.35), Vector3(x, 1.46, z), PALETTE.stone)
	_box(node, Vector3(width + 0.15, 0.22, 1.55), Vector3(0, 1.66, 0), team)
	_box(node,Vector3(width+.24,.07,1.65),Vector3(0,1.52,0),PALETTE.gold)
	_box(node,Vector3(width+.24,.07,1.65),Vector3(0,1.80,0),PALETTE.marble)
	for side in [-1,1]:
		for i in 7:
			_box(node,Vector3(.08,.10,.035),Vector3((i-3)*width/7.0,1.66,side*.79),PALETTE.gold)
	for sign_x in [-1, 1]:
		var roof := _box(node, Vector3(width * 0.59, 0.12, 1.68), Vector3(sign_x * width * 0.24, 1.92, 0), PALETTE.roof)
		roof.rotation.z = sign_x * -0.35
		for row in 8:
			var tile := _box(node, Vector3(width * .59,.026,.025),Vector3(sign_x*width*.24,1.987,-.74+row*.21),Color("d18b60"))
			tile.rotation.z = sign_x * -.35
	_sphere(node, Vector3(0.15, 0.15, 0.15), Vector3(0, 2.18, 0), PALETTE.gold)
	for s in [-1,1]:
		_cylinder(node,.065,.55,Vector3(s*width*.43,2.03,-.25),PALETTE.gold)
		var flag := _box(node,Vector3(.25,.33,.035),Vector3(s*width*.43,2.09,-.25),team)
		flag.rotation.z=s*.09
	if temple:
		# Central ceremonial brazier and laurel crest distinguish the crown objective.
		_cylinder(node,.25,.17,Vector3(0,.49,.58),PALETTE.gold)
		_sphere(node,Vector3(.13,.22,.13),Vector3(0,.70,.58),Color("ffbe67"))
		for i in 9:
			var a := i*PI/8
			_sphere(node,Vector3(.045,.07,.025),Vector3(cos(a)*.22,1.06+sin(a)*.24,.56),PALETTE.gold)
	_add_health(node, 3.1, 1.4, team)
	return node

func _make_unit(kind: String, side: int) -> Node3D:
	var node := Node3D.new()
	add_child(node)
	var team: Color = PALETTE.player if side == 0 else PALETTE.enemy
	_cylinder(node, 0.38, 0.055, Vector3(0, 0.035, 0), Color("263743"))
	_cylinder(node, 0.36, 0.035, Vector3(0, 0.077, 0), team)
	_cylinder(node, 0.29, 0.015, Vector3(0, 0.099, 0), team.lightened(.2))
	var figure := Node3D.new()
	figure.name = "Figure"
	node.add_child(figure)
	figure.rotation.y = PI if side == 0 else 0.0
	var size := 1.10 if kind in ["heracles", "minotaur", "hydra"] else .86
	figure.scale = Vector3.ONE * size
	if _figure_factory == null: _figure_factory = preload("res://presentation/olympus_figurines.gd").new(self)
	_figure_factory.build(figure, kind, team)
	_add_health(node, 2.10 if size > 1 else 1.75, .78, team)
	return node
func _add_health(node: Node3D, height: float, width: float, color: Color) -> void:
	var hit := _cylinder(node, width * 0.57, 0.035, Vector3(0, 0.18, 0), Color(1, 0.8, 0.25, 0.7))
	hit.name = "Hit"
	hit.visible = false
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

func _damage_feedback(node: Node3D, hp: float, delta: float) -> void:
	var timer := maxf(0.0, float(node.get_meta("hit_time", 0.0)) - delta)
	var previous_hp := float(node.get_meta("previous_hp", hp))
	if hp < previous_hp:
		timer = 0.22
		var number := Label3D.new()
		number.text = "−%d" % roundi(previous_hp-hp)
		number.font_size = 42
		number.pixel_size = .009
		number.outline_size = 8
		number.modulate = Color("fff2bc")
		number.outline_modulate = Color("583328")
		number.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		number.no_depth_test = true
		add_child(number)
		number.position = node.position + Vector3(.12,1.62,0)
		var rise := create_tween().set_parallel(true)
		rise.tween_property(number,"position:y",number.position.y+.65,.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		rise.tween_property(number,"modulate:a",0.0,.25).set_delay(.30)
		rise.chain().tween_callback(number.queue_free)
	node.set_meta("previous_hp", hp)
	node.set_meta("hit_time", timer)
	var hit: MeshInstance3D = node.get_node("Hit")
	hit.visible = timer > 0.0
	hit.scale = Vector3.ONE * (1.0 + (0.22 - timer) * 2.0)

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
