extends Area3D

@export var target_position:Array[Vector3]

func break_platform(platform)->void:
	add_neighbors(platform)
	
	platform.queue_free()
	$BubblesSpawner.active = true
	platform = $stone1
	
	change_visibility()
	break_animation(platform)
	
func add_neighbors(platform):
	$stone1.neighbors.append_array(platform.neighbors)
	$stone2.neighbors.append_array(platform.neighbors)
	$stone3.neighbors.append_array(platform.neighbors)
	$stone4.neighbors.append_array(platform.neighbors)
	for plt in platform.neighbors:
		plt.neighbors.append($stone1)
		plt.neighbors.append($stone2)
		plt.neighbors.append($stone3)
		plt.neighbors.append($stone4)
	
	
func change_visibility():
	$stone1.show()
	$stone2.show()
	$stone3.show()
	$stone4.show()


func break_animation(platform):
	var num = 0
	var tween = create_tween()
	for stone in get_children():
		if stone.name.begins_with("stone"):
			stone.get_node("platform").use_collision = false
			tween.parallel().tween_property(stone, "position", target_position[num], 0.5)
			num += 1 
	await get_tree().create_timer(0.5).timeout
	for stone in get_children():
		if stone.name.begins_with("stone"):
			stone.get_node("platform").use_collision = true
