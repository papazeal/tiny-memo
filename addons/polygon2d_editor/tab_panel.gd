extends Panel

class_name TabPanel

const Handler = preload("res://addons/polygon2d_editor/handle.tscn")
@export var presets_list : VBoxContainer

var dock : PolyDock
var handles := []  # all handles
var handle : Handle
var last_sel_handle : Handle
var target : Polygon2D
var poly : Polygon2D
var canvas_cont : Canvas
var canvas_tab : Canvas
var cont : Control
var tool : Tool
var debug : Button
var debug_label : Label
var brush : Brush
var stretch := false
var stretched := false
var stretch_add_radius := 0
var stretch_fin_radius := 0
var stretch_point : Vector2
var stretch_size : HSlider
var poly_max_size 
var anim_player : AnimationPlayer
var anim_name : String
var anim : Animation
#var anim_players = []
var anim_pos := 0.0
var anim_playing := false
var anim_record := false

enum Type  { EDIT, MOVE, BONES, CONTROL} 
@export var type : Type

var focused : = false
var mouse_left : = false
var mouse_right : = false
var mouse_middle : = false
var shift : = false
var ctrl : = false
var alt : = false

var sel_handles := [] # all selected handles
var pre_sel_handles := [] # pre selected handles by rect
var remove_sel_handles := [] # all selected handles

var del_poly := []
var del := false

var rot_start : Vector2
var rot : = false
var hold : Hold # transform selected points node

var sel_start := Vector2(0,0)
var sel_end := Vector2(0,0)
var select = false
var sel_rect : PackedVector2Array
var sel_polygons : Array
var sel_polygon : PackedVector2Array

var dragging := false
var drag_old_pos : Vector2
var drag_added := false

var point : Vector2 # last added point

signal pause(value : bool)
var confirmed : bool

# USE INSIDE VARIABLES:
var _arr := []
var _arr2 := []
var value


func setup():
	if type != Type.CONTROL:
		dock = get_parent()
		tool = dock.tool
		poly = $Container/Polygon2D
		canvas_cont = $Container/Canvas
		canvas_tab = $TabCanvas
		cont = $Container
		hold = $Container/Canvas/Hold
		debug = $buttons/debug
		debug_label = $buttons/debug_label
		canvas_cont.tool = tool
		canvas_cont.tab = self
		canvas_tab.tool = tool
		canvas_tab.tab = self
		hold.tab = self
		stretch_size = $buttons/stretch_size
		if not mouse_entered.is_connected(_mouse_enter):
			mouse_entered.connect(_mouse_enter)
		if not mouse_exited.is_connected(_mouse_exit):
			mouse_exited.connect(_mouse_exit)
		if not debug.pressed.is_connected(_on_debug_pressed):
			debug.pressed.connect(_on_debug_pressed)
		if not dock.confirm.confirmed.is_connected(_on_confirm):
			dock.confirm.confirmed.connect(_on_confirm)
		if not dock.confirm.custom_action.is_connected(_on_cancel):
			dock.confirm.custom_action.connect(_on_cancel)
		if not $buttons/stretch.toggled.is_connected(_on_stretch_toggled):
			$buttons/stretch.toggled.connect(_on_stretch_toggled)
		if not stretch_size.value_changed.is_connected(_on_stretch_resize):
			stretch_size.value_changed.connect(_on_stretch_resize)
		$buttons.show()
#		#for ch in EditorInterface.get_edited_scene_root().get_children(true):
#			#if ch is AnimationPlayer:
#				#anim_players.append(ch)
	match type:
		Type.EDIT:
			confirm_to_remove_presets()
		Type.MOVE:
			pass
		Type.EDIT:
			pass
			
	
	
func anim_player_selected(a : AnimationPlayer):
	anim_player = a
	if anim_player.assigned_animation != '':
		anim = anim_player.get_animation(anim_player.assigned_animation)
	
	
func _process(delta):
	if anim_player:
		if anim_player.assigned_animation != '':
			if anim_player.assigned_animation != anim_name:
				anim_name = anim_player.assigned_animation
				anim = anim_player.get_animation(anim_name)
			if anim_pos != anim_player.current_animation_position:
				if not anim_record:
					if type == Type.MOVE:
#						if anim_playing:
						update_from_target()
					anim_playing = true
				else:
					if type == Type.MOVE:
