class_name BattleScreen
extends Screen
## The one-screen battle: board, HUD, input and event playback.

var offer: Dictionary
var b: Battle
var bv: BoardView
var holder: Control
var selected: Entity = null
var mode: String = "idle"          # idle | target
var spell_sel: String = ""
var busy: bool = false
var finished: bool = false
var info: RichTextLabel
var logbox: RichTextLabel
var spell_box: VBoxContainer
var card: RichTextLabel
var end_btn: Button
var cancel_btn: Button
var dismount_btn: Button
var mount_btn: Button
var cast_btn: Button          # confirms a hand-placed ("pick") spell
var picks: Array = []          # squares placed so far for a pick spell
var touch_pending := Vector2i(-1, -1)   # touch: first tap previews, second tap confirms
var top_label: Label
var round_label: Label
var banner: Label
var spell_desc: RichTextLabel
var _prev: Dictionary = {}
var spell_scroll: ScrollContainer
var speed: float = 1.0
var _spell_order: Array = []

const T := DB.TILE

# ================================================================== setup
func setup(m: Control) -> void:
	super.setup(m)
	b = Game.start_battle(offer)
	_build_ui()
	bv.init_board(b)
	selected = b.player
	await _flush()

var side_panel: VBoxContainer

func _build_ui() -> void:
	# top bar
	top_label = UIKit.label("", 18, UIKit.GOLD)
	top_label.position = Vector2(12, 8)
	add_child(top_label)
	round_label = UIKit.label("", 18, UIKit.TEXT)
	round_label.position = Vector2(660, 8)
	add_child(round_label)
	# board
	holder = Control.new()
	holder.position = Vector2(8, 40)
	holder.size = Vector2(DB.W * T, DB.H * T)
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(holder)
	bv = BoardView.new()
	holder.add_child(bv)
	banner = UIKit.label("", 40, Color.WHITE)
	banner.add_theme_color_override("font_outline_color", Color.BLACK)
	banner.add_theme_constant_override("outline_size", 8)
	banner.position = Vector2(8, 300)
	banner.size = Vector2(DB.W * T, 60)
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.modulate.a = 0
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(banner)
	# right panel
	var panel := VBoxContainer.new()
	side_panel = panel
	panel.add_theme_constant_override("separation", 6)
	panel.clip_contents = true
	add_child(panel)
	get_viewport().size_changed.connect(_fit_panel)
	call_deferred("_fit_panel")
	var cp := PanelContainer.new()
	card = RichTextLabel.new()
	card.bbcode_enabled = true
	card.fit_content = true
	card.scroll_active = false
	cp.add_child(card)
	panel.add_child(cp)
	var ip := PanelContainer.new()
	ip.custom_minimum_size = Vector2(0, 100 if UIKit.touch else 128)
	ip.size_flags_vertical = Control.SIZE_EXPAND_FILL      # spare height goes to creature details...
	ip.size_flags_stretch_ratio = 1.0
	info = RichTextLabel.new()
	info.bbcode_enabled = true
	info.scroll_active = true
	ip.add_child(info)
	panel.add_child(ip)
	UIKit.drag_rich(info)
	# moving the mouse to the side panel crosses empty tiles: don't replace a creature's card on the way
	panel.mouse_entered.connect(func(): _info_gen += 1; _info_reset_fade())
	info.mouse_entered.connect(func(): _info_gen += 1; _info_reset_fade())
	panel.add_child(UIKit.label("Spells (1-9)", 14, UIKit.GOLD))
	call_deferred("_report_width")
	var sc := ScrollContainer.new()
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL      # ...and to the spell list
	sc.size_flags_stretch_ratio = 2.0
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.scroll_deadzone = 12
	spell_scroll = sc
	spell_box = VBoxContainer.new()
	spell_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spell_box.add_theme_constant_override("separation", 2)
	sc.add_child(spell_box)
	panel.add_child(sc)
	spell_desc = RichTextLabel.new()
	spell_desc.bbcode_enabled = true
	spell_desc.custom_minimum_size = Vector2(0, 56 if UIKit.touch else 70)
	spell_desc.scroll_active = true
	spell_desc.size_flags_vertical = Control.SIZE_EXPAND_FILL   # status explanations make this longer
	spell_desc.size_flags_stretch_ratio = 1.0
	panel.add_child(spell_desc)
	UIKit.drag_rich(spell_desc)
	var bh := HBoxContainer.new()
	panel.add_child(bh)
	end_btn = UIKit.button("End Turn" if UIKit.touch else "End Turn  [Space]", func(): _end_turn(), Vector2(0, 40))
	end_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	end_btn.clip_text = true       # never let a long label widen the side panel
	bh.add_child(end_btn)
	cancel_btn = UIKit.button("Cancel", func(): _cancel(), Vector2(0, 40))
	cancel_btn.visible = false
	bh.add_child(cancel_btn)
	cast_btn = UIKit.button("Cast", func(): _cast_picks(), Vector2(0, 40))
	cast_btn.visible = false
	bh.add_child(cast_btn)
	dismount_btn = UIKit.button("Dismount", func(): _do_dismount(), Vector2(0, 40))
	dismount_btn.visible = false
	bh.add_child(dismount_btn)
	threat_btn = UIKit.button("", func(): _toggle_threat(threat_btn.button_pressed), Vector2(40, 40))
	threat_btn.toggle_mode = true
	threat_btn.icon = _eye_icon(false)
	threat_btn.expand_icon = false
	threat_btn.tooltip_text = "Show every enemy's movement and threat range, and traps about to go off"
	bh.add_child(threat_btn)
	mount_btn = UIKit.button("Mount", func(): if selected != null and selected.alive: _do_mount(selected), Vector2(0, 40))
	mount_btn.visible = false
	bh.add_child(mount_btn)
	var flee_btn := UIKit.button("Flee", func(): _confirm_flee(), Vector2(0, 40))
	bh.add_child(flee_btn)
	var lp := PanelContainer.new()
	lp.custom_minimum_size = Vector2(0, 100 if UIKit.touch else 110)
	lp.size_flags_vertical = Control.SIZE_EXPAND_FILL
	lp.size_flags_stretch_ratio = 1.0
	logbox = RichTextLabel.new()
	logbox.bbcode_enabled = true
	logbox.scroll_following = true
	lp.add_child(logbox)
	UIKit.drag_rich(logbox)
	panel.add_child(lp)

