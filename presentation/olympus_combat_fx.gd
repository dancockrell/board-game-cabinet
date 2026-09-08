extends Node3D
## Cosmetic event consumer. Never mutates or advances authoritative game state.
## Add beneath the arena board, then call consume_state(snapshot, frame_delta).
const MAX_EFFECTS := 96
var effects: Array[Dictionary] = []
var _materials: Dictionary = {}
var _units: Array = []
var _towers: Array = []
var _previous_towers: Dictionary = {}
var _last_id := -1
var _elapsed := -1.0
var _sequence := 0
## Optional orthographic camera h_offset/v_offset, in world units. Host applies it.
## Keeping this separate leaves the authoritative picking plane untouched.
var camera_impulse := Vector2.ZERO
var _shake_strength := 0.0
var _clock := 0.0

func consume_state(state: Dictionary, delta := 0.0) -> void:
	var now := float(state.get("elapsed", 0.0))
	if now < _elapsed:
		clear_effects()
		_last_id = -1
		_previous_towers.clear()
	_elapsed = now
	# Copy the records used for inference; retaining a snapshot is never authority.
	_units = state.get("units", []).duplicate(true)
	_towers = state.get("towers", []).duplicate(true)
	animate(delta)
	for event in state.get("events", []):
		if int(event.get("id", -1)) <= _last_id: continue
		_last_id = int(event.id)
		show_event(event)
	for tower in _towers:
		var id := str(tower.id)
		var hp := float(tower.hp)
		var previous := float(_previous_towers.get(id, hp))
		if hp <= 0.0 and previous > 0.0:
			tower_destroyed(tower)
		elif hp < previous:
			show_tower_damage(tower, previous-hp)
		_previous_towers[id] = hp

func clear_effects() -> void:
	for effect in effects:
		if is_instance_valid(effect.node): effect.node.queue_free()
	effects.clear()
	_shake_strength = 0.0
	camera_impulse = Vector2.ZERO

func animate(delta: float) -> void:
	_clock += maxf(delta,0.0)
	_shake_strength = maxf(0.0,_shake_strength-delta*.75)
	camera_impulse = Vector2(sin(_clock*61),cos(_clock*47)) * _shake_strength
	for effect in effects.duplicate():
		if not is_instance_valid(effect.node):
			effects.erase(effect)
			continue
		effect.age += maxf(delta, 0.0)
		var t := clampf(effect.age/effect.life, 0.0, 1.0)
		var node: Node3D = effect.node
		match str(effect.motion):
			"projectile":
				node.position = effect.origin.lerp(effect.destination,t)
				node.position.y += sin(t*PI)*float(effect.get("arc",.12))
			"debris":
				node.position = effect.origin + effect.velocity*effect.age + Vector3(0,-3.7,0)*effect.age*effect.age
				node.rotation += effect.spin*delta
				node.scale = Vector3.ONE*maxf(.001,1.0-t*t)
			"smoke":
				node.position = effect.origin + effect.velocity*effect.age
				node.scale = Vector3.ONE*(.5+sin(t*PI)*.7)*maxf(.001,1.0-t*t)
			"rise":
				node.position = effect.origin + effect.velocity*effect.age
				node.rotation.y += delta*float(effect.get("turn",2.0))
				node.scale = Vector3.ONE*maxf(.001,sin(t*PI))
			"ring":
				node.scale = Vector3(1.0+t*float(effect.get("expansion",2.5)),1.0,1.0+t*float(effect.get("expansion",2.5)))
				node.position.y = effect.origin.y + t*.05
			"flash":
				node.scale = Vector3.ONE*maxf(.001,sin((.15+t*.85)*PI))
		if t >= 1.0:
			var impact: String = effect.get("impact", "")
			if not impact.is_empty(): _impact(effect.destination,impact,effect.get("color",Color.WHITE))
			node.queue_free()
			effects.erase(effect)

func _effect(at: Vector3, life: float, motion := "flash") -> Dictionary:
	while effects.size() >= MAX_EFFECTS:
		var oldest: Dictionary = effects.pop_front()
		if is_instance_valid(oldest.node): oldest.node.queue_free()
	var node := Node3D.new()
	add_child(node)
	node.position = at
	var effect := {"node":node,"origin":at,"age":0.0,"life":life,"motion":motion}
	effects.append(effect)
	_sequence += 1
	return effect

func _material(color: Color, glow := false) -> StandardMaterial3D:
	var key := "%s:%s" % [color.to_html(),glow]
	if _materials.has(key): return _materials[key]
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = .85
	if glow:
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = 1.4
	if color.a < 1.0:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.no_depth_test = false
	_materials[key] = mat
	return mat

