@tool
## A container that ensures that its childrens' sizes are the largest integer multiple of a base size that fits within this container.
class_name IntegerScalingContainer extends Container

@export var base_size: Vector2i = Vector2i(1, 1):
	get:
		return base_size
	set(value):
		if value.x < 1 || value.y < 1:
			push_error("invalid integer scaling base size: {0}".format([value]))
			return
		base_size = value
		self.custom_minimum_size = base_size
		self.queue_sort()

static func largest_multiple_within(x: int, high: int) -> int:
	return high - (high % x)

static func get_largest_integer_scale(base: Vector2i, within: Vector2i) -> int:
	var x := maxi(1, base.x)
	var y := maxi(1, base.y)
	var largest_y := largest_multiple_within(y, within.y)
	var largest_x := largest_multiple_within(x, within.x)
	var x_scale	:= floori(float(largest_x) / base.x)
	var y_scale := floori(float(largest_y) / base.y)
	return maxi(1, mini(x_scale, y_scale))

static func fit_window(win: Window, base: Vector2i) -> void:
	if Engine.is_editor_hint():
		return

	win.min_size = base
	var win_id := win.get_window_id()
	var brd_size := DisplayServer.window_get_size_with_decorations(win_id) - win.size

	var scr := DisplayServer.window_get_current_screen(win_id)
	var use_rect := DisplayServer.screen_get_usable_rect(scr)

	win.size = base * IntegerScalingContainer.get_largest_integer_scale(base, use_rect.size - brd_size)
	win.move_to_center()

func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		var new_rect := self.get_scaled_rect()
		for c: Node in self.get_children():
			if c is Control:
				self.fit_child_in_rect(c as Control, new_rect)

func get_largest_scale() -> int:
	return get_largest_integer_scale(self.base_size, self.size)

func get_scaled_rect() -> Rect2:
	var s := self.get_largest_scale()
	var new_size := Vector2(self.base_size * s)
	return Rect2((self.size / 2.0) - (new_size / 2.0), new_size)
