extends Node3D
const DepartureFX = preload("res://presentation/olympus_unit_departure_fx.gd")
const EAST_WALK = preload("res://themes/hoplite_east_walk.tres")
const WEST_WALK = preload("res://themes/hoplite_west_walk.tres")
const MINOTAUR_WALK = {"north":preload("res://themes/minotaur_north_walk.tres"),"south":preload("res://themes/minotaur_south_walk.tres")}
const HERACLES_WALK = {"north":preload("res://themes/heracles_north_walk.tres"),"south":preload("res://themes/heracles_south_walk.tres")}
const ATALANTA_WALK = {"north":preload("res://themes/atalanta_north_walk.tres"),"south":preload("res://themes/atalanta_south_walk.tres")}
const HYDRA_IDLE = {"north":preload("res://themes/hydra_north_idle.tres"),"south":preload("res://themes/hydra_south_idle.tres"),"east":preload("res://themes/hydra_east_idle.tres"),"west":preload("res://themes/hydra_west_idle.tres")}
const HYDRA_ATTACK = {"north":preload("res://themes/hydra_north_attack.tres"),"south":preload("res://themes/hydra_south_attack.tres"),"east":preload("res://themes/hydra_east_attack.tres"),"west":preload("res://themes/hydra_west_attack.tres")}
const HERACLES_REST = {"east":preload("res://themes/heracles_east_rest.tres"),"west":preload("res://themes/heracles_west_rest.tres"),"north":preload("res://themes/heracles_north_rest.tres"),"south":preload("res://themes/heracles_south_rest.tres")}
const HERACLES_ATTACK = {"east":preload("res://themes/heracles_east_attack.tres"),"west":preload("res://themes/heracles_west_attack.tres"),"north":preload("res://themes/heracles_north_attack.tres"),"south":preload("res://themes/heracles_south_attack.tres")}
const HARPIES_FLIGHT = {"north":preload("res://themes/harpies_north_flight.tres"),"south":preload("res://themes/harpies_south_flight.tres")}
const HARPIES_ATTACK = {"north":preload("res://themes/harpies_north_attack.tres"),"south":preload("res://themes/harpies_south_attack.tres")}
const MEDUSA_WALK = {"east":preload("res://themes/medusa_east_walk.tres"),"west":preload("res://themes/medusa_west_walk.tres"),"north":preload("res://themes/medusa_north_walk.tres"),"south":preload("res://themes/medusa_south_walk.tres")}
const MINOTAUR_REST = {"north":preload("res://themes/minotaur_north_rest.tres"), "south":preload("res://themes/minotaur_south_rest.tres")}
const MINOTAUR_ATTACK = {"north":preload("res://themes/minotaur_north_attack.tres"), "south":preload("res://themes/minotaur_south_attack.tres")}
const MEDUSA_REST = {"east": preload("res://themes/medusa_east_rest.tres"), "west": preload("res://themes/medusa_west_rest.tres"), "north": preload("res://themes/medusa_north_rest.tres"), "south": preload("res://themes/medusa_south_rest.tres")}
const MEDUSA_ATTACK = {"east": preload("res://themes/medusa_east_attack.tres"), "west": preload("res://themes/medusa_west_attack.tres"), "north": preload("res://themes/medusa_north_attack.tres"), "south": preload("res://themes/medusa_south_attack.tres")}
const CollapseFX = preload("res://presentation/olympus_collapse_fx.gd")
const ATALANTA_REST = {"east": preload("res://themes/atalanta_east_rest.tres"), "west": preload("res://themes/atalanta_west_rest.tres"), "north": preload("res://themes/atalanta_north_rest.tres"), "south": preload("res://themes/atalanta_south_rest.tres")}
const ATALANTA_ATTACK = {"east": preload("res://themes/atalanta_east_attack.tres"), "west": preload("res://themes/atalanta_west_attack.tres"), "north": preload("res://themes/atalanta_north_attack.tres"), "south": preload("res://themes/atalanta_south_attack.tres")}
const SOUTH_WALK = preload("res://themes/hoplite_south_walk.tres")
const NORTH_WALK = preload("res://themes/hoplite_north_walk.tres")
## Persistent visual replicas of authoritative arena snapshots.
const WEST_ATTACK = preload("res://themes/hoplite_west_attack.tres")
const WEST_REST = preload("res://themes/hoplite_west_rest.tres")
const SOUTH_ATTACK = preload("res://themes/hoplite_south_attack.tres")
const SOUTH_REST = preload("res://themes/hoplite_south_rest.tres")
const NORTH_ATTACK = preload("res://themes/hoplite_north_attack.tres")
const NORTH_REST = preload("res://themes/hoplite_north_rest.tres")
const THRUST_CLIP = preload("res://themes/hoplite_thrust_clip.tres")
const RUBBLE_CLIP = preload("res://themes/olympus_shrine_rubble_clip.tres")
const SHRINE_CLIP = preload("res://themes/olympus_shrine_clip.tres")
const PALETTE = preload("res://themes/olympus_arena_theme.tres")
const PixelActor = preload("res://presentation/pixel_actor.gd")
const HOPLITE_GUARD = preload("res://themes/hoplite_guard_clip.tres")
var camera: Camera3D
var _tokens: Dictionary = {}
var _towers: Dictionary = {}
var _materials: Dictionary = {}
var _preview: MeshInstance3D
var _time := 0.0
var _last_event := -1
var _last_elapsed := 0.0
var _effects: Array = []
var _ghost: Node3D
var _ghost_kind := ""
var ambient_life
var combat_fx
var stage
var _collapses: Array = []
var _departures: Array = []
var damage_numbers

