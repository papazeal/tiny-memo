extends Node2D
class_name HpBar

var padding = 24
var dots = []
var Dot = preload("res://dot.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	for i in 10:
		#var dot:Sprite2D = Sprite2D.new()
		#dot.texture = texture
		#dot.scale = Vector2(0.1,0.1)
		#dot.position = Vector2(i*padding, 0)
		var d:Dot = Dot.instantiate()
		d.position = Vector2(i*padding, 0)
		#d.scale = Vector2(0.1,0.1)
		dots.append(d)
		add_child(d)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func set_hp(hp:int):
	
	for i in dots.size():
		if i<hp:
			dots[i].modulate = Color.ORANGE_RED
			#dots[i].modulate = Color('#d94a69')
		else:
			dots[i].modulate = Color(0,0,0,0)
	pass
