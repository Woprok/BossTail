extends CharacterBody3D

var pos_index = 0
var time = 0
var thrown = false
var hitted = false

func _physics_process(delta):
	if thrown==false:
		if not is_on_floor():
			velocity.y = -10
		move_and_slide()
		time += delta
		if time>30:
			get_parent().get_parent().get_parent().num_of_crates[pos_index]-=1
			queue_free()
	else:
		move_and_slide()

func _on_body_entered(body):
	if body.is_in_group("player") and not thrown:
		body.hit(10)
		get_parent().get_parent().get_parent().num_of_crates[pos_index]-=1
		queue_free()


func _on_hit_body_entered(body):
	if body.is_in_group("player"):
		if body.position.y+0.1>=position.y+3*scale.y:
			queue_free()
		else:
			body.hit(5)
			queue_free()

func _on_hit_area_entered(area: Area3D) -> void:
	if area.is_in_group("spike") and not hitted:
		hitted = true
		queue_free()
