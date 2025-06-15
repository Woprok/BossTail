extends RigidBody3D

@export var SPEED_BOULDER = 18

func _physics_process(_delta):
	if position.y<6 and position.y>5:
		linear_velocity.x = SPEED_BOULDER
	if position.y<-1 or position.x>34:
		respawn()

func respawn():
	queue_free()


func _on_body_entered(body):
	if body.is_in_group("player"):
		body.hit(null, 20)
		body.reset_player()
		queue_free()
