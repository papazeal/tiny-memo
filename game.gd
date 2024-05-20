extends Node2D

@onready var line:Line2D = $Line2D
var Dot = preload("res://dot.tscn")
var selected_dots = []
var dots = []
var colors_set = [Color.ORANGE, Color.YELLOW_GREEN]

# Called when the node enters the scene tree for the first time.
func _ready():
	init_level()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass
	
func init_level():
	var colors_set = colors_set + colors_set
	colors_set.shuffle()
	var i = 0
	for p in line.points:
		print_debug(p)
		var d:Dot = Dot.instantiate()
		d.init(colors_set[i])
		d.index = i
		d.position = p
		d.connect('click', _on_dot_click)
		add_child(d)
		dots.append(d)
		i += 1
	pass


func _on_dot_click(dot:Dot):
	if selected_dots.size() < 2:
		print('click')
		selected_dots.append(dot)
		dot.reveal()
	
	await get_tree().create_timer(1.0).timeout
	
	if selected_dots.size() == 2:
		#check color
		if selected_dots[0].dot_color == selected_dots[1].dot_color:
			print('match!')
			#selected_dots[0].queue_free()
			#selected_dots[1].queue_free()
			selected_dots[0].disclose()
			selected_dots[1].disclose()
		else:
			selected_dots[0].disclose()
			selected_dots[1].disclose()
		selected_dots.clear()
	
	if dots.size() == 0:
		init_level()
	
	pass # Replace with function body.
