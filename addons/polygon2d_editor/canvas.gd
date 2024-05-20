@tool
extends Node2D

class_name Canvas

var tool : Tool
var tab : TabPanel


func _draw():
	if tab:
		var poly = tab.poly
		var col_rect_sel = Color.BROWN
		var col_rect_rem = Color.CORNFLOWER_BLUE
		var col_rect = col_rect_rem if tab.shift else col_rect_sel
		col_rect.a = .3
		var col_sel_poly = Color.CORAL
		var col_sel_poly_2 = Color.TOMATO
		var col_sel_poly_3 = Color.CORAL
		var col_del = Color.CRIMSON
		var col_str_circ = Color.BLUE
		var col_str_circ_outline = Color.BLUE
		col_str_circ.a = .03
		col_str_circ_outline.a = .3
		col_del.a = .5
		col_sel_poly.a = .5
		col_sel_poly_2.a = .5
		col_sel_poly_3.a = .2
		
		
	#	CONT CANVAS
		if get_parent() == tab.cont:
			if poly:
				var polygon: PackedVector2Array = poly.polygon
				var polygons: Array = poly.polygons
				
				if tab.stretch and tab.has_selected():
					var r = tab.stretch_fin_radius
					var n = 30
					var w = 3 / tab.cont.scale.x
					draw_arc(tab.stretch_point, r, 0, 360, 50, col_str_circ_outline, w)
					for i in range(n):
						var _r = r / n * i
						draw_circle(tab.stretch_point, _r, col_str_circ)
						
				for face in polygons:
					if not polygon.is_empty():
						var points = PackedVector2Array()
						var colors = PackedColorArray()
						var color = Color.CORNFLOWER_BLUE
						color.a = 0.2
						for i in face:
							points.append(polygon[i])
							colors.append(color)
						
						draw_polygon(points, colors)
						points.append(polygon[face[0]])
						points.append(polygon[face[0]])
						draw_polyline(points, Color.CORNFLOWER_BLUE, 1 / tab.cont.scale.x)
				
			
			if tab.del and tab.type == tab.Type.EDIT:
				var out = tool.out_poly(tab.sel_polygon)
				if out.size() > 2:
					if Geometry2D.is_point_in_polygon(tab.mouse_pos(), out):
						var p = []
						for _p in out:
							var loc = to_local(tab.get_node('pos').to_global(_p))
							p.append(loc)
						
						draw_colored_polygon(p, col_del)
				else:
					if not tab.has_selected():
						for n in poly.polygons.size():
							var p = poly.polygons[n]
							var tr = []
							for point_ in p:
								tr.append(poly.polygon[point_])
							if tr.size() == 3:
								if Geometry2D.is_point_in_polygon(tab.mouse_pos(self), tr):
									draw_colored_polygon(tr, col_del)
						#if tab.mouse_left or tab.mouse_right:
				draw_circle(tab.mouse_pos(self), 10 / tab.cont.scale.x, col_del)
			
		
	#	TAB CANVAS
		elif get_parent() == tab:
			if tab.select:
				draw_colored_polygon(tab.sel_rect ,col_rect)

			if tab.has_selected() or tab.has_selected(true):
				var c = col_sel_poly_2 if tab.ctrl else col_sel_poly
				if tab.sel_polygon.size() > 2:
					draw_colored_polygon(tool.out_poly(tab.sel_polygon), col_sel_poly_3)
				for p in tab.sel_polygons:
					if p.size() == 3:
						draw_colored_polygon(p, c)

			if tab.shift and tab.mouse_left and not tab.mouse_right:
				draw_circle(tab.mouse_pos(), 20, col_rect)
			#if tab.rot:

				
		


		
		
