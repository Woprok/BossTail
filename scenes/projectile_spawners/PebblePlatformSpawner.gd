extends ProjectileSpawnerBase
class_name PebblePlatformSpawner

# just spawn stone, it should be good enough to pick any valid platform center
func _select_spawn_position() -> Vector3:
	var platforms: Array[Node] = get_tree().get_nodes_in_group("stone_platform")
	var random_platform = platforms.pick_random()
	
	var x = random_platform.position.x + randf_range(-distance_x, distance_x)
	var y = random_platform.position.y + 2
	var z = random_platform.position.z + randf_range(-distance_z, distance_z)
	return Vector3(x, y, z)
	
#	var platform
#	if stone_platforms.get_child_count()==0 and Global.phase>1:
#		var child_index = randi() % get_parent().get_parent().get_node("shards").get_child_count()
#		platform = get_parent().get_parent().get_node("shards").get_child(child_index)
#	else:
#		var child_index = randi() % stone_platforms.get_child_count()
#		platform = stone_platforms.get_child(child_index)
#	var x = randf() * 7 - 3.5
#	var z = randf() * 7 - 3.5
#	position = Vector3(platform.position.x+x,platform.position.y+2,platform.position.z+z)
	
