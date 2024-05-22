extends Node2D

@onready var audio:AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var p1:Mob = $p1
@onready var p2:Mob = $p2
var current_player:Mob = null

var TapSound = preload("res://tap.mp3")
var Dot = preload("res://dot.tscn")
var selected_dots = []
var dots = []
var colors_set = [Color.ORANGE, Color.YELLOW_GREEN, Color.LIGHT_CORAL, Color.DARK_TURQUOISE]
var line:Line2D = Line2D.new()
var level = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	audio.stream = TapSound
	
	line.width = 5
	line.default_color = Color(255,255,255,0.5)
	add_child(line)
	
	#generate_line()
	init_level()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#input
	if Input.is_action_just_pressed("action"):
		pass
	
	for d in dots:
		if d.position != d.next_position:
			d.position.x = move_toward(d.position.x, d.next_position.x, 300*delta)
			d.position.y = move_toward(d.position.y, d.next_position.y, 300*delta)
			
	pass


func clear_level():
	for d in dots:
		d.queue_free()
	dots.clear()
	pass	

func init_level():
	
	var points = []
	var row = 4
	var col = 4
	var grid_size = 75
	var pading_x = (get_viewport_rect().size.x - grid_size*(col-1))/2
	var padding_y = grid_size
	for x in col:
		for y in row:
			points.append(Vector2(pading_x+x*grid_size,padding_y+y*grid_size))
	
	# pallet
	var pallet = []
	pallet.assign(colors_set)
	pallet = pallet+pallet
	pallet.shuffle()
	print('pallet',pallet)
	pallet.resize(points.size()/2)
	
	pallet = pallet+pallet
	pallet.shuffle()
	
	var i = 0
	for p in points:
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
		
	# set player
	switch_player()
	
	pass

func switch_player():
	if current_player == null:
		current_player = p1
	
	if current_player == p1:
		current_player = p2
		p1.set_deactive()
		p2.set_active()
	else:
		current_player = p1
		p1.set_active()
		p2.set_deactive()
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
			switch_player()
			
		selected_dots.clear()
	
		# check active dots
		var all_dots_inactive = true
		for d in dots:
			if d.is_active:
				all_dots_inactive = false
		if all_dots_inactive:
			await get_tree().create_timer(1.50).timeout
			clear_level()
			init_level()
	
	pass # Replace with function body.
