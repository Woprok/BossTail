extends Node3D

var Fly = preload("res://scenes/Fly.tscn")
@export var neighbors: Array[Node] = []
var sinked = false
@export var radius = 7
var objects = 0
var time=0
var RESPAWN_TIME = 10

func _process(delta):
	if is_in_group("big_lily"):
		return
	if is_in_group("flower_lily"):
		if not get_node("Flower").has_node("fly"):
			time+=delta
			if time>RESPAWN_TIME:
				var fly = Fly.instantiate()
				fly.name = "fly"
				fly.flying = true
				fly.position.y = 1.3
				fly.scale=Vector3(2,2,2)
				get_node("Flower").add_child(fly)
	if position.y<-1:
		sinked = true
	else:
		sinked = false
	if objects>0:
		if position.y<-3:
			return
		position.y-=delta*0.2
	elif position.y<0:
		position.y+=delta*0.08	


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
