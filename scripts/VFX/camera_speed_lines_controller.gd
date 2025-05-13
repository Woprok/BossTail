extends Node3D
class_name CamSpeedLinesController

var material: ShaderMaterial
@export var shader_mesh: MeshInstance3D
var param_name: String = "Alpha"
var fx_tweener: Tween

func _ready() -> void:
	setup()

func setup():
	material = shader_mesh.material_override
	set_shader_param_val(0.0)

func appear(duration):
	if fx_tweener != null:
		fx_tweener.kill()
	fx_tweener = create_tween()
	fx_tweener.tween_method(set_shader_param_val, 0.0, 1.0, duration)
	
func fade(duration):
	if fx_tweener != null:
		fx_tweener.kill()
	fx_tweener = create_tween()
	fx_tweener.tween_method(set_shader_param_val, 1.0, 0.0, duration)

func set_shader_param_val(value: float) -> void:
	material.set_shader_parameter(param_name, value)
