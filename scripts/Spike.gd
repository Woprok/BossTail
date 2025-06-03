extends StaticBody3D


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and Global.phase == 0:
		body.hit(null, 20)
	elif body.is_in_group("player"):
		body.hit(null,5)
		body.spike_hit = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.spike_hit = false
