extends RigidBody3D
var stopped = false
var STOP_TIME = 1
var stop_time = 0

func _physics_process(delta):
	stop_time += delta
	if stop_time>=STOP_TIME:
		stopped = false
	if stopped:
		return
	rotate_y(delta*20)


func hit(_health):
	stopped = true
	stop_time = 0


func _on_body_entered(body):
	if not stopped and body.is_in_group("player") and body.pushed == false:
		body.velocity=(body.global_position-global_position).normalized()*13
		body.velocity.y = 0
		body.pushed = true
