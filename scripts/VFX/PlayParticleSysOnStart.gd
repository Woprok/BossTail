extends Node3D
class_name PlayParticleSysOnStart

@export var DestroyInSeconds: float = 1

func _ready() -> void:
	init()

func init():
	play_particle_systems()
	
	if DestroyInSeconds > 0:
		get_tree().create_timer(DestroyInSeconds).timeout.connect(queue_free)

func play_particle_systems():
	var children: Array[Node] = self.get_children()
	
	for child in children:
		if child is GPUParticles3D:
			#print("gpu particle:" + child.name)
			var particle_sys = child as GPUParticles3D
			particle_sys.restart()
			particle_sys.emitting = true
