extends SceneTree
const SOUND = preload("res://presentation/olympus_audio.gd")
var checks := 0
var failed := false

func _initialize() -> void:
	call_deferred("_run")

func _check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		push_error(message)
		failed = true

func _run() -> void:
	var audio := SOUND.new()
	root.add_child(audio)
	_check(audio._voices.size() == 8, "bounded voice pool")
	for kind in audio._clips:
		var clip: AudioStreamWAV = audio._clips[kind]
		_check(clip.mix_rate == 22050 and clip.data.size() > 2000, "valid PCM " + kind)
		var peak := 0
		for i in range(0, clip.data.size(), 2): peak = maxi(peak, absi(clip.data.decode_s16(i)))
		_check(peak > 200 and peak < 32767, "audible unclipped " + kind)
	_check(audio._clips["count_3"].data != audio._clips["count_2"].data and audio._clips["count_1"].data != audio._clips["count_0"].data, "countdown stings have distinct waveforms")
	var music: AudioStreamWAV = audio._music.stream
	_check(not audio._music.playing, "music stays silent before battle")
	_check(music.loop_mode == AudioStreamWAV.LOOP_FORWARD and music.loop_end == 352800, "bounded seamless music loop")
	var seam_delta := absi(music.data.decode_s16(0) - music.data.decode_s16(music.data.size() - 2))
	_check(seam_delta < 500, "music seam has no discontinuity")
	var music_pcm := music.data
	var music_peak := 0
	var square_sum := 0.0
	for i in range(0, music_pcm.size(), 2):
		var value := music_pcm.decode_s16(i)
		music_peak = maxi(music_peak, absi(value))
		square_sum += float(value) * value
	_check(music_peak > 1000 and music_peak < 30000, "music audible without clipping")
	print("Music PCM: peak=%s RMS=%.1f seam_delta=%s" % [music_peak, sqrt(square_sum / 352800.0), seam_delta])
	audio.start_match()
	_check(audio._music.playing, "start match begins music")
	audio.set_muted(true)
	_check(not audio._music.playing, "mute stops music")
	audio.play_countdown(3)
	_check(audio.played_counts.get("count_3", 0) == 0, "mute silences countdown")
	audio.set_muted(false)
	_check(audio._music.playing, "unmute restores active match bed")
	audio.set_music_enabled(false)
	_check(not audio._music.playing, "music can be disabled independently")
	audio.set_music_enabled(true)
	audio.stop_match()
	_check(not audio._music.playing, "stop match ends music")
	for number in [2, 1, 0, 3]:
		audio.play_countdown(number)
		audio.play_countdown(number)
		_check(audio.played_counts.get("count_%s" % number, 0) == 1, "one sting for countdown %s" % number)
	for voice in audio._voices: voice.stop()
	audio.start_match()
	var state := {"elapsed":1.0, "revision":1, "phase":"playing", "events":[{"id":0, "kind":"summon", "time":1.0}], "towers":[{"id":"blue", "hp":100}]}
	var original := state.duplicate(true)
	audio.consume_state(state)
	audio.consume_state(state)
	_check(audio.played_counts.get("summon", 0) == 1, "repeat snapshots do not replay audio")
	_check(state == original, "snapshot is untouched")
	for voice in audio._voices: voice.stop()
	state.events = [{"id":1, "kind":"hit", "time":1.0}, {"id":2, "kind":"hit", "time":1.0}, {"id":3, "kind":"hit", "time":1.0}]
	audio.consume_state(state)
	_check(audio.played_counts.get("hit", 0) == 1, "crowded attacks are rate limited")
	audio.set_muted(true)
	state.events = [{"id":4, "kind":"lightning", "time":1.0}]
	audio.consume_state(state)
	audio.set_muted(false)
	audio.consume_state(state)
	_check(audio.played_counts.get("lightning", 0) == 0, "unmute never replays muted events")
	state.towers[0].hp = 0
	audio.consume_state(state)
	audio.consume_state(state)
	_check(audio.played_counts.get("collapse", 0) == 1, "tower falls once")
	state.phase = "finished"
	state.winner = 0
	audio.consume_state(state)
	audio.consume_state(state)
	_check(audio.played_counts.get("victory", 0) == 1, "one victory fanfare")
	_check(not audio._music.playing, "result automatically ends music")
	state.elapsed = 0.0
	state.revision = 0
	state.phase = "playing"
	state.events = []
	state.towers[0].hp = 100
	audio.consume_state(state)
	state.elapsed = 0.1
	state.events = [{"id":0, "kind":"summon", "time":0.1}]
	audio.consume_state(state)
	_check(audio.played_counts.get("summon", 0) == 2, "new match resets event cursor")
	audio.free()
	# Let the audio server retire playback objects after node destruction.
	await create_timer(0.3).timeout
	print("Olympus audio: %s checks, failed=%s" % [checks, failed])
	quit(1 if failed else 0)
