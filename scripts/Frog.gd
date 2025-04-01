extends CharacterBody3D

var speed:int = 2
var gravity:int = -10
var HEIGHT_OF_ARC:float = 4.5

var time_of_extend = 0
var time_bubble = 0
var time_swipe = 0
var time_grab = 0
var time_swimming = 0
var time_stop = 5
var time_slam = 0
var time_eat = 0
var EXTEND_TIME = 3
var SAME_PLATFORM_TIME = 2
var DIFF_PLATFORM_TIME = 10
var BUBBLE_TIME = 5
var WATER_BUBBLE_TIME = 4
var STOP_TIME = 5
var TONGUE_TIME = 10
var GRAB_TIME = 10
var SWIMMING_TIME = 30
var SLAM_TIME = 5
var EAT_TIME = 20

var grab = false
var slam = false
var doing = false
var swipe = false
var jump = false
var swimming = false
var boulderHit = 0
var tongue_hit = 0
var leg_hit = 0
var tongue = false
var extended = false
var triggered = false
var path:Array[Node]
var subphase = 0
var platform : Node
var prev_platform : Node
var grab_target = null

var radius = 12.5                        
var angle = 0.0
var init_angle = 0

@onready var player = get_parent().get_node("Player")
@onready var flies = get_parent().get_node("flies")
@onready var health = get_parent().get_node("Player/health/ui/health_boss")
var Bubble = preload("res://scenes/Bubble.tscn")
var WaterBubble = preload("res://scenes/WaterBubble.tscn")

	
func _physics_process(delta):
	boulderHit += delta
	time_stop += delta
	if time_stop < STOP_TIME:
		return
	if not swimming or jump:
		velocity.y += speed*gravity*delta
		var collision = move_and_collide(speed*velocity*delta)
		if collision and jump:
			if not swimming and collision.get_collider().is_in_group("water"):
				return
			if slam and collision.get_collider().is_in_group("stone_platform"):
				ground_slam()
			jump = false
			$AnimationPlayer.play("GAME_02-jump-end")
			if path == [] and triggered:
				triggered = false
				doing = false
				subphase = 1-subphase
				
	if path!=[] and not jump:
		jump_direction(path[0].global_position)
		path.pop_front()
		if path == [] and not triggered:
			doing = false
	
	if extended:
		if swimming:
			extended = false
			time_of_extend = 0
			$AnimationPlayer.play("GAME_03-tongue_grab-end")
		else:
			time_of_extend += delta
			if time_of_extend >= EXTEND_TIME:
				extended = false
				time_of_extend = 0
				$AnimationPlayer.play("GAME_03-tongue_grab-end")
	if doing:
		return
	if Global.phase == 1:
		if subphase == 0:
			time_bubble += delta
			time_swipe += delta
			time_grab += delta
			if triggered:
				jump_to_water()
				tongue_hit = 0
				leg_hit = 0
				return
			if health.health <= 25 and time_grab >= GRAB_TIME and not doing and platform==player.platform:
				if position.distance_to(player.position)<6.25 or position.distance_to(player.position)>6.35:
					var point = find_point_on_platform(platform.position,player.position,6.3)
					if point!=null:
						jump_direction(point)
					doing = true
					grab_target=player
					grab = true
			if health.health <= 25 and time_grab >= GRAB_TIME and not doing and platform!=player.platform and player.platform.is_in_group("stone_platform"):
				time_bubble = 0
				time_swipe = 0
				plan_path(player.platform)
				if path.size()<=3:
					doing = true
				else:
					path = []
			if health.health <= 50 and not doing:
				if platform == player.platform and time_swipe>SAME_PLATFORM_TIME:
					time_bubble = 0
					randomize()
					SAME_PLATFORM_TIME = randi()%2+2
					swipe = true
					doing = true
					$AnimationPlayer.play("GAME_03-tongue_grab-start")
					tongue_hit = 0
					time_swipe = 0
				if platform!=player.platform and platform.neighbors.has(player.platform) and time_swipe>DIFF_PLATFORM_TIME:
					time_bubble = 0
					swipe = true
					doing = true
					$AnimationPlayer.play("GAME_03-tongue_grab-start")
					tongue_hit = 0
					time_swipe = 0
			if health.health!=100 and time_bubble>BUBBLE_TIME and platform != player.platform and not doing:
				doing = true
				bubble_spit()
		else:
			if not swimming:
				var dir = (prev_platform.position-platform.position).normalized()
				jump_direction(Vector3(platform.position.x + dir.x * radius,platform.position.y - 1,platform.position.z + dir.z * radius))
				swimming = true
				time_swimming = 0
				init_angle = atan2(dir.z * radius, dir.x * radius) 
				angle = init_angle
			else:
				time_bubble += delta
				time_swimming += delta
				if time_swimming >= SWIMMING_TIME:
					jump_to_platform()
					triggered = true
					tongue_hit = 0
					leg_hit = 0
					return
				if time_bubble >= WATER_BUBBLE_TIME and time_swimming<=SWIMMING_TIME-4:
					look_at(Vector3(player.position.x,position.y, player.position.z))
					if time_bubble>=WATER_BUBBLE_TIME+0.5:
						doing = true
						time_bubble=0
						bubble_spit()
						return
					return
				if angle-init_angle>TAU:
					var dir = (platform.position-prev_platform.position).normalized()
					var target_position = Vector3(prev_platform.position.x + dir.x * radius,-1,prev_platform.position.z + dir.z * radius)					
					var dir_frog = (target_position - position).normalized()
					if target_position.distance_to(position)>0.2:
						look_at(Vector3(target_position.x,position.y, target_position.z))
						position += dir_frog*delta*10
					else:
						init_angle = atan2(dir.z * radius, dir.x * radius) 
						angle = init_angle
						var p = platform
						platform = prev_platform
						prev_platform = p
				else:
					var center_position = platform.position 
					angle += delta
					var x = center_position.x + cos(angle) * radius
					var z = center_position.z + sin(angle) * radius
					look_at(Vector3(x, -1, z))
					position = Vector3(x, -1, z)
	elif Global.phase==2:
		time_bubble += delta
		time_swipe += delta
		time_grab += delta
		time_slam += delta
		time_of_extend += delta
		time_eat+=delta
		if platform!=null and platform != player.platform and platform.is_in_group("stone_platform") and platform.health>0:
			time_slam = 0
			
		if path==[] and time_eat>=EAT_TIME:
			if grab_target==null:
				for fly in flies.get_children():
					if fly.groupSize>=3 and ((fly.platform.is_in_group("big_lily") and fly.platform.is_in_group("lily_platform")) or (not fly.platform.is_in_group("shard")) and fly.platform.is_in_group("stone_platform")):
						grab_target = fly
						break
			elif grab_target.platform==platform:
				if position.distance_to(grab_target.position)<6.25 or position.distance_to(grab_target.position)>6.35:
					var point = find_point_on_platform(platform.position,grab_target.position,6.3)
					if point!=null:
						jump_direction(point)
					doing = true
					time_eat = 0
					time_swipe = 0
					grab = true
			else:
				if platform != grab_target.platform:
					time_swipe = 0
					plan_path(grab_target.platform)
					
		if time_slam>SLAM_TIME:
			if platform.is_in_group("stone_platform") and platform.health>0:
				if platform == player.platform:
					time_bubble = 0
					time_slam = 0
					randomize()
					SLAM_TIME = randi()%5+5
					doing = true
					jump_direction(position)
					slam = true
			else:
				for s in get_parent().get_node("stonePlatforms").get_children():
					if s.health>0:
						plan_path(s)
						time_bubble = 0
						time_slam = 0
						return
				plan_path(get_parent().get_node("lilyPlatforms/largeLily"))
		if health.health <= 50 and not doing:
			if platform!=null and platform == player.platform and time_swipe>SAME_PLATFORM_TIME:
				time_bubble = 0
				randomize()
				SAME_PLATFORM_TIME = randi()%2+2
				swipe = true
				doing = true
				$AnimationPlayer.play("GAME_03-tongue_grab-start")
				tongue_hit = 0
				time_swipe = 0
			if platform!=null and platform!=player.platform and platform.neighbors.has(player.platform) and time_swipe>DIFF_PLATFORM_TIME:
				time_bubble = 0
				swipe = true
				doing = true
				$AnimationPlayer.play("GAME_03-tongue_grab-start")
				tongue_hit = 0
				time_swipe = 0
		if health.health!=100 and time_bubble>BUBBLE_TIME and platform!=null and platform != player.platform and not doing:
				doing = true
				bubble_spit()
	if not $AnimationPlayer.is_playing() and not swipe and not extended:
		$AnimationPlayer.play("GAME_01-idle")
	