# STOP HERE /// ADD RECORD BUTTON AND WRITE movement to animation
						pass
				anim_pos = anim_player.current_animation_position
			else:
				anim_playing = false
		
		
func update_from_target():
	update_target(true)
	var sel
	if has_selected():
		sel = get_handles_indexes(sel_handles)
	update_points()
	if sel:
		sel_handles = get_handles_by_indexes(sel)
	update_sel()
	

func _on_stretch_resize(value):
	if stretch and has_selected():
		set_stretch(sel_handles)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
				if event.is_pressed():
					if focused:
						mouse_left = true
						point = canvas_cont.to_local(event.global_position)
						delete()
						if ctrl:
							set_rot_pivot()
						else:
							#set_select(false)
							if not hold.save_offset:
								hold.clear_offset()
				else:
					mouse_left = false
					redraw()

		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.is_pressed():
				if focused:
					mouse_right = true
					set_rotate(true)
					set_select(true)
					delete(false)
			else:
				mouse_right = false
				set_rotate(false)
				set_select(false)
				redraw()
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.is_pressed():
				if focused:
					mouse_middle = true
					if is_mouse_in_selected() and not ctrl:
						drag_begin(event.global_position)
			else:
				mouse_middle = false
				drag_end()
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if focused:
				scale_select(true, event)
				update_sel()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if focused:
				scale_select(false, event)
				update_sel()
	if event is InputEventMouseMotion:
		if focused:
			if select:
				sel_end = mouse_pos()
				update_sel()
			if shift:
				redraw()
			if mouse_middle or drag_added:
				drag(event)
				update_sel()
			if alt:
				if mouse_left or mouse_right:
					delete(false)
				redraw()
			if ctrl:
				if rot:
					rotate_select()
				update_sel()


func redraw(redraw_handles:=false):
	if canvas_cont: canvas_cont.queue_redraw()
	if canvas_tab: canvas_tab.queue_redraw()
	if hold: hold.queue_redraw()
	if redraw_handles:
		for h in handles:
			if is_instance_valid(h):
				h.queue_redraw()


func set_hold(on : bool):
	if on:
		if ctrl:
			if has_selected() and sel_handles.size() > 1 and not shift and not dragging and not select:
				if not hold.has_offset():
					var center
					center = tool.centroid(tool.out_poly(sel_polygon))
					hold.position = canvas_cont.to_local(canvas_tab.to_global(center))
					hold.clear_offset()
				for i in sel_handles.size():
					var h = sel_handles[i] 
					var p = Node2D.new()
					hold.offset.add_child(p)
					p.set_meta('n', i)
					p.position = hold.offset.to_local(h.global_position)
	else:
		if hold:
			hold.clear()
	redraw()

#func _draw():
	#draw_circle(canvas_tab.to_local(hold.global_position), 10, Color.CRIMSON)

func set_rot_pivot():
	if ctrl and has_selected() and sel_handles.size() > 1: 
		var pos = canvas_cont.to_local(get_viewport().get_mouse_position())
		var off = hold.offset.global_position
		hold.position = pos
		hold.offset.global_position = off
		
		for ch in hold.offset.get_children():
			var h = sel_handles[ch.get_meta('n')]
			h.position = canvas_cont.to_local(ch.global_position)
			poly.polygon[h.index] = h.position
		update_sel()
	

func scale_select(up : bool, event : InputEventMouseButton):
	if ctrl:
		if up:
			hold.scale = hold.scale * (1 + event.factor / 100)
		else:
			hold.scale = hold.scale * (1 - event.factor / 100)
			
		for ch in hold.offset.get_children():
			var h = sel_handles[ch.get_meta('n')]
			h.position = canvas_cont.to_local(ch.global_position)
			poly.polygon[h.index] = h.position
		update_target()
		update_sel()

func set_rotate(on : bool):
	if on:
		if ctrl:
			rot = true
			#hold.clear()
			rot_start = mouse_pos()
			
	else:
		rot = false
		#hold.clear()