## The side panel claims all spare window space: the stage is centred, so on a taller or wider
## window the panel extends to the window's top/bottom/right edges (the board stays put).
func _fit_panel() -> void:
	if side_panel == null or not is_inside_tree():
		return
	var vs := get_viewport_rect().size
	var extra := (vs - Vector2(1280, 720)).max(Vector2.ZERO) / 2.0
	var top := 40.0 if extra.y <= 0.0 else 8.0 - extra.y
	var bottom := 716.0 + extra.y - (0.0 if extra.y <= 0.0 else 4.0)
	var right := 1272.0 + extra.x - (0.0 if extra.x <= 0.0 else 8.0)
	side_panel.position = Vector2(976, top)
	side_panel.size = Vector2(right - 976.0, bottom - top)

# ================================================================== helpers
func _tile_at_mouse() -> Vector2i:
	var p := get_local_mouse_position() - holder.position
	return Vector2i(int(floor(p.x / T)), int(floor(p.y / T)))

func _log(text: String, col: String = "#e6e2f0") -> void:
	logbox.append_text("[color=%s]%s[/color]\n" % [col, text])

func _wait(sec: float) -> void:
	await get_tree().create_timer(sec / speed).timeout

func _float(p: Vector2i, text: String, col: Color, size: int = 20, rise: float = 34.0) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 6)
	l.position = bv.tile_center(p) + Vector2(-30, -34)
	l.size = Vector2(60, 24)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bv.fx_layer.add_child(l)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(l, "position:y", l.position.y - rise, 0.8 / speed)
	tw.tween_property(l, "modulate:a", 0.0, 0.8 / speed).set_delay(0.3 / speed)
	tw.chain().tween_callback(l.queue_free)

func _flash(p: Vector2i, col: Color, delay: float = 0.0, dur: float = 0.35) -> void:
	var n := Node2D.new()
	n.position = Vector2(p.x * T, p.y * T)
	n.modulate.a = 0.0
	n.set_script(preload("res://src/ui/fx_rect.gd"))
	n.col = col
	bv.fx_layer.add_child(n)
	var tw := create_tween()
	tw.tween_property(n, "modulate:a", 0.9, 0.05 / speed).set_delay(delay / speed)
	tw.tween_property(n, "modulate:a", 0.0, dur / speed)
	tw.tween_callback(n.queue_free)

func _projectile(from: Vector2i, to: Vector2i, col: Color, dur: float) -> void:
	var n := Node2D.new()
	n.set_script(preload("res://src/ui/fx_orb.gd"))
	n.col = col
	n.position = bv.tile_center(from)
	bv.fx_layer.add_child(n)
	var tw := create_tween()
	tw.tween_property(n, "position", bv.tile_center(to), dur / speed)
	tw.tween_callback(n.queue_free)
	await tw.finished

func _spell_sfx(school: String) -> void:
	match school:
		"pyromancy": Sfx.play("fire")
		"storm": Sfx.play("electro")
		"evocation", "cryomancy", "spatial", "earth": Sfx.play("beam")
		"conjuration", "nature", "chaos", "alchemy": Sfx.play("gooey")
		"divine": Sfx.play("justice", -10.0)
		_: Sfx.play("spellsuccess")

# ================================================================== event playback
func _flush() -> void:
	busy = true
	while true:
		var evs := b.drain_events()
		if evs.is_empty():
			break
		for ev in evs:
			await _play(ev)
	busy = false
	_refresh()
	if b.result != "" and not finished:
		await _wait(0.5)
		_show_result()

func _make_view(e: Entity) -> UnitView:
	var v := UnitView.new()
	v.setup(e)
	v.position = Vector2(e.pos.x * T, e.pos.y * T)
	if e.kind == Entity.OBJECT:
		bv.objs_layer.add_child(v)
	else:
		bv.units_layer.add_child(v)
	bv.views[e.uid] = v
	return v

