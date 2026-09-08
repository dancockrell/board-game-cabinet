extends Node3D
## One authored 2D background. World coordinates only register sprites and picking.
const BACKDROP = preload("res://assets/olympus_arena/terrain/pixel-arena-backdrop-v1.png")
const MOTION = preload("res://presentation/olympus_backdrop.gdshader")
const BRIDGE_CENTERS = [Vector2(582,484), Vector2(944,484)]
var _water_time := 0.0
var animation_enabled := true
var backdrop: Sprite3D
var sea_fill: Sprite3D
var _sea_material: ShaderMaterial
var _art_material: ShaderMaterial

func _ready() -> void:
	name = "OlympusStage"
	backdrop = Sprite3D.new()
	backdrop.name = "PaintedBackdrop"
	backdrop.texture = BACKDROP
	backdrop.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	backdrop.shaded = false
	backdrop.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	backdrop.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_art_material = ShaderMaterial.new()
	_art_material.shader = MOTION
	_art_material.set_shader_parameter("art", BACKDROP)
	backdrop.material_override = _art_material
	add_child(backdrop)
	sea_fill = Sprite3D.new()
	sea_fill.name = "PaintedSeaMargin"
	sea_fill.texture = BACKDROP
	sea_fill.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_sea_material = _art_material.duplicate()
	_sea_material.set_shader_parameter("sea_only", true)
	sea_fill.material_override = _sea_material
	add_child(sea_fill)

func configure(camera: Camera3D) -> void:
	# Register painted bridges to authoritative lanes, without changing rules.
	var anchor: Vector2 = (BRIDGE_CENTERS[0]+BRIDGE_CENTERS[1])*0.5
	backdrop.pixel_size = 5.4/(BRIDGE_CENTERS[1].x-BRIDGE_CENTERS[0].x)
	var offset := BACKDROP.get_size()*0.5-anchor
	backdrop.position = Vector3(0,0.12,0) + camera.basis.x*offset.x*backdrop.pixel_size - camera.basis.y*offset.y*backdrop.pixel_size - camera.basis.z*20.0
	sea_fill.position = backdrop.position-camera.basis.z*0.5
	sea_fill.pixel_size = backdrop.pixel_size*3.0

func advance_visual(delta: float) -> void:
	if not animation_enabled or not is_finite(delta) or delta <= 0.0: return
	_water_time += delta
	_art_material.set_shader_parameter("animation_time", _water_time)
	_sea_material.set_shader_parameter("animation_time", _water_time)
