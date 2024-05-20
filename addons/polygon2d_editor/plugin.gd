@tool
extends EditorPlugin

const dock_scene := preload("res://addons/polygon2d_editor/dock.tscn")
var dock : PolyDock
var editor_settings := get_editor_interface().get_editor_settings()
var anim_player : AnimationPlayer


func _ready():
	if not Engine.has_singleton('Polygon2DEditor'):
		Engine.register_singleton('Polygon2DEditor', self)
		ProjectSettings.save()
	dock = dock_scene.instantiate() as PolyDock
	dock.plugin = self
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, dock)
	make_visible(true)
	while not dock.is_inside_tree():
		await get_tree().process_frame
	dock.setup()
	#add_control_to_bottom_panel(dock, "Polygon2D")


func _handles(object):
	return object is AnimationPlayer
	
func _edit(object):
	anim_player = object


func _exit_tree():
	if dock:
		remove_control_from_docks(dock)
		dock.queue_free()


func make_visible(visible):
	if dock and visible:
		make_bottom_panel_item_visible(dock)

func handles(object):
	if object is Polygon2D:
		return not object.polygon.empty()
	return false

func get_plugin_name():
	return "Polygon2D"
	
func get_plugin_icon():
	var gui = get_editor_interface().get_base_control()
	return gui.get_icon("Polygon2D", "EditorIcons")


