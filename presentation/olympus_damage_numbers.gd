extends Node3D
## Short damage bursts, driven by the same pause-aware clock as the board.
const LIFETIME := 0.72
const MERGE_WINDOW := 0.18
const MAX_LABELS := 24
var entries: Array[Dictionary] = []

func clear() -> void:
	for entry in entries:
		entry.label.queue_free()
	entries.clear()

func show_loss(target_id: int, anchor: Vector3, amount: float) -> void:
	if not is_finite(amount) or amount <= 0.0: return
	for entry in entries:
		if entry.target == target_id and entry.age <= MERGE_WINDOW:
			entry.amount += amount
			entry.label.text = "−%d" % maxi(1, roundi(entry.amount))
			return
	while entries.size() >= MAX_LABELS:
		var oldest: Dictionary = entries.pop_front()
		oldest.label.queue_free()
	# Use a few clear slots above the target instead of drawing every hit over
	# the sprite's face. Recent nearby bursts prefer different horizontal slots.
	var slots := [0.0, -0.42, 0.42, -0.84, 0.84]
	var origin := anchor
	var best_clearance := -1.0
	for slot in slots:
		var candidate := anchor + Vector3(slot, 0, 0)
		var clearance := 10.0
		for entry in entries:
			if absf(entry.origin.z-candidate.z) < 0.85 and absf(entry.origin.y-candidate.y) < 0.7:
				clearance = minf(clearance, absf(entry.origin.x-candidate.x))
		if clearance > best_clearance:
			best_clearance = clearance
			origin = candidate
		if clearance >= 0.4: break
	var label := Label3D.new()
	label.text = "−%d" % maxi(1, roundi(amount))
	label.font_size = 36
	label.pixel_size = 0.007
	label.outline_size = 6
	label.modulate = Color("fff2bc")
	label.outline_modulate = Color("583328")
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	add_child(label)
	label.position = origin
	entries.append({"target":target_id, "label":label, "origin":origin, "age":0.0, "amount":amount})

func advance_visual(delta: float) -> void:
	if not is_finite(delta) or delta <= 0.0: return
	for index in range(entries.size()-1, -1, -1):
		var entry: Dictionary = entries[index]
		entry.age += delta
		if entry.age >= LIFETIME:
			entry.label.queue_free()
			entries.remove_at(index)
			continue
		var t: float = entry.age / LIFETIME
		entry.label.position = entry.origin + Vector3(0, 0.42*(1.0-pow(1.0-t, 2.0)), 0)
		entry.label.modulate.a = 1.0-clampf((t-0.6)/0.4, 0.0, 1.0)
