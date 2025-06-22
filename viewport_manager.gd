class_name SViewportManager extends Node

## Base size of game viewport
var base_size: Vector2i

## Centers game viewport within window
var center_container: CenterContainer
## Used for sizing of vp_container and pp_display
var vp_root: Control
## Container for the game viewport
var vp_container: SubViewportContainer
## Viewport in which the game is rendered
var vp: SubViewport

## Background displayed behind game
var bg: Control

## Post-processor
var pp_display: PostProcessor

func _init() -> void:
	self.base_size = Vector2i(ProjectSettings.get_setting(&"display/window/size/viewport_width", 427) as int, ProjectSettings.get_setting(&"display/window/size/viewport_height", 320) as int)

	var texrect: TextureRect = TextureRect.new()
	texrect.texture = load(&"res://gui/theme/square.png")
	texrect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texrect.stretch_mode = TextureRect.STRETCH_TILE
	self.bg = texrect
	self.bg.name = &"DisplayBackground"
	# self.bg.material = load(&"res://shaders/combat_bg/singularity.tres")
	self.bg.set_anchors_preset(Control.LayoutPreset.PRESET_FULL_RECT)

	self.center_container = CenterContainer.new()
	self.center_container.set_anchors_preset(Control.LayoutPreset.PRESET_FULL_RECT)

	self.vp_root = Control.new()

	self.vp_container = SubViewportContainer.new()
	self.vp_container.set_anchors_preset(Control.LayoutPreset.PRESET_FULL_RECT)
	self.vp_container.stretch = true

	self.vp = SubViewport.new()
	self.vp.name = &"GameViewport"
	# ensure vp always renders
	self.vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	# rendering options
	self.vp.size = self.base_size
	self.vp.transparent_bg = true
	self.vp.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	self.vp.snap_2d_vertices_to_pixel = true
	self.vp.gui_embed_subwindows = true
	self.vp.gui_snap_controls_to_pixels = true

	self.pp_display = PostProcessor.new()
	self.pp_display.name = &"DisplayPostProcessor"
	self.pp_display.set_anchors_preset(Control.PRESET_FULL_RECT)
	self.pp_display.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	self.pp_display.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	self.pp_display.initial = self.vp
	self.pp_display.chain = load(&"res://shaders/post_processing_chain_display.tres")

	self.pp_display.was_reset.connect(self._on_pp_display_changed)
	self.pp_display.input_changed.connect(self._on_pp_display_changed)
	self._on_pp_display_changed()

func _enter_tree() -> void:
	var window: Window = self.get_window()
	window.size_changed.connect(self._on_window_size_changed)
	window.mode = Window.MODE_MAXIMIZED

	self._on_window_size_changed()

func _ready() -> void:
	self.vp.add_child(FocusCursorLayer.new(), false, Node.INTERNAL_MODE_BACK)
	self.vp_container.add_child(self.vp)
	self.vp_root.add_child(self.vp_container)
	self.vp_root.add_child(self.pp_display)
	self.center_container.add_child(self.vp_root)
	var window: Window = self.get_window()
	window.add_child.call_deferred(self.bg)
	window.add_child.call_deferred(self.center_container)

static func largest_multiple_within(x: int, high: int) -> int:
	return high - (high % x)

func _on_window_size_changed() -> void:
	var w_size: Vector2i = self.get_window().size

	# get new size
	var largest_y: int = largest_multiple_within(base_size.y, w_size.y)
	var largest_x: int = largest_multiple_within(base_size.x, w_size.x)
	var x_scale: int = floor(float(largest_x) / float(base_size.x))
	var y_scale: int = floor(float(largest_y) / float(base_size.y))
	var scale: int = maxi(1, mini(x_scale, y_scale))
	var new_size: Vector2i = Vector2i(base_size.x * scale, base_size.y * scale)

	# update vp_root & container
	self.vp_root.custom_minimum_size = new_size
	self.vp_root.size = new_size
	self.vp_container.stretch_shrink = scale

func _on_pp_display_changed() -> void:
	# if self.pp_display.is_rendering():
	# 	self.pp_display.visible = true
	# 	self.vp_container.visible = false
	# else:
	# 	self.pp_display.visible = false
	# 	self.vp_container.visible = true
	pass
