extends Node
## Background music.  One track per adventure environment (assets/music/<env id>.ogg) plus the tower theme, which plays
## everywhere outside battle.  Each file is the song from its real start up to the end of its repeating section; the last
## seconds are cross-faded into the music that precedes the loop start (loops.json: S), so looping [S, end] is endless and
## the intro (0..S) plays only once per visit.
##
## In the web build the music is NOT played by Godot.  The page plays the .ogg files itself with the browser's own audio
## engine (an AudioBufferSourceNode with native loopStart/loopEnd, sample-accurate and gap-free, mixed off the game's thread;
## Godot's web sample playback ignores loop offsets).  Elsewhere Godot plays it with loop_offset.

const FADE := 1.2          # back to the tower
const FADE_IN_LEVEL := 0.5   # into a level: be quick
var enabled: bool = true
var current: String = ""
var _players: Array = []
var _active := 0
var _streams: Dictionary = {}
var _resume: Dictionary = {}     # track -> playback position when we left it (tower music only)
var _web := false
var _dbg_t := 0.0
var _debug := false

const JS := """
window.TocMusic = (function () {
  var ctx = null, master = null, cur = null, meta = null, cache = {}, token = 0, target = 0.5, pos = {}, ver = 0;
  function ensure() {
    if (ctx) return ctx;
    var C = window.AudioContext || window.webkitAudioContext;
    try { ctx = new C({ sampleRate: 32000, latencyHint: 'playback' }); } catch (e) { ctx = new C({ latencyHint: 'playback' }); }
    master = ctx.createGain(); master.gain.value = target; master.connect(ctx.destination);
    return ctx;
  }
  function kick() { if (ctx && ctx.state === 'suspended') ctx.resume().catch(function () {}); }
  ['pointerdown', 'keydown', 'touchend', 'click'].forEach(function (n) { document.addEventListener(n, kick, true); });
  function getMeta() {
    if (!meta) meta = fetch(new URL('../music/loops.json', location.href).href).then(function (r) { return r.json(); }).catch(function () { return {}; });
    return meta;
  }
  function load(id) {
    if (cache[id]) return cache[id];
    var p = fetch(new URL('../music/' + id + '.ogg', location.href).href).then(function (r) { return r.arrayBuffer(); })
      .then(function (ab) { return new Promise(function (res, rej) { ctx.decodeAudioData(ab, res, rej); }); });
    cache[id] = p;
    p.catch(function () { delete cache[id]; });
    return p;
  }
  function position(c) {
    var el = ctx.currentTime - c.t0 + c.off;
    if (el >= c.E && c.E > c.S) el = c.S + ((el - c.S) % (c.E - c.S));
    return Math.max(0, el);
  }
  function curve(n, up, scale) {
    var a = new Float32Array(n);
    for (var i = 0; i < n; i++) { var t = i / (n - 1); a[i] = (up ? Math.sin(t * Math.PI / 2) : Math.cos(t * Math.PI / 2)) * scale; }
    return a;
  }
  return {
    play: function (id, fade, vol, startAt) {
      target = vol; ensure(); kick();
      master.gain.setTargetAtTime(vol, ctx.currentTime, 0.05);
      if (cur && cur.id === id) return;
      var my = ++token;
      Promise.all([getMeta(), load(id)]).then(function (r) {
        if (my !== token) return;
        var m = r[0][id] || {}, buf = r[1];
        var leaving = cur;
        if (leaving && leaving.id === 'tower') pos.tower = position(leaving);
        var src = ctx.createBufferSource();
        src.buffer = buf; src.loop = true; src.loopStart = m.S || 0; src.loopEnd = buf.duration;
        var gin = ctx.createGain(), gout = ctx.createGain();
        gin.gain.value = 0;
        src.connect(gin); gin.connect(gout); gout.connect(master);
        var off = startAt || ((id === 'tower' && pos.tower) ? pos.tower : 0);
        if (off >= buf.duration) off = m.S || 0;
        var t = ctx.currentTime + 0.05;
        src.start(t, off);
        gin.gain.setValueCurveAtTime(curve(64, true, 1), t, fade);
        if (leaving) {
          leaving.gout.gain.setValueCurveAtTime(curve(64, false, 1), t, fade);
          leaving.src.stop(t + fade + 0.1);
          leaving.src.onended = function () { try { leaving.src.disconnect(); leaving.gout.disconnect(); } catch (e) {} };
        }
        cur = { id: id, src: src, gout: gout, t0: t, off: off, S: m.S || 0, E: buf.duration };
        Object.keys(cache).forEach(function (k) { if (k !== id && k !== 'tower') delete cache[k]; });
      }).catch(function (e) { console.log('MUSIC load failed ' + id + ' ' + e); });
    },
    vol: function (v) { target = v; if (ctx) master.gain.setTargetAtTime(v, ctx.currentTime, 0.05); },
    state: function () { return JSON.stringify({ id: cur ? cur.id : '', pos: cur ? position(cur) : 0, ctx: ctx ? ctx.state : 'none', rate: ctx ? ctx.sampleRate : 0, base: ctx ? ctx.baseLatency : 0 }); },
    stop: function () { token++; if (cur) { try { cur.src.stop(); } catch (e) {} cur = null; } }
  };
})();
"""

