extends Node3D

@export var inner_circle:Array[Vector3] = []
@export var outer_circle:Array[Vector3] = []
@export var BUBBLE_SPAWN_TIME = 1

var WaterBubble = preload("res://scenes/WaterBubble.tscn")

var active = false
var last_inner_index = -1
var last_outer_index = -1
var last_bubble = 0

func _process(delta: float) -> void:
	if not active: return
	last_bubble += delta
	if last_bubble > BUBBLE_SPAWN_TIME:
		spawn_bubbles()
		last_bubble = 0
		
func spawn_bubbles():
	last_inner_index = (last_inner_index + 1) % inner_circle.size()
	last_outer_index = (last_outer_index + 1) % outer_circle.size() 
	
	var bubble_inner = WaterBubble.instantiate()
	var bubble_outer = WaterBubble.instantiate()
	bubble_inner.scale.y /= get_parent().scale.y
	bubble_outer.scale.y /= get_parent().scale.y
	bubble_inner.scale *= 2
	bubble_outer.scale *= 2
	bubble_inner.spawner = true
	bubble_outer.spawner = true
	add_child(bubble_inner)
	add_child(bubble_outer)
	
	bubble_inner.shoot(get_parent().global_position + inner_circle[last_inner_index])
	bubble_outer.shoot(get_parent().global_position + outer_circle[last_outer_index])
