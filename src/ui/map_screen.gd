class_name MapScreen
extends Screen
## Choose one of three adventures.

class EnvPreview extends Control:
	var env_id := ""
	var seed_v := 0
	func _ready() -> void:
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		custom_minimum_size = Vector2(0, 96)
	func _draw() -> void:
		var env: Dictionary = DB.envs[env_id]
		var rng := RandomNumberGenerator.new()
		rng.seed = seed_v
		var ts := 32.0
		var cols := int(size.x / ts) + 1
		for y in range(3):
			for x in range(cols):
				var t: String = env.floor
				var r := rng.randf()
				if r < 0.18:
					t = env.solid[rng.randi() % env.solid.size()]
				elif r < 0.30 and env.fluid != "":
					t = env.fluid
				# pillars, statues and trees stand on the environment's own floor
				var under: String = env.floor if t in BoardView.PROPS else ""
				var tex := Art.tile_tex(t, rng.randi() % 4, env.pal, env_id, under)
				draw_texture_rect(tex, Rect2(x * ts, y * ts, ts, ts), false)

func setup(m: Control) -> void:
	super.setup(m)
	backdrop("map", 0.3)
	var root := MarginContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		root.add_theme_constant_override("margin_" + side, 24)
	add_child(root)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	root.add_child(v)
	var top := HBoxContainer.new()
	v.add_child(top)
	top.add_child(UIKit.label("Where will you go?", 32, UIKit.GOLD))
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(sp)
	top.add_child(UIKit.button("Back to Tower", func(): main.show_tower(), Vector2(160, 36)))
	var prep_warn := UIKit.label("", 15, UIKit.BAD)
	if Game.s.prepared.is_empty():
		prep_warn.text = "You have not prepared any spells! Visit the Study first."
	v.add_child(prep_warn)
	var cards := HBoxContainer.new()
	cards.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cards.add_theme_constant_override("separation", 18)
	v.add_child(cards)
	for o in Game.s.offers:
		cards.add_child(_card(o))

func _card(o: Dictionary) -> Control:
	var env: Dictionary = DB.envs[o.env]
	var pc := PanelContainer.new()
	pc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	pc.add_child(v)
	var prev := EnvPreview.new()
	prev.env_id = o.env
	prev.seed_v = o.seed
	v.add_child(prev)
	v.add_child(UIKit.label(env.nm, 26, UIKit.GOLD))
	var d := UIKit.label(env.desc, 14, UIKit.DIM)
	d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(d)
	var mods := LevelGen.mission_mods(o.obj, o.diff, o.seed)
	v.add_child(UIKit.rich("[b]Goal:[/b] %s" % Game.objective_text(o.obj, mods)))
	var band := clampi(int((o.diff - Game.base_difficulty() + 0.9) / 0.75), 0, 3)
	var dc: Color = [UIKit.GOOD, UIKit.TEXT, Color("f0a050"), UIKit.BAD][band]
	var skulls := "☠".repeat(1 + band)
	v.add_child(UIKit.rich("[b]Danger:[/b] [color=%s]%s %s[/color]" % [UIKit.color_hex(dc), Game.DIFF_NAMES[band], skulls]))
	var hints: Array = []
	if o.obj == "slay_wizard":
		hints.append("A rival wizard of %s lairs here." % DB.SCHOOLS[env.wizards[0]].nm.to_lower() if env.wizards.size() > 0 else "A rival wizard lairs here.")
	for m in mods:
		if LevelGen.MOD_INFO.get(m, "") != "":
			hints.append(LevelGen.MOD_INFO[m])
	hints.append("Hazards: " + ", ".join(_hazard_names(env)))
	var hint := UIKit.label("\n".join(hints), 13, UIKit.DIM)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(hint)
	var sp := Control.new()
	sp.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(sp)
	if o.book != "":
		var b: Dictionary = DB.books[o.book]
		v.add_child(UIKit.rich("[b]Reward:[/b] [color=%s]%s[/color]\n[color=#9a96aa]%s book, %d spells, up to level %d[/color]" % [UIKit.color_hex(b.col), b.nm, DB.SCHOOLS[b.school].nm, b.spells.size(), b.tier]))
	else:
		v.add_child(UIKit.rich("[b]Reward:[/b] Insight (+1 Mind)"))
	var btn := UIKit.button("Embark", func(): main.start_battle(o), Vector2(0, 46))
	v.add_child(btn)
	return pc

func _hazard_names(env: Dictionary) -> Array:
	var out: Array = []
	for h in env.hazards:
		var n: String = DB.objs[h[0]].nm
		if not out.has(n) and out.size() < 3:
			out.append(n)
	return out