func _mesh(p: Node3D, mesh: Mesh, at: Vector3, color: Color, glow := false) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.material_override = _material(color,glow)
	node.position = at
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	p.add_child(node)
	return node

func _ball(p: Node3D, at: Vector3, size: Vector3, color: Color, _glow := false) -> Sprite3D:
	# Small effects are pixel drawings on transparent cards, never solid models.
	var image := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	for y in 8:
		for x in 8:
			if Vector2(x - 3.5, y - 3.5).length() <= 3.8:
				image.set_pixel(x, y, color)
	var node := Sprite3D.new()
	node.texture = ImageTexture.create_from_image(image)
	node.pixel_size = 0.25
	node.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	node.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	node.shaded = false
	node.position = at
	node.scale = Vector3(size.x, size.y, 1.0)
	p.add_child(node)
	return node

func _line(p: Node3D, a: Vector3, b: Vector3, radius: float, color: Color) -> void:
	if a.distance_squared_to(b) < .00001: return
	# A single flat ribbon facing the fixed tactical camera; no cylinder sides.
	var direction := (b-a).normalized()
	var across := direction.cross(Vector3(0, .63, .78)).normalized() * radius
	if across.length_squared() < .000001: across = Vector3.RIGHT * radius
	var vertices := PackedVector3Array([a-across, a+across, b+across, a-across, b+across, b-across])
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var node := _mesh(p, mesh, Vector3.ZERO, color, true)
	node.material_override.cull_mode = BaseMaterial3D.CULL_DISABLED

func _ring(at: Vector3, radius: float, color: Color, life := .32, segments := 16) -> void:
	var e := _effect(at,life,"ring")
	for i in segments:
		var a := i*TAU/segments
		var b := (i+1)*TAU/segments
		_line(e.node,Vector3(cos(a),0,sin(a))*radius,Vector3(cos(b),0,sin(b))*radius,.018,color)

func _attacker(event: Dictionary) -> String:
	if event.has("source_kind"): return str(event.source_kind)
	if not event.has("source_x"): return "hoplites"
	var source := Vector2(event.source_x,event.source_z)
	var distance := .55
	var kind := "tower"
	for unit in _units:
		if int(unit.side) != int(event.side): continue
		var d := Vector2(unit.x,unit.z).distance_to(source)
		if d < distance:
			distance = d
			kind = str(unit.kind)
	return kind

func show_event(event: Dictionary) -> void:
	var at := Vector3(float(event.get("x",0)),.40,float(event.get("z",0)))
	var team := Color("72d4ff") if int(event.get("side",0)) == 0 else Color("ff9576")
	match str(event.get("kind","")):
		"lightning": _thunder(at)
		"charge_ready":
			# The halo makes the Minotaur's stored first strike legible before it
			# reaches a building; rules still own the charge state and damage.
			_ring(at-Vector3(0,.16,0),.36,Color("e8b65f"),.65,20)
			for i in 5:
				var a := i*TAU/5.0
				var e := _effect(at+Vector3(cos(a)*.28,.08,sin(a)*.28),.55,"rise")
				e.velocity=Vector3(cos(a)*.08,.65,sin(a)*.08)
				e.turn=2.5+i*.25
				_ball(e.node,Vector3.ZERO,Vector3(.045,.09,.045),Color("f3c878"),true)
		"charge_hit":
			_shake_strength = maxf(_shake_strength,.055)
			_ring(at-Vector3(0,.13,0),.44,Color("f0c66f"),.42,20)
			for i in 7: _debris(at,i,Color("b49568"),.075+(i%2)*.025,.52)
		"heal":
			for i in 7:
				var a := i*2.399
				var e := _effect(at+Vector3(cos(a)*(.12+i*.025),.05,sin(a)*(.12+i*.025)),.72,"rise")
				e.velocity=Vector3(cos(a)*.08,.72+i*.025,sin(a)*.08)
				e.turn=2.0+i*.18
				_ball(e.node,Vector3.ZERO,Vector3(.035,.10,.035),Color("89d596"),true)
		"summon":
			_ring(at-Vector3(0,.12,0),.32,team,.42)
			for i in 6:
				var a := i*TAU/6
				var e := _effect(at+Vector3(cos(a)*.32,0,sin(a)*.32),.45,"smoke")
				e.velocity=Vector3(0,.75,0)
				_ball(e.node,Vector3.ZERO,Vector3(.028,.13,.028),team,true)
		"hit":
			var kind := _attacker(event)
			var source := Vector3(float(event.get("source_x",at.x)),.95,float(event.get("source_z",at.z)))
			if kind in ["atalanta","tower","temple"]:
				var e := _effect(source,.15,"projectile")
				e.destination=at+Vector3(0,.35,0)
				e.impact="arrow"
				e.color=team
				var direction := (e.destination-source).normalized() as Vector3
				if kind == "temple":
					_line(e.node,-direction*.34,Vector3.ZERO,.04,team.lightened(.42))
					_ball(e.node,Vector3.ZERO,Vector3(.12,.12,.12),Color("fff1a8"),true)
					e.impact="giant"
				else:
					_line(e.node,-direction*.50,Vector3.ZERO,.017,Color("fff0bd"))
					_ball(e.node,Vector3.ZERO,Vector3(.055,.055,.055),Color("fff5da"),true)
			elif kind == "medusa":
				var e := _effect(source,.16,"flash")
				_line(e.node,Vector3.ZERO,at-source+Vector3(0,.45,0),.034,Color("88efb2"))
				_impact(at,"medusa",Color("9cf2be"))
			else:
				_impact(at,kind,team)

