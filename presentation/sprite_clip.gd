extends Resource
## Ordered presentation frames; never drives simulation events or damage.
@export var atlas: Texture2D
@export var regions: Array[Rect2i] = []
@export var durations: PackedFloat32Array = PackedFloat32Array()
@export var pivot := Vector2.ZERO
@export var looping := true

func validation_error() -> String:
	if atlas == null or regions.is_empty(): return "Missing atlas or frames"
	if durations.size() != regions.size(): return "Each frame needs a duration"
	var bounds := Rect2i(Vector2i.ZERO,Vector2i(atlas.get_size()))
	for i in regions.size():
		if regions[i].size.x <= 0 or regions[i].size.y <= 0 or not bounds.encloses(regions[i]): return "Frame outside atlas"
		if not is_finite(durations[i]) or durations[i] <= 0: return "Invalid duration"
		if regions[i].size != regions[0].size: return "Frames require equal cells for stable pivots"
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
