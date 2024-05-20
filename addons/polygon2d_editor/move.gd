@tool
extends TabPanel

func set_panel(target):
	setup()
	if not gui_input.is_connected(_on_gui_input):
		gui_input.connect(_on_gui_input)
	self.target = target
	poly.texture = target.texture
	poly.texture_offset = target.texture_offset
	poly.texture_rotation = target.texture_rotation
	poly.texture_scale = target.texture_scale
	poly.polygon = target.polygon
	poly.polygons = target.polygons
	poly.uv = target.uv
	update_points()
	brush = $Container/Canvas/Brush
	
	
func _on_gui_input(event):
	if target:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.is_pressed():
					if sel_handles.is_empty():
						pass
					else:
						if not ctrl and not shift:
							clear_selected()

			elif event.button_index == MOUSE_BUTTON_RIGHT:
				if event.is_pressed():
					pass
				else:
					pass
		if event is InputEventMouseMotion:
			pass


func _on_reset_pressed():
	reset_poly()
	

func _on_save_preset_pressed():
	if has_selected():
		dock.add_preset()


func _on_save_pivot_toggled(toggled_on):
	hold.save_offset = toggled_on


func _on_presets_toggled(toggled_on):
	if toggled_on:
		$settings/presets/cont.show()
	else:
		$settings/presets/cont.hide()


func _on_debug__pressed():
#	print(EditorInterface.get_inspector().get_edited_object())
	pass
	


func _on_brush_toggled(toggled_on):
	brush.on = toggled_on

