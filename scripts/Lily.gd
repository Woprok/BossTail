extends Node3D

@export var neighbors: Array[Node] = []
var sinked = false
var objects = 0

func _process(delta):
	if position.y<-1:
		sinked = true
	else:
		sinked = false
	if objects>0:
		if position.y<-3:
			return
		position.y-=delta*0.2
	elif position.y<0.9:
		position.y+=delta*0.08	


func _on_body_entered(body):
	if body.is_in_group("player"):
		objects+=1


func _on_body_exited(body):
	if body.is_in_group("player"):
		objects-=1
