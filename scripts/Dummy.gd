extends CharacterBody3D

var time_length:float = 5
var direction:Vector3 = Vector3.ZERO
var speed:int = 3
var fall_acceleration:int = 75
#var projectile = preload("res://scenes/projectile.tscn")
#var target_position

func _physics_process(delta):
	time_length+=delta
	#kazdych 5 vterin vygeneruje jiny smer, kterym pujde
	if time_length>5:
		direction = Vector3(randf_range(-1,1), direction.y, randf_range(-1,1))
		direction.normalized()
		time_length = 0
	velocity = direction * speed
	# pokud je ve vzduchu, spadne na zem
	if not is_on_floor():
		velocity.y = velocity.y - (fall_acceleration * delta)*speed
	look_at(position-direction)
	move_and_slide()
	
# v zavislosti na miste trefeni se odecte 1-10
func hit(area):
	if area.is_in_group("hp1"):
		$health/health_bar_3d.decHealth(1)
	if area.is_in_group("hp5"):
		$health/health_bar_3d.decHealth(5)
	if area.is_in_group("hp10"):
		$health/health_bar_3d.decHealth(10)
	if $health/health_bar_3d.health<=0:
		$AnimationPlayer.play("death")


func _on_animation_finished(anim_name):
	if anim_name == "death":
		queue_free()


func _on_aim_timeout():
	pass
	#target_position = get_parent().get_node("Player").global_position
	#look_at(target_position)
	#Global.show_indicator(get_parent().get_node("Player"))
	#$shoot.start()

func _on_shoot_timeout():
	pass
	#var p = projectile.instantiate()
	#get_parent().add_child(p)
	#p.position = position+transform.basis.z	
	#look_at(target_position)
	#var result = true
	#p.shoot(position, target_position,  false)
	#Global.hide_indicator()
	#$shoot.stop()

