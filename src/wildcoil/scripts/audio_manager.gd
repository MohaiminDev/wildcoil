extends Node
class_name AudioManager

var muted := false
var music_player: AudioStreamPlayer

func play_hit() -> void:
	_play_tone(260.0, 0.045, 0.11)

func play_heavy() -> void:
	_play_tone(92.0, 0.075, 0.16)

func play_pickup() -> void:
	_play_tone(520.0, 0.065, 0.09)

func play_boss_warning() -> void:
	_play_tone(138.0, 0.11, 0.13)

func play_ui() -> void:
	_play_tone(620.0, 0.035, 0.055)

func play_victory() -> void:
	_play_tone(440.0, 0.14, 0.12)

func play_stage_music() -> void:
	if muted or music_player != null or _audio_disabled_for_headless():
		return
	music_player = AudioStreamPlayer.new()
	music_player.name = "GeneratedStagePulse"
	music_player.volume_db = -24.0
	music_player.stream = _make_loop_stream(82.0, 0.32, 0.035)
	add_child(music_player)
	music_player.play()

func _play_tone(frequency: float, duration: float, volume: float) -> void:
	if muted or _audio_disabled_for_headless():
		return
	var player := AudioStreamPlayer.new()
	player.stream = _make_tone_stream(frequency, duration, volume)
	player.volume_db = -12.0
	add_child(player)
	player.play()
	var tween := create_tween()
	tween.tween_interval(duration + 0.04)
	tween.tween_callback(player.queue_free)

func _make_tone_stream(frequency: float, duration: float, volume: float) -> AudioStreamWAV:
	var mix_rate := 22050
	var frame_count := maxi(1, int(float(mix_rate) * duration))
	var data := PackedByteArray()
	data.resize(frame_count * 2)
	for i in range(frame_count):
		var t := float(i) / float(mix_rate)
		var fade := 1.0 - (float(i) / maxf(float(frame_count), 1.0))
		var sample := int(clampf(sin(t * TAU * frequency) * volume * fade, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, sample)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = mix_rate
	stream.stereo = false
	stream.data = data
	return stream

func _make_loop_stream(frequency: float, duration: float, volume: float) -> AudioStreamWAV:
	var stream := _make_tone_stream(frequency, duration, volume)
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = stream.data.size() / 2
	return stream

func _exit_tree() -> void:
	if music_player != null:
		music_player.stop()
		music_player.stream = null

func _audio_disabled_for_headless() -> bool:
	return DisplayServer.get_name() == "headless"
