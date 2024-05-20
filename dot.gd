extends Area2D
class_name Dot

@onready var sprite = $Sprite2D
var dot_color = Color.WHITE
var is_showing = false
var index = 0
signal click(dot:Dot)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func init(color:Color):
	dot_color = color
	pass

func reveal():
	is_showing = true
	sprite.modulate = dot_color
	pass
	
func disclose():
	is_showing = false
	sprite.modulate = Color.WHITE
	pass

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event.is_action_pressed("click"):
		#print_debug('click')
		#sprite.modulate = dot_color
		emit_signal('click', self)
	pass # Replace with function body.
