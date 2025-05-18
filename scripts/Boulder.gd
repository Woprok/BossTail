extends RigidBody3D

func _physics_process(_delta):
	linear_velocity.x*=0.97
	linear_velocity.z*=0.97
