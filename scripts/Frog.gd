extends CharacterBody3D
class_name Frog

@export var animationPlayer : AnimationPlayer
@onready var animationTree : ToadAnimationController = $AnimationTree

# speed on ground
@export var speed:int = 2
# swimming speed
@export var swimming_speed = 10
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
@export var SWIPE_DIFF_PLATFORM_TIME = 10
@export var SLAM_TIME_CONST = 5
@export var SWIPE_SAME_PLATFORM_TIME_CONST = 2
@export var SWIPE_DIFF_PLATFORM_TIME_CONST = 10
@export var SPIT_BUBBLE_TIME_CONST = 5

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
@export var EAT_TIME = 20

# Player's HP lost by slam 
@export var SLAM_HP = 10
# Player's HP lost by swipe 
@export var SWIPE_DAMAGE_HP = 5
# Player's HP lost by grab
@export var GRAB_DAMAGE_HP = 5
# HP lost by leg hit
@export var LEG_HP = 5
# HP lost by head hit
@export var HEAD_HP = 10
# HP lost by boulder hit
@export var BOULDER_HP = 20
# HP lost by spike hit
@export var SPIKE_HP = 20
# HP lost by pebble hit
@export var PEBBLE_HP = 1
# HP lost to trigger swimming
@export var TRIGGER_SWIMMING = 10

# must be bigger than attack length
var DOING_TIME = 10

var grab = false
var slam = false
var doing = false
var swipe = false
var jump = false
var swimming = false
var sluggish = false
var bubble_num = 0
var boulderHit = 0
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

# radius of path around platform for swimming
var radius = 12.5                  
var angle = 0.0
var init_angle = 0

var grab_len_max = 6*2
var grab_len_min = 6

