extends PlayerBase

var Fly = preload("res://scenes/Fly.tscn")

@export var platform: Node
@export var animation: AnimationTree
@onready var flies = get_parent().get_node("flies")

var start_position:Vector3 = Vector3(0,-1.8,0)

var STICKY_SPEED:int = 2

var aciding_liquid:int = 0
var grabbed: bool = false
var launched:bool = false
var push_start_position = Vector3.ZERO
var push_length = 0
var grab_target_position = Vector3.ZERO

@export_group("VFX")
@export var PlayerHitVFX: EntityHitVFX
	
func _physics_process(delta):
#	time = time+ delta
	var freeze = respawn_freeze(delta)
	
	lastHit += delta
	if spike_hit:
		hit(null, 1)
	
	if launched and push_length!=0 and push_start_position.distance_to(position) >= push_length:
		launched = false
		direction = Vector3.ZERO
		push_length = 0
	
	if launched and grab_target_position!=Vector3.ZERO and grab_target_position.distance_to(position)<3:
		animation.idle()
		launched = false
		direction = Vector3.ZERO
		grab_target_position = Vector3.ZERO
	
	if position.y<-3 or (is_on_floor() and position.y<-0.6):
		respawn()
		
	if grabbed:
		velocity.y += 2.5*-9*delta
		var _collision = move_and_collide(2.5*velocity*delta)
		if velocity.y<0 and position.y<3:
			grabbed = false
		return
	
	last_shot += delta
	
	_handle_camera()
	
	if not launched:
		direction = Vector3.ZERO
	if Input.is_action_pressed("move_back") and not launched and not freeze:
		direction.z += 1
	if Input.is_action_pressed("move_forward") and not launched and not freeze:
		direction.z -= 1
	if Input.is_action_pressed("strafe_left") and not launched and not freeze:
		direction.x -= 1
	if Input.is_action_pressed("strafe_right") and not launched and not freeze:
		direction.x += 1
		
	if Input.is_action_just_pressed("dash") and can_dash and not fighting and not freeze:
		_start_dash()
		
	if dashing:
		#animation.dash_start()
		direction.z = -1
		speed = DASH_SPEED
	elif aiming:
		speed = AIM_SPEED
	elif aciding_liquid>0:
		speed = STICKY_SPEED
	else:
		speed = SPEED
		
	if Input.is_action_just_pressed("jump") and aciding_liquid == 0 and not freeze:
		jump_time = 0
		player_data.change_jump_height(delta)
		direction.y += 1
		
		#jump audio sfx
		AudioClipManager.play("res://assets/audio/sfx/Jump.wav")
		
	if Input.is_action_pressed("jump") and aciding_liquid == 0 and not freeze:
		jump_time += delta
		player_data.change_jump_height(delta*333)
	if Input.is_action_just_released("jump") and not freeze:
		player_data.change_jump_height(0)
		
		if jump_time>=0.7:
			target_velocity.y *= 0.1
			jump_time = 0
		else:
			target_velocity.y *= 0.7
			
	if not Input.is_action_pressed("jump") and jump_time != 0 and not freeze:
		if jump_time>=0.7:
			jump_time = 0
			target_velocity.y *= 0.1
		else:
			jump_time+=delta 
			
	if direction != Vector3.ZERO:
		$melee/target.disabled = true
		if not dashing:
			animation.run()
		
	if last_shot > 0.5 and Input.is_action_pressed("aim") and not freeze:
		player_data.change_ranged_indicator(true)
	elif last_shot > 0.5:
		player_data.change_melee_indicator(true)
	else:
		player_data.change_ranged_indicator(false)

	if Input.is_action_pressed("fight") and is_on_floor() and direction == Vector3.ZERO and not freeze:
		if not aiming:
			if last_shot > 0.75:
				last_shot = 0
				_stab_started()
		elif last_shot > 0.75:
			shoot()
			last_shot = 0
	elif Input.is_action_just_pressed("aim") and not freeze:
		_aim_started()

	elif Input.is_action_just_released("aim") and not freeze:
		_aim_finished()
	
	var movement_dir = null
	if launched:
		movement_dir = Vector3(direction.x, 0, direction.z)
	else:
		movement_dir = transform.basis * Vector3(direction.x, 0, direction.z)
	
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
		
	if velocity.y<0:
		if jump:
			animation.jump_descending()
		else:
			animation.falling()
	elif velocity.y>0:
		animation.jump_start()
	move_and_slide()
		

