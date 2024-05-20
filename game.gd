extends Node2D

@onready var line:Line2D = $Line2D
@onready var audio:AudioStreamPlayer2D = $AudioStreamPlayer2D
var TapSound = preload("res://tap.mp3")
var Dot = preload("res://dot.tscn")
var selected_dots = []
var dots = []
var colors_set = [Color.ORANGE, Color.YELLOW_GREEN, Color.LIGHT_CORAL]

# Called when the node enters the scene tree for the first time.
func _ready():
	audio.stream = TapSound
	init_level()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass
	
func init_level():
	# pallet
	var pallet = colors_set
	pallet = pallet+pallet
	pallet.shuffle()
	
	var rng = RandomNumberGenerator.new()
	var i = 0
	
	for p in line.points:
		print_debug(p)
		#p.x += 20-40*rng.randf()
		#p.y += 20-40*rng.randf()
		var d:Dot = Dot.instantiate()
		d.init(pallet[i])
		d.index = i
		d.position = p
		d.connect('click', _on_dot_click)
		add_child(d)
		dots.append(d)
		i += 1
	pass


func _on_dot_click(dot:Dot):
	if selected_dots.size() >= 2:
		return
	
	print('click')
	
	selected_dots.append(dot)
	audio.pitch_scale = 1+((selected_dots.size()-1)*0.1)
	audio.play()
	dot.reveal()
	
	
	
	if selected_dots.size() == 2:
		await get_tree().create_timer(0.75).timeout
		#check color
		if selected_dots[0].dot_color == selected_dots[1].dot_color:
			print('match!')
			selected_dots[0].disclose()
			selected_dots[1].disclose()
			audio.pitch_scale = 1.4
			audio.play()
		else:
			selected_dots[0].disclose()
			selected_dots[1].disclose()
		selected_dots.clear()
	
	if dots.size() == 0:
		init_level()
	
	pass # Replace with function body.
