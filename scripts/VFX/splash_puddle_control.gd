extends MeshInstance3D
class_name PuddleController

var material: ShaderMaterial
var param_name: String = "Dissolve"
var effect_tweener: Tween

func setup():
	material = self.material_override
	set_dissolve_param_value(1.0)
	
func puddle_appear(duration: float) -> void:
	if effect_tweener != null and effect_tweener.is_running():
		effect_tweener.kill()
	effect_tweener = create_tween()
	
	effect_tweener.tween_method(set_dissolve_param_value, 1.0, 0.0, duration)

func puddle_fade(duration: float) -> void:
	if effect_tweener != null and effect_tweener.is_running():
		effect_tweener.kill()
	effect_tweener = create_tween()
	
	effect_tweener.tween_method(set_dissolve_param_value, 0.0, 1.0, duration)

func set_dissolve_param_value(value: float) -> void:
	material.set_shader_parameter(param_name, value)
