extends Node3D
class_name ToadAtkIndicatorVFXController

var vfxTweener: Tween
@export var indicMesh: MeshInstance3D
var  shaderMaterial: ShaderMaterial
@export var startBorderOpacity: float
@export var startShapesOpacity: float

func setup() -> void:
	shaderMaterial = indicMesh.material_override
	set_border_opacity(startBorderOpacity)
	set_shapes_opacity(startShapesOpacity)
	
func appear(scale_in_dur: float, ind_scale: float = 1) -> void:
	if vfxTweener:
		vfxTweener.kill()
	vfxTweener = self.create_tween()
	
	self.scale = Vector3.ZERO
	set_border_opacity(startBorderOpacity)
	set_shapes_opacity(0)
	vfxTweener.tween_property(self, "scale", Vector3.ONE*ind_scale, scale_in_dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	vfxTweener.parallel().tween_method(set_shapes_opacity, 0.01, startShapesOpacity, scale_in_dur)

func fade(duration: float) -> void:
	if vfxTweener:
		vfxTweener.kill()
	vfxTweener = self.create_tween()
	
	vfxTweener.tween_method(set_border_opacity, startBorderOpacity, 0, duration)
	vfxTweener.parallel().tween_method(set_shapes_opacity, startShapesOpacity, 0, duration)
	vfxTweener.tween_callback(dispose)
	pass
	
func set_border_opacity(val: float) -> void:
	shaderMaterial.set_shader_parameter("BorderOpacity", val)
func set_shapes_opacity(val: float) -> void:
	shaderMaterial.set_shader_parameter("ShapesOpacity", val)
	
func dispose() -> void:
	if vfxTweener:
		vfxTweener.kill()
	queue_free()
	pass
