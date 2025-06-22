@tool
extends EditorPlugin

func get_plugin_path() -> String:
	return get_script().resource_path.get_base_dir()

func _enter_tree() -> void:
	if !Engine.is_editor_hint():
		return
	Engine.set_meta(&"IntegerViewportPlugin", self)

func _exit_tree() -> void:
	if !Engine.is_editor_hint():
		return
	Engine.remove_meta(&"IntegerViewportPlugin")

func _enable_plugin() -> void:
	add_autoload_singleton("ViewportManager", get_plugin_path() + "/viewport_manager.gd")

func _disable_plugin() -> void:
	remove_autoload_singleton("ViewportManager")

