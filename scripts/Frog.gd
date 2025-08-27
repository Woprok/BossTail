extends CharacterBody3D
class_name Frog

@export var animationPlayer : AnimationPlayer
@onready var animationTree : ToadAnimationController = $AnimationTree
@onready var special_material = preload("res://assets/materials/toad_unlit_overlay_body_special.tres")
@onready var body_mesh = $Char_ToadBoss/rig_deform/Skeleton3D/Toad

# speed on ground
@export var speed:int = 2
# swimming speed
@export var MAX_SWIMMING_SPEED = 10
# health percent for swipe
@export var SWIPE_HP = 75
# health percent for grab
@export var GRAB_HP = 45

var gravity:int = -10
var HEIGHT_OF_ARC:float = 5

# actual time of ability
var time_of_extend = 0
var time_bubble = 0
var time_swipe_diff = 0
var time_swipe_same = 0 
var time_grab = 0
var time_swimming = 0
var time_stop = 5
var time_slam = 0
var time_eat = 0
var time_doing = 0
var time_big_lily = 0

@export_group("Animation Timings")
@export_subgroup("Anticipations")
@export var TONGUE_SWIPE_ANTIC_DUR = 0.6667
@export var TONGUE_GRAB_ANTIC_DUR = 0.6667
@export var GROUND_SLAM_ANTIC_DUR = 0.5
@export var SPIT_ANTIC_DUR = 0.5
@export var BUBBLE_ANTIC_DUR = 0.8333

@export_subgroup("Window of Opportunity")
@export var TONGUE_SWIPE_WOO_DUR = 1
@export var TONGUE_GRAB_WOO_DUR = TONGUE_EXTEND_TIME
@export var GROUND_SLAM_WOO_DUR = 1
@export var SPIT_WOO_DUR = 0
@export var BUBBLE_WOO_DUR = 0

@export_group("Attack params")
# time of extension of tongue 
@export var TONGUE_EXTEND_TIME = 6
# time between two swipes, player and enemy on same platform
@export var SWIPE_SAME_PLATFORM_TIME = 2
# time between two swipes, player and enemy on different platform
@export var SWIPE_DIFF_PLATFORM_TIME = 6
@export var SLAM_TIME_CONST = 5
@export var SWIPE_SAME_PLATFORM_TIME_CONST = 2
@export var SWIPE_DIFF_PLATFORM_TIME_CONST = 6
@export var SPIT_BUBBLE_TIME_CONST = 5
@export var BIG_LILY_BEHAVIOR_TIME = 1.5

# time between two spit attacks
@export var SPIT_BUBBLE_TIME = 5
# time between two bubble attacks from water
@export var WATER_BUBBLE_TIME = 4
# number of water bubbles to spit
@export var BUBBLE_NUM = 3
# time of waiting after tongue major damage
@export var STOP_TIME = 5
# time between two grabs
@export var GRAB_TIME = 10
# time of swimming
@export var SWIMMING_TIME = 30
# time between two slams
@export var SLAM_TIME = 5
# time between two eatings
@export var EAT_TIME = 10
# health restored per eating as minimum, fly and flyProjectile define their own values
@export var EAT_HP_BASE_RESTORE_PER_EATING = 0

# Player's HP lost by slam 
@export var SLAM_HP = 10
# Player's HP lost by swipe 
@export var SWIPE_DAMAGE_HP = 5
# Player's HP lost by grab
@export var GRAB_DAMAGE_HP = 5
# Player's HP lost by jump on him
@export var JUMP_DAMAGE_HP = 10
# HP lost by leg hit
@export var LEG_HP = 5
# HP lost by tongue hit
@export var TONGUE_HP = 6
# HP lost by head hit
@export var HEAD_HP = 10
# HP lost by boulder hit
@export var BOULDER_HP = 20
# HP lost by spike hit
@export var SPIKE_HP = 20
# HP lost by spike hit
@export var SPIKE_SPECIAL_HP = 35
# HP lost by pebble hit
@export var PEBBLE_HP = 2.5
# HP lost to trigger swimming
@export var TRIGGER_SWIMMING = 10
@export var TRIGGER_SWIMMING_END: float = 7.5
@export var WEAK_DAMAGE_ARMOR_PROTECTION: float = 20.0

@export var SWIMMING_ACCELERATION_TIME:float = 0.7
@export var SWIMMING_DECELERATION_TIME:float = 0.7

var swimming_accumulated_damage: float = 0

# must be bigger than attack length
var DOING_TIME = 10

