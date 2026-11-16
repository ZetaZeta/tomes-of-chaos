class_name Entity
extends RefCounted
## Anything on the board: wizards, creatures and objects (walls, traps, fires...).

const WIZARD := 0
const CREATURE := 1
const OBJECT := 2

const T_PLAYER := 0
const T_ENEMY := 1

var uid: int = 0
var kind: int = CREATURE
var def_id: String = ""
var nm: String = ""
var team: int = T_PLAYER
var pos := Vector2i.ZERO
var hp: int = 1
var max_hp: int = 1
var dmg: int = 1
var dtype: String = "phys"
var move: int = 1
var ab: Array = []
var ranged: Array = []        # [range, dmg, type, (status, turns)]
var on_hit: Array = []        # [status, turns]
var minion: String = ""
var status: Dictionary = {}   # name -> {"t": turns, "n": magnitude}
var arch: String = "humanoid"
var col := Color.WHITE
var moves_left: int = 0
var acted: bool = false
var attacks_left: int = 0
var casts_left: int = 0
var spells: Array = []        # prepared spell ids (wizards)
var school: String = ""
var alive: bool = true
var life: int = -1            # objects: rounds remaining (-1 = forever)
var owner_uid: int = -1
var props: Dictionary = {}
var dormant: bool = false
var aggro: int = 5
var timer: int = 0            # misc counters (summoner cooldown, vent cycle)
var orig_team: int = -1       # for charm
var form: String = ""         # monster id while shapechanged
var weapon_base: Dictionary = {}  # attack stats before any conjured weapon
var weapons: Dictionary = {}
var weapon_fx: Dictionary = {}    # slot -> extras (lifesteal, push, splash, uses, random element)
var contingency: Dictionary = {}   # stored effects that trigger when badly hurt
var souls: Array = []              # monster ids trapped in soul gems
var mount: Dictionary = {}         # a steed being ridden: id, nm, hp, mv, fly, timed
var snap: Dictionary = {}          # state at the start of this turn
var snap_prev: Dictionary = {}     # state at the start of the previous turn
var weapon_bonus: int = 0         # enchantment on the weapon in hand      # slot -> weapon name
var form_save: Dictionary = {}  # the wizard's own body, restored when the form ends

## Wizards, and creatures that carry their own spells (at-will, one cast a turn).
func has_spellbook() -> bool:
	return kind == WIZARD or props.get("innate", false)

func is_unit() -> bool:
	return kind != OBJECT

func has_ab(a: String) -> bool:
	if status.has("unwarded") and (a.begins_with("res:") or a.begins_with("imm:") or a.begins_with("immst:") or a == "heavy"):
		return false
	if status.has("solid") and (a in ["phased", "phantom", "stealth", "fly", "res:phys", "imm:phys"]):
		return false
	return ab.has(a)

func has_st(s: String) -> bool:
	return status.has(s)

func st_n(s: String) -> int:
	return status[s].n if status.has(s) else 0

func flies() -> bool:
	return (ab.has("fly") or status.has("levitating") or status.has("gaseous") or (not mount.is_empty() and mount.get("fly", false))) and not status.has("grounded")

func swims() -> bool:
	return ab.has("swim") or status.has("waterbreathing")

func phases() -> bool:
	return ab.has("phased") or status.has("phased") or status.has("gaseous")

func odef() -> Dictionary:
	return DB.objs.get(def_id, {})

func is_hostile_to(o: Entity) -> bool:
	return team != o.team

func display_name() -> String:
	return nm

func hp_text() -> String:
	return "%d/%d" % [hp, max_hp]


## Does this creature work magic?  (Used by wards that bar spellcasters.)
static func is_caster(e: Entity) -> bool:
	if e.kind == WIZARD:
		return true
	if e.has_ab("summoner") or e.has_ab("healer") or e.props.get("innate", false):
		return true
	if e.ranged.size() >= 3 and str(e.ranged[2]) in ["force", "psychic", "necro", "holy", "fire", "cold", "elec"]:
		return true
	return false

## True of creatures made of flesh: not constructs, skeletons, golems, spirits, oozes, elementals, trees or plants.
static func has_flesh(e: Entity) -> bool:
	if e.has_ab("construct") or e.has_ab("phantom") or e.has_ab("phased"):
		return false
	if e.arch in ["golem", "skeleton", "ghost", "elemental", "blob", "tree", "plant"]:
		return false
	if e.def_id.begins_with("bone") or e.def_id.begins_with("skeleton"):
		return false
	return true
