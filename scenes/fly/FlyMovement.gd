class_name FlyMovement

@export var flying_idle_speed: float = 1.5
@export var flying_chase_speed: float = 3.0
@export var flying_offset: Vector3 = Vector3(0.0, 0.0, 0.0)

@export var orbit_angle: float = 0.0 # Add this to Swarm node as a member
@export var flying_orbit_speed: float = 1.5 # Also add this as a variable if you want to tweak

func _init(idle_speed: float, chase_speed: float, offset: Vector3 = Vector3(0.0, 0.0, 0.0)) -> void:
	flying_idle_speed = idle_speed
	flying_orbit_speed = idle_speed
	flying_chase_speed = chase_speed
	flying_offset = offset

func get_target_position_by_idle(init_position: Vector3, target_position: Vector3, delta: float) -> Vector3:
	return _get_to_position(init_position, target_position, delta, flying_idle_speed)
	
func get_target_position_by_chase(init_position: Vector3, target_position: Vector3, delta: float) -> Vector3:
	return _get_to_position(init_position, target_position, delta, flying_chase_speed)
	
func _get_to_position(init_position: Vector3, target_position: Vector3, delta: float, speed: float) -> Vector3:
	var dir = target_position - init_position
	dir = dir.normalized()
	return init_position + dir * speed * delta

func fly_around(center: Vector3, radius: float):
	var angle = randf() * TAU
	var distance = sqrt(randf()) * radius
	var x = center.x + distance * cos(angle) + flying_offset.x
	var y = center.y + flying_offset.y
	var z = center.z + distance * sin(angle) + flying_offset.z
	return Vector3(x, center.y, z)

func fly_around_orbit(center: Vector3, radius: float, delta: float) -> Vector3:
	orbit_angle += flying_orbit_speed * delta
	orbit_angle = fmod(orbit_angle, TAU) # Keep it between 0-2π

	var x = center.x + radius * cos(orbit_angle) + flying_offset.x
	var y = center.y + flying_offset.y
	var z = center.z + radius * sin(orbit_angle) + flying_offset.z
	return Vector3(x, y, z)