var grab = false
var slam = false
var doing = false
var swipe = false
var jump = false
var swimming = false
var sluggish = false
var swipe_grab_switch = true
var bubble_num = 0
var boulderHit = 0
var cinematic = false
# num of tongue hits for one grab
var tongueHit = 0
# HP lost from last triggering of swimming
var HPHit = 0
# is tongue extended
var extended = false
# is subphase change triggered
var triggered = false
# path between platforms
var path:Array[Node]
# num of subphase
var subphase = 0
# actual platform with toadboss
var platform : Node
# previous platform
var prev_platform : Node
# target for grab attack or eating target
var grab_target = null
var grab_target_position = null

# radius of path around platform for swimming
var radius = 12.5                  
var angle = 0.0
var init_angle = 0
var swimming_speed = 0
var swimming_stop = false

var grab_len_max = 6*2
var grab_len_min = 1

@export var boss_data: BossDataModel = preload("res://data_resources/FrogBossDataModel.tres")
@onready var player: PlayerBase = get_parent().get_node("Player")
@export var AcidSpit: PackedScene
@export var WaterBubble: PackedScene

@export_group("VFX")
@export var bubble_chargeup: BubbleChargeupVFXController
@export var bubble_appear_pos: Node3D
@export var hit_VFX: EntityHitVFX
@export var hit_impact_VFX: PackedScene
@export var stun_VFX: StunVFX
@export var swipe_indicator: PackedScene
@export var grab_indicator: PackedScene
@export var ground_slam_indicator: PackedScene
@export var death_VFX: DeathVFX

@export var hit_body_pos: Node3D
@export var hit_head_pos: Node3D

var current_bubble_inst = null
var triggered_once: bool = false

func _ready() -> void:
	boss_data.boss_restart()
	GameEvents.boss_changed.emit(boss_data)
	#stun test
	#create_tween().tween_callback(stun_VFX.play_stun_effect.bind(3)).set_delay(0.5)
	
# tf is this mess?
# behavior for character in both phase
func _physics_process(delta):
	boulderHit += delta
	time_stop += delta
	if cinematic:
		animationTree.swim_start_swimming()
		return
	# is stopped and do nothing
	if time_stop < STOP_TIME:
		return
	
	set_ability_cooldown()
	handle_movement(delta)
	
	handle_path_following()
	
	handle_tongue_extension(delta)
				
	if is_doing(delta): return
		
	if Global.phase == 1:
		process_phase_1(delta)
	elif Global.phase==2:
		process_phase_2(delta)

func process_phase_1(delta):
	if subphase == 0:
		set_ground_collisions()
		if triggered:
			jump_to_water()
			tongueHit = 0
			HPHit = 0
			return
		if can_grab(delta):
			if can_grab_same_platform():
				grab_same_platform()
			elif can_grab_other_platform():
				grab_other_platform()

		if can_swipe():
			handle_swipe(delta)

		if can_spit_bubble(delta):
			handle_bubble_spit(delta)
	else:
		if not swimming:
			start_swimming()
		else:
			update_swimming(delta)

func process_phase_2(delta:float):
	time_of_extend += delta
	time_eat+=delta
	slam_reset()
	if can_eat():
		handle_eating()
	time_slam += delta
	if time_slam>SLAM_TIME:
		if can_slam():
			if platform == player.platform:
				handle_slam()
		else:
			find_slam_platform_phase2()
	if is_on_big_lily():
		handle_big_lily(delta)
	else:
		if can_swipe():
			handle_swipe(delta)
		if can_spit_bubble(delta):
				handle_bubble_spit(delta)

func set_ground_collisions():
	$body/bodyShape.disabled = false
	$body/legShape.disabled = false
	$body/swimmingShape.disabled = true
	$headShape.disabled = false
	$bodyShape.disabled = false
	$legShape.disabled = false

func set_swimming_collision():
	$body/bodyShape.disabled = true
	$body/legShape.disabled = true
	$body/swimmingShape.disabled = false
	$headShape.disabled = true
	$bodyShape.disabled = true
	$legShape.disabled = true

func can_grab_same_platform():
	return boss_data.get_current_health() <= GRAB_HP and not doing and platform == player.platform

func can_grab_other_platform():
	return boss_data.get_current_health() <= GRAB_HP and not doing and platform != player.platform \
		and player.platform.is_in_group("stone_platform")

func can_swipe():
	return boss_data.get_current_health() <= SWIPE_HP and not doing
	
func can_grab(delta):
	time_grab += delta
	return time_grab>=GRAB_TIME
	
func can_spit_bubble(delta):
	if Global.phase > 1:
		time_bubble += delta
	return (boss_data.get_current_health() != 100 or (Global.phase == 2 and time_bubble>SPIT_BUBBLE_TIME)) and not doing

