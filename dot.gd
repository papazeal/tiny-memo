extends Area2D
class_name Dot

@onready var sprite = $sprite
@onready var dot_core = $sprite/core
@onready var dot_bg = $sprite/bg
@onready var dot_cover = $sprite/cover
@onready var audio = $AudioStreamPlayer
#var tap_sound = preload("res://tap.mp3")
var tap_sound = preload("res://drop_002.ogg")
var dot_color = Color.WHITE
var is_showing = false
var is_active = true
var index = 0
var next_position = Vector2()
var compact_pos = Vector2()
var expand_pos = Vector2()
signal click(dot:Dot)
var rng = RandomNumberGenerator.new()
var tween:Tween
# Called when the node enters the scene tree for the first time.
func _ready():
	
	audio.stream = tap_sound
	dot_bg.visible = false
	is_active = false
	sprite.scale = Vector2(0.25,0.25)
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
	audio.stop()
	audio.pitch_scale = pitch
	audio.play()
	pass

func reveal():
	is_showing = true
	#dot_bg.visible = true
	#sprite.modulate = dot_color
	#sprite.scale = Vector2(1.3,1.3)
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	#tween.tween_property(dot_core, "modulate", dot_color, 0.2)
	tween.tween_property(dot_cover, "modulate", Color(255,255,255, 0), 0.2)
	
	sprite.scale = Vector2(0.85,0.85)
	tween.tween_property(sprite, "scale", Vector2(1,1), 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	pass
	
func disclose():
	is_showing = false
	dot_bg.visible = false
	#dot_core.modulate = Color.WHITE
	
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	#tween.tween_property(dot_core, "modulate", Color.WHITE, 0.3)
	tween.tween_property(dot_cover, "modulate", Color(255,255,255, 1), 0.1)
	
	pass

	
func activate(lv=0):
	await get_tree().create_timer(rng.randi_range(1,4)*0.2).timeout
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	dot_core.modulate = dot_color
	dot_cover.modulate = Color(255,255,255,0)
	sprite.scale = Vector2(0.6,0.6)
	tween.tween_property(sprite, "scale", Vector2(1,1), 1.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(sprite, "scale", Vector2(1,1), lv*0.2)
	tween.tween_callback(set_active)
	tween.tween_property(dot_cover, "modulate", Color(255,255,255,1), 0.5)

func set_active():
	is_active = true

func deactivate():
	is_active = false
	#dot_core.modulate = Color.WHITE
	dot_cover.modulate = Color.WHITE
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	
	tween.tween_property(sprite, "scale", Vector2(0.25,0.25), 0.3).set_ease(Tween.EASE_OUT)
	#tween.tween_property(dot_cover, "modulate", Color(255,255,255,1), 0.2)
	pass

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if !is_active:
		return
		
	if event.is_action_pressed("click"):
		emit_signal('click', self)
	pass # Replace with function body.
