extends Node3D
class_name SpawnPoint3D

@export var entity_custom_root: Node3D
@export var entity_to_spawn: PackedScene

@export var min_spawn_offset: Vector3 = Vector3(0.0, 0.0, 0.0)
@export var max_spawn_offset: Vector3 = Vector3(0.0, 0.0, 0.0)
@export var max_spawned_entities: int = 15

var spawned_entities: int = 0

func despawn(entity) -> void:
	spawned_entities -= 1

func spawn() -> void:
	spawned_entities += 1
	var new_entity: Node3D = entity_to_spawn.instantiate()
	new_entity.position = _select_spawn_position()
	
	# assign entity under desired root or default
	if entity_custom_root:
		entity_custom_root.add_child(new_entity)
	else:		
		get_tree().current_scene.add_child(new_entity)
	new_entity.SetSpawner(self)

func _select_spawn_position() -> Vector3:
	var x = self.global_position.x + randf_range(min_spawn_offset.x, max_spawn_offset.x)
	var y = self.global_position.y + randf_range(min_spawn_offset.y, max_spawn_offset.y)
	var z = self.global_position.z + randf_range(min_spawn_offset.z, max_spawn_offset.z)
	return Vector3(x,y,z)

func _on_spawn_timer_timeout() -> void:
	if spawned_entities < max_spawned_entities:
		spawn()
