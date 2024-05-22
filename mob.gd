extends Area2D
class_name Mob

@onready var arrow = $arrow
@onready var animation = $AnimationPlayer
@onready var body = $body

var is_active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_deactive()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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

func bounce():
	body.scale = Vector2(0.8,0.8)
	var tween = get_tree().create_tween()
	tween.tween_property(body, "scale", Vector2(1,1), 1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	pass

func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click"):
		#emit_signal('click mob', self)
		print('click mob')
	pass 
