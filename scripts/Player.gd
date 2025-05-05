extends CharacterBody3D

var Rock = preload("res://scenes/Rock.tscn")
var Fly = preload("res://scenes/Fly.tscn")

@export var player_data: PlayerDataModel = preload("res://data_resources/PlayerDataModelInstance.tres")
@export var platform: Node
@export var animation: AnimationTree
@onready var Camera = $CameraPivot/SpringArm3D/Camera3D
@onready var flies = get_parent().get_node("flies")
@onready var pebbles = get_parent().get_node("pebbles")

var start_position:Vector3 = Vector3(0,-1.8,0)
var pebble_count = 0
var fly_count = 0
@export var AMMO_CAPACITY = 3
@export var FLY_CAPACITY = 1

var speed:int = 15
var jump_speed:int = 30

var fall_acceleration:int = 75
var MOUSE_SENS:float = 0.008
var AIM_MOUSE_SENS:float = 0.004
var DASH_SPEED:int = 25
var AIM_SPEED:int = 5
var STICKY_SPEED:int = 2
var SPEED:int = 15
var back = -1
var lastHit = 100

var time:float = 0
var target_velocity:Vector3 = Vector3.ZERO
var mouse_sensitivity:float = 0.008
var melee:bool = false
var fighting:bool = false
var jump:bool = false
var dashing:bool = false
var can_dash:bool = true
var aiming:bool = false
var last_shot:float = 0
var aciding_liquid:int = 0
var grabbed: bool = false
var launched:bool = false
var direction = Vector3.ZERO

func _ready() -> void:
	player_data.player_restart()
	$CameraPivot.rotation.x = deg_to_rad(-8)	
	
func _physics_process(delta):
	time = time+ delta
	lastHit += delta
	if position.y<-3 or (is_on_floor() and position.y<-0.6):
		respawn()
	if grabbed:
		velocity.y += 2.5*-9*delta
		var collision = move_and_collide(2.5*velocity*delta)
		if velocity.y<0 and position.y<3:
			grabbed = false
		return
	
	last_shot += delta
	if Input.is_action_pressed("move_right"):
		rotate_y(-0.05)
	if Input.is_action_pressed("move_left"):
		rotate_y(0.05)
	
	if not launched:
		direction = Vector3.ZERO
	if Input.is_action_pressed("move_back") and not launched:
		direction.z += 1
	if Input.is_action_pressed("move_forward") and not launched:
		direction.z -= 1
	if Input.is_action_pressed("strafe_left") and not launched:
		direction.x -= 1
	if Input.is_action_pressed("strafe_right") and not launched:
		direction.x += 1
		
	if Input.is_action_just_pressed("dash") and can_dash:
		dashing = true
		player_data.change_dash_indicator(false)		
		can_dash = false
		$dash_timer.start(0.5)
		
	if dashing:
		animation.dash_start()
		direction.z -= 1
		speed = DASH_SPEED
	elif aiming:
		speed = AIM_SPEED
	elif aciding_liquid>0:
		speed = STICKY_SPEED
	else:
		speed = SPEED
		
	if Input.is_action_just_pressed("jump") and aciding_liquid == 0:
		player_data.change_jump_height(delta)
		direction.y += 1
	if Input.is_action_pressed("jump") and aciding_liquid == 0:
		player_data.change_jump_height(delta*333)
	if Input.is_action_just_released("jump"):
		player_data.change_jump_height(0)
		target_velocity.y *= 0.1
		
	if direction != Vector3.ZERO:
		fighting = false
		$melee/target.disabled = true
		if not dashing:
			if is_on_floor() and direction.y!=0:
				animation.jump_descending()
			elif is_on_floor():
				animation.run()
			else:
				animation.jump_descending()
		
	if last_shot > 0.5 and Input.is_action_pressed("aim"):
		player_data.change_ranged_indicator(true)
	else:
		player_data.change_ranged_indicator(false)
	if Input.is_action_pressed("fight"):
		if not aiming:
			$melee/target.disabled = false
			animation.lunge_r()
			fighting=true
			player_data.change_melee_indicator(false)
		elif last_shot>0.5:
			shoot()
			last_shot = 0
	elif Input.is_action_just_pressed("aim"):
		player_data.change_melee_indicator(false)
		player_data.change_ranged_indicator(true)
		aiming = true
		mouse_sensitivity = AIM_MOUSE_SENS
		speed = AIM_SPEED
		$CameraPivot/zoom.speed_scale = 3
		Camera.get_node("target").show()
		$CameraPivot/zoom.play("zoom")
	elif Input.is_action_just_released("aim"):
		player_data.change_melee_indicator(true)
		player_data.change_ranged_indicator(false)	
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
		target_velocity.y = 0
		
	# skok
	if direction.y>0 and jump==false:
		target_velocity.y = direction.y * jump_speed
		jump = true
	
	# pokud je ve vzduchu, spadne
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)

	velocity = target_velocity
	if not fighting and is_on_floor() and direction==Vector3.ZERO:
		animation.idle()
		$melee/target.disabled = true
	move_and_slide()
	
		
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		if Input.is_action_pressed("aim"):
			Camera.rotation.x -= event.relative.y * mouse_sensitivity
			Camera.rotation.x = clamp(Camera.rotation.x, deg_to_rad(-70), deg_to_rad(25))

