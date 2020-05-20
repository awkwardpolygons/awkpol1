tool
extends Viewport
# TODO: Replace this with a VisualServer implementation at some point
class_name TexturePainter

enum Action {NONE, PAINT, ERASE, CLEAR}

export(Texture) var texture: Texture setget _set_texture
export(Material) var material: Material setget _set_material, _get_material
var brush: PaintBrush setget _set_brush, _get_brush

var _vp: Viewport
var _cvi: TextureRect
var _shader = preload("res://addons/cartographer/texture_painter/texture_painter.shader")

func _init():
	#_vp = Viewport.new()
	_vp = self
	_vp.size = Vector2(2048, 2048)
	_vp.transparent_bg = true
	_vp.hdr = false
	_vp.keep_3d_linear = true
	_vp.disable_3d = true
	_vp.usage = Viewport.USAGE_2D
	_vp.render_target_v_flip = true
	_vp.render_target_clear_mode = Viewport.CLEAR_MODE_NEVER
	_vp.render_target_update_mode = Viewport.UPDATE_ALWAYS
	
	_cvi = TextureRect.new()
	_cvi.rect_min_size = _vp.size
	_cvi.rect_size = _vp.size
	_cvi.expand = true
	_cvi.stretch_mode = TextureRect.STRETCH_SCALE
	_vp.add_child(_cvi)
	
	_cvi.texture = load("res://largetex.tres")
	_cvi.material = ShaderMaterial.new()
	_cvi.material.shader = _shader
#	_cvi.material.set_shader_param("texture", load("res://addons/cartographer/rect_green.png"))

func _set_material(m: Material):
	_cvi.material = m

func _get_material():
	return _cvi.material

func _set_brush(br: PaintBrush):
	brush = br
	_cvi.material.set_shader_param("brush_mask", brush.brush_mask)
	_cvi.material.set_shader_param("brush_strength", brush.brush_strength)
	_cvi.material.set_shader_param("brush_scale", brush.brush_scale)
	_cvi.material.set_shader_param("brush_rotation", brush.brush_rotation)

func _get_brush():
	return brush

func _set_texture(t: Texture):
	texture = t

func save_to_image(i: Image):
	i.copy_from(_vp.get_texture().get_data())

func clear():
	print("CLEAR")
	# TODO: Temporary for shader updates during dev:
	_cvi.material.shader = load("res://addons/cartographer/texture_painter/texture_painter.shader")
	_cvi.material.set_shader_param("action", Action.CLEAR)

func paint_masks(action: int, pos: Vector2, layer: int):
	layer = clamp(layer, 0, 15)
	var region = int(layer / 4)
	var channel: Color = Color(-1, -1, -1, -1)
	channel[layer % 4] = 1
	_cvi.material.set_shader_param("action", action)
	_cvi.material.set_shader_param("brush_pos", pos)
	_cvi.material.set_shader_param("add_channel", channel)
	_cvi.material.set_shader_param("active_region", region)

func paint(action: int, pos: Vector2):
	_cvi.material.set_shader_param("action", action)
	_cvi.material.set_shader_param("brush_pos", pos)

func stop():
	_cvi.material.set_shader_param("action", Action.NONE)
