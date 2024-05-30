extends Node2D

@onready var audio:AudioStreamPlayer2D = $AudioStreamPlayer2D
var current_player:Mob = null

#var TapSound = preload("res://tap.mp3")
var TapSound = preload("res://drop_002.ogg")
var Dot = preload("res://dot.tscn")
var selected_dots = []
var dots = []
var colors_set = [Color.ORANGE, Color.YELLOW_GREEN, Color.LIGHT_CORAL, Color.DARK_TURQUOISE, Color.MEDIUM_SLATE_BLUE]

var line:Line2D = Line2D.new()
var level = 1
var rng = RandomNumberGenerator.new()
var hp = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	audio.stream = TapSound
	#colors_set = colors_set+colors_set
	
	#generate_line()
	init_level()
	await get_tree().create_timer(1.0).timeout
	next_level()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#input
	if Input.is_action_just_pressed("action"):
		expand()
		pass
	
	#for d in dots:
		#if d.position != d.next_position:
			#d.position.x = move_toward(d.position.x, d.next_position.x, 300*delta)
			#d.position.y = move_toward(d.position.y, d.next_position.y, 300*delta)
			
	pass

func expand():
	for d in dots:
		var tween = get_tree().create_tween()
		tween.tween_property(d, "position", d.expand_pos, 0.5).set_ease(Tween.EASE_OUT)
	pass

func clear_level():
	for d in dots:
		d.deactivate()
	pass	

func init_level():
	
	var points = []
	var compact_points = []
	var row = 6
	var col = 4
	var grid_size = 75
	
	var pading_x = (get_viewport_rect().size.x - grid_size*(col-1))/2
	var padding_y = (get_viewport_rect().size.y - grid_size*(row-1))/2
	for x in col:
		for y in row:
			points.append(Vector2(pading_x+x*grid_size,padding_y+y*grid_size))
	
	var compact_grid_size = 20
	var compact_pading_x = (get_viewport_rect().size.x - compact_grid_size*(col-1))/2
	var compact_padding_y = (get_viewport_rect().size.y - compact_grid_size*(row-1))/2
	for x in col:
		for y in row:
			compact_points.append(Vector2(compact_pading_x+x*compact_grid_size,compact_padding_y+y*compact_grid_size))
	
	var i = 0
	for p in points:
		print_debug(p)
		#p.x += 20-40*rng.randf()
		#p.y += 20-40*rng.randf()
		var d:Dot = Dot.instantiate()
		#d.init(pallet[i])
		d.index = i
		
		d.expand_pos = p
		d.compact_pos = compact_points[i]
		d.position = p
		d.next_position = p
		d.connect('click', _on_dot_click)
		add_child(d)
		dots.append(d)
		i += 1
	pass

func next_level(lv=null):
	if lv:
		level = lv
	hp = 3
	dots.shuffle()
	colors_set.shuffle()
	for i in level:
		dots[i*2].set_color(colors_set[i])
		dots[i*2+1].set_color(colors_set[i])
		dots[i*2].activate()
		dots[i*2+1].activate()
	level = level+1
	if(level > 4):
		level = 5
	pass


func success_sound():
	#audio.play()
	#get_tree().create_timer(0.5).timeout
	#audio.pitch_scale = 1.1
	#audio.stop()
	#audio.play()
	#get_tree().create_timer(0.5).timeout
	#audio.pitch_scale = 1.2
	#audio.stop()
	#audio.play()
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
	#dot.sfx_tap(1)
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
			audio.pitch_scale = 1.3
			audio.play()
			#rotate_dots()
		else:
			selected_dots[0].disclose()
			selected_dots[1].disclose()
			hp -= 1
				
			
		selected_dots.clear()
	
		# check active dots
		var all_dots_inactive = true
		for d in dots:
			if d.is_active:
				all_dots_inactive = false
		if all_dots_inactive:
			
			#await get_tree().create_timer(1.5).timeout
			success_sound()
			await get_tree().create_timer(1.5).timeout
			clear_level()
			#init_level()
			next_level()
			
		# game over
		if hp == 0:
			clear_level()
			#reset_level()
			await get_tree().create_timer(1.0).timeout
			next_level(1)
	
	pass # Replace with function body.
