extends PlayerBase

var pushed = false
var time_of_push = 0

var part = 1
var reset_position_part2 = Vector3(-25, 1, 35)
var reset_position_part3 = Vector3(66.5, 1.82, 0.26)
var reset_position_part4 = Vector3(-26,1,-37)
	
func _ready() -> void:
	super._ready()
	$melee.connect("body_entered", _on_melee_body_entered)
	
func _exit_tree() -> void:
	$melee.disconnect("body_entered", _on_melee_body_entered)
	
func _physics_process(delta):
	var freeze = respawn_freeze(delta)
	#print(global_position)
	if position.y < -10:
		respawn()
		
	#time = time+ delta
	lastHit += delta
	last_shot += delta
	
	_handle_camera()
	
	if pushed:
		velocity.y = 0
		time_of_push += delta
		if time_of_push >= 1:
			time_of_push = 0
			pushed = false
		else:
			move_and_slide()
			return
	else:
		direction = Vector3.ZERO
		if Input.is_action_pressed("move_back") and not freeze:
			direction.z += 1
		if Input.is_action_pressed("move_forward") and not freeze:
			direction.z -= 1
		if Input.is_action_pressed("strafe_left") and not freeze:
			direction.x -= 1
		if Input.is_action_pressed("strafe_right") and not freeze:
			direction.x += 1
		
	if Input.is_action_just_pressed("dash") and can_dash and not fighting and not freeze:
		_start_dash()
		
	if dashing:
		$AnimationTree.dash_start()
		direction.z = -1
		speed = DASH_SPEED
	elif aiming:
		speed = AIM_SPEED
	else:
		speed = SPEED
		
	if Input.is_action_just_pressed("jump") and not freeze:
		jump_time = 0
		player_data.change_jump_height(delta)
		direction.y += 1
	if Input.is_action_pressed("jump") and not freeze:
		player_data.change_jump_height(delta*333)
		jump_time += delta
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
			target_velocity.y *= 1
		else:
			jump_time+=delta 
		
	if direction != Vector3.ZERO:
		$melee/target.disabled = true
		if not dashing:
			$AnimationTree.run()
		
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
		$AnimationTree.idle()
		$melee/target.disabled = true
	if velocity.y<0:
		if jump:
			$AnimationTree.jump_descending()
		else:
			$AnimationTree.falling()
	elif velocity.y>0:
		$AnimationTree.jump_start()
	move_and_slide()
	
	
func hit(_collision, health):
	if lastHit<1:
		return
	lastHit = 0
	player_data.player_decrease_health(health)
	$PlayerHitVFX.play_effect()
	if player_data.is_player_dead():
		respawn()
		player_data.player_restart()

func respawn():
	reset_player_respawn()
	
	var reset_position 
	if part == 2:
		reset_position = reset_position_part2
	if part == 3:
		reset_position = reset_position_part3
	if part == 4:
		reset_position = reset_position_part4
	pushed = false
	position = reset_position
	

func _on_animation_finished(anim_name):
	if anim_name == "GAME_05_lunge_right":
		$melee/target.disabled = true
		player_data.change_melee_indicator(true)
		$AnimationTree.idle()
		fighting = false
			
			
	if anim_name == "GAME_05_lunge_right_settle":
		melee = false
		$melee/target.disabled = true
		fighting=false
		player_data.change_melee_indicator(true)


# melee
func _on_area_entered(area):
	if area.get_parent().is_in_group("enemy") and not melee:
		melee = true
		area.get_parent().hit(area, 0)


func _on_dash_timer_timeout():
	dashing = false
	$dash_timer.stop()
	$next_dash_timer.start(1.5)


func _on_next_dash_timer_timeout():
	can_dash = true
	player_data.change_dash_indicator(true)	
	$next_dash_timer.stop()


func _on_melee_body_entered(body):
	if body.is_in_group("mini_dummy"):
		body.death()
	elif body.is_in_group("enemy"):
		body.hit(null, 10)



func _on_standing(area):
	if area.is_in_group("spike"):
		hit(null, 20)
		get_parent().respawn_player()
	if area.is_in_group("part2"):
		part = 3
		
		
func _on_leaving(_area):
	pass
