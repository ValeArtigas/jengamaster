extends Node

const RATE := 22050

var _players: Array = []
var _next := 0
var _streams: Dictionary = {}

func _ready() -> void:
	for i in 8:
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_players.append(p)
	_streams["correct"] = _sequence([659.25, 783.99, 1046.5], 0.09, 0.35)
	_streams["wrong"] = _sequence([311.13, 233.08], 0.18, 0.4)
	_streams["pop"] = _sequence([880.0], 0.08, 0.3)
	_streams["click"] = _sequence([523.25], 0.05, 0.28)
	_streams["win"] = _sequence([523.25, 659.25, 783.99, 1046.5, 1318.51], 0.13, 0.35)
	_streams["lose"] = _sequence([392.0, 329.63, 261.63, 196.0], 0.16, 0.4)

func play(sound: String) -> void:
	if not _streams.has(sound):
		return
	var p: AudioStreamPlayer = _players[_next]
	_next = (_next + 1) % _players.size()
	p.stream = _streams[sound]
	p.play()

func _sequence(freqs: Array, note_time: float, volume: float) -> AudioStreamWAV:
	var total := int(RATE * note_time * float(freqs.size())) + 1
	var data := PackedByteArray()
	data.resize(total * 2)
	var idx := 0
	for f in freqs:
		var count := int(RATE * note_time)
		for i in count:
			var t := float(i) / float(RATE)
			var env := sin(PI * (float(i) / float(count)))
			var s := sin(TAU * float(f) * t) * env * volume
			data.encode_s16(idx * 2, int(clamp(s, -1.0, 1.0) * 32767.0))
			idx += 1
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = RATE
	stream.stereo = false
	stream.data = data
	return stream
