extends Node2D

@onready var audio:AudioStreamPlayer2D = $AudioStreamPlayer2D
var TapSound = preload("res://tap.mp3")
var Dot = preload("res://dot.tscn")
var selected_dots = []
var dots = []
var colors_set = [Color.ORANGE, Color.YELLOW_GREEN, Color.LIGHT_CORAL, Color.MEDIUM_TURQUOISE]
var line:Line2D = Line2D.new()
var level = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	audio.stream = TapSound
	
	
	line.width = 5
	line.default_color = Color(255,255,255,0.5)
	add_child(line)
	
	generate_line()
	init_level()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#input
	if Input.is_action_just_pressed("action"):
		generate_line()
	
	for d in dots:
		if d.position != d.next_position:
			d.position.x = move_toward(d.position.x, d.next_position.x, 300*delta)
			d.position.y = move_toward(d.position.y, d.next_position.y, 300*delta)
			
	pass

func generate_line(point_count:int=2):
	if point_count > 6:
		point_count = 6
	line.clear_points()
	var gird_size = 20
	var line_points = []
	var rng = RandomNumberGenerator.new()
	
		
	for i in point_count:
		var good_point = false
		var distance = 59
		var point = Vector2()
		while !good_point:
			point = Vector2(rng.randi_range(5,15) * gird_size, rng.randi_range(5,25) * gird_size)
			# first point
			if line_points.size() == 0:
				good_point = true
			
			good_point = true
			for p in line_points:
				if point.distance_to(p) < 100:
					good_point = false
			
		line_points.append(point)
	
	#draw line
	#var line:Line2D = Line2D.new()
	for point in line_points:
		line.add_point(point)
	#add_child(line)
	pass

func clear_level():
	for d in dots:
		d.queue_free()
	dots.clear()
	pass	

func init_level():
	var rng = RandomNumberGenerator.new()
	
	# pallet
	var pallet = []
	pallet.assign(colors_set)
	pallet.shuffle()
	print('pallet',pallet)
	pallet.resize(line.points.size()/2)
	
	pallet = pallet+pallet
	pallet.shuffle()
	
	var i = 0
	for p in line.points:
		print_debug(p)
		#p.x += 20-40*rng.randf()
		#p.y += 20-40*rng.randf()
		var d:Dot = Dot.instantiate()
		d.init(pallet[i])
		d.index = i
		d.position = p
		d.next_position = p
		d.connect('click', _on_dot_click)
		add_child(d)
		dots.append(d)
		i += 1
	pass

func rotate_dots():
	for i in dots.size():
		dots[i-1].next_position = dots[i%dots.size()].position
	pass

func _on_dot_click(dot:Dot):
	print('click')
	
	# select dot must not more than 2
	if selected_dots.size() >= 2:
		return
	
	# check duplicate
	if selected_dots.size() == 1:
		if selected_dots[0] == dot:
			return
	
	selected_dots.append(dot)
	dot.sfx_tap(1+((selected_dots.size()-1)*0.1))
	#audio.pitch_scale = 1+((selected_dots.size()-1)*0.1)
	#audio.play()
	dot.reveal()
	
	if selected_dots.size() == 2:
		await get_tree().create_timer(0.75).timeout
		#check color
		if selected_dots[0].dot_color == selected_dots[1].dot_color:
			print('match!')
			selected_dots[0].disclose()
			selected_dots[1].disclose()
			selected_dots[0].deactivate()
			selected_dots[1].deactivate()
			audio.pitch_scale = 1.4
			audio.play()
			#rotate_dots()
		else:
			selected_dots[0].disclose()
			selected_dots[1].disclose()
			
		selected_dots.clear()
	
		# check active dots
		var all_dots_inactive = true
		for d in dots:
			if d.is_active:
				all_dots_inactive = false
		if all_dots_inactive:
			await get_tree().create_timer(1.50).timeout
			clear_level()
			level += 1
			generate_line(level*2)
			init_level()
	
	pass # Replace with function body.
