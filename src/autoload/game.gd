extends Node
## Persistent run state: the wizard, their tower, spell books, prepared spells,
## and the adventures on offer.  Saved as JSON in user://.

const LEGACY_SAVE := "user://tomes_save.json"   # the old single-slot file; migrated on first run
const MAX_LEVEL := 20
const SAVE_VER := 2   # bump when content changes make old saves invalid

var s: Dictionary = {}

func _ready() -> void:
	DB.init()

# ================================================================== lifecycle
## Saves live in save_dir, one JSON file per game: <save_dir>/<slot>.json.
var save_dir := "user://saves"
var slot := ""            # id of the game currently loaded ("" = none)

func _slot_path(id: String) -> String:
	return "%s/%s.json" % [save_dir, id]

func _migrate_legacy() -> void:
	if save_dir != "user://saves" or not FileAccess.file_exists(LEGACY_SAVE):
		return
	DirAccess.make_dir_recursive_absolute(save_dir)
	var txt := FileAccess.get_file_as_string(LEGACY_SAVE)
	var f := FileAccess.open(_slot_path("legacy"), FileAccess.WRITE)
	if f:
		f.store_string(txt)
		f.close()
		DirAccess.remove_absolute(ProjectSettings.globalize_path(LEGACY_SAVE))

## All usable saves, most recently played first: [{id, name, level, wins, books, saved_at}]
func list_saves() -> Array:
	_migrate_legacy()
	var out: Array = []
	var d := DirAccess.open(save_dir)
	if d == null:
		return out
	for fn in d.get_files():
		if not fn.ends_with(".json"):
			continue
		var id := fn.trim_suffix(".json")
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(_slot_path(id)))
		if typeof(parsed) != TYPE_DICTIONARY or int(parsed.get("ver", 0)) != SAVE_VER:
			continue
		out.append({"id": id, "name": str(parsed.get("name", "?")), "level": int(parsed.get("level", 1)),
			"wins": int(parsed.get("wins", 0)), "books": (parsed.get("books", []) as Array).size(),
			"saved_at": int(parsed.get("saved_at", 0))})
	out.sort_custom(func(a, b): return a.saved_at > b.saved_at)
	return out

func has_save() -> bool:
	return not list_saves().is_empty()

func new_game(wizard_name: String) -> void:
	s = {
		"name": wizard_name if wizard_name != "" else "Apprentice",
		"level": 1, "wins": 0, "losses": 0, "books": ["primer"],
		"prepared": [], "offers": [], "bonus_mind": 0, "bonus_hp": 0, "seed": randi(),
		"history": [], "primer": [], "ver": SAVE_VER,
	}
	slot = "g%d_%04d" % [int(Time.get_unix_time_from_system()), randi() % 10000]
	s.primer = roll_primer()
	auto_prepare()
	make_offers()
	mark_all_seen()
	save_game()

func save_game() -> void:
	if s.is_empty():
		return
	if slot == "":
		slot = "g%d_%04d" % [int(Time.get_unix_time_from_system()), randi() % 10000]
	DirAccess.make_dir_recursive_absolute(save_dir)
	s["saved_at"] = int(Time.get_unix_time_from_system())
	var f := FileAccess.open(_slot_path(slot), FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(s))

## Load a save by id; with no id, the most recently played one.
func load_game(id: String = "") -> bool:
	var saves := list_saves()
	if saves.is_empty():
		return false
	if id == "":
		id = saves[0].id
	if not FileAccess.file_exists(_slot_path(id)):
		return false
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(_slot_path(id)))
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	slot = id
	s = parsed
	# JSON turns ints into floats; normalise
	for k in ["level", "wins", "losses", "bonus_mind", "bonus_hp", "seed"]:
		s[k] = int(s.get(k, 0))
	for o in s.get("offers", []):
		o["seed"] = int(o.get("seed", 1))
	# drop spells/books that no longer exist (content changes between versions)
	s.books = s.books.filter(func(b): return DB.books.has(b))
	if not s.has("primer") or s.primer.is_empty():
		s["primer"] = roll_primer()
	s.primer = s.primer.filter(func(x): return DB.spells.has(x))
	if not s.has("seen"):
		mark_all_seen()          # saves from before the "new" tags: nothing is new
	s.prepared = s.prepared.filter(func(x): return DB.spells.has(x))
	return true