func _impact(at: Vector3, kind: String, team: Color) -> void:
	var color := Color("ffe9a6")
	if kind == "medusa" or kind == "hydra": color=Color("a2f2a0")
	if kind in ["minotaur","heracles"]:
		_ring(at-Vector3(0,.13,0),.24,Color("f0cd85"),.30)
		for i in 4: _debris(at,i,Color("c3ad82"),.085,.45)
	elif kind in ["harpy","harpies"]:
		for i in 3:
			var e := _effect(at,.42,"debris")
			var a := i*TAU/3
			e.velocity=Vector3(cos(a)*.65,1.0,sin(a)*.65)
			e.spin=Vector3(1.2,2.0,1.0)
			_ball(e.node,Vector3.ZERO,Vector3(.025,.12,.045),Color("f5e6ca"))
	elif kind == "medusa":
		_ring(at,.22,Color("8ddaaf"),.26)
	var flash := _effect(at+Vector3(0,.25,0),.19,"flash")
	for i in 5:
		var a := i*TAU/5 + _sequence*.7
		_line(flash.node,Vector3.ZERO,Vector3(cos(a)*.24,.05+sin(a)*.18,sin(a)*.18),.025,color)
	if kind in ["hoplites","hoplite","heracles","minotaur","hydra"]:
		# A readable curved weapon sweep, kept separate from any damage decision.
		var arc := _effect(at+Vector3(0,.55,0),.18,"flash")
		for i in 5:
			var a := -.9+i*.36
			var b := a+.36
			_line(arc.node,Vector3(cos(a)*.40,sin(a)*.28,0),Vector3(cos(b)*.40,sin(b)*.28,0),.025,team.lightened(.35))

func _thunder(at: Vector3) -> void:
	_shake_strength = maxf(_shake_strength,.075)
	var e := _effect(at,.32,"flash")
	var points := [Vector3.ZERO,Vector3(-.19,.65,0),Vector3(.26,1.0,.06),Vector3(-.13,1.5,0),Vector3(.25,2.3,-.1),Vector3(0,3.5,0)]
	for i in points.size()-1:
		_line(e.node,points[i],points[i+1],.048,Color("fff8c4"))
		_line(e.node,points[i]+Vector3(.025,0,.025),points[i+1]+Vector3(.025,0,.025),.019,Color("8cdaff"))
	_ring(at-Vector3(0,.10,0),.52,Color("fff0ad"),.38)
	for i in 8: _debris(at,i,Color("f8d98c"),.045,.45)

func _debris(at: Vector3, index: int, color: Color, size: float, life: float) -> void:
	var e := _effect(at,life,"debris")
	var a := index*2.399+_sequence*.11
	e.velocity=Vector3(cos(a)*(1.0+index*.08),1.2+(index%3)*.25,sin(a)*(1.0+index*.08))
	e.spin=Vector3(2.0+index,1.0,2.0)
	_ball(e.node,Vector3.ZERO,Vector3(size,size*.75,size),color)

func show_tower_damage(tower: Dictionary, _amount := 0.0) -> void:
	var at := Vector3(float(tower.x),1.1,float(tower.z))
	for i in 2: _debris(at,i,Color("d6c49b"),.10,.5)
	if float(tower.hp)/maxf(1.0,float(tower.get("max_hp",1))) < .4:
		var e := _effect(at+Vector3(0,.6,0),.8,"smoke")
		e.velocity=Vector3(.10,.65,.04)
		_ball(e.node,Vector3.ZERO,Vector3(.20,.24,.20),Color(.40,.37,.32,.48))

func tower_destroyed(_tower: Dictionary) -> void:
	# Authored shrine collapse owns the visible masonry and dust. A second generic
	# explosion would cover those drawings with large circles and duplicate debris.
	_shake_strength = maxf(_shake_strength,.055)
