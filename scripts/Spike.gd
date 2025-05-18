extends StaticBody3D


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and Global.phase == 0:
		body.hit(20)
		body.get_parent().respawn_player()