func _play(ev: Dictionary) -> void:
	match ev.t:
		"spawn":
			var e: Entity = ev.ent
			var v := _make_view(e)
			v.position = Vector2(ev.pos.x * T, ev.pos.y * T)
			if e.kind == Entity.OBJECT:
				var hidden: bool = e.props.get("hidden", false)
				if hidden:
					if e.props.get("owner_team", -1) == -1:
						v.visible = false
					else:
						v.modulate.a = 0.5
			if not ev.get("initial", false):
				v.modulate.a = 0.0
				v.scale = Vector2(0.4, 0.4)
				v.position += Vector2(T * 0.3, T * 0.3)
				var tw := create_tween()
				tw.set_parallel(true)
				tw.tween_property(v, "modulate:a", 1.0 if not e.props.get("hidden", false) else 0.5, 0.2 / speed)
				tw.tween_property(v, "scale", Vector2.ONE, 0.2 / speed)
				tw.tween_property(v, "position", Vector2(ev.pos.x * T, ev.pos.y * T), 0.2 / speed)
				if e.is_unit():
					Sfx.play("gooey", -10.0)
				await tw.finished
		"move", "slide":
			var v: UnitView = bv.view_of(ev.id)
			if v == null:
				return
			var to: Vector2 = Vector2(ev.to.x * T, ev.to.y * T)
			v.face(signi(int(to.x - v.position.x)))
			var tw2 := create_tween()
			tw2.tween_property(v, "position", to, (0.11 if ev.t == "move" else 0.07) / speed)
			if ev.t == "move":
				Sfx.play("walk", -14.0)
			await tw2.finished
		"teleport":
			var v: UnitView = bv.view_of(ev.id)
			if v == null:
				return
			var tw3 := create_tween()
			tw3.tween_property(v, "modulate:a", 0.0, 0.1 / speed)
			tw3.tween_callback(func(): v.position = Vector2(ev.to.x * T, ev.to.y * T))
			tw3.tween_property(v, "modulate:a", 1.0, 0.12 / speed)
			await tw3.finished
		"attack":
			var v: UnitView = bv.view_of(ev.id)
			var tv: UnitView = bv.view_of(ev.tid)
			if v == null or tv == null:
				return
			v.face(signi(int(tv.position.x - v.position.x)))
			var from := v.position
			if ev.kind == "melee":
				var tw4 := create_tween()
				tw4.tween_property(v, "position", from.lerp(tv.position, 0.45), 0.07 / speed)
				tw4.tween_property(v, "position", from, 0.09 / speed)
				Sfx.play("attack")
				await tw4.finished
			else:
				var col := _type_col(ev.type)
				Sfx.play("range", -10.0)
				await _projectile(Vector2i(int(from.x / T), int(from.y / T)), Vector2i(int(tv.position.x / T), int(tv.position.y / T)), col, 0.16)
		"cast":
			var v: UnitView = bv.view_of(ev.id)
			if v != null:
				_float(Vector2i(int(v.position.x / T), int(v.position.y / T)), ev.name, DB.school_col(DB.spells[ev.spell].school), 18, 44.0)
			_log("%s casts %s." % [b_name(ev.id, ev.team), ev.name], UIKit.color_hex(DB.school_col(DB.spells[ev.spell].school)))
			await _wait(0.12)
		"fx":
			await _play_fx(ev)
		"dmg":
			var v: UnitView = bv.view_of(ev.id)
			if v == null:
				return
			v.hp = ev.hp
			v.queue_redraw()
			var p := Vector2i(int(v.position.x / T), int(v.position.y / T))
			_float(p, "-%d" % mini(ev.n, 9) if ev.n < 90 else "DEATH", _type_col(ev.type), 22)
			v.sprite.modulate = Color(1, 0.3, 0.3)
			var tw5 := create_tween()
			tw5.tween_property(v.sprite, "modulate", Color.WHITE, 0.2 / speed)
			var ox := v.position
			tw5.parallel().tween_property(v, "position", ox + Vector2(4, 0), 0.04 / speed)
			tw5.tween_property(v, "position", ox - Vector2(4, 0), 0.05 / speed)
			tw5.tween_property(v, "position", ox, 0.04 / speed)
			await tw5.finished
		"block":
			var v: UnitView = bv.view_of(ev.id)
			if v != null:
				var txt := {"shield": "Shield!", "mirror": "Image!", "resist": "Resisted", "immune": "Immune", "ward": "Warded", "boss": "Resists", "blessed": "Blessed", "steady": "Steadied", "undead": "Immune", "construct": "Immune", "weak": "Weak", "wizard": "Wizards resist"}.get(ev.why, "Blocked")
				_float(Vector2i(int(v.position.x / T), int(v.position.y / T)), txt, Color("a0c0ff"), 16)
				Sfx.play("urgh", -16.0)
				await _wait(0.1)
		"heal":
			var v: UnitView = bv.view_of(ev.id)
			if v != null:
				v.hp = ev.hp
				v.max_hp = ev.max
				v.queue_redraw()
				_float(Vector2i(int(v.position.x / T), int(v.position.y / T)), "+%d" % ev.n, UIKit.GOOD, 20)
				await _wait(0.1)
		"hp":
			var v: UnitView = bv.view_of(ev.id)
			if v != null:
				v.hp = ev.hp
				v.queue_redraw()
		"die":
			var v: UnitView = bv.view_of(ev.id)
			if v == null:
				return
			bv.views.erase(ev.id)
			if not ev.silent:
				Sfx.play("scream", -10.0)
			var tw6 := create_tween()
			tw6.set_parallel(true)
			tw6.tween_property(v, "modulate:a", 0.0, 0.3 / speed)
			tw6.tween_property(v.sprite, "scale", v.sprite.scale * 0.3, 0.3 / speed)
			tw6.chain().tween_callback(v.queue_free)
			_log("%s is destroyed." % v.ent.nm, "#c8a0a0")
			await _wait(0.2)
		"remove":
			var v: UnitView = bv.view_of(ev.id)
			if v == null:
				return
			bv.views.erase(ev.id)
			var tw7 := create_tween()
			tw7.tween_property(v, "modulate:a", 0.0, 0.25 / speed)
			tw7.tween_callback(v.queue_free)
		"status":
			var v: UnitView = bv.view_of(ev.id)
			if v == null:
				return
			if ev.on:
				v.st[ev.s] = true
				var sd: Dictionary = DB.STATUS[ev.s]
				_float(Vector2i(int(v.position.x / T), int(v.position.y / T)), sd.nm, sd.col, 14)
			else:
				v.st.erase(ev.s)
			if ev.s in ["enlarged", "reduced", "tiny", "mounted"]:
				v.refresh_texture()
			v.queue_redraw()
		"team":
			var v: UnitView = bv.view_of(ev.id)
			if v != null:
				v.team = ev.team
				v.queue_redraw()
		"terrain":
			bv.terr[ev.pos.y * b.board.w + ev.pos.x] = ev.to
			_flash(ev.pos, Color(1, 1, 1, 0.5), 0.0, 0.3)
		"corpse":
			bv.corpses[ev.pos] = ev.on
		"reveal":
			var v: UnitView = bv.view_of(ev.id)
			if v != null:
				v.visible = true
				v.modulate.a = 1.0
				_float(Vector2i(int(v.position.x / T), int(v.position.y / T)), "!", Color("ffd060"), 22)
		"trigger":
			_flash(ev.pos, Color(1, 0.6, 0.2, 0.7), 0.0, 0.4)
			Sfx.play("spellstep", -8.0)
		"warn":
			bv.warn_tiles[ev.pos] = true
		"msg":
			_log(ev.text, "#d8c8f0")
			await _wait(0.1)
		"phase":
			bv.warn_tiles = {}
			if ev.team == Battle.PLAYER:
				_banner("Round %d" % ev.round, Color("9ac8ff"))
			else:
				_banner("Enemy Turn", Color("ff8a8a"))
			await _wait(0.35)
		"round_end":
			bv.warn_tiles = {}
		"skip":
			var v: UnitView = bv.view_of(ev.id)
			if v != null:
				_float(Vector2i(int(v.position.x / T), int(v.position.y / T)), "Zzz" if ev.s == "asleep" else DB.STATUS[ev.s].nm, Color("c0c0ff"), 16)
				await _wait(0.12)
		"alert":
			var v: UnitView = bv.view_of(ev.id)
			if v != null:
				v.dormant = false
				v.queue_redraw()
				_float(Vector2i(int(v.position.x / T), int(v.position.y / T)), "!", Color("ff6060"), 26)
				await _wait(0.08)
		"channel":
			if ev.on:
				_banner("Hold the book!", Color("ffe060"))
			else:
				_banner("The book slips away", Color("ff9070"))
			await _wait(0.3)
		"trap":
			Sfx.play("urgh")
			_banner("It's a trap!", Color("ff5050"))
			_flash(ev.pos, Color(1, 0.3, 0.2, 0.8), 0.0, 0.6)
			await _wait(0.5)
		"exit":
			_banner("Escape!", Color("70ffa0"))
			await _wait(0.3)
		"book":
			Sfx.play("chosen")
			_float(ev.pos, "Spell book!", UIKit.GOLD, 24, 50.0)
			_flash(ev.pos, Color(1, 0.9, 0.4, 0.8), 0.0, 0.6)
			await _wait(0.4)
		"bump":
			Sfx.play("urgh", -12.0)
		"morph":
			var v: UnitView = bv.view_of(ev.id)
			if v != null:
				v.ent = ev.ent
				v.max_hp = ev.ent.max_hp
				v.hp = ev.ent.hp
				v.refresh_texture()
				v.queue_redraw()
				_flash(Vector2i(int(v.position.x / T), int(v.position.y / T)), Color(1, 0.4, 1, 0.7), 0.0, 0.4)
				await _wait(0.15)
		"restyle":
			var v: UnitView = bv.view_of(ev.id)
			if v != null:
				v.sprite.modulate = ev.tint
		"dot":
			pass
		"end":
			pass

