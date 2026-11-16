extends Node
## Tiny sound-effect player.  Sounds come from assets/sfx (taken from the Chaos build).

var _streams: Dictionary = {}
var _players: Array = []
var enabled: bool = true
var _next: int = 0

func _ready() -> void:
	for i in range(8):
		var p := AudioStreamPlayer.new()
		if Music.threaded_audio():
			p.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
		add_child(p)
		_players.append(p)
	for n in ["attack", "beam", "chosen", "cpustart", "electro", "fire", "gooey", "justice", "menu", "range", "scream", "spellstep", "spellsuccess", "urgh", "walk"]:
		var path := "res://assets/sfx/%s.ogg" % n
		var st = null
		if ResourceLoader.exists(path):
			st = load(path)
		if st == null and FileAccess.file_exists(path):
			st = AudioStreamOggVorbis.load_from_file(path)
		if st != null:
			_streams[n] = st

func play(n: String, vol_db: float = -6.0) -> void:
	if not enabled or not _streams.has(n):
		return
	var p: AudioStreamPlayer = _players[_next]
	_next = (_next + 1) % _players.size()
	p.stream = _streams[n]
	var sv := Prefs.sfx_volume()
	if sv <= 0.001:
		return
	p.volume_db = vol_db + linear_to_db(sv)
	p.play()

# ---------------------------------------------------------------- weather ambience
# No recorded rain or wind ships with the game, so the sounds are synthesised the first time they are needed.
var _amb: AudioStreamPlayer = null
var _amb_kind: String = ""
var _synth: Dictionary = {}
var _thunder_player: AudioStreamPlayer = null

func _make(kind: String) -> AudioStreamWAV:
	if not _synth.has(kind):
		_synth[kind] = WeatherSynth.make(kind)
	return _synth[kind]

func _ensure_players() -> void:
	if _amb == null:
		_amb = AudioStreamPlayer.new()
		_thunder_player = AudioStreamPlayer.new()
		if Music.threaded_audio():
			_amb.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
			_thunder_player.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
		add_child(_amb)
		add_child(_thunder_player)

## Start the weather's background sound ("rain", "gale"; anything else is silence).
func set_ambience(weather: String) -> void:
	if weather == _amb_kind:
		return
	_amb_kind = weather
	_ensure_players()
	var sv := Prefs.sfx_volume()
	if not enabled or sv <= 0.001 or not (weather == "rain" or weather == "gale"):
		_amb.stop()
		return
	var st: AudioStream = null
	if weather == "gale":
		# a recorded wind, cross-faded so that it loops without a seam (assets/sfx/gale.ogg)
		var gp := "res://assets/sfx/gale.ogg"
		if ResourceLoader.exists(gp):
			st = load(gp)
		elif FileAccess.file_exists(gp):
			st = AudioStreamOggVorbis.load_from_file(gp)
		if st is AudioStreamOggVorbis:
			st.loop = true
	if st == null:
		st = _make(weather)
	_amb.stream = st
	_amb.volume_db = (-17.0 if weather == "rain" else -11.0) + linear_to_db(sv)
	_amb.play()

func thunder(vol_db: float = -6.0) -> void:
	var sv := Prefs.sfx_volume()
	if not enabled or sv <= 0.001:
		return
	_ensure_players()
	_thunder_player.stream = _make("thunder")
	_thunder_player.volume_db = vol_db + linear_to_db(sv)
	_thunder_player.play()
