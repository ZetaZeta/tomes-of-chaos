class_name NameGen
extends RefCounted
## Random wizard names for the title screen.

const A := ["Al", "Bar", "Cor", "Dra", "El", "Fen", "Gal", "Hal", "Ith", "Jor", "Kel", "Lor", "Mor", "Nyx", "Or", "Pel", "Quin", "Rav", "Sel", "Tor", "Ul", "Vel", "Wyn", "Xan", "Yor", "Zel", "Ang", "Bel", "Cal", "Mer"]
const B := ["a", "e", "i", "o", "u", "an", "en", "ar", "il", "or", "ath", "iel", "ae", "ud", "em", ""]
const C := ["dor", "mir", "wyn", "thas", "rix", "bus", "lan", "dric", "ius", "ora", "ina", "eth", "ox", "ndra", "vus", "phine", "lin", "gar", "mund", "zar", "bold", "ric", "tha", "nor"]
const TITLES := ["the Grey", "the Bold", "the Curious", "the Unready", "the Singed", "the Wise-ish", "the Brief", "the Lucky", "the Damp", "the Late", "Many-Hats", "of the Tower"]

static func wizard(rng: RandomNumberGenerator = null) -> String:
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()
	var n: String = A[rng.randi() % A.size()] + B[rng.randi() % B.size()] + C[rng.randi() % C.size()]
	if rng.randf() < 0.3:
		n += " " + TITLES[rng.randi() % TITLES.size()]
	return n