func rotate_select():
	if rot:
		var pos = canvas_tab.to_local(hold.global_position)
		var a = pos.direction_to(rot_start)
		var b = pos.direction_to(mouse_pos())
		var ang = rad_to_deg(a.angle_to(b))
		if ang < 0:
			ang = rad_to_deg(a.angle_to(b * -1)) + 180
		hold.rotation_degrees = ang
		
		debug.text = str(hold.rotation_degrees)
		for ch in hold.offset.get_children():
			var h = sel_handles[ch.get_meta('n')]
			if is_instance_valid(h):
				h.position = canvas_cont.to_local(ch.global_position)
				poly.polygon[h.index] = h.position
				
		update_target()
		update_sel()

func set_del(on: bool):
	if type == Type.EDIT:
		if on and focused:
			del = true
			if has_selected():
				for h in sel_handles:
					if is_instance_valid(h):
						h.set_state(1)
		else:
			del = false
			if has_selected():
				for h in sel_handles:
					if is_instance_valid(h):
						h.set_state(2)

func delete(fill := true):
	if del and type == Type.EDIT:
		if has_selected():
			if is_mouse_in_selected():
				var _p := Array(poly.polygon)
				var polys = poly.polygons
				var p := []
				for h in sel_handles:
					if is_instance_valid(h):
						p.append(_p[h.index])
				for _point in p:
					var i = _p.find(_point)
					if i != -1:
						_p.remove_at(i)
						for face_n in polys.size():
							for v_n in polys[face_n].size():
								var v = polys[face_n][v_n]
								if v == i:
									polys[face_n][v_n] = -1
								if v > i:
									polys[face_n][v_n] = v - 1
				polys = polys.filter(
					func(face):
						for v in face:
							if v == -1:
								return false
						return true
				)
				sel_handles = []
				poly.polygon = _p
				poly.uv = poly.polygon
				poly.polygons = polys
				if fill:
					tool.triangulate(poly)
					dock.remove_poly_presets()
		else:
			for n in poly.polygons.size():
				var p = poly.polygons[n]
				var tr = []
				for point_ in p:
					tr.append(poly.polygon[point_])
				if Geometry2D.is_point_in_polygon(mouse_pos(canvas_cont), tr):
					var new_polys = poly.polygons
					new_polys.remove_at(n)
					poly.polygons = new_polys
					break
		update_target()
		update_points()
		clear_selected()
		update_sel()
		

func set_select(on : bool):
	if not rot and not alt:
		if on:
			select = true
			sel_start = mouse_pos()
			sel_end = mouse_pos()
			pre_sel_handles = []
		else:
			select = false
			for h in pre_sel_handles:
				if is_instance_valid(h):
					add_selected(h)
			for h in remove_sel_handles:
				if is_instance_valid(h):
					remove_selected(h)
			pre_sel_handles = []
			remove_sel_handles = []
			update_sel()

func set_handle(h : Handle, _focused : bool):
	var state = h.state
	h.focused = _focused
	if not dragging:
	#	mouse enter handle
		if _focused:
			if select:
				pass
			else:
				if has_selected():
					if shift and mouse_left:
						if state == 0:
							add_selected(h)
						elif state == 2:
							remove_selected(h)
						update_sel()
				else:
					if state == 0:
						add_selected(h)
	#	mouse exit handle
		else:
			if select:
				pass
			else:
				if state == 2:
					if sel_handles.size() < 2:
						if not shift:
							remove_selected(h)
		update_sel()

