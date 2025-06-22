extends Node3D
class_name DeathVFX

@export var disintegrate_duration: float = 1.25
@export var fade_particles_delay: float = 0.75
@export var fade_particles_dur: float = 0.75

@export var animator: ToadAnimationController
@export var disintegrate_particles: Array[GPUParticles3D]
@export var MatMeshes: Array[MeshInstance3D]
var mesh_shaders: Array[ShaderMaterial]

func _ready() -> void:
	for particle_sys: GPUParticles3D in disintegrate_particles:
		particle_sys.emitting = false
		
	get_shaders()
	for shader: ShaderMaterial in mesh_shaders:
		shader.set_shader_parameter("Dissolve", 0.0)

func play_effect():
	animator.tongue_grab_start(-1)
	get_shaders()
	start_particle_systems()
	dissolve_mats()
	fade_particles()
	
func dissolve_mats():
	var tweener = create_tween()
	var first: bool = true
	for shader: ShaderMaterial in mesh_shaders:
		if first:
			first = false
			tweener.tween_method(set_dissolve_param_val.bind(shader), 0.0, 1.0, disintegrate_duration)
		else:
			tweener.parallel().tween_method(set_dissolve_param_val.bind(shader), 0.0, 1.0, disintegrate_duration)

func fade_particles():
	for particle_sys: GPUParticles3D in disintegrate_particles:
		var tweener: Tween = create_tween()
		tweener.tween_property(particle_sys, "amount", 1, fade_particles_dur).set_delay(fade_particles_delay)
		tweener.tween_property(particle_sys, "emitting", false, 0.01).set_delay(particle_sys.lifetime - 0.1)

func start_particle_systems():
	for particle_sys: GPUParticles3D in disintegrate_particles:
		particle_sys.emitting = true
	
func get_shaders():
	for mesh in MatMeshes:
			var surfaces = mesh.get_surface_override_material_count()
			for surf_id in surfaces:
				var material = mesh.get_active_material(surf_id)
				if material is ShaderMaterial:
					mesh_shaders.append(material)

func set_dissolve_param_val(value: float, shader: ShaderMaterial) -> void:
	shader.set_shader_parameter("Dissolve", value)