## A save as a single line of text that can be pasted anywhere (chat, notes, e-mail) and imported on another device.
const CODE_PREFIX := "TOC1:"

func export_code(id: String) -> String:
	if not FileAccess.file_exists(_slot_path(id)):
		return ""
	var bytes := FileAccess.get_file_as_string(_slot_path(id)).to_utf8_buffer()
	return CODE_PREFIX + Marshalls.raw_to_base64(bytes.compress(FileAccess.COMPRESSION_DEFLATE)) + ":" + str(bytes.size())

## Imports a code as a NEW game (never overwrites).  Returns "" on success or an error message.
func import_code(text: String) -> String:
	var t := text.strip_edges().replace("\n", "").replace(" ", "")
	if not t.begins_with(CODE_PREFIX):
		return "That doesn't look like a Tomes of Chaos save code."
	var parts := t.trim_prefix(CODE_PREFIX).split(":")
	if parts.size() != 2 or not parts[1].is_valid_int() or int(parts[1]) <= 0 or int(parts[1]) > 2000000:
		return "The save code is incomplete or damaged."
	var re := RegEx.create_from_string("^[A-Za-z0-9+/]+={0,2}$")
	if re.search(parts[0]) == null or parts[0].length() % 4 != 0:
		return "The save code is incomplete or damaged."
	var raw := Marshalls.base64_to_raw(parts[0])
	if raw.is_empty():
		return "The save code is incomplete or damaged."
	var bytes := raw.decompress(int(parts[1]), FileAccess.COMPRESSION_DEFLATE)
	if bytes.is_empty():
		return "The save code is incomplete or damaged."
	var parsed = JSON.parse_string(bytes.get_string_from_utf8())
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("name") or not parsed.has("level") or not parsed.has("books"):
		return "The save code is incomplete or damaged."
	if int(parsed.get("ver", 0)) != SAVE_VER:
		return "This save is from a different version of the game."
	var id := "g%d_%04d" % [int(Time.get_unix_time_from_system()), randi() % 10000]
	DirAccess.make_dir_recursive_absolute(save_dir)
	var f := FileAccess.open(_slot_path(id), FileAccess.WRITE)
	if f == null:
		return "Couldn't write the save."
	f.store_string(JSON.stringify(parsed))
	return ""

func delete_save(id: String) -> void:
	if FileAccess.file_exists(_slot_path(id)):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(_slot_path(id)))
	if id == slot:
		slot = ""
		s = {}

# ================================================================== wizard stats
func max_hp() -> int:
	return 5 + (s.level - 1) / 3 + s.bonus_hp

func mind_cap() -> int:
	return mini(8 + 2 * (s.level - 1) + s.bonus_mind, 60)

func mind_used() -> int:
	var n := 0
	for id in s.prepared:
		n += DB.spells[id].lvl
	return n

func known_spells() -> Array:
	var seen := {}
	var out: Array = []
	for b in s.books:
		for id in book_spells(b):
			if not seen.has(id):
				seen[id] = true
				out.append(id)
	out.sort_custom(func(a, b):
		var sa: Dictionary = DB.spells[a]
		var sb: Dictionary = DB.spells[b]
		if sa.school != sb.school:
			return sa.school < sb.school
		if sa.lvl != sb.lvl:
			return sa.lvl < sb.lvl
		return sa.nm < sb.nm)
	return out

## Spells in a book (the starting primer is different every game).
func book_spells(book_id: String) -> Array:
	if book_id == "primer":
		return s.get("primer", [])
	return DB.books[book_id].spells

