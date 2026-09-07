extends Resource
## Ordered presentation frames; never drives simulation events or damage.
@export var atlas: Texture2D
## Optional source per frame, allowing coherent generated sheets to stay intact.
@export var frame_atlases: Array[Texture2D] = []
@export var regions: Array[Rect2i] = []
@export var durations: PackedFloat32Array = PackedFloat32Array()
@export var pivot := Vector2.ZERO
@export var looping := true
@export var magenta_backing := false
@export var frame_pivots: Array[Vector2] = []
@export var frame_cutouts: Array[Rect2i] = []
@export var draw_scale := 1.0
@export var depth_bias := 0.0

func validation_error() -> String:
	if atlas == null or regions.is_empty(): return "Missing atlas or frames"
	if not frame_atlases.is_empty() and frame_atlases.size() != regions.size(): return "Each frame needs a source atlas"
	if durations.size() != regions.size(): return "Each frame needs a duration"
	if not frame_pivots.is_empty() and frame_pivots.size()!=regions.size(): return "Each irregular frame needs a pivot"
	if not frame_cutouts.is_empty() and (not magenta_backing or frame_cutouts.size()!=regions.size()): return "Cutouts require keyed frames and one rectangle per frame"
	if not is_finite(draw_scale) or draw_scale<=0: return "Invalid draw scale"
	if not is_finite(depth_bias) or depth_bias<0 or depth_bias>0.3 or (depth_bias>0 and not magenta_backing): return "Invalid keyed-sprite depth bias"
	for i in regions.size():
		var source := atlas if frame_atlases.is_empty() else frame_atlases[i]
		if source == null: return "Missing frame source atlas"
		var bounds := Rect2i(Vector2i.ZERO,Vector2i(source.get_size()))
		if regions[i].size.x <= 0 or regions[i].size.y <= 0 or not bounds.encloses(regions[i]): return "Frame outside atlas"
		if not is_finite(durations[i]) or durations[i] <= 0: return "Invalid duration"
		if frame_pivots.is_empty() and regions[i].size != regions[0].size: return "Unequal cells need individual pivots"
		if not frame_pivots.is_empty() and not frame_pivots[i].is_finite(): return "Invalid frame pivot"
		if not frame_cutouts.is_empty():
			var cut:=frame_cutouts[i]
			if cut.size.x<0 or cut.size.y<0 or (cut.has_area() and not bounds.encloses(cut)): return "Invalid cutout"
	if not pivot.is_finite(): return "Invalid pivot"
	return ""

func frame_at(seconds: float) -> int:
	if not validation_error().is_empty() or not is_finite(seconds): return -1
	var length := 0.0
	for duration in durations: length += duration
	var cursor := fposmod(maxf(0,seconds),length) if looping else minf(maxf(0,seconds),length)
	for i in durations.size():
		if cursor < durations[i]: return i
		cursor -= durations[i]
	return durations.size()-1