func b_name(id: int, team: int) -> String:
	var v: UnitView = bv.view_of(id)
	if v != null:
		return v.ent.nm
	return "Someone"

func _type_col(t: String) -> Color:
	match t:
		"fire": return Color("ff8030")
		"cold": return Color("80e0ff")
		"elec": return Color("e0e060")
		"acid": return Color("a0e030")
		"poison": return Color("70c030")
		"necro": return Color("b060e0")
		"holy": return Color("fff0a0")
		"radiant": return Color("fffad0")
		"force": return Color("a0a0ff")
		"psychic": return Color("ff80c0")
		"sonic": return Color("c0c0e0")
	return Color("ffffff")

func _banner(text: String, col: Color) -> void:
	banner.text = text
	banner.add_theme_color_override("font_color", col)
	banner.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_property(banner, "modulate:a", 0.0, 0.7 / speed).set_delay(0.25 / speed)

func _play_fx(ev: Dictionary) -> void:
	var col: Color = ev.col
	var tiles: Array = ev.tiles
	var from: Vector2i = ev.from
	var to: Vector2i = ev.to
	_spell_sfx(ev.school)
	match ev.vis:
		"single", "bolt", "chain":
			var last := from
			var hops: Array = tiles if ev.vis == "chain" else ([tiles.back()] if (ev.vis == "bolt" and not tiles.is_empty()) else [to])
			for h in hops:
				if h != last:
					await _projectile(last, h, col, 0.05 + 0.015 * Board.cheb(last, h))
				last = h
			for tt in tiles:
				_flash(tt, col)
			await _wait(0.1)
		"pulse":
			for tt in tiles:
				_flash(tt, col)
			await _wait(0.1)
		_:
			var origin := from if ev.vis in ["line", "cone", "los", "all", "perp", "rebound", "phase_line"] else to
			var maxd := 0
			for tt in tiles:
				var d := Board.cheb(origin, tt)
				maxd = maxi(maxd, d)
				_flash(tt, col, d * 0.03)
			await _wait(0.12 + maxd * 0.03)

# ================================================================== state refresh
func _refresh() -> void:
	if b == null:
		return
	var pl := b.player
	top_label.text = "%s — %s" % [DB.envs[b.env_id].nm, Game.objective_text(b.objective.type, b.objective.get("mods", []), b.book_taken)]
	top_label.text += "  ·  " + b.tod_name()
	if b.weather_name() != "":
		top_label.text += "  ·  " + b.weather_name()
	bv.queue_redraw()
	var foes := b.board.units_of(Battle.ENEMY).size()
	round_label.text = "Round %d   ·   Foes left: %d" % [b.round_no, foes]
	round_label.position.x = 976 - round_label.get_minimum_size().x - 30
	# wizard card
	var sts: Array = []
	for s in pl.status:
		var sd: Dictionary = DB.STATUS[s]
		sts.append(SpellText.status_link(s))
	var form_nm: String = " [color=#e0b070](%s)[/color]" % DB.monsters[pl.form].nm if pl.form != "" else ""
	var t := "[b]%s[/b]%s  Lv %d\n[color=#ff8a8a]%s[/color]  %d/%d HP\nMove %d · Cast %d · Hit %d" % [pl.nm, form_nm, Game.s.level, UIKit.pips(pl.hp, pl.max_hp), pl.hp, pl.max_hp, pl.moves_left, pl.casts_left, pl.attacks_left]
	if not sts.is_empty():
		t += "\n" + ", ".join(sts)
	card.text = t
	if not card.meta_clicked.is_connected(_status_clicked):
		card.meta_underlined = true
		card.meta_clicked.connect(_status_clicked)
	_mark_ready()
	_rebuild_spells()
	cancel_btn.visible = mode == "target"
	dismount_btn.visible = not b.player.mount.is_empty() and b.phase == "player" and b.result == ""
	mount_btn.visible = b.player.mount.is_empty() and b.phase == "player" and b.result == "" and not busy and selected != null and selected.alive \
		and selected != b.player and selected.kind == Entity.CREATURE and selected.has_ab("mount") and selected.team == Battle.PLAYER and not selected.props.get("free", false)
	var picking: bool = mode == "target" and DB.spells[spell_sel].shape == "pick"
	cast_btn.visible = picking
	if picking:
		cast_btn.text = "Cast %d/%d" % [picks.size(), DB.spells[spell_sel].r]
		cast_btn.disabled = picks.is_empty()
	end_btn.disabled = busy or b.phase != "player" or b.result != ""
	_update_highlights()
	_update_info(bv.hover_tile)

## Whoever is casting right now: the selected summon if it carries spells of its own, otherwise your wizard.
func _cs() -> Entity:
	if selected != null and selected.alive and selected.team == Battle.PLAYER and selected.has_spellbook():
		return selected
	return b.player

