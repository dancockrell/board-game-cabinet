extends Sprite3D
## Camera-facing pixel presentation; caller supplies the authoritative clip/time.
const Clip = preload("res://presentation/sprite_clip.gd")
var clip: Clip
var _atlas := AtlasTexture.new()
var _shown := -1
var _rest_clip: Clip
var _reaction_elapsed := -1.0
var _last_hit_event := -1

func reset_playback(rest: Clip) -> bool:
	if not set_clip(rest): return false
	_rest_clip=rest
	_reaction_elapsed=-1.0
	_last_hit_event=-1
	return true

func react_to_hit(event_id: int, reaction: Clip) -> bool:
	if event_id <= _last_hit_event or reaction == null or reaction.looping: return false
	if not set_clip(reaction): return false
	_last_hit_event=event_id
	_reaction_elapsed=0.0
	return true

func advance_visual(delta: float) -> void:
	if _reaction_elapsed < 0 or not is_finite(delta) or delta < 0: return
	_reaction_elapsed+=delta
	var duration:=0.0
	for seconds in clip.durations: duration+=seconds
	if _reaction_elapsed >= duration and _rest_clip != null:
		set_clip(_rest_clip)
		_reaction_elapsed=-1.0
	else:
		show_time(_reaction_elapsed)


func _init() -> void:
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	alpha_scissor_threshold = .5
	shaded = false
	double_sided = true

func set_clip(value: Clip) -> bool:
	if value == null or not value.validation_error().is_empty(): return false
	clip = value
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
	_atlas.region=Rect2(clip.regions[index])
	var half_cell := Vector2(clip.regions[index].size)*.5
	offset=Vector2(half_cell.x-clip.pivot.x,clip.pivot.y-half_cell.y)
