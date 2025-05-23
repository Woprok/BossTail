extends CharacterBody3D

var pos_index = 0
var time = 0
var thrown = false
var hitted = false
var dummy_box = false
var dummy_parent = null


func _physics_process(delta):
	time += delta
	if dummy_box:
		return
	if thrown==false:
		if not is_on_floor():
			velocity.y = -10
		move_and_slide()
		if time>30:
			get_parent().get_parent().get_parent().num_of_crates[pos_index]-=1
			queue_free()
	else:
		if time>30:
			queue_free()
		move_and_slide()

func _on_body_entered(body):
	if body.is_in_group("player") and not thrown and not dummy_box:
		body.hit(10)
		get_parent().get_parent().get_parent().num_of_crates[pos_index]-=1
		queue_free()


func _on_hit_body_entered(body):
	if body.is_in_group("player") and not dummy_box :
		if body.position.y+0.1>=position.y+3*scale.y:
			get_parent().addRock(position)
			queue_free()
		else:
			body.hit(5)
			get_parent().addRock(position)
			queue_free()
	if body.is_in_group("pebble"):
		if dummy_box:
			if dummy_parent.stopped:
				return 
			dummy_parent._on_box_hit(body)
		body.queue_free()
		queue_free()
	if body.is_in_group("box") and time>0.4:
		body.queue_free()

func _on_hit_area_entered(area: Area3D) -> void:
	if area.is_in_group("spike") and not hitted:
		hitted = true
		get_parent().addRock(position)
		queue_free()
