extends CharacterBody3D

var gravity:int = -9
var HEIGHT_OF_ARC:float = 1
var speed:float = 2.5
@export var splash_prefab: PackedScene

func _physics_process(delta):
	velocity.y += speed*gravity*delta
	var collision = move_and_collide(speed*velocity*delta)
	if collision:
		if collision.get_collider().is_in_group("player"):
			if collision.get_collider().platform.is_in_group("stone_platform"):
				instantiate_splash(collision.get_position()-Vector3(0,0.5,0))
			collision.get_collider().hit(5)
			queue_free()
			return
		if collision.get_collider().is_in_group("lily_platform"):
			#instantiate_splash(collision.get_position())
			if collision.get_collider().get_parent().name=="largeLily":
				queue_free()
				return
			var tween = get_tree().create_tween()
			var platform = collision.get_collider().get_parent()
			tween.tween_property(platform,"position",Vector3(platform.position.x,-0.9,platform.position.z),0.5)
			queue_free()
			return
		if collision.get_collider().is_in_group("stone_platform"): 
			instantiate_splash(collision.get_position(), true)
			queue_free()
			return
		if collision.get_collider().is_in_group("pebble"):
			instantiate_splash(collision.get_position())
			collision.get_collider().respawn()
			queue_free()
			return
		if  collision.get_collider().is_in_group("boulder"):
			instantiate_splash(collision.get_position())
			collision.get_collider().queue_free()
			queue_free()
			return
	if speed<=0:
		queue_free()
		
	look_at(self.position + velocity)

func instantiate_splash(splash_pos: Vector3, create_puddle: bool = false):
	var splash: PlayBubbleSplashOnStart = splash_prefab.instantiate()
	get_parent().add_child(splash)
	splash.global_position = splash_pos
	if create_puddle:
		splash.create_puddle = true

func shoot(end):
	var height = end.y - global_position.y + HEIGHT_OF_ARC
	height = abs(height)
	var displacement_y = end.y-global_position.y
	var displacemnt_xz = Vector3(end.x-global_position.x,0,end.z-global_position.z)
	var velocity_y = Vector3.UP * sqrt(-2*gravity*height)
	var velocity_xz = displacemnt_xz/(sqrt(-2*height/gravity)+sqrt(2*(displacement_y-height)/gravity))
	velocity = velocity_y+velocity_xz