@export var boss_data: BossDataModel = preload("res://data_resources/FrogBossDataModel.tres")
@onready var player: PlayerBase = get_parent().get_node("Player")
@onready var flies = get_parent().get_node("flies")
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
	
	# is stopped and do nothing
	if time_stop < STOP_TIME:
		return
	
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
		
	if jump and velocity.y>0:
		$bodyShape.disabled = true
		$headShape.disabled = true
		$legShape.disabled = true
	elif velocity.y<=0:
		$bodyShape.disabled = false
		$legShape.disabled = false
		$headShape.disabled = false
	
	# character moving
	if not swimming or jump:
		velocity.y += speed*gravity*delta
		var collision = move_and_collide(speed*velocity*delta)
		# collision and jump means end of jumping
		if collision and jump:
			if not swimming and collision.get_collider().is_in_group("water"):
				return
			animationTree.jump_end()
	
	# jumping between platforms if path is not empty
	if path!=[] and not jump:
		jump_direction(path[0].global_position)
		path.pop_front()
		if path == [] and not triggered:
			doing = false
			time_doing = 0
	
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
				
	if doing or jump:
		time_doing += delta
		# prevents from freezing
		if doing and time_doing>=DOING_TIME:
			doing = false
			animationTree.idle()
			time_doing = 0
		return
		
	if Global.phase == 1:
		if subphase == 0:
			$body/bodyShape.disabled = false
			$body/legShape.disabled = false
			$body/swimmingShape.disabled = true
			$headShape.disabled = false
			$bodyShape.disabled = false
			$legShape.disabled = false
			if triggered:
				jump_to_water()
				tongueHit = 0
				HPHit = 0
				return
			time_grab += delta
			if boss_data.get_current_health() <= GRAB_HP and time_grab >= GRAB_TIME and not doing and platform==player.platform:
				if position.distance_to(player.position)<grab_len_min or position.distance_to(player.position)>grab_len_max:
					var point = find_point_on_platform(platform.global_position,player.global_position,grab_len_min, grab_len_max)
					if point!=null:
						jump_direction(point)
						doing = true
						time_doing = 0
						grab_target=player
						grab = true
						time_bubble = 0
						time_swipe_diff = 0
						time_swipe_same = 0
				else:
					jump_direction(position)
					doing = true
					time_doing = 0
					grab_target = player
					grab = true
					time_bubble = 0
					time_swipe_diff = 0
					time_swipe_same = 0
			if boss_data.get_current_health() <= GRAB_HP and time_grab >= GRAB_TIME and not doing and platform!=player.platform and player.platform.is_in_group("stone_platform"):
				time_bubble = 0
				time_swipe_diff = 0
				time_swipe_same = 0
				plan_path(player.platform)
				if path.size()<=3:
					doing = true
					time_doing = 0
				else:
					path = []
			if boss_data.get_current_health() <= SWIPE_HP and not doing:
				time_swipe_diff += delta
				time_swipe_same += delta
				if platform == player.platform and time_swipe_same>SWIPE_SAME_PLATFORM_TIME:
					time_bubble = 0
					swipe = true
					doing = true
					time_doing = 0
					tongue_swipe()
					tongueHit = 0
					time_grab -= 1
					time_swipe_same = 0
					time_swipe_diff = 0
				if platform!=player.platform and platform.neighbors.has(player.platform) and time_swipe_diff>SWIPE_DIFF_PLATFORM_TIME:
					time_bubble = 0
					swipe = true
					doing = true
					time_doing = 0
					tongue_swipe()
					time_grab -= 1
					tongueHit = 0
					time_swipe_same = 0
					time_swipe_diff = 0
			if boss_data.get_current_health() != 100 and not doing:
				time_bubble += delta
				if time_bubble>SPIT_BUBBLE_TIME and platform != player.platform:
					doing = true
					time_doing = 0
					time_swipe_diff -= 1
					time_swipe_same = 0 
					animationTree.spit_start(SPIT_ANTIC_DUR, SPIT_WOO_DUR)
					bubble_spit()
					#animationTree.spit_end()
		else:
			if not swimming:
				if prev_platform==null or platform==null:
					jump_to_water()
					return
				var dir = (prev_platform.position-platform.position).normalized()
				jump_direction(Vector3(platform.position.x + dir.x * radius,platform.position.y,platform.position.z + dir.z * radius))
				swimming = true
				time_swimming = 0
				init_angle = atan2(dir.z * radius, dir.x * radius) 
				angle = init_angle
			else:
				$body/bodyShape.disabled = true
				$body/legShape.disabled = true
				$body/swimmingShape.disabled = false
				$headShape.disabled = true
				$bodyShape.disabled = true
				$legShape.disabled = true
				animationTree.swim_idle()
				time_bubble += delta
				time_swimming += delta
				if time_swimming >= SWIMMING_TIME:
					jump_to_platform()
					triggered = true
					tongueHit = 0
					HPHit = 0
					return
				if time_bubble >= WATER_BUBBLE_TIME and time_swimming<=SWIMMING_TIME:
					animationTree.swim_bubble_atk_start()
					# play antic chargeup vfx and inst and scale up bubble proj
					if not triggered_once and bubble_chargeup != null:
						triggered_once = true
						bubble_chargeup.fx_appear(0.1)
						create_tween().tween_callback(bubble_chargeup.fx_fade.bind(0.1)).set_delay(BUBBLE_ANTIC_DUR - 0.2)
						#instatiate bubble and tween its scale to one
						current_bubble_inst = WaterBubble.instantiate()
						get_parent().add_child(current_bubble_inst)
						current_bubble_inst.antic_phase = true
						current_bubble_inst.global_position = bubble_appear_pos.global_position
						current_bubble_inst.scale = Vector3.ZERO
						create_tween().tween_property(current_bubble_inst, "scale", Vector3.ONE, BUBBLE_ANTIC_DUR - 0.1)
					look_at(Vector3(player.position.x,position.y, player.position.z))
					if current_bubble_inst != null: current_bubble_inst.global_position = bubble_appear_pos.global_position
					if time_bubble>=WATER_BUBBLE_TIME + BUBBLE_ANTIC_DUR:
						triggered_once = false
						doing = true
						time_doing = 0
						time_bubble=0
						bubble_spit(current_bubble_inst)
						bubble_num += 1
						if bubble_num==BUBBLE_NUM:
							bubble_num = 0
						else:
							time_bubble = WATER_BUBBLE_TIME
						current_bubble_inst = null
						animationTree.swim_bubble_atk_end_antic()
						return
					return
				animationTree.swim_start_swimming()
				if angle-init_angle>TAU:
					var dir = (platform.position-prev_platform.position).normalized()
					var target_position = Vector3(prev_platform.position.x + dir.x * radius,-0.15,prev_platform.position.z + dir.z * radius)					
					var dir_frog = (target_position - position).normalized()
					if target_position.distance_to(position)>0.2:
						look_at(Vector3(target_position.x,position.y, target_position.z))
						position += dir_frog*delta*swimming_speed
					else:
						init_angle = atan2(dir.z * radius, dir.x * radius) 
						angle = init_angle
						var p = platform
						platform = prev_platform
						prev_platform = p
				else:
					var center_position = platform.position 
					angle += delta/10*swimming_speed
					var x = center_position.x + cos(angle) * radius
					var z = center_position.z + sin(angle) * radius
					look_at(Vector3(x, -0.15, z))
					position = Vector3(x, -0.15, z)
	elif Global.phase==2:
		time_of_extend += delta
		time_eat+=delta
		if platform!=null and platform != player.platform and platform.is_in_group("stone_platform") and platform.health>0:
			time_slam = 0
		if path==[] and time_eat>=EAT_TIME:
			if grab_target==null:
				for fly in flies.get_children():
					if fly.groupSize>=3 and ((fly.platform.is_in_group("big_lily")) or (not fly.platform.is_in_group("shard")) and fly.platform.is_in_group("stone_platform")):
						grab_target = fly
						break
			elif grab_target.platform==platform:
				if position.distance_to(grab_target.position)<grab_len_min or position.distance_to(grab_target.position)>grab_len_max:
					var point = find_point_on_platform(platform.global_position,grab_target.global_position,grab_len_min, grab_len_max)
					if point!=null:
						jump_direction(point)
						doing = true
						time_doing = 0
						time_eat = 0
						time_swipe_same = 0
						time_swipe_diff = 0
						sluggish = true
						grab = true
				else:
					jump_direction(position)
					doing = true
					time_doing = 0
					time_eat = 0
					time_swipe_same = 0
					time_swipe_diff = 0
					sluggish = true
					grab = true
			else:
				if platform != grab_target.platform:
					time_swipe_same = 0
					time_swipe_diff = 0
					plan_path(grab_target.platform)
		time_slam += delta
		if time_slam>SLAM_TIME:
			if platform.is_in_group("stone_platform") and platform.health>0:
				if platform == player.platform:
					time_bubble = 0
					time_slam = 0
					time_swipe_same = 0
					time_swipe_diff = 0
					doing = true
					time_doing = 0
					animationTree.ground_slam_start(GROUND_SLAM_ANTIC_DUR)
					
					var indicCtrlr = instantiate_indicator_object(ground_slam_indicator)
					indicCtrlr.appear(GROUND_SLAM_ANTIC_DUR * 0.75)
					get_tree().create_tween().tween_callback(indicCtrlr.fade.bind(0.5)).set_delay(GROUND_SLAM_ANTIC_DUR)
					
					slam = true
			else:
				for s in get_parent().get_node("stonePlatforms").get_children():
					if s.health>0:
						plan_path(s)
						time_bubble = 0
						time_slam = 0
						time_swipe_same = 0
						time_swipe_diff -= 1
						return
				plan_path(get_parent().get_node("lilyPlatforms/largeLily"))
		if boss_data.get_current_health() <= SWIPE_HP and not doing:
			time_swipe_same += delta
			time_swipe_diff += delta
			if platform!=null and platform == player.platform and time_swipe_same>SWIPE_SAME_PLATFORM_TIME:
				time_bubble = 0
				swipe = true
				doing = true
				time_doing = 0
				tongue_swipe()
				tongueHit = 0
				time_swipe_same = 0
				time_swipe_diff = 0
			if platform!=null and platform!=player.platform and platform.neighbors.has(player.platform) and time_swipe_diff>SWIPE_DIFF_PLATFORM_TIME:
				time_bubble = 0
				swipe = true
				doing = true
				time_doing = 0
				tongue_swipe()
				tongueHit = 0
				time_swipe_same = 0
				time_swipe_diff = 0
		time_bubble += delta
		if boss_data.get_current_health() !=100 and time_bubble>SPIT_BUBBLE_TIME and platform!=null and platform != player.platform and not doing:
				doing = true
				time_doing = 0
				animationTree.spit_start(SPIT_ANTIC_DUR, SPIT_WOO_DUR)
				bubble_spit()
				#animationTree.spit_end()
	
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
	look_at(Vector3(player.position.x,position.y, player.position.z))
	if water_bubble_instance == null:
		get_parent().add_child(bubble)
		if not swimming:
			bubble.position = position-transform.basis.z*2
			bubble.position.y+=0.5
	bubble.shoot(player.position)
	time_bubble = 0
	doing = false