func _rebuild_spells() -> void:
	for c in spell_box.get_children():
		c.queue_free()
	var counts := {}
	for id in _cs().spells:
		counts[id] = counts.get(id, 0) + 1
	var ids: Array = counts.keys()
	ids.sort_custom(func(a, c):
		if DB.spells[a].lvl != DB.spells[c].lvl:
			return DB.spells[a].lvl < DB.spells[c].lvl
		return DB.spells[a].nm < DB.spells[c].nm)
	_spell_order = ids
	var i := 0
	for id in ids:
		var sp: Dictionary = DB.spells[id]
		var btn := Button.new()
		btn.clip_text = true
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.text = "%s %s%s" % [str(i + 1) if i < 9 else " ", sp.nm, " x%d" % counts[id] if counts[id] > 1 else ""]
		btn.add_theme_color_override("font_color", DB.school_col(sp.school).lightened(0.3))
		btn.disabled = busy or b.phase != "player" or not b.can_cast(_cs())
		if mode == "target" and spell_sel == id:
			btn.add_theme_stylebox_override("normal", UIKit.box(Color("4a3a78"), UIKit.GOLD))
		UIKit.drag_scroll(btn, spell_scroll)
		btn.pressed.connect(func():
			if not UIKit.was_dragged(btn):
				_pick_spell(id))
		btn.mouse_entered.connect(func():
			if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				_desc_spell(id))
		spell_box.add_child(btn)
		i += 1
	if _cs() != b.player:
		var hdr := UIKit.label("%s's spells (at will)" % _cs().nm, 13, UIKit.GOLD)
		spell_box.add_child(hdr)
		spell_box.move_child(hdr, 0)
	if ids.is_empty():
		spell_box.add_child(UIKit.label("No spells left.", 14, UIKit.DIM))

## Allies that can still move/attack/cast get a gold ring and arrow; those that are finished are dimmed.
func _mark_ready() -> void:
	for e in b.board.units_of(Battle.PLAYER):
		var v: UnitView = bv.view_of(e.uid)
		if v == null:
			continue
		if b.phase != "player" or b.result != "" or e.props.get("free", false):
			v.set_turn_state(0)
		elif e.moves_left > 0 or e.attacks_left > 0 or e.casts_left > 0:
			v.set_turn_state(1)
		else:
			v.set_turn_state(2)

func _report_width() -> void:
	if "--shots" in OS.get_cmdline_user_args():
		print("PANEL MINW ", side_panel.get_combined_minimum_size().x)

func _status_clicked(meta: Variant) -> void:
	var m := str(meta)
	if m.begins_with("st:") and DB.STATUS.has(m.substr(3)):
		info.text = SpellText.status_note(m.substr(3))

func _desc_spell(id: String) -> void:
	var sp: Dictionary = DB.spells[id]
	spell_desc.text = "[b][color=%s]%s[/color][/b]\n%s" % [UIKit.color_hex(DB.school_col(sp.school)), sp.nm, SpellText.describe(sp)]

func _update_highlights() -> void:
	bv.clear_highlights()
	_show_threat(bv.hover_tile)
	bv.selected_tile = Vector2i(-1, -1)
	if busy or b.phase != "player" or b.result != "":
		return
	if mode == "target":
		var sp: Dictionary = DB.spells[spell_sel]
		bv.target_tiles = SpellEngine.valid_targets(b, _cs(), sp)
		bv.aoe_col = DB.school_col(sp.school)
		return
	if selected == null or not selected.alive or selected.team != Battle.PLAYER:
		selected = b.player if b.player.alive else null
	if selected == null:
		return
	bv.selected_tile = selected.pos
	var prev := {}
	var reach := b.board.reach(selected, selected.moves_left, prev, false)
	reach.erase(selected.pos)
	_prev = prev
	bv.reach_tiles = reach
	for p in reach:
		if b.board.is_dangerous(selected, p, true):
			bv.danger_tiles[p] = true
	if selected.attacks_left > 0:
		for o in b.board.ents:
			if o.alive and o.kind == Entity.OBJECT and b.can_attack(selected, o):
				bv.attack_now.append(o.pos)
		for h in b.board.units_of(Battle.ENEMY):
			if b.can_attack(selected, h):
				bv.attack_now.append(h.pos)
			elif selected.moves_left > 0:
				for p in reach:
					if EnemyAI._hit_kind_from(b, selected, p, h) != "":
						bv.attack_move.append(h.pos)
						break

## Hovering an enemy shows where it can walk this coming turn and which further squares it could strike;
## hovering a trap or vent shows the squares it reaches. The toggle does this for everything dangerous at once.
var threat_all := false
var threat_btn: Button

func _show_threat(p: Vector2i) -> void:
	bv.threat_move = {}
	bv.threat_hit = {}
	if b == null or busy:
		return
	if threat_all:
		for e in b.board.ents:
			if not e.alive:
				continue
			if e.kind == Entity.OBJECT:
				if _trap_soon(e):
					_threat_of(e, bv.threat_move, bv.threat_hit)
			elif e.is_unit() and e.team != Battle.PLAYER:
				_threat_of(e, bv.threat_move, bv.threat_hit)
	if not b.board.inb(p):
		return
	var u := b.board.unit_at(p)
	if u != null:
		_threat_of(u, bv.threat_move, bv.threat_hit)
	else:
		for o in b.board.objects_at(p):
			_threat_of(o, bv.threat_move, bv.threat_hit)

func _trap_soon(o: Entity) -> bool:
	var d: Dictionary = o.odef()
	if o.props.get("hidden", false) and o.props.get("owner_team", -1) == -1:
		return false
	if d.has("cycle"):
		return int(d.cycle.period) - o.timer <= 1
	return d.has("pulse") or d.has("on_death")

