@tool
extends HBoxContainer

class_name PointsPreset

var tab : TabPanel
var data := {}
var presets_list
var dock : TabContainer

func setup():
	var name_ = create_name('preset_' + str(presets_list.get_children().size()))
		
	rename(name_)
	data = {
		'handles' : [],
		'pivot_pos' : null,
		'handles_pos' : [],
		'child_index' : get_index()
	}

func create_name(name_ : String):
	if tab.presets_list.has_node(name_):
		name_ = create_name(name_ + '_2')
	return name_
	
func rename(n : String):
	name = n
	$name.text = n
	$rename.text = n


func _on_del_pressed():
	dock.remove_preset(self)


func _on_rename_text_submitted(new_text):
	update_name(new_text)
	
		
func update_name(new_name):
	if new_name != '':
		dock.rename_preset(self, new_name)
	else:
		rename(name)
	
	
func _on_sel_pressed():
	var handles = tab.get_handles_by_indexes(data.handles)
	tab.sel_handles = handles
	tab.update_sel()
	
func toggle(value : bool):
	$name.visible = value
	$rename.visible = not value
	$sel.visible =  not value
	$del.visible =  not value
	if not value:
		$rename.mouse_filter = MOUSE_FILTER_IGNORE
		$sel.mouse_filter = MOUSE_FILTER_IGNORE
		$del.mouse_filter = MOUSE_FILTER_IGNORE
	else:
		$rename.mouse_filter = MOUSE_FILTER_PASS
		$sel.mouse_filter = MOUSE_FILTER_PASS
		$del.mouse_filter = MOUSE_FILTER_PASS



func _on_rename_mouse_exited():
	$rename.release_focus()
	update_name($rename.text)