func hit(_collision, health):
	if lastHit<1 and health==1:
		return
	lastHit = 0
	player_data.player_decrease_health(health)
	if player_data.is_player_dead():
		animation.death()
		GameInstance.PlayerDefeated()
	if PlayerHitVFX != null:
		PlayerHitVFX.play_effect()
		
	#hit impact sfx
	AudioClipManager.play("res://assets/audio/sfx/HitImpact.wav")

func respawn():
	reset_player_respawn()
	
	player_data.player_decrease_health(1)
	if launched:
		launched = false
		var min_respawn_pos = INF
		for i in get_parent().get_node("stonePlatforms").get_children():
			if get_parent().get_node("frog").platform != i and min_respawn_pos > i.position.distance_to(position):
				min_respawn_pos = i.position.distance_to(position)
				platform = i
		if platform == null and Global.phase>1:
			platform = get_parent().get_node("lilyPlatforms/largeLily")
		position = platform.position
		position.y += 5
	else:
		if get_parent().get_node("frog").platform == platform or position.y>-3:
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
	launched = true
	direction = pos+Vector3(0,1,0)
	direction *= 1.8

func push(dir:Vector3, push_len:float):
	dir.y = 0
	launched = true
	push_start_position = position
	push_length = push_len
	direction = dir.normalized()

func grab(dir, target_position):
	dir.y = 0
	launched = true
	grab_target_position = target_position
	direction = dir.normalized()

func _on_animation_finished(anim_name):
	if anim_name == "GAME_05_lunge_right" or anim_name == "GAME_05_lunge_left_combo":
		#$melee/target.disabled = false
		#player_data.change_melee_indicator(true)
		$AnimationTree.idle()
		#fighting = false
		
	if anim_name == "GAME_05_lunge_right_settle" or anim_name == "GAME_05_lunge_left_settle":
		melee = false
		$melee/target.disabled = true
		fighting=false
		player_data.change_melee_indicator(true)
		
# melee
func _on_area_entered(area):
	if area.get_parent().is_in_group("enemy") and not melee:
		melee = true
		area.get_parent().hit(area, 0)
		#melee hit sfx
		AudioClipManager.play("res://assets/audio/sfx/StabHit.mp3")
	
	if area.get_parent()!=null and area.get_parent().is_in_group("fly"):
		area.get_parent().call_deferred("enable_collision")
		area.get_parent().velocity.y = 1
		area.get_parent().flying = false


func _on_dash_timer_timeout():
	dashing = false
	$dash_timer.stop()
	$next_dash_timer.start(1.5)


func _on_next_dash_timer_timeout():
	can_dash = true
	player_data.change_dash_indicator(true)	
	$next_dash_timer.stop()


func _on_pickup_entered(body):
	if body.is_in_group("fly") and body.dead and player_data.ammo_special.can_pick():
		player_data.player_ammo_picked(true)
		body.queue_free()
	super._on_pickup_entered(body)


func _on_standing(area):
	if area.is_in_group("spike"):
		hit(null, 5)
		spike_hit = true
	if area.is_in_group("aciding_liquid"):
		launched = false
		grabbed = false
		aciding_liquid += 1
	if area.is_in_group("stone_platform") or area.is_in_group("lily_platform"):
		animation.jump_land()
		#land sfx
		AudioClipManager.play("res://assets/audio/sfx/Land.wav", 0.5)
		
		platform = area
		launched = false
		grabbed = false
		
func _on_leaving(area):
	if area.is_in_group("aciding_liquid"):
		aciding_liquid -= 1
	if area.is_in_group("spike"):
		spike_hit = false
	if area.is_in_group("boulder"):
		collision_mask &= ~(1 << 4)

func _on_frog_standing(area: Area3D) -> void:
	if area.is_in_group("body") and area.get_parent().is_in_group("enemy"):
		var away = (global_position - area.get_parent().global_position).normalized()
		launched = true
		direction = away
		direction.y = 0.2

func _on_body_standing(body: Node3D) -> void:
	if body.is_in_group("boulder"):
		collision_mask |= 1 << 4
