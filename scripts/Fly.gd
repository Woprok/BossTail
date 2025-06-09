extends CharacterBody3D
class_name Fly
# Fly is harmless on its own
# It does not collide or do anything
# It does collide with player attacks, as it can be killed

enum FlyState { 
	FLYING, # Idle fly
	NAVIGATING, # Moves toward the swarn
	SWARMING, # Is moving as swarm
	SACRIFICE # Moving to the boss
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
# Required for Swarm
var swarm_index: int = -1
var swarm_position: Vector3 = Vector3.ZERO
var last_target_position: Vector3

@export_category("Death")
@export var dead_body: PackedScene = null
@export var projectile_chance: float = 0.5 # randf is from 0.0 to 1.0

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
		
	#if self.global_position.y < KILL_OFF_ZONE:
	# destroy()
	# this needs to be reworked		
	#if $Body.disabled:
	#	call_deferred("enable_collision")
	#velocity.y += fly_speed * gravity * delta
	#var collision = move_and_collide(fly_speed * velocity * delta)
	#if collision:
		#if FlyState.SWARMING and home_swarm != null:
		#	home_swarm.leave_swarm(self)
		#destroy()
		
func enable_collision():
	$Body.disabled = false

func _fly_idle(delta: float) -> void:
	last_target_position = MovementComponent.fly_around(home_spawner.global_position, fly_buzz_radius)
	
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

# Fly is dead, it should spawn FlyProjectile
func destroy() -> void:
	if randf() >= projectile_chance:
		var fd = dead_body.intantiate()
		fd.global_position = self.global_position
		get_tree().root.add_child(fd)
	queue_free()
	
func _on_body_entered(body):
	if body.is_in_group("boss"):
		pass
	if body.is_in_group("player"):
		pass

func _on_body_exited(body):
	if body.is_in_group("boss"):
		pass
	if body.is_in_group("player"):
		pass