func _ready() -> void:
	_setup()
	get_viewport().msaa_3d = Viewport.MSAA_4X

func _setup() -> void:
	if camera != null: return
	camera = Camera3D.new()
	add_child(camera)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 14.0
	camera.position = Vector3(0, 16.4, 20.6)
	camera.look_at(Vector3(0, 0.15, 0))
	camera.current = true
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("082f3d")
	world.environment = env
	add_child(world)
	stage = preload("res://presentation/olympus_stage.gd").new()
	add_child(stage)
	stage.configure(camera)
	combat_fx = preload("res://presentation/olympus_combat_fx.gd").new()
	add_child(combat_fx)
	damage_numbers = preload("res://presentation/olympus_damage_numbers.gd").new()
	add_child(damage_numbers)
	_preview = _cylinder(self, 0.6, 0.035, Vector3.ZERO, Color(0.3, 0.8, 1, 0.5))
	_preview.visible = false

func show_state(state: Dictionary, delta: float = 0.0) -> void:
	_setup()
	stage.advance_visual(delta)
	_time += delta
	var resetting := float(state.get("elapsed", 0.0)) < _last_elapsed
	if resetting:
		damage_numbers.clear()
		for departure in _departures:
			if is_instance_valid(departure): departure.queue_free()
		_departures.clear()
		for collapse in _collapses: collapse.fx.queue_free()
		_collapses.clear()
		_last_event = -1
		for effect in _effects: effect.node.queue_free()
		_effects.clear()
	_last_elapsed = float(state.get("elapsed", 0.0))
	damage_numbers.advance_visual(delta)
	for i in range(_departures.size()-1,-1,-1):
		var departure = _departures[i]
		if not is_instance_valid(departure):
			_departures.remove_at(i)
			continue
		departure.advance_visual(delta)
		if departure.elapsed >= DepartureFX.LIFETIME: _departures.remove_at(i)
	for i in range(_collapses.size()-1,-1,-1):
		var collapse = _collapses[i]
		collapse.fx.advance_visual(delta)
		if collapse.fx.age >= CollapseFX.DURATION:
			collapse.fx.queue_free()
			_collapses.remove_at(i)
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
			_face_pixel_unit(node, Vector2(target.x-previous.x,target.z-previous.z))
			if not node.get_node("Figure").has_node("PixelActor"):
				node.get_node("Figure").rotation.y = atan2(target.x - previous.x, target.z - previous.z)
			node.set_meta("walking_until", _time + .14)
		_health(node, float(unit["hp"]) / maxf(1.0, float(unit.get("max_hp", unit["hp"]))))
		_ability_status(node, unit)
		_damage_feedback(node, float(unit["hp"]), delta)
		var sprite = node.get_node("Figure").get_node_or_null("PixelActor")
		if sprite != null:
			var moved := previous.distance_to(target) > 0.004
			# Render-only repeats must retain movement until a new authoritative tick.
			if not state.has("elapsed") or moved or not node.has_meta("motion_tick") or float(node.get_meta("motion_tick", -1.0)) != float(state.elapsed):
				node.set_meta("motion_active", moved)
				node.set_meta("motion_tick", float(state.get("elapsed", -1.0)))
			var moving := bool(node.get_meta("motion_active", false))
			var walks := {"north": NORTH_WALK, "south": SOUTH_WALK, "east":EAST_WALK, "west":WEST_WALK}
			if str(node.get_meta("kind", "")) != "hoplites": walks={}
			if str(node.get_meta("kind", "")) == "medusa": walks=MEDUSA_WALK
			if str(node.get_meta("kind", "")) == "atalanta": walks=ATALANTA_WALK
			if str(node.get_meta("kind", "")) == "heracles": walks=HERACLES_WALK
			if str(node.get_meta("kind", "")) == "minotaur": walks=MINOTAUR_WALK
			var locomotion=walks.get(str(node.get_meta("pixel_facing", "east"))) if moving else null
			if str(node.get_meta("kind", "")) == "harpies":
				locomotion=HARPIES_FLIGHT[str(node.get_meta("pixel_facing", "south"))]
			if str(node.get_meta("kind", "")) == "hydra":
				locomotion=HYDRA_IDLE[str(node.get_meta("pixel_facing", "south"))]
			sprite.set_locomotion(locomotion)
			sprite.advance_visual(delta)
	for id in _tokens.keys():
		if not alive.has(id):
			if not resetting: _departure(_tokens[id])
			_tokens[id].queue_free()
			_tokens.erase(id)
	_mark_attack_events(state.get("events", []))
	for tower in state.get("towers", []):
		var id = tower["id"]
		if not _towers.has(id): _towers[id] = _make_tower(tower)
		var node: Node3D = _towers[id]
		var destroyed := float(tower["hp"]) <= 0
		if not node.has_meta("destroyed") or node.get_meta("destroyed") != destroyed:
			if destroyed and node.has_meta("destroyed"):
				var collapse := CollapseFX.new()
				add_child(collapse)
				collapse.position=node.position
				collapse.begin(node.get_node("Architecture/PixelBuilding"))
				_collapses.append({"fx":collapse,"tower":id})
			elif not destroyed:
				for i in range(_collapses.size()-1,-1,-1):
					if _collapses[i].tower==id:
						_collapses[i].fx.queue_free()
						_collapses.remove_at(i)
			node.set_meta("destroyed", destroyed)
			node.get_node("Architecture/PixelBuilding").reset_playback(RUBBLE_CLIP if destroyed else SHRINE_CLIP)
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
	_preview.material_override.set_shader_parameter("ink", Color(0.2, 0.8, 1, 0.55) if valid else Color(1, 0.2, 0.15, 0.5))

