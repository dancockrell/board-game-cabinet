extends Sprite3D
## Camera-facing pixel presentation; caller supplies the authoritative clip/time.
const Clip = preload("res://presentation/sprite_clip.gd")
var clip: Clip
var _atlas := AtlasTexture.new()
var _shown := -1
var _rest_clip: Clip
var _reaction_elapsed := -1.0
var _last_hit_event := -1
var _last_attack_event := -1
var _motion_clip: Clip
var _motion_elapsed := 0.0
var _rest_elapsed := 0.0
var damage_flash := 0.0

func set_damage_flash(strength: float) -> void:
	if not is_finite(strength): return
	damage_flash=clampf(strength,0.0,1.0)
	if material_override is ShaderMaterial:
		material_override.set_shader_parameter("damage_flash", damage_flash)
		modulate=Color.WHITE
	else:
		modulate=Color(1.0,1.0-damage_flash*.18,1.0-damage_flash*.36)

func set_locomotion(walk: Clip) -> bool:
	if walk != null and (not walk.looping or not walk.validation_error().is_empty()): return false
	if walk == _motion_clip: return true
	# Locomotion clips represent the same stride cycle in different facings.
	# Transfer phase rather than restarting the leading foot on every turn.
	var phase := 0.0
	if _motion_clip != null:
		phase = fposmod(_motion_elapsed, _clip_duration(_motion_clip)) / _clip_duration(_motion_clip)
	_motion_clip=walk
	_motion_elapsed=phase * _clip_duration(walk) if walk != null else 0.0
	if _reaction_elapsed < 0:
		var accepted := set_clip(walk if walk != null else _rest_clip)
		if accepted: show_time(_motion_elapsed if walk != null else _rest_elapsed)
		return accepted
	return true

func _clip_duration(value: Clip) -> float:
	var duration := 0.0
	for seconds in value.durations: duration += seconds
	return duration

func reset_playback(rest: Clip) -> bool:
	if not set_clip(rest): return false
	_rest_clip=rest
	_motion_clip=null
	_motion_elapsed=0.0
	_rest_elapsed=0.0
	set_damage_flash(0.0)
	_reaction_elapsed=-1.0
	_last_hit_event=-1
	_last_attack_event=-1
	return true

func play_attack(event_id: int, action: Clip) -> bool:
	if event_id<=_last_attack_event or action==null or action.looping: return false
	if not set_clip(action): return false
	_last_attack_event=event_id
	_reaction_elapsed=0.0
	return true

func set_rest_pose(rest: Clip) -> bool:
	if rest==null or not rest.looping or not rest.validation_error().is_empty(): return false
	if rest==_rest_clip: return true
	var phase := fposmod(_rest_elapsed, _clip_duration(_rest_clip)) / _clip_duration(_rest_clip) if _rest_clip != null else 0.0
	_rest_clip=rest
	_rest_elapsed=phase * _clip_duration(rest)
	if _reaction_elapsed<0 and _motion_clip==null:
		set_clip(rest)
		show_time(_rest_elapsed)
		return true
	return true

func react_to_hit(event_id: int, reaction: Clip) -> bool:
	if event_id <= _last_hit_event or reaction == null or reaction.looping: return false
	if not set_clip(reaction): return false
	_last_hit_event=event_id
	_reaction_elapsed=0.0
	return true

func advance_visual(delta: float) -> void:
	if not is_finite(delta) or delta < 0: return
	if _reaction_elapsed < 0:
		if _motion_clip != null:
			_motion_elapsed+=delta
			show_time(_motion_elapsed)
		elif _rest_clip != null:
			_rest_elapsed+=delta
			show_time(_rest_elapsed)
		return
	_reaction_elapsed+=delta
	var duration := _clip_duration(clip)
	if _reaction_elapsed >= duration and _rest_clip != null:
		# Hold the stride during the action; only the time after its end belongs
		# to locomotion. This also makes recovery independent of render rate.
		if _motion_clip != null: _motion_elapsed += _reaction_elapsed - duration
		else: _rest_elapsed += _reaction_elapsed - duration
		set_clip(_motion_clip if _motion_clip != null else _rest_clip)
		show_time(_motion_elapsed if _motion_clip != null else _rest_elapsed)
		_reaction_elapsed=-1.0
	else:
		show_time(_reaction_elapsed)


func _init() -> void:
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	alpha_scissor_threshold = .5
	shaded = false
	double_sided = true

func set_clip(value: Clip) -> bool:
	if value == null or not value.validation_error().is_empty(): return false
	clip = value
	scale = Vector3.ONE * clip.draw_scale
	material_override = null
	if clip.magenta_backing:
		var keyed := ShaderMaterial.new()
		keyed.shader = preload("res://presentation/pixel_chroma.gdshader")
		keyed.set_shader_parameter("source_atlas", clip.atlas)
		keyed.set_shader_parameter("depth_bias", clip.depth_bias)
		material_override = keyed
	set_damage_flash(damage_flash)
	_atlas.atlas = clip.atlas
	texture = _atlas
	_shown = -1
	show_time(0)
	return true

func show_time(seconds: float) -> void:
	if clip == null: return
	var index := clip.frame_at(seconds)
	if index < 0 or index == _shown: return
	_shown=index
	scale=Vector3.ONE * (clip.draw_scale if clip.frame_draw_scales.is_empty() else clip.frame_draw_scales[index])
	var source: Texture2D = clip.atlas if clip.frame_atlases.is_empty() else clip.frame_atlases[index]
	_atlas.atlas = source
	_atlas.region=Rect2(clip.regions[index])
	var half_cell := Vector2(clip.regions[index].size)*.5
	var anchor: Vector2 = clip.pivot if clip.frame_pivots.is_empty() else clip.frame_pivots[index]
	offset=Vector2(half_cell.x-anchor.x,anchor.y-half_cell.y)
	if clip.magenta_backing:
		material_override.set_shader_parameter("source_atlas", source)
		var cut := Rect2i() if clip.frame_cutouts.is_empty() else clip.frame_cutouts[index]
		var dimensions := source.get_size()
		material_override.set_shader_parameter("cutout", Vector4(cut.position.x/dimensions.x,cut.position.y/dimensions.y,cut.size.x/dimensions.x,cut.size.y/dimensions.y))
