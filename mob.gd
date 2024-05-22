extends Area2D
class_name Mob

@onready var arrow = $arrow
@onready var animation = $AnimationPlayer
@onready var body = $body

var  score = 0
var is_active = false
var initial_position = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	initial_position = position
	set_deactive()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.y = move_toward(position.y, initial_position.y-score, delta*50)
	pass

func init():
	score = 0
	set_deactive()
	pass

func set_active():
	is_active = true
	arrow.visible = true
	bounce()
	pass

func set_deactive():
	is_active = false
	arrow.visible = false
	pass

func add_score():
	score += 25
	pass

func bounce():
	body.scale = Vector2(0.85,0.85)
	var tween = get_tree().create_tween()
	tween.tween_property(body, "scale", Vector2(1,1), 1.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	pass

func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click"):
		#emit_signal('click mob', self)
		print('click mob')
	pass 
