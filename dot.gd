extends Area2D
class_name Dot

@onready var sprite = $sprite
@onready var dot_core = $sprite/core
@onready var dot_bg = $sprite/bg
@onready var audio = $AudioStreamPlayer
var tap_sound = preload("res://tap.mp3")
var dot_color = Color.WHITE
var is_showing = false
var is_active = true
var index = 0
var next_position = Vector2()
signal click(dot:Dot)
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	audio.stream = tap_sound
	dot_bg.visible = false
	is_active = false
	sprite.scale = Vector2(0.3,0.3)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func init(color:Color):
	dot_color = color
	pass

func set_color(color:Color):
	dot_color = color
	pass

func sfx_tap(pitch:float):
	audio.pitch_scale = pitch
	audio.play()
	pass

func reveal():
	is_showing = true
	dot_bg.visible = true
	#sprite.modulate = dot_color
	#sprite.scale = Vector2(1.3,1.3)
	var tween = get_tree().create_tween()
	tween.tween_property(dot_core, "modulate", dot_color, 0.25).set_ease(Tween.EASE_IN)
	pass
	
func disclose():
	is_showing = false
	dot_bg.visible = false
	dot_core.modulate = Color.WHITE
	pass

#func activate():
	#is_active = true
	
func activate():
	var tween = get_tree().create_tween()
	dot_core.modulate = dot_color
	#tween.tween_interval(rng.randi_range(0,5)*0.5).finished
	tween.tween_property(sprite, "scale", Vector2(1,1), 1.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	#tween.tween_property(sprite, "scale", Vector2(1,1), 0.4)
	tween.tween_property(dot_core, "modulate", Color.WHITE, 0.2)
	tween.tween_callback(set_active)

func set_active():
	is_active = true

func deactivate():
	is_active = false
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "scale", Vector2(0.3,0.3), 0.4).set_ease(Tween.EASE_OUT)
	pass

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if !is_active:
		return
		
	if event.is_action_pressed("click"):
		emit_signal('click', self)
	pass # Replace with function body.