func grab_same_platform():
	if position.distance_to(player.position) < grab_len_min or position.distance_to(player.position) > grab_len_max:
		var point = find_point_on_platform(platform.global_position, player.global_position, grab_len_min, grab_len_max)
		if point != null:
			jump_direction(point)
	else:
		jump_direction(position)
	start_grab(player)

func grab_other_platform():
	time_bubble = 0
	time_swipe_diff = 0
	time_swipe_same = 0
	plan_path(player.platform)
	if path.size() <= 3:
		doing = true
		time_doing = 0
	else:
		path = []
	
func handle_swipe(delta):
	time_swipe_diff += delta
	time_swipe_same += delta

	if platform == player.platform and time_swipe_same > SWIPE_SAME_PLATFORM_TIME:
		start_swipe()
	elif platform != player.platform and platform.neighbors.has(player.platform) and time_swipe_diff > SWIPE_DIFF_PLATFORM_TIME:
		start_swipe()

func handle_bubble_spit(delta:float):
	time_bubble += delta
	if time_bubble>SPIT_BUBBLE_TIME and platform != player.platform:
		time_bubble += delta
		doing = true
		time_doing = 0
		time_swipe_diff -= 1
		time_swipe_same = 0
		look_at(Vector3(player.position.x,position.y, player.position.z))
		animationTree.spit_start(SPIT_ANTIC_DUR, SPIT_WOO_DUR)
	
func handle_big_lily(delta):
	time_big_lily+=delta
	if time_big_lily>=BIG_LILY_BEHAVIOR_TIME:
		time_big_lily = 0
		swipe_grab_switch = !swipe_grab_switch
		if swipe_grab_switch:
			start_swipe()
		else:
			grab_same_platform()
			
func start_grab(target):
	doing = true
	time_doing = 0
	grab_target = target
	grab_target_position = target.position
	grab = true
	time_bubble = 0
	time_swipe_diff = 0
	time_swipe_same = 0
	
func start_swipe():
	time_bubble = 0
	swipe = true
	doing = true
	time_doing = 0
	tongue_swipe()
	tongueHit = 0
	if Global.phase==1:
		time_grab -= 0.5
	else:
		time_slam -= 0.5
	time_swipe_same = 0
	time_swipe_diff = 0

func start_swimming():
	if prev_platform == null or platform == null:
		jump_to_water()
		return
	var dir = (prev_platform.position - platform.position).normalized()
	jump_direction(Vector3(platform.position.x + dir.x * radius, platform.position.y, platform.position.z + dir.z * radius))
	swimming = true
	time_swimming = 0
	init_angle = atan2(dir.z * radius, dir.x * radius)
	angle = init_angle

func update_swimming(delta):
	set_swimming_collision()
	animationTree.swim_idle()
	time_bubble += delta
	time_swimming += delta

	if time_swimming >= SWIMMING_TIME:
		swimming_stop = true
		if swimming_speed == 0:
			end_swimming()
			swimming_stop = false
			return

	if time_bubble >= WATER_BUBBLE_TIME and time_swimming <= SWIMMING_TIME:
		swimming_stop = true
		if swimming_speed == 0:
			handle_swimming_bubble_attack()
			swimming_stop = false
			return
			
	handle_acceleration(delta)
	animationTree.swim_start_swimming()
	update_swimming_movement(delta)

func end_swimming():
	jump_to_platform()
	triggered = true
	tongueHit = 0
	HPHit = 0
	swimming_accumulated_damage = 0

func handle_acceleration(delta:float):
	if swimming_stop:
		swimming_speed = max(0, swimming_speed - delta*MAX_SWIMMING_SPEED/SWIMMING_DECELERATION_TIME)
	else:
		swimming_speed = min(MAX_SWIMMING_SPEED, swimming_speed + delta * MAX_SWIMMING_SPEED/SWIMMING_ACCELERATION_TIME)

func handle_swimming_bubble_attack():
	animationTree.swim_bubble_atk_start()

	if not triggered_once and bubble_chargeup != null:
		triggered_once = true
		bubble_chargeup.fx_appear(0.1)
		create_tween().tween_callback(bubble_chargeup.fx_fade.bind(0.1)).set_delay(BUBBLE_ANTIC_DUR - 0.2)

		current_bubble_inst = WaterBubble.instantiate()
		get_parent().add_child(current_bubble_inst)
		current_bubble_inst.antic_phase = true
		current_bubble_inst.global_position = bubble_appear_pos.global_position
		current_bubble_inst.scale = Vector3.ZERO
		create_tween().tween_property(current_bubble_inst, "scale", Vector3.ONE, BUBBLE_ANTIC_DUR - 0.1)

	look_at(Vector3(player.position.x, position.y, player.position.z))

	if current_bubble_inst != null:
		current_bubble_inst.global_position = bubble_appear_pos.global_position

	if time_bubble >= WATER_BUBBLE_TIME + BUBBLE_ANTIC_DUR:
		triggered_once = false
		doing = true
		time_doing = 0
		time_bubble = 0
		bubble_spit(current_bubble_inst)
		bubble_num += 1
		if bubble_num == BUBBLE_NUM:
			bubble_num = 0
		else:
			time_bubble = WATER_BUBBLE_TIME
		current_bubble_inst = null
		animationTree.swim_bubble_atk_end_antic()