func hit(health):
	if lastHit<1:
		return
	lastHit = 0
	player_data.player_decrease_health(health)
	if player_data.is_player_dead():
		animation.death()
		GameInstance.PlayerDefeated()

# strelba dle typu zbrane
func shoot():
	var p
	if fly_count==0 and pebble_count==0:
		return
	if fly_count>0:
		p = Fly.instantiate()
		flies.add_child(p)
		fly_count=0
	elif pebble_count > 0:
		p = Rock.instantiate()
		pebbles.add_child(p)
		pebble_count -= 1
		
	p.global_position = position-transform.basis.z
	p.velocity=-transform.basis.z
	
	var space_state = Camera.get_world_3d().direct_space_state
	var screen_center = get_viewport().size/2
	var origin = Camera.project_ray_origin(screen_center)
	var end = origin + Camera.project_ray_normal(screen_center)*1000
	
	var query = PhysicsRayQueryParameters3D.create(origin,end)
	query.collide_with_bodies = true
	var result = space_state.intersect_ray(query)
	
	p.shoot(origin, end, result)

func respawn():
	player_data.player_decrease_health(1)
	if launched:
		launched = false
		var min = INF
		for i in get_parent().get_node("stonePlatforms").get_children():
			if get_parent().get_node("frog").platform != i and min > i.position.distance_to(position):
				min = i.position.distance_to(position)
				platform = i
		if platform == null and Global.phase>1:
			platform = get_parent().get_node("lilyPlatforms/largeLily")
		position = platform.position
		position.y += 5
	else:
		if position.y>-3:
			for i in platform.neighbors:
				if i != null and i.is_in_group("stone_platform") and get_parent().get_node("frog").platform != i:
					platform = i
					break
				if i != null and i.is_in_group("lily_platform") and i.sinked == false:
					platform = i
					break
		position = platform.global_position
		position.y += 5
	
	
func launch(pos):
	launched=true
	direction= pos+Vector3(0,1,0)
	direction*=2.5
	

func _on_animation_finished(anim_name):
	if anim_name == "GAME_05_lunge_right":
		$melee/target.disabled = true
		player_data.change_melee_indicator(true)
		$AnimationTree.idle()
	if anim_name == "GAME_05_lunge_right_settle":
		melee = false
		$melee/target.disabled = true
		fighting=false
		player_data.change_melee_indicator(true)
		
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
	player_data.change_dash_indicator(true)	
	$next_dash_timer.stop()


func _on_melee_body_entered(body):
	if body.is_in_group("fly"):
		body.velocity.y = 1
		body.flying = false


func _on_pickup_entered(body):
	if body.is_in_group("fly") and body.dead and fly_count < FLY_CAPACITY:
		fly_count += 1
		body.queue_free()
	if body.is_in_group("pebble") and pebble_count < AMMO_CAPACITY:
		pebble_count += 1
		body.queue_free()


func _on_standing(area):
	if area.is_in_group("spike"):
		hit(5)
	if area.is_in_group("aciding_liquid"):
		launched = false
		grabbed = false
		aciding_liquid += 1
	if area.is_in_group("stone_platform") or area.is_in_group("lily_platform"):
		animation.jump_land()
		platform = area
		launched = false
		grabbed = false
		

func _on_leaving(area):
	if area.is_in_group("aciding_liquid"):
		aciding_liquid -= 1
