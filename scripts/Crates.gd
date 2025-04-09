extends CharacterBody3D

var pos_index = 0
var time = 0

func _physics_process(delta):
	if not is_on_floor():
		velocity.y = -10
	move_and_slide()
	time += delta
	if time>30:
		get_parent().get_parent().get_parent().num_of_crates[pos_index]-=1
		queue_free()


func _on_body_entered(body):
	if body.is_in_group("player"):
		body.hit(10)
		get_parent().get_parent().get_parent().num_of_crates[pos_index]-=1
		queue_free()
