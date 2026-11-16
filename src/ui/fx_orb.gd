extends Node2D
## A projectile orb.
var col: Color = Color.WHITE
func _draw() -> void:
	draw_circle(Vector2.ZERO, 12, Color(col.r, col.g, col.b, 0.35))
	draw_circle(Vector2.ZERO, 8, Color(col.r, col.g, col.b, 0.8))
	draw_circle(Vector2.ZERO, 4, Color.WHITE)