func update_swimming_movement(delta):
	if angle - init_angle > TAU:
		var dir = (platform.position - prev_platform.position).normalized()
		var target_position = Vector3(prev_platform.position.x + dir.x * radius, -0.15, prev_platform.position.z + dir.z * radius)
		var dir_frog = (target_position - position).normalized()
		if target_position.distance_to(position) > 0.2:
			look_at(Vector3(target_position.x, position.y, target_position.z))
			position += dir_frog * delta * swimming_speed
		else:
			init_angle = atan2(dir.z * radius, dir.x * radius)
			angle = init_angle
			var p = platform
			platform = prev_platform
			prev_platform = p
	else:
		var center_position = platform.position
		angle += delta / 10 * swimming_speed
		var x = center_position.x + cos(angle) * radius
		var z = center_position.z + sin(angle) * radius
		look_at(Vector3(x, -0.15, z))
		position = Vector3(x, -0.15, z)

func slam_reset():
	if platform != null and platform != player.platform:
		time_slam = 0
		
func is_on_big_lily():
	return platform!=null and platform.is_in_group("big_lily") and platform == player.platform

func can_slam():
	return (platform.is_in_group("stone_platform") and platform.health>0) || platform.is_in_group("big_lily")

func handle_slam():
	time_bubble = 0
	time_slam = 0
	time_swipe_same = 0
	time_swipe_diff = 0
	doing = true
	time_doing = 0
	animationTree.ground_slam_start(GROUND_SLAM_ANTIC_DUR)
	var indicCtrlr = instantiate_indicator_object(ground_slam_indicator, Vector3(platform.position.x,global_position.y,platform.position.z))
	indicCtrlr.appear(GROUND_SLAM_ANTIC_DUR * 0.75,1.8)
	get_tree().create_tween().tween_callback(indicCtrlr.fade.bind(0.5)).set_delay(GROUND_SLAM_ANTIC_DUR)
	
	slam = true

func can_eat():
	return path==[] and time_eat>=EAT_TIME

func handle_eating():
	if grab_target == null:
		grab_target = find_eat_target()
	elif grab_target.platform==platform:
		grab_target_position = grab_target.position
		if position.distance_to(grab_target.position)<grab_len_min or position.distance_to(grab_target.position)>grab_len_max:
			var point = find_point_on_platform(platform.global_position,grab_target.global_position,grab_len_min, grab_len_max)
			if point!=null:
				jump_direction(point)
				reset_eat_time()
		else:
			jump_direction(position)
			reset_eat_time()
	else:
		grab_target_position = grab_target.position 
		if platform != grab_target.platform:
			time_swipe_same = 0
			time_swipe_diff = 0
			plan_path(grab_target.platform)

func find_slam_platform_phase2():
	for s in get_parent().get_node("stonePlatforms").get_children():
		if s.health>0:
			plan_path(s)
			time_bubble = 0
			time_slam = 0
			time_swipe_same = 0
			time_swipe_diff -= 1
			return
	plan_path(get_parent().get_node("lilyPlatforms/largeLily"))

func set_ability_cooldown():
	if sluggish:
		SWIPE_DIFF_PLATFORM_TIME = SWIPE_DIFF_PLATFORM_TIME_CONST * 2
		SWIPE_SAME_PLATFORM_TIME = SWIPE_SAME_PLATFORM_TIME_CONST * 2
		SLAM_TIME = SLAM_TIME_CONST * 2
		SPIT_BUBBLE_TIME = SPIT_BUBBLE_TIME_CONST * 2
	else:
		SWIPE_DIFF_PLATFORM_TIME = SWIPE_DIFF_PLATFORM_TIME_CONST
		SWIPE_SAME_PLATFORM_TIME = SWIPE_SAME_PLATFORM_TIME_CONST
		SPIT_BUBBLE_TIME = SPIT_BUBBLE_TIME_CONST
		SLAM_TIME = SLAM_TIME_CONST
	
func set_movement_shape():
	if jump and velocity.y<0:
		$ground_player/CollisionShape3D.disabled = false
	else:
		$ground_player/CollisionShape3D.disabled = true
	if jump and velocity.y>0:
		$bodyShape.disabled = true
		$headShape.disabled = true
		$legShape.disabled = true
	elif velocity.y<=0:
		$bodyShape.disabled = false
		$legShape.disabled = false
		$headShape.disabled = false

