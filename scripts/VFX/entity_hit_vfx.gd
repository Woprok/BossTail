extends Node3D
class_name EntityHitVFX

@export var HitColor: Color = Color.WHITE
@export var HitFlashDuration: float
@export var HitFlashCycles: int
@export var HitFlashPeakBlendValue: float
@export var OverlayMatMeshes : Array[MeshInstance3D]

var mesh_shaders: Array[ShaderMaterial]
var effect_tweener: Tween

func _ready() -> void:
	for mesh in OverlayMatMeshes:		
			var surfaces = mesh.get_surface_override_material_count()
			for surf_id in surfaces:
				var material = mesh.get_active_material(surf_id)
				if material is ShaderMaterial:
					mesh_shaders.append(material)
	
	for shader in mesh_shaders:
		shader.set_shader_parameter("OverlayColor", HitColor)
	pass

func play_effect() -> void:
	var first_iter: bool = true
	if effect_tweener != null and effect_tweener.is_running():
		effect_tweener.kill()
	effect_tweener = get_tree().create_tween().set_loops(HitFlashCycles)
	
	for shader in mesh_shaders:
		if first_iter:
			first_iter = false
			effect_tweener.tween_subtween(flash_overlay_subtween(shader))
		else:
			effect_tweener.parallel().tween_subtween(flash_overlay_subtween(shader))

func flash_overlay_subtween(shader: ShaderMaterial) -> Tween:
	var subtween = create_tween()
	subtween.tween_method(set_blend_weight_val.bind(shader), 0.0, HitFlashPeakBlendValue, HitFlashDuration/2.0)
	subtween.tween_method(set_blend_weight_val.bind(shader), HitFlashPeakBlendValue, 0.0, HitFlashDuration/2.0)
	return subtween
	
func set_blend_weight_val(val: float, shader: ShaderMaterial) -> void:
	shader.set_shader_parameter("BlendWeight", val)