func _spell_role(sp: Dictionary) -> String:
	var has_dmg := false
	var has_bad := false
	var has_good := false
	for f in sp.fx:
		match f.k:
			"summon":
				return "summon"
			"dmg", "drain", "kill":
				if f.get("side", "") != "any" and f.get("side", "") != "ally" and f.get("only", "") != "illusion":
					has_dmg = true
			"st":
				var bad: bool = DB.STATUS[f.s].get("bad", false)
				if bad:
					has_bad = true
				else:
					has_good = true
			"heal", "cleanse", "max_hp", "ward":
				has_good = true
	if has_dmg and sp.tgt != "self":
		return "attack"
	if has_bad and sp.tgt != "self":
		return "control"
	if has_good:
		return "defense"
	return "util"

## A random, balanced starting book of level-1 spells: two attacks, a summon, a defence, a control spell and a wildcard.
func roll_primer(rng: RandomNumberGenerator = null) -> Array:
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()
	var pool := {"attack": [], "summon": [], "defense": [], "control": [], "util": []}
	for id in DB.spell_order:
		var sp: Dictionary = DB.spells[id]
		if sp.lvl != 1 or sp.tgt == "corpse":
			continue
		pool[_spell_role(sp)].append(id)
	for k in pool:
		_shuffle(pool[k], rng)
	var out: Array = []
	var used_schools := {}
	# two attacks from different schools, at least one with real range
	var ranged: Array = pool.attack.filter(func(id): return DB.spells[id].rng >= 4 or DB.spells[id].rng < 0)
	if not ranged.is_empty():
		var a: String = ranged[0]
		out.append(a)
		used_schools[DB.spells[a].school] = true
	for id in pool.attack:
		if out.size() >= 2:
			break
		if out.has(id):
			continue
		if used_schools.has(DB.spells[id].school) and pool.attack.size() > 4:
			continue
		out.append(id)
		used_schools[DB.spells[id].school] = true
	for role in ["summon", "defense", "control"]:
		for id in pool[role]:
			if not out.has(id):
				out.append(id)
				break
	# one wildcard from anything left
	var rest: Array = []
	for k in pool:
		for id in pool[k]:
			if not out.has(id):
				rest.append(id)
	if not rest.is_empty():
		out.append(rest[rng.randi() % rest.size()])
	return out

## "New" tags: a spell ("s:id") or book ("b:id") is new until the player has looked at it in the study / library.
func mark_all_seen() -> void:
	s["seen"] = []
	for b in s.books:
		s.seen.append("b:" + b)
	for id in known_spells():
		s.seen.append("s:" + id)

func is_new(key: String) -> bool:
	return not (s.get("seen", []) as Array).has(key)

func mark_seen(key: String) -> void:
	if is_new(key):
		s.seen.append(key)
		save_game()

func knows(id: String) -> bool:
	return known_spells().has(id)

func prepared_count(id: String) -> int:
	return s.prepared.count(id)

func can_prepare(id: String) -> bool:
	return mind_used() + DB.spells[id].lvl <= mind_cap()

func prepare(id: String) -> bool:
	if not can_prepare(id):
		return false
	s.prepared.append(id)
	return true

func unprepare(id: String) -> void:
	var i: int = s.prepared.find(id)
	if i >= 0:
		s.prepared.remove_at(i)

func auto_prepare() -> void:
	s.prepared = []
	# attacks first, then summon/defence/control, then more attacks, then utility
	var lv1: Array = known_spells().filter(func(id): return DB.spells[id].lvl == 1)
	for roles in [["attack"], ["summon", "defense", "control"], ["attack"], ["util"], ["attack"]]:
		for id in lv1:
			if _spell_role(DB.spells[id]) in roles and can_prepare(id):
				s.prepared.append(id)

func trim_prepared() -> void:
	while mind_used() > mind_cap() and not s.prepared.is_empty():
		s.prepared.pop_back()

