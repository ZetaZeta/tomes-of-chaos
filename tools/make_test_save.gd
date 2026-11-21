extends SceneTree
## Builds a dev save that knows every spell: godot --headless --path . --script tools/make_test_save.gd
## Prints a pasteable TOC1: code (Load Game > Import) and writes tools/test_save_all_spells.txt.
var Game: Node

func _init() -> void:
	DB.init()
	Game = load("res://src/autoload/game.gd").new()
	Game.save_dir = "user://scratch_saves"
	Game.new_game("Archmage Tester")
	var s: Dictionary = Game.s
	s.books = ["primer"]
	for id in DB.book_order:
		s.books.append(id)
	var booked := {}
	for id in DB.book_order:
		for sp in DB.books[id].spells:
			booked[sp] = true
	var loose: Array = []
	for id in DB.spell_order:
		if not booked.has(id):
			loose.append(id)
	s.primer = loose
	print("spells in DB: ", DB.spells.size(), "  in books: ", booked.size(), "  loose (put in primer): ", loose.size())
	s.level = Game.MAX_LEVEL
	s.bonus_mind = 60 - (8 + 2 * (s.level - 1))   # mind cap 60
	s.wins = 0                                       # difficulty follows wins, so offers stay gentle
	s.prepared = []
	Game.mark_all_seen()
	Game.make_offers()
	Game.save_game()
	print("known: ", Game.known_spells().size(), " of ", DB.spells.size(), "  mind cap ", Game.mind_cap(), "  hp ", Game.max_hp())
	var code: String = Game.export_code(Game.slot)
	var f := FileAccess.open("res://tools/test_save_all_spells.txt", FileAccess.WRITE)
	f.store_string(code)
	f.close()
	print("code length ", code.length())
	# adventure check: start every offer, prepare spells, run a few turns
	var fails := 0
	for o in s.offers:
		print("offer: ", o.env, " ", o.obj, " book='", o.book, "'")
		for id in Game.known_spells():
			if Game.can_prepare(id) and Game.prepared_count(id) == 0 and DB.spells[id].lvl <= 3:
				Game.prepare(id)
		var b: Battle = Game.start_battle(o)
		for i in range(6):
			b.end_player_phase()
		print("  battle ran, result '", b.result, "', prepared ", s.prepared.size())
		var res: Dictionary = Game.finish_battle(b, o) if b.result != "" else {}
		print("  finish: ", res)
	# reload from disk
	Game.s = {}
	print("reload ok: ", Game.load_game(Game.slot), " known ", Game.known_spells().size())
	quit()
