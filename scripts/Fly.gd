extends CharacterBody3D

var speed:int = 2
var time:int = 0
var gravity:int = -10
@export var flying = false
@export var swarm = false
@export var position_in_swarm = Vector3(0,0,0)
var dead = false
var HEIGHT_OF_ARC:float = 2
var groupSize = 1
var angle = 0
var platform:Node
var target_position
var split_off = false
var split_off_time = 0
var TIME_SPLIT_OFF = 10
var player_in_area = false

func _physics_process(delta):
	if flying and not swarm:
		angle += delta
		var center_position = get_parent().position
		angle = fmod(angle,TAU)
		var x = center_position.x + cos(angle) * 4
		var z = center_position.z + sin(angle) * 4
		position = Vector3(x,position.y,z) 
		return
	if flying and swarm:
		if split_off:
			split_off_time += delta
			if split_off_time>TIME_SPLIT_OFF:
				split_off_time = 0
				get_parent().active+=1
				split_off = false
		if get_parent().dispersed or split_off:
			if target_position!= null and target_position.distance_to(global_position)>=0.5:
				chase_position(delta, target_position, true)
			else:
				target_position = fly_around(get_parent().position,10)
				chase_position(delta, target_position, true)
		else:
			chase_position(delta, position_in_swarm, false)
		return
	velocity.y += speed*gravity*delta
	var collision = move_and_collide(speed*velocity*delta)
	if collision:
		dead = true
		if not swarm:
			scale=Vector3(1,1,1)
		if swarm and not split_off:
			get_parent().active -= 1 
		var root = get_tree().root.get_node("SecondPhase")
		var gl_position = self.global_position
		get_parent().remove_child(self)
		root.get_node("flies").add_child(self)
		self.position = gl_position
		swarm = false
			

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


func chase_position(delta, target_position,global):
	if global:
		var dir = target_position-global_position
		dir = dir.normalized()
		global_position += dir*speed*delta
	else:
		var dir = target_position-position
		dir = dir.normalized()
		position += dir*speed*delta
	

func fly_around(center, radius):
	var angle = randf() * TAU
	var distance = sqrt(randf()) * radius
	var x = center.x + distance * cos(angle)
	var z = center.z + distance * sin(angle)
	return Vector3(x,center.y, z)


func _on_body_entered(body):
	if body.is_in_group("fly") and self!=body:
		groupSize += 1
	if body.is_in_group("player"):
		player_in_area = true


func _on_body_exited(body):
	if body.is_in_group("fly") and self!=body:
		groupSize -= 1
	if body.is_in_group("player"):
		player_in_area = false


func _on_area_entered(area):
	if area.is_in_group("stone_platform") or area.is_in_group("lily_platform"):
		platform = area
