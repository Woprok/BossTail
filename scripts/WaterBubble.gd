extends CharacterBody3D

var gravity:int = -9
var HEIGHT_OF_ARC:float = 4
var speed:int = 3
var collision_num = 0 
var collision_with_player = false

func _physics_process(delta):
	if position.y<-1:
		queue_free()
	velocity.y += speed*gravity*delta
	var collision = move_and_collide(speed*velocity*delta)
	
	if collision:
		if collision.get_collider().is_in_group("player") and not collision_with_player:
			collision_with_player = true
			collision_num += 1
			pop()
			collision.get_collider().launch(transform.basis.z)
			collision.get_collider().hit(5)
			return
		elif collision.get_collider().is_in_group("stone_platform") or collision.get_collider().is_in_group("lily_platform"):
			collision_num += 1
			pop()
		else:
			collision_num += 1
			pop()

func pop():
	if collision_num == 1:
		var tween = get_tree().create_tween()
		tween.tween_property($bubble,"scale",Vector3(10,10,10),0.1)
		tween.tween_callback(queue_free)

func shoot(end):
	var height = end.y - global_position.y + HEIGHT_OF_ARC
	height = abs(height)
	var displacement_y = end.y-global_position.y
	var displacemnt_xz = Vector3(end.x-global_position.x,0,end.z-global_position.z)
	var velocity_y = Vector3.UP * sqrt(-2*gravity*height)
	var velocity_xz = displacemnt_xz/(sqrt(-2*height/gravity)+sqrt(2*(displacement_y-height)/gravity))
	velocity = velocity_y+velocity_xz
	
func emerge():
	velocity.y = 8