# ================================================================== adventures
const OBJECTIVE_NAMES := {
	"slay_all": "Slay every foe",
	"slay_wizard": "Defeat the rival wizard",
	"retrieve": "Seize the spell book",
}
## Goal line shown on mission cards and in battle; `taken` once the book is in hand.
func objective_text(obj: String, mods: Array, taken: bool = false) -> String:
	if obj != "retrieve" or mods.is_empty():
		return OBJECTIVE_NAMES[obj]
	if mods.has("carrier"):
		return "Kill the thief, take the book" if not taken else "Spell book won"
	var t := "Seize the spell book"
	if taken:
		t = "Escape with the book" if mods.has("escape") else "Slay the guardians"
		if mods.has("escape") and mods.has("trap"):
			t = "Escape with the book (guardians!)"
	var tags: Array = []
	for m in ["chamber", "ward", "channel", "escape"]:
		if mods.has(m) and not taken:
			tags.append(m)
	if not tags.is_empty():
		t += " [" + ", ".join(tags) + "]"
	return t

const DIFF_NAMES := ["Gentle", "Fair", "Perilous", "Deadly"]

func base_difficulty() -> float:
	return 0.9 + s.wins * 0.5

func make_offers() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = s.seed + s.wins * 7919 + s.losses * 104729
	var envs: Array = []
	for id in DB.envs:
		if DB.envs[id].min_diff <= base_difficulty() + 0.9:
			envs.append(id)
	_shuffle(envs, rng)
	var offers: Array = []
	var mods := [-0.5, 0.2, 1.0]
	var used_books := {}
	for i in range(3):
		var env_id: String = envs[i % envs.size()]
		var obj: String = ["slay_all", "slay_all", "slay_wizard", "retrieve", "retrieve"][rng.randi() % 5]
		var diff := maxf(0.6, base_difficulty() + mods[i] + rng.randf_range(-0.15, 0.15))
		var o := {"env": env_id, "obj": obj, "diff": diff, "seed": rng.randi(), "tier": i}
		o["book"] = _pick_book(env_id, i, used_books, rng)
		if o.book != "":
			used_books[o.book] = true
		offers.append(o)
	s.offers = offers

func _shuffle(a: Array, rng: RandomNumberGenerator) -> void:
	for i in range(a.size() - 1, 0, -1):
		var j := rng.randi() % (i + 1)
		var t = a[i]
		a[i] = a[j]
		a[j] = t

func _pick_book(env_id: String, tier_slot: int, used: Dictionary, rng: RandomNumberGenerator) -> String:
	var schools: Array = DB.envs[env_id].books
	var want: float = 1.0 + s.wins * 0.45 + tier_slot * 0.7
	var cands: Array = []
	for id in DB.book_order:
		if s.books.has(id) or used.has(id):
			continue
		cands.append(id)
	if cands.is_empty():
		return ""
	var in_env: Array = cands.filter(func(id): return DB.books[id].school in schools)
	var pool: Array = in_env if not in_env.is_empty() else cands
	var best := ""
	var best_score := 999.0
	for id in pool:
		var sc := absf(DB.books[id].tier - want) + rng.randf() * 0.9
		if sc < best_score:
			best_score = sc
			best = id
	return best

func start_battle(offer: Dictionary) -> Battle:
	var spells: Array = s.prepared.duplicate()
	var b := LevelGen.generate(offer.env, offer.diff, offer.obj, offer.seed, {
		"nm": s.name, "hp": max_hp(), "spells": spells, "move": 2})
	return b

## Apply the outcome of a battle. Returns a summary dictionary for the result screen.
func finish_battle(b: Battle, offer: Dictionary) -> Dictionary:
	var res := {"result": b.result, "book": "", "new_spells": [], "level_up": false, "bonus": ""}
	if b.result == "win":
		s.wins += 1
		if offer.book != "" and not s.books.has(offer.book):
			s.books.append(offer.book)
			res.book = offer.book
			res.new_spells = DB.books[offer.book].spells.duplicate()
		elif offer.book == "":
			s.bonus_mind += 1
			res.bonus = "The dungeon holds no more books you lack. Your mind sharpens (+1 mind)."
		if s.level < MAX_LEVEL:
			s.level += 1
			res.level_up = true
	else:
		s.losses += 1
	s.history.append({"env": offer.env, "result": b.result})
	trim_prepared()
	make_offers()
	save_game()
	return res
