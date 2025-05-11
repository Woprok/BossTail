extends MeshInstance3D

var material: ShaderMaterial
var param_name: String = "Dissolve"
var effect_tweener: Tween

func _ready() -> void:
	material = self.material
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