func bubble_spit():
	var bubble
	if swimming:
		bubble = WaterBubble.instantiate()
	else:
		bubble = Bubble.instantiate()
	get_parent().add_child(bubble)
	bubble.position = position-transform.basis.z*2
	bubble.position.y+=0.2
	look_at(Vector3(player.position.x,position.y, player.position.z))
	bubble.shoot(player.position)
	time_bubble = 0
	doing = false


func tongue_swipe():
	var tween = get_tree().create_tween()
	tween.tween_property(self,"rotation",self.rotation+Vector3(0,6.2,0),0.5)
	tween.tween_callback(after_swipe)


func after_swipe():
	$AnimationPlayer.play("GAME_03-tongue_grab-end")
	swipe = false
	time_swipe = 0
	
func ground_slam():
	slam = false
	platform.health -= 1
	player.hit(player.get_node("CollisionShape3D"))
	player.get_node("CameraPivot").apply_shake()
	doing = false
	if platform.health == 0:
		player.launch(platform.position-player.position+Vector3(0,1.2,0))
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
		platform.queue_free()
		platform = newShards.get_node("stone1")
		newShards.get_node("AnimationPlayer").play("break")
	
func find_point_on_platform(platform_position, player_position, distance):
	var platform_top_left = Vector3(platform_position.x - 14 / 2, platform_position.y, platform.position.z - 14 / 2)
	var platform_bottom_right =  Vector3(platform_position.x + 14 / 2, platform_position.y, platform.position.z + 14 / 2)
	for x in range(int(platform_top_left.x), int(platform_bottom_right.x)):
		for z in range(int(platform_top_left.z), int(platform_bottom_right.z)):
			var point = Vector3(x, player.position.y, z)
			if point.distance_to(player_position) >= distance-0.1 and point.distance_to(player_position)<=distance+0.1:
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
	$AnimationPlayer.play("GAME_02-jump-start")