func clear_preview() -> void:
	if _preview: _preview.visible = false
	if _ghost: _ghost.visible = false

func _mark_attack_events(events: Array) -> void:
	for event in events:
		var event_id := int(event.get("id", -1))
		if event_id <= _last_event: continue
		_last_event = event_id
		if str(event.get("kind", "")) != "hit": continue
		# Missing/departed sources are skipped, never reassigned to a nearby actor.
		if str(event.get("source_type", "")) != "unit": continue
		var attacker = _tokens.get(event.get("source_id"))
		if attacker != null:
			attacker.set_meta("attack_until", _time + 0.24)
			var sprite=attacker.get_node_or_null("Figure/PixelActor")
			if sprite != null:
				var direction:=Vector2(float(event.x)-float(event.get("source_x",attacker.position.x)),float(event.z)-float(event.get("source_z",attacker.position.z)))
				_face_pixel_unit(attacker,direction,true)
				var facing=str(attacker.get_meta("pixel_facing","east"))
				var attacks:={"north":NORTH_ATTACK,"south":SOUTH_ATTACK,"west":WEST_ATTACK,"east":THRUST_CLIP}
				if str(attacker.get_meta("kind", "")) == "atalanta": attacks=ATALANTA_ATTACK
				if str(attacker.get_meta("kind", "")) == "medusa": attacks=MEDUSA_ATTACK
				if str(attacker.get_meta("kind", "")) == "minotaur": attacks=MINOTAUR_ATTACK
				if str(attacker.get_meta("kind", "")) == "heracles": attacks=HERACLES_ATTACK
				if str(attacker.get_meta("kind", "")) == "harpies": attacks=HARPIES_ATTACK
				if str(attacker.get_meta("kind", "")) == "hydra": attacks=HYDRA_ATTACK
				sprite.play_attack(event_id, attacks[facing])

