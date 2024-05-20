@tool
extends TabContainer

class_name PolyDock

const Preset_sc = preload('res://addons/polygon2d_editor/points_preset.tscn')
var presets_list : VBoxContainer

var container: Control
var canvas: Node2D

var tab : TabPanel
var plugin : EditorPlugin
var tool : Tool
var poly : Polygon2D
var target
var preset_config : ConfigFile
var plugin_config : ConfigFile
var scene
var confirm : ConfirmDialog
var interface
@export var move : TabPanel
@export var edit : TabPanel
var poly_data := {
	'poly':null,
	'int':null,
	'polys':null,
	'uv':null
}

var _dragging = false
var _old_position


var undo_redo: EditorUndoRedoManager

func setup():
	#undo_redo = plugin.get_undo_redo()
#	plugin = Polygon2DEditor
	confirm = $Confirm
	preset_config = ConfigFile.new()
	plugin_config = ConfigFile.new()
	tab = get_current_tab_control()
	tool = $Tool
	$Edit.setup()
	$Move.setup()
	#$Bones.setup()
	update_tab()
	if poly and poly.polygon.is_empty():
		current_tab = 1
		update_tab()
	plugin.get_editor_interface().get_selection().selection_changed.connect(_on_selection_changed)
	
	
func _process(delta):
	if tab:
#		update selected node when scene changed
		var sc = plugin.get_editor_interface().get_edited_scene_root()
		if scene and sc != scene:
			_on_selection_changed()
		scene = sc
			
			
func _on_target_propety_changed(prop):
	if tab and target and target is Polygon2D and poly:
		match prop:
			'polygon':
				if tab == move:
					tab.update_from_target()
				else:
					_on_selection_changed()
			_:
				_on_selection_changed()


# //// PRESETS FUNCTIONS STARTS ////////////////////////////////
func setup_presets():
#	if is_inside_tree():
	
	presets_list = $Move.presets_list
	clear_presets()
	await get_tree().process_frame
	load_presets()
	
func load_presets():
	if target:
		var err = preset_config.load('res://addons/polygon2d_editor/project_data/presets_data.cfg')
		if err == OK:
			var id := str(target.get_path())
			if preset_config.has_section(id):
				for name_ in preset_config.get_section_keys(id):
					var data = preset_config.get_value(id, name_)
					add_preset(name_, data, false)
				
				var presets = presets_list.get_children()
				presets.sort_custom(func(a, b): return a.data.child_index < b.data.child_index)
				for ch in presets_list.get_children():
					presets_list.remove_child(ch)
				for ch in presets:
					presets_list.add_child(ch)
				
					

func add_preset(name_ := '', data := {}, save := true):
	var preset : PointsPreset = Preset_sc.instantiate()
	preset.tab = $Move
	preset.dock = self
	preset.presets_list = presets_list
	presets_list.add_child(preset)
	preset.owner = self.owner
	preset.setup()
	if name_ != '':
		preset.rename(name_)
	if data != {}:
		preset.data = data
	else:
		if tab == $Move and tab.has_selected():
			preset.data.handles = tab.get_handles_indexes(tab.sel_handles)
			preset.data.handles_pos = tab.get_handles_pos(tab.sel_handles)
	if save:
		save_preset(preset)

func save_presets():
	for ch in presets_list.get_children():
		save_preset(ch)

func rename_preset(preset : PointsPreset, new_name : String):
	if target:
		preset_config.erase_section_key(str(target.get_path()), preset.name)
		preset.rename(new_name)
		save_preset(preset)

func save_preset(preset : PointsPreset):
	if target:
		preset_config.set_value(str(target.get_path()), preset.name, preset.data)
		preset_config.save('res://addons/polygon2d_editor/project_data/presets_data.cfg')
	
func clear_presets():
	if target and presets_list:
		for ch in presets_list.get_children():
			ch.queue_free()
	
func remove_poly_presets():
	if target:
		if preset_config.has_section(str(target.get_path())):
			preset_config.erase_section(str(target.get_path()))
			preset_config.save('res://addons/polygon2d_editor/project_data/presets_data.cfg')
		for ch in presets_list.get_children():
			ch.queue_free()

func remove_preset(preset: PointsPreset):
	if target:
		preset_config.erase_section_key(str(target.get_path()), preset.name)
		preset_config.save('res://addons/polygon2d_editor/project_data/presets_data.cfg')
		preset.queue_free()
	
# //// PRESETS FUNCTIONS ENDS ////////////////////////////////
	
func _on_selection_changed():
	if is_inside_tree():
		var nodes = plugin.get_editor_interface().get_selection().get_selected_nodes()
		if not nodes.is_empty():
			target = nodes[0]
			if target is Polygon2D:
				poly = tab.get_node('Container/Polygon2D')
				container.show()
				setup_presets()
				tab.set_panel(target)
				tab.clear_selected()
				tab.update_sel()
				if not plugin.get_editor_interface().get_inspector().property_edited\
				.is_connected(_on_target_propety_changed):
					plugin.get_editor_interface().get_inspector().property_edited\
					.connect(_on_target_propety_changed)
				tabs_visible = true
				tab.show()
			elif target is AnimationPlayer:
				if tab:
					tab.anim_player_selected(target)
			else:
				tabs_visible = false
				tab.hide()

	

func update_tab():
	tab = get_current_tab_control()
	if tab != $Info:
		container = tab.get_node('Container')
		container.scale = Vector2(.3,.3)
		var rect = Vector2.ZERO
		if target and target is Polygon2D and target.texture:
			rect = target.texture.get_size() * container.scale
		container.position = Vector2(get_parent().size.x / 2 - rect.x / 2, \
		get_parent().size.y / 2 - rect.y /2)
		_on_selection_changed()


func _on_tab_gui_input(event):
	var zoom_pos
	if event is InputEventMouseButton:
		if not tab.dragging:
			if event.is_pressed():
				if not tab.ctrl:
					if event.button_index == MOUSE_BUTTON_WHEEL_UP:
							container.scale = container.scale * (1 + event.factor / 10)
							tab.update_sel()
					if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
						container.scale = container.scale * (1 - event.factor / 10)
						tab.update_sel()
			if event.button_index == MOUSE_BUTTON_MIDDLE:
				_dragging = event.is_pressed()
				_old_position = event.global_position
				tab.update_sel()
	if event is InputEventMouseMotion:
		if _dragging:
			container.position += (event.global_position - _old_position)
			_old_position = event.global_position
			tab.update_sel()


func _on_tab_clicked(tab):
	update_tab()
	


