extends Node3D
class_name Lily

var Fly = preload("res://scenes/Fly.tscn")

@export var neighbors: Array[Node] = []
@export var radius = 7
@export var RESPAWN_TIME = 5
@export var recovery_time = 15 
@export var sink_depth = -3.0

var health = 1
var objects = 0
var time=0
var sinked = false

func _process(delta):
	if is_in_group("big_lily"):
		handle_sink(delta)
		return
	if is_in_group("flower_lily"):
		if not get_node("Flower").has_node("fly"):
			time+=delta
			if time>RESPAWN_TIME:
				respawn_fly()
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


func respawn_fly():
	time = 0
	var fly = Fly.instantiate()
	fly.name = "fly"
	fly.flying = true
	fly.position.y = 1.3
	fly.scale=Vector3(2,2,2)
	get_node("Flower").add_child(fly)

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
