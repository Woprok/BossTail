extends Node3D
class_name Lily

@export var neighbors: Array[Node] = []
@export var radius = 7
@export var recovery_time = 15 
@export var sink_depth = -3.0

var health = 1
var objects = 0
var sinked = false

func _process(delta):
	if is_in_group("big_lily"):
		handle_sink(delta)
		return
	if position.y<-1:
		sinked = true
	else:
		sinked = false
	if objects>0:
		if position.y < -3:
			return
		position.y -= delta * 0.2
	elif position.y < 0:
		position.y += delta * 0.08	

func handle_sink(delta):
	if sinked:
		position.y -= delta * 2
		if position.y<=sink_depth:
			sinked = false
	else:
		if position.y<0:
			position.y += -sink_depth/recovery_time*delta
		else:
			position.y = 0

func _on_body_entered(body):
	if body.is_in_group("player"):
		objects+=1
	if body.is_in_group("boulder"):
		sinked = true
		position.y = -0.9
		body.respawn()


func _on_body_exited(body):
	if body.is_in_group("player"):
		objects-=1
