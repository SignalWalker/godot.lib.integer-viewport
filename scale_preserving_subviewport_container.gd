@tool
class_name IntegerScalingSubViewportContainer extends SubViewportContainer

@export var base_size: Vector2i = Vector2i.ZERO:
	get:
		return base_size
	set(value):
		base_size = value
		self.custom_minimum_size = base_size
		self._update_scale()
		self.queue_sort()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_RESIZED:
			self._update_scale()
		_:
			pass

func _init() -> void:
	self.stretch = true

	self.child_entered_tree.connect(self._on_child_entered)

func _update_scale() -> void:
	self.stretch = true
	self.stretch_shrink = IntegerScalingContainer.get_largest_integer_scale(self.base_size, self.size)

func _on_child_entered(c: Node) -> void:
	if c is SubViewport:
		var v := c as SubViewport
		v.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
		v.snap_2d_vertices_to_pixel = true
		v.gui_snap_controls_to_pixels = true
