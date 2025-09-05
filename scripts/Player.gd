extends PlayerBase

@export var platform: Node
@export var animation: AnimationTree

var start_position:Vector3 = Vector3(0,-1.8,0)

var STICKY_SPEED:int = 2

var aciding_liquid:int = 0
var launched:bool = false
var push_start_position = Vector3.ZERO
var push_length = 0
var grab_target_position = Vector3.ZERO

@export_group("VFX")
@export var PlayerHitVFX: EntityHitVFX
	
func _physics_process(delta):
	var freeze = respawn_freeze(delta)
	
	update_timers(delta)
	handle_spike_hit()
	
	if launched:
		handle_launch()
	
	check_respawn_conditions()
	_handle_camera()
	handle_movement()
		
	update_speed()
	
	update_character_facing()
	handle_jump_input(delta)
	
	update_attack_indicators()
	handle_attack_input()
	
	handle_animations()
	move(delta)
	

func hit(_collision, health):
	if last_hit<1 and health==1:
		return
	last_hit = 0
	player_data.player_decrease_health(health)
	if player_data.is_player_dead():
		animation.death()
		GameInstance.PlayerDefeated()
	if PlayerHitVFX != null:
		PlayerHitVFX.play_effect()
		
	#hit impact sfx
	AudioClipManager.play("res://assets/audio/sfx/HitImpact.wav")

func handle_spike_hit():
	if spike_hit:
		hit(null, 1)
		
func handle_launch():
	if push_length!=0 and push_start_position.distance_to(position) >= push_length:
		launched = false
		direction = Vector3.ZERO
		push_length = 0
	
	if grab_target_position!=Vector3.ZERO and grab_target_position.distance_to(position)<3:
		animation.idle()
		launched = false
		direction = Vector3.ZERO
		grab_target_position = Vector3.ZERO
	if aiming:
		_aim_finished()

	
func can_move():
	return controls and not launched and not fighting and not freeze

	
func handle_movement():
	if not launched:
		direction = Vector3.ZERO
	if can_move():
		movement_input()
	direction = direction.normalized()


func handle_jump_input(delta):
	if Input.is_action_just_pressed("jump") and controls and aciding_liquid == 0 and not freeze:
		jump_time = 0
		player_data.change_jump_height(delta)
		direction.y += 1
		
		#jump audio sfx
		AudioClipManager.play("res://assets/audio/sfx/Jump.wav")
		
	if Input.is_action_pressed("jump") and controls and aciding_liquid == 0 and not freeze:
		jump_time += delta
		player_data.change_jump_height(delta*333)
	if Input.is_action_just_released("jump") and controls and not freeze:
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


func check_respawn_conditions():
	if position.y<-3 or (is_on_floor() and position.y<-0.6):
		respawn()
		
		
func update_speed():
	if dashing:
		direction = - $Char_Mouseketeer_Rig.transform.basis.z.normalized()
		speed = DASH_SPEED
	elif aiming:
		speed = AIM_SPEED
	elif aciding_liquid>0:
		speed = STICKY_SPEED
	else:
		speed = SPEED

func move(delta):
	var movement_dir = null
	if launched:
		movement_dir = Vector3(direction.x, 0, direction.z)
	else:
		movement_dir = transform.basis * Vector3(direction.x, 0, direction.z)
	# floor movement
	target_velocity.x = movement_dir.x * speed
	target_velocity.z = movement_dir.z * speed
	update_position(delta)


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
		if platform == null:
			platform = get_parent().find_child("LeafBoat")
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
	# melee attack against fly
	if area.get_parent() != null and area.get_parent().is_in_group("fly"):
		area.get_parent().hit(self, 5)
		#AudioClipManager.play("res://assets/audio/sfx/StabHit.mp3")
	# melee attack against swarm
	if area != null and area.is_in_group("swarm"):
		area.hit(self, 5)
		AudioClipManager.play("res://assets/audio/sfx/StabHit.mp3")

func _on_standing(area):
	if area.is_in_group("spike"):
		hit(null, 5)
		spike_hit = true
	if area.is_in_group("aciding_liquid"):
		launched = false
		aciding_liquid += 1
	if area.is_in_group("stone_platform") or area.is_in_group("lily_platform"):
		#land sfx
		AudioClipManager.play("res://assets/audio/sfx/Land.wav", 0.5)
		
		platform = area
		launched = false
		
		
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