func handle_movement(delta:float):
	set_movement_shape()
	if not swimming or jump:
		velocity.y += speed*gravity*delta
		var collision = move_and_collide(speed*velocity*delta)
		# collision and jump means end of jumping
		if collision and jump:
			if not swimming and collision.get_collider().is_in_group("water"):
				return
			animationTree.jump_end()
			
func handle_path_following():
	# jumping between platforms if path is not empty
	if path!=[] and not jump:
		jump_direction(path[0].global_position)
		path.pop_front()
		if path == [] and not triggered:
			doing = false
			time_doing = 0
	
func handle_tongue_extension(delta:float):
	if extended:
		if swimming:
			extended = false
			time_of_extend = 0
			animationTree.tongue_grab_end()
		else:
			time_of_extend += delta
			if time_of_extend >= TONGUE_EXTEND_TIME:
				extended = false
				time_of_extend = 0
				animationTree.tongue_grab_end()
				
func is_doing(delta:float)->bool:
	if doing or jump:
		time_doing += delta
		# prevents from freezing
		if doing and time_doing>=DOING_TIME:
			doing = false
			animationTree.idle()
			time_doing = 0
		return true
	return false
	
func reset_eat_time() -> void:
	time_doing = 0
	time_eat = 0
	time_swipe_same = 0
	time_swipe_diff = 0
	doing = true
	sluggish = true
	grab = true
	
func find_eat_target() -> Node:
	var fly_minions: Array[Node] = get_tree().get_nodes_in_group("minion")
	
	for fm in fly_minions:
		if fm.is_in_group("pickable") and fm.is_pickable():
			return fm
	
	return null
		
# spit and bubble attack
func bubble_spit(water_bubble_instance = null):
	var bubble
	if swimming:
		if water_bubble_instance != null:
			bubble = water_bubble_instance
			var distance = player.position.distance_to(bubble.position)
			#print(distance)
			if distance <= 5.0: #hacky hack
				bubble.ignore_collisions_time = 0.0
			
		else:
			bubble = WaterBubble.instantiate()
	else:
		bubble = AcidSpit.instantiate()
		
	#spit audio sfx
	AudioClipManager.play("res://assets/audio/sfx/Spit.mp3", 0.75)
		
	look_at(Vector3(player.position.x,position.y, player.position.z))
	if water_bubble_instance == null:
		get_parent().add_child(bubble)
		if not swimming:
			bubble.position = position-transform.basis.z*2
			bubble.position.y+=0.5
	bubble.shoot(player.position+Vector3(0,0.5,0))
	time_bubble = 0
	doing = false

func tongue_swipe():
	grab = false
	look_at(Vector3(player.position.x,position.y,player.position.z))
	animationTree.swipe_start(TONGUE_SWIPE_ANTIC_DUR)
	#play antic sfx
	AudioClipManager.play("res://assets/audio/sfx/ToadAttackAntic.wav")
	#play swipe sfx after antic delay
	get_tree().create_tween(). \
		tween_callback(AudioClipManager.play.bind("res://assets/audio/sfx/ToadTongueAttack.wav")). \
		set_delay(TONGUE_SWIPE_ANTIC_DUR)
	var indicCtrlr = instantiate_indicator_object(swipe_indicator,global_position)
	indicCtrlr.appear(TONGUE_SWIPE_ANTIC_DUR * 0.75,1.02)
	get_tree().create_tween().tween_callback(indicCtrlr.fade.bind(0.5)).set_delay(TONGUE_SWIPE_ANTIC_DUR)
	extended = true
	
func ground_slam():
	slam = false
	#play slam sfx
	AudioClipManager.play("res://assets/audio/sfx/ToadSlam.wav")
	
	if !platform.is_in_group("big_lily"):
		platform.health -= 1
	else:
		platform.sinked = true
	if player.platform == platform and player.position.distance_to(Vector3(platform.position.x,player.position.y, platform.position.z))<8:
		player.hit(null, SLAM_HP)
		player.get_node("CameraPivot").apply_shake()
	doing = false
	if platform.health == 0:
		if player.is_on_floor():
			player.launch((player.position - platform.position-Vector3(0,1,0)).normalized()*1.5)
		for s in get_parent().get_node("stonePlatforms").get_children():
			if s.health>0:
				plan_path(s)
				break
			plan_path(get_parent().get_node("lilyPlatforms/largeLily"))
		var num = platform.num
		var newShards = get_parent().get_node("breakable").get_child(num-1)
		newShards.break_platform(platform)
		if player.platform == platform:
			player.platform = newShards.get_node("stone2")
		transform_to_frozen()
	