func _threat_of(e: Entity, mv: Dictionary, hit: Dictionary) -> void:
	if e.kind == Entity.OBJECT:
		if e.props.get("hidden", false) and e.props.get("owner_team", -1) == -1:
			return
		var od: Dictionary = e.odef()
		var r := -1
		for key in ["cycle", "pulse", "on_enter", "on_death"]:
			if od.has(key):
				r = maxi(r, int(od[key].get("r", 0)))
		if od.has("grow") and od.has("pulse"):
			r = maxi(r, int(od.grow.max))
		if r < 0:
			return
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				var q: Vector2i = e.pos + Vector2i(dx, dy)
				if b.board.inb(q):
					hit[q] = true
		return
	if not e.alive or e.team == Battle.PLAYER:
		return
	var reach := {e.pos: 0}
	if not (e.has_st("rooted") or e.has_st("stunned") or e.has_ab("stationary")):
		reach = b.board.reach(e, b.calc_move(e), {}, true)
	var walk := {}
	for q in reach:
		if q != e.pos:
			walk[q] = true
			mv[q] = true
	if e.has_st("feared") or e.has_st("stunned") or (e.has_ab("healer") and e.dmg == 0):
		return
	var rng := 2 if e.has_ab("reach") else 1
	if e.ranged.size() >= 3:
		rng = maxi(rng, 1 if e.has_st("blind") else int(e.ranged[0]))
	for q in reach:
		for dy in range(-rng, rng + 1):
			for dx in range(-rng, rng + 1):
				var t: Vector2i = q + Vector2i(dx, dy)
				if t == q or not b.board.inb(t) or walk.has(t) or t == e.pos or hit.has(t):
					continue
				if maxi(absi(dx), absi(dy)) > 1 and not b.board.los(q, t):
					continue
				hit[t] = true

## Closed eye (off) / open eye (on), drawn in code so no font glyph is needed.
func _eye_icon(open: bool) -> ImageTexture:
	var n := 28
	var im := Image.create(n, n, false, Image.FORMAT_RGBA8)
	var c := Color(0.95, 0.9, 0.7)
	var cx := n / 2.0
	var cy := n / 2.0 + (3.0 if not open else 0.0)
	for x in range(2, n - 2):
		var t := (x - cx) / (n / 2.0 - 2.0)
		var h := (1.0 - t * t) * 7.0
		if open:
			for sgn in [-1, 1]:
				var y := int(round(cy + sgn * h))
				for dy in range(2):
					if y + dy >= 0 and y + dy < n:
						im.set_pixel(x, y + dy, c)
		else:
			var y2 := int(round(cy - 6.0 + (1.0 - t * t) * 6.0))
			for dy in range(2):
				im.set_pixel(x, clampi(y2 + dy, 0, n - 1), c)
	if open:
		for yy in range(n):
			for xx in range(n):
				if (xx - cx) * (xx - cx) + (yy - cy) * (yy - cy) <= 12.0:
					im.set_pixel(xx, yy, Color(1.0, 0.85, 0.3))
	else:
		# lashes under the closed lid
		for lx in [7, 14, 21]:
			var ly := int(round(cy - 6.0 + (1.0 - pow((lx - cx) / (n / 2.0 - 2.0), 2)) * 6.0)) + 2
			for k in range(4):
				var yy2 := clampi(ly + k, 0, n - 1)
				im.set_pixel(lx, yy2, c)
	return ImageTexture.create_from_image(im)

func _toggle_threat(on: bool) -> void:
	threat_all = on
	threat_btn.icon = _eye_icon(on)
	_show_threat(bv.hover_tile)

var _info_gen := 0
var _info_unit := false

## Hover preview with a short grace period: leaving a creature for empty ground keeps its card for a moment,
## so the mouse can travel to the panel and scroll it.
func _hover_info(p: Vector2i) -> void:
	_info_gen += 1
	_info_reset_fade()
	var has := b != null and b.board.inb(p) and (b.board.unit_at(p) != null or not b.board.objects_at(p).is_empty())
	if has or not _info_unit:
		_info_unit = has
		_update_info(p)
		return
	var g := _info_gen
	await get_tree().create_timer(1.0).timeout
	if g != _info_gen or not is_inside_tree():
		return
	# quick fade so it is clear the card is being replaced
	_info_tw = create_tween()
	_info_tw.tween_property(info, "modulate:a", 0.0, 0.22)
	await _info_tw.finished
	if g != _info_gen or not is_inside_tree():
		return
	_info_unit = false
	_update_info(p)
	_info_tw = create_tween()
	_info_tw.tween_property(info, "modulate:a", 1.0, 0.18)

var _info_tw: Tween

func _info_reset_fade() -> void:
	if _info_tw != null and _info_tw.is_valid():
		_info_tw.kill()
	info.modulate.a = 1.0

func _update_info(p: Vector2i) -> void:
	if b == null or not b.board.inb(p):
		if selected != null and selected.alive:
			info.text = SpellText.monster_text(selected)
		return
	var txt := ""
	var u := b.board.unit_at(p)
	if u != null:
		txt = SpellText.monster_text(u)
	for o in b.board.objects_at(p):
		if o.props.get("hidden", false) and o.props.get("owner_team", -1) == -1:
			continue
		txt += ("\n\n" if txt != "" else "") + SpellText.monster_text(o)
	var td := b.board.tdef(p)
	var tname: String = td.nm
	if td.has("hurt"):
		tname += " (%d %s damage)" % [td.hurt[0], td.hurt[1]]
	elif td.has("st"):
		tname += " (inflicts %s)" % DB.STATUS[td.st[0]].nm
	elif td.get("fall", false):
		tname += " (only fliers cross)"
	elif td.get("deep", false):
		tname += " (only fliers and swimmers)"
	elif td.get("cost", 1) > 1:
		tname += " (slow going)"
	txt += ("\n\n" if txt != "" else "") + "[color=#9a96aa]%s[/color]" % tname
	if b.board.corpses.has(p):
		txt += "\n[color=#9a96aa]A corpse lies here.[/color]"
	info.text = txt

# ================================================================== input
func _gui_input(ev: InputEvent) -> void:
	if finished:
		return
	if ev is InputEventMouseMotion:
		var p := _tile_at_mouse()
		if p != bv.hover_tile:
			bv.hover_tile = p
			_hover_info(p)
			_show_threat(p)
			bv.aoe_tiles = []
			if mode == "target" and not busy:
				var sp: Dictionary = DB.spells[spell_sel]
				if sp.shape == "pick":
					bv.aoe_tiles = picks.duplicate()
					if bv.target_tiles.has(p) and not picks.has(p) and picks.size() < sp.r and (picks.is_empty() or _touches_picks(p)):
						bv.aoe_tiles.append(p)
				elif bv.target_tiles.has(p) or sp.tgt == "self":
					bv.aoe_tiles = SpellEngine.tiles_for(b, _cs(), sp, p)
	elif ev is InputEventMouseButton and ev.pressed:
		if ev.button_index == MOUSE_BUTTON_LEFT:
			if ev.device == InputEvent.DEVICE_ID_EMULATION:
				_touch_tap(_tile_at_mouse())   # a finger, not a mouse
			else:
				_click(_tile_at_mouse())
		elif ev.button_index == MOUSE_BUTTON_RIGHT:
			_cancel()

