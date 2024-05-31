extends Node2D
class_name ScoreBar
@onready var bg = $bg
var max_score:float = 100
var score:float = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_length(px:int):
	bg.points[1] = Vector2(px,0)
	pass

func set_max_score(val:float):
	max_score = val
	pass

func add_score(val:int,col:Color=Color.BLUE_VIOLET):
	score += val
	var line:Line2D = Line2D.new()
	line.width = 10
	line.modulate = col
	#line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.add_point(Vector2(0,0))
	line.z_index = 1000 - score
	line.z_as_relative = true
	print((score/max_score)*300)
	line.add_point(Vector2((score/max_score)*bg.points[1].x,0))
	bg.add_child(line)
	pass

func clear_score():
	score = 0
	pass
