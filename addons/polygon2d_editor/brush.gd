@tool
extends Node2D

class_name Brush

var radius := 30.0
var on := false

@export var tab : TabPanel 
var circ_col = Color.BLUE


func _draw():
	if tab and tab.brush and tab.brush.on:
		circ_col.a = .4
		draw_circle(position, radius, circ_col)


func _process(delta):
	if tab and tab.brush.on:
		position = tab.mouse_pos(self)
	queue_redraw()