func transform_to_frozen() -> void:
	body_mesh.set_surface_override_material(0, special_material)
	boss_data.start_health_special()
	
func transform_to_normal() -> void:
	body_mesh.set_surface_override_material(0, null)	
	
func find_point_on_platform(platform_position, player_position, min_distance, max_distance):
	var nav_distance = 2.5 # todo split this between large and small platforms, larger could use larger area
	var platform_top_left = Vector3(platform_position.x - nav_distance, platform_position.y, platform.position.z - nav_distance)
	var platform_bottom_right =  Vector3(platform_position.x + nav_distance, platform_position.y, platform.position.z + nav_distance)
	var target_point = null
	for x in range(int(platform_top_left.x), int(platform_bottom_right.x)):
		for z in range(int(platform_top_left.z), int(platform_bottom_right.z)):
			var point = Vector3(x, player.position.y, z)
			if point.distance_to(player_position) >= min_distance and point.distance_to(player_position)<=max_distance:
				target_point = point
	
	return target_point

func jump_direction(target_position):
	if target_position!=position:
		look_at(Vector3(target_position.x,position.y,target_position.z))	
	var height = target_position.y - global_position.y + HEIGHT_OF_ARC
	height = abs(height)
	var displacement_y = target_position.y-position.y
	var displacemnt_xz = Vector3(target_position.x-position.x,0,target_position.z-position.z)
	var velocity_y = Vector3.UP * sqrt(-2*gravity*height)
	var velocity_xz = displacemnt_xz/(sqrt(-2*height/gravity)+sqrt(2*(displacement_y-height)/gravity))
	velocity = velocity_y+velocity_xz
	jump = true
	animationTree.jump_start()

func extend():
	if extended:
		return
	animationTree.tongue_grab_start(TONGUE_GRAB_ANTIC_DUR)
	#play antic sfx
	AudioClipManager.play("res://assets/audio/sfx/ToadAttackAntic.wav")
	# delayed extend sfx play call
	get_tree().create_tween(). \
		tween_callback(AudioClipManager.play.bind("res://assets/audio/sfx/ToadTongueAttack.wav")). \
		set_delay(TONGUE_GRAB_ANTIC_DUR)
		
	var indicCtrlr = instantiate_indicator_object(grab_indicator,global_position)
	indicCtrlr.appear(TONGUE_GRAB_ANTIC_DUR * 0.75,1.02)
	get_tree().create_tween().tween_callback(indicCtrlr.fade.bind(0.5)).set_delay(TONGUE_GRAB_ANTIC_DUR)
	
	time_of_extend = 0
	tongueHit = 0
	return
	
func plan_path(target):
	path = []
	if platform == target:
		return
	var next = platform
	while target != next:
		var min = INF
		var o = null
		for n in next.neighbors:
			if n!=null:
				var dist = n.global_position.distance_to(target.global_position)
				if dist<min:
					min = dist
					o = n
		path.append(o)
		next = o
		
		
func jump_to_water():
	randomize()
	var i = randi() % platform.neighborStonePlatform.size()
	doing = true
	time_doing = 0
	time_bubble = 0
	plan_path(platform.neighborStonePlatform[i])


func jump_to_platform():
	if position.distance_to(platform.position)<position.distance_to(prev_platform.position):
		look_at(Vector3(platform.position.x, position.y, platform.position.z))
		jump_direction(Vector3(platform.position.x, 1.6, platform.position.z))
	else:
		look_at(Vector3(prev_platform.position.x, position.y, prev_platform.position.z))
		jump_direction(Vector3(prev_platform.position.x, 1.6, prev_platform.position.z))
	time_bubble = 0
	time_doing = 0
	doing = true
	swimming = false
	
func _on_swimming_critical_damage() -> void:
	#jump_to_platform()
	swimming_stop = true
	time_swimming = SWIMMING_TIME
	tongueHit = 0
	HPHit = 0
	triggered = true
	swimming_accumulated_damage = 0
	#sfx
	AudioClipManager.play("res://assets/audio/sfx/ToadBoulderHit.wav", 1.5)
	
