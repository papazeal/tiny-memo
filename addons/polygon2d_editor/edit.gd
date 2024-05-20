@tool
extends TabPanel


# generation:
var density := 10
var scatter = 100

var icon : Sprite2D

	
func set_panel(target : Polygon2D):
	setup()
	if not gui_input.is_connected(_on_gui_input):
		gui_input.connect(_on_gui_input)
	self.target = target
	icon = $Container/UV
	icon.centered = false
	icon.texture = target.texture
	icon.rotation = target.texture_rotation
	icon.offset = target.texture_offset
	icon.scale = target.texture_scale
	
	poly.uv = target.uv
	poly.polygon = target.uv
	poly.polygons = target.polygons
	poly.internal_vertex_count = target.internal_vertex_count
	update_points()



func subdivide():
	if poly.polygon.is_empty():
		pass
	else:
		var polygon = Array(poly.polygon)
		# FIX split outter polygon before inner
		# split inner polygon 
		for tr in poly.polygons:
			var a = poly.polygon[tr[0]]
			var b = poly.polygon[tr[1]]
			var c = poly.polygon[tr[2]]
			var center = tool.centroid([a,b,c])
			polygon.append(center)
		poly.polygon = polygon
		poly.uv = poly.polygon
		tool.triangulate(poly)
		update_target()
		update_points()


func _on_gui_input(event):
	if target:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.is_pressed():
					if sel_handles.is_empty():
						if not alt and not shift:
							add_point_to_poly(point, poly)
							update_target()
							update_points()
								# drag when added
							
# FIX drag when added
							if ctrl and handle:
								#if last_sel_handle.position == mouse_pos(poly):
								drag_added = true
								add_selected(handle)
								drag_begin(event.global_position)
					else:
						if not ctrl and not shift:
							clear_selected()
								
					pass
				else:
					if drag_added:
						drag_added = false
						drag_end()
						clear_selected()
					
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				if event.is_pressed():
					pass
				else:
					pass
		if event is InputEventMouseMotion:
			pass


func _on_save_pivot_toggled(toggled_on):
	hold.save_offset = toggled_on



# RESERVE COPIES: ::::::::::::::::::::::::::::::::::::::::::::::::::::
# ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::




