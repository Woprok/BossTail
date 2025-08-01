extends Area3D
class_name Swarm

enum SwarmState { 
	BUZZING, # Can split off and heal the boss
	CHASING, # Chases player around and harms him
	DISPERSED, # Does not exists and is transported to swarm home to assemble
}

# By default this can only chase the player, so we can get it onready
@onready var player = get_tree().current_scene.get_node("Player")
# Swarm must move slower than individual fly, so fly can catch up and keep up
@export var fly_idle_speed: float = 1.0
@export var fly_chase_speed: float = 4.0
var MovementComponent: FlyMovement = FlyMovement.new(fly_idle_speed, fly_chase_speed, Vector3(0.0, 3.0, 0.0))

# Swarm configuration
@export_category("Swarm Behavior")
@export var swarm_home: Node3D
@export var swarm_home_offset: Vector3 = Vector3(0.0, 3.0, 0.0)
@export var swarm_buzz_radius: float = 7.5
@export var swarm_chase_radius: float = 20.0
@export var additional_radius_per_fly: float = 1.7
@export var fly_in_swarm_positions: Array[Vector3] = [
	Vector3(0.0, 	0.0, 	0.0),
	# Center
	Vector3(0.35, 	0.0, 	0.0),
	Vector3(0.0, 	0.0, 	0.35),
	Vector3(-0.35, 	0.0, 	0.0),
	Vector3(0.0, 	0.0, 	-0.35),
	# Top
	Vector3(0.2, 	0.2, 	0.2),
	Vector3(-0.2, 	0.2, 	0.2),
	Vector3(0.2, 	0.2, 	-0.2),
	Vector3(-0.2, 	0.2, 	-0.2),
	# Bottom 
	Vector3(0.2, 	-0.2, 	0.2),
	Vector3(-0.2, 	-0.2, 	0.2),
	Vector3(0.2, 	-0.2, 	-0.2),
	Vector3(-0.2, 	-0.2, 	-0.2),
]
var active_swarm_fly: Array[Fly]
var state: SwarmState = SwarmState.BUZZING
var last_target_position: Vector3

@export_category("Swarm Damage")
@export var SWARM_INITIAL_HIT: float = 0.5
@export var SWARM_CONTINUOUS_HIT: float = 0.5
@export var SWARM_FINAL_HIT: float = 0.0
@export var FLY_REQUIRED_FOR_CHASE: int = 5

@export_category("Swarm Healing")
@export var FLY_REQUIRED_FOR_SPLIT_OFF: int = 10
@export var TIME_BETWEEN_SPLIT_OFF: float = 60.0
var accumulated_split_off_time: float = 0

func _physics_process(delta):	
	# First resolve state change
	match state:
		SwarmState.DISPERSED:
			$CollisionShape3D.debug_color = Color.RED
		SwarmState.BUZZING:
			$CollisionShape3D.debug_color = Color.GREEN
			if _update_split_off_time(delta):
				_split_off_random_fly()
			var can_chase: bool = _can_chase_player()
			if can_chase and active_swarm_fly.size() >= FLY_REQUIRED_FOR_CHASE:
				state = SwarmState.CHASING
		SwarmState.CHASING:
			$CollisionShape3D.debug_color = Color.BLUE
			# Swarm chases the player and fly follows
			var can_chase: bool = _can_chase_player() 
			if not can_chase or active_swarm_fly.size() < FLY_REQUIRED_FOR_CHASE:
				state = SwarmState.BUZZING
	# Second resolve navigation
	_select_and_navigate_to_target(delta)
			
func _update_split_off_time(delta: float) -> bool:
	accumulated_split_off_time += delta
	return accumulated_split_off_time >= TIME_BETWEEN_SPLIT_OFF and active_swarm_fly.size() >= FLY_REQUIRED_FOR_SPLIT_OFF

func _split_off_random_fly() -> void:
	accumulated_split_off_time -= TIME_BETWEEN_SPLIT_OFF
	if accumulated_split_off_time < 0.0:
		accumulated_split_off_time = 0.0
	var fly = active_swarm_fly.pick_random()
	leave_swarm(fly, Fly.FlyState.SACRIFICE)
					
func _transition_to_dispersed() -> void:
	state = SwarmState.DISPERSED
	%DisperseTimer.start()

