extends CharacterBody3D

var time = 0
var speed:int = 2
var max_time:int = 30
var gravity:int = -10
var HEIGHT_OF_ARC:float = 2
@onready var stone_platforms = get_parent().get_parent().get_node("stonePlatforms")

func _physics_process(delta):
	time += delta
	if time>max_time:
		respawn()
	velocity.y += speed*gravity*delta
	if position.y<-0.3:
		respawn()
		return
	var collision = move_and_collide(speed*velocity*delta)
	if collision:
		if collision.get_collider().is_in_group("enemy"):
			if collision.get_collider().swimming:
				collision.get_collider().hit(self)
			else:
				collision.get_collider().hit(collision.get_collider_shape())
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
	var platform
	if stone_platforms.get_child_count()==0 and Global.phase>1:
		var child_index = randi() % get_parent().get_parent().get_node("shards").get_child_count()
		platform = get_parent().get_parent().get_node("shards").get_child(child_index)
	else:
		var child_index = randi() % stone_platforms.get_child_count()
		platform = stone_platforms.get_child(child_index)
	var x = randf() * 7 - 3.5
	var z = randf() * 7 - 3.5
	position = Vector3(platform.position.x+x,platform.position.y+2,platform.position.z+z)
	velocity = Vector3(0,0,0)
	time = 0
