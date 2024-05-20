@tool
extends AcceptDialog

class_name ConfirmDialog

var state = 0

func _ready():
	add_button('Cancel', false, 'cancel')
	if not custom_action.is_connected(_on_custom):
		custom_action.connect(_on_custom)
	hide()


func _on_custom(action):
	if action == 'cancel':
		close()
	

func open(state_num := 0):
	position = get_parent().global_position + get_parent().size / 2
	state = state_num
	match state:
		0:
			dialog_text = 'hello!'
		1:
			dialog_text = 'Editing will remove saved presets in Move Tab'
	show()
	
	
func close():
	dialog_text = ''
	hide()
