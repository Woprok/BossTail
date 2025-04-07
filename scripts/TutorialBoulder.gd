extends RigidBody3D

func _physics_process(delta):
	if global_position.y<1:
		respawn()

func respawn():
	pass
