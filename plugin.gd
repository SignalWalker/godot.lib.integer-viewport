@tool
extends EditorPlugin

func get_plugin_path() -> String:
	var scr: Variant = get_script()
	assert(scr != null)
	return (scr as Script).resource_path.get_base_dir()

func _enter_tree() -> void:
	if !Engine.is_editor_hint():
		return
	Engine.set_meta(&"IntegerViewportPlugin", self)

func _exit_tree() -> void:
	if !Engine.is_editor_hint():
		return
	Engine.remove_meta(&"IntegerViewportPlugin")

func _enable_plugin() -> void:
	pass

func _disable_plugin() -> void:
	pass

