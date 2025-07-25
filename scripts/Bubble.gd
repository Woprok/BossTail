extends CharacterBody3D

var gravity:int = -9
var HEIGHT_OF_ARC:float = 1
var speed:float = 2.5
@export var splash_prefab: PackedScene

func _physics_process(delta):
	velocity.y += speed*gravity*delta
	var collision = move_and_collide(speed*velocity*delta)
	if collision:
		#play_hit sfx
		AudioClipManager.play("res://assets/audio/sfx/SpitSplash.wav", 0.5)
		
		if collision.get_collider().is_in_group("player"):
			if collision.get_collider().platform and (collision.get_collider().platform.is_in_group("stone_platform") or collision.get_collider().platform.is_in_group("big_lily")):
				find_ground_position(collision.get_position(),collision.get_collider())
			collision.get_collider().hit(collision.get_collider_shape(), 5)
			queue_free()
			return
		if collision.get_collider().is_in_group("stone_platform") or collision.get_collider().get_parent().is_in_group("big_lily"): 
			instantiate_splash(collision.get_position(), true)
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
		if collision.get_collider().is_in_group("player_projectile"):
			instantiate_splash(collision.get_position())
			collision.get_collider().respawn()
			queue_free()
			return
		if  collision.get_collider().is_in_group("boulder"):
			instantiate_splash(collision.get_position())
			collision.get_collider().queue_free()
			queue_free()
			return
		queue_free()
	if speed<=0 or position.y<-10:
		queue_free()
		
	look_at(self.position + velocity)

func instantiate_splash(splash_pos: Vector3, create_puddle: bool = false):
	var splash: PlayBubbleSplashOnStart = splash_prefab.instantiate()
	get_parent().add_child(splash)
	splash.global_position = splash_pos
	if create_puddle:
		splash.create_puddle = true

func find_ground_position(hit_position,collider):
	var space_state = get_world_3d().direct_space_state
	var ray_params = PhysicsRayQueryParameters3D.new()
	ray_params.from = hit_position
	ray_params.to = hit_position + Vector3.DOWN * 100.0
	ray_params.collision_mask = 1
	ray_params.exclude = [self,collider]
	
	var result = space_state.intersect_ray(ray_params)

	if result:
		var ground_position = result.position
		instantiate_splash(ground_position)

func shoot(end):
	var height = end.y - global_position.y + HEIGHT_OF_ARC
	height = abs(height)
	var displacement_y = end.y-global_position.y
	var displacemnt_xz = Vector3(end.x-global_position.x,0,end.z-global_position.z)
	var velocity_y = Vector3.UP * sqrt(-2*gravity*height)
	var velocity_xz = displacemnt_xz/(sqrt(-2*height/gravity)+sqrt(2*(displacement_y-height)/gravity))
	velocity = velocity_y+velocity_xz
