extends CharacterBody3D

var Projectile = preload("res://scenes/projectile.tscn")
var Rock = preload("res://scenes/rock.tscn")

@onready var Camera = $CameraPivot/SpringArm3D/Camera3D
var start_position:Vector3 = Vector3(0,-1.8,0)
var weapon_type:int = 1

var speed:int = 10
var jump_speed:int = 20

var fall_acceleration:int = 75
var MOUSE_SENS:float = 0.008
var AIM_MOUSE_SENS:float = 0.004
var DASH_SPEED:int = 30
var AIM_SPEED:int = 5
var SPEED:int = 10

var target_velocity:Vector3 = Vector3.ZERO
var mouse_sensitivity:float = 0.008
var double_jump:bool = false
var dashing:bool = false
var can_dash:bool = true
var aiming:bool = false
var last_shot:float = 0
var world

func _ready():
	$CameraPivot.rotation.x = deg_to_rad(-8)	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	world = get_node("../")
	
func _physics_process(delta):
	last_shot += delta
	var direction = Vector3.ZERO
	var jump = false
	if Input.is_action_pressed("move_right"):
		rotate_y(-0.05)
	if Input.is_action_pressed("move_left"):
		rotate_y(0.05)
		
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if Input.is_action_pressed("strafe_left"):
		direction.x -= 1
	if Input.is_action_pressed("strafe_right"):
		direction.x += 1
	
	if Input.is_action_just_pressed("crouch"):
		#crouch
		pass
	if Input.is_action_just_released("crouch"):
		#stand up	
		pass
		
	if Input.is_action_just_pressed("dash") and can_dash:
		dashing = true
		can_dash = false
		$dash_timer.start(0.5)
		
	if dashing:
		direction.z -= 1
		speed = DASH_SPEED
	else:
		speed = SPEED
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		
	if Input.is_action_just_pressed("jump"):
		direction.y += 1
	if Input.is_action_just_released("jump") and target_velocity.y>0:
		target_velocity.y *= 0.1
	var movement_dir = transform.basis * Vector3(direction.x, 0, direction.z)
	
	# pohyb po zemi
	target_velocity.x = movement_dir.x * speed
	target_velocity.z = movement_dir.z * speed
	
	# skok
	if is_on_floor():
		target_velocity.y = direction.y * jump_speed
		double_jump = false
	elif direction.y>0 and not is_on_floor() and double_jump == false:
		double_jump = true
		target_velocity.y = direction.y * speed	* 2	
	
	# pokud je ve vzduchu, spadne
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)

	velocity = target_velocity
	move_and_slide()
	
	if Input.is_action_pressed("fight"):
		if not aiming:
			$animation.play("melee",-1, 6)
		elif last_shot>0.5:
			shoot()
			last_shot = 0
	elif Input.is_action_just_pressed("aim"):
		aiming = true
		mouse_sensitivity = AIM_MOUSE_SENS
		speed = AIM_SPEED
		$CameraPivot/zoom.speed_scale = 3
		Camera.get_node("target").show()
		$CameraPivot/zoom.play("zoom")
	elif Input.is_action_just_released("aim"):
		aiming = false
		mouse_sensitivity = MOUSE_SENS
		speed = SPEED
		Camera.get_node("target").hide()
		$CameraPivot/zoom.speed_scale = 1
		Camera.rotation.x = deg_to_rad(-20)
		$CameraPivot/zoom.play_backwards("zoom")	
		
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		if Input.is_action_pressed("aim"):
			Camera.rotation.x -= event.relative.y * mouse_sensitivity
			Camera.rotation.x = clamp(Camera.rotation.x, deg_to_rad(-70), deg_to_rad(25))

func hit(area):
	if area.is_in_group("hp1"):
		$health/health_bar_3d.decHealth(1)
	if area.is_in_group("hp5"):
		$health/health_bar_3d.decHealth(5)
	if area.is_in_group("hp10"):
		$health/health_bar_3d.decHealth(10)
	if $health/health_bar_3d.health<=0:
		#death
		pass

# strelba dle typu zbrane
func shoot():
	var p
	if weapon_type == 0:
		p = Projectile.instantiate()
	if weapon_type == 1:
		p = Rock.instantiate()
	world.add_child(p)
	p.position = position-transform.basis.z
	p.velocity=-transform.basis.z
	
	var space_state = Camera.get_world_3d().direct_space_state
	var screen_center = get_viewport().size/2
	var origin = Camera.project_ray_origin(screen_center)
	var end = origin + Camera.project_ray_normal(screen_center)*1000
	
	var query = PhysicsRayQueryParameters3D.create(origin,end)
	query.collide_with_bodies = true
	var result = space_state.intersect_ray(query)
	
	p.shoot(origin, end, result)

func _on_animation_finished(anim_name):
	if anim_name == "melee":
		$animation.play("RESET")


# melee
func _on_area_entered(area):
	if area.get_parent().is_in_group("enemy"):
		area.get_parent().hit(area)


func _on_dash_timer_timeout():
	dashing = false
	$dash_timer.stop()
	$next_dash_timer.start(1.5)


func _on_next_dash_timer_timeout():
	can_dash = true
	$next_dash_timer.stop()