func _face_pixel_unit(node: Node3D, direction: Vector2, attack_target := false) -> void:
	var sprite=node.get_node_or_null("Figure/PixelActor")
	if sprite==null or direction.length_squared()<0.000001: return
	# Crowd correction is movement, not a new attack direction. Keep a playing
	# action oriented toward its actual target until the action finishes.
	if not attack_target and sprite._reaction_elapsed >= 0.0: return
	var previous := str(node.get_meta("pixel_facing", ""))
	var north:=direction.y<0 and absf(direction.y)>=absf(direction.x)
	var south:=direction.y>0 and absf(direction.y)>=absf(direction.x)
	var facing:="north" if north else ("south" if south else ("west" if direction.x<0 else "east"))
	if str(node.get_meta("kind", "")) in ["minotaur","harpies"]:
		# With only front/rear art, almost lateral motion must not flip the
		# entire creature because of a tiny positive/negative crowd adjustment.
		facing="north" if direction.y<0 else "south"
		if previous in ["north","south"] and absf(direction.normalized().y)<0.2:
			facing=previous
	elif not attack_target and previous in ["north","south","east","west"]:
		var axes := {"north":Vector2.UP,"south":Vector2.DOWN,"east":Vector2.RIGHT,"west":Vector2.LEFT}
		# A ten-degree overlap around the 45-degree movement boundary prevents
		# repeated turns while following a bridge or separating from an ally.
		if direction.normalized().dot(axes[previous]) >= cos(deg_to_rad(55.0)):
			facing=previous
	node.set_meta("pixel_facing",facing)
	var poses:={"north":NORTH_REST,"south":SOUTH_REST,"west":WEST_REST,"east":node.get_meta("front_rest")}
	if str(node.get_meta("kind", "")) == "atalanta": poses=ATALANTA_REST
	if str(node.get_meta("kind", "")) == "medusa": poses=MEDUSA_REST
	if str(node.get_meta("kind", "")) == "minotaur": poses=MINOTAUR_REST
	if str(node.get_meta("kind", "")) == "heracles": poses=HERACLES_REST
	if str(node.get_meta("kind", "")) == "harpies": poses=HARPIES_FLIGHT
	if str(node.get_meta("kind", "")) == "hydra": poses=HYDRA_IDLE
	sprite.set_rest_pose(poses[facing])

func _tint_ghost(node: Node) -> void:
	if node is Sprite3D: node.modulate=Color(.35,.8,1,.45)
	if node is MeshInstance3D:
		var material := StandardMaterial3D.new()
		material.albedo_color = Color(.35,.8,1,.45)
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		node.material_override = material
	for child in node.get_children(): _tint_ghost(child)

func _departure(unit: Node3D) -> void:
	var source = unit.get_node_or_null("Figure/PixelActor")
	if source != null:
		var departure := DepartureFX.new()
		add_child(departure)
		if departure.begin(source): _departures.append(departure)
		else: departure.queue_free()
		return
func _make_tower(data: Dictionary) -> Node3D:
	var node := Node3D.new()
	add_child(node)
	node.position = Vector3(float(data["x"]), 0.1, float(data["z"]))
	var team: Color = PALETTE.player if int(data["side"]) == 0 else PALETTE.enemy
	var temple: bool = str(data.get("kind", "tower")) == "temple"
	var architecture := Node3D.new()
	architecture.name = "Architecture"
	architecture.scale = Vector3.ONE
	node.add_child(architecture)
	var building := PixelActor.new()
	building.name = "PixelBuilding"
	# Put the front step at the forward footprint edge; replica origin stays authoritative.
	building.position = Vector3(0, 0.05, 0.45 if temple else 0.36)
	building.pixel_size = 0.0017 if temple else 0.0014
	architecture.add_child(building)
	building.reset_playback(SHRINE_CLIP)
	_cylinder(node, 0.72 if temple else 0.59, 0.025, Vector3(0, 0.01, 0), team.darkened(.4))
	_cylinder(node, 0.66 if temple else 0.53, 0.027, Vector3(0, 0.012, 0), Color("666855"))
	_add_health(node, 2.3 if temple else 1.95, 1.05, team)
	return node

