extends Node3D

var frog_health = preload("res://data_resources/FrogBossDataModel.tres")
var WaterBubble = preload("res://scenes/WaterBubble.tscn")
var last_bubble = 0
var angles:Array[float] = []
var last_num_of_bubbles = 0
@export var platform:Node

func _process(delta):
	if Global.phase == 2:
		last_bubble += delta
		var num_of_bubbles = 5-(frog_health.get_current_health()-1)/20
		if last_num_of_bubbles!=num_of_bubbles:
			reset_respawn_position(num_of_bubbles)
		if last_bubble >= 1:
			last_bubble = 0
			for index in range(angles.size()):
				angles[index] = (angles[index] + delta*20)
				var bubble = WaterBubble.instantiate()
				bubble.scale*=2
				add_child(bubble)
				var center_position = platform.global_position 
				var radius = platform.radius
				var x = center_position.x + cos(angles[index]) * radius
				var z = center_position.z + sin(angles[index]) * radius
				bubble.global_position = Vector3(x,4,z)
				bubble.emerge()

func reset_respawn_position(num_of_bubbles):
	last_num_of_bubbles = num_of_bubbles
	angles.clear()
	for i in range(num_of_bubbles):
		var angle = TAU * i / num_of_bubbles
		angles.append(angle)
