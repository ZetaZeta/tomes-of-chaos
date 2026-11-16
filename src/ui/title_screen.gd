class_name TitleScreen
extends Screen

var name_edit: LineEdit

func setup(m: Control) -> void:
	super.setup(m)
	backdrop("title", 0.25)
	# menu sits in the left third so it doesn't cover the tower in the backdrop
	var center := HBoxContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var lead := Control.new()
	lead.custom_minimum_size = Vector2(70 if Art.use_generated else 0, 0)
	lead.size_flags_horizontal = Control.SIZE_EXPAND_FILL if not Art.use_generated else Control.SIZE_FILL
	center.add_child(lead)
	var v := VBoxContainer.new()
	v.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	v.add_theme_constant_override("separation", 14)
	v.custom_minimum_size = Vector2(420, 0)
	center.add_child(v)
	var tail := Control.new()
	tail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.add_child(tail)
	var t := UIKit.label("TOMES OF CHAOS", 56, UIKit.GOLD)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(t)
	var st := UIKit.label("A wizard's tower. A pile of unwritten spells. Everyone else's spell books.", 16, UIKit.DIM)
	st.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	st.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(st)
	v.add_child(Control.new())
	var nh := HBoxContainer.new()
	nh.add_theme_constant_override("separation", 8)
	v.add_child(nh)
	name_edit = LineEdit.new()
	name_edit.placeholder_text = "Name your wizard"
	name_edit.text = NameGen.wizard()
	name_edit.max_length = 24
	name_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nh.add_child(name_edit)
	nh.add_child(UIKit.button("Reroll", func(): name_edit.text = NameGen.wizard(), Vector2(80, 0)))
	v.add_child(UIKit.button("New Game", _new_game, Vector2(0, 44)))
	var saves := Game.list_saves()
	var cont_text := "Continue"
	if not saves.is_empty():
		cont_text = "Continue: %s (level %d)" % [saves[0].name, saves[0].level]
	var cont := UIKit.button(cont_text, _continue, Vector2(0, 44))
	cont.disabled = saves.is_empty()
	v.add_child(cont)
	v.add_child(UIKit.button("Options", func(): main.show_options("title"), Vector2(0, 36)))
	if not OS.has_feature("web"):
		v.add_child(UIKit.button("Quit", func(): get_tree().quit(), Vector2(0, 36)))
	var credit := UIKit.label("Inspired by Julian Gollop's Chaos: The Battle of Wizards (1985)", 12, UIKit.DIM)
	credit.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(credit)

func _new_game() -> void:
	_start()   # saves are separate files now, so starting a new game never erases another

func _start() -> void:
	Game.new_game(name_edit.text.strip_edges())
	main.show_tower()

func _continue() -> void:
	if Game.load_game():
		main.show_tower()