func _make_unit(kind: String, side: int) -> Node3D:
	var node := Node3D.new()
	add_child(node)
	node.set_meta("side", side)
	node.set_meta("kind", kind)
	var team: Color = PALETTE.player if side == 0 else PALETTE.enemy
	_cylinder(node, 0.38, 0.055, Vector3(0, 0.035, 0), Color("263743"))
	_cylinder(node, 0.36, 0.035, Vector3(0, 0.077, 0), team.darkened(.18))
	var ability := _cylinder(node, 0.31, 0.012, Vector3(0, 0.116, 0), Color("e6b96580"))
	ability.name = "Ability"
	ability.visible = false
	var figure := Node3D.new()
	figure.name = "Figure"
	node.add_child(figure)
	figure.rotation.y = PI if side == 0 else 0.0
	var size := 1.10 if kind in ["heracles", "minotaur", "hydra"] else .86
	figure.scale = Vector3.ONE * size
	if kind in ["hoplites", "atalanta", "medusa", "minotaur", "heracles", "harpies", "hydra"]:
		figure.rotation=Vector3.ZERO
		var sprite:=PixelActor.new()
		sprite.name="PixelActor"
		sprite.pixel_size=.0027
		figure.add_child(sprite)
		var rest=HOPLITE_GUARD.duplicate()
		rest.regions.assign([HOPLITE_GUARD.regions[0]])
		rest.durations=PackedFloat32Array([1.0])
		rest.looping=true
		if kind=="atalanta": rest=ATALANTA_REST["north" if side==0 else "south"]
		if kind=="medusa": rest=MEDUSA_REST["north" if side==0 else "south"]
		if kind=="minotaur": rest=MINOTAUR_REST["north" if side==0 else "south"]
		if kind=="heracles": rest=HERACLES_REST["north" if side==0 else "south"]
		if kind=="harpies":
			rest=HARPIES_FLIGHT["north" if side==0 else "south"]
			sprite.position.y=1.0
			node.set_meta("pixel_facing","north" if side==0 else "south")
		if kind=="hydra":
			rest=HYDRA_IDLE["north" if side==0 else "south"]
			sprite.pixel_size=.005
			node.set_meta("pixel_facing","north" if side==0 else "south")
		sprite.reset_playback(rest)
		node.set_meta("front_rest",rest)
	else:
		push_error("Missing 2D character art: "+kind)
	_add_health(node, 2.10 if size > 1 else 1.75, .78, team)
	return node

func _ability_status(node: Node3D, unit: Dictionary) -> void:
	var marker: MeshInstance3D = node.get_node("Ability")
	var charged := bool(unit.get("charge_ready", false))
	var recovering := str(unit.get("kind", "")) == "hydra" and float(unit.get("recovery_time", 0.0)) >= 4.0 and float(unit.get("hp", 0.0)) < float(unit.get("max_hp", 0.0))
	marker.visible = charged or recovering
	if not marker.visible: return
	marker.material_override.set_shader_parameter("ink", Color("e6b9659c") if charged else Color("72b98583"))
	var pulse := .94 + sin(_time * (6.5 if charged else 3.5)) * .06
	marker.scale = Vector3(pulse, 1.0, pulse)

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
	# Health indicators are interface overlays in world space. They must not
	# cast floating rectangular shadows onto the stone or change with sunlight.
	for indicator in holder.get_children():
		if indicator is MeshInstance3D:
			indicator.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			var material := indicator.material_override.duplicate() as StandardMaterial3D
			material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			indicator.material_override = material

func _health(node: Node3D, fraction: float) -> void:
	var fill: MeshInstance3D = node.get_node("Health/Fill")
	fraction = clampf(fraction, 0.0, 1.0)
	fill.scale.x = maxf(0.001, fraction)
	fill.position.x = (fraction - 1.0) * float(fill.get_meta("width")) / 2

func _damage_feedback(node: Node3D, hp: float, delta: float) -> void:
	var timer := maxf(0.0, float(node.get_meta("hit_time", 0.0)) - delta)
	var previous_hp := float(node.get_meta("previous_hp", hp))
	if hp < previous_hp:
		var sprite = node.get_node_or_null("Figure/PixelActor")
		if sprite != null:
			var serial := int(node.get_meta("damage_serial",0))+1
			node.set_meta("damage_serial",serial)
			if str(node.get_meta("kind", ""))=="hoplites" and node.get_meta("pixel_facing","east")=="east": sprite.react_to_hit(serial,HOPLITE_GUARD)
		timer = 0.22
		var height: float = node.get_node("Health").position.y + 0.32
		damage_numbers.show_loss(node.get_instance_id(), node.position + Vector3(0,height,0), previous_hp-hp)
	node.set_meta("previous_hp", hp)
	node.set_meta("hit_time", timer)
	var hit: MeshInstance3D = node.get_node("Hit")
	hit.visible = timer > 0.0
	hit.scale = Vector3.ONE * (1.0 + (0.22 - timer) * 2.0)

func _material(color: Color) -> StandardMaterial3D:
	if _materials.has(color): return _materials[color]
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
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
	var mesh := QuadMesh.new()
	mesh.size = Vector2(size.x, size.y)
	return _mesh(parent, mesh, at, color)

func _cylinder(parent: Node3D, radius: float, _height: float, at: Vector3, color: Color) -> MeshInstance3D:
	# Flat ground-space interface disk, not a sculpted base or model.
	var mesh := PlaneMesh.new()
	mesh.size = Vector2.ONE*radius*2.0
	var node := _mesh(parent, mesh, at, color)
	var material := ShaderMaterial.new()
	material.shader = preload("res://presentation/olympus_flat_marker.gdshader")
	material.set_shader_parameter("ink", color)
	node.material_override = material
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return node
