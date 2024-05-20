@tool
extends Node2D

class_name Hold

var offset : Offset
var tab : TabPanel
var save_offset := false


func has_offset():
	if offset.position != Vector2.ZERO:
		return true
	else:
		return false


func get_offset():
	return offset.position


func clear_offset():
	offset.position = Vector2.ZERO


func _ready():
	offset = $Offset
	
func clear(clear_off:= false):
	for ch in offset.get_children():
		ch.queue_free()
	var off_pos = offset.global_position
	if clear_off:
		clear_offset()
	rotation_degrees = 0
	scale = Vector2(1,1)
	offset.global_position = off_pos
#
#
func _draw():
		var col_line_rot_1 = Color.CORNFLOWER_BLUE
		var col_line_rot_2 = Color.CRIMSON
		if tab and tab.ctrl and tab.has_selected() and tab.sel_handles.size() > 1:
# TESTING
			#for ch in tab.hold.offset.get_children():
				#draw_circle(to_local(ch.global_position), 5 / tab.cont.scale.x ,Color.RED)
			#draw_circle(offset.position, 5 / tab.cont.scale.x ,Color.BLUE)
			
# PROD
			var line_col = col_line_rot_2 if tab.mouse_right else col_line_rot_1
			draw_line(Vector2.ZERO, tab.mouse_pos(self), line_col,  2 / tab.cont.scale.x)
			draw_circle(Vector2.ZERO, 5 / tab.cont.scale.x ,col_line_rot_2)
			draw_circle(Vector2.ZERO, 3 / tab.cont.scale.x,col_line_rot_1)