func update_sel():
	var all_sel = []
	if select:
		var st = sel_start
		var en = sel_end
		sel_rect = PackedVector2Array([st,Vector2(st.x,en.y),en,Vector2(en.x,st.y)])
		
		for n in poly.polygon.size():
			var p = canvas_tab.to_local(canvas_cont.to_global(poly.polygon[n]))
			var h = handles[n]
			
			if Geometry2D.is_point_in_polygon(p, sel_rect):
				if sel_handles.has(h):
					if shift:
						remove_selected(h)
						remove_selected(h, true)
						remove_sel_handles.append(h)
				else:
					if pre_sel_handles.has(h):
						if shift:
							remove_selected(h)
							remove_selected(h, true)
							remove_sel_handles.append(h)
					else:
						if not shift:
							add_selected(h, true)
			else:
				if shift:
					var i = remove_sel_handles.find(h)
					if i != -1:
						remove_sel_handles.remove_at(i)
						add_selected(h, true)
				else:
					remove_selected(h, true)

	all_sel = sel_handles.duplicate()
	if has_selected(true):
		all_sel.append_array(pre_sel_handles)
	for h in remove_sel_handles:
		all_sel.erase(h)
	for h in handles:
		if is_instance_valid(h):
			h.set_state(0)
	for h in all_sel:
		if is_instance_valid(h):
			h.set_state(2)
	if has_selected() or has_selected(true):
		sel_polygons = []
		for p in poly.polygons:
			var arr = []
			for h in all_sel:
				if is_instance_valid(h):
					for i in p:
						if h.index == i:
							var point = canvas_tab.to_local(canvas_cont.to_global(h.position))
							arr.append(point)
			if arr.size() == 3:
				sel_polygons.append(arr)

		sel_polygon = []
		for h in all_sel:
			if is_instance_valid(h):
				var point = canvas_tab.to_local(canvas_cont.to_global(h.position))
				if not sel_polygon.has(point):
					sel_polygon.append(point)
	if alt:
		set_del(true)
		
	if stretch and has_selected():
		set_stretch(sel_handles, Vector2.ZERO)
	redraw()

func mouse_pos(node : Node2D = canvas_tab):
	if node and is_instance_valid(node) and get_viewport():
		return node.to_local(get_viewport().get_mouse_position())

func has_selected(pre := false):
	if pre:
		if not pre_sel_handles.is_empty():
			return true
		else:
			return false
	else:
		if not sel_handles.is_empty():
			return true
		else:
			return false

func is_mouse_in_selected():
	if has_selected():
		if sel_polygon.size() > 2:
			if Geometry2D.is_point_in_polygon(mouse_pos(), tool.out_poly(sel_polygon)):
				return true
		else:
			for h in sel_handles:
				if is_instance_valid(h):
					if h.focused:
						return true
	return false

func add_selected(h : Handle, pre := false, state := 2):
	if is_instance_valid(h):
		if pre:
			pre_sel_handles.append(h)
		else:
			sel_handles.append(h)
		h.set_state(state)

func remove_selected(h : Handle, pre := false, state := 0):
	if is_instance_valid(h):
		if pre:
			pre_sel_handles.erase(h)
		else:
			sel_handles.erase(h)
		h.set_state(state)

func remove_point(h : Handle):
	if is_instance_valid(h):
		pass

func drag(event : InputEvent):
	if dragging:
		if has_selected():
			var offset = (event.global_position - drag_old_pos) / $Container.scale
			hold.position += offset
			if not select:
				for h in sel_handles:
					if is_instance_valid(h):
						var old = poly.polygon[h.index]
						var vec = old + offset
						set_point(vec, h.index)
			if stretch:
				set_stretch(sel_handles, offset)
			drag_old_pos = event.global_position


func set_stretch(root_handles: Array, offset:= Vector2.ZERO):
	if stretch:
		var positions = tool.get_handles_pos(root_handles)
		var points = tool.get_distanced_points_pair(positions)
		if points:
			stretch_point = tool.centroid(tool.get_distanced_points_pair(positions).points)
			var diam = tool.get_points_max_dist(tool.get_handles_pos(root_handles))
			stretch_fin_radius = diam / 2 + (poly_max_size * stretch_size.value)
			for _h in handles:
				if _h.state == 0:
					if Geometry2D.is_point_in_circle(_h.position, stretch_point, stretch_fin_radius):
						var old = poly.polygon[_h.index]
						var p = (stretch_fin_radius / (stretch_fin_radius - _h.position.distance_to(stretch_point)))
						var vec = old + offset / p
						set_point(vec, _h.index)
			redraw()


func drag_begin(pos : Vector2):
	if has_selected():
		drag_old_pos = pos
		dragging = true

func drag_end():
#	if has_selected():
	dragging = false
	stretched = false
		

func set_point(point : Vector2, index : int):
	poly.polygon[index] = point
	handles[index].position = point
	if type == Type.EDIT:
		tool.triangulate(poly)
	update_target()

