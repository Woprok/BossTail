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
	
	if position.y < -10:
		respawn()
		
	update_timers(delta)
	
	_handle_camera()
	
	if handle_push(delta): return
	handle_movement()
	update_speed()
	
	update_character_facing()
	handle_jump_input(delta)
		
	update_attack_indicators()
	handle_attack_input()
	handle_animations()
		
	move(delta)
	

func can_move():
	return not freeze and not fighting and not pushed
	
func move(delta):
	var movement_dir = transform.basis * Vector3(direction.x, 0, direction.z)
	# floor movement
	target_velocity.x = movement_dir.x * speed
	target_velocity.z = movement_dir.z * speed
	update_position(delta)
	
	
func handle_movement():
	direction = Vector3.ZERO
	if can_move():
		movement_input()
	direction = direction.normalized()

func handle_push(delta):
	if pushed:
		velocity.y = 0
		time_of_push += delta
		if time_of_push >= 1:
			time_of_push = 0
			pushed = false
		else:
			move_and_slide()
			return true
	return false


func hit(_collision, health):
	if last_hit<1:
		return
	last_hit = 0
	player_data.player_decrease_health(health)
	$PlayerHitVFX.play_effect()
	if player_data.is_player_dead():
		respawn()
		player_data.player_restart()
	#sfx
	AudioClipManager.play("res://assets/audio/sfx/HitImpact.wav")

func reset_player() -> void:
	player_data.player_increase_health(100)
	respawn()

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

func _on_melee_body_entered(body):
	if body.is_in_group("mini_dummy"):
		body.death()
		AudioClipManager.play("res://assets/audio/sfx/StabHit.mp3")
	elif body.is_in_group("enemy"):
		body.hit(null, 10)
		AudioClipManager.play("res://assets/audio/sfx/StabHit.mp3")

func _on_standing(area):
	if area.is_in_group("spike"):
		hit(null, 20)
		reset_player()
	else:
		#land sfx
		AudioClipManager.play("res://assets/audio/sfx/Land.wav")
	if area.is_in_group("part2"):
		player_data.player_increase_health(100)
		part = 3
		
		
func _on_leaving(_area):
	pass
