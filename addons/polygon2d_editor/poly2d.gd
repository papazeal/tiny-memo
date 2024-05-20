@tool
extends Polygon2D

# Poly class
# can add handlers to animate polygon points

class_name Poly

@export var update_points = false: set = upd_points


func upd_points(value : bool):
	if value:
		var point = Marker2D.new()
		for n in polygon.size():
			var p = polygon[n]
			add_child(point)
			point.position = p
			point.name = '_' + str(n)

