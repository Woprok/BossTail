extends CharacterBody3D

var speed:int = 2
var time:int = 0
var max_time:int = 3
var gravity:int = -10
var HEIGHT_OF_ARC:float = 2

func _physics_process(delta):
	time += delta
	if time>max_time:
		queue_free()
	velocity.y += speed*gravity*delta
	var colision = move_and_collide(speed*velocity*delta)
	if colision:
		if colision.get_collider().is_in_group("enemy") or colision.get_collider().is_in_group("player"):
			colision.get_collider().hit(colision.get_collider_shape())
		queue_free()	


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
