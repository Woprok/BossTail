extends CharacterBody3D

var gravity:int = -9
var HEIGHT_OF_ARC:float = 1.5
var speed:int = 2.5
var ACID = preload("res://scenes/AcidingLiquid.tscn")

func _physics_process(delta):
	velocity.y += speed*gravity*delta
	var collision = move_and_collide(speed*velocity*delta)
	if collision:
		if collision.get_collider().is_in_group("player"):
			collision.get_collider().hit(collision.get_collider_shape())
			queue_free()
			return
		if collision.get_collider().is_in_group("lily_platform"):
			var tween = get_tree().create_tween()
			var platform = collision.get_collider().get_parent()
			tween.tween_property(platform,"position",Vector3(platform.position.x,-0.9,platform.position.z),0.5)
			queue_free()
			return
		if collision.get_collider().is_in_group("stone_platform"): 
			var liquid = ACID.instantiate()
			liquid.position = position
			get_parent().add_child(liquid)
			queue_free()
			return
		if collision.get_collider().is_in_group("pebble"):
			collision.get_collider().respawn()
			queue_free()
			return
		if  collision.get_collider().is_in_group("boulder"):
			collision.get_collider().queue_free()
			queue_free()
			return
	if speed<=0:
		queue_free()

func shoot(end):
	var height = end.y - global_position.y + HEIGHT_OF_ARC
	height = abs(height)
	var displacement_y = end.y-global_position.y
	var displacemnt_xz = Vector3(end.x-global_position.x,0,end.z-global_position.z)
	var velocity_y = Vector3.UP * sqrt(-2*gravity*height)
	var velocity_xz = displacemnt_xz/(sqrt(-2*height/gravity)+sqrt(2*(displacement_y-height)/gravity))
	velocity = velocity_y+velocity_xz