func can_join_swarm() -> bool:
	return active_swarm_fly.size() < fly_in_swarm_positions.size()

# Fly is notified of joining the swarm at specific position
func join_swarm(fly: Fly, to_state: Fly.FlyState = Fly.FlyState.SWARMING) -> bool:
	if not can_join_swarm():
		return false
	var idx = active_swarm_fly.size()
	fly.swarm_index = idx 
	fly.swarm_position = fly_in_swarm_positions[idx] 
	active_swarm_fly.push_back(fly)
	# fly is informed of joining the swarm
	fly.SetState(to_state)
	return true
	
# Fly is removed from swarm and it's position is released
# Thus all fly move to fill the spot
func leave_swarm(fly: Fly, to_state: Fly.FlyState) -> void:
	# Set's fly as free
	active_swarm_fly.erase(fly)
	fly.SetState(to_state)
	# Clean it from array
	for fly_index in range(active_swarm_fly.size()):
		var swarm_fly = active_swarm_fly[fly_index]
		swarm_fly.swarm_index = fly_index
		swarm_fly.swarm_position = fly_in_swarm_positions[fly_index]
	
func _murder_swarm() -> void:
	state = SwarmState.DISPERSED
	while active_swarm_fly.size() > 0:
		var next_fly = active_swarm_fly.pop_back()
		next_fly.destroy()
	
func _murder_swarm_member() -> bool:
	if active_swarm_fly.size() > 0:
		var next_fly = active_swarm_fly.pick_random()
		next_fly.destroy()
		return true
	return false

func _can_chase_player() -> bool:
	return swarm_home.global_position.distance_to(player.global_position) <= _get_swarm_radius(swarm_chase_radius)

func _get_swarm_radius(base_radius: float) -> float:
	return base_radius + active_swarm_fly.size() * additional_radius_per_fly

func _select_and_navigate_to_target(delta: float) -> void:
	# Swarm navigates only in two states
	match state:
		# Swarm navigates to the home
		SwarmState.DISPERSED:
			last_target_position = swarm_home.global_position + swarm_home_offset
			self.global_position = MovementComponent.get_target_position_by_idle(self.global_position, last_target_position, delta)
		# Swarm navigates around the home
		SwarmState.BUZZING:
			last_target_position = MovementComponent.fly_around_orbit(swarm_home.global_position, swarm_buzz_radius, delta)
			self.global_position = MovementComponent.get_target_position_by_idle(self.global_position, last_target_position, delta)
		# Swarm chases player that is close enough
		SwarmState.CHASING:
			last_target_position = player.global_position
			self.global_position = MovementComponent.get_target_position_by_chase(self.global_position, last_target_position, delta)

func _player_start_taking_damage(_player_body) -> void:
	if not %TickTimer.is_stopped():
		%TickTimer.stop()
	%TickTimer.start()
	if state == SwarmState.CHASING:
		player.hit(self, SWARM_INITIAL_HIT)

func _on_tick_timer_timeout() -> void:
	if state == SwarmState.CHASING:
		player.hit(self, SWARM_CONTINUOUS_HIT)
	
func _player_stop_taking_damage(_player_body) -> void:
	%TickTimer.stop()
	if state == SwarmState.CHASING and SWARM_FINAL_HIT != 0.0:
		player.hit(self, SWARM_FINAL_HIT)

func hit(_source, _damage) -> bool:
	# Swarm is easy to hit and does take damage
	# It's just super ineffective
	# Pebbles solve this
	return _murder_swarm_member()

func _on_body_entered(body):
	# swarm is chasing and reached player
	if state == SwarmState.CHASING and body.is_in_group("player"):
		_player_start_taking_damage(body)
	# swarm is dispersed
	if body.is_in_group("player_projectile") and body.is_in_group("ammo_standard"):
		body.destroy()
		_transition_to_dispersed()
	# swarm is destroyed by Frog or Environment
	if body.is_in_group("frog_bubble"):
		body.queue_free()
		_transition_to_dispersed()
	# TODO frog can kill swarm
	#if body.is_in_group("boss"):
	#	_murder_swarm()

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_stop_taking_damage(body)

func _on_disperse_timer_timeout() -> void:
	%DisperseTimer.stop()
	# Always moved to idle state
	state = SwarmState.BUZZING
