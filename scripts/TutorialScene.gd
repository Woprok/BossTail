extends Node3D

var walls_down = false

func _process(delta):
	if not walls_down and get_node("Player").position.distance_to(get_node("Enemy").position)<=115:
		$walls.show()
		$AnimationPlayer.play("walls",2)
		walls_down=true


func _on_animation_finished(anim_name):
	if anim_name=="walls":
		$obstacles.show()
