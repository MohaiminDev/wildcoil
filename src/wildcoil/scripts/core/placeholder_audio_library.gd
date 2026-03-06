class_name PlaceholderAudioLibrary
extends RefCounted

const SAMPLE_RATE := 22050


static func make_explore_loop() -> AudioStreamWAV:
	return build_loop([82.0, 123.0, 164.0], 1.8, 0.18, 0.10, 0.14)


static func make_combat_loop() -> AudioStreamWAV:
	return build_loop([98.0, 147.0, 196.0], 1.2, 0.24, 0.55, 0.18)


static func make_clear_loop() -> AudioStreamWAV:
	return build_loop([164.0, 220.0, 246.0], 1.6, 0.16, 0.08, 0.08)


static func make_boss_loop() -> AudioStreamWAV:
	return build_loop([73.0, 110.0, 147.0, 220.0], 1.3, 0.24, 0.62, 0.12)


static func make_spectacle_stinger() -> AudioStreamWAV:
	return build_sweep(120.0, 420.0, 1.4, 0.32)


static func build_loop(frequencies: Array[float], duration: float, amplitude: float, pulse_strength: float, wobble_depth: float) -> AudioStreamWAV:
	var sample_count := maxi(int(SAMPLE_RATE * duration), 1)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	for sample_index in range(sample_count):
		var time := float(sample_index) / float(SAMPLE_RATE)
		var sample := 0.0
		for frequency_index in range(frequencies.size()):
			var frequency := frequencies[frequency_index] * (1.0 + wobble_depth * sin(TAU * time * 0.35 + float(frequency_index)))
			sample += sin(TAU * time * frequency + float(frequency_index) * 0.45)
		sample /= maxf(float(frequencies.size()), 1.0)
		var pulse := lerpf(1.0, 0.35 + 0.65 * maxf(sin(TAU * time * 2.0), 0.0), pulse_strength)
		var fade_in := minf(time / 0.08, 1.0)
		data.encode_s16(sample_index * 2, int(round(clampf(sample * amplitude * pulse * fade_in, -1.0, 1.0) * 32767.0)))
	return build_stream(data, sample_count, true)


static func build_sweep(start_frequency: float, end_frequency: float, duration: float, amplitude: float) -> AudioStreamWAV:
	var sample_count := maxi(int(SAMPLE_RATE * duration), 1)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	for sample_index in range(sample_count):
		var time := float(sample_index) / float(SAMPLE_RATE)
		var progress := time / duration
		var frequency := lerpf(start_frequency, end_frequency, progress)
		var envelope := sin(progress * PI)
		var sample := sin(TAU * time * frequency) + 0.35 * sin(TAU * time * frequency * 1.5)
		data.encode_s16(sample_index * 2, int(round(clampf(sample * envelope * amplitude, -1.0, 1.0) * 32767.0)))
	return build_stream(data, sample_count, false)


static func build_stream(data: PackedByteArray, sample_count: int, loop_enabled: bool) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = data
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if loop_enabled else AudioStreamWAV.LOOP_DISABLED
	stream.loop_begin = 0
	stream.loop_end = sample_count
	return stream
