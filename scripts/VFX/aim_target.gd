extends Node3D

var space_state
var screen_center
var gravity: int = -10
var Camera
@export var HEIGHT_OF_ARC: float = 2.0
@export var MIN_RANGE:float = 2.0
@export var MAX_RANGE:float = 60.0 

func set_camera(camera) -> void:
	Camera = camera
	space_state = Camera.get_world_3d().direct_space_state


func update_target_marker(start_position):
	screen_center = get_viewport().size / 2
	var origin = Camera.project_ray_origin(screen_center)
	var end = origin + Camera.project_ray_normal(screen_center) * 1000
	
	var query = PhysicsRayQueryParameters3D.create(origin,end)
	query.collide_with_bodies = true
	var result = space_state.intersect_ray(query)
	var result_position
	if result:
		result_position = result.get("position")
		if origin.distance_to(result_position)<MIN_RANGE:
			result_position = origin + (end - origin).normalized() * MIN_RANGE
			result_position = ground_intersect(result_position)
		elif origin.distance_to(result_position)>MAX_RANGE:
			result_position = origin + (end - origin).normalized() * MAX_RANGE
			result_position = ground_intersect(result_position)
	else:
		result_position = origin + (end - origin).normalized() * MAX_RANGE
		result_position = ground_intersect(result_position)
		
	global_position = result_position
	scale = Vector3.ONE * get_target_size(origin.distance_to(result_position))
	update_trajectory(start_position, result_position)


func update_trajectory(start_position, result_position):
	var velocity = compute_velocity(result_position, start_position)
	var delta = 0.01
	velocity.y += 2 * gravity * delta
	var pos = start_position + velocity * delta * 2 
	var points = []
	while velocity.y > 0 or pos.y > result_position.y:
		points.append(pos)
		velocity.y += 2 * gravity * delta
		pos += velocity * delta * 2 
	draw_line(points)
	
	
func draw_line(points):
	$mesh.mesh.clear_surfaces()
	$mesh.mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	for point in points:
		$mesh.mesh.surface_add_vertex($mesh.to_local(point))
	$mesh.mesh.surface_end()
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color.YELLOW
	$mesh.mesh.surface_set_material(0, mat)
	
	
func ground_intersect(position):
	var from = position
	var to = from + Vector3.DOWN * 1000  
	var space_state = Camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from,to)
	query.collide_with_bodies = true
	var result = space_state.intersect_ray(query)
	if result:
		return result.position
	else:
		return position


func get_target_size(distance: float) -> float:
	var min_dist = MIN_RANGE
	var max_dist = MAX_RANGE
	var min_size = 0.1
	var max_size = 1.5

	distance = clamp(distance, min_dist, max_dist)

	var size = lerp(min_size, max_size, (distance - min_dist) / (max_dist - min_dist))
	return size
	
	
func compute_velocity(result_position, start_position):
	var height = result_position.y - start_position.y + HEIGHT_OF_ARC
	height = abs(height)
	var displacement_y = result_position.y-start_position.y
	var displacemnt_xz = Vector3(result_position.x - start_position.x, 0, result_position.z - start_position.z)
	var velocity_y = Vector3.UP * sqrt(-2 * gravity * height)
	var velocity_xz = displacemnt_xz / (sqrt(-2 * height / gravity) + sqrt(2 * (displacement_y - height) / gravity))
	var velocity = velocity_y + velocity_xz
	return velocity
