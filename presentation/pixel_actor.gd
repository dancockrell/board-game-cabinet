extends Sprite3D
## Camera-facing pixel presentation; caller supplies the authoritative clip/time.
const Clip = preload("res://presentation/sprite_clip.gd")
var clip: Clip
var _atlas := AtlasTexture.new()
var _shown := -1

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
