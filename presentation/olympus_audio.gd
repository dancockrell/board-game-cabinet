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
var music_enabled := true
var _match_active := false
var _music: AudioStreamPlayer
var _last_countdown := -1

func _ready() -> void:
	for kind in ["deploy", "summon", "hit", "lightning", "collapse", "victory", "defeat", "draw", "count_3", "count_2", "count_1", "count_0"]:
		_clips[kind] = _synthesize(kind)
	for i in VOICE_COUNT:
		var voice := AudioStreamPlayer.new()
		voice.bus = &"Master"
		add_child(voice)
		_voices.append(voice)

	_music = AudioStreamPlayer.new()
	_music.stream = _make_music()
	_music.volume_db = -28.0
	add_child(_music)

func _exit_tree() -> void:
	# Detach playback resources before child destruction. Godot's audio server
	# may retain stopped streams until its next mix/update cycle.
	for voice in _voices:
		voice.stop()
		voice.stream = null
	if is_instance_valid(_music):
		_music.stop()
		_music.stream = null
	_clips.clear()

func set_muted(value: bool) -> void:
	muted = value
	if muted:
		for voice in _voices: voice.stop()
	_update_music()

func set_music_enabled(value: bool) -> void:
	music_enabled = value
	_update_music()

func start_match() -> void:
	_match_active = true
	_update_music()

func stop_match() -> void:
	_match_active = false
	_last_countdown = -1
	_update_music()

func _update_music() -> void:
	if not is_instance_valid(_music): return
	if muted or not music_enabled or not _match_active:
		_music.stop()
	elif not _music.playing:
		_music.play()

func play_countdown(number: int) -> void:
	if number < 0 or number > 3 or number == _last_countdown: return
	_last_countdown = number
	_play("count_%s" % number, -16.0 if number == 0 else -19.0)

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
		stop_match()
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
	var duration: float = {"deploy":0.09, "summon":0.48, "hit":0.10, "lightning":0.65, "collapse":1.05, "victory":1.7, "defeat":1.1, "draw":0.8, "count_3":0.42, "count_2":0.42, "count_1":0.42, "count_0":0.75}[kind]
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
			"count_3", "count_2", "count_1", "count_0":
				var number := int(kind.trim_prefix("count_"))
				var frequency: float = [523.25, 392.0, 349.23, 261.63][number]
				sample = _bell(t, frequency) * 0.4 + sin(TAU * (100.0 * t - 22.0 * t * t)) * exp(-t * 18.0) * 0.28
				if number == 0:
					sample += _bell(t, 659.25) * 0.2 + _bell(t, 783.99) * 0.2
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

func _make_music() -> AudioStreamWAV:
	# Original 16-second modal lyre phrase. The pentatonic pitches and open
	# fourth/fifth bass suggest an ancient instrument without claiming reconstruction.
	# Each decaying note is wrapped into the loop buffer so tails cross its seam.
	var length := SAMPLE_RATE * 16
	var mix: Array[float] = []
	mix.resize(length)
	mix.fill(0.0)
	var melody := [[0.0, 293.665], [1.0, 440.0], [1.75, 392.0], [3.0, 329.628],
		[4.5, 293.665], [6.0, 220.0], [7.0, 293.665], [8.0, 392.0],
		[9.5, 440.0], [11.0, 587.33], [12.5, 440.0], [14.0, 392.0], [15.5, 293.665]]
	for note in melody: _mix_pluck(mix, float(note[0]), float(note[1]), 0.22)
	for beat in [0, 4, 8, 12]:
		_mix_pluck(mix, float(beat), 146.832 if beat < 8 else 196.0, 0.19)
		_mix_pluck(mix, float(beat) + 0.04, 220.0 if beat < 8 else 293.665, 0.1)
	var rng := RandomNumberGenerator.new()
	rng.seed = 631
	for beat in 16:
		for i in int(SAMPLE_RATE * 0.25):
			var t := float(i) / SAMPLE_RATE
			var drum := sin(TAU * (92.0 * t - 55.0 * t * t)) * exp(-t * 26.0) * 0.1
			drum += rng.randf_range(-1, 1) * exp(-t * 90.0) * 0.015
			mix[(beat * SAMPLE_RATE + i) % length] += drum * minf(t / 0.004, 1.0)
	var bytes := PackedByteArray()
	bytes.resize(length * 2)
	for i in length: bytes.encode_s16(i * 2, int(clampf(mix[i], -0.9, 0.9) * 32767.0))
	var clip := AudioStreamWAV.new()
	clip.format = AudioStreamWAV.FORMAT_16_BITS
	clip.mix_rate = SAMPLE_RATE
	clip.data = bytes
	clip.loop_mode = AudioStreamWAV.LOOP_FORWARD
	clip.loop_begin = 0
	clip.loop_end = length
	return clip

func _mix_pluck(mix: Array[float], start: float, frequency: float, gain: float) -> void:
	var offset := int(start * SAMPLE_RATE)
	var count := int(SAMPLE_RATE * 2.4)
	for i in count:
		var t := float(i) / SAMPLE_RATE
		var sample := sin(TAU * frequency * t) * exp(-t * 3.2)
		sample += sin(TAU * frequency * 2.0 * t) * exp(-t * 6.0) * 0.36
		sample += sin(TAU * frequency * 3.0 * t) * exp(-t * 9.0) * 0.13
		sample *= gain * minf(t / 0.004, 1.0) * minf((2.4 - t) / 0.1, 1.0)
		mix[(offset + i) % mix.size()] += sample
