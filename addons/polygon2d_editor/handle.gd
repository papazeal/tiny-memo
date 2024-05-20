@tool
extends Control

class_name Handle

var index

var tab : TabPanel

var state = 0
var focused = false
var stretch_col : Color


func _ready():
	$GUI.mouse_entered.connect(_on_mouse_entered)
	$GUI.mouse_exited.connect(_on_mouse_exited)
	stretch_col = Color.BLUE
	stretch_col.a = .2


func _draw():
	if tab:
		var factor = tab.cont.scale.x
		var out = 3 / factor
		var ins = 1 / factor
		$GUI.scale = Vector2(1 / factor, 1 / factor)
		match state:
			0:
			#	normal color
				draw_circle(pivot_offset, out, Color.CORNFLOWER_BLUE)
				draw_circle(pivot_offset, ins, Color.WHITE)
			1:
				draw_circle(pivot_offset, out, Color.CRIMSON)
				draw_circle(pivot_offset, ins, Color.WHITE)
			2:
				draw_circle(pivot_offset, out, Color.CORAL)
				draw_circle(pivot_offset, ins, Color.WHITE)
				


func set_state(n : int):
	state = n
	queue_redraw()


func _on_mouse_entered():
	tab.handle = self
	tab.last_sel_handle = self
	tab.focused = true
	tab.set_handle(self, true)


func _on_mouse_exited():
	tab.handle = null
	tab.focused = true
	tab.set_handle(self, false)




