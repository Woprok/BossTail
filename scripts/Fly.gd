extends CharacterBody3D
class_name Fly
# Fly is harmless on its own
# It does not collide or do anything
# It does collide with player attacks, as it can be killed

# TODO better dead and hit management, so Destroy is called only once on fly
# most issues are fixed, but it blocks some additional improvements to post death

enum FlyState { 
	FLYING, # Idle fly
	NAVIGATING, # Moves toward the swarn
	SWARMING, # Is moving as swarm
	SACRIFICE, # Moving to the boss
	DEAD
}

var state: FlyState = FlyState.FLYING

@export var KILL_OFF_ZONE: int = -10

@export_category("Fly Speed")
var gravity: int = -10
@export var fly_sacrifice_speed: float = 4.0
@export var fly_catch_speed: float = 10.0
@export var fly_idle_speed: float = 2.5
@export var fly_chase_speed: float = 5.5
var MovementComponent: FlyMovement = FlyMovement.new(fly_idle_speed, fly_chase_speed)

@export_category("Positioning and Swarm")
@export var home_spawner: Node3D
@export var home_swarm: Swarm #Node3D
@export var fly_buzz_radius: float = 10.0
@export var fly_leave_swarm_on_hit_chance: float = 0.7
# Required for Swarm
var swarm_index: int = -1
var swarm_position: Vector3 = Vector3.ZERO
var last_target_position: Vector3
var is_ignoring_swarms: bool = false

@export_category("Death")
@export var dead_body: PackedScene = preload("res://scenes/player/FlyProjectile.tscn")
@export var projectile_chance: float = 0.5 # randf is from 0.0 to 1.0
@export var eat_healing_value: float = 10.0

@export_category("Visual Transform")
@onready var special_material = preload("res://assets/godot_csg/fly_green.tres")
@onready var body_mesh = $CSGBakedMeshInstance3D

func _ready() -> void:
	# handle finding closest swarm
	# funny thing this is bad idea as it can sometimes find closest that is not intended
	if home_swarm == null:
		var swarms = get_tree().get_nodes_in_group("swarm")
		var closest: Node3D
		var closest_distance: float = 1.79769e308
		for si in swarms:
			var dist = self.global_position.distance_to(si.global_position)
			if dist < closest_distance:
				closest = si
				closest_distance = dist
		home_swarm = closest
		

func SetSpawner(spawner) -> void:
	home_spawner = spawner

func SetState(desired_state: FlyState) -> void:
	# this is called from outside, so we need to check that we understand the transition
	if state == FlyState.DEAD: # point of no return and this is kind of expected to be called
		return
	# Flying -> Navigating
	if desired_state == FlyState.NAVIGATING and state == FlyState.FLYING:
		state = desired_state
	# Navigating -> Swarming, Flying
	elif desired_state == FlyState.FLYING and state == FlyState.NAVIGATING:
		state = desired_state
	elif desired_state == FlyState.SWARMING and state == FlyState.NAVIGATING:
		state = desired_state
	# Swarming -> Sacrifice, Flying
	elif desired_state == FlyState.FLYING and state == FlyState.SWARMING:
		state = desired_state
	elif desired_state == FlyState.SACRIFICE and state == FlyState.SWARMING:
		state = desired_state
	# -> Dead
	elif desired_state == FlyState.DEAD:
		state = desired_state
	else:
		Global.LogError("Attempt to transition to not supported state on Fly")
		Global.LogError(desired_state)		

func _physics_process(delta: float) -> void:
	# Fly is simple as it can get
	# State determines target to move toward
	# Handle additional state transition per tick
	match state:
		FlyState.FLYING:
			if home_swarm != null and home_swarm.can_join_swarm() and not is_ignoring_swarms:
				SetState(FlyState.NAVIGATING)
		FlyState.NAVIGATING:
			if home_swarm == null or not home_swarm.can_join_swarm():
				SetState(FlyState.FLYING)
			if _reached_target_position():
				home_swarm.join_swarm(self)
		FlyState.SWARMING:
			pass				
		FlyState.SACRIFICE:
			_transform_to_big()
		FlyState.DEAD:
			return
			
	_select_and_navigate_to_target(delta)
		
	# Move with physics
	var direction = (last_target_position - global_position).normalized()
	velocity = direction * _state_to_speed()
	velocity.y += gravity * delta
	move_and_slide()

func _transform_to_big():
	#if body_mesh.get_surface_override_material_count() == 0:
		body_mesh.set_surface_override_material(0, special_material)
		self.scale = Vector3(3.0, 3.0, 3.0)

func _state_to_speed() -> float:
	match state:
		FlyState.FLYING:
			return fly_idle_speed
		FlyState.NAVIGATING:
			return fly_catch_speed
		FlyState.SWARMING:
			return fly_chase_speed
		FlyState.SACRIFICE:
			return fly_sacrifice_speed
	# otherwise, we don't need to care
	return 0.0
	

func _select_and_navigate_to_target(delta: float) -> void:
	# Fly moves based on state
	match state:
		FlyState.FLYING:
			if home_spawner:
				last_target_position = MovementComponent.fly_around_orbit(home_spawner.global_position, fly_buzz_radius, delta)
		FlyState.NAVIGATING:
			if home_swarm:
				last_target_position = home_swarm.global_position
		FlyState.SWARMING:
			if home_swarm:
				last_target_position = home_swarm.global_position + swarm_position #* randf()
		FlyState.SACRIFICE:
			# Defines target as boss global position
			var boss = get_tree().get_first_node_in_group("boss")
			if boss:
				last_target_position = boss.global_position
		FlyState.DEAD:
			return

func _navigate_to_last_target(delta: float) -> void:
	self.global_position = MovementComponent.get_target_position_by_chase(self.global_position, last_target_position, delta)

func _reached_target_position(max_distance: float = 0.5) -> bool:
	return self.global_position.distance_to(last_target_position) <= max_distance

	
func _on_body_entered(body):
	if body.is_in_group("boss"):
		body.special_fly_arrived(self)

func _on_body_exited(body):
	if body.is_in_group("boss"):
		pass

func hit(_source, _damage) -> bool:
	
	# can be ended by pebble
	#if state == FlyState.SACRIFICE and _source.is_in_group("player_projectile") and _source.is_in_group("ammo_standard"):
	#	_source.destroy()
	#	destroy()
	#	return true
	
	if state == FlyState.SWARMING:
		_try_leave_swarm()
		return false
	else:
		destroy()
		return true

# Fly is dead
func destroy() -> void:
	if state == FlyState.DEAD:
		return
	# spawn projectile body
	# leave swarm
	# leave spawner
	_try_spawn_body()
	if home_swarm and state == FlyState.SWARMING:
		home_swarm.leave_swarm(self, FlyState.DEAD)
	if home_spawner:
		home_spawner.despawn(self)
	# free self as there is nothing to do as dead fly
	queue_free()
	
# This is random as we now have too many fly
func _try_spawn_body() -> void:
	if randf() >= projectile_chance:
		var fd = dead_body.instantiate()
		get_tree().current_scene.add_child(fd)
		fd.global_position = self.global_position
	
# Swarm leaving mechanic on hit
func _try_leave_swarm() -> void:
	if randf() < fly_leave_swarm_on_hit_chance:
		home_swarm.leave_swarm(self, FlyState.FLYING)
		is_ignoring_swarms = true
		if $SwarmJoinTimer.is_stopped():
			$SwarmJoinTimer.start()
# Reenables joining the swarms
func _on_swarm_join_timer_timeout() -> void:
	$SwarmJoinTimer.stop()
	is_ignoring_swarms = false
