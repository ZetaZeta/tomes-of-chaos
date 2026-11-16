extends SceneTree
## godot --headless --path . -s tests/dump_spells.gd  -> writes /home/claude/work/out/spells_dump.json
func _init() -> void:
	DB.init()
	var out: Array = []
	for id in DB.spell_order:
		var sp: Dictionary = DB.spells[id]
		var book := ""
		for bk in DB.books.values():
			if bk.spells.has(id):
				book = bk.nm
				break
		var txt := SpellText.describe(sp)
		var re := RegEx.new()
		re.compile("\\[/?[a-z]+(=[^\\]]*)?\\]")
		txt = re.sub(txt, "", true)
		out.append({"id": id, "nm": sp.nm, "school": DB.SCHOOLS[sp.school].nm, "lvl": sp.lvl, "tgt": SpellText.target_text(sp), "shape": SpellText.shape_text(sp), "effects": SpellText.effects_only(sp), "flavour": sp.flavour, "tgt_raw": sp.tgt, "rng": sp.rng, "shape_raw": sp.shape, "r": sp.r, "fx": sp.fx, "los": sp.get("los", true), "book": book, "text": txt})
	var f := FileAccess.open("/home/claude/work/out/spells_dump.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(out))
	f.close()
	var mons := {}
	for mid in DB.monsters:
		var md: Dictionary = DB.monsters[mid]
		mons[mid] = {"hp": md.hp, "mv": md.mv, "dmg": md.dmg, "tier": md.tier, "ab": md.ab, "rg": md.get("rg", []), "dt": md.get("dt", "phys"), "on_hit": md.get("on_hit", []), "spells": md.get("spells", [])}
	var f2 := FileAccess.open("/home/claude/work/out/monsters_dump.json", FileAccess.WRITE)
	f2.store_string(JSON.stringify(mons))
	f2.close()
	print("DUMPED ", out.size())
	quit()