func _shortcut_input(event : InputEvent):
	if event.keycode == KEY_SHIFT:
		if event.is_pressed() and not alt:
			shift = true
			ctrl = false
			alt = false
		else:
			shift = false
			pre_sel_handles = []
			remove_sel_handles = []
		update_sel()
	elif event.keycode == KEY_CTRL:
		if event.is_pressed() and not shift:
			if focused:
				ctrl = true
				set_hold(true)
				shift = false
				alt = false
		else:
			ctrl = false
			set_hold(false)
			set_rotate(false)
	elif event.keycode == KEY_ALT:
		if event.is_pressed() and not select and not shift:
			alt = true
			ctrl = false
			shift = false
			set_del(true)
		else:
			alt = false
			set_del(false)
	redraw()

func update_points():
	for handler in handles:
		handler.queue_free()
	handles.clear()
	var min_vec: Vector2
	var max_vec: Vector2
	var init = false
	var index = 0
	for vec in poly.polygon:
		if not init:
			min_vec = vec
			max_vec = vec
			init = true
		else:
			if vec.x < min_vec.x:
				min_vec.x = vec.x
			if vec.y < min_vec.y:
				min_vec.y = vec.y
			if vec.x > max_vec.x:
				max_vec.x = vec.x
			if vec.y > max_vec.y:
				max_vec.y = vec.y
		var handle = Handler.instantiate()
		handle.position = vec
		handle.tab = self
		canvas_cont.add_child(handle)
		handles.push_back(handle)
		handle.index = index
		index += 1
		handle.z_index = 1
		
		if handle.position == mouse_pos(poly):
			self.handle = handle

	redraw()

func clear_selected(clear_state := true):
	if clear_state:
		for h in sel_handles:
			if is_instance_valid(h):
				h.set_state(0)
	sel_handles = []
	sel_polygon = []
	sel_polygons = []
	if not hold.save_offset:
		hold.clear_offset()
	redraw()

func update_target(from_target := false):
	if poly and target:
		var to = poly if from_target else target
		var from = target if from_target else poly
		match type:
			Type.EDIT:
				to.uv = from.polygon
				to.polygon = from.polygon
				to.polygons = from.polygons
				to.internal_vertex_count = from.internal_vertex_count
			Type.MOVE:
				to.polygon = from.polygon
				pass
		redraw()


func add_point_to_poly(point: Vector2, poly: Polygon2D, global := true):
	var arr = poly.polygon
	arr.append(point)
	if global:
		poly.polygon = arr
		tool.triangulate(poly)
	else:
		var inside_tr = tool.get_poly_triangle_in_point(point, poly)



func clear_poly():
	poly.polygon = PackedVector2Array([])
	poly.uv = PackedVector2Array([])
	poly.polygons = []
	poly.internal_vertex_count = 0
	update_points()
	update_target()
	sel_handles = []

func reset_poly():
	poly.uv = target.uv
	poly.polygon = target.uv
	poly.polygons = target.polygons
	update_points()
	update_target()

func _mouse_enter():
	focused = true

func _mouse_exit():
	focused = false
	

func get_handles_indexes(_handles : Array):
	var indexes = []
	for h in _handles:
		if is_instance_valid(h):
			indexes.append(h.index)
	return indexes

func get_handles_by_indexes(indexes : Array):
	var h = []
	for i in indexes:
		h.append(handles[i])
	return h

func get_handles_pos(_handles : Array):
	var pos := PackedVector2Array([])
	for h in _handles:
		pos.append(h.position)
	return pos


func _on_stretch_toggled(toggled_on):
	poly_max_size = tool.get_points_max_dist(get_handles_pos(handles))
	stretch = toggled_on
	if toggled_on:
		stretch_size.show()
	else:
		stretch_size.hide()
	update_sel()

#////////////// START CONFIRMATION LOGIC ////////////////////

# waiting to confirm logic
func confirm_to_remove_presets():
	confirmed = true
	if dock.presets_list:
		if dock.presets_list.get_children().size() > 0:
			dock.confirm.open(1)
			await pause
			if confirmed:
				dock.remove_poly_presets()
			else:
				dock.current_tab = 0
				dock.update_tab()
			return confirmed
		else:
			return confirmed

func _on_confirm():
	match dock.confirm.state:
		1:
			confirmed = true
			pause.emit(true)

func _on_cancel(action):
	match dock.confirm.state:
		1:
			confirmed = false
			pause.emit(false)

# ////////// END CONFIRMATION LOGIC //////////////

func _on_debug_pressed():
	if anim_player:
		print(anim_player.current_animation, 'H')
	


			
