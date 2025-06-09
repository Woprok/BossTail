extends CharacterBody3D

@export var gravity:float = -9
@export var HEIGHT_OF_ARC:float = 4
@export var speed:float = 5
var collision_num = 0 
var collision_with_player = false
@export var ignore_collisions_time = 0.25

@onready var bubble_obj: Node3D = $Bubble
var antic_phase: bool = false
var popping: bool = false
@export var SplashVFX: PackedScene
var scale_tweener: Tween

func _physics_process(delta):
	if antic_phase or popping:
		return
		
	#align with velocity
#	look_at(self.position + velocity)
	
	velocity.y += speed*gravity*delta
	var collision: KinematicCollision3D = move_and_collide(speed*velocity*delta)
	
	if collision:
		if collision.get_collider().is_in_group("player") and not collision_with_player:
			collision_with_player = true
			collision_num += 1
			pop(collision.get_position(), true)
			collision.get_collider().push(collision.get_collider().position-position,3)
			collision.get_collider().hit(null, 5)
			return
		elif collision.get_collider().is_in_group("stone_platform") or collision.get_collider().is_in_group("lily_platform"):
			collision_num += 1
			pop(collision.get_position(), true)
		else:
			collision_num += 1
			pop(collision.get_position())
	else:
		if position.y<-10:
			queue_free()
	
	if ignore_collisions_time > 0:
		ignore_collisions_time -= delta
		if ignore_collisions_time <= 0:
			$CollisionShape3D.disabled = false
	
		

func pop(collision_pos: Vector3, create_puddle: bool = false):
	if collision_num == 1:
		popping = true
		self.rotation = Vector3.ZERO
		if scale_tweener != null:
			scale_tweener.kill()
		scale_tweener = create_tween()
		scale_tweener.tween_property(bubble_obj, "scale", Vector3(1.25, 0.75, 1.25), 0.05)
		scale_tweener.tween_callback(instantiate_splash_vfx.bind(create_puddle, collision_pos))
		
	pass

func instantiate_splash_vfx(create_puddle: bool, pos: Vector3):
	if SplashVFX != null:
			var splash_obj: PlayBubbleSplashOnStart = SplashVFX.instantiate()
			get_parent().add_child(splash_obj)
			splash_obj.scale = Vector3.ONE * 2.0
			splash_obj.global_position = pos + Vector3.UP * 0.1
			splash_obj.create_puddle = create_puddle
	queue_free()

func shoot(end):
	antic_phase = false
	var height = end.y - global_position.y + HEIGHT_OF_ARC
	height = abs(height)
	var displacement_y = end.y-global_position.y
	var displacemnt_xz = Vector3(end.x-global_position.x,0,end.z-global_position.z)
	var velocity_y = Vector3.UP * sqrt(-2*gravity*height)
	var velocity_xz = displacemnt_xz/(sqrt(-2*height/gravity)+sqrt(2*(displacement_y-height)/gravity))
	velocity = velocity_y+velocity_xz
	
	$CollisionShape3D.disabled = true
	
	#stretch
	scale_tweener = create_tween()
	scale_tweener.tween_property(bubble_obj, "scale", Vector3(0.9,0.9,1.15), 0.05)
	
func emerge():
	velocity.y = 8
