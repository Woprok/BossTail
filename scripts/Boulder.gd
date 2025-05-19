extends RigidBody3D

var launched = false
var respawn_position = null

func _physics_process(_delta):
	linear_velocity.x*=0.97
	linear_velocity.z*=0.97
	
	if launched and position.y < -3 and respawn_position != null:
		respawn()

func respawn():
	launched = false
	position = respawn_position
