extends SceneTree
## godot --headless --path . --script tools/contact_sheet.gd -- out.png
func _init() -> void:
	DB.init()
	var archs := ["humanoid","brute","beast","bird","bat","snake","spider","blob","skeleton","ghost","dragon","plant","insect","golem","elemental","eye","fish","crab","imp","worm","tree","wizard","wizard_player"]
	var cols := [Color("60a040"), Color("c04040"), Color("5080d0"), Color("d0b050")]
	var S := 64
	var sheet := Image.create(S * 24, S * (4 + 3 + 3), false, Image.FORMAT_RGBA8)
	sheet.fill(Color("3a3a44"))
	for r in range(cols.size()):
		for i in range(archs.size()):
			var img := Art.unit_image(archs[i], cols[r])
			img.resize(S, S, Image.INTERPOLATE_NEAREST)
			sheet.blit_rect(img, Rect2i(0, 0, S, S), Vector2i(i * S, r * S))
	# objects
	var ids := DB.objs.keys()
	for i in range(ids.size()):
		var o: Dictionary = DB.objs[ids[i]]
		var img := Art.object_image(o.sym, o.col)
		img.resize(S, S, Image.INTERPOLATE_NEAREST)
		sheet.blit_rect(img, Rect2i(0, 0, S, S), Vector2i((i % 24) * S, (4 + i / 24) * S))
	# tiles
	var pal := ["3a3a48", "46465a", "5a5a6a", "8a6aaa"]
	var tids := DB.TERRAIN.keys()
	for i in range(tids.size()):
		var img := Art.tile_image(tids[i], i, pal)
		img.resize(S, S, Image.INTERPOLATE_NEAREST)
		sheet.blit_rect(img, Rect2i(0, 0, S, S), Vector2i((i % 24) * S, (7 + i / 24) * S))
	var out := "/tmp/claude-0/-home-claude/bb62c9a6-73fb-5655-92ed-15bafdfde485/scratchpad/sheet.png"
	sheet.save_png(out)
	print("saved ", out)
	quit()
