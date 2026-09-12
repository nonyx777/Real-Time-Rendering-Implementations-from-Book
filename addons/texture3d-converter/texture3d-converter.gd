@tool
extends EditorPlugin

var dock: Control

func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	dock = preload("res://addons/texture3d-converter/texture3d-converter-dock.gd").new()
	dock.name = "Texture3DConverter"
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)


func _exit_tree() -> void:
	if dock:
		remove_control_from_docks(dock)
		dock.free()
