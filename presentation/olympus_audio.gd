extends Node
class_name OlympusAudio
## Original, deterministic synthesized audio. Observes snapshots; never owns game state.
## Eight bounded voices and per-event cooldowns keep crowded battles comfortable.
const SAMPLE_RATE := 22050
const VOICE_COUNT := 8
var muted := false
var pitch_scale := 1.0
var played_counts: Dictionary = {}
var _clips: Dictionary = {}
var _voices: Array[AudioStreamPlayer] = []
var _last_event := -1
var _last_elapsed := -1.0
var _last_revision := -1
var _tower_health: Dictionary = {}
var _cooldowns: Dictionary = {}
var _finished := false

func _ready() -> void:
	for kind in ["deploy", "summon", "hit", "lightning", "collapse", "victory", "defeat", "draw"]:
		_clips[kind] = _synthesize(kind)
	for i in VOICE_COUNT:
		var voice := AudioStreamPlayer.new()
		voice.bus = &"Master"
		add_child(voice)
		_voices.append(voice)

func _exit_tree() -> void:
	# Detach playback resources before child destruction. Godot's audio server
	# may retain stopped streams until its next mix/update cycle.
	for voice in _voices:
		voice.stop()
		voice.stream = null
	_clips.clear()

func set_muted(value: bool) -> void:
	muted = value
	if muted:
		for voice in _voices: voice.stop()

func play_move_sound() -> void:
	_play("deploy", -20.0)

func consume_state(state: Dictionary) -> void:
	var elapsed := float(state.get("elapsed", 0.0))
	var revision := int(state.get("revision", 0))
	if elapsed < _last_elapsed or revision < _last_revision:
		_last_event = -1
		_tower_health.clear()
		_cooldowns.clear()
		_finished = false
		for voice in _voices: voice.stop()
	_last_elapsed = elapsed
	_last_revision = revision
	for event in state.get("events", []):
		var id := int(event.get("id", -1))
		if id <= _last_event: continue
		_last_event = id
		var kind := str(event.get("kind", ""))
		# Ignore old buffered effects when attaching the presenter mid-match.
		if elapsed - float(event.get("time", elapsed)) > 0.35: continue
		match kind:
			"summon": _limited("summon", elapsed, 0.14, -19.0)
			"hit": _limited("hit", elapsed, 0.18, -27.0)
			"lightning": _limited("lightning", elapsed, 0.3, -17.0)
	for tower in state.get("towers", []):
		var id := str(tower.get("id", ""))
		var hp := float(tower.get("hp", 0))
		if _tower_health.has(id) and float(_tower_health[id]) > 0 and hp <= 0:
			_limited("collapse", elapsed, 0.2, -15.0)
		_tower_health[id] = hp
	if state.get("phase", "playing") == "finished" and not _finished:
		_finished = true
		var winner := int(state.get("winner", 2))
		_play("victory" if winner == 0 else ("defeat" if winner == 1 else "draw"), -15.0)

func _limited(kind: String, elapsed: float, gap: float, volume: float) -> void:
	if elapsed < float(_cooldowns.get(kind, -100.0)): return
	_cooldowns[kind] = elapsed + gap
	_play(kind, volume)

func _play(kind: String, volume: float) -> void:
	if muted or not _clips.has(kind): return
	var available: AudioStreamPlayer = null
	for voice in _voices:
		if not voice.playing:
			available = voice
			break
	# Never interrupt a fanfare or explosion for a minor combat tick.
	if available == null:
		if kind in ["hit", "deploy", "summon"]: return
		for voice in _voices:
			if voice.get_meta("kind", "") in ["hit", "deploy", "summon"]:
				available = voice
				break
	if available == null: return
	available.stream = _clips[kind]
	available.volume_db = volume
	available.pitch_scale = clampf(pitch_scale, 0.5, 2.0)
	available.set_meta("kind", kind)
	available.play()
	played_counts[kind] = int(played_counts.get(kind, 0)) + 1

func _synthesize(kind: String) -> AudioStreamWAV:
	var duration: float = {"deploy":0.09, "summon":0.48, "hit":0.10, "lightning":0.65, "collapse":1.05, "victory":1.7, "defeat":1.1, "draw":0.8}[kind]
	var bytes := PackedByteArray()
	var count := int(SAMPLE_RATE * duration)
	bytes.resize(count * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 5909 + kind.hash()
	var low_noise := 0.0
	for i in count:
		var t := float(i) / SAMPLE_RATE
		var noise := rng.randf_range(-1.0, 1.0)
		low_noise = lerpf(low_noise, noise, 0.13)
		var sample := 0.0
		match kind:
			"deploy": sample = sin(TAU * 780.0 * t) * exp(-t * 65.0) * 0.45
			"hit": sample = (sin(TAU * 185.0 * t) * 0.48 + noise * 0.22) * exp(-t * 60.0)
			"summon":
				for note in 3:
					var age := t - note * 0.045
					if age >= 0: sample += _bell(age, [440.0, 554.37, 659.25][note]) * 0.28
			"lightning":
				sample = noise * exp(-t * 24.0) * 0.32 + low_noise * exp(-t * 5.0) * 1.5
				sample += sin(TAU * (75.0 * t - 20.0 * t * t)) * exp(-t * 8.0) * 0.45
			"collapse":
				sample = low_noise * exp(-t * 3.8) * 1.8 + sin(TAU * 57.0 * t) * exp(-t * 6.0) * 0.34
				for impact in 4:
					var age := t - float(impact) * 0.11
					if age >= 0: sample += noise * exp(-age * 55.0) * 0.14
			"victory", "defeat", "draw":
				var notes: Array = [392.0, 493.88, 587.33, 783.99] if kind == "victory" else ([392.0, 349.23, 261.63] if kind == "defeat" else [392.0, 523.25])
				for note in notes.size():
					var age := t - note * 0.17
					if age >= 0: sample += _bell(age, notes[note]) * 0.31
		# Brief ramps prevent digital clicks; no clip can exceed full scale.
		sample *= minf(t / 0.003, 1.0) * minf((duration - t) / 0.04, 1.0)
		bytes.encode_s16(i * 2, int(clampf(sample, -0.95, 0.95) * 32767.0))
	var clip := AudioStreamWAV.new()
	clip.format = AudioStreamWAV.FORMAT_16_BITS
	clip.mix_rate = SAMPLE_RATE
	clip.stereo = false
	clip.data = bytes
	return clip

func _bell(age: float, frequency: float) -> float:
	return (sin(TAU * frequency * age) + sin(TAU * frequency * 2.01 * age) * 0.2 + sin(TAU * frequency * 3.98 * age) * 0.07) * exp(-age * 5.5)