func hit(area, health):
	var hit_pos: Vector3 = hit_body_pos.global_position
	
	# halves the damage taken from weak sources
	# TODO this whole method needs rework so we can modify final value
	if boss_data.health_special.has_any_health_left():
		if typeof(area) == TYPE_INT:
			area = area / 2
		if health <= WEAK_DAMAGE_ARMOR_PROTECTION:
			health = health / 2 
	
	if boss_data.get_current_health() == 100:
		time_bubble = 0
	if swimming:
		if area.is_in_group("boulder") and position.y < 1:
			boss_data.boss_take_damage(BOULDER_HP)
			hit_pos = hit_head_pos.global_position
			_on_swimming_critical_damage()
		if area.is_in_group("player_projectile") and area.is_in_group("ammo_standard"):
			boss_data.boss_take_damage(PEBBLE_HP)
			swimming_accumulated_damage += PEBBLE_HP
			if swimming_accumulated_damage >= TRIGGER_SWIMMING_END:
				hit_pos = hit_head_pos.global_position
				_on_swimming_critical_damage()
	else:
		sluggish = false
		# this one is probably obsolate
		if typeof(area) == TYPE_INT:
			boss_data.boss_take_damage(area)
		elif area == null:
			boss_data.boss_take_damage(health)
			#return #TODO this might be breaking transform stuff
						
		elif area.is_in_group("tongue"):
			tongueHit += 1
			boss_data.boss_take_damage(TONGUE_HP)
			if tongueHit>=2:
				tongueHit = 0
				time_of_extend = TONGUE_EXTEND_TIME
		elif area.is_in_group("body"):
			HPHit += LEG_HP
			time_stop = 5
			boss_data.boss_take_damage(LEG_HP)
		elif area.is_in_group("head"):
			HPHit += HEAD_HP
			boss_data.boss_take_damage(HEAD_HP)
			time_stop = 5
			hit_pos = hit_head_pos.global_position
		if HPHit >= TRIGGER_SWIMMING:
			triggered = true
	if Global.phase > 1:
		triggered = false
	
	if not boss_data.health_special.has_any_health_left() and body_mesh.get_surface_override_material_count() > 0:
		transform_to_normal()
	
	#hit vfx
	if hit_impact_VFX != null:
		var impactVFXObj = hit_impact_VFX.instantiate()
		get_parent().add_child(impactVFXObj)
		impactVFXObj.global_position = hit_pos
	if hit_VFX != null:
		hit_VFX.play_effect()
	
	if boss_data.get_current_health() <= 0:
		triggered = false
		doing = true
		if !GameInstance.CanTravelToNextLevel():
			#play death animation
			death_VFX.play_effect()
			pass
		await get_tree().create_timer(2.0).timeout
		GameInstance.PlayerVictorious()
	
func _on_ground_entered(area):
	if Global.phase >= 2:
		if area.is_in_group("stone_platform") or area.is_in_group("lily_platform"):
			platform = area
			return
	randomize()
	if area.is_in_group("stone_platform") or area.is_in_group("lily_platform"):
		if area.is_in_group("stone_platform") and area!=platform:
			if area.get_node("boulders/boulder1").is_visible()==false or area.get_node("boulders/boulder1").position.y<-3:
				area.get_node("boulders/boulder1").position = area.boulder1Position
				area.get_node("boulders/boulder1").linear_velocity = Vector3(0,0,0)
				area.get_node("boulders/boulder1").angular_velocity = Vector3(0,0,0)
				area.get_node("boulders/boulder1").show()
			else:
				var sign1 = 1 if randi() % 2 == 0 else -1
				var sign2 = 1 if randi() % 2 == 0 else -1
				area.get_node("boulders/boulder1").linear_velocity = Vector3(sign1*30,20,sign2*30)
				area.get_node("boulders/boulder1").launched = true
				area.get_node("boulders/boulder1").respawn_position = area.boulder1Position
			if area.get_node("boulders/boulder2").is_visible()==false or area.get_node("boulders/boulder2").position.y<-3:
				area.get_node("boulders/boulder2").position = area.boulder2Position
				area.get_node("boulders/boulder2").linear_velocity = Vector3(0,0,0)
				area.get_node("boulders/boulder2").angular_velocity = Vector3(0,0,0)
				area.get_node("boulders/boulder2").show()
			else:
				var sign1 = 1 if randi() % 2 == 0 else -1
				var sign2 = 1 if randi() % 2 == 0 else -1
				area.get_node("boulders/boulder2").linear_velocity = Vector3(sign1*30,20,sign2*30)
				area.get_node("boulders/boulder2").launched = true
				area.get_node("boulders/boulder2").respawn_position = area.boulder2Position
		if platform!=null and platform.is_in_group("stone_platform"):
			prev_platform = platform
		platform = area


