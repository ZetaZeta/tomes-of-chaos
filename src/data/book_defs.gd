class_name BookDefs
extends RefCounted
## Spell books.  Books are generated automatically from the spell tables:
## every school's spells (sorted by level) are split into small books of 2-4
## spells, so low-level books come first.  The Apprentice's Primer you begin
## with is rolled per game (Game.roll_primer).

const FORMS := {
	1: ["Scrap", "Primer", "Pamphlet", "Jottings", "Notes", "Crib Sheet"],
	2: ["Handbook", "Folio", "Notebook", "Manual", "Pocket Guide"],
	3: ["Codex", "Treatise", "Grimoire", "Compendium", "Lexicon"],
	4: ["Grand Codex", "Great Grimoire", "Tome", "Opus", "Archive"],
	5: ["Forbidden Tome", "Arcanum", "Apocrypha", "Black Grimoire", "Magnum Opus"],
}

const TOPICS := {
	"evocation": ["Force", "Invocation", "Arcane Might", "Raw Power", "Blasting", "Radiance", "Impact", "Pure Energy", "Havoc"],
	"pyromancy": ["Embers", "Cinders", "Flame", "Ash", "Smoke", "Brimstone", "Sparks", "Kindling", "the Pyre"],
	"cryomancy": ["Frost", "Rime", "Winter", "Glaciers", "Hoarfrost", "Stillness", "Icicles", "the Long Night", "Snowfall"],
	"storm": ["Thunder", "Gales", "Tempests", "Lightning", "the Squall", "Static", "Stormfronts", "Cloudbreak", "Whirlwinds"],
	"necromancy": ["Graves", "Bones", "Dread", "the Ossuary", "Whispers", "Rot", "Shades", "the Cold Dead", "Last Breaths"],
	"conjuration": ["Servants", "Summoning", "Gates", "Calling", "Bound Things", "the Menagerie", "Visitors", "Contracts", "Pacts"],
	"abjuration": ["Wards", "Barriers", "Sigils", "Seals", "Aegis", "Warding", "Shields", "Banishment", "Sanctuary"],
	"illusion": ["Mirrors", "Shadows", "Smoke", "Glamours", "Phantasms", "Mirage", "Veils", "Masks", "Deceit"],
	"enchantment": ["Wills", "Whispers", "Charm", "Dominion", "Puppets", "Compulsion", "Silver Tongues", "Obedience", "Moods"],
	"divination": ["Omens", "Secrets", "Foresight", "Oracles", "Far Sight", "Fate", "Auspices", "Hidden Things", "Stars"],
	"transmutation": ["Change", "Becoming", "Shapes", "Alteration", "Quicksilver", "Metamorphosis", "Flux", "Substance", "Transformation"],
	"nature": ["Thorns", "the Wild", "Roots", "the Hunt", "Beasts", "Greenwood", "Seasons", "Moss", "Claws"],
	"divine": ["Light", "Psalms", "Mercy", "Judgement", "Blessings", "Radiance", "Litany", "Saints", "Dawn"],
	"alchemy": ["Vials", "Retorts", "Acids", "Elixirs", "Poisons", "Reagents", "Distillation", "Cauldrons", "Residue"],
	"chaos": ["Madness", "Entropy", "Chance", "Disorder", "Coincidence", "the Unwritten", "Wild Magic", "Mayhem", "Folly"],
	"spatial": ["Gates", "Folds", "Distance", "Elsewhere", "Gravity", "Waypoints", "Time", "Thresholds", "Cartography"],
	"earth": ["Stone", "Deep Places", "Crystal", "Faults", "Titans", "Bedrock", "Sand", "Mountains", "Iron"],
	"blood": ["Veins", "Pacts", "Sacrifice", "Hunger", "the Red Ledger", "Crimson", "Sanguinity", "Marrow", "Vows"],
}

## Target spells per book (books end up with 2-4).
const PER_BOOK := 3

static func _book_name(school: String, tier: int, i: int, used: Dictionary) -> String:
	var forms: Array = FORMS[clampi(tier, 1, 5)]
	var topics: Array = TOPICS.get(school, [DB.SCHOOLS[school].nm])
	for k in range(forms.size() * topics.size()):
		var nm: String = "%s of %s" % [forms[(i + k) % forms.size()], topics[(i * 2 + k / forms.size()) % topics.size()]]
		if not used.has(nm):
			used[nm] = true
			return nm
	var fb := "%s Vol. %d" % [DB.SCHOOLS[school].nm, i + 1]
	used[fb] = true
	return fb

## Spells that are nothing but a status, and apply the same one (Hunter's Mark and Weak Point both just "mark"), are too alike to
## share a book: swap one with a same-level spell from another book where that is possible.
static func _status_sig(id: String) -> Array:
	var sp: Dictionary = DB.spells[id]
	var out: Array = []
	for f in sp.fx:
		if f.get("k", "") != "st":
			return []
		out.append(f.s)
	return out

static func _twins(a: String, b: String) -> bool:
	if DB.spells[a].tgt != DB.spells[b].tgt:
		return false
	var sa := _status_sig(a)
	if sa.is_empty():
		return false
	for s in _status_sig(b):
		if sa.has(s):
			return true
	return false

static func _clash(chunk: Array, id: String, skip: String = "") -> bool:
	for o in chunk:
		if o != skip and o != id and _twins(o, id):
			return true
	return false

static func _separate_twins(chunks: Array) -> void:
	for ci in range(chunks.size()):
		var chunk: Array = chunks[ci]
		for bi in range(chunk.size()):
			var b: String = chunk[bi]
			if not _clash(chunk, b):
				continue
			var done := false
			for cj in range(chunks.size()):
				if cj == ci or done:
					continue
				var other: Array = chunks[cj]
				for xi in range(other.size()):
					var x: String = other[xi]
					if DB.spells[x].lvl != DB.spells[b].lvl:
						continue
					if _clash(chunk, x, b) or _clash(other, b, x):
						continue
					chunk[bi] = x
					other[xi] = b
					done = true
					break

static func register() -> void:
	# The starting book
	# The starting book is rolled per game (see Game.roll_primer); its spell list is stored in the save.
	DB.add_book({"id": "primer", "nm": "Apprentice's Primer", "school": "evocation", "tier": 1, "spells": [], "col": Color("c8b080")})
	var by_school := {}
	for id in DB.spell_order:
		var s: Dictionary = DB.spells[id]
		if not by_school.has(s.school):
			by_school[s.school] = []
		by_school[s.school].append(id)
	var used_names := {}
	for school in DB.SCHOOLS:
		if not by_school.has(school):
			continue
		var ids: Array = by_school[school]
		ids.sort_custom(func(a, b):
			var la: int = DB.spells[a].lvl
			var lb: int = DB.spells[b].lvl
			if la != lb:
				return la < lb
			return DB.spells[a].nm < DB.spells[b].nm)
		var nb := maxi(1, int(round(float(ids.size()) / PER_BOOK)))
		var chunks: Array = []
		for i in range(nb):
			chunks.append(ids.slice(ids.size() * i / nb, ids.size() * (i + 1) / nb))
		_separate_twins(chunks)
		for i in range(nb):
			var chunk: Array = chunks[i]
			var tier := 1
			for sid in chunk:
				tier = maxi(tier, DB.spells[sid].lvl)
			var nm := _book_name(school, tier, i, used_names)
			DB.add_book({"id": "%s_%d" % [school, i + 1], "nm": nm, "school": school, "tier": tier,
				"spells": chunk, "col": DB.school_col(school)})
