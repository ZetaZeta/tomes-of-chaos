class_name Screen
extends Control
## Base class for full-screen views managed by Main.
var main: Control

func setup(m: Control) -> void:
	main = m
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

## Full-screen generated backdrop (assets/ui/bg_<name>.jpg), darkened so the UI on top stays readable.
## Only used with the generated art style.
func backdrop(bg_name: String, dim: float = 0.5) -> void:
	if not Art.use_generated:
		return
	var path := "res://assets/ui/bg_%s.jpg" % bg_name
	if not ResourceLoader.exists(path):
		return
	var tr := TextureRect.new()
	tr.texture = load(path)
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	tr.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var shade := ColorRect.new()
	shade.color = Color(0.03, 0.03, 0.06, dim)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Put the backdrop on Main's full-window layer so it also fills any space around the 1280x720 stage.
	var layer: Control = main.wide_bg if main != null and main.get("wide_bg") != null else null
	if layer != null:
		for c in layer.get_children():
			c.queue_free()
		layer.add_child(tr)
		layer.add_child(shade)
	else:
		add_child(tr)
		move_child(tr, 0)
		add_child(shade)
		move_child(shade, 1)