func extend():
	if extended:
		return
	$AnimationPlayer.play("GAME_03-tongue_grab-start")
	time_of_extend = 0
	tongue_hit = 0
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
	swimming = false
	
func hit(area):
	if health.health == 100:
		time_bubble = 0
	if swimming:
		if area.is_in_group("boulder"):
			health.decHealth(20)
			jump_to_platform()
			tongue_hit = 0
			leg_hit = 0
			triggered = true
		if area.is_in_group("pebble"):
			health.decHealth(1)
	else:
		if area.is_in_group("tongue"):
			tongue_hit += 1
			if tongue_hit>=5:
				health.decHealth(5)
				tongue_hit = 0
				if time_stop>=STOP_TIME:
					time_stop = 0
				else:
					time_stop = 5
			elif tongue_hit==3:
				health.decHealth(5)
		if area.is_in_group("body"):
			leg_hit += 1
			time_stop = 5
			health.decHealth(5)
			if leg_hit == 2:
				triggered = true
		if area.is_in_group("head"):
			health.decHealth(10)
			time_stop = 5
			triggered = true
	if Global.phase > 1:
		triggered = false
	if health.health<=0:
		Global.changeScene()

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
				area.get_node("boulders/boulder1").linear_velocity = Vector3(sign1*10,10,sign2*10)
			if area.get_node("boulders/boulder2").is_visible()==false or area.get_node("boulders/boulder2").position.y<-3:
				area.get_node("boulders/boulder2").position = area.boulder2Position
				area.get_node("boulders/boulder2").linear_velocity = Vector3(0,0,0)
				area.get_node("boulders/boulder2").angular_velocity = Vector3(0,0,0)
				area.get_node("boulders/boulder2").show()
			else:
				var sign1 = 1 if randi() % 2 == 0 else -1
				var sign2 = 1 if randi() % 2 == 0 else -1
				area.get_node("boulders/boulder2").linear_velocity = Vector3(sign1*10,10,sign2*10)
		if platform!=null and platform.is_in_group("stone_platform"):
			prev_platform = platform
		platform = area


func _on_tongue_body_entered(body):
	if body.is_in_group("player"):
		if swipe:
			body.hit(body.get_node("CollisionShape3D"))
			body.launch(transform.basis.z)
		if grab:
			body.hit(body.get_node("CollisionShape3D"))
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
		hit($head)
		hit($head)
	if body.is_in_group("fly"):
		body.queue_free()


func _on_animation_finished(anim_name):
	if anim_name=="GAME_03-tongue_grab-end":
		extended = false
		doing = false
		$tongue/CollisionShape3D.disabled = true
		$tongueShape.disabled = true
		grab = false
	if anim_name == "GAME_03-tongue_grab-start":
		extended = true
		$tongue/CollisionShape3D.disabled = false
		$tongueShape.disabled = false
		if swipe:
			grab = false
			tongue_swipe()
	if anim_name == "GAME_02-jump-end":
		if grab:
			time_bubble = 0
			time_swipe = 0
			time_grab = 0
			look_at(Vector3(grab_target.position.x,position.y,grab_target.position.z))
			grab_target = null
			extend()


func _on_head_entered(body):
	if body.is_in_group("boulder") and boulderHit>5 and swimming:
		boulderHit = 0
		hit(body)


func _on_body_entered(body):
	if body.is_in_group("boulder") and boulderHit>5 and swimming:
		boulderHit = 0
		hit(body)
