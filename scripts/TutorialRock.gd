extends CharacterBody3D

var speed:int = 2
var gravity:int = -10
var HEIGHT_OF_ARC:float = 1.8

func _physics_process(delta):
	velocity.y += speed*gravity*delta
	var collision = move_and_collide(speed*velocity*delta)
	if collision:
		velocity = Vector3(0,0,0)
		if collision.get_collider().is_in_group("enemy"):
			collision.get_collider().hit(5)
			respawn()


func shoot(origin, end, result):
	if result:
		var result_position = result.get("position")
		var height = result_position.y - global_position.y + HEIGHT_OF_ARC
		height = abs(height)
		var displacement_y = result_position.y-global_position.y
		var displacemnt_xz = Vector3(result_position.x-global_position.x,0,result_position.z-global_position.z)
		var velocity_y = Vector3.UP * sqrt(-2*gravity*height)
		var velocity_xz = displacemnt_xz/(sqrt(-2*height/gravity)+sqrt(2*(displacement_y-height)/gravity))
		velocity = velocity_y+velocity_xz
	else:
		velocity = end - origin
		var height = velocity.y/8
		velocity = velocity.normalized()
		velocity *= 40
		velocity.y = height

func respawn():
	randomize()
	var x = randf() * 2 - 1
	var z = randf() * 2 - 1
	position = Vector3(x,0,z)
	velocity = Vector3(0,0,0)