func _ready() -> void:
	_web = OS.has_feature("web")
	if _web:
		JavaScriptBridge.eval(JS, true)
		_debug = bool(JavaScriptBridge.eval("new URLSearchParams(location.search).has('musicdebug')"))
	set_process(_debug)
	if _web:
		return
	for i in range(2):
		var p := AudioStreamPlayer.new()
		p.volume_db = -80.0
		add_child(p)
		_players.append(p)

## True when the web page is cross-origin isolated (not needed for music any more; Options shows it for diagnosis).
static func threaded_audio() -> bool:
	return OS.has_feature("web") and bool(JavaScriptBridge.eval("window.crossOriginIsolated === true && typeof SharedArrayBuffer !== 'undefined'"))

static func isolation_note() -> String:
	if not OS.has_feature("web"):
		return ""
	var iso := bool(JavaScriptBridge.eval("window.crossOriginIsolated === true"))
	var sab := bool(JavaScriptBridge.eval("typeof SharedArrayBuffer !== 'undefined'"))
	return "isolated:%s sab:%s build:%s" % ["yes" if iso else "no", "yes" if sab else "no", "mt" if OS.has_feature("threads") else "st"]

## Where the repeating part starts (seconds); everything before it (the intro) plays only once.
func _loop_start(id: String) -> float:
	var d = JSON.parse_string(FileAccess.get_file_as_string("res://assets/music/loops.json"))
	if typeof(d) == TYPE_DICTIONARY and d.has(id):
		return float(d[id].S)
	return 0.0

func _stream(id: String) -> AudioStream:
	if _streams.has(id):
		return _streams[id]
	var path := "res://assets/music/%s.ogg" % id
	var st: AudioStream = null
	if ResourceLoader.exists(path):
		st = load(path)
	if st is AudioStreamOggVorbis:
		st.loop = true
		st.loop_offset = _loop_start(id)
	_streams[id] = st
	for k in _streams.keys():     # keep only the tower theme, the current track and the new one
		if k != id and k != current and k != "tower":
			_streams.erase(k)
	return st

func target_linear() -> float:
	var v := Prefs.music_volume() * Prefs.master_volume()
	return v * 0.7 if v > 0.001 else 0.0

func target_db() -> float:
	var v := Prefs.music_volume()
	return linear_to_db(v) - 3.0 if v > 0.001 else -80.0

## Cross-fade to a track (does nothing if it is already playing).
func play_track(id: String) -> void:
	if not enabled or id == current:
		return
	var FADE_T := FADE if id == "tower" else FADE_IN_LEVEL
	if _web:
		JavaScriptBridge.eval("TocMusic.play('%s', %f, %f)" % [id, FADE_T, target_linear()])
		current = id
		return
	var st := _stream(id)
	if st == null:
		return
	var old: AudioStreamPlayer = _players[_active]
	if current != "" and old.playing:
		if current == "tower":
			_resume[current] = old.get_playback_position()
		_fade_out(old, FADE_T)
	_active = 1 - _active
	var p: AudioStreamPlayer = _players[_active]
	p.stop()
	p.stream = st
	p.volume_db = -80.0
	var start2: float = _resume.get(id, 0.0)
	if start2 >= st.get_length() - 0.5:
		start2 = 0.0
	p.play(start2)
	var top := target_db()
	var tw := create_tween()
	tw.tween_method(func(t: float): p.volume_db = linear_to_db(maxf(sin(t * PI * 0.5), 0.0001)) + top if top > -79.0 else -80.0, 0.0, 1.0, FADE_T)
	p.set_meta("tween", tw)
	current = id

func _fade_out(p: AudioStreamPlayer, secs: float) -> void:
	var tw := create_tween()
	var from := p.volume_db
	tw.tween_method(func(t: float): p.volume_db = linear_to_db(maxf(cos(t * PI * 0.5), 0.0001)) + from if from > -79.0 else -80.0, 0.0, 1.0, secs)
	tw.tween_callback(p.stop)

## Called when a volume slider moves.
func refresh_volume() -> void:
	if _web:
		JavaScriptBridge.eval("TocMusic.vol(%f)" % target_linear())
		return
	if _players.is_empty():
		return
	var p: AudioStreamPlayer = _players[_active]
	if p.playing:
		var old_tw = p.get_meta("tween", null)
		if old_tw is Tween and old_tw.is_valid():
			old_tw.kill()
		p.volume_db = target_db()

func _process(delta: float) -> void:
	_dbg_t += delta
	if _dbg_t >= 1.0:
		_dbg_t = 0.0
		print("MUSIC cur=%s %s" % [current, JavaScriptBridge.eval("TocMusic.state()")])