## Touch has no hover, so: tap a tile to preview it (info card, spell area),
## tap the same tile again to commit. Tapping your own wizard/summons just selects.
func _touch_tap(p: Vector2i) -> void:
	if busy or finished or b.phase != "player" or not b.board.inb(p):
		return
	bv.hover_tile = p
	_update_info(p)
	var confirm := touch_pending == p
	var none := Vector2i(-1, -1)
	if mode == "target":
		if DB.spells[spell_sel].shape == "pick":
			_pick_tile(p)       # every tap places or removes a square; the Cast button confirms
			return
		if not bv.target_tiles.has(p):
			touch_pending = none
			_cancel()
			return
		if confirm:
			touch_pending = none
			_click(p)
			return
		touch_pending = p
		bv.aoe_tiles = SpellEngine.tiles_for(b, _cs(), DB.spells[spell_sel], p)
		info.text = "[color=#e8c870][b]Tap again to cast[/b][/color]\n" + info.text
		return
	var u := b.board.unit_at(p)
	if u != null and u.team == Battle.PLAYER and not u.props.get("free", false):
		touch_pending = none
		_click(p)
		return
	var smash := _smashable_at(p)
	var actionable: bool = ((u != null or smash != null) and selected != null) or bv.reach_tiles.has(p)
	if actionable and confirm:
		touch_pending = none
		_click(p)
	elif actionable:
		touch_pending = p
		var verb := "attack" if (u != null or smash != null) else "move here"
		info.text = "[color=#e8c870][b]Tap again to %s[/b][/color]\n%s" % [verb, info.text]
	else:
		touch_pending = none

func _unhandled_key_input(ev: InputEvent) -> void:
	if finished or not ev.pressed:
		return
	var k: int = ev.keycode
	if k == KEY_ESCAPE:
		_cancel()
	elif mode == "target" and k == KEY_ENTER and not picks.is_empty():
		_cast_picks()
	elif k == KEY_SPACE or k == KEY_ENTER:
		_end_turn()
	elif k == KEY_TAB:
		_cycle_unit()
	elif k >= KEY_1 and k <= KEY_9:
		var i := k - KEY_1
		if i < _spell_order.size():
			_pick_spell(_spell_order[i])

func _cancel() -> void:
	touch_pending = Vector2i(-1, -1)
	picks = []
	if mode == "target":
		mode = "idle"
		spell_sel = ""
		bv.aoe_tiles = []
		_refresh()

func _cycle_unit() -> void:
	if busy or b.phase != "player":
		return
	var units := b.board.units_of(Battle.PLAYER).filter(func(x): return not x.props.get("free", false))
	if units.is_empty():
		return
	var i := units.find(selected)
	selected = units[(i + 1) % units.size()]
	mode = "idle"
	_refresh()

func _pick_spell(id: String) -> void:
	touch_pending = Vector2i(-1, -1)
	if busy or b.phase != "player" or finished:
		return
	if not b.can_cast(_cs()):
		_log("You cannot cast right now.", "#e86060")
		return
	var sp: Dictionary = DB.spells[id]
	_desc_spell(id)
	if mode == "target" and spell_sel == id:
		_cancel()
		return
	var tg := SpellEngine.valid_targets(b, _cs(), sp)
	if b.ward_center().x >= 0 and SpellEngine._teleports(sp):
		_log("The ward blocks teleporting within 2 squares of the %s." % ("exit" if b.book_taken else "book"), "#c090ff")
	if tg.is_empty():
		_log("No valid targets for %s." % sp.nm, "#e86060")
		return
	mode = "target"
	spell_sel = id
	picks = []
	_refresh()
	if sp.shape == "pick":
		_show_picks()
	elif sp.tgt == "self":
		_log("Click your wizard to cast %s (right-click or Esc to cancel)." % sp.nm, "#e8c870")

## Hand-placed shapes: click squares to add them (each must touch the group so far); click one again to remove it.
func _pick_tile(p: Vector2i) -> void:
	var sp: Dictionary = DB.spells[spell_sel]
	if picks.has(p):
		var rest := picks.duplicate()
		rest.erase(p)
		if SpellEngine.connected(rest):
			picks = rest
		else:
			_log("Remove an end square first.", "#e86060")
	elif not bv.target_tiles.has(p):
		_log("Out of range.", "#e86060")
	elif picks.size() >= sp.r:
		_log("%s has only %d squares." % [sp.nm, sp.r], "#e86060")
	elif not picks.is_empty() and not _touches_picks(p):
		_log("Squares must touch each other.", "#e86060")
	else:
		picks.append(p)
		Sfx.play("menu")
		if picks.size() >= sp.r:
			_cast_picks()
			return
	_show_picks()

func _touches_picks(p: Vector2i) -> bool:
	for q in picks:
		if Board.cheb(p, q) <= 1:
			return true
	return false

func _show_picks() -> void:
	var sp: Dictionary = DB.spells[spell_sel]
	bv.aoe_tiles = picks.duplicate()
	cast_btn.text = "Cast %d/%d" % [picks.size(), sp.r]
	cast_btn.disabled = picks.is_empty()
	info.text = "[color=#e8c870][b]%s[/b][/color]\nClick up to %d connected squares, then Cast (Enter). Click a placed square to remove it." % [sp.nm, sp.r]

func _cast_picks() -> void:
	if mode != "target" or picks.is_empty():
		return
	_do_cast(spell_sel, picks[0], picks.duplicate())

