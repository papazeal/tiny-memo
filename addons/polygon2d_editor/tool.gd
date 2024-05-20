@tool
extends Node

class_name Tool

	
	
func get_poly_rect(poly: Polygon2D):
	var start : Vector2
	var end : Vector2
	var size : Vector2
	for p in poly.polygon:
		if start:
			if start.x > p.x:
				start.x = p.x
			if start.y > p.y:
				start.y = p.y
		else:
			start = p
		if end:
			if end.x < p.x:
				end.x = p.x
			if end.y < p.y:
				end.y = p.y
		else:
			end = p
	size = end - start
	return Rect2(start, size)
	
	
func centroid(points : PackedVector2Array):
	if points.size() > 1:
		var center : Vector2
		var x_sum = 0
		var y_sum = 0
		for p in points:
			x_sum += p.x
			y_sum += p.y
		center.x = x_sum / points.size()
		center.y = y_sum / points.size()
		
		return center
		
func get_points_max_dist(points : PackedVector2Array):
	var max = 0
	for p in points:
		for _p in points:
			var dist = p.distance_to(_p)
			if dist > max:
				max = dist
	return max
	
func average_points_dist(points : PackedVector2Array):
	pass
	
func get_distanced_points_pair(points : PackedVector2Array, closest := false):
	var rem = {'indexes': [], 'points': [], 'dist' : 0}
	for n in points.size():
		var p = points[n]
		for _n in points.size():
			var _p = points[_n]
			var dist = p.distance_to(_p)
			if rem.points.is_empty():
				rem.points.append(p)
				rem.points.append(_p)
				rem.indexes.append(n)
				rem.indexes.append(_n)
				rem.dist = dist
			else:
				if closest:
					if dist < rem.points[0].distance_to(rem.points[1]):
						rem.points[0] = p
						rem.points[1] = _p
						rem.indexes[0] = n
						rem.indexes[1] = _n
						rem.dist = dist
				else:
					if dist > rem.points[0].distance_to(rem.points[1]):
						rem.points[0] = p
						rem.points[1] = _p
						rem.indexes[0] = n
						rem.indexes[1] = _n
						rem.dist = dist
	return rem
	
	
func get_handles_pos(handles: Array):
	var arr = []
	for h in handles:
		if is_instance_valid(h):
			arr.append(h.position)
	return arr
	
	
func between_point(a:Vector2, b:Vector2):
	var pos : Vector2
	pos.x = a.x + .5 * (b.x - a.x)
	pos.y = a.y + .5 * (b.y - a.y)
	return pos
	
	

func clean_polygon(poly: Polygon2D):
	#_clean_polygon_from_dups(poly)
	var polygon = Geometry2D.merge_polygons(poly.polygon, PackedVector2Array([]))
	poly.polygon = polygon
			
			
			
func clean_polygon_from_dups(poly :PackedVector2Array):
	for n in poly.size():
		var p = poly[n]
		var i = poly.find(p, n + 1)
		if i != -1:
			poly.remove_at(i)
			clean_polygon_from_dups(poly)
			break
	
func triangulate(poly : Polygon2D, dup:= false):
	if dup:
		poly = poly.duplicate()
	poly.polygons = []
	var points = Geometry2D.triangulate_delaunay(poly.polygon)
	for point in range(0, points.size(), 3):
		var triangle = []
		triangle.push_back(points[point])
		triangle.push_back(points[point + 1])
		triangle.push_back(points[point + 2])
		poly.polygons.push_back(triangle)
		
	update_internal(poly)
	return poly
	


func get_poly_triangle_in_point(point : Vector2, poly : Polygon2D):
	var inside_tr
	for face_n in poly.polygons.size():
		var face = poly.polygons[face_n]
		var tr = []
		for v in face:
			tr.append(poly.polygon[v])
		if Geometry2D.is_point_in_polygon(point, tr):
			inside_tr = face_n
			break
	return inside_tr
	

func update_internal(poly : Polygon2D):
	var convex := Geometry2D.convex_hull(poly.polygon)
	convex.remove_at(convex.size() - 1)
	poly.internal_vertex_count = 0
	for p in poly.polygon:
		var st = 0.001
		if Geometry2D.is_point_in_polygon(p + Vector2(st, 0), convex) and \
		Geometry2D.is_point_in_polygon(p + Vector2(-st, 0), convex) and \
		Geometry2D.is_point_in_polygon(p + Vector2(0, st), convex) and \
		Geometry2D.is_point_in_polygon(p + Vector2(0, -st), convex):
			poly.internal_vertex_count += 1
			
			
func out_poly(polygon : PackedVector2Array):
	var convex = polygon
	if polygon.size() > 2:
		convex = Geometry2D.convex_hull(polygon)
		convex.remove_at(convex.size() - 1)
	return convex

func remove_from_polygons(indexes : Array, arr : Array):
	pass

func remove_duplicates_in_array(arr : Array):
	var dup
	for _n in arr.size():
		var _i = arr.find(arr[_n], _n + 1)
		if _i != -1:
			dup = _i
			break
	if dup:
		arr.remove_at(dup)
		remove_duplicates_in_array(arr)
	else:
		return













# RESERVE COPIES :::::::::::::::::::::::::
# ::::::::::::::::::::::::::::::::::::::::
# ::::::::::::::::::::::::::::::::::::::::
# ::::::::::::::::::::::::::::::::::::::::

func triangulate_poly(polygon2d : Polygon2D) -> void:
	if polygon2d.polygon.size() < 3:
		# Can't triangulate without a triangle...
		return

	polygon2d.polygons = []
	var points = Geometry2D.triangulate_delaunay(polygon2d.polygon)
	# Outer verticies are stored at the beginning of the PackedVector2Array
	var outer_polygon = polygon2d.polygon.slice(0, polygon2d.polygon.size() - polygon2d.internal_vertex_count)
	for point in range(0, points.size(), 3):
		var triangle = []
		triangle.push_back(points[point])
		triangle.push_back(points[point + 1])
		triangle.push_back(points[point + 2])
		
		# only add the triangle if all points are inside the polygon
		var a : Vector2 = polygon2d.polygon[points[point]]
		var b : Vector2 = polygon2d.polygon[points[point + 1]]
		var c : Vector2 = polygon2d.polygon[points[point + 2]]
		
		if _points_are_inside_polygon(a, b, c, outer_polygon):
			polygon2d.polygons.push_back(triangle)


func _points_are_inside_polygon(a: Vector2, b: Vector2, c: Vector2, polygon: PackedVector2Array) -> bool:
	var center = (a + b + c) / 3
	# move points inside the triangle so we don't check for intersection with polygon edge
	a = a - (a - center).normalized() * 0.01
	b = b - (b - center).normalized() * 0.01
	c = c - (c - center).normalized() * 0.01
	
	return Geometry2D.is_point_in_polygon(a, polygon) \
		and Geometry2D.is_point_in_polygon(b, polygon) \
		and Geometry2D.is_point_in_polygon(c, polygon)
