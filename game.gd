extends Node2D

#@onready var audio:AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var score_bar:ScoreBar = $score_bar
@onready var hp_bar:HpBar = $hp_bar
@onready var midi:Midi = $midi
@onready var score_label:Label = $score_container/score
@onready var score_container = $score_container

#var TapSound = preload("res://tap.mp3")
#var TapSound = preload("res://drop_002.ogg")
var Dot = preload("res://dot.tscn")
var selected_dots = []
var dots = []
#var colors_set = [Color.ORANGE, Color.YELLOW_GREEN, Color.LIGHT_CORAL, Color.SLATE_BLUE]
var colors_set = [Color('#F85D6B'), Color('#a6cc34'), Color('#fba501'), Color('#7964ba')]
#var a = Color.ORANGE
var line:Line2D = Line2D.new()
var level = 1
var rng = RandomNumberGenerator.new()
var hp = 1
var max_level = 8
var score = 0
var target_score = 0
var combo = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	#audio.stream = TapSound
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
	
	#if score != target_score:
		#score = move_toward(score, target_score, 100*delta)
		
	
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
	var padding_y = (get_viewport_rect().size.y - grid_size*(row-1))/2 + 20
	for x in col:
		for y in row:
			points.append(Vector2(pading_x+x*grid_size,padding_y+y*grid_size))
	
	score_bar.position = Vector2i(pading_x-5,padding_y-80)
	score_bar.set_length(grid_size*3 +10)
	score_bar.set_max_score(15)
	
	hp_bar.position = Vector2i(pading_x,padding_y-89)
	hp_bar.set_hp(hp)
	
	# score label
	reset_score()
	score_container.position = Vector2i(pading_x+grid_size*3+10,padding_y-62)
	
	for p in points:
		var d:Dot = Dot.instantiate()
		d.position = p
		d.connect('click', _on_dot_click)
		add_child(d)
		dots.append(d)
	pass

func next_level(lv=null):
	if lv:
		level = lv
	
	# new game
	if level == 1:
		hp = 1
		combo = 0
		hp_bar.set_hp(hp)
		reset_score()
	
	dots.shuffle()
	#colors_set.shuffle()
	var pallets = colors_set.duplicate()
	pallets.shuffle()
	pallets += pallets
	pallets += pallets
	for i in level:
		dots[i*2].set_color(pallets[i])
		dots[i*2+1].set_color(pallets[i])
		dots[i*2].activate(level)
		dots[i*2+1].activate(level)
	level = level+1
	if(level > max_level):
		level = max_level
	pass

func reset_score():
	score = 0
	score_label.text = str('0')
	pass
	
func add_score(val:int):
	score += val
	score_label.text = str(score)
	pass

var processing_dot = false
func _on_dot_click(dot:Dot):
	print('click')
	
	# select dot must not more than 2
	if selected_dots.size() >= 2:
		return
	
	# check duplicate
	if selected_dots.size() == 1:
		if selected_dots[0] == dot:
			return
	
	if processing_dot:
		return
		
	processing_dot = true
	
	selected_dots.append(dot)
	midi.play([selected_dots.size()*2-4])
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
			midi.play([5])
			add_score(100+combo*10)
			combo += 1
			score_bar.add_score(1, selected_dots[0].dot_color)
		else:
			selected_dots[0].disclose()
			selected_dots[1].disclose()
			midi.play([-5])
			hp -= 1
			combo = 0
			hp_bar.set_hp(hp)
				
			
		selected_dots.clear()
	
		# check lv pass
		var all_dots_inactive = true
		for d in dots:
			if d.is_active:
				all_dots_inactive = false
		if all_dots_inactive:
			await get_tree().create_timer(1.0).timeout
			midi.play([1,6])
			clear_level()
			await get_tree().create_timer(1).timeout
			hp += 1
			combo = 0
			hp_bar.set_hp(hp)
			next_level()
			
		# game over
		if hp == 0:
			await get_tree().create_timer(1.0).timeout
			midi.play([5,3,0])
			clear_level()
			await get_tree().create_timer(3).timeout
			next_level(1)
			
	processing_dot = false
	
	pass # Replace with function body.
