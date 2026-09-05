extends AudioStreamPlayer
class_name MoveAudio
## Original synthesized wooden tap. No network, imported clips, or audio dependency.
var muted: bool = false

func _ready() -> void:
    stream = _make_tap()
    volume_db = -16.0
    max_polyphony = 2

func set_muted(value: bool) -> void:
    muted = value
    if muted:
        stop()

func play_move_sound() -> void:
    if not muted:
        if stream == null:
            stream = _make_tap()
        play()

func _make_tap() -> AudioStreamWAV:
    var sample_rate: int = 22050
    var count: int = int(sample_rate * 0.115)
    var bytes := PackedByteArray()
    bytes.resize(count * 2)
    var rng := RandomNumberGenerator.new()
    rng.seed = 7919
    for i in range(count):
        var time_: float = float(i) / sample_rate
        var attack: float = minf(time_ / 0.0018, 1.0)
        var body: float = sin(TAU * 410.0 * time_) * exp(-time_ * 51.0)
        var overtone: float = sin(TAU * 1130.0 * time_) * exp(-time_ * 83.0) * 0.24
        var strike: float = rng.randf_range(-1.0, 1.0) * exp(-time_ * 225.0) * 0.18
        var sample: int = int(clampf((body + overtone + strike) * attack * 0.6, -1.0, 1.0) * 32767.0)
        bytes.encode_s16(i * 2, sample)
    var clip := AudioStreamWAV.new()
    clip.format = AudioStreamWAV.FORMAT_16_BITS
    clip.mix_rate = sample_rate
    clip.stereo = false
    clip.data = bytes
    return clip
