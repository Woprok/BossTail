extends CharacterBody3D
class_name Fly
# Fly is harmless on its own
# It does not collide or do anything
# It does collide with player attacks, as it can be killed

enum FlyState { 
	FLYING, # Idle fly
	NAVIGATING, # Moves toward the swarn
	SWARMING, # Is moving as swarm
	SACRIFICE, # Moving to the boss
	DEAD
}

var state: FlyState = FlyState.FLYING

@export var KILL_OFF_ZONE: int = -10

var gravity: int = -10
@export var fly_speed: float = 15.0
@export var fly_idle_speed: float = 3.5
@export var fly_chase_speed: float = 5.0
var MovementComponent: FlyMovement = FlyMovement.new(fly_idle_speed, fly_chase_speed)

@export_category("Positioning and Swarm")
@export var home_spawner: Node3D
@export var home_swarm: Node3D
@export var fly_buzz_radius: float = 10.0
@export var fly_leave_swarm_on_hit_chance: float = 0.1
# Required for Swarm
var swarm_index: int = -1
var swarm_position: Vector3 = Vector3.ZERO
var last_target_position: Vector3
var is_ignoring_swarms: bool = false

@export_category("Death")
@export var dead_body: PackedScene = preload("res://scenes/player/FlyProjectile.tscn")
@export var projectile_chance: float = 0.5 # randf is from 0.0 to 1.0

func hit(source, damage) -> bool:
	if state == FlyState.SWARMING:
		_try_leave_swarm()
		return false
	else:
		destroy()
		return true

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
	if state == FlyState.DEAD: # point of no return
		return
	if desired_state == FlyState.SACRIFICE and state == FlyState.SWARMING:
		state = desired_state
	elif desired_state == FlyState.SWARMING and state == FlyState.FLYING:
		state = desired_state
	elif desired_state == FlyState.FLYING and state == FlyState.SWARMING:
		state = desired_state

func _physics_process(delta: float) -> void:
	# Fly is simple as it can get
	# State determines target to move toward
	
	# Try Join Swarm when relevant only
	if home_swarm:
		if not home_swarm.can_join_swarm() and state == FlyState.NAVIGATING:
			state = FlyState.FLYING
		if home_swarm.can_join_swarm() and state == FlyState.FLYING:
			state = FlyState.NAVIGATING
			
	if is_ignoring_swarms and (state == FlyState.NAVIGATING or state == FlyState.SWARMING):
		state = FlyState.FLYING
	
	match state:
		FlyState.FLYING:
			_fly_idle(delta)
		FlyState.NAVIGATING:
			_navigate_to_swarm(delta)
		FlyState.SWARMING:
			_swarm_behavior(delta)
		FlyState.SACRIFICE:
			_try_sacrifice_self(delta)
			
	# the above defines only targets, this moves fly
	_navigate_to_last_target(delta)
	if _reached_target_position():
		match state:
			FlyState.NAVIGATING:
				state = FlyState.SWARMING
				home_swarm.join_swarm(self)
		
	# Move with physics
	var direction = (last_target_position - global_position).normalized()
	velocity = direction * fly_speed
	velocity.y += gravity * delta
	move_and_slide()

func _fly_idle(delta: float) -> void:
	last_target_position = MovementComponent.fly_around_orbit(home_spawner.global_position, fly_buzz_radius, delta)
	
func _navigate_to_swarm(delta: float) -> void:
	last_target_position = home_swarm.global_position
	
func _swarm_behavior(delta: float) -> void:
	last_target_position = home_swarm.global_position + swarm_position #* randf()

func _try_sacrifice_self(delta: float) -> void:
	# Defines target as boss global position
	var boss = get_tree().get_first_node_in_group("boss")
	last_target_position = boss.global_position

func _navigate_to_last_target(delta: float) -> void:
	self.global_position = MovementComponent.get_target_position_by_chase(self.global_position, last_target_position, delta)

func _reached_target_position(max_distance: float = 0.5) -> bool:
	return self.global_position.distance_to(last_target_position) <= max_distance

	
func _on_body_entered(body):
	if body.is_in_group("boss"):
		body.special_fly_arrived(self)
	if body.is_in_group("player"):
		pass

func _on_body_exited(body):
	if body.is_in_group("boss"):
		pass
	if body.is_in_group("player"):
		pass

# Fly is dead
func destroy() -> void:
	if state == FlyState.DEAD:
		print(self)
		return
	print(self)
	state = FlyState.DEAD
	# spawn projectile body
	# leave swarm
	# leave spawner
	_try_spawn_body()
	if home_swarm and state == FlyState.SWARMING:
		home_swarm.leave_swarm(self)
	if home_spawner:
		home_spawner.despawn(self)
	# free self as there is nothing to do as dead fly
	queue_free()
	
# This is random as we now have too many fly
func _try_spawn_body() -> void:
	if randf() >= projectile_chance:
		var fd = dead_body.instantiate()
		fd.global_position = self.global_position
		get_tree().root.add_child(fd)
	
# Swarm leaving mechanic on hit
func _try_leave_swarm() -> void:
	if randf() < fly_leave_swarm_on_hit_chance:
		home_swarm.leave_swarm(self)
		is_ignoring_swarms = true
		if $SwarmJoinTimer.is_stopped():
			$SwarmJoinTimer.start()
# Reenables joining the swarms
func _on_swarm_join_timer_timeout() -> void:
	$SwarmJoinTimer.stop()
	is_ignoring_swarms = true
