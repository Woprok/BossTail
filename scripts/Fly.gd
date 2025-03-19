extends CharacterBody3D

var speed:int = 2
var time:int = 0
var gravity:int = -10
@export var flying = false
var dead = false
var HEIGHT_OF_ARC:float = 2
var groupSize = 1
var platform:Node

func _physics_process(delta):
	if flying:
		return
	velocity.y += speed*gravity*delta
	var collision = move_and_collide(speed*velocity*delta)
	if collision:
		dead = true

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


func _on_body_entered(body):
	if body.is_in_group("fly") and self!=body:
		groupSize += 1


func _on_body_exited(body):
	if body.is_in_group("fly") and self!=body:
		groupSize -= 1


func _on_area_entered(area):
	if area.is_in_group("stone_platform") or area.is_in_group("lily_platform"):
		platform = area
