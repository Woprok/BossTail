extends CharacterBody3D

var Rock = preload("res://scenes/Rock.tscn")
var Fly = preload("res://scenes/Fly.tscn")

@export var platform: Node
@onready var Camera = $CameraPivot/SpringArm3D/Camera3D
@onready var ui = $health/ui
@onready var flies = get_parent().get_node("flies")
@onready var pebbles = get_parent().get_node("pebbles")

var start_position:Vector3 = Vector3(0,-1.8,0)
var weapon_type:int = -1

var speed:int = 10
var jump_speed:int = 22

var fall_acceleration:int = 75
var MOUSE_SENS:float = 0.008
var AIM_MOUSE_SENS:float = 0.004
var DASH_SPEED:int = 25
var AIM_SPEED:int = 5
var STICKY_SPEED:int = 2
var SPEED:int = 10
var back = -1

var time:float = 0
var target_velocity:Vector3 = Vector3.ZERO
var mouse_sensitivity:float = 0.008
var melee:bool = false
var fighting:bool = false
var jump:bool = false
var double_jump:bool = false
var dashing:bool = false
var can_dash:bool = true
var aiming:bool = false
var last_shot:float = 0
var aciding_liquid:int = 0
var launched:bool = false
var direction = Vector3.ZERO


func _ready():
	$CameraPivot.rotation.x = deg_to_rad(-8)	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
func _physics_process(delta):
	time = time+ delta
	if position.y<-3 or (is_on_floor() and position.y<-0.6):
		respawn()
	last_shot += delta
	if Input.is_action_pressed("move_right"):
		rotate_y(-0.05)
	if Input.is_action_pressed("move_left"):
		rotate_y(0.05)
	
	if not launched:
		direction = Vector3.ZERO
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if Input.is_action_pressed("strafe_left"):
		direction.x -= 1
	if Input.is_action_pressed("strafe_right"):
		direction.x += 1
		
	if Input.is_action_just_pressed("dash") and can_dash:
		dashing = true
		ui.change_dash_indicator(false)		
		can_dash = false
		$dash_timer.start(0.5)
		
	if dashing:
		direction.z -= 1
		speed = DASH_SPEED
	elif aiming:
		speed = AIM_SPEED
	elif aciding_liquid>0:
		speed = STICKY_SPEED
	else:
		speed = SPEED
#	if direction != Vector3.ZERO:
#		direction = direction.normalized()
		
	if Input.is_action_just_pressed("jump") and aciding_liquid == 0:
		ui.change_jump_height(delta)
		direction.y += 1
	if Input.is_action_pressed("jump") and aciding_liquid == 0:
		ui.change_jump_height(delta*333)		
	if Input.is_action_just_released("jump"):
		ui.change_jump_height(0)
		target_velocity.y *= 0.1
		
	if direction != Vector3.ZERO:
		fighting = false
		$melee/target.disabled = true
		if is_on_floor() and direction.y!=0:
			$AnimationPlayer.play("GAME_03_jump_start")
		elif is_on_floor():
			$AnimationPlayer.play("GAME_02_run")
		else:
			$AnimationPlayer.play("GAME_03_jump_looping")
		
	if last_shot > 0.5 and Input.is_action_pressed("aim"):
		ui.change_ranged_indicator(true)
	else:
		ui.change_ranged_indicator(false)
	if Input.is_action_pressed("fight"):
		if not aiming:
			$melee/target.disabled = false
			$AnimationPlayer.play("GAME_05_lunge_right")
			fighting=true
			ui.change_melee_indicator(false)
		elif last_shot>0.5:
			shoot()
			last_shot = 0
	elif Input.is_action_just_pressed("aim"):
		ui.change_melee_indicator(false)
		ui.change_ranged_indicator(true)
		aiming = true
		mouse_sensitivity = AIM_MOUSE_SENS
		speed = AIM_SPEED
		$CameraPivot/zoom.speed_scale = 3
		Camera.get_node("target").show()
		$CameraPivot/zoom.play("zoom")
	elif Input.is_action_just_released("aim"):
		ui.change_melee_indicator(true)
		ui.change_ranged_indicator(false)	
		aiming = false
		mouse_sensitivity = MOUSE_SENS
		speed = SPEED
		Camera.get_node("target").hide()
		$CameraPivot/zoom.speed_scale = 1
		Camera.rotation.x = deg_to_rad(-20)
		$CameraPivot/zoom.play_backwards("zoom")	
		
	var movement_dir = transform.basis * Vector3(direction.x, 0, direction.z)
	
	# pohyb po zemi
	target_velocity.x = movement_dir.x * speed
	target_velocity.z = movement_dir.z * speed
	
	if is_on_floor():
		jump = false
		double_jump = false
		
	# skok
	if direction.y>0 and jump==false and not double_jump:
		target_velocity.y = direction.y * jump_speed
		jump = true
	elif direction.y>0 and not is_on_floor() and double_jump == false:
		double_jump = true
		target_velocity.y = direction.y * speed	* 2	
	
	# pokud je ve vzduchu, spadne
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)

	velocity = target_velocity
	if not fighting and is_on_floor() and direction==Vector3.ZERO:
		$AnimationPlayer.play("GAME_01_idle")
		$melee/target.disabled = true
	move_and_slide()
	
		
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		if Input.is_action_pressed("aim"):
			Camera.rotation.x -= event.relative.y * mouse_sensitivity
			Camera.rotation.x = clamp(Camera.rotation.x, deg_to_rad(-70), deg_to_rad(25))

