extends Node2D
## A glowing tile-sized flash used for spell effects.
var col: Color = Color.WHITE
func _draw() -> void:
	var T := float(DB.TILE)
	draw_rect(Rect2(2, 2, T - 4, T - 4), Color(col.r, col.g, col.b, 0.45))
	draw_rect(Rect2(4, 4, T - 8, T - 8), Color(col.r, col.g, col.b, 0.35))
	draw_rect(Rect2(2, 2, T - 4, T - 4), Color(col.r, col.g, col.b, 1.0), false, 2.0)