func tongue_swipe():
	grab = false
	look_at(Vector3(player.position.x,position.y,player.position.z))
	animationTree.swipe_start(TONGUE_SWIPE_ANTIC_DUR)
	
	var indicCtrlr = instantiate_indicator_object(swipe_indicator)
	indicCtrlr.appear(TONGUE_SWIPE_ANTIC_DUR * 0.75)
	get_tree().create_tween().tween_callback(indicCtrlr.fade.bind(0.5)).set_delay(TONGUE_SWIPE_ANTIC_DUR)
	extended = true
	#var tween = get_tree().create_tween()
	#tween.tween_property(self,"rotation",self.rotation+Vector3(0,6.2,0),0.5)
	#tween.tween_callback(after_swipe)


#func after_swipe():
#	animationPlayer.play("G_03-tongue_grab-end")
#	swipe = false
#	time_swipe = 0
	
func ground_slam():
	slam = false
	platform.health -= 1
	if player.platform == platform:
		player.hit(SLAM_HP)
		player.get_node("CameraPivot").apply_shake()
	doing = false
	if platform.health == 0:
		if player.is_on_floor():
			player.launch((player.position - platform.position-Vector3(0,1,0)).normalized()*1.2)
		for s in get_parent().get_node("stonePlatforms").get_children():
			if s.health>0:
				plan_path(s)
				break
			plan_path(get_parent().get_node("lilyPlatforms/largeLily"))
		var num = platform.num
		var newShards = get_parent().get_node("breakable").get_child(num-1)
		newShards.get_node("stone1").neighbors.append_array(platform.neighbors)
		newShards.get_node("stone2").neighbors.append_array(platform.neighbors)
		newShards.get_node("stone3").neighbors.append_array(platform.neighbors)
		newShards.get_node("stone4").neighbors.append_array(platform.neighbors)
		if player.platform == platform:
			player.platform = newShards.get_node("stone2")
		platform.queue_free()
		platform = newShards.get_node("stone1")
		newShards.get_node("AnimationPlayer").play("break")
	
