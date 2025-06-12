extends Node3D
class_name ProjectileSpawnerBase

@export var projectile: PackedScene
@export var distance_x: float = 0.5
@export var distance_z: float = 0.5

@export var min_spawn: int = 1
@export var max_spawn: int = 10
var spawned_count: int = 0

func _ready() -> void:
	spawn_projectile()

func _process(delta: float) -> void:
	if spawned_count < max_spawn:
		spawn_projectile()

func spawn_projectile():
	# Instantiate, define spawner and increment spawned count to prevent too many on spawner
	# After that define position based on select spawn position strategy
	var new_pickable = projectile.instantiate()
	new_pickable.spawner = self
	spawned_count += 1
	new_pickable.position = _select_spawn_position()
	get_tree().current_scene.add_child.call_deferred(new_pickable)

func _select_spawn_position() -> Vector3:
	var x = self.global_position.x + randf_range(-distance_x, distance_x)
	var y = self.global_position.y + 2
	var z = self.global_position.z + randf_range(-distance_z, distance_z)
	return Vector3(x, y, z)
	

func on_projectile_picked(projectile):
	spawned_count -= 1
