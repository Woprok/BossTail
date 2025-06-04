extends MeshInstance3D
class_name WhirlwindStrand

@export var SpinSpeed: float

var shader_mat: ShaderMaterial
var fade_tweener: Tween

func _ready() -> void:
	shader_mat = get_active_material(0)
	#fade(0)

func _process(delta: float) -> void:
	rotate_y(deg_to_rad(SpinSpeed) * delta)
	
func fade(dur: float):
	tween_opacity(1.0, 0.0, dur)
	
func appear(dur: float):
	tween_opacity(0.0, 1.0, dur)
	
func tween_opacity(from: float, to: float, dur: float):
	if fade_tweener != null and fade_tweener.is_running():
		fade_tweener.kill()
	fade_tweener = create_tween()
	fade_tweener.tween_method(set_shader_opacity, from, to, dur)
	
func set_shader_opacity(val: float):
	shader_mat.set_shader_parameter("Opacity", val)