func find_point_on_platform(platform_position, player_position, min_distance, max_distance):
	var platform_top_left = Vector3(platform_position.x - 9 / 2, platform_position.y, platform.position.z - 9 / 2)
	var platform_bottom_right =  Vector3(platform_position.x + 9 / 2, platform_position.y, platform.position.z + 9 / 2)
	for x in range(int(platform_top_left.x), int(platform_bottom_right.x)):
		for z in range(int(platform_top_left.z), int(platform_bottom_right.z)):
			var point = Vector3(x, player.position.y, z)
			if point.distance_to(player_position) >= min_distance and point.distance_to(player_position)<=max_distance:
				return point
	return null

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
	
	var indicCtrlr = instantiate_indicator_object(grab_indicator)
	indicCtrlr.appear(TONGUE_GRAB_ANTIC_DUR * 0.75)
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
	doing = true
	time_doing = 0
	swimming = false
	
	
func hit(area):
	var hit_pos: Vector3 = hit_body_pos.global_position
	if boss_data.get_current_health() == 100:
		time_bubble = 0
	if swimming:
		if area.is_in_group("boulder") and position.y < 1:
			boss_data.boss_decrease_health(BOULDER_HP)
			jump_to_platform()
			tongueHit = 0
			HPHit = 0
			triggered = true
			hit_pos = hit_head_pos.global_position
		if area.is_in_group("pebble"):
			boss_data.boss_decrease_health(PEBBLE_HP)
	else:
		sluggish = false
		if typeof(area) == TYPE_INT:
			boss_data.boss_decrease_health(area)
		if area.is_in_group("tongue"):
			tongueHit += 1
			if tongueHit>=5:
				boss_data.boss_decrease_health(5)
				tongueHit = 0
				if time_stop>=STOP_TIME:
					time_stop = 0
				else:
					time_stop = 5
			elif tongueHit==3:
				boss_data.boss_decrease_health(5)
		if area.is_in_group("body"):
			HPHit += LEG_HP
			time_stop = 5
			boss_data.boss_decrease_health(LEG_HP)
		if area.is_in_group("head"):
			HPHit += HEAD_HP
			boss_data.boss_decrease_health(HEAD_HP)
			time_stop = 5
			hit_pos = hit_head_pos.global_position
		if HPHit >= TRIGGER_SWIMMING:
			triggered = true
	if Global.phase > 1:
		triggered = false
	if boss_data.get_current_health() <= 0:
		GameInstance.PlayerVictorious()
		
	#hit vfx
	if hit_impact_VFX != null:
		var impactVFXObj = hit_impact_VFX.instantiate()
		get_parent().add_child(impactVFXObj)
		impactVFXObj.global_position = hit_pos
	if hit_VFX != null:
		hit_VFX.play_effect()
	
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
			body.hit(SWIPE_DAMAGE_HP)
			body.launch((body.position - position).normalized()*1.2)
		if grab:
			body.hit(GRAB_DAMAGE_HP)
			var farestPlatform = []
			var max = -INF
			for p in get_parent().get_node("stonePlatforms").get_children():
				var dist = p.position.distance_to(platform.position)
				if dist>=max:
					if dist == max:
						farestPlatform.append(p)
					else:
						max = dist
						farestPlatform = [p]
			if farestPlatform==[]:
				return
			randomize()
			var i = randi()%farestPlatform.size()
			var newPlatform = farestPlatform[i]
			var height = newPlatform.position.y - player.position.y + 10
			height = abs(height)
			var displacement_y = newPlatform.position.y-player.position.y
			var displacemnt_xz = Vector3(newPlatform.position.x-player.position.x,0,newPlatform.position.z-player.position.z)
			var velocity_y = Vector3.UP * sqrt(-2*gravity*height)
			var velocity_xz = displacemnt_xz/(sqrt(-2*height/gravity)+sqrt(2*(displacement_y-height)/gravity))
			player.velocity = velocity_y+velocity_xz
			player.grabbed = true
	if body.is_in_group("spike"):
		hit(SPIKE_HP)
	if body.is_in_group("fly"):
		body.queue_free()


func _on_animation_finished(anim_name):
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
			if grab_target == null:
				return
			look_at(Vector3(grab_target.position.x,position.y,grab_target.position.z))
			grab_target = null
			extend()
	if anim_name == "G_07-ground_slam-start":
		animationTree.ground_slam_end()
		ground_slam()
		
func _on_body_entered(body):
	if body.is_in_group("boulder") and boulderHit>5 and swimming:
		boulderHit = 0
		hit(body)
	if body.is_in_group("pebble") and swimming:
		hit(body)

func instantiate_indicator_object(indicatorScene: PackedScene) -> ToadAtkIndicatorVFXController:
	var indicRoot: ToadAtkIndicatorVFXController = indicatorScene.instantiate()
	self.add_child(indicRoot)
	indicRoot.global_position = self.global_position + Vector3(0, 0.1, 0)
	indicRoot.global_rotation = self.global_rotation
	
	indicRoot.setup()
	return indicRoot