func hit(area):
	if area.is_in_group("hp1"):
		ui.get_node("health_player").decHealth(1)
	if area.is_in_group("hp5"):
		ui.get_node("health_player").decHealth(5)
	if area.is_in_group("hp10"):
		ui.get_node("health_player").decHealth(10)
	if ui.get_node("health_player").health<=0:
		#death
		pass

# strelba dle typu zbrane
func shoot():
	var p
	if weapon_type == -1:
		return
	if weapon_type == 0:
		p = Rock.instantiate()
		pebbles.add_child(p)
	if weapon_type == 1:
		p = Fly.instantiate()
		flies.add_child(p)
		
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
	weapon_type = -1

func respawn():
	ui.get_node("health_player").decHealth(1)
	if launched:
		launched = false
		var min = INF
		for i in get_parent().get_node("stonePlatforms").get_children():
			if get_parent().get_node("frog").platform != i and min > i.position.distance_to(position):
				min = i.position.distance_to(position)
				platform = i
		position = platform.position
		position.y += 5
	else:
		if position.y>-3:
			for i in platform.neighbors:
				if i.is_in_group("stone_platform") and get_parent().get_node("frog").platform != i:
					platform = i
					break
				if i.is_in_group("lily_platform") and i.sinked == false:
					platform = i
					break
		position = platform.position
		position.y += 5
	
	
func launch(pos):
	launched=true
	direction= pos+Vector3(0,1,0)
	direction*=2.5
	

func _on_animation_finished(anim_name):
	if anim_name == "GAME_05_lunge_right":
		if back == 1:
			back *= -1
			melee = false
			$melee/target.disabled = true
			fighting=false
			ui.change_melee_indicator(true)
		else:
			back *= -1
			$AnimationPlayer.play_backwards("GAME_05_lunge_right")

# melee
func _on_area_entered(area):
	if area.get_parent().is_in_group("enemy") and not melee:
		melee = true
		area.get_parent().hit(area)


func _on_dash_timer_timeout():
	dashing = false
	$dash_timer.stop()
	$next_dash_timer.start(1.5)


func _on_next_dash_timer_timeout():
	can_dash = true
	ui.change_dash_indicator(true)	
	$next_dash_timer.stop()


func _on_melee_body_entered(body):
	if body.is_in_group("fly"):
		body.velocity.y = 1
		body.flying = false


func _on_pickup_entered(body):
	if body.is_in_group("fly") and body.dead:
		weapon_type = 1
		body.queue_free()
	if body.is_in_group("pebble"):
		weapon_type = 0
		body.queue_free()


func _on_standing(area):
	launched = false
	if area.is_in_group("aciding_liquid"):
		aciding_liquid += 1
	if area.is_in_group("stone_platform") or area.is_in_group("lily_platform"):
		$AnimationPlayer.play_backwards("GAME_03_jump_start")
		platform = area


func _on_leaving(area):
	if area.is_in_group("aciding_liquid"):
		aciding_liquid -= 1
