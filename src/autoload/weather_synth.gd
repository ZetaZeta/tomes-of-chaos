class_name WeatherSynth
extends RefCounted
## Synthesised weather sounds (no recordings ship with the game).

const RATE := 22050

static func _wav(samples: PackedFloat32Array, loop: bool) -> AudioStreamWAV:
	var data := PackedByteArray()
	data.resize(samples.size() * 2)
	for i in range(samples.size()):
		data.encode_s16(i * 2, int(clampf(samples[i], -1.0, 1.0) * 32000.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = RATE
	w.stereo = false
	w.data = data
	if loop:
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
		w.loop_end = samples.size()
	return w

static func make(kind: String) -> AudioStreamWAV:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7919
	var out := PackedFloat32Array()
	match kind:
		"rain":
			# hiss: white noise with the lows taken out, plus a little patter
			var n := RATE * 3
			out.resize(n)
			var lp := 0.0
			for i in range(n):
				var w := rng.randf_range(-1.0, 1.0)
				lp += (w - lp) * 0.6
				var hp := lp - 0.0
				var drop := 0.0
				if rng.randf() < 0.0035:
					drop = rng.randf_range(0.3, 0.8)
				out[i] = hp * 0.30 + drop * 0.25
		"gale":
			# heavy low-passed noise that swells and falls; whole cycles so the loop is seamless
			var secs := 6
			var n := RATE * secs
			out.resize(n)
			var l1 := 0.0
			var l2 := 0.0
			for i in range(n):
				var ph := float(i) / float(n) * TAU
				var swell := 0.55 + 0.30 * sin(ph * 2.0) + 0.15 * sin(ph * 5.0 + 1.3)
				var w := rng.randf_range(-1.0, 1.0)
				l1 += (w - l1) * (0.05 + 0.04 * swell)
				l2 += (l1 - l2) * 0.25
				out[i] = l2 * swell * 1.8
		"thunder":
			var n := int(RATE * 3.6)
			out.resize(n)
			var l1 := 0.0
			var l2 := 0.0
			for i in range(n):
				var tt := float(i) / RATE
				var w := rng.randf_range(-1.0, 1.0)
				l1 += (w - l1) * 0.035
				l2 += (l1 - l2) * 0.12
				var crack := exp(-tt * 18.0) * w * 0.5
				var roll := exp(-tt * 0.9) * (0.7 + 0.3 * sin(tt * 9.0 + sin(tt * 2.3) * 3.0))
				out[i] = clampf(l2 * roll * 5.5 + crack, -1.0, 1.0)
	var st := _wav(out, kind != "thunder")
	return st
