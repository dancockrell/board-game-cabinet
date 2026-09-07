extends Node3D
## A short-lived replica of a destroyed shrine. Its clock is driven by the board,
## so pausing and replay resets cannot leave an independently running effect.
const DURATION := 1.35
var age := 0.0
var _ghost: Sprite3D
var _origin := Vector3.ZERO
var _original_scale := Vector3.ONE
var _particles: Array[Dictionary] = []

func begin(building: Sprite3D) -> void:
	if _ghost != null: return
	_ghost = Sprite3D.new()
	_ghost.name = "FallingShrine"
	_ghost.texture = building.texture.duplicate()
	_ghost.pixel_size = building.pixel_size
	_ghost.offset = building.offset
	_ghost.billboard = building.billboard
	_ghost.texture_filter = building.texture_filter
	_ghost.alpha_cut = building.alpha_cut
	_ghost.alpha_scissor_threshold = building.alpha_scissor_threshold
	_ghost.shaded = building.shaded
	_ghost.double_sided = true
	_ghost.material_override = building.material_override
	add_child(_ghost)
	_ghost.transform = building.transform
	_origin = _ghost.position
	_original_scale = _ghost.scale
	# Seedless arithmetic makes review captures reproducible and never consumes RNG
	# from the simulation. Dust uses discrete blocks rather than smooth spheres.
	var size_factor := building.pixel_size / .0014
	for i in 16:
		var angle := float(i) * 2.399963
		var radius := .12 + float(i % 4) * .075
		var launch := Vector3(cos(angle) * radius, .3 + float(i % 5) * .21, sin(angle) * radius)
		var velocity := Vector3(cos(angle) * (1.0 + float(i % 3) * .25), 1.5 + float(i % 4) * .3, sin(angle) * .8)
		_particle(launch * size_factor, velocity * size_factor, .045 + float(i % 3) * .018, false, i)
	for i in 18:
		var angle := float(i) * 2.399963
		var launch := Vector3(cos(angle) * .24, .08 + float(i % 3) * .05, sin(angle) * .24 + .25)
		var velocity := Vector3(cos(angle) * 1.0, .22 + float(i % 3) * .1, sin(angle) * .65)
		_particle(launch * size_factor, velocity * size_factor, (.065 + float(i % 4) * .015) * size_factor, true, i)
	advance_visual(0)

func _particle(origin: Vector3, velocity: Vector3, size: float, dust: bool, index: int) -> void:
	var piece := MeshInstance3D.new()
	piece.name = ("Dust" if dust else "Stone") + str(index)
	var mesh := BoxMesh.new()
	mesh.size = Vector3(size, size * (.75 if dust else .65), size)
	piece.mesh = mesh
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var colors := [Color("bda57d"), Color("ddc99d"), Color("92816a")] if dust else [Color("e3d3b3"), Color("b4a185"), Color("857766")]
	material.albedo_color = colors[index % 3]
	piece.material_override = material
	piece.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(piece)
	_particles.append({"node":piece, "origin":origin, "velocity":velocity, "dust":dust, "index":index})

func advance_visual(delta: float) -> void:
	if not is_finite(delta) or delta < 0: return
	age = minf(DURATION, age + delta)
	if _ghost == null: return
	var fall := clampf((age - .06) / .43, 0.0, 1.0)
	_ghost.visible = age < .49
	_ghost.position = _origin + Vector3(sin(age * 81.0) * .04 * (1.0 - fall), -fall * .02, .16)
	_ghost.scale = _original_scale * Vector3(1.0 + fall * .05, maxf(.08, 1.0 - fall * .84), 1.0)
	for particle in _particles:
		var node: MeshInstance3D = particle.node
		var t := maxf(0.0, age - (.14 if particle.dust else .07))
		node.visible = t > 0 and age < DURATION
		if particle.dust:
			node.position = particle.origin + particle.velocity * t
			# Quantized expansion keeps the clouds in the pixel scene's visual idiom.
			var growth := floorf((1.0 + minf(t, .5) * 1.5) * 8.0) / 8.0
			var dissolve := clampf((DURATION - age) / .55, 0.0, 1.0)
			node.scale = Vector3.ONE * growth * dissolve
		else:
			var travel: Vector3 = particle.origin + particle.velocity * t + Vector3.DOWN * 3.6 * t * t
			travel.y = maxf(.025, travel.y)
			node.position = travel
			node.rotation = Vector3(t * 3.0, float(particle.index) + t * 2.0, t * 4.0)
			node.scale = Vector3.ONE * clampf((DURATION - age) / .3, 0.0, 1.0)
	visible = age < DURATION

func is_finished() -> bool:
	return age >= DURATION
