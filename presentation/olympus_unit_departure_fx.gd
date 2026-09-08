extends Node3D
## A short, manually clocked copy of a removed unit's last visible frame.
## The board owns this cosmetic node and frees it immediately on match reset.
const LIFETIME := 0.78
var elapsed := 0.0
var ghost: Sprite3D
var _material: ShaderMaterial
var _flecks: Array[Sprite3D] = []
var drawn_actor

func begin(source: Sprite3D, defeat_clip = null) -> bool:
	if ghost != null or not is_instance_valid(source) or source.texture == null or not is_inside_tree(): return false
	if defeat_clip != null:
		if defeat_clip.looping or not defeat_clip.validation_error().is_empty(): return false
		var duration := 0.0
		for seconds in defeat_clip.durations: duration += seconds
		if duration > LIFETIME + .00001: return false
	global_transform = source.global_transform
	if defeat_clip != null:
		# Preserve parent placement, but do not multiply the old pose's draw scale
		# into the new sheet's independently authored scale.
		global_transform = source.get_parent_node_3d().global_transform
		global_position = source.global_position
		drawn_actor = preload("res://presentation/pixel_actor.gd").new()
		ghost = drawn_actor
		add_child(ghost)
		drawn_actor.set_clip(defeat_clip)
	else:
		ghost = Sprite3D.new()
		ghost.texture = source.texture.duplicate()
		add_child(ghost)
	ghost.pixel_size = source.pixel_size
	if drawn_actor == null: ghost.offset = source.offset
	ghost.centered = source.centered
	ghost.flip_h = source.flip_h
	ghost.flip_v = source.flip_v
	ghost.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	ghost.shaded = false
	ghost.double_sided = true
	_material = ShaderMaterial.new()
	_material.shader = preload("res://presentation/olympus_unit_departure.gdshader")
	var atlas: Texture2D = ghost.texture
	if atlas is AtlasTexture: atlas = atlas.atlas
	_material.set_shader_parameter("source_atlas", atlas)
	var material_source = ghost if drawn_actor != null else source
	if material_source.material_override is ShaderMaterial:
		for parameter in ["cutout", "depth_bias"]:
			var value = material_source.material_override.get_shader_parameter(parameter)
			if value != null: _material.set_shader_parameter(parameter, value)
		_material.set_shader_parameter("magenta_backing", true)
	ghost.material_override = _material
	if drawn_actor != null: return true
	var palette := [Color("bf954e"), Color("ebe0bd"), Color("426d89")]
	for i in 12:
		var fleck := Sprite3D.new()
		var image := Image.create(3, 3, false, Image.FORMAT_RGBA8)
		image.fill(palette[i % palette.size()])
		fleck.texture = ImageTexture.create_from_image(image)
		fleck.pixel_size = (0.025 + (i % 3) * 0.009) / 3.0
		fleck.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		fleck.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		fleck.shaded = false
		fleck.visible = false
		add_child(fleck)
		_flecks.append(fleck)
	return true

func advance_visual(delta: float) -> void:
	if ghost == null or not is_finite(delta) or delta <= 0.0: return
	elapsed = minf(elapsed + delta, LIFETIME)
	var phase := elapsed / LIFETIME
	if drawn_actor != null:
		drawn_actor.show_time(elapsed)
		_material.set_shader_parameter("departure", smoothstep(.88, 1.0, phase))
		if elapsed >= LIFETIME: queue_free()
		return
	_material.set_shader_parameter("departure", smoothstep(0.12, 0.84, phase))
	# A modest loss of posture, not a flattened building-like squash.
	ghost.position.y = -0.1 * phase
	ghost.scale.y = 1.0 - 0.18 * phase
	for i in _flecks.size():
		var fleck := _flecks[i]
		var t := clampf((phase - 0.18) / 0.82, 0.0, 1.0)
		var angle := float(i) * 2.399963
		fleck.visible = phase > 0.18 and phase < 0.95
		fleck.position = Vector3(cos(angle) * t * 0.36, 0.18 + (i % 5) * 0.17 + sin(t * PI) * 0.15 - t * 0.22, sin(angle) * t * 0.24)
		fleck.scale = Vector3.ONE * (1.0 - t)
	if elapsed >= LIFETIME: queue_free()
