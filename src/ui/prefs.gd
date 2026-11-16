class_name Prefs
extends RefCounted
## Player preferences, saved to user://settings.json.  Add new options here and to OptionsScreen.

const PATH := "user://settings.json"
static var data: Dictionary = {}
static var loaded := false

static func load_all() -> void:
	loaded = true
	data = {}
	if FileAccess.file_exists(PATH):
		var d = JSON.parse_string(FileAccess.get_file_as_string(PATH))
		if typeof(d) == TYPE_DICTIONARY:
			data = d
	apply_audio()

static func get_v(key: String, default: Variant) -> Variant:
	if not loaded:
		load_all()
	return data.get(key, default)

static func set_v(key: String, value: Variant) -> void:
	if not loaded:
		load_all()
	data[key] = value
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))

static func master_volume() -> float:
	return clampf(float(get_v("master_vol", 1.0)), 0.0, 1.0)

static func music_volume() -> float:
	return clampf(float(get_v("music_vol", 0.8)), 0.0, 1.0)

static func sfx_volume() -> float:
	return clampf(float(get_v("sfx_vol", 1.0)), 0.0, 1.0)

## Master volume goes to the audio bus; the effects slider is applied by Sfx.play.
static func apply_audio() -> void:
	var m := master_volume()
	AudioServer.set_bus_volume_db(0, linear_to_db(m) if m > 0.001 else -80.0)
	var ml := Engine.get_main_loop()
	if ml is SceneTree and ml.root.has_node("Music"):
		ml.root.get_node("Music").refresh_volume()