func _on_tongue_body_entered(body):
	if body.is_in_group("player"):
		if swipe:
			body.hit(null, SWIPE_DAMAGE_HP)
			body.launch((body.position - position).normalized()*1.2)
		if grab:
			body.hit(null, GRAB_DAMAGE_HP)
			body.grab(position - body.position, position)
			extended = false
			time_of_extend = 0
			animationTree.tongue_grab_end()
			#var farestPlatform = []
			#var max = -INF
			#for p in get_parent().get_node("stonePlatforms").get_children():
		#		var dist = p.position.distance_to(platform.position)
		#		if dist>=max:
		#			if dist == max:
		#				farestPlatform.append(p)
		#			else:
		#				max = dist
		#				farestPlatform = [p]
		#	if farestPlatform==[]:
		#		return
		#	randomize()
		#	var i = randi()%farestPlatform.size()
		#	var newPlatform = farestPlatform[i]
		#	var height = newPlatform.position.y - player.position.y + 10
		#	height = abs(height)
		#	var displacement_y = newPlatform.position.y-player.position.y
		#	var displacemnt_xz = Vector3(newPlatform.position.x-player.position.x,0,newPlatform.position.z-player.position.z)
		#	var velocity_y = Vector3.UP * sqrt(-2*gravity*height)
		#	var velocity_xz = displacemnt_xz/(sqrt(-2*height/gravity)+sqrt(2*(displacement_y-height)/gravity))
		#	player.velocity = velocity_y+velocity_xz
		#	player.grabbed = true
	if body.is_in_group("spike"):
		if boss_data.health_special.has_any_health_left():
			hit(null, SPIKE_SPECIAL_HP)
		else:
			hit(null, SPIKE_HP)
	if body.is_in_group("minion"):
		_eat_fly(body)

# TODO some cool effect for this
# This is called when Swarm heals with special fly the boss
func special_fly_arrived(fly: Fly) -> void:
	boss_data.boss_heal(EAT_HP_BASE_RESTORE_PER_EATING + fly.eat_healing_value)
	fly.destroy()

# Frog eats Fly that is projectile, e.g. was thrown
func _eat_fly(fly_body: FlyProjectile) -> void:
	boss_data.boss_heal(EAT_HP_BASE_RESTORE_PER_EATING + fly_body.projectile_healing)
	fly_body.destroy()
	await get_tree().create_timer(0.2).timeout

	if platform.is_in_group("small_platform"):
		plan_path(get_parent().get_node("lilyPlatforms/largeLily"))
	

func _on_animation_finished(anim_name):
	if anim_name == "G_04-spit-antic":
		bubble_spit()
	if anim_name=="G_03-tongue_grab-end":
		extended = false
		doing = false
		tongueHit = 0
		$tongue/CollisionShape3D.disabled = true
		grab = false
	if anim_name == "G_03-tongue_grab-start":
		extended = true
		time_of_extend = 0
		$tongue/CollisionShape3D.disabled = false
	#if anim_name == "G_05-swipe-antic":
	#	$tongue/CollisionShape3D.disabled = false
	if anim_name == "G_05-swipe-start":
		extended = false
		doing = false
	#	$tongue/CollisionShape3D.disabled = false
		animationTree.swipe_end()
	if anim_name == "G_05-swipe-end":
		$tongue/CollisionShape3D.disabled = true
		swipe = false
		time_swipe_same = 0
		time_swipe_diff = 0
	if anim_name == "G_02-jump-end":
		jump = false
		if path == [] and triggered:
			triggered = false
			doing = false
			subphase = 1-subphase
		if grab:
			time_bubble = 0
			time_swipe_same = 0
			time_swipe_diff = 0
			time_grab = 0
			if grab_target_position == null:
				return
			look_at(Vector3(grab_target_position.x,position.y,grab_target_position.z))
			grab_target = null
			grab_target_position = null
			extend()
	#if anim_name == "G_07-ground_slam-antic":
	#	animationTree.ground_slam_start()
	if anim_name == "G_07-ground_slam-start":
		animationTree.ground_slam_end()
		ground_slam()
		
func _on_body_entered(body):
	# Handle only case, when Frog is swimming
	if swimming:
		_on_swimming_damage_taken(body)
		
func _on_swimming_damage_taken(source) -> void:
	# Swimming Frog can take damage from following two sources
	if source.is_in_group("boulder") and boulderHit > 5:
		boulderHit = 0
		hit(source, 0)
	if source.is_in_group("player_projectile") and source.is_in_group("ammo_standard"):
		hit(source, 0)

func instantiate_indicator_object(indicatorScene: PackedScene, ind_position:Vector3) -> ToadAtkIndicatorVFXController:
	var indicRoot: ToadAtkIndicatorVFXController = indicatorScene.instantiate()
	self.add_child(indicRoot)
	indicRoot.global_position = ind_position + Vector3(0, 0.1, 0)
	indicRoot.global_rotation = self.global_rotation
	
	indicRoot.setup()
	return indicRoot


func _on_ground_player(body: Node3D) -> void:
	move_and_slide()
	if body.is_in_group("player") and not is_on_floor():
		body.hit(null, JUMP_DAMAGE_HP)
		jump_direction(position)
		var dir = body.position - position
		dir.y = 0
		body.push(dir.normalized(),5)
