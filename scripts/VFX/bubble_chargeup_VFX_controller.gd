extends Node3D
class_name BubbleChargeupVFXController

var particle_sys: GPUParticles3D
var material: StandardMaterial3D

func _ready() -> void:
	setup_refs()
	
	material.albedo_color = Color.TRANSPARENT
	particle_sys.speed_scale = 0.0
	
func setup_refs():
	particle_sys = $Chargeup
	material = particle_sys.material_override
	
func fx_appear(duration: float): #
	var fx_tweener = create_tween()
	material.albedo_color = Color.TRANSPARENT
	particle_sys.speed_scale = 0.0
	fx_tweener.tween_property(material, "albedo_color", Color.WHITE, duration)
	fx_tweener.parallel().tween_property(particle_sys, "speed_scale", 1.0, duration)

func fx_fade(duration: float):
	var fx_tweener = create_tween()
	material.albedo_color = Color.WHITE
	particle_sys.speed_scale = 1.0
	fx_tweener.tween_property(material, "albedo_color", Color.TRANSPARENT, duration)
	fx_tweener.parallel().tween_property(particle_sys, "speed_scale", 0.0, duration)
