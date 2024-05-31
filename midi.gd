extends Node2D
class_name Midi
var stream = preload("res://drop_002.ogg")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func play(notes:Array[int], bpm:float=300):
	for i in notes:
		var afx:AudioStreamPlayer = AudioStreamPlayer.new()
		add_child(afx)
		afx.stream = stream
		afx.pitch_scale = pow(2,i/12.0)
		afx.play()
		await get_tree().create_timer(60/bpm).timeout
	pass