func _click(p: Vector2i) -> void:
	if busy or finished or b.phase != "player" or not b.board.inb(p):
		return
	if mode == "target":
		var sp: Dictionary = DB.spells[spell_sel]
		if sp.shape == "pick":
			_pick_tile(p)
			return
		if bv.target_tiles.has(p):
			_do_cast(spell_sel, p)
		else:
			_cancel()
		return
	var u := b.board.unit_at(p)
	if u != null and u.team == Battle.PLAYER and not u.props.get("free", false):
		# clicking a steed selects it like any ally; the Mount button climbs on (walking up to it first if needed)
		if u != b.player and u.kind == Entity.CREATURE and u.has_ab("mount") and b.player.mount.is_empty() and selected != u:
			_log("The %s can be ridden: use the Mount button, or command it yourself." % u.nm, "#e8c870")
		selected = u
		_refresh()
		return
	if selected == null:
		return
	if u != null and u.team != Battle.PLAYER:
		_do_attack(selected, u)
		return
	var ob := _smashable_at(p)
	if ob != null:
		_do_attack(selected, ob)
		return
	if bv.reach_tiles.has(p):
		_do_move(selected, p)
	elif p != selected.pos:
		_log(_why_not(selected, p), "#e86060")

## A destructible, visible object a player unit may attack on tile p (or null).
func _smashable_at(p: Vector2i) -> Entity:
	for o in b.board.objects_at(p):
		if o.odef().get("hp", 0) > 0 and not o.props.get("hidden", false) and o.props.get("owner_team", -1) != Battle.PLAYER:
			return o
	return null

func _why_not(e: Entity, p: Vector2i) -> String:
	if e.moves_left <= 0:
		return "%s has no movement left." % e.nm
	var td := b.board.tdef(p)
	if td.get("deep", false) or td.get("fall", false):
		return "%s cannot cross that." % e.nm
	if b.board.blocking_object_at(p) != null or td.get("block", false):
		return "That square is blocked."
	return "Too far to reach this turn."

func _do_move(e: Entity, p: Vector2i) -> void:
	var path := b.board.path_from(_prev, e.pos, p)
	if path.is_empty():
		return
	busy = true
	b.walk(e, path)
	await _flush()

func _do_mount(steed: Entity) -> void:
	var w: Entity = b.player
	busy = true
	if Board.cheb(w.pos, steed.pos) > 1:
		var best := Vector2i(-1, -1)
		var best_path: Array = []
		for dy in range(-1, 2):
			for dx in range(-1, 2):
				var q: Vector2i = steed.pos + Vector2i(dx, dy)
				if (dx != 0 or dy != 0) and bv.reach_tiles.has(q):
					var pth := b.board.path_from(_prev, w.pos, q)
					if not pth.is_empty() and (best_path.is_empty() or pth.size() < best_path.size()):
						best = q
						best_path = pth
		if best_path.is_empty():
			busy = false
			_log("The %s is too far to reach this turn." % steed.nm, "#e86060")
			return
		b.walk(w, best_path)
		await _flush()
		busy = true
	if w.alive and steed.alive:
		b.mount_steed(w, steed)
	await _flush()
	selected = b.player

func _do_dismount() -> void:
	if busy or finished or b.phase != "player" or b.player.mount.is_empty():
		return
	busy = true
	b.dismount_free(b.player)
	await _flush()
	selected = b.player

func _do_attack(att: Entity, tgt: Entity) -> void:
	if att.attacks_left <= 0:
		_log("%s has already attacked." % att.nm, "#e86060")
		return
	if b.can_attack(att, tgt):
		busy = true
		b.attack(att, tgt)
		await _flush()
		return
	if att.moves_left > 0:
		var prev := {}
		var reach := b.board.reach(att, att.moves_left, prev, true)
		var best := Vector2i(-1, -1)
		var best_c := 999
		for p in reach:
			if p == att.pos:
				continue
			var kind := EnemyAI._hit_kind_from(b, att, p, tgt)
			if kind != "" and reach[p] < best_c:
				best_c = reach[p]
				best = p
		if best.x >= 0:
			busy = true
			b.walk(att, b.board.path_from(prev, att.pos, best))
			if att.alive and tgt.alive and b.can_attack(att, tgt):
				b.attack(att, tgt)
			await _flush()
			return
	_log("Out of reach.", "#e86060")

func _do_cast(id: String, p: Vector2i, placed: Array = []) -> void:
	busy = true
	mode = "idle"
	spell_sel = ""
	picks = []
	bv.aoe_tiles = []
	cast_btn.visible = false
	b.cast_spell(_cs(), id, p, placed)
	await _flush()

func _end_turn() -> void:
	if busy or finished or b.phase != "player" or b.result != "":
		return
	mode = "idle"
	busy = true
	end_btn.disabled = true
	bv.clear_highlights()
	b.end_player_phase()
	await _flush()
	if b.player.alive:
		selected = b.player

func _confirm_flee() -> void:
	if finished or busy:
		return
	UIKit.confirm(self, "Flee?", "Flee the battlefield? You will return to your tower empty-handed.", "Flee", func():
		b.msg("You flee!")
		b.lose()
		_flush(), "Stay")

# ================================================================== result
func _show_result() -> void:
	if finished:
		return
	finished = true
	var res := Game.finish_battle(b, offer)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.65)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var pc := PanelContainer.new()
	pc.custom_minimum_size = Vector2(560, 0)
	center.add_child(pc)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	pc.add_child(v)
	if res.result == "win":
		Sfx.play("justice")
		v.add_child(UIKit.label("VICTORY", 44, UIKit.GOLD))
		if res.book != "":
			var bk: Dictionary = DB.books[res.book]
			v.add_child(UIKit.rich("You claim [b][color=%s]%s[/color][/b]!" % [UIKit.color_hex(bk.col), bk.nm]))
			var parts: Array = []
			for sid in res.new_spells:
				var sp: Dictionary = DB.spells[sid]
				parts.append("[color=%s]%s[/color] (Lv %d)" % [UIKit.color_hex(DB.school_col(sp.school)), sp.nm, sp.lvl])
			v.add_child(UIKit.rich("[b]New spells:[/b] " + ", ".join(parts)))
		if res.bonus != "":
			v.add_child(UIKit.rich(res.bonus))
		if res.level_up:
			v.add_child(UIKit.rich("[b]You reach level %d.[/b] More Mind to prepare spells with%s." % [Game.s.level, ", and tougher skin" if (Game.s.level - 1) % 3 == 0 else ""]))
	else:
		Sfx.play("scream")
		v.add_child(UIKit.label("DEFEAT", 44, UIKit.BAD))
		v.add_child(UIKit.rich("You limp back to your tower. The book will keep, and so will your enemies."))
	v.add_child(UIKit.button("Return to the Tower", func(): main.show_tower(), Vector2(0, 46)))
